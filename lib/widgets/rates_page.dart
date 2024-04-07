// ignore_for_file: use_build_context_synchronously, sort_child_properties_last

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:web_parental_control/widgets/about_page.dart';
import 'package:web_parental_control/widgets/account_page.dart';
import 'package:web_parental_control/widgets/login_page.dart';

class RatesPage extends StatefulWidget {
  final int userId;
  const RatesPage(this.userId, {super.key});

  @override
  State<RatesPage> createState() => _RatesPageState();
}

class _RatesPageState extends State<RatesPage> {
  int selectedPlanIndex = 0;
  bool isLoggedIn = false;

  List<TariffPlan> tariffPlans = [
    TariffPlan('Подписка\nна 1 месяц', 30, 450),
    TariffPlan('Подписка\nна 3 месяца', 90, 1350),
    TariffPlan('Подписка\nна год', 365, 5400),
  ];

  Future<void> purchaseLicense(int selectedPlanIndex) async {
    // Получение количества дней лицензии в зависимости от выбранного тарифного плана
    int licenseDays = tariffPlans[selectedPlanIndex].days;

    // Формирование JSON-тела запроса
    var requestBody = {
      'userId': widget.userId,
      'selectedPlanIndex': selectedPlanIndex,
    };

    try {
      // Отправка данных на сервер
      var response = await http.post(
        Uri.parse('http://62.217.182.138:3000/purchaseLicense'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(requestBody),
      );

      if (!isLoggedIn) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Ошибка'),
              content: const Text('Пожалуйста, авторизуйтесь перед покупкой'),
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
        return;
      }

      // Проверка ответа от сервера
      if (response.statusCode == 200) {
        // Обработка успешного ответа (например, показ сообщения об успешной покупке)
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Успешная покупка'),
              content:
                  Text('Лицензия успешно приобретена на $licenseDays дней'),
              actions: <Widget>[
                TextButton(
                  child: const Text('OK'),
                  onPressed: () {
                    // Переход на страницу профиля
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AccountPage(widget.userId)),
                    );
                  },
                ),
              ],
            );
          },
        );
      } else {
        // Обработка ошибочного ответа (например, показ сообщения об ошибке)
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Ошибка'),
              content: const Text('Произошла ошибка при покупке лицензии'),
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
    } catch (e) {
      // Обработка ошибок при отправке запроса (например, показ сообщения об ошибке)
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Ошибка'),
            content: const Text('Произошла ошибка при отправке запроса'),
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
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          toolbarHeight: 70,
          backgroundColor: const Color.fromRGBO(53, 50, 50, 1),
          title: Row(
            children: <Widget>[
              Container(
                padding: const EdgeInsets.all(8), // Отступ вокруг иконки
                decoration: const BoxDecoration(
                  shape: BoxShape.circle, // Форма - круг
                  color: Color.fromRGBO(39, 37, 37, 1), // Цвет фона - черный
                ),
                child: Image.asset('assets/images/logoController.png',
                    height: 50), // Высота логотипа
              ),
              const SizedBox(
                width: 40 * 15,
              ), // Раздвигает логотип и остальные элементы.
              InkWell(
                onTap: () {
                  // Действие при нажатии на 'Тарифы'
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AboutPage(widget.userId)),
                  );
                },
                child: const Text(
                  'О нас',
                  style: TextStyle(
                    fontSize: 35,
                    fontFamily: 'Jura',
                  ),
                ),
              ),
              const SizedBox(width: 10 * 30),
              InkWell(
                onTap: () {
                  // Действие при нажатии на 'Тарифы'
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => RatesPage(widget.userId)),
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
              const SizedBox(width: 10 * 30),
              InkWell(
                onTap: () {
                  // Действие при нажатии на 'Тарифы'
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const NewLoginPage()),
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
          decoration: const BoxDecoration(
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
              const SizedBox(
                height: 45,
              ),
              const Text(
                'Тарифы',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 100,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Jura',
                ),
              ),
              const SizedBox(
                height: 45,
              ),
              Expanded(
                flex: 3,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(tariffPlans.length, (index) {
                    return SubscriptionCard(
                      plan: tariffPlans[index],
                      title: '',
                      price: '',
                      index: index,
                      purchaseLicense: () {
                        purchaseLicense(index);
                      },
                    );
                  }),
                ),
              ),
              const SizedBox(
                height: 35,
              ),
              Card(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30)),
                color: const Color.fromRGBO(
                    53, 50, 50, 1), // set the background color of the card
                child: const SizedBox(
                  height: 87, // set the height of the card
                  width: 804, // set the width of the card to maximum
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        '**Скидка при покупке на несколько устройств 5%',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 30,
                          fontFamily: 'Jura',
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 40,
              ),
              Container(
                color: const Color.fromRGBO(53, 50, 50, 1),
                height: 70,
                child: Center(
                  child: RichText(
                    text: const TextSpan(
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

class SubscriptionCard extends StatelessWidget {
  final String title;
  final String price;
  final TariffPlan plan;
  final int index;
  final VoidCallback purchaseLicense;

  const SubscriptionCard({
    super.key,
    required this.title,
    required this.price,
    required this.plan,
    required this.purchaseLicense,
    required this.index,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
      color: const Color.fromRGBO(53, 50, 50, 1),
      child: Container(
        width: 404,
        height: 471,
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(plan.title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  height: 1.5,
                  color: Colors.white,
                  fontSize: 36,
                  fontFamily: 'Jura',
                )),
            const SizedBox(height: 125),
            Text('${plan.price}р за ${plan.days} дней',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontFamily: 'Jura',
                )),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {
                purchaseLicense();
              },
              child: const Text(
                'Купить',
                style: TextStyle(
                  // adjust this value as needed
                  color: Colors.white,
                  fontSize: 64,
                  fontFamily: 'Jura',
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromRGBO(34, 16, 16, 1),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(100.0),
                ),
                minimumSize: const Size(302, 74),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TariffPlan {
  final String title;
  final int days;
  final int price;

  TariffPlan(this.title, this.days, this.price);
}
