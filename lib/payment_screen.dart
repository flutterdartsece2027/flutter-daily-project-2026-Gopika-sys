import 'package:flutter/material.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    // 1. Initialize Razorpay instance interface
    _razorpay = Razorpay();

    // 2. Set up event stream listeners
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    // 3. Clear listeners when screen closes to prevent memory leaks
    _razorpay.clear();
    super.dispose();
  }

  void openCheckout(int amount, String productName) {
    var options = {
      'key': 'rzp_test_T0I44R1EEx6EWL', // Replace with your actual Razorpay API Key Dashboard String
      'amount': amount * 100, // Amount in paise (e.g., 500 INR = 50000 paise)
      'name': 'Glowher Beauty Store',
      'description': productName,
      'timeout': 300, // Timeout window in seconds
      'prefill': {
        'contact': '9876543210',
        'email': 'gopika@example.com',
      },
      'external': {
        'wallets': ['paytm'] // External wallet payment mappings
      }
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint("Error opening checkout target window: $e");
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) {
    // Payment verified successfully. Use response.paymentId to record transactional states
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("✅ Payment Successful! ID: ${response.paymentId}"),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    // Payment unsuccessful. Inspect response.code or response.message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("❌ Payment Failed: Code ${response.code} | ${response.message}"),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    // Handles specific third-party configurations redirect maps
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Selected External Wallet: ${response.walletName}"),
        backgroundColor: Colors.orange,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Checkout Premium Items')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Card(
                color: Color(0xFF1F1A24),
                child: Padding(
                  padding: EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Text("Premium Skincare Kit", style: TextStyle(fontSize: 22, fontFamily: 'Serif', fontWeight: FontWeight.bold)),
                      SizedBox(height: 10),
                      Text("₹ 1,500.00", style: TextStyle(fontSize: 20, color: Colors.purpleAccent, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple,
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
                onPressed: () => openCheckout(1500, "Premium Skincare Kit Checkout Purchase"),
                child: const Text('Pay with Razorpay 💳', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
