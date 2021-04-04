import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uber_clone_task/utils/colors.dart';

class CongratulationBottom extends StatefulWidget {
  String message;

  CongratulationBottom({@required this.message});

  @override
  _CongratulationBottomState createState() => _CongratulationBottomState();
}

class _CongratulationBottomState extends State<CongratulationBottom> {
  int count = 0;
  @override
  void initState() {
    super.initState();
    Timer(Duration(seconds: 3), () {
      Get.back();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        //alignment: AlignmentDirectional.bottomEnd,
        children: [
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: Get.height * 0.03),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(26),
                      topRight: Radius.circular(26))),
              child: Column(
                children: [
                  Container(
                    margin: EdgeInsets.symmetric(vertical: Get.height * .01),
                    child: Text(
                      "Congratulations",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: themeColor,
                          fontFamily: 'pop_med',
                          fontSize: Get.height * .024),
                    ),
                  ),
                  Text(
                    widget.message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Color(0xffB4B7BA),
                        fontFamily: 'pop_regular',
                        fontSize: Get.height * .021),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
