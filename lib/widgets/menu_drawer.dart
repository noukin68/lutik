// ignore_for_file: library_prefixes, prefer_const_constructors

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:web_parental_control/account_info_page.dart';
import 'package:web_parental_control/home_screen.dart';
import 'package:web_parental_control/login_page.dart';

class MenuDrawer extends StatelessWidget {
  final int userId;

  const MenuDrawer({super.key, required this.userId});

  Future<Map<String, dynamic>> fetchUserInfo() async {
    final userInfoResponse =
        await http.get(Uri.parse('http://62.217.182.138:3000/user/$userId'));
    final licenseInfoResponse = await fetchUserLicense();

    if (userInfoResponse.statusCode == 200 &&
        licenseInfoResponse.statusCode == 200) {
      final userInfo = jsonDecode(userInfoResponse.body);
      final licenseInfo = jsonDecode(licenseInfoResponse.body);

      return {
        'username': userInfo['username'],
        'uid': licenseInfo['uid'],
      };
    } else {
      throw Exception('Failed to load user info or license info');
    }
  }

  Future<http.Response> fetchUserLicense() async {
    return await http
        .get(Uri.parse('http://62.217.182.138:3000/licenseInfo/$userId'));
  }

  Future<String> fetchUserAvatar() async {
    final response = await http
        .get(Uri.parse('http://62.217.182.138:3000/getAvatar/$userId'));
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['avatarUrl'];
    } else {
      throw Exception('Failed to load user avatar');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: const Color(0xFFEFCEAD),
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Expanded(
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      'Меню',
                      style: TextStyle(
                        color: Color.fromRGBO(119, 75, 36, 1),
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_back),
                  color: Colors.black,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Color.fromRGBO(119, 75, 36, 1),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      FutureBuilder<String>(
                        future: fetchUserAvatar(),
                        builder: (context, avatarSnapshot) {
                          if (avatarSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          } else if (avatarSnapshot.hasError) {
                            return const CircleAvatar(
                              radius: 40,
                              child: Icon(Icons.person),
                            );
                          } else {
                            return CircleAvatar(
                              radius: 40,
                              backgroundImage:
                                  NetworkImage(avatarSnapshot.data!),
                              child: null,
                            );
                          }
                        },
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FutureBuilder<Map<String, dynamic>>(
                            future: fetchUserInfo(),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const CircularProgressIndicator();
                              } else if (snapshot.hasError) {
                                return const Text(
                                  'Ошибка при загрузке информации о пользователе',
                                  style: TextStyle(
                                    color: Colors.white,
                                  ),
                                );
                              } else {
                                return Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Имя: ${snapshot.data!['username']}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                          ),
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              'UID: ${snapshot.data!['uid']}',
                                              style: const TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            IconButton(
                                              icon: Icon(Icons.copy),
                                              color: Colors.white,
                                              onPressed: () {
                                                Clipboard.setData(ClipboardData(
                                                    text:
                                                        snapshot.data!['uid']));
                                                ScaffoldMessenger.of(context)
                                                    .showSnackBar(
                                                  const SnackBar(
                                                      content: Text(
                                                          'UID скопирован')),
                                                );
                                              },
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            ListTile(
              title: const Text(
                'Подключение устройств',
                style: TextStyle(color: Colors.black87),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation1, animation2) =>
                        HomePage(userId),
                    transitionDuration: const Duration(milliseconds: 500),
                    transitionsBuilder:
                        (context, animation1, animation2, child) {
                      return FadeTransition(
                        opacity: animation1,
                        child: child,
                      );
                    },
                  ),
                );
              },
            ),
            ListTile(
              title: const Text(
                'Мой аккаунт',
                style: TextStyle(color: Colors.black87),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation1, animation2) =>
                        AccountInfoPage(userId),
                    transitionDuration: const Duration(milliseconds: 500),
                    transitionsBuilder:
                        (context, animation1, animation2, child) {
                      return FadeTransition(
                        opacity: animation1,
                        child: child,
                      );
                    },
                  ),
                );
              },
            ),
            ListTile(
              title: const Text(
                'Выйти из аккаунта',
                style: TextStyle(color: Colors.black87),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation1, animation2) =>
                        LoginPage(),
                    transitionDuration: const Duration(milliseconds: 500),
                    transitionsBuilder:
                        (context, animation1, animation2, child) {
                      return FadeTransition(
                        opacity: animation1,
                        child: child,
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
