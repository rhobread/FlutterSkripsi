import 'package:workout_skripsi_app/service/InitialService/signup_service.dart';
import 'package:workout_skripsi_app/view/InitialView/login_view.dart';
import 'package:workout_skripsi_app/service/CommonService/export_service.dart';

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
                    Text(
                      'sign_up'.tr,
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
                      labelText: 'username'.tr,
                      icon: Icons.person,
                    ),
                    const SizedBox(height: 15),
                    buildTextField(
                      controller: _passwordController,
                      labelText: 'password'.tr,
                      icon: Icons.lock,
                      obscureText: _obscurePassword,
                      trailingIcon: _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
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
                        Text(
                          'have_account'.tr,
                          style: TextStyle(fontSize: 14),
                        ),
                        GestureDetector(
                          onTap: () {
                            Get.to(() => const LoginPage());
                          },
                          child: Text(
                            'log_in'.tr,
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
      label: 'sign_up'.tr,
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
