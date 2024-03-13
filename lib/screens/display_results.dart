import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:d_chart/d_chart.dart';
import 'package:fl_chart/fl_chart.dart';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'models/candidate.dart';
import 'voting_results.dart';

class Displayresults extends StatefulWidget {
  final List<Map<String, dynamic>> ppData;

  const Displayresults({super.key, required this.ppData});

  @override
  State<Displayresults> createState() => _DisplayresultsState();
}

class _DisplayresultsState extends State<Displayresults> {
  bool isLoading = false;

  var eligibleNas = [
    "NA#79",
    "NA#80",
    "NA#81",
    "NA#82",
    "NA#83",
    "NA#84",
  ];
  var selectedNA = "NA#79";

  final List<Map<String, Candidate>> votingResult = [];

  final List<Map<String, Candidate>> topThreeCandidates = [];

  final List<PieChartSectionData> pieSections = [];

  //a function that will load ppdata and fill the pieSections by the data
  void loadPPData() {
    //a colors list to be used for the pie chart
    final colors = [
      Colors.green,
      Colors.red,
      Colors.blue,
      Colors.black,
      Colors.purple,
      Colors.orange,
    ];
    for (var i in widget.ppData) {
      pieSections.add(
        PieChartSectionData(
          value: i['votes'].toDouble(),
          title: "${i['party']} (${i['votes']} votes)",
          color: colors[widget.ppData.indexOf(i)],
          titlePositionPercentageOffset: 0.7,
          radius: 200,
        ),
      );
    }
  }

  @override
  void initState() {
    fetchVotingResults();
    loadPPData();
    super.initState();
  }

  void fetchVotingResults() async {
    setState(() {
      isLoading = true;
    });
    for (var na in eligibleNas) {
      await FirebaseFirestore.instance
          .collection("NA-Result")
          .doc(na)
          .collection("Candidates")
          .get()
          .then(
            (value) => {
              for (var i in value.docs)
                {
                  // print(i.data()),
                  votingResult.add({na: Candidate.fromDocument(i.data())}),
                },
              //getTopThreeCandidates(votingResult, selectedNA),
              setState(() {
                isLoading = false;
              }),
            },
          )
          .catchError((error) => {
                print("Error fetching voting results: $error"),
                setState(() {
                  isLoading = false;
                })
              });
    }

    print(votingResult);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Election Winners'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(
              height: 80,
            ),
            SizedBox(
              height: 400,
              width: 400,
              child: PieChart(
                PieChartData(sections: pieSections),
              ),
            ),
            const SizedBox(
              height: 40,
            ),
            SizedBox(
              height: 220,
              child: PollWidget(
                  ppData: widget.ppData,
                  title: "PP",
                  displayTopCandidateOnly: true),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text(
                        "National Assembly Results",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(.1),
                          borderRadius: BorderRadius.circular(50),
                        ),
                        child: IconButton(
                          onPressed: () {
                            fetchVotingResults();
                          },
                          icon: const Icon(
                            Icons.refresh,
                            color: Colors.green,
                          ),
                        ),
                      )
                    ],
                  ),
                  // horizontal lis
                  //t view to display chips
                  const SizedBox(
                    height: 15,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(0.0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: eligibleNas
                            .map(
                              (na) => GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedNA = na;
                                  });
                                },
                                child: Container(
                                  margin: const EdgeInsets.only(right: 10),
                                  padding: const EdgeInsets.all(10),
                                  decoration: BoxDecoration(
                                    color: selectedNA == na
                                        ? Colors.green
                                        : Colors.grey[200],
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    na,
                                    style: TextStyle(
                                      color: selectedNA == na
                                          ? Colors.white
                                          : Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ),

                  const SizedBox(
                    height: 40,
                  ),

                  isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                          color: Colors.green,
                        ))
                      : Container(
                          margin: const EdgeInsets.only(left: 0, right: 0),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(.1),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          width: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(20.0),
                                child: Text(
                                  "Winner for $selectedNA",
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),

                              //sort the data by the vote count descending
                              //and display the poll widget for all the candidates
                              NaPollWidget(
                                votingResult: votingResult,
                                selectedNA: selectedNA,
                                displayTopCandidateOnly: true,
                              ),
                            ],
                          ),
                        )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class NaPollWidget extends StatelessWidget {
  const NaPollWidget({
    super.key,
    required this.votingResult,
    required this.selectedNA,
    required this.displayTopCandidateOnly,
  });

  final List<Map<String, Candidate>> votingResult;
  final String selectedNA;
  final bool displayTopCandidateOnly;

  @override
  Widget build(BuildContext context) {
    final currNAList = [];
    for (var i in votingResult) {
      if (i.containsKey(selectedNA)) {
        currNAList.add(i);
      }
    }

    //sort the data by the vote count descending
    //and display the poll widget for all the candidates
    currNAList.sort(
        (a, b) => b.values.first.voteCount.compareTo(a.values.first.voteCount));

    int numCandidates = displayTopCandidateOnly ? 1 : currNAList.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        //loop through the data and display the votes for each candidate
        //display the name of the candidate, thier party name and the number of votes they have
        for (var i = 0; i < numCandidates; i++)
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          currNAList[i].values.first.party,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        Text(
                          currNAList[i].values.first.name,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "1st Position",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.purple,
                          ),
                        ),
                        Text(
                          "with ${currNAList[i].values.first.voteCount}  votes",
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.normal,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // LinearProgressIndicator(
                //   value: currNAList[i].values.first.voteCount / 100,
                //   backgroundColor: Colors.green.withOpacity(.2),
                //   valueColor:
                //       const AlwaysStoppedAnimation<Color>(Colors.green),
                // ),
              ],
            ),
          ),
      ],
    );
  }
}

class PollWidget extends StatelessWidget {
  const PollWidget({
    super.key,
    required this.ppData,
    required this.title,
    required this.displayTopCandidateOnly,
  });

  final List<Map<String, dynamic>> ppData;
  final String title;
  final bool displayTopCandidateOnly;

  @override
  Widget build(BuildContext context) {
    // Sort the data by the number of votes
    ppData.sort((a, b) => b['votes'].compareTo(a['votes']));

    // Determine the number of candidates to display based on the flag
    int numCandidates = displayTopCandidateOnly ? 1 : ppData.length;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.grey.withOpacity(.1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text("Winner of $title",
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold)),
            ),
            // Loop through the data and display the votes for each candidate
            // Display the name of the candidate, their party name, and the number of votes they have
            for (int index = 0; index < numCandidates; index++)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            ppData[index]["party"],
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                          Text(
                            ppData[index]["name"],
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "1st Position",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.purple,
                            ),
                          ),
                          Text("with ${ppData[index]['votes']} Votes"),
                        ],
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
