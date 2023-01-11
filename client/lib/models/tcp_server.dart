import 'tcp_socket_connection.dart';

class TcpServer {
  TcpServer({
    required this.port,
    required this.ipAddress,
  });

  late TcpSocketConnection _socket;

  final String port;
  final String ipAddress;

  @override
  String toString() {
    return '$ipAddress:$port';
  }

  bool isConnected() {
    return _socket.isConnected();
  }

  Future<bool> tryConnect() async {
    try {
      _socket = TcpSocketConnection(ipAddress, int.parse(port));
      await _socket.connect(6000, () {});
    } catch (_) {
      return false;
    }
    return _socket.isConnected();
  }

  void closeConnection() {
    _socket.disconnect();
  }

  void trySend(List<int> command) {
    if (_socket.isConnected()) {
      _socket.sendBytes(command);
    }
  }
}
