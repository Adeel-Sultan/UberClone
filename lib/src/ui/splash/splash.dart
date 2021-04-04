import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uber_clone_task/src/ui/home/home_screen.dart';
import 'package:uber_clone_task/utils/images.dart';

class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  void initState() {
    Timer(Duration(seconds: 3), () {
      // rememberMeChecked == true ? loginSharedPrefs() :
      Get.offAll(HomeScreen());
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        width: Get.width,
        height: Get.height,
        decoration: BoxDecoration(
            image: DecorationImage(
          image: AssetImage(splash),
          fit: BoxFit.cover,
        )),
      ),
    );
  }
}
