import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:windows_controller/widgets/create_server_dialog.dart';
import 'package:windows_controller/widgets/keyboard_control.dart';
import 'package:windows_controller/widgets/mouse_control.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/control_modes.dart';
import '../models/tcp_server.dart';

class WindowsController extends StatefulWidget {
  const WindowsController({super.key});

  @override
  State<WindowsController> createState() => _WindowsControllerState();
}

class _WindowsControllerState extends State<WindowsController>
    with WidgetsBindingObserver {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  TcpServer? _selectedServer;
  late Future<List<String>> _tcpServerMetaData;
  late Future<int> _selectedServerIndex;
  late ControlModes _controlMode = ControlModes.keyboard;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _selectedServerIndex = _prefs.then((SharedPreferences prefs) {
      return prefs.getInt('selectedServerIndex') ?? -1;
    });

    _tcpServerMetaData = _prefs.then((SharedPreferences prefs) {
      return prefs.getStringList('tcpServers') ?? [];
    });

    _setSelectedServer(_selectedServerIndex);

    onOpen();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) onOpen();
  }

  void onOpen() async {
    if (_selectedServer != null) {
      if (!await _selectedServer!.tryConnect()) {
        _selectedServer = null;
      }
    }
  }

  Future<void> addServer(TcpServer server) async {
    final SharedPreferences prefs = await _prefs;
    List<String> tcpServers = await _tcpServerMetaData;
    tcpServers.add("${server.ipAddress}:${server.port}");

    setState(() {
      {
        _tcpServerMetaData =
            prefs.setStringList('tcpServers', tcpServers).then((bool success) {
          return tcpServers;
        });
      }
    });

    final int selectedServerIndex = await _selectedServerIndex;
    if (selectedServerIndex == -1) {
      _setSelectedServer(Future<int>(() => 0));
    }
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
          child: FutureBuilder<List<Widget>>(
              future: _buildServerMenu(),
              builder:
                  (BuildContext context, AsyncSnapshot<List<Widget>> snapshot) {
                switch (snapshot.connectionState) {
                  case ConnectionState.waiting:
                    return const CircularProgressIndicator();
                  default:
                    if (snapshot.hasError) {
                      return Text('Error: ${snapshot.error}');
                    } else {
                      return ListView(
                        padding: EdgeInsets.zero,
                        children: snapshot.data!,
                      );
                    }
                }
              }),
        ),
        appBar: AppBar(title: const Text("Windows Controller")),
        bottomNavigationBar: _getBottomNavigationBar(),
        body: _getBody());
  }

  void _toggleConnected(int index) async {
    final SharedPreferences prefs = await _prefs;
    final selectedServerIndex = await _selectedServerIndex;

    if (selectedServerIndex == index) {
      setState(() {
        _selectedServer?.closeConnection();
        _selectedServer = null;
        _selectedServerIndex =
            prefs.setInt('selectedServerIndex', -1).then((bool success) {
          return -1;
        });
      });
    } else {
      _setSelectedServer(Future<int>(() => index));
    }
  }

  Future<List<Widget>> _buildServerMenu() async {
    final tcpServerMetaData = await _tcpServerMetaData;
    final selectedServerIndex = await _selectedServerIndex;


    List<Widget> menu = List<Widget>.generate(
        tcpServerMetaData.length,
        (index) => ListTile(
              leading: TextButton(
                  child: Text(tcpServerMetaData[index],
                      style: TextStyle(
                          fontSize: 16,
                          color: index == selectedServerIndex
                              ? Colors.orangeAccent
                              : Colors.white)),
                  onPressed: () {
                    _toggleConnected(index);
                  }),
              trailing: IconButton(
                  onPressed: () {
                    _removeServer(index);
                  },
                  icon: const Icon(Icons.close_outlined)),
            ));

    final menuTitle = Text(
      await _getTitleText(),
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
  }

  String _getModeText() {
    return _controlMode == ControlModes.keyboard
        ? "Mouse Mode"
        : "Keyboard Mode";
  }

  void _showAddServerDialog() {
    showDialog(
        context: context,
        builder: (context) => StatefulBuilder(builder: (context, setState) {
              return CreateServerDialog(addServer: addServer);
            }));
  }

  Future<String> _getTitleText() async {
    final tcpServers = await _tcpServerMetaData;

    return tcpServers.isEmpty
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

  Future<void> _setSelectedServer(Future<int> possibleIndex) async {
    final index = await possibleIndex;
    if (index == -1) {
      return;
    }

    final metadata = await _tcpServerMetaData;
    if (metadata.isEmpty) {
      return;
    }

    final serverData = metadata[index].split(":");
    final ip = serverData.first;
    final port = serverData.last;
    final tcpServer = TcpServer(port: port, ipAddress: ip);

    final SharedPreferences prefs = await _prefs;
    if (await tcpServer.tryConnect()) {
      setState(() {
        _selectedServer = tcpServer;

        _selectedServerIndex =
            prefs.setInt('selectedServerIndex', index).then((bool success) {
          return index;
        });
      });
    }
  }

  Future<void> _removeServer(int index) async {
    final SharedPreferences prefs = await _prefs;
    final tcpServers = prefs.getStringList('tcpServers') ?? [];
    final selectedServerIndex = prefs.getInt('selectedServerIndex');
    tcpServers.removeAt(index);

    setState(() {
      _tcpServerMetaData =
          prefs.setStringList('tcpServers', tcpServers).then((bool success) {
        return tcpServers;
      });
    });

    if (selectedServerIndex == index) {
      setState(() {
        _selectedServer = null;
        _selectedServerIndex =
            prefs.setInt('selectedServerIndex', -1).then((bool success) {
          return -1;
        });
      });
    }
  }
}
