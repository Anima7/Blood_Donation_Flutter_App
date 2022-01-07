
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../brand_colors.dart';
import 'OutlineButton.dart';

class DonorDetail extends StatefulWidget {
  String title ;
  String subTitle;
  DonorDetail({this.title, this.subTitle});

  @override
  _DonorDetailState createState() => _DonorDetailState();
}

class _DonorDetailState extends State<DonorDetail> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      elevation: 0.0,
      backgroundColor: Colors.transparent,
      child: Container(
        margin: EdgeInsets.all(0),
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
        ),
        child: Padding(
          padding:  EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 10,),

                Text(widget.title, style: TextStyle(fontSize: 22.0, fontFamily: 'Brand-Bold'),),

                SizedBox(height: 25,),

                Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text(widget.subTitle, textAlign: TextAlign.center,),
                ),

                SizedBox(height: 30,),

                Container(
                  width: 200,
                  child: UserOutlineButton(
                    title: 'CLOSE',
                    color: BrandColors.colorLightGrayFair,
                    onPressed: (){
                      Navigator.pop(context);
                    },
                  ),
                ),

                SizedBox(height: 10,),

              ],
            ),
          ),
        ),
      ),
    );
  }
}