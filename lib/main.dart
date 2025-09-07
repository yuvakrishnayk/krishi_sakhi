import 'package:flutter/material.dart';
import 'package:krishi_sakhi/screens/chatbot_screen.dart';





void main(){
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      
      theme: ThemeData(
         brightness: Brightness.light
         
         
      ),
        home: ChatbotScreen(),
        debugShowCheckedModeBanner: false,

    );
  }
}