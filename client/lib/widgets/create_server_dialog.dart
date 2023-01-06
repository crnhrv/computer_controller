import 'package:flutter/material.dart';

import '../models/tcp_server.dart';

class CreateServerDialog extends StatefulWidget {
  final Function(TcpServer server) addServer;
  const CreateServerDialog({Key? key, required this.addServer})
      : super(key: key);

  @override
  State<CreateServerDialog> createState() => _CreateServerDialogState();
}

class _CreateServerDialogState extends State<CreateServerDialog> {
  final ipAddressController = TextEditingController();
  final portController = TextEditingController();
  late TcpServer? _createdServer;
  late String _statusText = "";

  Future<void> _addServer(BuildContext context, Function setState,
      VoidCallback onSuccess, VoidCallback onFailure) async {
    final ip = ipAddressController.text;
    final port = portController.text;

    final tcpServer = TcpServer(port: port, ipAddress: ip);

    final connected = await tcpServer.tryConnect();
    if (connected) {
      _createdServer = tcpServer;
      onSuccess.call();
    } else {
      onFailure.call();
    }
  }

  void _tryAddServer(BuildContext context, Function setState) {
    setState(() {
      _statusText = "Connecting....";
    });

    onFailure() {
      setState(() {
        _statusText = "Failed to connect";
      });
    }

    onSuccess() {
      setState(() {
        widget.addServer(_createdServer!);
        Navigator.of(context).pop();
        _createdServer = null;
      });
    }

    _addServer(context, setState, onSuccess, onFailure);
  }

  @override
  Widget build(BuildContext context) {
    final saveButton = ElevatedButton(
        onPressed: () {
          _tryAddServer(context, setState);
        },
        child: const Text(
          "Save",
          style: TextStyle(fontSize: 18),
        ));

    final ipAddressField = TextField(
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'IP Address',
      ),
      enableSuggestions: true,
      keyboardType: TextInputType.text,
      controller: ipAddressController,
    );

    final portField = TextField(
      decoration: const InputDecoration(
        border: OutlineInputBorder(),
        labelText: 'Port',
      ),
      keyboardType: TextInputType.number,
      controller: portController,
    );

    return AlertDialog(
        title: const Text('Add a new server'),
        content: Container(
          height: 150.0,
          width: 300.0,
          constraints:
          const BoxConstraints(minWidth: 0, maxWidth: 300, maxHeight: 300),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ipAddressField,
                portField,
              ]), //Column
        ), //Container
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          Container(
            padding: const EdgeInsets.fromLTRB(20, 0, 0, 0),
            child: Text(_statusText),
          ),
          saveButton
        ]);
  }
}