import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:web_parental_control/timer_screen.dart';
import 'package:http/http.dart' as http;
import 'package:web_parental_control/widgets/menu_drawer.dart';

class HomePage extends StatefulWidget {
  final int userId;

  const HomePage(this.userId);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
        socket?.emit('join', uid);

        socket?.once('joined', (data) {
          setState(() {
            if (!connectedUIDs.contains(uid)) {
              connectedUIDs.add(uid);
              sockets[uid] = socket!;
            }
          });
        });
      } else {
        var jsonResponse = jsonDecode(response.body);
        showErrorMessage('Ошибка: ${jsonResponse['error']}');
      }
    } catch (error) {
      showErrorMessage('Ошибка: $error');
    }
  }

  void removeUID(String uid) {
    setState(() {
      connectedUIDs.remove(uid);
      sockets.remove(uid);
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEFCEAD),
      appBar: AppBar(
        title: Text('Подключение устройств'),
        backgroundColor: const Color.fromRGBO(119, 75, 36, 1),
      ),
      drawer: MenuDrawer(
        userId: widget.userId,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: LayoutBuilder(
          builder: (context, constraints) {
            if (constraints.maxWidth > 600) {
              return _buildDesktopLayout();
            } else {
              return _buildMobileLayout();
            }
          },
        ),
      ),
    );
  }

  Widget _buildDesktopLayout() {
    return Center(
      child: Container(
        width: 500,
        height: 500,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              width: 300,
              child: TextField(
                controller: uidController,
                decoration: InputDecoration(
                  hintText: 'Введите UID',
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
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                String uid = uidController.text.trim();
                if (uid.isNotEmpty) {
                  addUID(uid);
                  uidController.clear();
                } else {
                  showErrorMessage('Пожалуйста, введите действительный UID');
                }
              },
              child: Text('Добавить соединение'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Color.fromRGBO(239, 206, 173, 1),
                backgroundColor: Color.fromRGBO(119, 75, 36, 1),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Список подключений',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            SizedBox(height: 10),
            Expanded(
              child: SizedBox(
                width: 300,
                child: connectedUIDs.isEmpty
                    ? Center(
                        child: Text('У пользователя нет подключений'),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: connectedUIDs.length,
                        itemBuilder: (context, index) {
                          String uid = connectedUIDs[index];
                          return Card(
                            child: ListTile(
                              title: Text(uid),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () {
                                      removeUID(uid);
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.arrow_forward),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => TimerScreen(
                                            socket: sockets[uid]!,
                                            uid: uid,
                                          ),
                                        ),
                                      ).then((_) {});
                                    },
                                  ),
                                ],
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
    );
  }

  Widget _buildMobileLayout() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        TextField(
          controller: uidController,
          decoration: InputDecoration(
            hintText: 'Введите UID',
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
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: () {
            String uid = uidController.text.trim();
            if (uid.isNotEmpty) {
              addUID(uid);
              uidController.clear();
            } else {
              showErrorMessage('Пожалуйста, введите действительный UID');
            }
          },
          child: Text('Добавить соединение'),
          style: ElevatedButton.styleFrom(
            foregroundColor: Color.fromRGBO(239, 206, 173, 1),
            backgroundColor: Color.fromRGBO(119, 75, 36, 1),
          ),
        ),
        SizedBox(height: 20),
        Expanded(
          child: connectedUIDs.isEmpty
              ? Center(
                  child: Text('У пользователя нет подключений'),
                )
              : ListView.builder(
                  itemCount: connectedUIDs.length,
                  itemBuilder: (context, index) {
                    String uid = connectedUIDs[index];
                    return Card(
                      child: ListTile(
                        title: Text(uid),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () {
                                removeUID(uid);
                              },
                            ),
                            IconButton(
                              icon: Icon(Icons.arrow_forward),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => TimerScreen(
                                      socket: sockets[uid]!,
                                      uid: uid,
                                    ),
                                  ),
                                ).then((_) {});
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
