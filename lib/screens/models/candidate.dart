class Candidate {
  final String name;
  final String party;
  final int voteCount;

  Candidate({required this.name, required this.party, required this.voteCount});

  //factory from document snapshot
  factory Candidate.fromDocument(dynamic doc) {
    return Candidate(
      name: doc['name'],
      party: doc['party'],
      voteCount: doc['vote_count'],
    );
  }
}
