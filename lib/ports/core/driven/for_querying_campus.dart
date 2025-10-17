import 'package:mobile/domain/core/campus.dart';

abstract class ForQueryingCampus {
  Future<List<Campus>> getCampus(String? q);

  Future<Campus> getCampusById(int id);

}