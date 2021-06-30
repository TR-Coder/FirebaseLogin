import 'package:firebase_login/domain/entities.dart';

abstract class IRepository {
  Future<List<Hora>> getHores();
}
