import 'package:flutter/material.dart';

class VotingResults extends StatefulWidget {
  final List<Map<String, dynamic>> ppData;
  const VotingResults({super.key, required this.ppData});

  @override
  State<VotingResults> createState() => _VotingResultsState();
}

class _VotingResultsState extends State<VotingResults> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("Voting Results"),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              pollWidget(widget.ppData, "PP"),
            ],
          ),
        ));
  }

  Widget pollWidget(List<Map<String, dynamic>> ppData, String title) {
    //sort the data by the number of votes
    ppData.sort((a, b) => b['votes'].compareTo(a['votes']));
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.grey.withOpacity(.1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Voting Results for $title",
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            //loop through the data and display the votes for each candidate
            //display the name of the candidate, thier party name and the number of votes they have
            for (var i in ppData)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                i["party"],
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              Text(
                                i["name"],
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Column(
                            children: [
                              Text(
                                "Position: ${ppData.indexOf(i) + 1}",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.purple,
                                ),
                              ),
                              Text("${i['votes']} Votes"),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      LinearProgressIndicator(
                        value: i['votes'] / 100,
                        backgroundColor: Colors.green.withOpacity(.2),
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(Colors.green),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
