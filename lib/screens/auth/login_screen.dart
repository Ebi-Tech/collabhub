# lib/screens/auth/login_screen.dart
  
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:collabhub/bloc/auth_bloc.dart';
import 'package:collabhub/screens/auth/register_screen.dart';
import 'package:collabhub/utils/constants.dart';
import 'package:collabhub/utils/validators.dart';
import 'package:collabhub/widgets/app_header.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _showEmailForm = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _loginWithGoogle(BuildContext context) {
    context.read<AuthBloc>().add(const AuthGoogleLoginRequested());
  }

  void _loginWithEmail(BuildContext context) {
    if (!_formKey.currentState!.validate()) return;
    context.read<AuthBloc>().add(AuthEmailLoginRequested(
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
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Logo
                                Container(
                                  width: 64,
                                  height: 64,
                                  decoration: BoxDecoration(
                                    color: AppColors.primary,
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.xxxl),
                                  ),
                                  child: const Icon(
                                    Icons.group_rounded,
                                    color: Colors.white,
                                    size: 40,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'Welcome to CollabHub',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.onSurface(context),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Connect with fellow students and find project collaborators',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: AppColors.secondaryText(context),
                                    height: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 32),
                                // Google button
                                _GoogleSignInButton(
                                  isLoading: isLoading,
                                  onTap: () => _loginWithGoogle(context),
                                ),
                                const SizedBox(height: 16),
                                // Divider
                                const Row(
                                  children: [
                                    Expanded(child: Divider(color: AppColors.gray300)),
                                    Padding(
                                      padding: EdgeInsets.symmetric(horizontal: 12),
                                      child: Text(
                                        'or',
                                        style: TextStyle(
                                            fontSize: 12,
                                            color: AppColors.gray500),
                                      ),
                                    ),
                                    Expanded(child: Divider(color: AppColors.gray300)),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                // Email form toggle
                                if (!_showEmailForm)
                                  GestureDetector(
                                    onTap: () =>
                                        setState(() => _showEmailForm = true),
                                    child: const Text(
                                      'Sign in with email',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: AppColors.primary,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  )
                                else
                                  _EmailForm(
                                    formKey: _formKey,
                                    emailCtrl: _emailCtrl,
                                    passwordCtrl: _passwordCtrl,
                                    obscure: _obscurePassword,
                                    onToggleObscure: () => setState(
                                        () => _obscurePassword = !_obscurePassword),
                                    isLoading: isLoading,
                                    onSubmit: () => _loginWithEmail(context),
                                  ),
                                const SizedBox(height: 24),
                                const Text(
                                  'By continuing, you agree to our Terms of Service and Privacy Policy',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 12, color: AppColors.gray500),
                                ),
                                const SizedBox(height: 12),
                                GestureDetector(
                                  onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) =>
                                            const RegisterScreen()),
                                  ),
                                  child: const Text(
                                    "Don't have an account? Register",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Bottom footer
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
}