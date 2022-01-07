import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:bdf/datamodels/reqprogressdetails.dart';
import 'package:bdf/globalvariable.dart';
import 'package:bdf/widgets/NotificationDialog.dart';
import 'package:bdf/widgets/ProgressDialog.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class PushNotificationService{
  final FirebaseMessaging fcm = FirebaseMessaging();
  Future initialize(context) async {
    if(Platform.isIOS){
      fcm.requestNotificationPermissions(IosNotificationSettings());
    }
    fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        fetchRequestInfo(getRequestID(message), context);
      },
      onLaunch: (Map<String, dynamic> message) async {
        fetchRequestInfo(getRequestID(message), context);
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume $message");
        fetchRequestInfo(getRequestID(message), context);
      },
    );
  }
  Future<String> getToken() async{
    String token = await fcm.getToken();
    print('token: $token');

    DatabaseReference tokenRef = FirebaseDatabase.instance.reference().child('users/${currentFirebaseUser.uid}/token');
    tokenRef.set(token);
    fcm.subscribeToTopic('allusers');
    fcm.subscribeToTopic('alldonors');
  }

  String getRequestID(Map<String, dynamic> message){
    String requestID = '';
    if(Platform.isAndroid){
      requestID = message['data']['request_id'];
    }
    else{
      requestID = message['request_id'];
      print('request_id: $requestID');
    }

    return requestID;
  }

  void fetchRequestInfo(String requestID, context){
    //show please wait dialog
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => ProgressDialog(status: 'Fetching details',),
    );

    DatabaseReference requestRef = FirebaseDatabase.instance.reference().child('accepterRequest/$requestID');
    requestRef.once().then((DataSnapshot snapshot)
    {

      Navigator.pop(context);

      if(snapshot.value != null){
        assetsAudioPlayer.open(
          Audio('sounds/alert.mp3'),
        );
        assetsAudioPlayer.play();

        double pickupLat = double.parse(snapshot.value['location']['latitude'].toString());
        double pickupLng = double.parse(snapshot.value['location']['longitude'].toString());
        String pickupAddress = snapshot.value['aceptr_address'].toString();
        String accepterName = snapshot.value['aceptr_name'];
        String accepterPhone = snapshot.value['aceptr_phone'];
        String  requestedBloodGroup = snapshot.value['Requested_Group'];

        ReqProgressDetails reqProgresDetails = ReqProgressDetails();

      reqProgresDetails.requestID = requestID;
      reqProgresDetails.pickupAddress = pickupAddress;

      reqProgresDetails.pickup = LatLng(pickupLat, pickupLng);

      reqProgresDetails.accepterName = accepterName;
      reqProgresDetails.accepterPhone = accepterPhone;
      reqProgresDetails.requestBloodGroup = requestedBloodGroup;

        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (BuildContext context) => NotificationDialog(reqProgressDetails: reqProgresDetails,),
        );

      }
    }
    );
  }
}