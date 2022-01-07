
import 'package:google_maps_flutter/google_maps_flutter.dart';

class ReqProgressDetails {
  String pickupAddress;
  LatLng pickup;
  String requestID;
  String accepterName;
  String accepterPhone;
  String requestBloodGroup;


  ReqProgressDetails({
    this.pickupAddress,
    this.requestID,
    this.pickup,
    this.accepterName,
    this.accepterPhone,
    this.requestBloodGroup,
  });

}