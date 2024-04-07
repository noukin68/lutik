// ignore_for_file: use_build_context_synchronously, sort_child_properties_last, prefer_is_empty

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_parental_control/login_page.dart';

class RegistrationPage extends StatefulWidget {
  const RegistrationPage({super.key});

  @override
  // ignore: library_private_types_in_public_api
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController usernameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController emailVerificationCodeController =
      TextEditingController();

  void showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ошибка'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void navigateToLoginPage() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Успешная регистрация'),
          content: const Text('Вы успешно зарегистрированы!'),
          actions: <Widget>[
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> registerUser() async {
    String email = emailController.text.trim();
    String username = usernameController.text.trim();
    String phone = phoneController.text.trim();
    String password = passwordController.text;
    String confirmPassword = confirmPasswordController.text;

    if (email.isEmpty ||
        username.isEmpty ||
        phone.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      showErrorMessage('Пожалуйста, заполните все поля');
      return;
    }

    RegExp phoneRegExp = RegExp(r'^\+7|8[0-9]{10}$');
    if (!phoneRegExp.hasMatch(phone)) {
      showErrorMessage('Пожалуйста, введите корректный номер телефона');
      return;
    }

    if (password != confirmPassword) {
      showErrorMessage('Пароли не совпадают');
      return;
    }

    await verifyEmail();

    try {
      var requestBody = jsonEncode({
        'email': email,
        'username': username,
        'phone': phone,
        'password': password,
      });

      var response = await http.post(
        Uri.parse('http://62.217.182.138:3000/userregister'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: requestBody,
      );

      if (response.statusCode == 200) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('email', email);

        navigateToLoginPage();
      } else {
        showErrorMessage('Ошибка регистрации');
      }
    } catch (e) {
      showErrorMessage('Ошибка регистрации: $e');
    }
  }

  Future<void> sendEmailVerificationCode() async {
    String email = emailController.text.trim();

    if (email.isEmpty) {
      showErrorMessage('Пожалуйста, введите email');
      return;
    }

    try {
      var response = await http.post(
        Uri.parse('http://62.217.182.138:3000/sendEmailVerificationCode'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'email': email}),
      );

      if (response.statusCode == 200) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Код подтверждения отправлен'),
              content:
                  const Text('Пожалуйста, проверьте свою электронную почту'),
              actions: <Widget>[
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      } else {
        showErrorMessage('Ошибка отправки кода подтверждения');
      }
    } catch (e) {
      showErrorMessage('Ошибка отправки кода подтверждения: $e');
    }
  }

  Future<void> verifyEmail() async {
    String email = emailController.text.trim();
    String code = emailVerificationCodeController.text.trim();

    if (email.isEmpty || code.isEmpty) {
      showErrorMessage('Пожалуйста, заполните все поля');
      return;
    }

    try {
      // ignore: unused_local_variable
      var response = await http.post(
        Uri.parse('http://62.217.182.138:3000/verifyEmail'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({'email': email, 'code': code}),
      );
    } catch (e) {
      showErrorMessage('Ошибка подтверждения email: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFCEAD),
      resizeToAvoidBottomInset: false,
      body: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          if (constraints.maxWidth > 600) {
            return _buildDesktopLayout();
          } else {
            return _buildMobileLayout();
          }
        },
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Center(
      child: Container(
        width: 400,
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Text(
              'Регистрация',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(119, 75, 36, 1),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(
                color: Color.fromRGBO(119, 75, 36, 1),
              ),
              decoration: const InputDecoration(
                hintText: 'Email',
                hintStyle: TextStyle(
                  color: Color.fromRGBO(119, 75, 36, 1),
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color.fromRGBO(119, 75, 36, 1),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                sendEmailVerificationCode();
              },
              child: const Text('Подтвердить email'),
              style: ElevatedButton.styleFrom(
                foregroundColor: const Color.fromRGBO(239, 206, 173, 1),
                backgroundColor: const Color.fromRGBO(119, 75, 36, 1),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: emailVerificationCodeController,
              keyboardType: TextInputType.number,
              style: const TextStyle(
                color: Color.fromRGBO(119, 75, 36, 1),
              ),
              decoration: const InputDecoration(
                hintText: 'Введите код подтверждения',
                hintStyle: TextStyle(
                  color: Color.fromRGBO(119, 75, 36, 1),
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color.fromRGBO(119, 75, 36, 1),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: usernameController,
              style: const TextStyle(
                color: Color.fromRGBO(119, 75, 36, 1),
              ),
              decoration: const InputDecoration(
                hintText: 'Имя пользователя',
                hintStyle: TextStyle(
                  color: Color.fromRGBO(119, 75, 36, 1),
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color.fromRGBO(119, 75, 36, 1),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              style: const TextStyle(
                color: Color.fromRGBO(119, 75, 36, 1),
              ),
              onChanged: (value) {
                if (value.isNotEmpty) {
                  if (!value.startsWith('+7') && !value.startsWith('8')) {
                    phoneController.text = '+7';
                    phoneController.selection = TextSelection.fromPosition(
                      TextPosition(offset: phoneController.text.length),
                    );
                  }

                  String digits = value.replaceAll(RegExp(r'\D'), '');

                  if (digits.length >= 1) {
                    String formattedPhone = '+7';

                    if (digits.length >= 2) {
                      formattedPhone += ' (${digits.substring(1, 4)}';
                    }

                    if (digits.length >= 5) {
                      formattedPhone += ') ${digits.substring(4, 7)}';
                    }

                    if (digits.length >= 8) {
                      formattedPhone += '-${digits.substring(7, 9)}';
                    }

                    if (digits.length >= 10) {
                      formattedPhone += '-${digits.substring(9, 11)}';
                    }

                    phoneController.value = phoneController.value.copyWith(
                      text: formattedPhone,
                      selection: TextSelection.collapsed(
                          offset: formattedPhone.length),
                    );
                  }
                }
              },
              decoration: const InputDecoration(
                hintText: 'Номер телефона',
                hintStyle: TextStyle(
                  color: Color.fromRGBO(119, 75, 36, 1),
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color.fromRGBO(119, 75, 36, 1),
                  ),
                ),
              ),
              validator: (value) {
                RegExp phoneRegExp =
                    RegExp(r'^\+7 \(\d{3}\) \d{3}-\d{2}-\d{2}$');
                if (!phoneRegExp.hasMatch(value!)) {
                  return 'Введите корректный номер телефона';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: passwordController,
              obscureText: true,
              style: const TextStyle(
                color: Color.fromRGBO(119, 75, 36, 1),
              ),
              decoration: const InputDecoration(
                hintText: 'Пароль',
                hintStyle: TextStyle(
                  color: Color.fromRGBO(119, 75, 36, 1),
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color.fromRGBO(119, 75, 36, 1),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: confirmPasswordController,
              obscureText: true,
              style: const TextStyle(
                color: Color.fromRGBO(119, 75, 36, 1),
              ),
              decoration: const InputDecoration(
                hintText: 'Подтвердите пароль',
                hintStyle: TextStyle(
                  color: Color.fromRGBO(119, 75, 36, 1),
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color.fromRGBO(119, 75, 36, 1),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                registerUser();
              },
              child: const Text('Зарегистрироваться'),
              style: ElevatedButton.styleFrom(
                foregroundColor: const Color.fromRGBO(239, 206, 173, 1),
                backgroundColor: const Color.fromRGBO(119, 75, 36, 1),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              child: const Text(
                'Войти в аккаунт',
                style: TextStyle(
                  color: Color.fromRGBO(119, 75, 36, 1),
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileLayout() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            const Text(
              'Регистрация',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(119, 75, 36, 1),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              style: const TextStyle(
                color: Color.fromRGBO(119, 75, 36, 1),
              ),
              decoration: const InputDecoration(
                hintText: 'Email',
                hintStyle: TextStyle(
                  color: Color.fromRGBO(119, 75, 36, 1),
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color.fromRGBO(119, 75, 36, 1),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: usernameController,
              style: const TextStyle(
                color: Color.fromRGBO(119, 75, 36, 1),
              ),
              decoration: const InputDecoration(
                hintText: 'Имя пользователя',
                hintStyle: TextStyle(
                  color: Color.fromRGBO(119, 75, 36, 1),
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color.fromRGBO(119, 75, 36, 1),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              style: const TextStyle(
                color: Color.fromRGBO(119, 75, 36, 1),
              ),
              onChanged: (value) {
                if (value.isNotEmpty) {
                  if (!value.startsWith('+7') && !value.startsWith('8')) {
                    phoneController.text = '+7';
                    phoneController.selection = TextSelection.fromPosition(
                      TextPosition(offset: phoneController.text.length),
                    );
                  }

                  String digits = value.replaceAll(RegExp(r'\D'), '');

                  if (digits.length >= 1) {
                    String formattedPhone = '+7';

                    if (digits.length >= 2) {
                      formattedPhone += ' (${digits.substring(1, 4)}';
                    }

                    if (digits.length >= 5) {
                      formattedPhone += ') ${digits.substring(4, 7)}';
                    }

                    if (digits.length >= 8) {
                      formattedPhone += '-${digits.substring(7, 9)}';
                    }

                    if (digits.length >= 10) {
                      formattedPhone += '-${digits.substring(9, 11)}';
                    }

                    phoneController.value = phoneController.value.copyWith(
                      text: formattedPhone,
                      selection: TextSelection.collapsed(
                          offset: formattedPhone.length),
                    );
                  }
                }
              },
              decoration: const InputDecoration(
                hintText: 'Номер телефона',
                hintStyle: TextStyle(
                  color: Color.fromRGBO(119, 75, 36, 1),
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color.fromRGBO(119, 75, 36, 1),
                  ),
                ),
              ),
              validator: (value) {
                RegExp phoneRegExp =
                    RegExp(r'^\+7 \(\d{3}\) \d{3}-\d{2}-\d{2}$');
                if (!phoneRegExp.hasMatch(value!)) {
                  return 'Введите корректный номер телефона';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: passwordController,
              obscureText: true,
              style: const TextStyle(
                color: Color.fromRGBO(119, 75, 36, 1),
              ),
              decoration: const InputDecoration(
                hintText: 'Пароль',
                hintStyle: TextStyle(
                  color: Color.fromRGBO(119, 75, 36, 1),
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color.fromRGBO(119, 75, 36, 1),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: confirmPasswordController,
              obscureText: true,
              style: const TextStyle(
                color: Color.fromRGBO(119, 75, 36, 1),
              ),
              decoration: const InputDecoration(
                hintText: 'Подтвердите пароль',
                hintStyle: TextStyle(
                  color: Color.fromRGBO(119, 75, 36, 1),
                ),
                border: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Color.fromRGBO(119, 75, 36, 1),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                registerUser();
              },
              child: const Text('Зарегистрироваться'),
              style: ElevatedButton.styleFrom(
                foregroundColor: const Color.fromRGBO(239, 206, 173, 1),
                backgroundColor: const Color.fromRGBO(119, 75, 36, 1),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                );
              },
              child: const Text(
                'Войти в аккаунт',
                style: TextStyle(
                  color: Color.fromRGBO(119, 75, 36, 1),
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
