class ImagenResidencia {
  final String url;
  final String? descripcion;

  const ImagenResidencia({required this.url, this.descripcion});

  factory ImagenResidencia.fromJson(Map<String, dynamic> json) =>
      ImagenResidencia(
        url: json['url'] as String,
        descripcion: json['description'] as String?,
      );

  Map<String, dynamic> toJson() => {
    'url': url,
    if (descripcion != null) 'description': descripcion,
  };
}
