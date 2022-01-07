import 'dart:async';
import 'dart:ui';
import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:bdf/datamodels/user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'brand_colors.dart';

String mapKey = 'AIzaSyCkpnKQIETL6dgxy1C1lUrlGz3mt7tZlZk';
User currentFirebaseUser;
UserApp currentUserInfo;
String serverKey = 'key=AAAAPjARrws:APA91bGv3H5evlubv5EpCfutijebUedw8O5Q7l0E8xWP_RJhstMF5R6mdZxnsRmr7s-FFpxZ_0IPZWF5I051cNqjr8UGa0yFYbfAe4OI2iSME0EogGhqJTDHHcHvyGfPbsCS2FgNwhRQ';
CameraPosition kGooglePlex = CameraPosition(
  target: LatLng(37.42796133580664, -122.085749655962),
  zoom: 14.4746,);
bool isEnabled = false;
StreamSubscription<Position> homeTabPositionStream;
StreamSubscription<Position> requestPositionStream;
final assetsAudioPlayer = AssetsAudioPlayer();
Position currentPosition;
DatabaseReference donorRef;
DatabaseReference acceptrRef;
DatabaseReference bloodRequestRef;
String appState = 'NORMAL';
String id;
String confirm = 'allowed';
String availabilityTitle = 'GO ONLINE';
Color availabilityColor = BrandColors.colorOrange;
bool isAvailable = false;