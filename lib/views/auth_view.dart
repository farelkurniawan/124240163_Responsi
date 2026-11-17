import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/controllers.dart';

// Halaman Login & Register
class AuthView extends StatefulWidget {
  const AuthView({super.key});

  @override
  State<AuthView> createState() => _AuthViewState();
}

class _AuthViewState extends State<AuthView> {
  final AuthController authController = Get.find<AuthController>();
  final _usernameCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool isLoginMode = true;

  // Fungsi untuk submit login atau register
  void submit() async {
    String user = _usernameCtrl.text.trim();
    String pass = _passwordCtrl.text.trim();

    if (user.isEmpty || pass.isEmpty) {
      Get.snackbar('Error', 'Harap isi semua kolom');
      return;
    }

    if (isLoginMode) {
      bool success = await authController.login(user, pass);
      if (success) {
        Get.offAllNamed('/home');
      } else {
        Get.snackbar('Error', 'Username atau password salah');
      }
    } else {
      bool success = await authController.register(user, pass);
      if (success) {
        Get.snackbar('Sukses', 'Registrasi berhasil, silakan login');
        setState(() => isLoginMode = true);
      } else {
        Get.snackbar('Error', 'Username sudah digunakan');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                isLoginMode ? 'Login ShoppingHub' : 'Register ShoppingHub',
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _usernameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _passwordCtrl,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: submit,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: Text(isLoginMode ? 'Login' : 'Register'),
              ),
              TextButton(
                onPressed: () => setState(() => isLoginMode = !isLoginMode),
                child: Text(
                  isLoginMode
                      ? 'Belum punya akun? Register'
                      : 'Sudah punya akun? Login',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
