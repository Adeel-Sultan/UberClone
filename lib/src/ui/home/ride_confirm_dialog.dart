import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:uber_clone_task/utils/colors.dart';
import 'package:uber_clone_task/utils/dialog.dart';

class RideConfirmDialog extends StatefulWidget {
  @override
  _RideConfirmDialogState createState() => _RideConfirmDialogState();
}

class _RideConfirmDialogState extends State<RideConfirmDialog> {
  @override
  Widget build(BuildContext context) {
    return rideConfirmDialogShow();
  }

  Widget rideConfirmDialogShow() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(30),
          topLeft: Radius.circular(30),
        ),
      ),
      padding: EdgeInsets.only(top: Get.height * .03),
      height: Get.height * .3,
      child: Column(
        children: [
          SizedBox(height: Get.height * .03),
          Text(
            'Your total fare is \n \$60',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: Get.height * .021,
              color: themeColor,
            ),
          ),
          SizedBox(height: Get.height * .02),
          Text(
            'Are you sure you want to book \n this ride?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: Get.height * .021,
              color: Colors.black,
            ),
          ),
          Row(
            children: [
              Expanded(
                child: button(0, 'NO'),
              ),
              Expanded(
                child: button(1, 'YES'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget button(int index, String title) {
    return GestureDetector(
      onTap: () {
        setState(() {
          if (index == 1) {
            Get.back();
            Get.dialog(
              BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                child: CongratulationBottom(
                  message: "You have successfully booked a ride",
                ),
              ),
            );
          } else {
            Get.back();
          }
        });
      },
      child: Container(
        height: Get.height * .07,
        margin: EdgeInsets.only(
          top: Get.height * .04,
          bottom: Get.height * .01,
          left: index == 0 ? Get.width * .04 : Get.width * .02,
          right: index == 1 ? Get.width * .04 : Get.width * .02,
        ),
        decoration: BoxDecoration(
            border: Border.all(
                width: 1, color: index == 0 ? Color(0xffCACCCD) : themeColor),
            color: index == 0 ? Color(0xffEFF1F3) : themeColor,
            borderRadius: BorderRadius.circular(5)),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: index == 0 ? Color(0xff252029) : Colors.white,
              fontSize: Get.height * .018,
            ),
          ),
        ),
      ),
    );
  }
}
