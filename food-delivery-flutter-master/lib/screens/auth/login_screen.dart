import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zomato/constants/app_colors.dart';
import 'package:zomato/models/user_model.dart';
import 'package:zomato/providers/auth_provider.dart';
import 'package:zomato/screens/auth/register_screen.dart';
import 'package:zomato/services/api_service.dart';
import 'package:zomato/widgets/custom_button.dart';
import 'package:zomato/widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  final UserRole role;
  const LoginScreen({super.key, required this.role});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;

  String get _roleLabel {
    switch (widget.role) {
      case UserRole.customer:
        return 'Customer';
      case UserRole.vendor:
        return 'Vendor';
      case UserRole.admin:
        return 'Admin';
    }
  }

  Color get _roleColor {
    switch (widget.role) {
      case UserRole.customer:
        return AppColors.primary;
      case UserRole.vendor:
        return AppColors.vendorColor;
      case UserRole.admin:
        return AppColors.adminColor;
    }
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _showForgotPassword() async {
    final sent = await showDialog<bool>(
      context: context,
      builder: (_) => _ForgotPasswordDialog(
        initialEmail: _emailCtrl.text.trim(),
        roleColor: _roleColor,
      ),
    );
    if (sent == true && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            'If this email is registered, a reset link has been sent. Check your inbox.'),
        backgroundColor: AppColors.success,
        duration: Duration(seconds: 5),
      ));
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    final auth = context.read<AuthProvider>();
    final error =
        await auth.login(_emailCtrl.text.trim(), _passCtrl.text, widget.role);
    setState(() => _loading = false);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error), backgroundColor: AppColors.error));
      return;
    }
    String route;
    switch (widget.role) {
      case UserRole.customer:
        route = '/customer-main';
        break;
      case UserRole.vendor:
        route = '/vendor-main';
        break;
      case UserRole.admin:
        route = '/admin-main';
        break;
    }
    Navigator.pushNamedAndRemoveUntil(context, route, (_) => false);
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
              SizedBox(height: 20),
              Text('$_roleLabel Sign In',
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text('Welcome back! Please login to continue.',
                  style:
                      TextStyle(color: AppColors.textSecondary, fontSize: 15)),
              SizedBox(height: 40),
              CustomTextField(
                hint: 'Email',
                controller: _emailCtrl,
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (v) =>
                    v == null || v.isEmpty ? 'Enter your email' : null,
              ),
              SizedBox(height: 16),
              CustomTextField(
                hint: 'Password',
                controller: _passCtrl,
                prefixIcon: Icons.lock_outline,
                obscureText: _obscure,
                suffixIcon: IconButton(
                  icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey),
                  onPressed: () => setState(() => _obscure = !_obscure),
                ),
                validator: (v) =>
                    v == null || v.isEmpty ? 'Enter your password' : null,
              ),
              SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _showForgotPassword,
                  child: Text('Forgot Password?',
                      style: TextStyle(
                          color: _roleColor, fontWeight: FontWeight.w600)),
                ),
              ),
              SizedBox(height: 20),
              CustomButton(
                  text: 'Sign In',
                  onPressed: _login,
                  color: _roleColor,
                  isLoading: _loading),
              SizedBox(height: 20),
              if (widget.role != UserRole.admin)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text("Don't have an account? ",
                        style: TextStyle(color: AppColors.textSecondary)),
                    GestureDetector(
                      onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  RegisterScreen(role: widget.role))),
                      child: Text('Sign Up',
                          style: TextStyle(
                              color: _roleColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 15)),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────────────────────────────────────
// Standalone dialog widget — avoids StatefulBuilder context-lifecycle issues
// ──────────────────────────────────────────────────────────────────────────────
class _ForgotPasswordDialog extends StatefulWidget {
  final String initialEmail;
  final Color roleColor;
  const _ForgotPasswordDialog(
      {required this.initialEmail, required this.roleColor});

  @override
  State<_ForgotPasswordDialog> createState() => _ForgotPasswordDialogState();
}

class _ForgotPasswordDialogState extends State<_ForgotPasswordDialog> {
  late final TextEditingController _emailCtrl;
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _emailCtrl = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final email = _emailCtrl.text.trim();
    if (email.isEmpty) return;
    setState(() => _sending = true);
    try {
      // Route through the backend which uses the food-delivery-e78ef Firebase
      // project (where user accounts actually live).  Calling Firebase Auth
      // directly from Flutter targets zomato-101e9 and always gets
      // user-not-found, so no email would ever be sent.
      await ApiService.forgotPassword(email);
    } catch (_) {
      // Swallow — never reveal whether the email is registered.
    }
    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Reset Password'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Enter your email address and we\'ll send a reset link if an account exists.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          SizedBox(height: 14),
          TextField(
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'Email',
              prefixIcon: Icon(Icons.email_outlined),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _sending ? null : () => Navigator.pop(context, false),
          child: Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: widget.roleColor),
          onPressed: _sending ? null : _send,
          child: _sending
              ? SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
              : Text('Send', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
