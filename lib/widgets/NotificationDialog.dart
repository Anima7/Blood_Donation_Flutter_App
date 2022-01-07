
import 'package:bdf/datamodels/reqprogressdetails.dart';
import 'package:bdf/helpers/helpermethods.dart';
import 'package:bdf/screens/newrequestpage.dart';
import 'package:bdf/widgets/OutlineButton.dart';
import 'package:bdf/widgets/donorbutton.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:toast/toast.dart';
import '../brand_colors.dart';
import '../globalvariable.dart';
import 'ProgressDialog.dart';
import 'brandDivider.dart';

class NotificationDialog extends StatelessWidget {

  final ReqProgressDetails reqProgressDetails;

  NotificationDialog({this.reqProgressDetails});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Container(
        margin: EdgeInsets.all(4),
        width: double.infinity,
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(4)
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[

            SizedBox(height: 30.0,),

            Image.asset('images/blood_icon.png', width: 100,),

            SizedBox(height: 16.0,),

            Text('NEW BLOOD REQUEST', style: TextStyle(fontFamily: 'Brand-Bold', fontSize: 18),),

            SizedBox(height: 30.0,),

            Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(

                children: <Widget>[

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Image.asset('images/pickicon.png', height: 16, width: 16,),
                      SizedBox(width: 18,),
                      Expanded(child: Container(child: Text(reqProgressDetails.pickupAddress, style: TextStyle(fontSize: 18),)))


                    ],
                  ),

                  SizedBox(height: 15,),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Image.asset('images/bloodicon.jpg', height: 16, width: 16,),
                      SizedBox(width: 18,),

                      Expanded(child: Container(child: Text(reqProgressDetails.requestBloodGroup, style: TextStyle(fontSize: 18),)))


                    ],
                  ),

                ],
              ),
            ),

            SizedBox(height: 20,),

            BrandDivider(),

            SizedBox(height: 8,),

            Padding(
              padding: EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[

                  Expanded(
                    child: Container(
                      child: UserOutlineButton(
                        title: 'DECLINE',
                        color: BrandColors.colorPrimary,
                        onPressed: () async {
                          assetsAudioPlayer.stop();
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ),

                  SizedBox(width: 10,),

                  Expanded(
                    child: Container(
                      child: DonorButton(
                        title: 'ACCEPT',
                        color: BrandColors.colorGreen,
                        onPressed: () async {
                          assetsAudioPlayer.stop();
                          checkAvailablity(context);
                        },
                      ),
                    ),
                  ),

                ],
              ),
            ),

            SizedBox(height: 10.0,),

          ],
        ),
      ),
    );
  }

  Future<void> checkAvailablity(context) async {

    //show please wait dialog
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) => ProgressDialog(status: 'Accepting request',),
    );

    currentFirebaseUser = await FirebaseAuth.instance.currentUser;
    DatabaseReference newRequestRef = FirebaseDatabase.instance.reference().child('users/${currentFirebaseUser.uid}/newrequest');
    newRequestRef.once().then((DataSnapshot snapshot) {

      Navigator.pop(context);
      Navigator.pop(context);

      String thisRequestID = "";
      if(snapshot.value != null){
        thisRequestID = snapshot.value.toString();
      }
      else{
        Toast.show("Request not found", context, duration: Toast.LENGTH_SHORT, gravity:  Toast.BOTTOM);
      }
//if the requestID (request_id feild in accepterRequest) is waiting condition check with newrequest (field in users)
      if(thisRequestID == reqProgressDetails.requestID){
        newRequestRef.set('accepted');
        Toast.show("Request has been accepted", context, duration: Toast.LENGTH_SHORT, gravity:  Toast.BOTTOM);
        print("accepted");
        HelperMethods.disableHomTabLocationUpdates();
        Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => NewRequestPage(reqProgressDetails: reqProgressDetails,),
            ));
      }
      else if(thisRequestID == 'cancelled'){
        Toast.show("Request has been cancelled", context, duration: Toast.LENGTH_SHORT, gravity:  Toast.BOTTOM);
      }
      else if(thisRequestID == 'timeout'){
        Toast.show("Request has timed out", context, duration: Toast.LENGTH_SHORT, gravity:  Toast.BOTTOM);
      }
      else{
        Toast.show("Request not found", context, duration: Toast.LENGTH_SHORT, gravity:  Toast.BOTTOM);
      }

    });
  }

}