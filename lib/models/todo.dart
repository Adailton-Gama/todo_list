class Todo {
  Todo({required this.title, required this.dataTime, required this.complete});
  Todo.fromJson(Map<String, dynamic> json)
      : title = json['title'],
        dataTime = DateTime.parse(json['datetime']),
        complete = json['concluido'];

  String title;
  DateTime dataTime;
  bool complete = false;

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'datetime': dataTime.toIso8601String(),
      'concluido': complete,
    };
  }
}
