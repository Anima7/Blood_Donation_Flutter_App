

import 'package:bdf/datamodels/nearbydonor.dart';

class FireHelper{

  static List<NearbyDonor> nearbyDonorList = [];

  static void removeFromList(String key){

    int index = nearbyDonorList.indexWhere((element) => element.key == key);

    if(nearbyDonorList.length > 0){
      nearbyDonorList.removeAt(index);
    }
  }

  static void updateNearbyLocation(NearbyDonor donor){

    int index = nearbyDonorList.indexWhere((element) => element.key == donor.key);

    nearbyDonorList[index].longitude = donor.longitude;
    nearbyDonorList[index].latitude = donor.latitude;


  }

}