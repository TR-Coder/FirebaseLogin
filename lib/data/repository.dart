import 'package:firebase_login/data/models.dart';
import 'package:firebase_login/domain/entities.dart';
import 'package:firebase_login/domain/i_repository.dart';
import 'package:firebase_login/data/remote_data_sources/firebase_repository.dart';

class Repository implements IRepository {
  FireBaseRepository firebaseRepository;
  Repository({required this.firebaseRepository});

  @override
  Future<List<Hora>> getHores() async {
    List<HoraModel> listHoraModel = await firebaseRepository.GetHoresFirebase();
    //return listHoraModel.map((h)=>Hora.fromHoraModel(h)).toList();
    return listHoraModel.map(Hora.fromHoraModel).toList();
  }
}
