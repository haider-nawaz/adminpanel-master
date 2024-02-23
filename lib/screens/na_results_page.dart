import 'package:admin_panel/screens/models/candidate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NaResultsPage extends StatefulWidget {
  const NaResultsPage({super.key});

  @override
  State<NaResultsPage> createState() => _NaResultsPageState();
}

class _NaResultsPageState extends State<NaResultsPage> {
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

  @override
  void initState() {
    fetchVotingResults();
    super.initState();
  }

  void getTopThreeCandidates(
      List<Map<String, Candidate>> votingResult, String selectedNA) {
    List<MapEntry<String, Candidate>> sortedCandidates =
        votingResult.first.entries.toList();
    sortedCandidates
        .sort((a, b) => b.value.voteCount.compareTo(a.value.voteCount));
    topThreeCandidates.add({selectedNA: sortedCandidates[0].value});
    topThreeCandidates.add({selectedNA: sortedCandidates[1].value});
    topThreeCandidates.add({selectedNA: sortedCandidates[2].value});

    // print("Top three candidates: $topThreeCandidates");

    print("1st candidate: ${topThreeCandidates[0].values.first.name}");
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
              getTopThreeCandidates(votingResult, selectedNA),
              setState(() {
                isLoading = false;
              })
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
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
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
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        width: double.infinity,
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Text(
                                "Voting Results for $selectedNA",
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),

                            //sort the data by the vote count descending
                            //and display the poll widget for all the candidates
                            pollWidget(selectedNA),
                          ],
                        ),
                      )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget pollWidget(String selectedNA) {
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

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 0.0),
      child: Container(
        padding: const EdgeInsets.all(0.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: Colors.transparent.withOpacity(.9),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            //loop through the data and display the votes for each candidate
            //display the name of the candidate, thier party name and the number of votes they have
            for (var i in currNAList)
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
                                i.values.first.party,
                                style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                              Text(
                                i.values.first.name,
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
                                "Position: ${currNAList.indexOf(i) + 1}",
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.purple,
                                ),
                              ),
                              Text(
                                "Votes: ${i.values.first.voteCount}",
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
                      LinearProgressIndicator(
                        value: i.values.first.voteCount / 100,
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
