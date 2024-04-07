import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:web_parental_control/account_info_page.dart';

class LicensePurchasePage extends StatefulWidget {
  final int userId;
  LicensePurchasePage(this.userId);

  @override
  _LicensePurchasePageState createState() => _LicensePurchasePageState();
}

class _LicensePurchasePageState extends State<LicensePurchasePage> {
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expirationDateController =
      TextEditingController();
  final TextEditingController _cvvController = TextEditingController();
  int selectedPlanIndex = 0;

  List<TariffPlan> tariffPlans = [
    TariffPlan('На месяц', 'Получите лицензию на один месяц по выгодной цене.',
        30, 450),
    TariffPlan('На 3 месяца',
        'Пользуйтесь нашим сервисом в течение трех месяцев.', 90, 1350),
    TariffPlan('На год', 'Получите доступ к полному функционалу на год вперед.',
        365, 5400),
  ];

  @override
  void initState() {
    super.initState();
    // Установка тестовых данных по умолчанию
    _cardNumberController.text = '1234567890123456'; // Тестовый номер карты
    _expirationDateController.text =
        '12/24'; // Тестовая дата истечения срока действия
    _cvvController.text = '123'; // Тестовый CVV код
  }

  Future<void> purchaseLicense() async {
    // Извлечение данных о карте из контроллеров
    String cardNumber = _cardNumberController.text.replaceAllMapped(
        RegExp(r'^(\d{4})(\d{4})(\d{4})(\d{4})$'),
        (Match match) => '${match[1]} ${match[2]} ${match[3]} ${match[4]}');
    String expirationDate = _expirationDateController.text;
    String cvv = _cvvController.text;

    // Получение количества дней лицензии в зависимости от выбранного тарифного плана
    int licenseDays = tariffPlans[selectedPlanIndex].days;

    // Формирование JSON-тела запроса
    var requestBody = {
      'userId': widget.userId,
      'cardNumber': cardNumber,
      'expirationDate': expirationDate,
      'cvv': cvv,
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

      // Проверка ответа от сервера
      if (response.statusCode == 200) {
        // Обработка успешного ответа (например, показ сообщения об успешной покупке)
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('Успешная покупка'),
              content:
                  Text('Лицензия успешно приобретена на $licenseDays дней'),
              actions: <Widget>[
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    // Переход на страницу профиля
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AccountInfoPage(widget.userId)),
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
              title: Text('Ошибка'),
              content: Text('Произошла ошибка при покупке лицензии'),
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
    } catch (e) {
      // Обработка ошибок при отправке запроса (например, показ сообщения об ошибке)
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Ошибка'),
            content: Text('Произошла ошибка при отправке запроса'),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEFCEAD),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Покупка лицензии',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color.fromRGBO(119, 75, 36, 1),
                ),
              ),
              SizedBox(height: 20),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _cardNumberController,
                        decoration: InputDecoration(
                          labelText: 'Номер карты',
                          border: OutlineInputBorder(),
                          labelStyle: TextStyle(
                            color: Color.fromRGBO(119, 75, 36, 1),
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(16),
                        ],
                      ),
                      SizedBox(height: 16.0),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: _expirationDateController,
                              decoration: InputDecoration(
                                labelText: 'Срок действия',
                                border: OutlineInputBorder(),
                                labelStyle: TextStyle(
                                  color: Color.fromRGBO(119, 75, 36, 1),
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(5),
                                // Ввод месяца и года разделенных /
                                MaskTextInputFormatter(
                                    mask: '##/##',
                                    filter: {"#": RegExp(r'[0-9]')}),
                              ],
                            ),
                          ),
                          SizedBox(width: 16.0),
                          Expanded(
                            child: TextFormField(
                              controller: _cvvController,
                              decoration: InputDecoration(
                                labelText: 'CVV',
                                border: OutlineInputBorder(),
                                labelStyle: TextStyle(
                                  color: Color.fromRGBO(119, 75, 36, 1),
                                ),
                              ),
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(3),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              Column(
                children: [
                  for (int i = 0; i < tariffPlans.length; i++)
                    Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10.0),
                            border: Border.all(
                              color: Color.fromRGBO(119, 75, 36, 1),
                              width: 2.0,
                            ),
                            color: Colors.white, // Белый фон
                          ),
                          child: _buildTariffPlan(i),
                        ),
                        SizedBox(height: 10),
                      ],
                    ),
                ],
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: purchaseLicense,
                child: Text(
                  'Купить лицензию',
                  style: TextStyle(
                    color: Color.fromRGBO(239, 206, 173, 1),
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color.fromRGBO(119, 75, 36, 1),
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTariffPlan(int index) {
    bool isSelected = index == selectedPlanIndex;

    return InkWell(
      onTap: () {
        setState(() {
          selectedPlanIndex = index;
        });
      },
      child: Container(
        padding: EdgeInsets.all(10.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          border: Border.all(
            color: Color.fromRGBO(119, 75, 36, 1),
            width: 2.0,
          ),
          color: isSelected
              ? Colors.green
              : Colors.white, // Применяем зеленый цвет, если выбран
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              tariffPlans[index].title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(119, 75, 36, 1),
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              tariffPlans[index].description,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color.fromRGBO(119, 75, 36, 1),
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              '${tariffPlans[index].price} ₽ за ${tariffPlans[index].days} дней',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(119, 75, 36, 1),
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
  final String description;
  final int days;
  final double price;

  TariffPlan(this.title, this.description, this.days, this.price);
}
