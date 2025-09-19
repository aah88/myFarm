import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_application_1/providers/cart_provider.dart';
import 'package:flutter_application_1/screens/auth/validation_per_phone.dart';
import 'package:flutter_application_1/screens/home/home_screen_user.dart';
import 'package:flutter_application_1/theme/design_tokens.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../screens/product/product_management_screen.dart';
import '../../screens/category/category_management_screen.dart';
import '../../screens/home/home_screen_farmer.dart';
import '../../services/firebase_service.dart';
import 'sign_up_screen.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  final _auth = FirebaseAuth.instance;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  final FirebaseService _firebaseService = FirebaseService();

  Future<void> _signIn() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      _showMessage("Please enter both email and password.");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = userCredential.user;
      if (user != null) {
        if (!user.emailVerified) {
          _showMessage("Please verify your email before logging in.");
          await _auth.signOut();
          setState(() => _isLoading = false);
          return;
        }
        String uid = userCredential.user!.uid;

        _showMessage("Sign in successful!");
        if (!mounted) return;
        context.read<UserProvider>().setUserId(uid);
        var userDetails = await _firebaseService.getUserById(uid);

        //HERE ADD
        //1.Check if cart exist and get it, if not then create one for this user
        final cartProvider = Provider.of<CartProvider>(context, listen: false);
        await cartProvider.loadCart(uid);
        //
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder:
                (context) =>
                    userDetails!.isFarmer
                        ? HomeScreenFarmer()
                        : HomeScreenUser(),
          ),
        );
      }
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        _showMessage("No user found for that email.");
      } else if (e.code == 'wrong-password') {
        _showMessage("Wrong password.");
      } else {
        _showMessage(e.message ?? "Something went wrong.");
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _forgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showMessage("Please enter your email first.");
      return;
    }

    try {
      await _auth.sendPasswordResetEmail(email: email);
      _showMessage("Password reset email sent.");
    } on FirebaseAuthException catch (e) {
      _showMessage(e.message ?? "Error sending reset email.");
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _navigateToSignUp() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => SignUpScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Sign In"),
        backgroundColor: AppColors.green,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock, size: 80, color: AppColors.green),
            const SizedBox(height: 20),

            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: "Email",
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Password",
                prefixIcon: Icon(Icons.lock_outline),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            _isLoading
                ? const CircularProgressIndicator()
                : SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _signIn,
                    child: const Text(
                      "Sign In",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => PhoneAuthPage()),
                  ),
              child: const Text('تسجيل الدخول'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => HomeScreenFarmer()),
                  ),
              child: const Text('استعراض فلاح'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => HomeScreenUser()),
                  ),
              child: const Text('استعراض مسنخدم'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ProductManagementScreen(),
                    ),
                  ),
              child: const Text('Add Product'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CategoryManagementScreen(),
                    ),
                  ),
              child: const Text('Add Category'),
            ),
            TextButton(
              onPressed: _forgotPassword,
              child: const Text("Forgot Password?"),
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text("Don’t have an account?"),
                TextButton(
                  onPressed: _navigateToSignUp,
                  child: const Text(
                    "Sign Up",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.green,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
