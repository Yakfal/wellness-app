import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/booking_service.dart';

// Enum to manage which mode the screen is in
enum AuthMode { login, signup }

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  AuthMode _authMode = AuthMode.login;
  bool _isLoading = false;

  // Controllers to read the input from the text fields
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController(); // The new controller

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _firstNameController.dispose(); // Dispose the new controller
    super.dispose();
  }

  void _switchAuthMode() {
    setState(() {
      _authMode = _authMode == AuthMode.login ? AuthMode.signup : AuthMode.login;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return; // If form is not valid, do nothing
    }
    _formKey.currentState!.save();
    setState(() => _isLoading = true);

    try {
      final authService = Provider.of<BookingService>(context, listen: false);
      if (_authMode == AuthMode.login) {
        // Sign in doesn't need the first name
        await authService.signInWithEmail(
            _emailController.text, _passwordController.text);
      } else {
        // Sign up now passes the first name to the service
        await authService.signUpWithEmail(_emailController.text,
            _passwordController.text, _firstNameController.text);
      }
      // If successful, the GoRouter redirect will handle navigation automatically.
      // We don't need to call context.go() here.
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(error.toString().replaceFirst("Exception: ", "")), // Clean up the error message
              backgroundColor: Colors.red),
        );
      }
    }

    if (mounted) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_authMode == AuthMode.login ? 'Welcome Back!' : 'Create Your Account'),
        automaticallyImplyLeading: false, // Removes the back button
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'Andreasen Center for Wellness',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 32),

                // Conditionally show the First Name field only in Sign Up mode
                if (_authMode == AuthMode.signup)
                  TextFormField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(labelText: 'First Name', border: OutlineInputBorder()),
                    validator: (value) => (value == null || value.isEmpty) ? 'Please enter your first name' : null,
                  ),
                if (_authMode == AuthMode.signup) const SizedBox(height: 16),

                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: 'Email', border: OutlineInputBorder()),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) => (value == null || !value.contains('@')) ? 'Please enter a valid email' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
                  obscureText: true,
                  validator: (value) => (value == null || value.length < 6) ? 'Password must be at least 6 characters' : null,
                ),
                const SizedBox(height: 24),
                if (_isLoading)
                  const CircularProgressIndicator()
                else
                  ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 50),
                      backgroundColor: Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(_authMode == AuthMode.login ? 'LOGIN' : 'SIGN UP'),
                  ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: _switchAuthMode,
                  child: Text(
                    _authMode == AuthMode.login ? 'Don\'t have an account? Sign Up' : 'Already have an account? Login',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}