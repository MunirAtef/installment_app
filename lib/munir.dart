import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class Munir extends StatelessWidget {
  const Munir({Key? key}) : super(key: key);


  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: Colors.black,

      appBar: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: 90,
        backgroundColor: Colors.black,
        // shape: const RoundedRectangleBorder(
        //   borderRadius: BorderRadius.vertical(
        //     bottom: Radius.circular(30),
        //   ),
        // ),
        title: Row(
          children: [
            InkWell(
              borderRadius: BorderRadius.circular(20),
              child: SizedBox(
                width: 40,
                height: 40,
                child: Row(
                  children: const [
                    SizedBox(width: 12),
                    Icon(Icons.arrow_back_ios, color: Colors.purple),
                  ],
                ),
              ),
              onTap: () {Navigator.of(context).pop();},
            ),

            Text(
              "Munir",
              style: GoogleFonts.bebasNeue(
                fontSize: 30,
                color: Colors.red,
              ),
            ),

            Text(
              " Mohamed ",
              style: GoogleFonts.bebasNeue(
                fontSize: 30,
                color: Colors.green,
              ),
            ),

            Text(
              "Atef",
              style: GoogleFonts.bebasNeue(
                fontSize: 30,
                color: Colors.blue,
              ),
            ),
          ],
        ),
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            /// image
            ClipRRect(
              child: Image.asset("Assets/Munir.png"),
              borderRadius: const BorderRadius.only(
                bottomRight: Radius.circular(60),
                bottomLeft: Radius.circular(60),
              ),
            ),

            const SizedBox(height: 30),

            /// munir m. atef
            Text(
              "Munir M. Atef",
              textAlign: TextAlign.center,
              style: GoogleFonts.tangerine(
                color: Colors.purple,
                fontSize: 50,
                fontWeight: FontWeight.w900,
                decoration: TextDecoration.underline,
              ),
            ),

            const SizedBox(height: 10),

            /// mobile developer
            Text(
              "Mobile Developer",
              style: GoogleFonts.bebasNeue(
                color: Colors.red[500],
                fontSize: 30,
                fontWeight: FontWeight.w500,
              ),
            ),

            /// contacts
            Container(
              margin: const EdgeInsets.only(top: 30),
              width: size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    children: [
                      /// whatsapp
                      InkWell(
                        child: ClipRRect(
                          child: Image.asset("Assets/whatsapp.png", width: 40),
                          borderRadius: BorderRadius.circular(8),
                        ),

                        onTap: () async {
                          final Uri _url = Uri.parse("whatsapp://send?phone=+201146721499");
                          if (await canLaunchUrl(_url)) {
                            await launchUrl(_url);
                          } else {
                            throw "could not launch URL";
                          }
                        },
                      ),

                      SizedBox(width: (size.width - 160) / 6),

                      /// facebook
                      InkWell(
                        child: ClipRRect(
                          child: Image.asset("Assets/facebook.png", width: 40),
                          borderRadius: BorderRadius.circular(8),
                        ),

                        onTap: () async {
                          final Uri _url = Uri.parse("https://www.facebook.com/munir.atef.52");
                          if (await canLaunchUrl(_url)) {
                            await launchUrl(_url);
                          } else {
                            throw "could not launch URL";
                          }
                        },
                      ),

                      SizedBox(width: (size.width - 160) / 6),

                      /// linkedin
                      InkWell(
                        child: ClipRRect(
                          child: Image.asset("Assets/linkedin.png", width: 40),
                          borderRadius: BorderRadius.circular(8),
                        ),

                        onTap: () async {
                          final Uri _url = Uri.parse("https://www.linkedin.com/in/munir-m-atef-573255215");
                          if (await canLaunchUrl(_url)) {
                            await launchUrl(_url);
                          } else {
                            throw "could not launch URL";
                          }
                        },
                      ),

                      SizedBox(width: (size.width - 160) / 6),

                      /// twitter
                      InkWell(
                        child: ClipRRect(
                          child: Image.asset("Assets/twitter.png", width: 40),
                          borderRadius: BorderRadius.circular(8),
                        ),

                        onTap: () async {
                          final Uri _url = Uri.parse("https://twitter.com/MunirAtef?t=zQajIL7jatoUF7rtftFDjw&s=08");
                          if (await canLaunchUrl(_url)) {
                            await launchUrl(_url);
                          } else {
                            throw "could not launch URL";
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
