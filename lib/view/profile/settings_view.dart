// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectify/services/auth_services.dart';
import 'package:connectify/view/auth/login_view.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SettingsView extends StatefulWidget {
  final String uid;
  final String email;

  const SettingsView({super.key, required this.uid, required this.email});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  bool _notificationsEnabled = true;
  bool _darkMode = false;
  bool _loading = true;
  String _appVersion = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    // Load preferences from Firestore
    final doc = await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .get();
    if (doc.exists) {
      final data = doc.data()!;
      _notificationsEnabled = data['notificationsEnabled'] ?? true;
      _darkMode = data['darkMode'] ?? false;
    }

    // Load app version
    try {
      final info = await PackageInfo.fromPlatform();
      _appVersion = 'v${info.version} (${info.buildNumber})';
    } catch (_) {
      _appVersion = 'v1.0.0';
    }

    setState(() => _loading = false);
  }

  Future<void> _updateSetting(String key, dynamic value) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.uid)
        .update({key: value});
  }

  // LOGOUT
  Future<void> _logout() async {
    final confirmed = await _confirm(
      title: 'Log Out',
      message: 'Are you sure you want to log out?',
      confirmLabel: 'Log Out',
      confirmColor: Colors.red,
    );
    if (!confirmed) return;

    await AuthServices().logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginView()),
      (_) => false,
    );
  }

  // ── CHANGE PASSWORD
  Future<void> _showChangePasswordDialog() async {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Change Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "We'll send a password reset link to your email address.",
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 10),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(Icons.email_outlined,
                      size: 16, color: Colors.grey),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.email,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 13),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: Colors.black),
            onPressed: () async {
              Navigator.pop(context);
              await AuthServices().resetPassword(widget.email);
            },
            child: const Text('Send Reset Email'),
          ),
        ],
      ),
    );
  }

  // ── DELETE ACCOUNT ────────────────────────────────────────────────────────
  Future<void> _showDeleteAccountDialog() async {
    final passwordController = TextEditingController();
    bool isDeleting = false;

    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          title: const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: Colors.red),
              SizedBox(width: 8),
              Text('Delete Account',
                  style: TextStyle(color: Colors.red)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'This will permanently delete:\n'
                '• Your account & profile\n'
                '• Your provider profile (if any)\n'
                '• All your bookings\n\n'
                'This cannot be undone.',
                style: TextStyle(fontSize: 13, height: 1.6),
              ),
              const SizedBox(height: 16),
              const Text('Enter your password to confirm:',
                  style: TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 8),
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: InputDecoration(
                  hintText: 'Your password',
                  prefixIcon: const Icon(Icons.lock_outline),
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed:
                    isDeleting ? null : () => Navigator.pop(dialogContext),
                child: const Text('Cancel')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                disabledBackgroundColor: Colors.red.shade200,
              ),
              onPressed: isDeleting
                  ? null
                  : () async {
                      final password = passwordController.text.trim();
                      if (password.isEmpty) return;

                      setDialogState(() => isDeleting = true);

                      final reauthed = await AuthServices()
                          .reauthenticate(
                              email: widget.email, password: password);

                      if (!reauthed) {
                        setDialogState(() => isDeleting = false);
                        return;
                      }

                      try {
                        await AuthServices().deleteAccount();
                      } catch (e) {
                        setDialogState(() => isDeleting = false);
                        if (!dialogContext.mounted) return;
                        ScaffoldMessenger.of(dialogContext).showSnackBar(
                            SnackBar(
                                content: Text('Failed to delete: $e')));
                        return;
                      }

                      if (!dialogContext.mounted) return;
                      Navigator.of(dialogContext).pop();

                      if (!mounted) return;
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const LoginView()),
                        (_) => false,
                      );
                    },
              child: isDeleting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Text('Delete My Account',
                      style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  // ── CONFIRM DIALOG ────────────────────────────────────────────────────────
  Future<bool> _confirm({
    required String title,
    required String message,
    required String confirmLabel,
    Color confirmColor = Colors.black,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title),
        content: Text(message,
            style: const TextStyle(color: Colors.grey, fontSize: 13)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          ElevatedButton(
            style:
                ElevatedButton.styleFrom(backgroundColor: confirmColor),
            onPressed: () => Navigator.pop(context, true),
            child: Text(confirmLabel,
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F5EF),
      body: SafeArea(
        child: Column(
          children: [
            // ── HEADER ──────────────────────────────────────────────
            Container(
              color: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Settings',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Urbanist',
                    ),
                  ),
                ],
              ),
            ),

            // ── CONTENT ─────────────────────────────────────────────
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        // ── PREFERENCES ──────────────────────────
                        _Section(
                          title: 'Preferences',
                          children: [
                            _SettingsTile(
                              icon: Icons.notifications_outlined,
                              iconColor: Colors.deepPurple,
                              title: 'Notifications',
                              subtitle: 'Booking updates & alerts',
                              trailing: Switch(
                                value: _notificationsEnabled,
                                activeColor: Colors.deepPurple,
                                onChanged: (val) {
                                  setState(
                                      () => _notificationsEnabled = val);
                                  _updateSetting(
                                      'notificationsEnabled', val);
                                },
                              ),
                            ),
                            _SettingsTile(
                              icon: Icons.dark_mode_outlined,
                              iconColor: Colors.indigo,
                              title: 'Dark Mode',
                              subtitle: 'Coming soon',
                              trailing: Switch(
                                value: _darkMode,
                                activeColor: Colors.indigo,
                                onChanged: (val) {
                                  setState(() => _darkMode = val);
                                  _updateSetting('darkMode', val);
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Dark mode coming in the next update!'),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // ── ACCOUNT ───────────────────────────────
                        _Section(
                          title: 'Account',
                          children: [
                            _SettingsTile(
                              icon: Icons.lock_outline,
                              iconColor: Colors.teal,
                              title: 'Change Password',
                              subtitle: 'Send reset link to your email',
                              onTap: _showChangePasswordDialog,
                            ),
                            _SettingsTile(
                              icon: Icons.email_outlined,
                              iconColor: Colors.blue,
                              title: 'Email Address',
                              subtitle: widget.email,
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // ── ABOUT ─────────────────────────────────
                        _Section(
                          title: 'About',
                          children: [
                            _SettingsTile(
                              icon: Icons.info_outline,
                              iconColor: Colors.orange,
                              title: 'App Version',
                              subtitle: _appVersion,
                            ),
                            _SettingsTile(
                              icon: Icons.shield_outlined,
                              iconColor: Colors.green,
                              title: 'Privacy Policy',
                              subtitle: 'How we use your data',
                              onTap: () => ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content: Text('Coming soon'),
                                behavior: SnackBarBehavior.floating,
                              )),
                            ),
                            _SettingsTile(
                              icon: Icons.description_outlined,
                              iconColor: Colors.blueGrey,
                              title: 'Terms of Service',
                              subtitle: 'Our terms and conditions',
                              onTap: () => ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content: Text('Coming soon'),
                                behavior: SnackBarBehavior.floating,
                              )),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // ── DANGER ZONE ───────────────────────────
                        _Section(
                          title: 'Danger Zone',
                          titleColor: Colors.red.shade700,
                          children: [
                            _SettingsTile(
                              icon: Icons.logout,
                              iconColor: Colors.red,
                              title: 'Log Out',
                              subtitle: 'Sign out of your account',
                              titleColor: Colors.red,
                              onTap: _logout,
                            ),
                            _SettingsTile(
                              icon: Icons.delete_forever_outlined,
                              iconColor: Colors.red.shade700,
                              title: 'Delete Account',
                              subtitle:
                                  'Permanently remove your account and all data',
                              titleColor: Colors.red.shade700,
                              onTap: _showDeleteAccountDialog,
                            ),
                          ],
                        ),

                        const SizedBox(height: 32),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── SECTION WIDGET ────────────────────────────────────────────────────────────
class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final Color? titleColor;

  const _Section({
    required this.title,
    required this.children,
    this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: titleColor ?? Colors.grey,
              letterSpacing: 1.1,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: children.asMap().entries.map((entry) {
              final isLast = entry.key == children.length - 1;
              return Column(
                children: [
                  entry.value,
                  if (!isLast)
                    Divider(
                        height: 1,
                        indent: 54,
                        color: Colors.grey.shade100),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}

// ── SETTINGS TILE ─────────────────────────────────────────────────────────────
class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Color? titleColor;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.titleColor,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 18),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
          color: titleColor ?? Colors.black,
        ),
      ),
      subtitle: subtitle != null
          ? Text(subtitle!,
              style: const TextStyle(fontSize: 12, color: Colors.grey))
          : null,
      trailing: trailing ??
          (onTap != null
              ? Icon(Icons.chevron_right,
                  color: Colors.grey.shade400, size: 20)
              : null),
      onTap: onTap,
    );
  }
}