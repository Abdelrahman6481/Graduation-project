import 'package:flutter/material.dart';
import 'visa_payment.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PaymentPage extends StatefulWidget {
  const PaymentPage({super.key});

  @override
  State<PaymentPage> createState() => _PaymentPageState();
}

class _PaymentPageState extends State<PaymentPage> {
  int numberOfCourses = 0;
  final double coursePrice = 5000.0;
  String? _currentUserEmail;

  double get totalAmount => numberOfCourses * coursePrice;

  @override
  void initState() {
    super.initState();
    _getCurrentUserEmail();
  }

  Future<void> _getCurrentUserEmail() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      setState(() {
        _currentUserEmail = currentUser.email;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        elevation: 0,
        title: const Text(
          'Course Payment',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red.shade900,
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              color: Colors.red.shade900,
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  _buildTotalAmountHeader(),
                  const SizedBox(height: 30),
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 20),
                        _buildCourseSelector(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverFillRemaining(
            hasScrollBody: false,
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _buildPaymentSummary(),
                  const SizedBox(height: 20),
                  if (numberOfCourses > 0) _buildPaymentMethods(context),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalAmountHeader() {
    return Column(
      children: [
        Text(
          'EGP ${totalAmount.toStringAsFixed(0)}',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 36,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Total Amount Due',
          style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 16),
        ),
      ],
    );
  }

  Widget _buildCourseSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Number of Courses',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Max: 8 courses',
                  style: TextStyle(
                    color: Colors.red.shade900,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildCounterButton(
                icon: Icons.remove,
                onPressed: () {
                  if (numberOfCourses > 0) {
                    setState(() => numberOfCourses--);
                  }
                },
              ),
              Text(
                '$numberOfCourses',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              _buildCounterButton(
                icon: Icons.add,
                onPressed: () {
                  if (numberOfCourses < 8) {
                    setState(() => numberOfCourses++);
                  }
                },
              ),
            ],
          ),
          const SizedBox(height: 15),
          Text(
            'EGP ${coursePrice.toStringAsFixed(0)} per course',
            style: TextStyle(color: Colors.grey[600], fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildCounterButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return Material(
      color: Colors.red.shade50,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Icon(icon, color: Colors.red.shade900, size: 24),
        ),
      ),
    );
  }

  Widget _buildPaymentSummary() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        children: [
          _buildSummaryRow(
            'Course Fee',
            'EGP ${coursePrice.toStringAsFixed(0)} × $numberOfCourses',
          ),
          const SizedBox(height: 10),
          _buildSummaryRow('Service Fee', 'EGP 0'),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 10),
            child: Divider(),
          ),
          _buildSummaryRow(
            'Total Amount',
            'EGP ${totalAmount.toStringAsFixed(0)}',
            isTotal: true,
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? Colors.black : Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            color: isTotal ? Colors.red.shade900 : Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethods(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Payment Methods',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 15),
        _buildPaymentMethodCard(
          icon: Icons.credit_card,
          title: 'Credit/Debit Card',
          subtitle: 'Visa, Mastercard',
          onTap:
              () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => VisaPaymentPage(
                        amount: totalAmount,
                        studentEmail: _currentUserEmail,
                      ),
                ),
              ),
        ),
        const SizedBox(height: 10),
        _buildPaymentMethodCard(
          icon: Icons.account_balance,
          title: 'Cash Payment',
          subtitle: 'Pay at university cashier',
          onTap: () => _showCashPaymentInfo(context),
        ),
      ],
    );
  }

  Widget _buildPaymentMethodCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.red.shade900),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
            ],
          ),
        ),
      ),
    );
  }

  void _showCashPaymentInfo(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Cash Payment Instructions'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ListTile(
                  leading: Icon(Icons.location_on, color: Colors.red.shade900),
                  title: const Text('Visit the Cashier Office'),
                  subtitle: const Text('Located in Building A, Ground Floor'),
                ),
                ListTile(
                  leading: Icon(Icons.access_time, color: Colors.red.shade900),
                  title: const Text('Working Hours'),
                  subtitle: const Text('Sunday to Thursday\n9:00 AM - 3:00 PM'),
                ),
                ListTile(
                  leading: Icon(Icons.payment, color: Colors.red.shade900),
                  title: const Text('Amount Due'),
                  subtitle: Text('EGP ${totalAmount.toStringAsFixed(0)}'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Close'),
              ),
            ],
          ),
    );
  }
}
