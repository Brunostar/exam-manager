import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:notify_me/screens/authentication/password_reset.dart';
import 'package:notify_me/screens/authentication/signup.dart';
import 'package:notify_me/screens/authentication/user_onboarding.dart';

import 'admin_onboarding.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  final List<TextEditingController> _controllers =
      List.generate(4, (_) => TextEditingController());
  final _emailFocusNode = FocusNode();
  final _passwordFocusNode = FocusNode();
  bool _passwordVisible = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    // Dispose focus nodes and text editing controllers
    _focusNodes.forEach((node) => node.dispose());
    _controllers.forEach((controller) => controller.dispose());
    _emailFocusNode.dispose();
    _passwordFocusNode.dispose();
    super.dispose();
  }

  String _email = '';
  String _password = '';
  String _pin = '';

  bool _isAdmin = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            // physics: const NeverScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth: MediaQuery.of(context).size.width,
                minHeight: MediaQuery.of(context).size.height,
              ),
              child: IntrinsicHeight(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 100.0),
                    const Text(
                      "Welcome Back!",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 150.0),
                    Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          _isAdmin
                              ? Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      "Log in to your account",
                                      style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(
                                      height: 16.0,
                                    ),
                                    SizedBox(
                                        width: 200.0,
                                        child: RichText(
                                          textAlign: TextAlign.center,
                                          text: TextSpan(
                                            children: [
                                              const TextSpan(
                                                text: "Don't have an account yet? ",
                                                style: TextStyle(
                                                  height: 1.5,
                                                  color: Color.fromRGBO(
                                                      50, 50, 50, 0.8),
                                                  // textAlign: TextAlign.center,
                                                )
                                              ),
                                              TextSpan(
                                                text: "Sign up",
                                                style: const TextStyle(
                                                  height: 1.5,
                                                    color: Colors.blue
                                                ),
                                                recognizer: TapGestureRecognizer()
                                                  ..onTap = () {
                                                    Navigator.push(
                                                      context,
                                                      MaterialPageRoute(builder: (context) =>
                                                      SignupPage()),
                                                    );
                                                  }
                                              ),
                                              const TextSpan(
                                                text: ' instead',
                                                style: TextStyle(
                                                  height: 1.5,
                                                  color: Color.fromRGBO(
                                                            50, 50, 50, 0.8),
                                                )
                                              )
                                            ]
                                          )
                                        ),

                                      ),
                                    const SizedBox(
                                      height: 40,
                                    ),
                                    TextFormField(
                                      decoration: const InputDecoration(
                                        labelText: 'Email',
                                        border: OutlineInputBorder(),
                                      ),
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return 'Please enter your email';
                                        }
                                        return null;
                                      },
                                      onSaved: (value) {
                                        _email = value!;
                                      },
                                    ),
                                    const SizedBox(
                                      height: 40,
                                    ),
                                    TextFormField(
                                      decoration: InputDecoration(
                                        labelText: 'Password',
                                        border: OutlineInputBorder(),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _passwordVisible
                                                ? Icons.visibility_off
                                                : Icons.visibility,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _passwordVisible = !_passwordVisible;
                                            });
                                          },
                                        ),
                                      ),
                                      obscureText: !_passwordVisible,
                                      validator: (value) {
                                        if (value!.isEmpty) {
                                          return 'Please enter your password';
                                        }
                                        return null;
                                      },
                                      onSaved: (value) {
                                        _password = value!;
                                      },
                                    ),
                                  ],
                                )
                              : Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text(
                                      "Enter your PIN",
                                      style: TextStyle(
                                          fontSize: 24,
                                          fontWeight: FontWeight.w600),
                                    ),
                                    const SizedBox(
                                      height: 16.0,
                                    ),
                                    const SizedBox(
                                        width: 200.0,
                                        child: Text(
                                          'Please enter the 4 digit PIN provided '
                                          'by your school administration to login',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                              height: 1.5,
                                              color: Color.fromRGBO(
                                                  50, 50, 50, 0.8)),
                                        )),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: List.generate(
                                        4,
                                        (index) => Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Container(
                                            width: 50.0,
                                            height: 50.0,
                                            decoration: BoxDecoration(
                                              border: Border.all(
                                                color: Colors.grey,
                                                width: 1.0,
                                              ),
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                            ),
                                            child: TextField(
                                              controller: _controllers[index],
                                              focusNode: _focusNodes[index],
                                              keyboardType:
                                                  TextInputType.number,
                                              obscureText: true,
                                              textAlign: TextAlign.center,
                                              maxLength: 1,
                                              decoration: const InputDecoration(
                                                border: InputBorder.none,
                                                counterText: '',
                                              ),
                                              onChanged: (value) {
                                                if (value.isNotEmpty) {
                                                  // Move focus to the next box
                                                  _focusNodes[index].unfocus();
                                                  if (index < 3) {
                                                    FocusScope.of(context)
                                                        .requestFocus(
                                                            _focusNodes[
                                                                index + 1]);
                                                  }
                                                } else {
                                                  // Move focus to the previous box
                                                  if (index > 0) {
                                                    FocusScope.of(context)
                                                        .requestFocus(
                                                            _focusNodes[
                                                                index - 1]);
                                                  }
                                                }
                                                setState(() {
                                                  // Update the PIN value
                                                  _pin = _controllers
                                                      .map((controller) =>
                                                          controller.text)
                                                      .join();
                                                });
                                              },
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                          const SizedBox(height: 32.0),
                          // const SizedBox(height: 16.0),
                          ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                _formKey.currentState!.save();
                                // Authenticate user here
                                if (_isAdmin) {
                                  // Authenticate admin user with email and password
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            OnboardingPage(isAdmin: true)),
                                  );
                                } else {
                                  // Authenticate non-admin user with pin
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            OnboardingPage(isAdmin: false)),
                                  );
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                                minimumSize: const Size.fromHeight(45),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                )),
                            child: const Text('login',
                                style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1.5)),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text('Are you an admin?'),
                              Switch(
                                value: _isAdmin,
                                onChanged: (value) {
                                  setState(() {
                                    _isAdmin = value;
                                  });
                                },
                              ),
                              if (_isAdmin)
                              TextButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                          PasswordResetScreen()),
                                    );
                                  },
                                  child: const Text('Forgot password?')
                              ),
                            ],
                          ),
                        ])
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
