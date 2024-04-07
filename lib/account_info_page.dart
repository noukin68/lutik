// ignore_for_file: library_private_types_in_public_api, avoid_print, prefer_const_declarations

import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:web_parental_control/renew_license_screen.dart';
import 'package:web_parental_control/widgets/menu_drawer.dart';

class AccountInfoPage extends StatefulWidget {
  final int userId;

  const AccountInfoPage(this.userId, {super.key});

  @override
  _AccountInfoPageState createState() => _AccountInfoPageState();
}

class _AccountInfoPageState extends State<AccountInfoPage> {
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
    return Scaffold(
      backgroundColor: const Color(0xFFEFCEAD),
      appBar: AppBar(
        title: const Text('Информация об аккаунте'),
        backgroundColor: const Color.fromRGBO(119, 75, 36, 1),
      ),
      drawer: MenuDrawer(userId: widget.userId),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<Map<String, dynamic>>(
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
              final licenseInfo = snapshot.data!;
              return LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth > 600) {
                    return _buildDesktopLayout(userInfo, licenseInfo);
                  } else {
                    return _buildMobileLayout(userInfo, licenseInfo);
                  }
                },
              );
            }
          },
        ),
      ),
    );
  }

  Widget _buildDesktopLayout(
      Map<String, dynamic> userInfo, Map<String, dynamic> licenseInfo) {
    final double avatarSize = 600;
    final double avatarRadius = 216;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'UID',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(119, 75, 36, 1),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Text(
                          userInfo['uid'],
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color.fromRGBO(119, 75, 36, 1),
                          ),
                        ),
                        const SizedBox(width: 10),
                        IconButton(
                          icon: Icon(Icons.copy),
                          onPressed: () {
                            Clipboard.setData(
                                ClipboardData(text: userInfo['uid']));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('UID скопирован')),
                            );
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Информация о пользователе',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(119, 75, 36, 1),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Имя пользователя: ${userInfo['username']}\nEmail: ${userInfo['email']}\nНомер телефона: ${userInfo['phone_number']}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color.fromRGBO(119, 75, 36, 1),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Статус лицензии',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(119, 75, 36, 1),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Статус: Активна\nСрок окончания: ${calculateRemainingDays(licenseInfo['expiration_date'])} дней',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color.fromRGBO(119, 75, 36, 1),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) =>
                                  RenewLicensePage(widget.userId)),
                        );
                      },
                      child: Text('Продлить лицензию'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Color.fromRGBO(239, 206, 173, 1),
                        backgroundColor: Color.fromRGBO(119, 75, 36, 1),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 20),
        Expanded(
          flex: 1,
          child: SizedBox(
            height: avatarSize,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () async {
                    FilePickerResult? result =
                        await FilePicker.platform.pickFiles(
                      type: FileType.image,
                      allowMultiple: false,
                    );

                    if (result != null) {
                      PlatformFile file = result.files.first;
                      await uploadAvatar(
                          widget.userId.toString(), file.bytes!, file.name);
                      setState(() {
                        _userInfoFuture = fetchUserInfo(widget.userId);
                      });
                    }
                  },
                  child: _isAvatarUploaded
                      ? FutureBuilder<Map<String, dynamic>>(
                          future: _userInfoFuture,
                          builder: (context, snapshot) {
                            final userInfo = snapshot.data;
                            final avatarUrl = userInfo?['avatar_url'];
                            print('Avatar URL: ${avatarUrl}');

                            return CircleAvatar(
                              radius: avatarRadius,
                              backgroundImage: avatarUrl.isNotEmpty
                                  ? NetworkImage(avatarUrl)
                                  : null,
                              child: avatarUrl.isEmpty
                                  ? const Icon(Icons.person,
                                      size: 80, color: Colors.white)
                                  : null,
                            );
                          },
                        )
                      : const CircularProgressIndicator(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(
      Map<String, dynamic> userInfo, Map<String, dynamic> licenseInfo) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFCEAD),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'UID',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(119, 75, 36, 1),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    userInfo['uid'],
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color.fromRGBO(119, 75, 36, 1),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Информация о пользователе',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(119, 75, 36, 1),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'Имя пользователя: ${userInfo['username']}\nEmail: ${userInfo['email']}\nНомер телефона: ${userInfo['phone_number']}',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Color.fromRGBO(119, 75, 36, 1),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 20),
                      GestureDetector(
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
                        child: _isAvatarUploaded
                            ? FutureBuilder<Map<String, dynamic>>(
                                future: _userInfoFuture,
                                builder: (context, snapshot) {
                                  final userInfo = snapshot.data;
                                  final avatarUrl = userInfo?['avatar_url'];
                                  print('Avatar URL: ${avatarUrl}');

                                  return CircleAvatar(
                                    radius: 40,
                                    backgroundImage: avatarUrl.isNotEmpty
                                        ? NetworkImage(avatarUrl)
                                        : null,
                                    child: avatarUrl.isEmpty
                                        ? const Icon(Icons.person,
                                            size: 80, color: Colors.white)
                                        : null,
                                  );
                                },
                              )
                            : const CircularProgressIndicator(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Статус лицензии',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(119, 75, 36, 1),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Статус: Активна\nСрок окончания: ${calculateRemainingDays(licenseInfo['expiration_date'])} дней',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color.fromRGBO(119, 75, 36, 1),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                RenewLicensePage(widget.userId)),
                      );
                    },
                    child: Text('Продлить лицензию'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Color.fromRGBO(239, 206, 173, 1),
                      backgroundColor: Color.fromRGBO(119, 75, 36, 1),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarContainer() {
    return Scaffold(
      backgroundColor: const Color(0xFFEFCEAD),
      appBar: AppBar(
        title: const Text('Информация об аккаунте'),
        backgroundColor: const Color.fromRGBO(119, 75, 36, 1),
      ),
      drawer: MenuDrawer(userId: widget.userId),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FutureBuilder<Map<String, dynamic>>(
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
              final licenseInfo = snapshot.data!;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'UID',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color.fromRGBO(119, 75, 36, 1),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          userInfo['uid'],
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color.fromRGBO(119, 75, 36, 1),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                'Имя пользователя: ${userInfo['username']}\nEmail: ${userInfo['email']}\nНомер телефона: ${userInfo['phone_number']}',
                                style: const TextStyle(
                                  fontSize: 16,
                                  color: Color.fromRGBO(119, 75, 36, 1),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        GestureDetector(
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
                          child: _isAvatarUploaded
                              ? FutureBuilder<Map<String, dynamic>>(
                                  future: _userInfoFuture,
                                  builder: (context, snapshot) {
                                    final userInfo = snapshot.data;
                                    final avatarUrl = userInfo?['avatar_url'];
                                    print('Avatar URL: ${avatarUrl}');

                                    return CircleAvatar(
                                      radius: 40,
                                      backgroundImage: avatarUrl.isNotEmpty
                                          ? NetworkImage(avatarUrl)
                                          : null,
                                      child: avatarUrl.isEmpty
                                          ? const Icon(Icons.person)
                                          : null,
                                    );
                                  },
                                )
                              : const CircularProgressIndicator(),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Статус лицензии',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Color.fromRGBO(119, 75, 36, 1),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Статус: Активна\nСрок окончания: ${calculateRemainingDays(licenseInfo['expiration_date'])} дней',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color.fromRGBO(119, 75, 36, 1),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      RenewLicensePage(widget.userId)),
                            );
                          },
                          child: Text('Продлить лицензию'),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }
          },
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
