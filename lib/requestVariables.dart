import 'dart:async';

import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

int donorRequestTimeout = 30;
String status = '';
String donorBloodGroup ='';
String donorFullName ='';
String rating = '';
String donorPhoneNumber ='';
LatLng donorLocationglobel = null;
StreamSubscription<Position> reqPositionStream;
String requestStatusDisplay = 'Donor is Arriving';