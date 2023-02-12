import 'tcp_socket_connection.dart';

class TcpServer {
  TcpServer({
    required this.port,
    required this.ipAddress,
  });

  static final Finalizer<TcpSocketConnection> _finalizer =
  Finalizer((connection) => connection.disconnect());

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
      _finalizer.attach(this, _socket, detach: this);
      await _socket.connect(6000, () {});
    } catch (_) {
      return false;
    }
    return _socket.isConnected();
  }

  void closeConnection() {
    _socket.disconnect();
    _finalizer.detach(this);
  }

  Future<void> trySend(List<int> command) async {
    if (_socket.isConnected()) {
      _socket.sendBytes(command);
    } else if (await tryConnect()) {
      _socket.sendBytes(command);
    }
  }
}
