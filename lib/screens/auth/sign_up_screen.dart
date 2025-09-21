import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class SignUpScreen extends StatefulWidget {
  @override
  SignUpScreenState createState() => SignUpScreenState();
}

class SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();

  bool _loading = false;
  final AuthService _authService = AuthService();

  void _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _loading = true);

    String? error = await _authService.signUp(
      name: _nameController.text.trim(),
      username: _usernameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      address: _addressController.text.trim(),
      phone: _phoneController.text.trim(),
      profileImage: "default.png", // or from image picker
    );

    setState(() => _loading = false);
    if (!mounted) return;
    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('تم التسجيل! تحقق من بريدك الإلكتروني للتأكيد.'),
        ),
      );
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('إنشاء حساب جديد')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _usernameController,
                decoration: InputDecoration(labelText: 'اسم المستخدم'),
              ),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'اسم'),
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'البريد الإلكتروني'),
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(labelText: 'كلمة المرور'),
                obscureText: true,
              ),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(labelText: 'العنوان'),
              ),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'رقم الهاتف'),
              ),
              SizedBox(height: 20),
              _loading
                  ? CircularProgressIndicator()
                  : ElevatedButton(onPressed: _register, child: Text('تسجيل')),
            ],
          ),
        ),
      ),
    );
  }
}
