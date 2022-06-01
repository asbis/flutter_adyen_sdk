import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
// import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import 'firstpage.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // get_cont();
    Timer(
      const Duration(seconds: 5),
      () async {
        Get.to(allcards());
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final double widthSize = MediaQuery.of(context).size.width;
    final double heightSize = MediaQuery.of(context).size.height;

    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Stack(
            children: [
              Container(
                height: heightSize,
                width: widthSize,
              ),
              Center(
                child: Text("Adyen Test APp"),
              ),
              SizedBox(
                height: 100,
              ),
            ],
          ),
        ));
  }
}
