import 'package:firebase_login/domain/entities.dart';
import 'package:firebase_login/domain/i_repository.dart';

class UseCases {
  IRepository repository;
  UseCases({required this.repository});

  Future<List<Hora>> getHores() {
    return repository.getHores();
  }
}
