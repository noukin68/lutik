// ignore_for_file: unused_local_variable, library_prefixes, library_private_types_in_public_api, avoid_print, prefer_conditional_assignment, sized_box_for_whitespace, use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:web_parental_control/circle_pregress_painter.dart';
import 'package:web_parental_control/countdown_timer.dart';
import 'package:web_parental_control/login_page.dart';
import 'package:web_parental_control/number_picker.dart';
import 'package:web_parental_control/process_info.dart';
import 'package:web_parental_control/process_screen.dart';
import 'package:web_parental_control/request_response.dart';
import 'main.dart';

class TimerScreen extends StatefulWidget {
  final IO.Socket socket;
  final String uid;

  const TimerScreen({super.key, required this.socket, required this.uid});
  static List<ProcessInfo> processInfoList = [];

  static ReceivePort? receivePort;

  static Future<void> onActionReceivedImplementationMethod(
      receivedAction) async {
    if (receivedAction.actionType) {
      Navigator.push(
        MyApp.navigatorKey.currentState!.context,
        MaterialPageRoute(
          builder: (context) => ProcessInfoScreen(TimerScreen.processInfoList),
        ),
      );
    }
  }

  @override
  _TimerScreenState createState() => _TimerScreenState();
}

class _TimerScreenState extends State<TimerScreen>
    with TickerProviderStateMixin {
  int? initialTimeInSeconds;
  int hours = 0;
  int minutes = 0;
  int seconds = 0;
  bool isCountingDown = false;
  bool isTimerRunning = false;
  bool isSocketConnected = true;
  List<ProcessInfo> processInfoList = [];

  String selectedSubject = 'История';
  int selectedClass = 5;

  late AnimationController _buttonAnimationController;
  late Animation<double> _buttonScaleAnimation;

  @override
  void initState() {
    super.initState();

    _buttonAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _buttonScaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _buttonAnimationController,
        curve: Curves.easeInOut,
      ),
    );

    widget.socket.on('process-data', (data) {
      setState(() {
        if (data != null && data['processes'] != null && data['uid'] != null) {
          var processes = data['processes'];
          var uid = data['uid'];
          if (processes is List) {
            TimerScreen.processInfoList = List<ProcessInfo>.from(
              processes.map((item) {
                if (item is Map<String, dynamic>) {
                  return ProcessInfo.fromJson(item);
                }
              }),
            );
            processInfoList = List<ProcessInfo>.from(
              processes.map((item) {
                if (item is Map<String, dynamic>) {
                  return ProcessInfo.fromJson(item);
                }
              }),
            );
          } else {
            TimerScreen.processInfoList = [];
            processInfoList = [];
          }
        } else {
          TimerScreen.processInfoList = [];
          processInfoList = [];
        }
      });
    });

    widget.socket.on('connection-status', (data) {
      setState(() {
        isSocketConnected = data['connected'] ?? false;
      });
    });

    widget.socket.on('restart-time', (data) {
      restartTime(data);
    });

    widget.socket.on(
      'test-completed',
      (data) {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: const Color.fromRGBO(119, 75, 36, 1),
              title: const Text(
                "Уведомление",
                style: TextStyle(
                  color: Color.fromRGBO(239, 206, 173, 1),
                ),
              ),
              content: const Text(
                "Тест завершен",
                style: TextStyle(
                  color: Color.fromRGBO(239, 206, 173, 1),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: onContinuePressed,
                  child: const Text(
                    'Продолжить работу',
                    style: TextStyle(
                      color: Color(0xFFEFCEAD),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: onFinishPressed,
                  child: const Text(
                    'Завершить работу',
                    style: TextStyle(
                      color: Color(0xFFEFCEAD),
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void restartTime(data) {
    try {
      final jsonData = json.decode(data);
      final List<RequestResponse> restart = (jsonData as List)
          .map((item) => RequestResponse.fromJson(item))
          .toList();

      if (restart.isNotEmpty) {
        final uid = restart[0].uid;

        if (uid == widget.uid) {
          print('UID: $uid');
          setState(() {
            hours = (initialTimeInSeconds! / 3600).floor();
            minutes = ((initialTimeInSeconds! % 3600) / 60).floor();
            seconds = initialTimeInSeconds! % 60;
            sendTimeToServer();
          });
        } else {
          print('UID не соответствует или initialTimeInSeconds равен null');
        }
      } else {
        print('Ошибка десериализации ответа');
      }
    } catch (e) {
      print('Ошибка при обработке данных перезапуска: $e');
    }
  }

  @pragma("vm:entry-point")
  static Future<void> navigateToProcessInfoScreen(
      BuildContext context, List<ProcessInfo> processInfoList) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProcessInfoScreen(processInfoList),
      ),
    );
  }

  Future<void> sendSubjectAndClassToServer(
      String selectedSubject, int selectedClass) async {
    widget.socket.emit('subject-and-class', {
      'uid': widget.uid,
      'subject': selectedSubject,
      'grade': selectedClass
    });
  }

  Future<String?> showSubjectSelectionDialog() async {
    final selectedSubject = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color.fromRGBO(156, 138, 114, 1),
          title: const Text(
            'Выберите предмет',
            style: TextStyle(
              color: Color.fromRGBO(119, 75, 36, 1),
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: const Text(
                  'История',
                  style: TextStyle(
                    color: Color.fromRGBO(239, 206, 173, 1),
                  ),
                ),
                onTap: () {
                  Navigator.pop(context, 'История');
                },
              ),
            ],
          ),
        );
      },
    );

    return selectedSubject;
  }

  Future<int?> showClassSelectionDialog() async {
    final selectedClass = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          backgroundColor: const Color.fromRGBO(156, 138, 114, 1),
          title: const Text(
            'Выберите класс',
            style: TextStyle(
              color: Color.fromRGBO(119, 75, 36, 1),
            ),
          ),
          children: <Widget>[
            for (int i = 5; i <= 11; i++)
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, i);
                },
                child: Text(
                  '$i класс',
                  style: const TextStyle(
                    color: Color.fromRGBO(239, 206, 173, 1),
                  ),
                ),
              ),
          ],
        );
      },
    );

    return selectedClass;
  }

  Future<void> onContinuePressed() async {
    widget.socket.emit('continue-work', {
      'uid': widget.uid,
    });
    Navigator.pop(context);
  }

  void onFinishPressed() {
    widget.socket.emit('finish-work', {
      'uid': widget.uid,
    });
    Navigator.pop(context);
  }

  void startCountdown() {
    final totalSeconds = hours * 3600 + minutes * 60 + seconds;

    setState(() {
      isCountingDown = true;
      isTimerRunning = true;
    });

    Future.delayed(Duration(seconds: totalSeconds), () {
      setState(() {
        isCountingDown = false;
        isTimerRunning = false;
      });
    });
  }

  void stopCountdown() {
    setState(() {
      isCountingDown = false;
      isTimerRunning = false;
    });

    final totalSeconds = calculateRemainingSeconds();
    print('Stopping timer and sending time: $totalSeconds');
    widget.socket.emit('stop-timer', {
      'uid': widget.uid,
      'totalSeconds': totalSeconds,
    });
  }

  void sendTimeToServer() {
    final totalSeconds = hours * 3600 + minutes * 60 + seconds;
    if (initialTimeInSeconds == null) {
      initialTimeInSeconds =
          totalSeconds; // Сохраняем время при первом получении
    }

    print('Sending time: $hours:$minutes:$seconds');
    widget.socket.emit('time-received', {
      'uid': widget.uid,
      'timeInSeconds': totalSeconds,
    });

    startCountdown();
  }

  int calculateRemainingSeconds() {
    final totalSeconds = hours * 3600 + minutes * 60 + seconds;
    return totalSeconds;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Лимит времени'),
        backgroundColor: const Color.fromRGBO(119, 75, 36, 1),
        foregroundColor: const Color.fromRGBO(239, 206, 173, 1),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.exit_to_app,
              color: Color.fromRGBO(239, 206, 173, 1),
            ),
            onPressed: () => logout(),
          ),
        ],
      ),
      body: Container(
        color: const Color(0xFFEFCEAD),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 200,
                height: 200,
                child: CustomPaint(
                  painter: CircleProgressPainter(
                      remainingSeconds: calculateRemainingSeconds()),
                  child: Center(
                    child: isCountingDown
                        ? CountdownTimer(
                            seconds: calculateRemainingSeconds(),
                            onFinish: () {
                              setState(() {
                                isCountingDown = false;
                              });
                            },
                          )
                        : Text(
                            formatTime(calculateRemainingSeconds()),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Color.fromRGBO(119, 75, 36, 1),
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  NumberPicker(
                    title: 'Часы',
                    minValue: 0,
                    maxValue: 23,
                    onChanged: (value) {
                      setState(() {
                        hours = value;
                      });
                    },
                  ),
                  NumberPicker(
                    title: 'Минуты',
                    minValue: 0,
                    maxValue: 59,
                    onChanged: (value) {
                      setState(() {
                        minutes = value;
                      });
                    },
                  ),
                  NumberPicker(
                    title: 'Секунды',
                    minValue: 0,
                    maxValue: 59,
                    onChanged: (value) {
                      setState(() {
                        seconds = value;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              AnimatedBuilder(
                animation: _buttonScaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _buttonScaleAnimation.value,
                    child: child,
                  );
                },
                child: GestureDetector(
                  onTapDown: (_) {
                    _buttonAnimationController.forward();
                  },
                  onTapUp: (_) async {
                    _buttonAnimationController.reverse();
                    final subjectSelected = await showSubjectSelectionDialog();
                    if (subjectSelected == null) {
                      return;
                    }
                    final classSelected = await showClassSelectionDialog();
                    if (classSelected == null) {
                      return;
                    }
                    sendSubjectAndClassToServer(subjectSelected, classSelected);
                    sendTimeToServer();
                  },
                  onTapCancel: () {
                    _buttonAnimationController.reverse();
                  },
                  child: Container(
                    width: 200,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: const Color.fromRGBO(119, 75, 36, 1),
                    ),
                    child: const Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.play_arrow_rounded,
                            color: Color.fromRGBO(239, 206, 173, 1),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Установить таймер',
                            style: TextStyle(
                              color: Color.fromRGBO(239, 206, 173, 1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              AnimatedBuilder(
                animation: _buttonScaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _buttonScaleAnimation.value,
                    child: child,
                  );
                },
                child: GestureDetector(
                  onTapDown: (_) {
                    _buttonAnimationController.forward();
                  },
                  onTapUp: (_) {
                    _buttonAnimationController.reverse();
                    stopCountdown();
                  },
                  onTapCancel: () {
                    _buttonAnimationController.reverse();
                  },
                  child: Container(
                    width: 200,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: const Color.fromRGBO(119, 75, 36, 1),
                    ),
                    child: const Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.stop,
                            color: Color.fromRGBO(239, 206, 173, 1),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Остановить таймер',
                            style: TextStyle(
                              color: Color.fromRGBO(239, 206, 173, 1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              AnimatedBuilder(
                animation: _buttonScaleAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _buttonScaleAnimation.value,
                    child: child,
                  );
                },
                child: GestureDetector(
                  onTapDown: (_) {
                    _buttonAnimationController.forward();
                  },
                  onTapUp: (_) {
                    _buttonAnimationController.reverse();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ProcessInfoScreen(processInfoList),
                      ),
                    );
                  },
                  onTapCancel: () {
                    _buttonAnimationController.reverse();
                  },
                  child: Container(
                    width: 200,
                    height: 50,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: const Color.fromRGBO(119, 75, 36, 1),
                    ),
                    child: const Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.info_outline,
                            color: Color.fromRGBO(239, 206, 173, 1),
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Отчёт',
                            style: TextStyle(
                              color: Color.fromRGBO(239, 206, 173, 1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Статус подключения: ${isSocketConnected ? 'Сопряжено' : 'Не сопряжено'}',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Color.fromRGBO(119, 75, 36, 1),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _buttonAnimationController.dispose();
    super.dispose();
  }

  String formatTime(int totalSeconds) {
    final int hours = totalSeconds ~/ 3600;
    final int minutes = (totalSeconds % 3600) ~/ 60;
    final int seconds = totalSeconds % 60;
    return '${hours.toString().padLeft(2, '0')} : ${minutes.toString().padLeft(2, '0')} : ${seconds.toString().padLeft(2, '0')}';
  }

  void logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isLoggedIn', false);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }
}
