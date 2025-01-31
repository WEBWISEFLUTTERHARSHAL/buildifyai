import 'dart:convert';
import 'package:Buildify_AI/models/user.dart';
import 'package:Buildify_AI/screens/composeMessage.dart';
import 'package:Buildify_AI/screens/dailyLog.dart';
import 'package:Buildify_AI/screens/fileManager.dart';
import 'package:Buildify_AI/screens/forwardMessage.dart';
import 'package:Buildify_AI/screens/home.dart';
import 'package:Buildify_AI/screens/listChat.dart';
import 'package:Buildify_AI/screens/login.dart';
import 'package:Buildify_AI/screens/newChat.dart';
import 'package:Buildify_AI/screens/newGroup.dart';
import 'package:Buildify_AI/screens/punchItem.dart';
import 'package:Buildify_AI/screens/qrCodeScanner.dart';
import 'package:Buildify_AI/screens/takePhoto.dart';
import 'package:Buildify_AI/utils/routes.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

CurrentUser? currentUser;
String? token;
late Widget initialScreen;
List<dynamic>? projectDropdownItems;
ValueNotifier<String> globalSelectedProjectId = ValueNotifier('');
int? creatorId;
Map<dynamic, dynamic>? businessInfo;
List<String> statusDropdownItems = [
  "Pending",
  "Approved",
  "Shipped",
  "Delivered",
];

// Initial Call
checkLoginOrHS() async {
  String? expiresAt;
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  creatorId = prefs.getInt('creator_id');
  businessInfo = json.decode(prefs.getString('business_info') ?? '{}');
  token = await prefs.getString('token');
  expiresAt = await prefs.getString('expiresAt');
  if (token != null && expiresAt != null) {
    if (DateTime.now().isAfter(DateTime.parse(expiresAt))) {
      await prefs.remove('token');
      await prefs.remove('expiresAt');
      return Login();
    } else {
      return Home();
    }
  } else {
    return Login();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initialScreen = await checkLoginOrHS();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  _getPermsiions() async {
    await Permission.storage.request();
  }

  @override
  void initState() {
    _getPermsiions();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    _getPermsiions();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // fontFamily: 'inter',
        useMaterial3: true,
      ),
      home: initialScreen,
      // home: const Newgroup(),
      routes: {
        Routes.homeRoute: (context) => const Home(),
        Routes.dailyLogRoute: (context) => DailyLog(),
        Routes.loginRoute: (context) => const Login(),
        Routes.punchItemRoute: (context) => PunchItem(),
        Routes.takePhotoRoute: (context) => const TakePhoto(),
        Routes.fileManagerRoute: (context) => const FileManager(),
        Routes.composeMessageRoute: (context) => const ComposeMessage(),
        Routes.scanQrRoute: (context) => const QrCodeScanner(),
        Routes.listChats: (context) => const ListChat(),
        Routes.newChat: (context) => const Newchat(),
        Routes.newGroup: (context) => const Newgroup(),
        Routes.forwardMessage: (context) => const ForwardMessage(),
      },
    );
  }
}
