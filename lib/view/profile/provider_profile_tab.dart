// ignore_for_file: deprecated_member_use

// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectify/view/profile/edit_provider_profile_view.dart';
import 'package:flutter/material.dart';

class ProviderProfileTab extends StatelessWidget {
  final Map<String, dynamic>? providerData;

  const ProviderProfileTab({super.key, required this.providerData});

  @override
  Widget build(BuildContext context) {
    if (providerData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    final skills =
        (providerData!['skills'] as List<dynamic>?)?.join(', ') ?? '';
    final phone = providerData!['phoneNumber'] ?? 'Not set';
    final online = providerData!['online'] ?? false;
    final ratingAvg = (providerData!['ratingAvg'] ?? 0).toDouble();
    final ratingCount = providerData!['ratingCount'] ?? 0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // ── STATS ROW ──────────────────────────────────────────────
          Row(
            children: [
              _StatCard(
                label: 'Rating',
                value: ratingCount == 0
                    ? 'New'
                    : '${ratingAvg.toStringAsFixed(1)}★',
                color: Colors.amber,
              ),
              const SizedBox(width: 12),
              _StatCard(
                label: 'Reviews',
                value: '$ratingCount',
                color: Colors.deepPurple,
              ),
              const SizedBox(width: 12),
              _StatCard(
                label: 'Status',
                value: online ? 'Online' : 'Offline',
                color: online ? Colors.green : Colors.grey,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // ── INFO CARD ──────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.07),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                _InfoRow(icon: Icons.phone, label: 'Phone', value: phone),
                const Divider(height: 24),
                _InfoRow(icon: Icons.build, label: 'Skills', value: skills),
                const Divider(height: 24),
                _InfoRow(
                  icon: online ? Icons.circle : Icons.circle_outlined,
                  label: 'Availability',
                  value: online
                      ? 'Available for jobs'
                      : 'Not accepting jobs',
                  iconColor: online ? Colors.green : Colors.grey,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const EditProviderProfileView()),
                    ),
                    icon: const Icon(Icons.edit),
                    label: const Text('Edit Profile'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── STAT CARD ─────────────────────────────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(value,
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color)),
            const SizedBox(height: 2),
            Text(label,
                style:
                    const TextStyle(fontSize: 11, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}

// ── INFO ROW ──────────────────────────────────────────────────────────────────
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? iconColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: iconColor ?? Colors.deepPurple),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style:
                      const TextStyle(fontSize: 11, color: Colors.grey)),
              const SizedBox(height: 2),
              Text(value, style: const TextStyle(fontSize: 15)),
            ],
          ),
        ),
      ],
    );
  }
}