import 'package:workout_skripsi_app/service/CommonService/export_service.dart';
import 'package:workout_skripsi_app/service/InitialService/login_service.dart';
import 'package:workout_skripsi_app/view/InitialView/signup_view.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  _LogInPageState createState() => _LogInPageState();
}

class _LogInPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _isLoading = false;
  final LoginService _logInService = LoginService();
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
                      'log_in'.tr,
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 25),

                    /// **Email Field**
                    buildTextField(
                      controller: _emailController,
                      labelText: 'Email',
                      icon: Icons.email,
                    ),
                    const SizedBox(height: 15),

                    /// **Password Field**
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
                    const SizedBox(height: 25),

                    /// **Login Button**
                    _buildLoginButton(),

                    const SizedBox(height: 20),
                    Text(
                      'dont_have_account'.tr,
                      style: TextStyle(fontSize: 14),
                    ),

                    /// **Sign Up Navigation**
                    GestureDetector(
                      onTap: () {
                        Get.to(() => const SignUpPage());
                      },
                      child: Text(
                        'sign_up'.tr,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
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

  Widget _buildLoginButton() {
    return buildCustomButton(
      label: 'log_in'.tr,
      isLoading: _isLoading,
      onPressed: _isLoading
          ? null
          : () {
              _logInService.Login(
                emailController: _emailController,
                passwordController: _passwordController,
                setLoading: _setLoading,
              );
            },
    );
  }
}
