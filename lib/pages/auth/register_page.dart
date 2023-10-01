import 'package:chatapp_firebase/helper/helper_function.dart';
import 'package:chatapp_firebase/services/auth/auth_exceptions.dart';
import 'package:chatapp_firebase/services/cloud/firebase_cloud_service.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:validators/validators.dart';
import '../../services/auth/auth_service.dart';
import '../../shared/routes.dart';
import '../../widgets/widgets.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;
  late TextEditingController _fullNameController;

  @override
  void initState() {
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _fullNameController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    super.dispose();
  }

  final formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            )
          : SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 80),
                child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          'Groupie',
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        const Text(
                          'Create your account now to chat and explore!',
                          style: TextStyle(fontSize: 15),
                        ),
                        Image.asset('assets/register.png'),
                        TextFormField(
                          controller: _fullNameController,
                          decoration: textInputDecoration.copyWith(
                            labelText: 'Full Name',
                            prefixIcon: Icon(
                              Icons.person,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter your Full Name';
                            } else if (isAlpha(value)) {
                              return 'Your name should contain only letters';
                            } else {
                              return null;
                            }
                          },
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          controller: _emailController,
                          decoration: textInputDecoration.copyWith(
                            labelText: 'Email',
                            prefixIcon: Icon(
                              Icons.email,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter your email';
                            }
                            // else if (!isEmail(value)) {
                            //   return 'Incorrect email format';
                            // }
                            else {
                              return null;
                            }
                          },
                        ),
                        const SizedBox(height: 15),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: textInputDecoration.copyWith(
                            labelText: 'Password',
                            prefixIcon: Icon(
                              Icons.lock,
                              color: Theme.of(context).primaryColor,
                            ),
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return 'Please enter your password';
                            }
                            //  else if (value.length < 6) {
                            //   return 'Password must be at least 6 characters';
                            // }
                            else {
                              return null;
                            }
                          },
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30)),
                            ),
                            onPressed: () async {
                              if (formKey.currentState!.validate()) {
                                setState(() {
                                  _isLoading = true;
                                });
                                try {
                                  await AuthService.firebase()
                                      .createUser(
                                        email: _emailController.text,
                                        password: _passwordController.text,
                                      )
                                      .then(
                                        (_) async =>
                                            await CloudService().saveUserData(
                                          fullName: _fullNameController.text,
                                          email: _emailController.text,
                                        ),
                                      );
                                  await HelperFunctions.saveUserLoggedInStatus(
                                      true);
                                  await HelperFunctions.saveUserNameSF(
                                      _fullNameController.text);
                                  await HelperFunctions.saveUserEmailSF(
                                      _emailController.text);
                                  Navigator.of(context).pushNamedAndRemoveUntil(
                                    homePageRoute,
                                    (route) => false,
                                  );
                                } catch (e) {
                                  if (e is WeakPasswordAuthException) {
                                    showSnackBar(
                                      context,
                                      Colors.red,
                                      WeakPasswordAuthException.message!,
                                    );
                                  } else if (e
                                      is EmailAlreadyInUseAuthException) {
                                    showSnackBar(
                                      context,
                                      Colors.red,
                                      EmailAlreadyInUseAuthException.message!,
                                    );
                                  } else if (e is InvalidEmailAuthException) {
                                    showSnackBar(
                                      context,
                                      Colors.red,
                                      InvalidEmailAuthException.message!,
                                    );
                                  } else if (e
                                      is OperationNotAllowedAuthException) {
                                    showSnackBar(
                                      context,
                                      Colors.red,
                                      OperationNotAllowedAuthException.message!,
                                    );
                                  } else {
                                    showSnackBar(
                                      context,
                                      Colors.red,
                                      'A network error has occured.',
                                    );
                                  }
                                }

                                setState(() {
                                  _isLoading = false;
                                });
                              } else {
                                setState(() {
                                  _isLoading = false;
                                });
                              }
                            },
                            child: const Text(
                              'Register',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text.rich(
                          TextSpan(
                            text: 'Already have an account? ',
                            style: const TextStyle(color: Colors.black),
                            children: <TextSpan>[
                              TextSpan(
                                text: 'Login now',
                                style: const TextStyle(
                                  color: Colors.black,
                                  decoration: TextDecoration.underline,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.of(context)
                                        .pushNamedAndRemoveUntil(
                                      loginPageRoute,
                                      (route) => false,
                                    );
                                  },
                              ),
                            ],
                          ),
                        ),
                      ],
                    )),
              ),
            ),
    );
  }
}
