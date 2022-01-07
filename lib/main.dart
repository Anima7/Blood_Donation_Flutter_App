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
      appId: '1:297855924061:ios:c6de2b69b03a5be8',
      apiKey: 'AIzaSyD_shO5mfO9lhy2TVWhfo1VUmARKlG4suk',
      projectId: 'flutter-firebase-plugins',
      messagingSenderId: '297855924061',
      databaseURL: 'https://flutterfire-cd2f7.firebaseio.com',
    )
        : FirebaseOptions(
      appId: '1:267094437643:android:7f2695c1918b17caa4fc0e',
      apiKey: 'AIzaSyCkpnKQIETL6dgxy1C1lUrlGz3mt7tZlZk',
      messagingSenderId: '267094437643',
      projectId: 'bdonor-80a65',
      databaseURL: 'https://bdonor-80a65-default-rtdb.firebaseio.com',
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
