import 'package:flutter/material.dart';

class BloodGroup extends StatefulWidget {
  String title;
  String imageUrl;
  BloodGroup({@required this.title, @required this.imageUrl});

  @override
  _BloodGroupState createState() => _BloodGroupState();
}

class _BloodGroupState extends State<BloodGroup> {

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Image.asset(
          widget.imageUrl,
          height: 70,
          width: 70,
        ),
        SizedBox(
          width: 16,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              widget.title,
              style: TextStyle(fontSize: 18, fontFamily: 'Brand-Bold'),
            ),
          ],
        ),
      ],
    );
  }
}
