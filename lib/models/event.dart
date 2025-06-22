class Event {
  final String id;
  final String title;
  final String description;
  final DateTime date;
  final String location;
  final String creatorId;
  final String? departmentId;
  final String? teamId;

  Event({
    required this.id,
    required this.title,
    required this.description,
    required this.date,
    required this.location,
    required this.creatorId,
    this.departmentId,
    this.teamId,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      date: DateTime.parse(json['date']),
      location: json['location'],
      creatorId: json['creatorId'],
      departmentId: json['departmentId'],
      teamId: json['teamId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'date': date.toIso8601String(),
      'location': location,
      'creatorId': creatorId,
      'departmentId': departmentId,
      'teamId': teamId,
    };
  }
}
