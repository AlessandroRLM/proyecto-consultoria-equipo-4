class Campus {
    int id;
    String name;
    String city;
    String commune;
    double latitude;
    double longitude;

    Campus({
        required this.id,
        required this.name,
        required this.city,
        required this.commune,
        required this.latitude,
        required this.longitude,
    });

    factory Campus.fromJson(Map<String, dynamic> json) => Campus(
        id: json["id"],
        name: json["name"],
        city: json["city"],
        commune: json["commune"],
        latitude: json["latitude"],
        longitude: json["longitude"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "city": city,
        "commune": commune,
        "latitude": latitude,
        "longitude": longitude,
    };
}