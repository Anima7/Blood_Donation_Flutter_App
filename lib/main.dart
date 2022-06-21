import 'package:bdf/dataprovider/appdata.dart';
import 'package:bdf/globalvariable.dart';
import 'package:bdf/screens/donormainpage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import './screens/registrationpage.dart';
import './screens/loginpage.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'dart:io';


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final FirebaseApp app = await Firebase.initializeApp(
    name: 'db2',
    options: Platform.isIOS || Platform.isMacOS
        ? FirebaseOptions(
      appId: 'your ios appID',
      apiKey: 'your api key',
      projectId: 'your ios project id',
      messagingSenderId: 'your ios messag sender id',
      databaseURL: 'your ios database URL',
    )
        : FirebaseOptions(
      appId: 'your android appID',
      apiKey: 'your api key',
      messagingSenderId: 'your android messagingSenderID',
      projectId: 'your android projectID',
      databaseURL: 'Your android database URL',
    ),
  );
   currentFirebaseUser = await FirebaseAuth.instance.currentUser;
  runApp(MyApp());
}
class MyApp extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppData(),
      child: MaterialApp(
        theme: ThemeData(
          fontFamily: 'Brand-Regular',
          primarySwatch: Colors.blue,
        ),
        initialRoute:(currentFirebaseUser == null)? LoginPage.id : DonorMainPage.id,
        routes: {
          RegistrationPage.id: (context) => RegistrationPage(),
          LoginPage.id: (context) => LoginPage(),
          DonorMainPage.id: (context) => DonorMainPage(),
        },
      ),
    );
  }
}
