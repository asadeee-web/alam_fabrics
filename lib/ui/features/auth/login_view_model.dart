import 'package:flutter/material.dart';
import '../../../core/services/auth_service.dart';

class LoginViewModel extends ChangeNotifier {
  final AuthService _authService;

  LoginViewModel(this._authService);

  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<String?> login() async {
    _isLoading = true;
    notifyListeners();

    final error = await _authService.signIn(
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    _isLoading = false;
    notifyListeners();
    return error;
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
