import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zomato/constants/app_colors.dart';
import 'package:zomato/models/user_model.dart';
import 'package:zomato/providers/auth_provider.dart';
import 'package:zomato/widgets/custom_button.dart';
import 'package:zomato/widgets/custom_text_field.dart';

class RegisterScreen extends StatefulWidget {
  final UserRole role;
  const RegisterScreen({super.key, required this.role});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  // Vendor-only
  final _restaurantNameCtrl = TextEditingController();
  final _restaurantDescCtrl = TextEditingController();
  bool _obscure = true;
  bool _obscureConfirm = true;

  Color get _roleColor => widget.role == UserRole.vendor
      ? AppColors.vendorColor
      : AppColors.primary;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    _restaurantNameCtrl.dispose();
    _restaurantDescCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    final id =
        '${widget.role == UserRole.vendor ? "v" : "c"}${DateTime.now().millisecondsSinceEpoch}';
    final user = UserModel(
      id: id,
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      phone: _phoneCtrl.text.trim(),
      password: _passCtrl.text,
      role: widget.role,
      restaurantName: widget.role == UserRole.vendor
          ? _restaurantNameCtrl.text.trim()
          : null,
      restaurantDescription: widget.role == UserRole.vendor
          ? _restaurantDescCtrl.text.trim()
          : null,
      restaurantRating: widget.role == UserRole.vendor ? 0.0 : null,
      isApproved: widget.role == UserRole.vendor ? false : null,
    );
    final error = await auth.register(user);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: AppColors.error));
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(widget.role == UserRole.vendor
          ? 'Registration successful! Awaiting admin approval.'
          : 'Registration successful! Please sign in.'),
      backgroundColor: AppColors.success,
    ));
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: IconThemeData(color: _roleColor)),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  widget.role == UserRole.vendor
                      ? 'Vendor Registration'
                      : 'Create Account',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text(
                  widget.role == UserRole.vendor
                      ? 'Register your restaurant to start selling'
                      : 'Sign up to start ordering delicious food',
                  style: TextStyle(color: AppColors.textSecondary)),
              SizedBox(height: 30),
              CustomTextField(
                hint: 'Full Name',
                controller: _nameCtrl,
                prefixIcon: Icons.person_outline,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Enter your name' : null,
              ),
              SizedBox(height: 14),
              CustomTextField(
                hint: 'Email',
                controller: _emailCtrl,
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Enter your email';
                  if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v))
                    return 'Enter a valid email';
                  return null;
                },
              ),
              SizedBox(height: 14),
              CustomTextField(
                hint: 'Phone Number',
                controller: _phoneCtrl,
                prefixIcon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Enter your phone number' : null,
              ),
              SizedBox(height: 14),
              CustomTextField(
                hint: 'Password',
                controller: _passCtrl,
                prefixIcon: Icons.lock_outline,
                obscureText: _obscure,
                suffixIcon: IconButton(
                    icon: Icon(
                        _obscure ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey),
                    onPressed: () => setState(() => _obscure = !_obscure)),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Enter a password';
                  if (v.length < 6)
                    return 'Password must be at least 6 characters';
                  return null;
                },
              ),
              SizedBox(height: 14),
              CustomTextField(
                hint: 'Confirm Password',
                controller: _confirmCtrl,
                prefixIcon: Icons.lock_outline,
                obscureText: _obscureConfirm,
                suffixIcon: IconButton(
                    icon: Icon(
                        _obscureConfirm
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey),
                    onPressed: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm)),
                validator: (v) {
                  if (v != _passCtrl.text) return 'Passwords do not match';
                  return null;
                },
              ),
              if (widget.role == UserRole.vendor) ...[
                SizedBox(height: 24),
                Text('Restaurant Details',
                    style:
                        TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                SizedBox(height: 14),
                CustomTextField(
                  hint: 'Restaurant Name',
                  controller: _restaurantNameCtrl,
                  prefixIcon: Icons.store_outlined,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Enter restaurant name' : null,
                ),
                SizedBox(height: 14),
                CustomTextField(
                  hint: 'Restaurant Description',
                  controller: _restaurantDescCtrl,
                  prefixIcon: Icons.description_outlined,
                  maxLines: 3,
                  validator: (v) => v == null || v.isEmpty
                      ? 'Enter restaurant description'
                      : null,
                ),
              ],
              SizedBox(height: 30),
              CustomButton(
                  text: 'Sign Up', onPressed: _register, color: _roleColor),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Already have an account? ',
                      style: TextStyle(color: AppColors.textSecondary)),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Text('Sign In',
                        style: TextStyle(
                            color: _roleColor, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
