// =============================================================
// Copiat de https://pub.dev/packages/data_connection_checker
// =============================================================
// Exemple d'ús:
//
// Simple check to see if we have internet:
//   print(await DataConnectionChecker().hasConnection);
//
// Actively listen for status updates:
//   var listener = InternetConnectionChecker().onStatusChange.listen((status) {
//     switch (status) {
//       case DataConnectionStatus.connected:
//         print('Data connection is available.');
//         break;
//       case DataConnectionStatus.disconnected:
//         print('You are disconnected from the internet.');
//         break;
//     }
//   });
//

import 'dart:io';
import 'dart:async';

enum InternetConnectionStatus { disconnected, connected }

// =====================================================================================================================
// =====================================================================================================================
class InternetConnectionChecker {
  static const int DNS_PORT = 53;
  static const SECONDS_INTERVAL = 10;
  static const Duration PING_TIMEOUT = Duration(seconds: 10); // segons per a considerar una adreça inabastable
  static Duration CHECK_INTERVAL =
      Duration(seconds: SECONDS_INTERVAL); // interval entre verificacions automàtiques de connexió
  static final InternetConnectionChecker _singletonInstance = InternetConnectionChecker._();

  // Constructor
  factory InternetConnectionChecker({int secondsInterval = SECONDS_INTERVAL}) {
    if (secondsInterval > 0) {
      InternetConnectionChecker.CHECK_INTERVAL = Duration(seconds: secondsInterval);
      _singletonInstance._emitStatusUpdate();
    }
    return _singletonInstance; // singleton
  }

  InternetConnectionStatus? _lastStatus;
  Timer? _timer;

  StreamController<InternetConnectionStatus> _statusController = StreamController.broadcast();
  Stream<InternetConnectionStatus> get onStatusChange => _statusController.stream;

  //-----------------------------
  InternetConnectionChecker._() {
    _statusController.onListen = () {
      _emitStatusUpdate();
    };

    _statusController.onCancel = () {
      _timer?.cancel();
      _lastStatus = null;
    };
  }

  /* --------------------------------------------------------
    CloudFlare, https://1.1.1.1
    Google, https://developers.google.com/speed/public-dns/
    OpenDNS, https://use.opendns.com/
   -------------------------------------------------------- */
  List<Address> testAddresses = List.of([
    Address(ip: InternetAddress('1.1.1.1'), port: DNS_PORT, timeout: PING_TIMEOUT),
    Address(ip: InternetAddress('8.8.4.4'), port: DNS_PORT, timeout: PING_TIMEOUT),
    Address(ip: InternetAddress('208.67.222.222'), port: DNS_PORT, timeout: PING_TIMEOUT),
  ]);

  // Ping a single address
  Future<bool> _isHostReachable(Address address) async {
    Socket? socket;
    try {
      socket = await Socket.connect(address.ip, address.port, timeout: address.timeout);
      socket.destroy();
      return true;
    } catch (e) {
      if (socket != null) socket.destroy();
      return false;
    }
  }

  // -----------------------------------
  // Fem un ping per cada ip en addresses. Considerem que tenim connexió a Internet si al menys una de les
  // connexions es true;
  Future<bool> get hasConnection async {
    List<Future<bool>> listFutureResponses = [];

    for (var address in testAddresses) {
      listFutureResponses.add(_isHostReachable(address));
    }

    // Nota: Future.wait waits for multiple futures to complete and collects their results.
    List<bool> _hostsReachables = List.of(await Future.wait(listFutureResponses));
    return _hostsReachables.contains(true);
  }

  // ------------------------
  _emitStatusUpdate() async {
    _timer?.cancel();
    if (!_statusController.hasListener) return;
    var currentStatus =
        await hasConnection ? InternetConnectionStatus.connected : InternetConnectionStatus.disconnected;

    if (_lastStatus != currentStatus) {
      _statusController.add(currentStatus);
    }

    if (CHECK_INTERVAL.inSeconds > 0) {
      _timer = Timer(CHECK_INTERVAL, _emitStatusUpdate);
    }
    _lastStatus = currentStatus;
  }
}

// =====================================================================================================================
// =====================================================================================================================
class Address {
  final InternetAddress ip;
  final int port;
  final Duration timeout;
  Address({required this.ip, required this.port, required this.timeout});
}
