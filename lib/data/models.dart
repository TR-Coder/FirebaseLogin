class HoraModel {
  HoraModel({required this.posicio, required this.descripcio, required this.esbarjo});
  final int posicio; // 0..9
  final String descripcio; // 0800
  final bool esbarjo; // false

  Map<String, dynamic> toJson() {
    return {
      'posicio': posicio,
      'esbarjo': esbarjo,
      'descripcio': descripcio,
    };
  }

  static HoraModel FromJson(Map<String, dynamic> json) {
    return HoraModel(
      posicio: json['posicio'] as int,
      esbarjo: json['esbarjo'] as bool,
      descripcio: json['descripcio'] as String,
    );
  }
}
