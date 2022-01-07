import 'dart:convert';
import 'dart:math';
import 'package:bdf/datamodels/address.dart';
import 'package:bdf/datamodels/directiondetails.dart';
import 'package:bdf/dataprovider/appdata.dart';
import 'package:bdf/helpers/requesthelper.dart';
import 'package:bdf/datamodels/user.dart';
import 'package:bdf/widgets/ProgressDialog.dart';
import 'package:connectivity/connectivity.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:bdf/globalvariable.dart';
import 'package:http/http.dart' as http;

import '../brand_colors.dart';

class HelperMethods {

  static Future<String> findCordinateAddress(Position position, context) async {
    String placeAddress = '';
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult != ConnectivityResult.mobile &&
        connectivityResult != ConnectivityResult.wifi) {
      return placeAddress;
    }
    Uri url = Uri.parse('https://maps.googleapis.com/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey');


    var response = await RequestHelper.getRequest(url);
    if (response != 'failed') {
      placeAddress = response['results'][0]['formatted_address'];
      Address pickupAddress = new Address();
      pickupAddress.longitude = position.longitude;
      pickupAddress.latitude = position.latitude;
      pickupAddress.placeName = placeAddress;
      Provider.of<AppData>(context, listen: false).updatePickupAddress(pickupAddress);
    }
    return placeAddress;
  }


  static Future<void> getCurrentUserInfo() async{
    //globely created currentFirebaseUser type of User( firebaseuser) in globelVariable
    currentFirebaseUser = await FirebaseAuth.instance.currentUser;
    String userid = currentFirebaseUser.uid;

    DatabaseReference userRef = FirebaseDatabase.instance.reference().child('users/$userid');
    userRef.once().then((DataSnapshot snapshot){
      print('my name is ');
      if(snapshot.value != null){
        currentUserInfo = UserApp.fromSnapshot(snapshot);
        print('my name is ${currentUserInfo.fullName}');
        print('my phone number is ${currentUserInfo.phone}');
      }

    });
  }

  static Future<DirectionDetails> getDirectionDetails(LatLng startPosition, LatLng endPosition) async {

    Uri url = Uri.parse('https://maps.googleapis.com/maps/api/directions/json?origin=${startPosition.latitude},'
        '${startPosition.longitude}&destination=${endPosition.latitude},${endPosition.longitude}&mode=driving&key=$mapKey');
    var response = await RequestHelper.getRequest(url);

    if(response == 'failed'){
      return null;
    }

    DirectionDetails directionDetails = DirectionDetails();

    directionDetails.durationText = response['routes'][0]['legs'][0]['duration']['text'];
    directionDetails.durationValue = response['routes'][0]['legs'][0]['duration']['value'];

    directionDetails.distanceText = response['routes'][0]['legs'][0]['distance']['text'];
    directionDetails.distanceValue = response['routes'][0]['legs'][0]['distance']['value'];

    directionDetails.encodedPoints = response['routes'][0]['overview_polyline']['points'];

    return directionDetails;
  }

  static double generateRandomNumber(int max){

    var randomGenerator = Random();
    int randInt = randomGenerator.nextInt(max);

    return randInt.toDouble();
  }

  static void disableHomTabLocationUpdates(){
    homeTabPositionStream.pause();
    Geofire.removeLocation(currentFirebaseUser.uid);
  }

  static void enableHomTabLocationUpdates(){
    homeTabPositionStream.resume();
    Geofire.setLocation(currentFirebaseUser.uid, currentPosition.latitude, currentPosition.longitude);
  }

  static void showProgressDialog(context){

    //show please wait dialog
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => ProgressDialog(status: 'Please wait',),
    );
  }

  static sendNotification(String token, context, String request_id) async {

    var destination = Provider.of<AppData>(context, listen: false).pickupAddress;

    Map<String, String> headerMap = {
      'Content-Type': 'application/json',
      'Authorization': serverKey,
    };

    Map notificationMap = {
      'title': 'NEW BLOOD REQUEST',
      'body': 'Destination, ${destination.placeName}'
    };

    Map dataMap = {
      'click_action': 'FLUTTER_NOTIFICATION_CLICK',
      'id': '1',
      'status': 'done',
      'request_id' : request_id,
    };

    Map bodyMap = {
      'notification': notificationMap,
      'data': dataMap,
      'priority': 'high',
      'to': token
    };

    var response = await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: headerMap,
        body: jsonEncode(bodyMap)
    );

    print('is this executed');
    print(response.body);

  }

  static void offlineDonor(){
    if(bloodRequestRef != null){
      Geofire.removeLocation(id);
      bloodRequestRef.onDisconnect();
      bloodRequestRef.remove();
      bloodRequestRef = null;
      availabilityTitle = 'GO ONLINE';
      availabilityColor = BrandColors.colorOrange;
      isAvailable = false;
    }
  }

  static void cancelBloodRequest(){
    if(donorRef != null){
      donorRef.remove();
    }

    appState = 'NORMAL';
  }

}

