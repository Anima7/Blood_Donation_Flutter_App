import 'package:firebase_database/firebase_database.dart';

class UserApp{
  String fullName;
  String email;
  String phone;
  String id;
  String bloodGroup;
  int rating;

  UserApp({
    this.email,
    this.fullName,
    this.phone,
    this.id,
    this.bloodGroup,
    this.rating,
  });

  UserApp.fromSnapshot(DataSnapshot snapshot){
    fullName = snapshot.value['fullname'];
    id = snapshot.key;
    phone = snapshot.value['phone'];
    email = snapshot.value['email'];
    bloodGroup = snapshot.value['bloodGroup'];
    rating = snapshot.value['rating'] ;
  }

}