import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_login/data/models.dart';

class FireBaseRepository {
  CollectionReference<HoraModel> horesRef = FirebaseFirestore.instance.collection('hores').withConverter<HoraModel>(
        fromFirestore: (snapshots, _) => HoraModel.FromJson(snapshots.data()!),
        toFirestore: (horaFirebase, _) => horaFirebase.toJson(),
      );

  Future<List<HoraModel>> GetHoresFirebase() async {
    QuerySnapshot<HoraModel> queryResult = await horesRef.get();
    return queryResult.docs.map((doc) => doc.data()).toList();
  }

// final Movie movie2 = (await collection.doc('2').get()).data()!;
// https://stackoverflow.com/questions/68079030/how-to-use-firestore-withconverter-in-flutter
// https://flutteragency.com/how-to-get-all-data-from-a-firestore-collection-in-flutter/

}
