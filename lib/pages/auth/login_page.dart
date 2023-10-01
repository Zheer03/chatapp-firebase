import 'package:chatapp_firebase/services/auth/auth_exceptions.dart';
import 'package:chatapp_firebase/services/auth/auth_service.dart';
import 'package:chatapp_firebase/services/cloud/cloud_constants.dart';
import 'package:chatapp_firebase/services/cloud/firebase_cloud_service.dart';
import 'package:chatapp_firebase/widgets/widgets.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:validators/validators.dart';
import '../../helper/helper_function.dart';
import '../../shared/routes.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  late TextEditingController _emailController;
  late TextEditingController _passwordController;

  @override
  void initState() {
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
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
                          'Login now to see what they are talking about!',
                          style: TextStyle(fontSize: 15),
                        ),
                        Image.asset('assets/login.png'),
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
                            } else if (!isEmail(value)) {
                              return 'Incorrect email format';
                            } else {
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
                            } else if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            } else {
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
                                      .logIn(
                                    email: _emailController.text,
                                    password: _passwordController.text,
                                  )
                                      .then((_) async {
                                    final snapshot =
                                        await CloudService().getUserData();
                                    await HelperFunctions
                                        .saveUserLoggedInStatus(true);
                                    await HelperFunctions.saveUserNameSF(
                                        snapshot[fullNameFieldName]);
                                    await HelperFunctions.saveUserEmailSF(
                                        snapshot[emailFieldName]);
                                  });
                                  Navigator.of(context).pushNamedAndRemoveUntil(
                                    homePageRoute,
                                    (route) => false,
                                  );
                                } catch (e) {
                                  if (e is UserNotFoundAuthException) {
                                    showSnackBar(
                                      context,
                                      Colors.red,
                                      UserNotFoundAuthException.message!,
                                    );
                                  } else if (e is WrongPasswordAuthException) {
                                    showSnackBar(
                                      context,
                                      Colors.red,
                                      WrongPasswordAuthException.message!,
                                    );
                                  } else if (e is UserDisabledAuthException) {
                                    showSnackBar(
                                      context,
                                      Colors.red,
                                      UserDisabledAuthException.message!,
                                    );
                                  } else if (e is InvalidEmailAuthException) {
                                    showSnackBar(
                                      context,
                                      Colors.red,
                                      InvalidEmailAuthException.message!,
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
                              'Sign In',
                              style:
                                  TextStyle(fontSize: 16, color: Colors.white),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text.rich(
                          TextSpan(
                            text: 'Don\'t have an account yet? ',
                            style: const TextStyle(color: Colors.black),
                            children: <TextSpan>[
                              TextSpan(
                                text: 'Register Here',
                                style: const TextStyle(
                                  color: Colors.black,
                                  decoration: TextDecoration.underline,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.of(context)
                                        .pushNamedAndRemoveUntil(
                                      registerPageRoute,
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
