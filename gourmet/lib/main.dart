import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import "package:firebase_core/firebase_core.dart";
import 'package:gourmet_app/screens/loginScreen.dart';

import 'firebase_options.dart';



void main() async{
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {

    Future<void> initializeApp() async {
      WidgetsFlutterBinding.ensureInitialized();
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      print("Firebase초기화 성공!");
      await Future.delayed(Duration(seconds: 1));
    }

    return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: "gourmetApp",
        theme: ThemeData(
          scaffoldBackgroundColor: Colors.white, // 기본 배경색을 흰색으로 설정
        ),
        home: FutureBuilder(
          future: initializeApp(),
          builder: (context,snapshot)
          {
            if(snapshot.connectionState==ConnectionState.waiting)
              {
                return SafeArea(
                  child: Container(
                    decoration: BoxDecoration(
                        image: DecorationImage(
                          image : AssetImage("images/loading.png"),
                          fit:BoxFit.fill,
                        )
                    ),
                  ),
                );
              }
            return LoginScreen();
          }
      )
    );
  }
}


