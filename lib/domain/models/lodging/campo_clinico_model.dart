class CampoClinico {
  final int clinicalFieldId;
  final String clinicalFieldName;

  const CampoClinico({
    required this.clinicalFieldId,
    required this.clinicalFieldName,
  });

  factory CampoClinico.fromJson(Map<String, dynamic> json) => CampoClinico(
    clinicalFieldId: _toInt(json['clinicalFieldId']),
    clinicalFieldName: (json['clinicalFieldName'] ?? '').toString(),
  );

  Map<String, dynamic> toJson() => {
    'clinicalFieldId': clinicalFieldId,
    'clinicalFieldName': clinicalFieldName,
  };

  // --- helpers ---
  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v.trim()) ?? 0;
    return 0;
  }
}
