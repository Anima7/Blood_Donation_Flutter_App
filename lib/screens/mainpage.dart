import 'dart:ui';
import 'package:bdf/brand_colors.dart';
import 'package:bdf/datamodels/nearbydonor.dart';
import 'package:bdf/dataprovider/appdata.dart';
import 'package:bdf/globalvariable.dart';
import 'package:bdf/helpers/firehelper.dart';
import 'package:bdf/helpers/helpermethods.dart';
import 'package:bdf/widgets/DonorDetails.dart';
import 'package:bdf/widgets/NoDonorDialog.dart';
import 'package:bdf/widgets/ProgressDialog.dart';
import 'package:bdf/widgets/bloodGroup.dart';
import 'package:bdf/widgets/brandDivider.dart';
import 'package:bdf/widgets/donorbutton.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:outline_material_icons/outline_material_icons.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'dart:async';
import 'dart:io';
import 'package:bdf/helpers/mapkithelper.dart';

import 'package:provider/provider.dart';
import 'package:rating_dialog/rating_dialog.dart';
import 'package:url_launcher/url_launcher.dart';

import '../requestVariables.dart';

class MainPage extends StatefulWidget {
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> with TickerProviderStateMixin {
  GlobalKey<ScaffoldState> scaffoldKey = new GlobalKey<ScaffoldState>();
  double selectSheetHeight = (Platform.isIOS || Platform.isMacOS) ? 300 : 275;
  double requestingSheetHeight = 0; // (Platform.isAndroid) ? 195 : 220
  double ariveSheetHeight = 0; // (Platform.isAndroid) ? 275 : 300
  Completer<GoogleMapController> _controller = Completer();
  GoogleMapController mapController;
  double mapBottomPadding = 0;
  String blood;
  List<LatLng> polylineCoordinates = [];
  DonorDetail detail = new DonorDetail();

  Set<Polyline> _polylines = {};
  Set<Marker> _mMarkers = {};
  Set<Circle> _cCircles = {};
  int i = 0;

  double avg = 0;
  int a = 0,b = 0,c = 0,d = 0,e = 0;

  BitmapDescriptor nearbyIcon;
  String text = 'Select Blood Group';

  List<NearbyDonor> availableDonor;
  var donor;
  NearbyDonor phoneDonor = NearbyDonor();

  StreamSubscription<Event> requestSubscription;
  bool nearbyDonorsKeysLoaded = false;
  bool isRequestingLocationDetails = false;

  var bloodGroup;


  void showRequestingSheet() {
    setState(() {
      selectSheetHeight = 0;
      requestingSheetHeight = (Platform.isAndroid) ? 195 : 220;
      mapBottomPadding = (Platform.isAndroid) ? 200 : 190;
    });

    createDonorRequest();
  }

  Future<void> showAriveSheet() async {
    setState(() {
      requestingSheetHeight = 0;
      ariveSheetHeight = (Platform.isAndroid) ? 275 : 300;
      mapBottomPadding = (Platform.isAndroid) ? 280 : 270;
    });

  }

  void createMarker() {
    if (nearbyIcon == null) {
      ImageConfiguration imageConfiguration = createLocalImageConfiguration(context, size: Size(2, 2));
      BitmapDescriptor.fromAssetImage(
          imageConfiguration, (Platform.isAndroid)
          ? 'images/displayicon.png'
          : 'images/displayicon.png'
      ).then((icon) {
        nearbyIcon = icon;
      });
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    HelperMethods.getCurrentUserInfo();
    resetApp();
  }


  @override
  Widget build(BuildContext context) {
    createMarker();
    return Scaffold(
      key: scaffoldKey,
      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(
              bottom: mapBottomPadding,
            ),
            mapType: MapType.normal,
            myLocationButtonEnabled: true,
            initialCameraPosition: kGooglePlex,
            myLocationEnabled: true,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: true,
            polylines: _polylines,
            markers: _mMarkers,
            circles: _cCircles,
            onMapCreated: (GoogleMapController controller) {
              _controller.complete(controller);
              mapController = controller;
              setState(() {
                mapBottomPadding = (Platform.isAndroid) ? 280 : 270;
              });
              setupPositionLocator();
              //getCurrentPosition();
            },
          ),

          /// Request Details Sheet
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedSize(
              vsync: this,
              duration: new Duration(milliseconds: 150),
              curve: Curves.easeIn,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 15.0, // soften the shadow
                      spreadRadius: 0.5, //extend the shadow
                      offset: Offset(
                        0.7, // Move to right 10  horizontally
                        0.7, // Move to bottom 10 Vertically
                      ),
                    )
                  ],
                ),
                height: selectSheetHeight,
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 18),
                  child: Column(
                    children: <Widget>[
                      Container(
                        height: 150,
                        width: double.infinity,
                        color: BrandColors.colorAccent1,
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            child: Column(
                              children: [
                                GestureDetector(
                                  onDoubleTap: () {
                                    setState(() {
                                      isEnabled = true;
                                      text = 'A+';
                                    });
                                  },
                                  child: BloodGroup(
                                    title: 'A+',
                                    imageUrl: 'images/A-Positive.png',
                                  ),
                                ),
                                BrandDivider(),
                                GestureDetector(
                                  onDoubleTap: () {
                                    setState(() {
                                      isEnabled = true;
                                      text = 'A-';
                                    });
                                  },
                                  child: BloodGroup(
                                      title: 'A-',
                                      imageUrl: 'images/A-Negative.png'),
                                ),
                                BrandDivider(),
                                GestureDetector(
                                  onDoubleTap: () {
                                    setState(() {
                                      isEnabled = true;
                                      text = 'B+';
                                    });
                                  },
                                  child: BloodGroup(
                                      title: 'B+',
                                      imageUrl: 'images/B-Positive.png'),
                                ),
                                BrandDivider(),
                                GestureDetector(
                                  onDoubleTap: () {
                                    setState(() {
                                      isEnabled = true;
                                      text = 'B-';
                                    });
                                  },
                                  child: BloodGroup(
                                      title: 'B-',
                                      imageUrl: 'images/B-Negative.png'),
                                ),
                                BrandDivider(),
                                GestureDetector(
                                  onDoubleTap: () {
                                    setState(() {
                                      isEnabled = true;
                                      text = 'AB+';
                                    });
                                  },
                                  child: BloodGroup(
                                      title: 'AB+',
                                      imageUrl: 'images/AB-Positive.png'),
                                ),
                                BrandDivider(),
                                GestureDetector(
                                  onDoubleTap: () {
                                    setState(() {
                                      isEnabled = true;
                                      text = 'AB-';
                                    });
                                  },
                                  child: BloodGroup(
                                      title: 'AB-',
                                      imageUrl: 'images/AB-Negative.png'),
                                ),
                                BrandDivider(),
                                GestureDetector(
                                  onDoubleTap: () {
                                    setState(() {
                                      isEnabled = true;
                                      text = 'O+';
                                    });
                                  },
                                  child: BloodGroup(
                                      title: 'O+',
                                      imageUrl: 'images/O-Positive.png'),
                                ),
                                BrandDivider(),
                                GestureDetector(
                                  onDoubleTap: () {
                                    setState(() {
                                      isEnabled = true;
                                      text = 'O-';
                                    });
                                  },
                                  child: BloodGroup(
                                      title: 'O-',
                                      imageUrl: 'images/O-Negative.png'),
                                ),
                                BrandDivider(),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 22,
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: DonorButton(
                          title: 'REQUEST DONOR',
                          color: BrandColors.colorGreen,
                          onPressed: (isEnabled == true)
                              ? () {
                            setState(() {
                              appState = 'REQUESTING';
                            });
                            showRequestingSheet();
                            HelperMethods.offlineDonor();
                           availableDonor = FireHelper.nearbyDonorList;
                           findDonor();
                          } : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          /// Requesting Sheet
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: AnimatedSize(
              vsync: this,
              duration: new Duration(milliseconds: 150),
              curve: Curves.easeIn,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 15.0, // soften the shadow
                      spreadRadius: 0.5, //extend the shadow
                      offset: Offset(
                        0.7, // Move to right 10  horizontally
                        0.7, // Move to bottom 10 Vertically
                      ),
                    )
                  ],
                ),
                height: requestingSheetHeight,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                        width: double.infinity,
                        child: TextLiquidFill(
                          text: 'Requesting a Donor...',
                          waveColor: BrandColors.colorTextSemiLight,
                          boxBackgroundColor: Colors.white,
                          textStyle: TextStyle(
                              color: BrandColors.colorText,
                              fontSize: 22.0,
                              fontFamily: 'Brand-Bold'),
                          boxHeight: 40.0,
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      GestureDetector(
                        onTap: () {
                          cancelRequest();
                          resetApp();
                          setState(() {
                            isEnabled = false;
                            text = '';
                            requestingSheetHeight = 0;
                            selectSheetHeight =
                            (Platform.isAndroid) ? 275 : 300;
                            mapBottomPadding = (Platform.isAndroid) ? 280 : 270;
                          });
                        },
                        child: Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                                width: 1.0,
                                color: BrandColors.colorLightGrayFair),
                          ),
                          child: Icon(
                            Icons.close,
                            size: 25,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Container(
                        width: double.infinity,
                        child: Text(
                          'Cancel Request',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

            /// Arrive Sheet
            Positioned(
            left: 0,
              right: 0,
              bottom: 0,
              child: AnimatedSize(
                vsync: this,
                duration: new Duration(milliseconds: 150),
                curve: Curves.easeIn,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        blurRadius: 15.0,
                        // soften the shadow
                         spreadRadius: 0.5,
                        //extend the shadow
                        offset: Offset(
                          0.7, // Move to right 10  horizontally
                           0.7, // Move to bottom 10 Vertically
                           ),
                      )
                    ],
                  ),
                  height: ariveSheetHeight,
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[

                        SizedBox(height: 5,),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [

                            Text(requestStatusDisplay,
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 18, fontFamily: 'Brand-Bold'),
                            ),
                          ],
                        ),
                        SizedBox(height: 20,),
                        BrandDivider(),
                        SizedBox(height: 20,),
                        Text(donorBloodGroup, style: TextStyle(color: BrandColors.colorTextLight),),
                        Row(
                          children: [
                            Text(donorFullName, style: TextStyle(fontSize: 20),),
                            SizedBox(width: 20,),
                            Text(rating, style: TextStyle(fontSize: 20, color: BrandColors.colorText),),
                            SizedBox(width: 5,),
                            Icon(Icons.star, size:20 ,color: Colors.amber,),
                          ],
                        ),
                        SizedBox(height: 20,),
                        BrandDivider(),
                        SizedBox(height: 20,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  height: 50,
                                  width: 50,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular((25))),
                                    border: Border.all(width: 1.0, color: BrandColors.colorTextLight),
                                  ),
                                  child: InkWell(
                                      child: Icon(Icons.call),
                                    onTap: (){
//                                        detail.title = 'Donor Phone Number';
//                                        detail.subTitle = donorPhoneNumber;
//                                        showDialog(
//                                            context: context,
//                                            barrierDismissible: false,
//                                            builder: (BuildContext context) => DonorPhone()
//                                        );
                                    customLaunch("tel:$donorPhoneNumber");
                                    },
                                  ),
                                ),
                                SizedBox(height: 10,),
                                Text('Call'),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  height: 50,
                                  width: 50,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.all(Radius.circular((25))),
                                    border: Border.all(width: 1.0, color: BrandColors.colorTextLight),
                                  ),
                                  child: InkWell(
                                    child: Icon(Icons.list),
                                  onTap: (){
                                      detail.title = donorFullName;
                                      detail.subTitle = donorPhoneNumber;
                                      showDialog(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (BuildContext context) => DonorDetail()
                                      );
                                  },
                                  ),
                                ),
                                SizedBox(height: 10,),
                                Text('Details'),
                              ],
                            ),
