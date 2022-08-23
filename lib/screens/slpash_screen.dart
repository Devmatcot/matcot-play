import 'package:flutter/material.dart';
import 'package:music_app/constants.dart';
import 'package:avatar_glow/avatar_glow.dart';
import 'package:music_app/screens/library.dart';

import 'keep_library.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  void _navigateToHome() async {
    await Future.delayed(const Duration(seconds: 4), () {});
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => Library()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: cwhite,
      body: Center(
        child: AvatarGlow(
          endRadius: 170,
          glowColor: Color.fromARGB(255, 82, 106, 236),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                // height: 120,
                // width: 120,
                // color: Colors.white,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: Image.asset('assets/images/logo.png',
                    fit: BoxFit.cover, height: 100, width: 100,),
              ),
              // SizedBox(height: 10,),
              const Text(
                'Matcot Play',
                style: TextStyle(
                    color: cblue, fontSize: 20, fontWeight: FontWeight.w400),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
