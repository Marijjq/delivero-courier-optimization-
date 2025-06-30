import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../services/auth_service.dart';
import 'register.dart';
import 'main_screen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool loading = false;
  bool _obscurePassword = true;

  Future<void> handleLogin() async {
    setState(() => loading = true);

    try {
      final result = await AuthService.login(
        emailController.text.trim(),
        passwordController.text.trim(),
      );

      if (result['success']) {
        final token = result['token'];
        const baseUrl = 'http://192.168.1.5:8888';
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => MainScreen(token: token, baseUrl: baseUrl),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result['message'] ?? tr('login.error'))),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error during login: $e')));
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),

              // Logo
              Center(
                child: CircleAvatar(
                  backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                  radius: 50,
                  child: Image.asset('assets/images/logo.png', height: 50),
                ),
              ),

              const SizedBox(height: 24),
              Text(
                'login.welcome'.tr(),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'login.instruction'.tr(),
                textAlign: TextAlign.center,
                style: TextStyle(color: theme.hintColor, fontSize: 12),
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: emailController,
                hint: tr('login.email'),
                icon: Icons.email,
                fillColor: theme.colorScheme.primary.withOpacity(0.05),
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: passwordController,
                hint: tr('login.password'),
                icon: Icons.lock,
                obscureText: _obscurePassword,
                toggleObscure: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
                isObscured: _obscurePassword,
                fillColor: theme.colorScheme.primary.withOpacity(0.05),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: loading ? null : handleLogin,
                style: ElevatedButton.styleFrom(
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child:
                    loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                          tr('login.button'),
                          style: const TextStyle(fontSize: 20),
                        ),
              ),
              const SizedBox(height: 32),

              // ✅ Responsive alternative to Row (fixes overflow)
              Center(
                child: Column(
                  children: [
                    Text(
                      tr('login.no_account'),
                      style: TextStyle(
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RegisterScreen(),
                          ),
                        );
                      },
                      child: Text(
                        tr('login.signup'),
                        style: TextStyle(color: theme.colorScheme.secondary),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    bool isObscured = true,
    VoidCallback? toggleObscure,
    Color? fillColor,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      decoration: InputDecoration(
        hintText: hint,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        fillColor: fillColor,
        filled: true,
        prefixIcon: Icon(icon),
        suffixIcon:
            toggleObscure != null
                ? IconButton(
                  icon: Icon(
                    isObscured ? Icons.visibility : Icons.visibility_off,
                  ),
                  onPressed: toggleObscure,
                )
                : null,
      ),
    );
  }
}
