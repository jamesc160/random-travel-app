import 'dart:convert';
import 'package:intl/intl.dart';

class Blog {
  int? id;
  String name;
  String title;
  DateTime date;
  String body;
  String? imagePath;
  Blog({
    this.id,
    this.imagePath,
    required this.name,
    required this.title,
    required this.date,
    required this.body,
  });

  String get formatedDate => DateFormat('dd-MM-yyyy').format(date);

  Blog copyWith(
      {String? name,
      String? title,
      DateTime? date,
      String? body,
      String? imagePath}) {
    return Blog(
        name: name ?? this.name,
        title: title ?? this.title,
        date: date ?? this.date,
        body: body ?? this.body,
        imagePath: imagePath ?? this.imagePath);
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'title': title,
      'date': date.toString(),
      'body': body,
      'image': imagePath
    };
  }

  factory Blog.fromMap(Map<String, dynamic> map) {
    return Blog(
        id: map['id'],
        name: map['name'] ?? '',
        title: map['title'] ?? '',
        date: DateTime.parse(map['date']),
        body: map['body'] ?? '',
        imagePath: map['image']);
  }

  String toJson() => json.encode(toMap());

  factory Blog.fromJson(String source) => Blog.fromMap(json.decode(source));

  @override
  String toString() {
    return 'Blog(id:$id, name: $name, title: $title, date: $date, body: $body, Image: $imagePath)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Blog &&
        other.name == name &&
        other.title == title &&
        other.date == date &&
        other.id == id &&
        other.imagePath == imagePath &&
        other.body == body;
  }

  @override
  int get hashCode {
    return name.hashCode ^ title.hashCode ^ date.hashCode ^ body.hashCode;
  }
}
