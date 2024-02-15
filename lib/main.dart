import 'package:admin_panel/screens/admin_login.dart';
import 'package:admin_panel/screens/main_screens.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:admin_panel/constants.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: const FirebaseOptions(
        apiKey: "AIzaSyD42ja7_Sh_Iy1NbGyvOvYR8Olh8TcHrbY",
        authDomain: "university-2696e.firebaseapp.com",
        projectId: "university-2696e",
        storageBucket: "university-2696e.appspot.com",
        messagingSenderId: "1034515887331",
        appId: "1:1034515887331:web:8978e7f53eed96de6b81d6"),
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Admin Panel',
      theme: ThemeData.dark().copyWith(
          scaffoldBackgroundColor: bgColor,
          textTheme: GoogleFonts.poppinsTextTheme(Theme.of(context).textTheme)
              .apply(bodyColor: Colors.white),
          canvasColor: secondaryColor),
      home: MainScreen(),
    );
  }
}
