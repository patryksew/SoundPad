import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:soundbar/online_mode_provider.dart';

class AuthForm extends StatefulWidget {
  // ignore: use_key_in_widget_constructors
  const AuthForm(this.submitFn, this.isLoading);

  final bool isLoading;
  final void Function(String email, String password, bool isLoginMode) submitFn;

  @override
  _AuthFormState createState() => _AuthFormState();
}

class _AuthFormState extends State<AuthForm> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoginMode = true;
  String _userEmail = '';
  String _password = '';

  void _trySubmit() {
    final isValid = _formKey.currentState!.validate();
    FocusScope.of(context).unfocus();
    if (isValid) {
      _formKey.currentState!.save();
      widget.submitFn(_userEmail, _password, _isLoginMode);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        margin: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Provider.of<OnlineModeProvider>(context, listen: false).setMode(false),
                        child: const Text('SKIP'),
                      )
                    ],
                  ),
                  TextFormField(
                    key: const ValueKey('email'),
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Email Address'),
                    validator: (val) {
                      if (val == null || val.isEmpty || !val.contains('@')) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                    onSaved: (val) {
                      _userEmail = val!;
                    },
                    textInputAction: TextInputAction.next,
                  ),
                  TextFormField(
                    key: const ValueKey('password'),
                    obscureText: true,
                    decoration: const InputDecoration(labelText: 'Password'),
                    validator: (val) {
                      if (val == null || val.length < 7) {
                        return 'Please enter a valid password';
                      }
                      return null;
                    },
                    onSaved: (val) {
                      _password = val!;
                    },
                  ),
                  const SizedBox(height: 12),
                  if (widget.isLoading) const CircularProgressIndicator(),
                  if (!widget.isLoading)
                    ElevatedButton(
                      onPressed: _trySubmit,
                      child: Text(_isLoginMode ? 'Login' : 'Register'),
                    ),
                  if (!widget.isLoading)
                    TextButton(
                        onPressed: () {
                          setState(() {
                            _isLoginMode = !_isLoginMode;
                          });
                        },
                        child: Text(_isLoginMode ? 'Create new account' : 'I already have an account'))
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
