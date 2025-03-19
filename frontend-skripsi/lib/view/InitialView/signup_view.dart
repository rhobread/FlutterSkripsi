import 'package:flutter_application_1/service/InitialService/signup_service.dart';
import 'package:flutter_application_1/view/InitialView/login_view.dart';
import 'package:flutter_application_1/service/CommonService/export_service.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  final SignUpService _signUpService = SignUpService();

  bool _obscurePassword = true;

  void _setLoading(bool value) {
    if (!mounted) return;
    setState(() {
      _isLoading = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildMainHeader(context: context),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const SizedBox(height: 30),
                    const Text(
                      'Sign Up',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),
                    buildTextField(
                      controller: _emailController,
                      labelText: 'Email',
                      icon: Icons.email,
                    ),
                    const SizedBox(height: 15),
                    buildTextField(
                      controller: _usernameController,
                      labelText: 'Username',
                      icon: Icons.person,
                    ),
                    const SizedBox(height: 15),
                    buildTextField(
                      controller: _passwordController,
                      labelText: 'Password',
                      icon: Icons.lock,
                      obscureText: _obscurePassword,
                      trailingIcon: _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      onIconTap: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    _buildSignUpButton(),
                    const SizedBox(height: 20),
                    Column(
                      children: [
                        const Text(
                          'Already have an account?',
                          style: TextStyle(fontSize: 14),
                        ),
                        GestureDetector(
                          onTap: () {
                            Get.to(() => const LoginPage());
                          },
                          child: const Text(
                            'Log In',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
          buildMainFooter(),
        ],
      ),
    );
  }

  Widget _buildSignUpButton() {
    return buildCustomButton(
      label: 'Sign Up',
      isLoading: _isLoading,
      onPressed: _isLoading
          ? null
          : () {
              _signUpService.signUp(
                emailController: _emailController,
                usernameController: _usernameController,
                passwordController: _passwordController,
                setLoading: _setLoading,
              );
            },
    );
  }
}