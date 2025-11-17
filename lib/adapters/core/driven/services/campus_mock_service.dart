import 'package:mobile/domain/core/campus.dart';
import 'package:mobile/ports/core/driven/for_querying_campus.dart';

class CampusMockService implements ForQueryingCampus {
  final List<Campus> _listCampus = [
    Campus(
      id: 21,
      name: "CLÍNICA SAN MARTÍN",
      city: "REGIÓN DE LOS LAGOS",
      commune: "OSORNO",
      latitude: -40.57310,
      longitude: -73.04120,
    ),
    Campus(
      id: 22,
      name: "HOSPITAL FAMILIAR MAIPÚ",
      city: "REGIÓN METROPOLITANA",
      commune: "MAIPÚ",
      latitude: -33.49785,
      longitude: -70.75930,
    ),
    Campus(
      id: 23,
      name: "CESFAM PUERTO VARAS",
      city: "REGIÓN DE LOS LAGOS",
      commune: "PUERTO VARAS",
      latitude: -41.32034,
      longitude: -72.98562,
    ),
    Campus(
      id: 24,
      name: "CESFAM PARQUE O'HIGGINS",
      city: "REGIÓN METROPOLITANA",
      commune: "SANTIAGO",
      latitude: -33.46000,
      longitude: -70.66190,
    ),
    Campus(
      id: 25,
      name: "HOSPITAL QUILPUÉ",
      city: "REGIÓN DE VALPARAÍSO",
      commune: "QUILPUÉ",
      latitude: -33.04730,
      longitude: -71.44220,
    ),
  ];

  @override
  Future<List<Campus>> getCampus(String? q) async {
    if (q == null) return _listCampus;
    return _listCampus
        .where((element) =>
            element.name.toLowerCase().contains(q.toLowerCase()) ||
            element.city.toLowerCase().contains(q.toLowerCase()) ||
            element.commune.toLowerCase().contains(q.toLowerCase()))
        .toList();
  }

  @override
  Future<Campus> getCampusById(int id) async {
    return _listCampus.firstWhere((element) => element.id == id);
  }
}
