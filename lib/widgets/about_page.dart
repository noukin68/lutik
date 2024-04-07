import 'package:flutter/material.dart';
import 'package:web_parental_control/widgets/login_page.dart';
import 'package:web_parental_control/widgets/rates_page.dart';

class AboutPage extends StatelessWidget {
  final int userId;
  const AboutPage(this.userId, {super.key});

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
                    MaterialPageRoute(builder: (context) => AboutPage(userId)),
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
          decoration: const BoxDecoration(
            gradient: RadialGradient(
              colors: [
                Colors.purple,
                Colors.purple, // Цвет внутри круга
                Color.fromRGBO(55, 55, 55, 1), // Цвет вне круга
              ],
              center:
                  Alignment.centerLeft, // Центр градиента - по центру экрана
              radius: 1.8, // Радиус градиента
              stops: [0.2, 0.3, 1], // Остановки для цветового перехода
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Image.asset(
                          'assets/images/family.png',
                          width: 700,
                        ),
                        const SizedBox(
                          width: 20,
                        ), // Ваше изображение слева
                        Expanded(
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: SizedBox(
                              width: 1180, // Change this to the desired width
                              child: Card(
                                color: Colors.white.withOpacity(0.8),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(30),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      RichText(
                                        text: const TextSpan(
                                          style: TextStyle(
                                              fontSize: 45,
                                              fontFamily: 'Jura',
                                              color: Colors
                                                  .black), // Здесь укажите общий стиль текста
                                          children: <TextSpan>[
                                            TextSpan(
                                                text:
                                                    'Ваш ребенок стал проводить слишком много времени в компьютере? Стал более'),
                                            TextSpan(
                                                text: ' агрессивным',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            TextSpan(text: ' и проводит все'),
                                            TextSpan(
                                                text:
                                                    ' меньше времени с семьей',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            TextSpan(text: '?'),
                                            TextSpan(
                                                text: ' Мы поможем',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            TextSpan(
                                                text: ' решить вашу проблему!'),
                                            TextSpan(
                                                text:
                                                    ' Наше приложение поможет избавить '),
                                            TextSpan(
                                                text: 'вашего ребенка',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            TextSpan(
                                                text:
                                                    ' от компьютерной зависимости, а также "подтянет" его по предметам'),
                                            TextSpan(
                                                text: ' на ваш выбор',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            TextSpan(text: '!'),
                                            TextSpan(
                                                text: ' Наше приложение имеет'),
                                            TextSpan(
                                                text: ' гибкую',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            TextSpan(text: ' вопросительную'),
                                            TextSpan(
                                                text: ' базу',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            TextSpan(
                                                text:
                                                    ' по всем школьным предметам,'),
                                            TextSpan(
                                                text: ' удобную настройку',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            TextSpan(text: ' и'),
                                            TextSpan(
                                                text: ' простое управление',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            TextSpan(
                                                text:
                                                    ' через мобильное устройство'),
                                            TextSpan(
                                                text: ' с любой точки',
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold)),
                                            TextSpan(text: ' земного шара.'),
                                          ],
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
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
