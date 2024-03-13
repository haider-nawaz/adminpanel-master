import 'package:admin_panel/screens/Components/donators_category.dart';
import 'package:admin_panel/screens/display_results.dart';
import 'package:admin_panel/screens/kyc_screen.dart';
import 'package:admin_panel/screens/na_results_page.dart';
import 'package:admin_panel/screens/voting_results.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'admin_profile.dart';

class SideMenu extends StatefulWidget {
  const SideMenu({
    Key? key,
  }) : super(key: key);

  @override
  State<SideMenu> createState() => _SideMenuState();
}

class _SideMenuState extends State<SideMenu> {
  var _isElectionStarted = false;
  late final List<Map<String, dynamic>> ppData;
  void fetchVoteData() async {
    //fetch data from firestore

    await FirebaseFirestore.instance
        .collection("PP")
        .get()
        .then((value) => {
              for (var i in value.docs)
                {
                  // print(i.data()),
                  ppData.add(i.data()),
                },
            })
        .catchError((onError) {
      print(onError);
    });
  }

  Future<void> checkElectionStatus() async {
    await FirebaseFirestore.instance
        .collection("settings")
        .doc("2E19U8ygCkmLIocvaU0D")
        .get()
        .then((value) {
      setState(() {
        _isElectionStarted = value.get("start_election");
      });
    });
  }

  @override
  void initState() {
    ppData = [];
    fetchVoteData();

    checkElectionStatus();
    super.initState();
  }

  // FUNCTION TO TOGGLE THE SWITCH which will get the value of the switch from firebase
  void _toggleSwitch(bool value) {
    setState(() {
      _isElectionStarted = value;
      FirebaseFirestore.instance
          .collection("settings")
          .doc("2E19U8ygCkmLIocvaU0D")
          .update({"start_election": value}).then((value) {
        //show a snackbar
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Election Status Updated"),
          ),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SingleChildScrollView(
        child: Column(
          children: [
            DrawerHeader(
              child: Image.asset(
                "assets/images/logo11.jpg",
                width: 10,
                height: 10,
              ),
            ),
            DrawerListTile(
              title: ' Dashboard',
              icon: Icons.dashboard,
              press: () {},
            ),
            ListTile(
              title: const Text(
                'Start/End Election',
                style: TextStyle(color: Colors.white54),
              ),
              trailing: Switch(
                value: _isElectionStarted,
                onChanged: (value) {
                  _toggleSwitch(value);
                },
              ),
            ),

            DrawerListTile(
              title: ' KYC',
              icon: Icons.check,
              press: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const KycScreen()),
                );
              },
            ),
            DrawerListTile(
              title: 'Provincial Assembly',
              icon: Icons.how_to_vote,
              press: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => VotingResults(
                            ppData: ppData,
                          )),
                );
              },
            ),
            DrawerListTile(
              title: 'National Assembly',
              icon: Icons.how_to_vote,
              press: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NaResultsPage(),
                  ),
                );
              },
            ),
            DrawerListTile(
              title: 'Results',
              icon: Icons.document_scanner,
              press: () {
                if (_isElectionStarted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          "Election is still ongoing. Please wait for it to end."),
                    ),
                  );
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => Displayresults(
                        ppData: ppData,
                      ),
                    ),
                  );
                }
              },
            ),
            //DrawerListTile(
            //title: 'Panel Settings',
            //icon: Icons.settings,
            //press: () {},
            //),
          ],
        ),
      ),
    );
  }
}

class DrawerListTile extends StatelessWidget {
  const DrawerListTile({
    Key? key,
    required this.title,
    required this.icon,
    required this.press,
  }) : super(key: key);

  final String title;
  final IconData icon;
  final VoidCallback press;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(
        icon,
        color: Colors.white54,
      ),
      onTap: press,
      horizontalTitleGap: 0.0,
      title: Text(
        title,
        style: TextStyle(color: Colors.white54),
      ),
    );
  }
}
