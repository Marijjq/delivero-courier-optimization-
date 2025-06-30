import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../services/auth_service.dart';
import 'login.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool loading = false;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  Future<void> handleRegister() async {
    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('register.passwords_no_match'.tr())),
      );
      return;
    }

    setState(() => loading = true);
    final result = await AuthService.register(
      nameController.text.trim(),
      emailController.text.trim(),
      passwordController.text.trim(),
      confirmPasswordController.text.trim(),
    );
    setState(() => loading = false);

    if (result['success']) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginPage()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'register.failed'.tr())),
      );
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
              Column(
                children: [
                  CircleAvatar(
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                    radius: 50,
                    child: Image.asset('assets/images/logo.png', height: 50),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "register.title".tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    "register.subtitle".tr(),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: theme.hintColor, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: nameController,
                hint: "register.username".tr(),
                icon: Icons.person,
                fillColor: theme.colorScheme.primary.withOpacity(0.05),
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: emailController,
                hint: "register.email".tr(),
                icon: Icons.email,
                fillColor: theme.colorScheme.primary.withOpacity(0.05),
              ),
              const SizedBox(height: 20),
              _buildTextField(
                controller: passwordController,
                hint: "register.password".tr(),
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
              const SizedBox(height: 20),
              _buildTextField(
                controller: confirmPasswordController,
                hint: "register.confirm_password".tr(),
                icon: Icons.lock,
                obscureText: _obscureConfirmPassword,
                toggleObscure: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
                isObscured: _obscureConfirmPassword,
                fillColor: theme.colorScheme.primary.withOpacity(0.05),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: loading ? null : handleRegister,
                style: ElevatedButton.styleFrom(
                  shape: const StadiumBorder(),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child:
                    loading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                          "register.button".tr(),
                          style: const TextStyle(fontSize: 20),
                        ),
              ),
              const SizedBox(height: 32),

              // ✅ Replaced Row with Wrap to fix overflow
              Center(
                child: Column(
                  children: [
                    Text(
                      "register.have_account".tr(),
                      style: TextStyle(
                        color: theme.textTheme.bodyMedium?.color,
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const LoginPage()),
                        );
                      },
                      child: Text(
                        "register.login".tr(),
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
