// ignore_for_file: deprecated_member_use

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectify/services/auth_services.dart';
import 'package:flutter/material.dart';

class EarningsView extends StatelessWidget {
  const EarningsView({super.key});

  @override
  Widget build(BuildContext context) {
    final uid = AuthServices().currentUser!.uid;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F5EF),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Earnings',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Urbanist',
                    ),
                  ),
                ],
              ),
            ),

            Expanded(
              child: StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('providers')
                    .doc(uid)
                    .snapshots(),
                builder: (context, snap) {
                  if (!snap.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  final data = snap.data!.data() as Map<String, dynamic>? ?? {};
                  final balance = (data['balance'] ?? 0).toDouble();
                  final pendingPayout = (data['pendingPayout'] ?? 0).toDouble();
                  final completedJobs = data['completedJobs'] ?? 0;

                  return ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Balance cards
                      Row(
                        children: [
                          _EarningsCard(
                            label: 'Available Balance',
                            value: '₦${_formatAmount(balance)}',
                            icon: Icons.account_balance_wallet_outlined,
                            color: Colors.deepPurple,
                          ),
                          const SizedBox(width: 12),
                          _EarningsCard(
                            label: 'Pending Payout',
                            value: '₦${_formatAmount(pendingPayout)}',
                            icon: Icons.pending_outlined,
                            color: Colors.orange,
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      _EarningsCard(
                        label: 'Completed Jobs',
                        value: '$completedJobs job${completedJobs == 1 ? '' : 's'}',
                        icon: Icons.check_circle_outline,
                        color: Colors.green,
                        fullWidth: true,
                      ),

                      const SizedBox(height: 24),

                      // Withdraw section
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Request Payout',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Urbanist',
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              balance > 0
                                  ? 'You have ₦${_formatAmount(balance)} available to withdraw.'
                                  : 'Complete jobs to earn money.',
                              style: const TextStyle(
                                  color: Colors.grey, fontSize: 13),
                            ),
                            const SizedBox(height: 16),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                onPressed: balance > 0
                                    ? () => _showPayoutDialog(
                                        context, uid, balance)
                                    : null,
                                icon: const Icon(Icons.send_rounded, size: 18),
                                label: const Text('Withdraw Funds'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  disabledBackgroundColor: Colors.grey.shade300,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30)),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Payout history
                      const Text(
                        'PAYOUT HISTORY',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.grey,
                          letterSpacing: 1.1,
                        ),
                      ),
                      const SizedBox(height: 12),

                      StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('payouts')
                            .where('providerId', isEqualTo: uid)
                            .orderBy('createdAt', descending: true)
                            .limit(20)
                            .snapshots(),
                        builder: (context, paySnap) {
                          if (!paySnap.hasData) {
                            return const Center(
                                child: CircularProgressIndicator());
                          }

                          final payouts = paySnap.data!.docs;

                          if (payouts.isEmpty) {
                            return Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Center(
                                child: Text(
                                  'No payout history yet.',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 13),
                                ),
                              ),
                            );
                          }

                          return Column(
                            children: payouts.map((doc) {
                              final d = doc.data() as Map<String, dynamic>;
                              final amount = (d['amount'] ?? 0).toDouble();
                              final status = d['status'] ?? 'pending';
                              final createdAt =
                                  (d['createdAt'] as Timestamp?)?.toDate();
                              final dateStr = createdAt != null
                                  ? '${createdAt.day}/${createdAt.month}/${createdAt.year}'
                                  : '';

                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(14),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.04),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        color:
                                            Colors.deepPurple.withOpacity(0.1),
                                        shape: BoxShape.circle,
                                      ),
                                      child: const Icon(
                                        Icons.account_balance_wallet_outlined,
                                        color: Colors.deepPurple,
                                        size: 18,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '₦${_formatAmount(amount)}',
                                            style: const TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 15,
                                            ),
                                          ),
                                          if (dateStr.isNotEmpty)
                                            Text(
                                              dateStr,
                                              style: const TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 11),
                                            ),
                                        ],
                                      ),
                                    ),
                                    _StatusBadge(status: status),
                                  ],
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPayoutDialog(
      BuildContext context, String uid, double balance) {
    final controller =
        TextEditingController(text: balance.toStringAsFixed(0));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom),
        child: Container(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Request Payout',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Urbanist',
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Available: ₦${_formatAmount(balance)}',
                style:
                    const TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Amount to withdraw',
                  prefixText: '₦ ',
                  filled: true,
                  fillColor: Colors.grey.shade100,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final amount =
                        double.tryParse(controller.text.trim()) ?? 0;
                    if (amount <= 0 || amount > balance) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Invalid amount')),
                      );
                      return;
                    }

                    // Create payout request and reduce balance
                    final db = FirebaseFirestore.instance;
                    await db.collection('payouts').add({
                      'providerId': uid,
                      'amount': amount,
                      'status': 'pending',
                      'createdAt': FieldValue.serverTimestamp(),
                    });

                    await db.collection('providers').doc(uid).update({
                      'balance': FieldValue.increment(-amount),
                      'pendingPayout': FieldValue.increment(amount),
                    });

                    if (!context.mounted) return;
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Payout request submitted!'),
                        backgroundColor: Colors.green,
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30)),
                  ),
                  child: const Text('Submit Request',
                      style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatAmount(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M';
    }
    if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K';
    }
    return amount.toStringAsFixed(0);
  }
}

class _EarningsCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final bool fullWidth;

  const _EarningsCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    final card = Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: color,
              fontFamily: 'Urbanist',
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );

    return fullWidth ? card : Expanded(child: card);
  }
}

class _StatusBadge extends StatelessWidget {
  final String status;
  const _StatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final (color, bg) = switch (status) {
      'completed' || 'approved' => (Colors.green, Colors.green.withOpacity(0.1)),
      'rejected' => (Colors.red, Colors.red.withOpacity(0.1)),
      _ => (Colors.orange, Colors.orange.withOpacity(0.1)),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration:
          BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
            color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
