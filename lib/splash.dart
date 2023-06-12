

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'home_page.dart';

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {

  String name = "Munir M. Atef";

  Widget _animatedSwitcherChild = const CircleAvatar(
    radius: 120,
    backgroundImage: AssetImage("Assets/MyCIB.png"),
  );


  @override
  void initState() {
    // TODO: implement initState
    Future.delayed(const Duration(seconds: 3), () {
      _animatedSwitcherChild = const SizedBox(
          child: CircleAvatar(
            radius: 120,
            backgroundImage: AssetImage("Assets/me_again.png"),
          )
      );
      setState(() {});
    });

    Future.delayed(const Duration(seconds: 5), () {
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const MainPage()));
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.yellow,
                borderRadius: BorderRadius.circular(120),
                boxShadow: const [
                  BoxShadow(
                      color: Colors.grey,
                      blurRadius: 20,
                      offset: Offset(0,15)
                  )
                ],
              ),
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 2000),
                child: _animatedSwitcherChild,
                // transitionBuilder: (Widget child, Animation<double> animation) =>
                //     RotationTransition(turns: animation, child: child),
              ),
            ),

            const SizedBox(height: 50),

            Text("Developed by", style: GoogleFonts.bebasNeue(fontSize: 35, fontWeight: FontWeight.w500, color: Colors.green[900])),

            Container(
              height: 50,
              width: 250,

              decoration: BoxDecoration(
                  color: Colors.yellow[400],
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: const [
                    BoxShadow(
                        color: Colors.grey,
                        blurRadius: 20,
                        offset: Offset(0, 10)
                    )
                  ]
              ),

              child: Center(
                child: AnimatedTextKit(
                  animatedTexts: [
                    TypewriterAnimatedText(
                      'Munir M. Atef',
                      textStyle: GoogleFonts.tangerine(
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          color: Colors.red
                      ),
                      speed: const Duration(milliseconds: 200),
                    ),
                  ],

                  totalRepeatCount: 1,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
