import 'dart:async';
import 'dart:io';
import 'dart:convert';

class TcpSocketConnection {
  late String _ipAddress;
  late int _portAddress;
  Socket? _server;
  bool _connected = false;

  TcpSocketConnection(String ip, int port) {
    _ipAddress = ip;
    _portAddress = port;
  }

  connect(int timeOut, Function callback, {int attempts = 1}) async {
    int k = 1;
    while (k <= attempts) {
      try {
        _server = await Socket.connect(_ipAddress, _portAddress,
            timeout: Duration(milliseconds: timeOut));
        break;
      } catch (ex) {
        if (k == attempts) {
          return;
        }
      }
      k++;
    }
    _connected = true;
    _server!.listen((List<int> event) async {
      String received = (utf8.decode(event));
      callback(received);
    }, onError: (Object error) {
      _connected = false;
    }, onDone: () {
      _connected = false;
    });
  }

  void disconnect() {
    if (_server != null) {
      try {
        _server!.close();
      } catch (_) {}
    }
    _connected = false;
  }

  bool isConnected() {
    return _connected;
  }

  void sendBytes(List<int> message) async {
    if (_server != null && _connected) {
      _server!.add(message);
    }
  }

  Future<bool> canConnect(int timeOut, {int attempts = 1}) async {
    int k = 1;
    while (k <= attempts) {
      try {
        _server = await Socket.connect(_ipAddress, _portAddress,
            timeout: Duration(milliseconds: timeOut));
        disconnect();
        return true;
      } catch (exception) {
        if (k == attempts) {
          disconnect();
          return false;
        }
      }
      k++;
    }
    disconnect();
    return false;
  }
}
