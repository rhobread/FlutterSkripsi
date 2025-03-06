import 'package:flutter/material.dart';
import 'package:flutter_application_1/view/HomeView/home_view.dart';
import 'package:flutter_application_1/view/InitialView/pickequipment_view.dart';
import 'package:flutter_application_1/view/InitialView/signup_view.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false, home: const SignUpPage());
  }

  //for test

  // @override
  // Widget build(BuildContext context) {
  //   return MaterialApp(
  //       debugShowCheckedModeBanner: false,
  //       home: const HomePage(
  //         userId: '8',
  //         // isGymSelected: false,
  //       ));
  // }
}
