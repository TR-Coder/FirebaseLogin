import 'dart:async';
import 'package:firebase_login/library/internet_connection_checker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

//------------------------------------------------------------------------------
// ESDEVENIMENTS
//------------------------------------------------------------------------------
class InternetConnectionBlocEventChanged {
  final InternetConnectionStatus connectivityResult;
  InternetConnectionBlocEventChanged(this.connectivityResult);
}

//------------------------------------------------------------------------------
// ESTAT
//------------------------------------------------------------------------------
enum InternetConnectionBlocState { disconnected, connected, loading }

//-----------------------------------------------------------------------------
// InternetConnection BLOC
//-----------------------------------------------------------------------------
class InternetConnectionBloc extends Bloc<InternetConnectionBlocEventChanged, InternetConnectionBlocState> {
  late StreamSubscription _connectivityStreamSubscription;
  InternetConnectionBloc() : super(InternetConnectionBlocState.loading) {
    _connectivityStreamSubscription = InternetConnectionChecker().onStatusChange.listen((status) {
      add(InternetConnectionBlocEventChanged(status));
    });
  }

  @override
  Stream<InternetConnectionBlocState> mapEventToState(InternetConnectionBlocEventChanged event) async* {
    if (event is InternetConnectionBlocEventChanged) {
      if (event.connectivityResult == InternetConnectionStatus.connected) {
        yield InternetConnectionBlocState.connected;
      } else if (event.connectivityResult == InternetConnectionStatus.disconnected) {
        yield InternetConnectionBlocState.disconnected;
      }
    }
  }

  @override
  Future<void> close() {
    _connectivityStreamSubscription.cancel();
    return super.close();
  }
}
