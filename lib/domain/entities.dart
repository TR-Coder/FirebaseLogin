import 'package:firebase_login/data/models.dart';

enum TipusTasca { examen, treball, exercici }
enum DiaSetmana { dilluns, dimarts, dimecres, dijous, divendres }

// =======================================================
class Hora {
  const Hora({required this.posicio, required this.descripcio, required this.esbarjo});
  final int posicio; // 0..9
  final String descripcio; // 0800
  final bool esbarjo; // false
  static Hora fromHoraModel(HoraModel horaModel) {
    return Hora(
      posicio: horaModel.posicio,
      esbarjo: horaModel.esbarjo,
      descripcio: horaModel.descripcio,
    );
  }

  HoraModel toHoraModel() {
    return HoraModel(
      posicio: posicio,
      esbarjo: esbarjo,
      descripcio: descripcio,
    );
  }
}

// =======================================================
class Assignatura {
  const Assignatura({required this.nom, required this.abreviatura});
  final String nom; // Matemàtiques
  final String abreviatura; // MAT
}

// =======================================================
class Horari {
  const Horari({required this.dia, required this.hora, this.assignatura, this.aula});
  final DiaSetmana dia; // 0..4
  final int hora; // 0..9
  final Assignatura? assignatura; // ref Assignatura
  final String? aula; // aula J01
}

// =======================================================
class Tasca {
  const Tasca({required this.data, required this.posicioHora, required this.tipusTasca, required this.descripcio});
  final DateTime data; // 14/01/21
  final int posicioHora; //  0..9
  final TipusTasca tipusTasca; // Exercici
  final String descripcio; // Tema 1, fer redacció
}
