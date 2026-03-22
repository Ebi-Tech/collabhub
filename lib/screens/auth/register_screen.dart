import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:collabhub/bloc/auth_bloc.dart';
import 'package:collabhub/utils/constants.dart';
import 'package:collabhub/utils/validators.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(AuthEmailRegisterRequested(
          name: _nameCtrl.text.trim(),
          email: _emailCtrl.text.trim(),
          password: _passwordCtrl.text,
        ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.red600,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.xl)),
              ),
            );
          }
          // On success, navigator is handled by app.dart's BlocListener
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;
          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.blue50, AppColors.indigo100],
              ),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 448),
                          child: Container(
                            padding: const EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: AppColors.surface(context),
                              borderRadius:
                                  BorderRadius.circular(AppRadius.xl),
                              boxShadow: AppShadows.card,
                            ),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  // Logo
                                  Container(
                                    width: 64,
                                    height: 64,
                                    decoration: BoxDecoration(
                                      color: AppColors.primary,
                                      borderRadius: BorderRadius.circular(
                                          AppRadius.xxxl),
                                    ),
                                    child: const Icon(
                                      Icons.group_rounded,
                                      color: Colors.white,
                                      size: 40,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Create Account',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.onSurface(context),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'Join CollabHub and start collaborating',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: AppColors.secondaryText(context),
                                        height: 1.5),
                                  ),
                                  const SizedBox(height: 24),
                                  _field(
                                    context: context,
                                    ctrl: _nameCtrl,
                                    hint: 'Full name',
                                    icon: Icons.person_outline,
                                    validator: (v) => Validators.required(v,
                                        field: 'Name'),
                                  ),
                                  const SizedBox(height: 10),
                                  _field(
                                    context: context,
                                    ctrl: _emailCtrl,
                                    hint: 'Email address',
                                    icon: Icons.email_outlined,
                                    keyboard: TextInputType.emailAddress,
                                    validator: Validators.email,
                                  ),
                                  const SizedBox(height: 10),
                                  _field(
                                    context: context,
                                    ctrl: _passwordCtrl,
                                    hint: 'Password',
                                    icon: Icons.lock_outline,
                                    obscure: _obscurePassword,
                                    toggleObscure: () => setState(() =>
                                        _obscurePassword = !_obscurePassword),
                                    validator: Validators.password,
                                  ),
                                  const SizedBox(height: 10),
                                  _field(
                                    context: context,
                                    ctrl: _confirmCtrl,
                                    hint: 'Confirm password',
                                    icon: Icons.lock_outline,
                                    obscure: _obscureConfirm,
                                    toggleObscure: () => setState(() =>
                                        _obscureConfirm = !_obscureConfirm),
                                    validator: (v) {
                                      if (v != _passwordCtrl.text) {
                                        return 'Passwords do not match';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 24),
                                  SizedBox(
                                    width: double.infinity,
                                    height: 48,
                                    child: ElevatedButton(
                                      onPressed: isLoading ? null : _submit,
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.primary,
                                        foregroundColor: AppColors.white,
                                        elevation: 0,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(
                                                    AppRadius.xl)),
                                      ),
                                      child: isLoading
                                          ? const SizedBox(
                                              width: 20,
                                              height: 20,
                                              child: CircularProgressIndicator(
                                                  strokeWidth: 2,
                                                  color: Colors.white),
                                            )
                                          : const Text('Create Account',
                                              style: TextStyle(
                                                  fontSize: 16,
                                                  fontWeight:
                                                      FontWeight.w600)),
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  GestureDetector(
                                    onTap: () => Navigator.pop(context),
                                    child: const Text(
                                      'Already have an account? Sign in',
                                      style: TextStyle(
                                          fontSize: 12,
                                          color: AppColors.primary,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(
                      '© 2026 CollabHub • For University Students',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: AppColors.gray500),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _field({
    required BuildContext context,
    required TextEditingController ctrl,
    required String hint,
    required IconData icon,
    TextInputType keyboard = TextInputType.text,
    bool obscure = false,
    VoidCallback? toggleObscure,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboard,
      obscureText: obscure,
      validator: validator,
      style: TextStyle(fontSize: 16, color: AppColors.onSurface(context)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.gray400),
        prefixIcon: Icon(icon, size: 20, color: AppColors.gray400),
        suffixIcon: toggleObscure != null
            ? IconButton(
                icon: Icon(
                  obscure
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  size: 20,
                  color: AppColors.gray400,
                ),
                onPressed: toggleObscure,
              )
            : null,
        filled: true,
        fillColor: AppColors.input(context),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          borderSide: const BorderSide(color: AppColors.red600),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          borderSide: const BorderSide(color: AppColors.red600, width: 2),
        ),
      ),
    );
  }
}
