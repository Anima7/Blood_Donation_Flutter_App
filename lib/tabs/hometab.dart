import 'dart:async';
import 'package:bdf/brand_colors.dart';
import 'package:bdf/datamodels/user.dart';
import 'package:bdf/globalvariable.dart';
import 'package:bdf/helpers/helpermethods.dart';
import 'package:bdf/helpers/pushnotificationservice.dart';
import 'package:bdf/widgets/AvailabilityButton.dart';
import 'package:bdf/widgets/ConfirmSheet.dart';
import 'package:bdf/widgets/NotAllowedDialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeTab extends StatefulWidget {
  @override
  _HomeTabState createState() => _HomeTabState();
}

class _HomeTabState extends State<HomeTab> {

  GoogleMapController mapController;
  Completer<GoogleMapController> _controller = Completer();

  //int allowedTime = 5184000;
  int allowedTime = 5184000;


  void getCurrentPosition() async {

    Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.bestForNavigation);
    currentPosition = position;
    LatLng pos = LatLng(position.latitude, position.longitude);
    mapController.animateCamera(CameraUpdate.newLatLng(pos));

  }

  void getCurrentDonorInfo () async {

    currentFirebaseUser = await FirebaseAuth.instance.currentUser;
    DatabaseReference donorRef = FirebaseDatabase.instance.reference().child('users/${currentFirebaseUser.uid}');

    donorRef.once().then((DataSnapshot snapshot){
      if(snapshot.value != null){
        currentUserInfo = UserApp.fromSnapshot(snapshot);
        print('Donor full name is ${currentUserInfo.fullName}');
      }
    });

    PushNotificationService pushNotificationService = PushNotificationService();
    pushNotificationService.initialize(context);
    pushNotificationService.getToken();
  }


  @override
  void initState() {
    // TODO: implement initState
    checkForAvailability();
    checkForTime();
    super.initState();
    HelperMethods.cancelBloodRequest();
    getCurrentDonorInfo();
  }

  checkForAvailability() async{
    bool avail = getAvailValue() ?? false;
    setState(() {
      isAvailable = avail;
    });
  }
  checkForTime() async{
    int time = getTimeValue() ?? 5184000;
    setState(() {
      allowedTime = time;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        GoogleMap(
          padding: EdgeInsets.only(top: 135),
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          mapType: MapType.normal,
          initialCameraPosition: kGooglePlex,
          onMapCreated: (GoogleMapController controller){
            _controller.complete(controller);
            mapController = controller;

            getCurrentPosition();
          },
        ),
        Container(
          height: 135,
          width: double.infinity,
          color: BrandColors.colorPrimary,
        ),

        Positioned(
          top: 60,
          left: 0,
          right: 0,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              AvailabilityButton(
                title: availabilityTitle,
                color: availabilityColor,
                onPressed: (){
                  if(confirm == 'ended'){
                    stopOnline();
                    if(allowedTime != 0){
                      showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (BuildContext context) => NotAllowedDialog()
                      );
                    }
                  }else{
                    showModalBottomSheet(
                      isDismissible: false,
                      context: context,
                      builder: (BuildContext context) => ConfirmSheet(
                        title: (!isAvailable) ? 'GO ONLINE' : 'GO OFFLINE',
                        subtitle: (!isAvailable) ? 'You are about to become available to receive Blood requests': 'you will stop receiving new Blood requests',

                        onPressed: (){

                          if(!isAvailable){
                            GoOnline();
                            getLocationUpdates();
                            Navigator.pop(context);

                            setState(() {
                              availabilityColor = BrandColors.colorGreen;
                              availabilityTitle = 'GO OFFLINE';
                              isAvailable = true;
                              setAvailValue();
                            });

                          }
                          else{

                            GoOffline();
                            Navigator.pop(context);
                            setState(() {
                              availabilityColor = BrandColors.colorOrange;
                              availabilityTitle = 'GO ONLINE';
                              isAvailable = false;
                              setAvailValue();
                            });
                          }

                        },
                      ),
                    );
                  }
                },
              ),
            ],
          ),
        )

      ],
    );
  }

  void GoOnline(){
    Geofire.initialize('donorsAvailabile');
    Geofire.setLocation(currentFirebaseUser.uid, currentPosition.latitude, currentPosition.longitude,);
    id = currentFirebaseUser.uid;
    bloodRequestRef = FirebaseDatabase.instance.reference().child('users/${currentFirebaseUser.uid}/newrequest');
    bloodRequestRef.set('waiting');

    bloodRequestRef.onValue.listen((event) {

    });
  }

  void GoOffline (){

    Geofire.removeLocation(currentFirebaseUser.uid);
    bloodRequestRef.onDisconnect();
    bloodRequestRef.remove();
    bloodRequestRef = null;

  }

  void getLocationUpdates(){

    homeTabPositionStream = Geolocator.getPositionStream(desiredAccuracy: LocationAccuracy.bestForNavigation, distanceFilter: 4).listen((Position position) {
      currentPosition = position;

      if(isAvailable){
        Geofire.setLocation(currentFirebaseUser.uid, position.latitude, position.longitude);
      }

      LatLng pos = LatLng(position.latitude, position.longitude);
      mapController.animateCamera(CameraUpdate.newLatLng(pos));

    });

  }

  getAvailValue() async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    bool avail = pref.getBool('availValue');
    return avail;
  }
  setAvailValue() async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setBool('availValue', isAvailable);
  }

  getTimeValue() async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    int time = pref.getInt('timeValue');
    return time;
  }
  setTimeValue() async{
    SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setInt('timeValue', allowedTime);
  }

  void stopOnline(){

    const oneSecTick = Duration(seconds: 1);
    var timer = Timer.periodic(oneSecTick, (timer) {
      allowedTime -- ;
      setTimeValue();
      if(allowedTime == 0){
        confirm = 'allowed';
        allowedTime = 5184000;
        timer.cancel();
        }
    });
  }
}