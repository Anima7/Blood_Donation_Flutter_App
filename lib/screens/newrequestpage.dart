import 'dart:async';
import 'dart:io';
import 'package:bdf/datamodels/reqprogressdetails.dart';
import 'package:bdf/dataprovider/appdata.dart';
import 'package:bdf/globalvariable.dart';
import 'package:bdf/helpers/helpermethods.dart';
import 'package:bdf/helpers/mapkithelper.dart';
import 'package:bdf/widgets/ProgressDialog.dart';
import 'package:bdf/widgets/donorbutton.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import '../brand_colors.dart';
import '../globalvariable.dart';
import 'donormainpage.dart';

class NewRequestPage extends StatefulWidget {

  final ReqProgressDetails reqProgressDetails;
  NewRequestPage({this.reqProgressDetails});

  @override
  _NewRequestPageState createState() => _NewRequestPageState();
}

class _NewRequestPageState extends State<NewRequestPage> {

  GoogleMapController requestMapController;
  Completer<GoogleMapController> _controller = Completer();
  double mapPaddingBottom = 0;

  Set<Marker> _markers = Set<Marker>();
  Set<Circle> _circles = Set<Circle>();
  Set<Polyline> _polyLines = Set<Polyline>();

  List<LatLng> polylineCoordinates = [];
  PolylinePoints polylinePoints = PolylinePoints();
  BitmapDescriptor movingMarkerIcon;
  Position myPosition;
  String status = 'accepted';
  String durationString = '';
  bool isRequestingDirection = false;
  String buttonTitle = 'ARRIVED';
  Color buttonColor = BrandColors.colorGreen;

