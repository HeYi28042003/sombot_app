import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:sombot_pc/data/models/map_model.dart';

class MapController extends ChangeNotifier {
  

   Future<PlaceModel?> getPlaceDetails(String userId) async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection('user_addresses')
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final data = querySnapshot.docs.first.data();
        // Use fromFirestore if you have it, otherwise fromJson
        return PlaceModel.fromFirestore(data);
      } else {
        return null;
      }
    } catch (e) {
      print('Error fetching place details: $e');
      return null;
    }
   }

}
