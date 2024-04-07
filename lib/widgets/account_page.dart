// ignore_for_file: unused_field, unused_local_variable, avoid_print, sized_box_for_whitespace, unnecessary_brace_in_string_interps

import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:web_parental_control/widgets/about_page.dart';
import 'package:web_parental_control/widgets/connect_devices_page.dart';
import 'package:web_parental_control/widgets/login_page.dart';
import 'dart:convert';

import 'package:web_parental_control/widgets/renew_rates_page.dart';

class AccountPage extends StatefulWidget {
  final int userId;
  const AccountPage(this.userId, {super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  late Future<Map<String, dynamic>> _userInfoFuture;
  bool _isAvatarUploaded = false;

  @override
  void initState() {
    super.initState();
    _userInfoFuture = fetchUserInfo(widget.userId);
    _fetchAvatar();
  }

  Future<void> _fetchAvatar() async {
    try {
      final userInfo = await fetchUserInfo(widget.userId);
      final avatarUrl = userInfo['avatar_url'];
      setState(() {
        _isAvatarUploaded = avatarUrl != null;
      });
    } catch (e) {
      print('Failed to fetch avatar: $e');
    }
  }

  Future<File?> pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['png', 'jpg'],
      allowMultiple: false,
    );

    if (result != null) {
      PlatformFile file = result.files.first;
      return File(file.path!);
    } else {
      return null;
    }
  }

