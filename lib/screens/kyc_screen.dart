import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../utils.dart';
import 'models/user_model.dart';

class KycScreen extends StatefulWidget {
  const KycScreen({super.key});

  @override
  State<KycScreen> createState() => _KycScreenState();
}

class _KycScreenState extends State<KycScreen> {
  //a function to approve or reject a user
  void approveOrRejectUser(UserModel user) {
    //if user is already verified, then reject it
    if (user.isVerified) {
      user.isVerified = false;
      user.status = 'rejected';
    } else {
      //if user is not verified, then approve it
      user.isVerified = true;
      user.status = 'approved';
    }
    //update the user in the database
    updateUserData(user);
    //update the UI
    setState(() {});
  }

  List<List<dynamic>>? candidates;
  List<Map<String, String>> formattedCandidates = [];

  @override
  void initState() {
    loadCSV();
    super.initState();
  }

  loadCSV() async {
    candidates = await loadCSVFile();

    for (var i = 0; i < candidates!.length; i++) {
      var candidate = candidates![i];
      //print("candidate: $candidate");

      try {
        String name = "${candidate[0]} ${candidate[1]}";
        String cnic = candidate[2].toString();
        cnic = cnic.replaceAll('-', '');

        formattedCandidates.add({
          'name': name,
          'cnic': cnic,
        });
      } catch (e) {
        print(e);
      }
    }
    print("formattedCandidates: $formattedCandidates");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('KYC'),
        actions: [
          ElevatedButton(
            onPressed: () {
              //loop through the users list and check if the name and cnic of the user is in the formattedCandidates list
              //if it is, then update the user's status to approved and isVerified to true
              //if it is not, then update the user's status to rejected and isVerified to false
              for (var i = 0; i < users.length; i++) {
                var user = users[i];
                print("user: ${user.toMap()}");
                var isUserVerified = false;

                for (var j = 0; j < formattedCandidates.length; j++) {
                  var candidate = formattedCandidates[j];
                  print("candidate: $candidate");
                  if (candidate['name'] ==
                          "${user.firstName} ${user.lastName}" &&
                      candidate['cnic'] == user.cnic) {
                    isUserVerified = true;
                    setState(() {
                      if (isUserVerified) {
                        print("user is verified");
                        users[i].isVerified = true;
                        users[i].status = 'approved';
                      } else {
                        print("user is not verified");
                        users[i].isVerified = false;
                        users[i].status = 'rejected';
                      }
                    });
                    break;
                  }
                }
              }
              updateAllUsersData();
            },
            child: const Text("Automatic Verification"),
          )
        ],
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 40,
            ),
            Text(
              'Users Data',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(
              height: 40,
            ),
            SizedBox(
              height: 600,
              width: MediaQuery.of(context).size.width * 0.8,
              child: DataTable2(
                  columnSpacing: 12,
                  horizontalMargin: 12,
                  minWidth: 800,

                  // border: TableBorder.all(
                  //     color: Colors.grey, style: BorderStyle.solid, width: 1),
                  columns: const [
                    DataColumn2(
                      label: Text('Serial No.'),
                      size: ColumnSize.L,
                    ),
                    DataColumn2(
                      label: Text('Fisrt Name'),
                      size: ColumnSize.L,
                    ),
                    DataColumn(
                      label: Text('Last Name'),
                    ),
                    DataColumn(
                      label: Text('CNIC'),
                    ),
                    DataColumn(
                      label: Text('Status'),
                    ),
                    DataColumn(
                      label: Text('Action'),
                    ),
                  ],
                  rows: buildDataRowFromList(users)),
            ),
          ],
        ),
      ),
    );
  }

  List<DataRow> buildDataRowFromList(List<UserModel> users) {
    return users
        .map((user) => DataRow(cells: [
              //user number, e.g. 1,2,3,4,5
              DataCell(Text((users.indexOf(user) + 1).toString())),

              DataCell(Text(user.firstName)),
              DataCell(Text(user.lastName)),
              DataCell(Text(user.cnic)),
              DataCell(buildStatusChip(user.status)),
              DataCell(
                ElevatedButton(
                  onPressed: () {
                    approveOrRejectUser(user);
                  },
                  child: user.isVerified
                      ? const Text('Reject User')
                      : const Text('Verify User'),
                ),
              ),
            ]))
        .toList();
  }

  Widget buildStatusChip(String status) {
    return Chip(
      label: Text(status.capitalizeFirst!),
      backgroundColor: status == 'new'
          ? Colors.blue
          : status == 'approved'
              ? Colors.green
              : Colors.red,
    );
  }

  void updateUserData(UserModel user) {
    print(user.toMap());
    FirebaseFirestore.instance
        .collection('Users')
        .doc(user.id)
        .update(user.toMap())
        .then(
          (value) => Get.snackbar(
            'Success',
            'User updated successfully',
            backgroundColor: Colors.green,
            maxWidth: 300,
            icon: const Icon(Icons.check),
            shouldIconPulse: true,
            duration: const Duration(seconds: 2),
          ),
        )
        .catchError((onError) => Get.snackbar('Error', onError.toString()));
  }

  void updateAllUsersData() {
    for (var i = 0; i < users.length; i++) {
      var user = users[i];
      FirebaseFirestore.instance
          .collection('Users')
          .doc(user.id)
          .update(user.toMap())
          .then(
            (value) => print('User updated successfully'),
          )
          .catchError((onError) => Get.snackbar('Error', onError.toString()));
    }
  }
}
