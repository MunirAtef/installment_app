import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tarek_cib/splash.dart';
import 'add_client.dart';
import 'add_transaction.dart';
import 'client_page.dart';
import 'general_report.dart';
import 'home_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown
  ]);

  runApp(
    MaterialApp(
      title: "My CIB",
      debugShowCheckedModeBanner: false,
      initialRoute: "/splash",
      routes: {
        "/splash": (context) => const Splash(),
        "/mainPage": (context) => const MainPage(),
        "/generalReport": (context) => GeneralReport(0),
        "/addClient": (context) => const NewClient(),
        "/clientPage": (context) => const ClientPage({}),
        "/addTransaction": (context) => const AddTransaction({}, 0),
      },
    ),
  );
}
