// a function that will get the count of 3 collections in firebase and return a map <String, int>

import 'dart:io';

import 'package:admin_panel/screens/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:csv/csv.dart';

List<UserModel> users = [];

Future<Map<String, int>> getCounts() async {
  Map<String, int> counts = {
    'activeUsers': 0,
    'verifiedCount': 0,
    'unverifiedCount': 0,
    'activeOrders': 0,
  };
  // get the count of active users
  await FirebaseFirestore.instance
      .collection('Users')
      //.where('status', isEqualTo: 'active')
      .get()
      .then((value) {
    //fill the users list with the users from the database
    users = value.docs.map((e) => UserModel.fromMap(e)).toList();
    //print(value.docs.length);
    counts['activeUsers'] = value.docs.length;

    //loop through the documents and get the count of active users
    for (var i = 0; i < value.docs.length; i++) {
      if (value.docs[i]['verified'] == true) {
        counts['verifiedCount'] = counts['verifiedCount']! + 1;
      } else {
        counts['unverifiedCount'] = counts['unverifiedCount']! + 1;
      }
    }
  });
  // get the count of active orders
  // await FirebaseFirestore.instance
  //     .collection('donations')
  //     .where('isActive', isEqualTo: true)
  //     .get()
  //     .then((value) {
  //   counts['activeOrders'] = value.docs.length;
  // });
  // // get the count of active requests
  // await FirebaseFirestore.instance
  //     .collection('requests')
  //     .where('status', isEqualTo: 'active')
  //     .get()
  //     .then((value) {
  //   counts['activeRequests'] = value.docs.length;
  // });
  // // get the count of completed orders
  // await FirebaseFirestore.instance
  //     .collection('requests')
  //     .where('status', isEqualTo: 'accepted')
  //     .get()
  //     .then((value) {
  //   counts['completedOrders'] = value.docs.length;
  // });
  //print(counts);
  return counts;
}

//a function that will load a csv file from the assets folder and return a list of lists of strings
Future<List<List<dynamic>>> loadCSVFile() async {
  final data = await rootBundle.loadString('assets/CNIC.csv');
  List<List<dynamic>> rowsAsListOfValues =
      const CsvToListConverter().convert(data);

  rowsAsListOfValues.removeAt(0);
  print(rowsAsListOfValues);

  return rowsAsListOfValues;
}