  Future<void> uploadAvatar(
      String userId, List<int> imageBytes, String fileName) async {
    final url = Uri.parse('http://62.217.182.138:3000/uploadAvatar/$userId');
    final request = http.MultipartRequest('POST', url);
    request.files.add(
        http.MultipartFile.fromBytes('avatar', imageBytes, filename: fileName));

    final response = await request.send();
    final responseData = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      final data = jsonDecode(responseData);
      final avatarUrl = data['avatarUrl'];
      print('Avatar uploaded successfully. URL: $avatarUrl');

      setState(() {
        _userInfoFuture = fetchUserInfo(widget.userId);
        _isAvatarUploaded = true; // Устанавливаем _isAvatarUploaded в true
      });
    } else {
      print('Failed to upload avatar: ${response.reasonPhrase}');
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
                child: const Text(
                  'Мой аккаунт',
                  style: TextStyle(
                    fontSize: 35,
                    fontFamily: 'Jura',
                  ),
                ),
              ),
              const SizedBox(width: 10 * 30),
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
              const SizedBox(width: 10 * 30),
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
        body: FutureBuilder<Map<String, dynamic>>(
          future: fetchUserInfo(widget.userId),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              final userInfo = snapshot.data!;
              final licenseInfo = snapshot.data!;
              return Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      Colors.purple,
                      Colors.purple, // Цвет внутри круга
                      Color.fromRGBO(55, 55, 55, 1), // Цвет вне круга
                    ],
                    center: Alignment
                        .centerLeft, // Центр градиента - по центру экрана
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
                              const SizedBox(
                                width: 200,
                              ),
                              Expanded(
                                child: _buildUserInfoCard(),
                              ),
                              const SizedBox(
                                width: 500,
                              ),
                              Expanded(
                                child: _buildLicenseInfo(licenseInfo),
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
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildUserInfoCard() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _userInfoFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Center(
            child: Text('Ошибка: ${snapshot.error}'),
          );
        } else {
          final userInfo = snapshot.data!;
          return _buildUserInfo(userInfo);
        }
      },
    );
  }

  Widget _buildUserInfo(Map<String, dynamic> userInfo) {
    return Container(
      width: 575,
      height: 448,
      child: Card(
        color: const Color.fromRGBO(53, 50, 50, 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(60),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text('Информация о пользователе',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(236, 236, 236, 1),
                    fontFamily: 'Jura',
                  )),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(width: 20),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                          alignment: Alignment.centerLeft,
                          child: Text('Имя: ${userInfo['username']}',
                              style: const TextStyle(
                                fontSize: 20,
                                color: Color.fromRGBO(202, 202, 202, 1),
                                fontFamily: 'Jura',
                              ))),
                      const SizedBox(height: 30),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Почта: ${userInfo['email']}',
                          style: const TextStyle(
                            fontSize: 20,
                            color: Color.fromRGBO(202, 202, 202, 1),
                            fontFamily: 'Jura',
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Text(
                          'Номер телефона: ${userInfo['phone_number']}',
                          style: const TextStyle(
                            fontSize: 20,
                            color: Color.fromRGBO(202, 202, 202, 1),
                            fontFamily: 'Jura',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(
                    width: 30,
                  ), // Space between text fields and avatar
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(
                          height: 0), // Space between text fields and avatar
                      Align(
                        alignment: Alignment.topCenter,
                        child: GestureDetector(
                          onTap: () async {
                            FilePickerResult? result =
                                await FilePicker.platform.pickFiles(
                              type: FileType.image,
                              allowMultiple: false,
                            );

                            if (result != null) {
                              PlatformFile file = result.files.first;
                              await uploadAvatar(widget.userId.toString(),
                                  file.bytes!, file.name);
                              setState(() {
                                _userInfoFuture = fetchUserInfo(widget.userId);
                              });
                            }
                          },
                          child: FutureBuilder<Map<String, dynamic>>(
                            future: _userInfoFuture,
                            builder: (context, snapshot) {
                              final userInfo = snapshot.data;
                              final avatarUrl = userInfo?['avatar_url'];

                              return CircleAvatar(
                                radius: 80,
                                backgroundColor:
                                    const Color.fromRGBO(100, 100, 100, 1),
                                backgroundImage: avatarUrl.isNotEmpty
                                    ? NetworkImage(avatarUrl)
                                    : null,
                                child: avatarUrl.isEmpty
                                    ? Image.asset(
                                        "assets/images/person.png",
                                        scale: 4,
                                      )
                                    : null,
                              );
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLicenseInfo(Map<String, dynamic> licenseInfo) {
    return Align(
      alignment: Alignment.centerRight,
      child: SizedBox(
        width: 1180,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildIdentifierCard(licenseInfo['uid']),
            const SizedBox(height: 120),
            _buildLicenseStatusCard(licenseInfo),
          ],
        ),
      ),
    );
  }

  Widget _buildIdentifierCard(String uid) {
    return Container(
      width: 357,
      height: 111,
      child: Card(
        color: const Color.fromRGBO(53, 50, 50, 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(13),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Идентификатор',
                      style: TextStyle(
                        fontSize: 32,
                        color: Color.fromRGBO(236, 236, 236, 1),
                        fontFamily: 'Jura',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      uid,
                      style: const TextStyle(
                        fontSize: 32,
                        color: Color.fromRGBO(202, 202, 202, 1),
                        fontFamily: 'Jura',
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                iconSize: 24,
                icon: const Icon(
                  Icons.copy,
                  color: Colors.white,
                ),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: uid));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('UID скопирован')),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLicenseStatusCard(Map<String, dynamic> licenseInfo) {
    return Container(
      width: 357,
      height: 196,
      child: Card(
        color: const Color.fromRGBO(53, 50, 50, 1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text('Статус лицензии',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(236, 236, 236, 1),
                      fontFamily: 'Jura',
                    )),
              ),
              const SizedBox(
                height: 5,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Статус: Активна',
                    style: TextStyle(
                      fontSize: 20,
                      color: Color.fromRGBO(202, 202, 202, 1),
                      fontFamily: 'Jura',
                    ),
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Text(
                    'Срок окончания: ${calculateRemainingDays(licenseInfo['expiration_date'])} дней',
                    style: const TextStyle(
                      fontSize: 20,
                      color: Color.fromRGBO(202, 202, 202, 1),
                      fontFamily: 'Jura',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10), // Add space between elements
              Center(
                child: Container(
                  width: 270,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                RenewRatesPage(widget.userId)),
                      );
                    },
                    style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all<Color>(
                          const Color.fromRGBO(100, 100, 100, 1)),
                      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                        RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                      ),
                    ),
                    child: const Center(
                      child: Text(
                        'Продлить лицензию',
                        style: TextStyle(
                          fontSize: 24,
                          color: Color.fromRGBO(202, 202, 202, 1),
                          fontFamily: 'Jura',
                        ),
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  int calculateRemainingDays(String? expirationDate) {
    if (expirationDate == null) return 0;

    DateTime now = DateTime.now();
    DateTime expire = DateTime.parse(expirationDate);
    int difference = expire.difference(now).inDays;
    return difference > 0 ? difference : 0;
  }
}

Future<Map<String, dynamic>> fetchUserInfo(int userId) async {
  final response =
      await http.get(Uri.parse('http://62.217.182.138:3000/user/${userId}'));
  final licenseResponse = await http
      .get(Uri.parse('http://62.217.182.138:3000/licenseInfo/${userId}'));

  if (response.statusCode == 200 && licenseResponse.statusCode == 200) {
    final userInfo = jsonDecode(response.body);
    final licenseInfo = jsonDecode(licenseResponse.body);
    final avatarResponse = await http
        .get(Uri.parse('http://62.217.182.138:3000/getAvatar/${userId}'));
    String? avatarUrl;
    if (avatarResponse.statusCode == 200) {
      final avatarData = jsonDecode(avatarResponse.body);
      avatarUrl = avatarData['avatarUrl'];
    }
    return {
      'uid': licenseInfo['uid'] ?? '',
      'expiration_date': licenseInfo['expiration_date'] ?? '',
      'username': userInfo['username'] ?? '',
      'email': userInfo['email'] ?? '',
      'phone_number': userInfo['phone_number'] ?? '',
      'avatar_url': avatarUrl ?? '',
    };
  } else {
    throw Exception('Failed to load user info');
  }
}
