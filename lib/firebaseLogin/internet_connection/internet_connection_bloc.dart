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
  const factory InternetConnectionBlocState.loading() = InternetConnectionBlocState_Loading;
  const factory InternetConnectionBlocState.connected(ConnectionType connectionType) =
      InternetConnectionBlocState_Connected;
  const factory InternetConnectionBlocState.disconnected() = InternetConnectionBlocState_Disconnected;
}

// ignore: camel_case_types
class InternetConnectionBlocState_Loading implements InternetConnectionBlocState {
  const InternetConnectionBlocState_Loading();
}

// ignore: camel_case_types
class InternetConnectionBlocState_Connected implements InternetConnectionBlocState {
  final ConnectionType connectionType;
  const InternetConnectionBlocState_Connected(this.connectionType);
}

// ignore: camel_case_types
class InternetConnectionBlocState_Disconnected implements InternetConnectionBlocState {
  const InternetConnectionBlocState_Disconnected();
}

//-----------------------------------------------------------------------------
// InternetConnection BLOC
//-----------------------------------------------------------------------------
class InternetConnectionBloc extends Bloc<InternetConnectionBlocEventChanged, InternetConnectionBlocState> {
  final Connectivity connectivity;
  late StreamSubscription _connectivityStreamSubscription;
  InternetConnectionBloc(this.connectivity) : super(InternetConnectionBlocState_Loading()) {
    _connectivityStreamSubscription = connectivity.onConnectivityChanged.listen((connectivityResult) {
      add(InternetConnectionBlocEventChanged(connectivityResult));
    });
  }

  @override
  Stream<InternetConnectionBlocState> mapEventToState(InternetConnectionBlocEventChanged event) async* {
    if (event is InternetConnectionBlocEventChanged) {
      if (event.connectivityResult == ConnectivityResult.wifi) {
        yield InternetConnectionBlocState_Connected(ConnectionType.wifi);
      } else if (event.connectivityResult == ConnectivityResult.mobile) {
        yield InternetConnectionBlocState_Connected(ConnectionType.mobile);
      } else if (event.connectivityResult == ConnectivityResult.none) {
        yield InternetConnectionBlocState_Disconnected();
      }
    }
  }

  @override
  Future<void> close() {
    _connectivityStreamSubscription.cancel();
    return super.close();
  }
}