//                            Column(
//                              crossAxisAlignment: CrossAxisAlignment.center,
//                              children: [
//                                Container(
//                                  height: 50,
//                                  width: 50,
//                                  decoration: BoxDecoration(
//                                    borderRadius: BorderRadius.all(Radius.circular((25))),
//                                    border: Border.all(width: 1.0, color: BrandColors.colorTextLight),
//                                  ),
//                                  child: Icon(OMIcons.clear),
//                                ),
//                                SizedBox(height: 10,),
//                                Text('Cancel'),
//                              ],
//                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  //Locate the position of nearbyDonor call startGeofireListerner function
  void setupPositionLocator() async {
    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
    currentPosition = position;
    LatLng pos = LatLng(position.latitude, position.longitude);
    CameraPosition cp = new CameraPosition(target: pos, zoom: 14);
    mapController.animateCamera(CameraUpdate.newCameraPosition(cp));
    String address = await HelperMethods.findCordinateAddress(position, context);
    print(address);
    startGeofireListener();
  }

  void startGeofireListener(){
    Geofire.initialize('donorsAvailabile');
    //current latitude and longitude, find nearbyDonor around 20km
    //donorsAvailable isa table created on database when ever a donor go online
    //the nearbyDonor are search in donorsAvailable table
    //get only those donors position (donorsAvailable table) which are near to this particular User( accepter )
    Geofire.queryAtLocation(currentPosition.latitude, currentPosition.longitude, 20).listen((map) {
      print(map);
      blood = map['key'].toString();
      DatabaseReference ref = FirebaseDatabase.instance.reference().child('users/$blood');
      if (map != null) {
        var callBack = map['callBack'];
        switch (callBack) {
          case Geofire.onKeyEntered:

            print('retrived blood group is $blood');
            ref.once().then((DataSnapshot snapshot) {
              if(snapshot.value != null){
                NearbyDonor nearbyDonor = NearbyDonor();
                bloodGroup = snapshot.value['bloodGroup'];
                nearbyDonor.blood_group = snapshot.value['bloodGroup'];
                nearbyDonor.phone_number = snapshot.value['phone'];
                print('nearbyDonor.bloodGroup inside snapshot ${nearbyDonor.blood_group}');
                print('bloodGroup $bloodGroup');
                nearbyDonor.key = map['key'];
                nearbyDonor.latitude = map['latitude'];
                nearbyDonor.longitude = map['longitude'];
                FireHelper.nearbyDonorList.add(nearbyDonor);
                print('nearbyDonor.bloodGroup ${nearbyDonor.blood_group}');
              }
            });


            if (nearbyDonorsKeysLoaded) {
              updateDonorsOnMap();}
            break;
          case Geofire.onKeyExited:
            FireHelper.removeFromList(map['key']);
            updateDonorsOnMap();
            break;
          case Geofire.onKeyMoved:
          // Update your key's location
            NearbyDonor nearbyDonor = NearbyDonor();
            nearbyDonor.key = map['key'];
            nearbyDonor.latitude = map['latitude'];
            nearbyDonor.longitude = map['longitude'];
            FireHelper.updateNearbyLocation(nearbyDonor);
            updateDonorsOnMap();
            break;
          case Geofire.onGeoQueryReady:
            nearbyDonorsKeysLoaded = true;
            updateDonorsOnMap();
            break;
        }}
    });
  }

  void updateDonorsOnMap() {
    setState(() {
      _mMarkers.clear();
    });

    Set<Marker> tempMarkers = Set<Marker>();

    for (NearbyDonor donor in FireHelper.nearbyDonorList) {
      LatLng donorPosition = LatLng(donor.latitude, donor.longitude);
      Marker thisMarker = Marker(
        markerId: MarkerId('users${donor.key}'),
        position: donorPosition,
        icon: nearbyIcon,
        rotation: HelperMethods.generateRandomNumber(360),
      );

      tempMarkers.add(thisMarker);
    }

    setState(() {
      _mMarkers = tempMarkers;
    });
  }

  void createDonorRequest(){
    donorRef = FirebaseDatabase.instance.reference().child('accepterRequest').push();
    var pickup = Provider.of<AppData>(context, listen: false).pickupAddress;
    Map pickupMap = {
      'latitude': pickup.latitude.toString(),
      'longitude': pickup.longitude.toString(),
    };
    Map aceptrMap = {
      'created_at': DateTime.now().toString(),
      'aceptr_name': currentUserInfo.fullName,
      'aceptr_phone': currentUserInfo.phone,
      'aceptr_address': pickup.placeName,
      'location': pickupMap,
      'Requested_Group': text,
      'request_id': 'waiting',
    };
    donorRef.set(aceptrMap);

    requestSubscription = donorRef.onValue.listen((event) async {

      //check for null snapshot
      if(event.snapshot.value == null){
        return;
      }

      //get bloodGroup Details
      if(event.snapshot.value['donor_blood_group'] != null){
        setState(() {
          donorBloodGroup = event.snapshot.value['donor_blood_group'].toString();
        });
      }

      // get donor name
      if(event.snapshot.value['donor_name'] != null){
        setState(() {
          donorFullName = event.snapshot.value['donor_name'].toString();
        });
      }

      // get donor phone number
      if(event.snapshot.value['donor_phone'] != null){
        setState(() {
          donorPhoneNumber = event.snapshot.value['donor_phone'].toString();
        });
      }

      // get donor rating
      if(event.snapshot.value['donor_rating'] != null){
        setState(() {
          rating = event.snapshot.value['donor_rating'].toString();
        });
      }

      //get and use donor location updates
      if(event.snapshot.value['donor_location'] != null){

        double donorLat = double.parse(event.snapshot.value['donor_location']['latitude'].toString());
        double donorLng = double.parse(event.snapshot.value['donor_location']['longitude'].toString());
        LatLng donorLocation = LatLng(donorLat, donorLng);
        donorLocationglobel = donorLocation;

        if(status == 'accepted'){
          if(i == 0){
            await  getDirection(donorLocationglobel);
            i++;
          }

//         getLocationUpdates(donorLocationglobel);
           updateToPickup(donorLocation);

        }
        else if(status == 'arrived and end'){
          setState(() {
            requestStatusDisplay = 'Donor has arrived';
          });
        }

      }
      if(event.snapshot.value['status'] != null){
        status = event.snapshot.value['status'].toString();
      }

      if(status == 'accepted'){
        showAriveSheet();
        Geofire.stopListener();
        removeGeofireMarkers();
      }

      if(status == 'ended'){
        _showRatingAppDialog();
        donorRef.onDisconnect();
        donorRef = null;
        requestSubscription.cancel();
        requestSubscription = null;
        resetApp();
      }

    });

  }

  void getLocationUpdates(LatLng donorLocation){

    LatLng oldPosition = LatLng(0,0);
    reqPositionStream = Geolocator.getPositionStream(desiredAccuracy: LocationAccuracy.bestForNavigation).listen((Position position) {
      LatLng pos = LatLng(donorLocation.latitude, donorLocation.longitude);
      var rotation = MapKitHelper.getMarkerRotation(oldPosition.latitude, oldPosition.longitude, pos.latitude, pos.longitude);
      print('my rotation = $rotation');
      Marker movingMaker = Marker(
          markerId: MarkerId('moving'),
          position: pos,
          icon: nearbyIcon,
          rotation: rotation,
          infoWindow: InfoWindow(title: 'Current Location')
      );
      setState(() {
        CameraPosition cp = new CameraPosition(target: pos, zoom: 17);
        mapController.animateCamera(CameraUpdate.newCameraPosition(cp));
        _mMarkers.removeWhere((marker) => marker.markerId.value == 'moving');
        _mMarkers.add(movingMaker);
      });
      oldPosition = pos;
      updateToPickup(donorLocation);
      Map locationMap = {
        'latitude': donorLocation.latitude.toString(),
        'longitude': donorLocation.longitude.toString(),
      };

      donorRef.child('donor_location').set(locationMap);
    });
  }

  Future<void> getDirection(LatLng pickupLatLng) async {

    var pickup = Provider.of<AppData>(context, listen: false).pickupAddress;
    var destinationLatLng = LatLng(pickup.latitude, pickup.longitude);


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

    _polylines.clear();

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

      _polylines.add(polyline);

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

    mapController.animateCamera(CameraUpdate.newLatLngBounds(bounds, 60));

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
      _mMarkers.add(pickupMarker);
      _mMarkers.add(destinationMarker);
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
      _cCircles.add(pickupCircle);
      _cCircles.add(destinationCircle);
    });

  }

  void cancelRequest() {
    donorRef.remove();
    setState(() {
      appState = 'NORMAL';
    });
  }

  void removeGeofireMarkers(){
    setState(() {
      _mMarkers.removeWhere((m) => m.markerId.value.contains('users'));
    });
  }

  void updateToPickup(LatLng donorLocation) async {

    if(!isRequestingLocationDetails){

      isRequestingLocationDetails = true;

      var positionLatLng = LatLng(currentPosition.latitude, currentPosition.longitude);

      var thisDetails = await HelperMethods.getDirectionDetails(donorLocation, positionLatLng);

      if(thisDetails == null){
        return;
      }

      setState(() {
        requestStatusDisplay = 'Donor is Arriving - ${thisDetails.durationText}';
      });

      isRequestingLocationDetails = false;

    }


  }

  resetApp(){

    setState(() {

      polylineCoordinates.clear();
      _polylines.clear();
      _mMarkers.clear();
      _cCircles.clear();
      requestingSheetHeight = 0;

      ariveSheetHeight = 0;
      selectSheetHeight = (Platform.isAndroid) ? 275 : 300;
      mapBottomPadding = (Platform.isAndroid) ? 280 : 270;

      isEnabled = false;
      status = '';
      donorFullName = '';
      donorPhoneNumber = '';
      donorBloodGroup = '';
      donorLocationglobel = null;
      requestStatusDisplay = 'Donor is Arriving';

    });

    setupPositionLocator();

  }

  void noDonorFound(){
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) => NoDonorDialog()
    );
  }

  void findDonor() {
    if (availableDonor.length == 0) {
      cancelRequest();
      resetApp();
      noDonorFound();
      return;
    }

    int index = availableDonor.indexWhere((element) => element.blood_group == text);
    if(index < 0){
      cancelRequest();
      resetApp();
      noDonorFound();
      return;
    }
    donor = availableDonor[index];
    notifyDonor(donor);

    availableDonor.removeAt(index);

    print(donor.key);
  }

  void notifyDonor(NearbyDonor donor){


    DatabaseReference donorRequestRef = FirebaseDatabase.instance.reference().child('users/${donor.key}/newrequest');
    donorRequestRef.set(donorRef.key);

    // Get and notify donor using token
    DatabaseReference tokenRef = FirebaseDatabase.instance.reference().child('users/${donor.key}/token');

    tokenRef.once().then((DataSnapshot snapshot){

      if(snapshot.value != null){

        String token = snapshot.value.toString();
        customLaunch('sms:${donor.phone_number}');

        // send notification to selected donor
        HelperMethods.sendNotification(token, context, donorRef.key);
      }
      else{

        return;
      }
      const oneSecTick = Duration(seconds: 1);
      var timer = Timer.periodic(oneSecTick, (timer) {
        // stop timer when blood request is cancelled;
        if(appState != 'REQUESTING'){
          donorRequestRef.set('cancelled');
          donorRequestRef.onDisconnect();
          timer.cancel();
          cancelRequest();
          donorRequestTimeout = 30;
        }
        donorRequestTimeout --;
        // a value event listener for donor accepting blood request
        donorRequestRef.onValue.listen((event) {
          // confirms that donor has clicked accepted for the new Blood request
          if(event.snapshot.value.toString() == 'accepted'){
            donorRequestRef.onDisconnect();
            timer.cancel();
            donorRequestTimeout = 30;
          }
        });


        if(donorRequestTimeout == 0){

          //informs donor that ride has timed out
          donorRequestRef.set('timeout');
          donorRequestRef.onDisconnect();
          donorRequestTimeout = 30;
          timer.cancel();
     //     select the next closest donor
          findDonor();
        }
      });
    });
}

  void customLaunch(command) async{
    if(await canLaunch(command)){
      await launch(command);
    }else{
      throw 'could not launch $command';
    }
}

  void _showRatingAppDialog() {
    final _ratingDialog = RatingDialog(
      ratingColor: Colors.amber,
      title: 'Rate The Donor',
      message: 'Tap on stars to give rating also mention your thoughts. '
          ' Add your Review here if you want.',
      image: Icon(Icons.star, size: 100,color: Colors.amber,),
//    Image.asset("assets/images/devs.jpg",
//      height: 100,),
      submitButton: 'Submit',
      onCancelled: () => print('cancelled'),
      onSubmitted: (response) {
        print('rating: ${response.rating}, '
            'comment: ${response.comment}');
        if (response.rating == 1.0) {
          a++;
          print("a: $a");
        } else if(response.rating == 2.0){
          b++;
          print("b: $b");
        } else if(response.rating == 3.0){
          c++;
        } else if(response.rating == 4.0){
          d++;
        }else{
          e++;
          print("e: $e");
        }

        avg = ((1*a)+(2*b)+(3*c)+(4*d)+(5*e))/5;
        print("Average : $avg");
        DatabaseReference ratRef = FirebaseDatabase.instance.reference().child('users/${donor.key}');
        ratRef.once().then((DataSnapshot snapshot) {
          if(snapshot.value != null){
          avg = snapshot.value['rating'] + avg;
        }
        });
        ratRef.child('rating').set(avg);

      },
    );

    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => _ratingDialog,
    );
  }

}