  void createMarker(){
    if(movingMarkerIcon == null){

      ImageConfiguration imageConfiguration = createLocalImageConfiguration(context, size: Size(2,2));
      BitmapDescriptor.fromAssetImage(
          imageConfiguration, (Platform.isIOS)
          ? 'images/display.png'
          : 'images/display.png'
      ).then((icon){
        movingMarkerIcon = icon;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    acceptRequest();
  }

  @override
  Widget build(BuildContext context) {

    createMarker();

    return Scaffold(
      body: Stack(
        children: <Widget>[
          GoogleMap(
            padding: EdgeInsets.only(bottom: mapPaddingBottom),
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            compassEnabled: true,
            mapToolbarEnabled: true,
            trafficEnabled: true,
            mapType: MapType.normal,
            circles: _circles,
            markers: _markers,
            polylines: _polyLines,
            initialCameraPosition: kGooglePlex,
            onMapCreated: (GoogleMapController controller) async {
              _controller.complete(controller);
              requestMapController = controller;

              setState(() {
                mapPaddingBottom = (Platform.isIOS) ? 255 : 260;
              });

              var currentLatLng = LatLng(currentPosition.latitude, currentPosition.longitude);
              var pickupLatLng = widget.reqProgressDetails.pickup;
              await getDirection(currentLatLng, pickupLatLng);
              getLocationUpdates();

            },
          ),


          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 15.0,
                    spreadRadius: 0.5,
                    offset: Offset(
                      0.7,
                      0.7,
                    ),
                  )
                ],
              ),
              height: Platform.isIOS ? 280 : 255,
              child: Padding(
                padding:  EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      durationString,
                      style: TextStyle(
                          fontSize: 14,
                          fontFamily: 'Brand-Bold',
                          color: BrandColors.colorAccentPurple
                      ),
                    ),

                    SizedBox(height: 5,),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        Text(widget.reqProgressDetails.accepterName, style: TextStyle(fontSize: 22, fontFamily: 'Brand-Bold'),),

                      ],
                    ),

                    SizedBox(height:  25,),

                    Row(
                      children: <Widget>[
                        Image.asset('images/pickicon.png', height: 16, width: 16,),
                        SizedBox(width: 18,),

                        Expanded(
                          child: Container(
                            //
                            child: Text(
                              widget.reqProgressDetails.pickupAddress,
                              style: TextStyle(fontSize: 18),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),

                      ],
                    ),

                    SizedBox(height: 15,),


                    Row(
                      children: <Widget>[

                        Icon(Icons.call),

                        SizedBox(width: 18,),

                        Expanded(
                          child: Container(
                            //
                            child: Text(
                              widget.reqProgressDetails.accepterPhone,
                              style: TextStyle(fontSize: 18),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),

                      ],
                    ),


                    SizedBox(height: 25,),

                    DonorButton(
                      title: buttonTitle,
                      color: buttonColor,
                      onPressed: () async {

                        if(status == 'accepted') {
                          status = 'arrived and end';
                          acceptrRef.child('status').set(('arrived and end'));
                          setState(() {
                            buttonTitle = 'END REQUEST';
                            buttonColor = Colors.red[900];
                          });
                        }
                        else if(status == 'arrived and end'){
                          endRequest();
                        }

                      },
                    )

                  ],
                ),
              ),
            ),
          )

        ],

      ),
    );
  }

  void acceptRequest(){

    String requestID = widget.reqProgressDetails.requestID;
    acceptrRef = FirebaseDatabase.instance.reference().child('accepterRequest/$requestID');
    var pickup = Provider.of<AppData>(context, listen: false).pickupAddress;

    acceptrRef.child('status').set('accepted');
    acceptrRef.child('donor_name').set(currentUserInfo.fullName);
    acceptrRef.child('donor_phone').set(currentUserInfo.phone);
    acceptrRef.child('donor_id').set(currentUserInfo.id);
    acceptrRef.child('donor_address').set(pickup.placeName);
    acceptrRef.child('donor_blood_group').set(currentUserInfo.bloodGroup);
    acceptrRef.child('donor_rating').set(currentUserInfo.rating);

    Map locationMap = {
      'latitude': currentPosition.latitude.toString(),
      'longitude': currentPosition.longitude.toString(),
    };

    acceptrRef.child('donor_location').set(locationMap);


  }

  void getLocationUpdates(){
    LatLng oldPosition = LatLng(0,0);
    requestPositionStream = Geolocator.getPositionStream(desiredAccuracy: LocationAccuracy.bestForNavigation).listen((Position position) {
      myPosition = position;
      currentPosition = position;
      LatLng pos = LatLng(position.latitude, position.longitude);
      var rotation = MapKitHelper.getMarkerRotation(oldPosition.latitude, oldPosition.longitude, pos.latitude, pos.longitude);
      print('my rotation = $rotation');
      Marker movingMaker = Marker(
          markerId: MarkerId('moving'),
          position: pos,
          icon: movingMarkerIcon,
          rotation: rotation,
          infoWindow: InfoWindow(title: 'Current Location')
      );
      setState(() {
        CameraPosition cp = new CameraPosition(target: pos, zoom: 17);
        requestMapController.animateCamera(CameraUpdate.newCameraPosition(cp));
        _markers.removeWhere((marker) => marker.markerId.value == 'moving');
        _markers.add(movingMaker);
      });
      oldPosition = pos;
      updateRequestDetails();
      Map locationMap = {
        'latitude': myPosition.latitude.toString(),
        'longitude': myPosition.longitude.toString(),
      };

      acceptrRef.child('donor_location').set(locationMap);

    });

  }

  void updateRequestDetails() async{
    if(!isRequestingDirection){
      isRequestingDirection = true;

      if(myPosition == null){
        return;
      }
      var positionLatLng = LatLng(myPosition.latitude, myPosition.longitude);
      LatLng destinationLatLng;
      if(status == 'accepted'){
        destinationLatLng = widget.reqProgressDetails.pickup;
      }
      var directionDetails = await HelperMethods.getDirectionDetails(positionLatLng, destinationLatLng);
      if(directionDetails != null){
        print(directionDetails.durationText);
        setState(() {
          durationString = directionDetails.durationText;
        });
      }
      isRequestingDirection = false;
    }
  }

  Future<void> getDirection(LatLng pickupLatLng, LatLng destinationLatLng) async {

    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (BuildContext context) => ProgressDialog(status: 'Please wait...',)
    );

    var thisDetails = await HelperMethods.getDirectionDetails(pickupLatLng, destinationLatLng);
    Navigator.pop(context);

    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> results = polylinePoints.decodePolyline(thisDetails.encodedPoints);

    polylineCoordinates.clear();
    if(results.isNotEmpty){
      // loop through all PointLatLng points and convert them
      // to a list of LatLng, required by the Polyline
      results.forEach((PointLatLng point) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      });
    }

    _polyLines.clear();

    setState(() {

      Polyline polyline = Polyline(
        polylineId: PolylineId('polyid'),
        color: Color.fromARGB(255, 95, 109, 237),
        points: polylineCoordinates,
        jointType: JointType.round,
        width: 4,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
      );

      _polyLines.add(polyline);

    });
    // make polyline to fit into the map
    LatLngBounds bounds;

    if(pickupLatLng.latitude > destinationLatLng.latitude && pickupLatLng.longitude > destinationLatLng.longitude){
      bounds = LatLngBounds(southwest: destinationLatLng, northeast: pickupLatLng);
    }
    else if(pickupLatLng.longitude > destinationLatLng.longitude){
      bounds = LatLngBounds(
          southwest: LatLng(pickupLatLng.latitude, destinationLatLng.longitude),
          northeast: LatLng(destinationLatLng.latitude, pickupLatLng.longitude),
      );
    }
    else if(pickupLatLng.latitude > destinationLatLng.latitude){
      bounds = LatLngBounds(
        southwest: LatLng(destinationLatLng.latitude, pickupLatLng.longitude),
        northeast: LatLng(pickupLatLng.latitude, destinationLatLng.longitude),
      );
    }
    else{
      bounds = LatLngBounds(southwest: pickupLatLng, northeast: destinationLatLng);
    }

    requestMapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 70));

    Marker pickupMarker = Marker(
      markerId: MarkerId('pickup'),
      position: pickupLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );

    Marker destinationMarker = Marker(
      markerId: MarkerId('destination'),
      position: destinationLatLng,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );

    setState(() {
      _markers.add(pickupMarker);
      _markers.add(destinationMarker);
    });

    Circle pickupCircle = Circle(
      circleId: CircleId('pickup'),
      strokeColor: Colors.green,
      strokeWidth: 3,
      radius: 12,
      center: pickupLatLng,
      fillColor: BrandColors.colorGreen,
    );

    Circle destinationCircle = Circle(
      circleId: CircleId('destination'),
      strokeColor: BrandColors.colorAccentPurple,
      strokeWidth: 3,
      radius: 12,
      center: destinationLatLng,
      fillColor: BrandColors.colorAccentPurple,
    );

    setState(() {
      _circles.add(pickupCircle);
      _circles.add(destinationCircle);
    });

  }

  void endRequest() async {

    HelperMethods.showProgressDialog(context);
    Navigator.pop(context);
    confirm = 'ended';
    acceptrRef.child('status').set('ended');
    requestPositionStream.cancel();
    HelperMethods.offlineDonor();
    Navigator.pushNamedAndRemoveUntil(context, DonorMainPage.id, (route) => false);


  }

}