// ignore_for_file: duplicate_import, library_prefixes, avoid_print, prefer_const_constructors, prefer_const_literals_to_create_immutables, sized_box_for_whitespace

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:web_parental_control/widgets/account_page.dart';
import 'package:web_parental_control/widgets/login_page.dart';

class ConnectDevicesPage extends StatefulWidget {
  final int userId;

  const ConnectDevicesPage(this.userId, {super.key});

  @override
  State<ConnectDevicesPage> createState() => _ConnectDevicesPageState();
}

class _ConnectDevicesPageState extends State<ConnectDevicesPage> {
  IO.Socket? socket;
  TextEditingController uidController = TextEditingController();
  List<String> connectedUIDs = [];
  Map<String, IO.Socket> sockets = {};

  @override
  void initState() {
    super.initState();
    initSocket();
  }

  void initSocket() {
    socket = IO.io('http://62.217.182.138:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket?.connect();

    socket?.on('action', (data) {
      String uid = data['uid'];
      String action = data['action'];
      print('Received action: $action for UID: $uid');
    });
  }

  void addUID(String uid) async {
    Map<String, dynamic> requestBody = {
      'uid': uid,
      'type': 'flutter',
    };

    try {
      var response = await http.post(
        Uri.parse('http://62.217.182.138:3000/check-uid-license'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(requestBody),
      );

      if (response.statusCode == 200) {
        socket?.emit('join', requestBody); // Отправляем данные на сервер
        socket?.once('joined', (data) {
          setState(() {
            if (!connectedUIDs.contains(uid)) {
              connectedUIDs.add(uid);
              sockets[uid] = socket!;
            }
          });

          // После успешного добавления UID отправляем событие flutter-connected
          socket?.emit('flutter-connected', {'uid': uid});
        });
      } else {
        var jsonResponse = jsonDecode(response.body);
        showErrorMessage('Ошибка: ${jsonResponse['error']}');
      }
    } catch (error) {
      showErrorMessage('Ошибка: $error');
    }
  }

  void showErrorMessage(String message) {
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

  void disconnectUID(String uid) {
    setState(() {
      connectedUIDs.remove(uid);
      sockets.remove(uid);
    });
    socket?.emit('disconnect-uid', uid);
    socket?.emit('flutter-disconnected',
        {'uid': uid}); // Отправляем на сервер событие об отключении Flutter
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
                width: 40 * 10,
              ), // Раздвигает логотип и остальные элементы.
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => AccountPage(widget.userId)),
                  );
                },
                child: Text(
                  'Мой аккаунт',
                  style: TextStyle(
                    fontSize: 35,
                    fontFamily: 'Jura',
                  ),
                ),
              ),
              SizedBox(width: 10 * 30),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) =>
                            ConnectDevicesPage(widget.userId)),
                  );
                },
                child: const Text(
                  'Подключение устройств',
                  style: TextStyle(
                    fontSize: 35,
                    fontFamily: 'Jura',
                  ),
                ),
              ),
              SizedBox(width: 10 * 30),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => NewLoginPage()),
                  );
                },
                child: const Text(
                  'Выход',
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
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: [
                Color.fromRGBO(111, 128, 20, 1),
                Color.fromRGBO(111, 128, 20, 1),
                Color.fromRGBO(
                    55, 55, 55, 1), // Цвет внутри круга// Цвет вне круга
              ],
              center:
                  Alignment.bottomRight, // Центр градиента - по центру экрана
              radius: 1.8, // Радиус градиента
              stops: [0.2, 0.3, 1], // Остановки для цветового перехода
            ),
          ),
          child: Column(
            children: [
              SizedBox(height: 40.0), // Added SizedBox for vertical spacing
              SizedBox(
                width: 721,
                height: 272,
                child: Card(
                  color: Color.fromRGBO(53, 50, 50, 1),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(60)),
                  child: Container(
                    padding: EdgeInsets.all(10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 557, // Set the width here
                          height: 85, // Set the height here
                          child: TextField(
                            controller: uidController,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 48,
                                fontFamily:
                                    'Jura'), // Set the text color and size
                            cursorColor: Colors.white,
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Color.fromRGBO(100, 100, 100, 1),
                              border: OutlineInputBorder(
                                borderSide: BorderSide.none,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              hintText: 'Идентификатор',
                              hintStyle: TextStyle(
                                  fontSize: 48.0,
                                  color: Colors.white,
                                  fontFamily: 'Jura'),
                            ),
                          ),
                        ),
                        SizedBox(height: 50.0),
                        SizedBox(
                          width: 302, // Set the width of the button
                          height: 74, // Set the height of the button
                          child: ElevatedButton(
                            onPressed: () {
                              String uid = uidController.text.trim();
                              if (uid.isNotEmpty) {
                                addUID(uid);
                                uidController.clear();
                              } else {
                                showErrorMessage(
                                    'Пожалуйста, введите действительный UID');
                              }
                            },
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                  Color.fromRGBO(34, 16, 16, 1),
                                ),
                                shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        35.0), // Set the border radius of the button
                                  ),
                                )),
                            child: Text(
                              'Подключить',
                              style:
                                  TextStyle(color: Colors.white, fontSize: 36),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              SizedBox(height: 100.0), // Added SizedBox for vertical spacing
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(
                        'Список подключенных устройств:',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 64,
                          fontFamily: 'Jura',
                        ),
                      ),
                      SizedBox(height: 20.0),
                      Expanded(
                        child: Container(
                          width: 957, // Устанавливаем ширину контейнера
                          height: 393, // Устанавливаем высоту контейнера
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(
                                53, 50, 50, 1), // Цвет фона контейнера
                            borderRadius: BorderRadius.circular(
                                60), // Скругление углов контейнера
                          ),
                          child: connectedUIDs.isEmpty
                              ? Center(
                                  child: Text(
                                    'У пользователя нет подключений',
                                    style: TextStyle(
                                        fontSize: 30,
                                        color: Colors.white,
                                        fontFamily: 'Jura'),
                                  ),
                                )
                              : ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: connectedUIDs.length,
                                  physics: BouncingScrollPhysics(),
                                  padding: EdgeInsets.all(28.0),
                                  itemBuilder: (context, index) {
                                    String uid = connectedUIDs[index];
                                    return ListTile(
                                      title: SizedBox(
                                        width:
                                            437, // Устанавливаем ширину BoxDecoration
                                        height:
                                            65, // Устанавливаем высоту BoxDecoration
                                        child: Container(
                                          alignment: Alignment
                                              .centerLeft, // Выравниваем текст по центру
                                          decoration: BoxDecoration(
                                            color: Color.fromRGBO(100, 100, 100,
                                                1), // Полупрозрачный белый цвет фона для текста
                                            borderRadius: BorderRadius.circular(
                                                15), // Скругление углов для текста
                                          ),
                                          padding: EdgeInsets.symmetric(
                                              horizontal:
                                                  10.0), // Отступ для текста
                                          child: Text(
                                            uid,
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 40,
                                              fontFamily: 'Jura',
                                            ),
                                          ),
                                        ),
                                      ),
                                      horizontalTitleGap: 190.0,
                                      trailing: Container(
                                        width: 245,
                                        height: 61,
                                        child: ElevatedButton(
                                          onPressed: () {
                                            disconnectUID(uid);
                                          },
                                          style: ButtonStyle(
                                            backgroundColor:
                                                MaterialStateProperty.all<
                                                    Color>(
                                              Color.fromRGBO(34, 16, 16, 1),
                                            ),
                                            shape: MaterialStateProperty.all<
                                                RoundedRectangleBorder>(
                                              RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(35),
                                              ),
                                            ),
                                          ),
                                          child: Center(
                                            child: Text(
                                              'Отключить',
                                              style: TextStyle(
                                                fontSize: 36,
                                                color: Color.fromRGBO(
                                                    202, 202, 202, 1),
                                                fontFamily: 'Jura',
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16.0),
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
