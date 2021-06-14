//------------------------------------------------------------------------------
// ESDEVENIMENTS
//------------------------------------------------------------------------------
import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class InternetConnectionBlocEventChanged {
  final ConnectivityResult connectivityResult;
  InternetConnectionBlocEventChanged(this.connectivityResult);
}

//------------------------------------------------------------------------------
// ESTAT
//------------------------------------------------------------------------------

enum ConnectionType { wifi, mobile }

abstract class InternetConnectionBlocState {
  const factory InternetConnectionBlocState.loading() = InternetConnectionBlocState_loading;
  const factory InternetConnectionBlocState.connected(ConnectionType connectionType) =
      InternetConnectionBlocState_connected;
  const factory InternetConnectionBlocState.disconnected() = InternetConnectionBlocState_disconnected;
}

class InternetConnectionBlocState_loading implements InternetConnectionBlocState {
  const InternetConnectionBlocState_loading();
}

class InternetConnectionBlocState_connected implements InternetConnectionBlocState {
  final ConnectionType connectionType;
  const InternetConnectionBlocState_connected(this.connectionType);
}

class InternetConnectionBlocState_disconnected implements InternetConnectionBlocState {
  const InternetConnectionBlocState_disconnected();
}

//-----------------------------------------------------------------------------
// InternetConnection BLOC
//-----------------------------------------------------------------------------
class InternetConnectionBloc extends Bloc<InternetConnectionBlocEventChanged, InternetConnectionBlocState> {
  final Connectivity connectivity;
  late StreamSubscription _connectivityStreamSubscription;
  InternetConnectionBloc(this.connectivity) : super(InternetConnectionBlocState_loading()) {
    _connectivityStreamSubscription = connectivity.onConnectivityChanged.listen((connectivityResult) {
      print('===================================================');
      add(InternetConnectionBlocEventChanged(connectivityResult));
    });
  }

  @override
  Stream<InternetConnectionBlocState> mapEventToState(InternetConnectionBlocEventChanged event) async* {
    if (event is InternetConnectionBlocEventChanged) {
      if (event.connectivityResult == ConnectivityResult.wifi) {
        yield InternetConnectionBlocState_connected(ConnectionType.wifi);
      } else if (event.connectivityResult == ConnectivityResult.mobile) {
        yield InternetConnectionBlocState_connected(ConnectionType.mobile);
      } else if (event.connectivityResult == ConnectivityResult.none) {
        yield InternetConnectionBlocState_disconnected();
      }
    }
  }

  @override
  Future<void> close() {
    _connectivityStreamSubscription.cancel();
    return super.close();
  }
}
