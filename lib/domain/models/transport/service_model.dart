import 'dart:convert';

/// Parada dentro del itinerario. Puede ser campus o centro clínico.
/// El backend usa indistintamente 'campus_id' o 'clinical_id'.
class ItineraryStopModel {
  final int? campusId;
  final int? clinicalId;
  final String name;

  const ItineraryStopModel({
    this.campusId,
    this.clinicalId,
    required this.name,
  });

  factory ItineraryStopModel.fromJson(Map<String, dynamic> json) =>
      ItineraryStopModel(
        campusId: json['campus_id'] as int?,
        clinicalId: json['clinical_id'] as int?,
        name: json['name'] as String,
      );

  Map<String, dynamic> toJson() => {
    if (campusId != null) 'campus_id': campusId,
    if (clinicalId != null) 'clinical_id': clinicalId,
    'name': name,
  };
}

/// Servicio/itinerario de transporte publicado para reserva.
class TransportServiceModel {
  final int id;
  final String name;
  final String nameItinerary;
  final String typeService; // "IDA" | "REGRESO"
  final String departure; // "HH:mm:ss"
  final bool monTrip;
  final bool tueTrip;
  final bool wedTrip;
  final bool thuTrip;
  final bool friTrip;
  final bool satTrip;
  final bool sunTrip;
  final int clinalId; // (tal como viene escrito en JSON)
  final int sedeId;
  final List<ItineraryStopModel> itinerary;

  const TransportServiceModel({
    required this.id,
    required this.name,
    required this.nameItinerary,
    required this.typeService,
    required this.departure,
    required this.monTrip,
    required this.tueTrip,
    required this.wedTrip,
    required this.thuTrip,
    required this.friTrip,
    required this.satTrip,
    required this.sunTrip,
    required this.clinalId,
    required this.sedeId,
    required this.itinerary,
  });

  static bool _asBool(dynamic v) => (v is int) ? v == 1 : (v as bool);

  factory TransportServiceModel.fromJson(Map<String, dynamic> json) =>
      TransportServiceModel(
        id: json['id'] as int,
        name: json['name'] as String,
        nameItinerary: json['name_itinerary'] as String,
        typeService: json['type_service'] as String,
        departure: json['departure'] as String,
        monTrip: _asBool(json['mon_trip']),
        tueTrip: _asBool(json['tue_trip']),
        wedTrip: _asBool(json['wed_trip']),
        thuTrip: _asBool(json['thu_trip']),
        friTrip: _asBool(json['fri_trip']),
        satTrip: _asBool(json['sat_trip']),
        sunTrip: _asBool(json['sun_trip']),
        clinalId: json['clinal_id'] as int,
        sedeId: json['sede_id'] as int,
        itinerary: (json['itinerario'] as List<dynamic>)
            .map((e) => ItineraryStopModel.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'name_itinerary': nameItinerary,
    'type_service': typeService,
    'departure': departure,
    'mon_trip': monTrip ? 1 : 0,
    'tue_trip': tueTrip ? 1 : 0,
    'wed_trip': wedTrip ? 1 : 0,
    'thu_trip': thuTrip ? 1 : 0,
    'fri_trip': friTrip ? 1 : 0,
    'sat_trip': satTrip ? 1 : 0,
    'sun_trip': sunTrip ? 1 : 0,
    'clinal_id': clinalId,
    'sede_id': sedeId,
    'itinerario': itinerary.map((e) => e.toJson()).toList(),
  };

  static List<TransportServiceModel> listFromJsonList(List<dynamic> list) =>
      list
          .map((e) => TransportServiceModel.fromJson(e as Map<String, dynamic>))
          .toList();

  static List<TransportServiceModel> listFromJsonString(String s) =>
      listFromJsonList(jsonDecode(s) as List<dynamic>);
}
