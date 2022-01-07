import 'package:bdf/brand_colors.dart';
import 'package:bdf/globalvariable.dart';
import 'package:bdf/helpers/helpermethods.dart';
import 'package:bdf/screens/loginpage.dart';
import 'package:bdf/widgets/AvailabilityButton.dart';
import 'package:bdf/widgets/ProgressDialog.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ProfileTab extends StatefulWidget {
  static const String id = 'profile';
  @override
  _ProfileTabState createState() => _ProfileTabState();
}

class _ProfileTabState extends State<ProfileTab> {
  final GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
//  String name;
//  String email;
//  String bloodGroup;
//  String rating;
//  String phoneNo;


  void showSnackBar(String title) {
    final snackbar = SnackBar(
      content: Text(
        title,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 15,
        ),
      ),
    );
    scaffoldKey.currentState.showSnackBar(snackbar);
  }
  void signOut() async {
    //show please wait dialog
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => ProgressDialog(
        status: 'Signing you out',
      ),
    );
    HelperMethods.offlineDonor();
    HelperMethods.cancelBloodRequest();
    //try to catch error when user or not registered in database
    try {
      await FirebaseAuth.instance.signOut();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'requires-recent-login') {
        print('The user must reauthenticate before this operation can be executed.');
      }
    }
    Navigator.pushNamedAndRemoveUntil(context, LoginPage.id, (route) => false);
  }

//  setuserProfile() async{
//    SharedPreferences pref = await SharedPreferences.getInstance();
//    name =  pref.setString('user_key', currentUserInfo.fullName) as String;
//    email = pref.setString('user_key', currentUserInfo.email) as String;
//    bloodGroup = pref.setString('user_key', currentUserInfo.bloodGroup) as String;
//    rating = pref.setDouble('user_key', currentUserInfo.rating) as String;
//    phoneNo = pref.setString('user_key', currentUserInfo.phone) as String;
//  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: BrandColors.colorLightGrayFair,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 150,
                  ),
                  //
                  Text('Name: ${currentUserInfo.fullName}',
                    style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'Brand_Bold',
                  ),
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  Text('Ratings: ${currentUserInfo.rating}',
                    style: TextStyle(
                      fontSize: 20,
                      fontFamily: 'Brand_Bold',
                    ),
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  //
                  Text('Email: ${currentUserInfo.email}',style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'Brand_Bold',
                  ),
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  //
                  Text('Phone Number: ${currentUserInfo.phone}',style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'Brand_Bold',
                  ),
                  ),
                  SizedBox(
                    height: 25,
                  ),
                  //
                  Text('Blood Group: ${currentUserInfo.bloodGroup}',style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'Brand_Bold',
                  ),
                  ),
                  SizedBox(
                    height: 70,
                  ),
                  AvailabilityButton(
                      title: 'Sign Out',
                      color: BrandColors.colorPink,
                      onPressed: () async{
                        //check network connectivity
                        var connectivityResult = await Connectivity().checkConnectivity();
                        if (connectivityResult != ConnectivityResult.mobile && connectivityResult != ConnectivityResult.wifi) {
                          showSnackBar('No Internet Connection');
                          return;
                        }
                        signOut();
                      },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}