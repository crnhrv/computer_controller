import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:windows_controller/widgets/create_server_dialog.dart';
import 'package:windows_controller/widgets/keyboard_control.dart';
import 'package:windows_controller/widgets/mouse_control.dart';

import '../models/control_modes.dart';
import '../models/tcp_server.dart';

class WindowsController extends StatefulWidget {
  const WindowsController({super.key});

  @override
  State<WindowsController> createState() => _WindowsControllerState();
}

class _WindowsControllerState extends State<WindowsController> {
  TcpServer? _selectedServer;
  final _tcpServers = <TcpServer>[];
  late ControlModes _controlMode = ControlModes.keyboard;

  void addServer(TcpServer server) {
    setState(() {
      _tcpServers.add(server);
      _selectedServer = server;
    });
  }

  void sendKeyCommand(int keyCommand) {
    BytesBuilder bytes = BytesBuilder();
    bytes.addByte(0);
    bytes.add([1, 0, 0, 0]);
    bytes.addByte(keyCommand);
    _selectedServer?.trySend(bytes.toBytes());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: _buildServerMenu(),
          ),
        ),
        appBar: AppBar(title: const Text("Windows Controller")),
        bottomNavigationBar: _getBottomNavigationBar(),
        body: _getBody());
  }

  void _toggleConnected(TcpServer server) async {
    if (_selectedServer == server) {
      server.closeConnection();
      setState(() {
        _selectedServer = null;
      });
    } else {
      if (await server.tryConnect()) {
        setState(() {
          _selectedServer = server;
        });
      }
    }
  }

  List<Widget> _buildServerMenu() {
    List<Widget> menu = List<Widget>.generate(
        _tcpServers.length,
        (index) => ListTile(
              leading: TextButton(
                  child: Text(_tcpServers[index].toString(),
                      style: TextStyle(
                          fontSize: 16,
                          color: _tcpServers[index] == _selectedServer
                              ? Colors.orangeAccent
                              : Colors.white)),
                  onPressed: () => _toggleConnected(_tcpServers[index])),
              trailing: IconButton(
                  onPressed: () => {
                        setState(() {
                          _tcpServers[index].closeConnection();
                          _tcpServers.removeAt(index);
                          _selectedServer = null;
                        })
                      },
                  icon: const Icon(Icons.close_outlined)),
            ));

    final menuTitle = Text(
      _getTitleText(),
      style: const TextStyle(fontSize: 16),
    );

    final header = SizedBox(
        height: 120,
        child: DrawerHeader(
            decoration: const BoxDecoration(color: Colors.deepOrange),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  menuTitle,
                  IconButton(
                    icon: const Icon(Icons.add_circle),
                    onPressed: _showAddServerDialog,
                  )
                ])));

    menu.insert(0, header);
    return menu;
  }

  Widget? _getBottomNavigationBar() {
    return _selectedServer == null
        ? null
        : ButtonBar(
            alignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                  onPressed: _toggleControlMode, child: Text(_getModeText()))
            ],
          );
  }

  void _toggleControlMode() {
    if (_controlMode == ControlModes.mouse) {
      setState(() {
        _controlMode = ControlModes.keyboard;
      });
    } else {
      setState(() {
        _controlMode = ControlModes.mouse;
      });
    }
    ;
  }

  String _getModeText() {
    return _controlMode == ControlModes.keyboard
        ? "Mouse Mode"
        : "Keyboard Mode";
  }

  void _showAddServerDialog() {
    showDialog(
        context: context,
        builder: (context) => StatefulBuilder(
            builder: (context, setState) =>
                CreateServerDialog(addServer: addServer)));
  }

  String _getTitleText() {
    return _tcpServers.isEmpty
        ? "No servers available"
        : _selectedServer == null
            ? "No server selected"
            : 'Connected';
  }

  Widget _getBody() {
    return _selectedServer != null
        ? _getCommandScreen()
        : const Center(
            child: Text("Not connected", style: TextStyle(fontSize: 32)));
  }

  Widget _getCommandScreen() {
    return _controlMode == ControlModes.mouse
        ? const MouseControl()
        : KeyboardControl(sendCommand: sendKeyCommand);
  }
}
