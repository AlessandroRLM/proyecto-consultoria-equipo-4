import 'dart:convert';

import 'user_model.dart';
import 'student_model.dart';

class StudentProfileModel {
  final UserModel user;
  final StudentModel student;

  const StudentProfileModel({required this.user, required this.student});

  factory StudentProfileModel.fromJson(Map<String, dynamic> json) =>
      StudentProfileModel(
        user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
        student: StudentModel.fromJson(json['student'] as Map<String, dynamic>),
      );

  Map<String, dynamic> toJson() => {
    'user': user.toJson(),
    'student': student.toJson(),
  };

  static StudentProfileModel fromJsonString(String s) =>
      StudentProfileModel.fromJson(jsonDecode(s) as Map<String, dynamic>);
  String toJsonString() => jsonEncode(toJson());
}
