import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/gestures.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_parental_control/widgets/about_page.dart';
import 'package:web_parental_control/widgets/account_page.dart';
import 'package:web_parental_control/widgets/rates_page.dart';
import 'package:web_parental_control/widgets/register_page.dart';

class NewLoginPage extends StatefulWidget {
  const NewLoginPage({super.key});

  @override
  State<NewLoginPage> createState() => _NewLoginPageState();
}

class _NewLoginPageState extends State<NewLoginPage> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  int userId = 0;

  void showErrorMessage(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Ошибка'),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> checkLicenseStatus(int userId) async {
    try {
      var response = await http.get(
        Uri.parse('http://62.217.182.138:3000/licenseStatus/${userId}'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
      );

      if (response.statusCode == 200) {
        var licenseStatus = json.decode(response.body);
        if (licenseStatus['active'] == true) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AccountPage(userId)),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => RatesPage(userId)),
          );
        }
      } else if (response.statusCode == 404) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => RatesPage(userId)),
        );
      } else {
        showErrorMessage(context, 'Ошибка при проверке статуса лицензии');
      }
    } catch (e) {
      showErrorMessage(context, 'Ошибка при проверке статуса лицензии: $e');
    }
  }

  Future<void> loginUser() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      showErrorMessage(context, 'Введите email и пароль');
      return;
    }

    try {
      var requestBody = jsonEncode({
        'email': email,
        'password': password,
      });

      var response = await http.post(
        Uri.parse('http://62.217.182.138:3000/userlogin'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: requestBody,
      );

      if (response.statusCode == 200) {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        prefs.setString('email', email);

        var responseData = json.decode(response.body);
        userId = responseData['userId'];

        await checkLicenseStatus(userId);
      } else {
        showErrorMessage(context, 'Неверный email или пароль');
      }
    } catch (e) {
      showErrorMessage(context, 'Ошибка аутентификации: $e');
    }
  }

  double _calculateWidth(double percent, BuildContext context) {
    return MediaQuery.of(context).size.width * percent / 100;
  }

  double _calculateHeight(double percent, BuildContext context) {
    return MediaQuery.of(context).size.height * percent / 100;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          toolbarHeight: 70,
          backgroundColor: Color.fromRGBO(53, 50, 50, 1),
          title: Row(
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(8), // Отступ вокруг иконки
                decoration: BoxDecoration(
                  shape: BoxShape.circle, // Форма - круг
                  color: Color.fromRGBO(39, 37, 37, 1), // Цвет фона - черный
                ),
                child: Image.asset('assets/images/logoController.png',
                    height: 50), // Высота логотипа
              ),
              SizedBox(
                width: 40 * 15,
              ), // Раздвигает логотип и остальные элементы.
              InkWell(
                onTap: () {
                  // Действие при нажатии на 'Тарифы'
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AboutPage(userId)),
                  );
                },
                child: Text(
                  'О нас',
                  style: TextStyle(
                    fontSize: 35,
                    fontFamily: 'Jura',
                  ),
                ),
              ),
              SizedBox(width: 10 * 30),
              InkWell(
                onTap: () {
                  // Действие при нажатии на 'Тарифы'
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RatesPage(userId)),
                  );
                },
                child: const Text(
                  'Тарифы',
                  style: TextStyle(
                    fontSize: 35,
                    fontFamily: 'Jura',
                  ),
                ),
              ),
              SizedBox(width: 10 * 30),
              InkWell(
                onTap: () {
                  // Действие при нажатии на 'Тарифы'
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NewLoginPage()),
                  );
                },
                child: const Text(
                  'Авторизация',
                  style: TextStyle(
                    fontSize: 35,
                    fontFamily: 'Jura',
                  ),
                ),
              ),
            ],
          ),
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                // Пурпурный цвет сверху слева
                Color(0xFFAA00FF),
                Color.fromARGB(255, 135, 90, 86), // Светло-пурпурный в середине
                Color.fromARGB(255, 229, 255, 0), // Зеленый снизу справа
              ], // Распределение цветов по градиенту
            ),
          ),
          child: Column(
            children: [
              SizedBox(
                height: _calculateHeight(2.5, context),
              ),
              Text(
                'Авторизация',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 96,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Jura',
                ),
              ),
              Expanded(
                flex: 3,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Card(
                      color: Color.fromRGBO(53, 50, 50, 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      elevation: 10,
                      child: Container(
                        width: 957,
                        height: 544,
                        padding: const EdgeInsets.all(30.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Container(
                              width: 557,
                              height: 85,
                              child: TextFormField(
                                cursorColor: Colors.white,
                                controller: emailController,
                                keyboardType: TextInputType.emailAddress,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 48,
                                    fontFamily: 'Jura'),
                                decoration: InputDecoration(
                                  hintText: 'E-mail',
                                  hintStyle: TextStyle(
                                    color: Color.fromRGBO(216, 216, 216, 1),
                                    fontSize: 48,
                                    fontFamily: 'Jura',
                                  ),
                                  filled: true,
                                  fillColor: Color.fromRGBO(100, 100, 100, 1),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 40),
                            Container(
                              width: 557,
                              height: 85,
                              child: TextFormField(
                                cursorColor: Colors.white,
                                controller: passwordController,
                                obscureText: true,
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 48,
                                    fontFamily: 'Jura'),
                                decoration: InputDecoration(
                                  hintText: 'Пароль',
                                  hintStyle: TextStyle(
                                    color: Color.fromRGBO(216, 216, 216, 1),
                                    fontSize: 48,
                                    fontFamily: 'Jura',
                                  ),
                                  filled: true,
                                  fillColor: Color.fromRGBO(100, 100, 100, 1),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(30.0),
                                    borderSide: BorderSide.none,
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(height: 40),
                            Text(
                              'Нет аккаунта?',
                              style: TextStyle(
                                color: Color.fromRGBO(216, 216, 216, 1),
                                fontSize: 32,
                                fontFamily: 'Jura',
                              ),
                            ),
                            Text.rich(
                              TextSpan(
                                text: 'Зарегистрироваться',
                                style: TextStyle(
                                  color: Color.fromRGBO(136, 51, 166, 1),
                                  fontSize: 32,
                                  fontFamily: 'Jura',
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              NewRegisterPage()),
                                    );
                                  },
                              ),
                            ),
                            SizedBox(height: 50),
                            SizedBox(
                              width: 302, // Set your desired width
                              height: 74, // Set your desired height
                              child: TextButton(
                                onPressed: () {
                                  loginUser();
                                },
                                child: Text(
                                  'Войти',
                                  style: TextStyle(
                                    fontSize: 64,
                                    fontFamily: 'Jura',
                                  ),
                                ),
                                style: TextButton.styleFrom(
                                  foregroundColor:
                                      Color.fromRGBO(216, 216, 216, 1),
                                  backgroundColor:
                                      Color.fromRGBO(100, 100, 100, 1),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(35),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                color: Color.fromRGBO(53, 50, 50, 1),
                height: 70,
                child: Center(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'ооо ',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 35,
                            fontFamily: 'Jura',
                          ),
                        ),
                        TextSpan(
                          text: '"ФТ-Групп"',
                          style: TextStyle(
                            color: Color.fromRGBO(142, 51, 174,
                                1), // Change this to the desired color
                            fontSize: 35,
                            fontFamily: 'Jura',
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
