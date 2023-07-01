import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class BluetoothApp extends StatefulWidget {
  const BluetoothApp({super.key});

  @override
  _BluetoothAppState createState() => _BluetoothAppState();
}

class _BluetoothAppState extends State<BluetoothApp> {
  // Initializing the Bluetooth connection state to be unknown
  BluetoothState _bluetoothState = BluetoothState.UNKNOWN;

  // Get the instance of the Bluetooth
  final FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;

  // Track the Bluetooth connection with the remote device
  late BluetoothConnection connection;

  // To track whether the device is still connected to bluetooth
  bool get isConnected => connection.isConnected;

  // This member variable will be used for tracking
  // the Bluetooth device connection state
  late int _deviceState;

  // This member variable for storing
  // the current device connectivity status
  bool _connected = false;

  bool _isButtonUnavailable = false;

  // This variable is for storing
  // each device from the dropdown items
  BluetoothDevice? _device;

  Map<String, Color> colors = {
    'onBorderColor': Colors.green,
    'offBorderColor': Colors.red,
    'neutralBorderColor': Colors.transparent,
    'onTextColor': Colors.green,
    'offTextColor': Colors.red,
    'neutralTextColor': Colors.blue,
  };

  @override
  void initState() {
    super.initState();

    // Get current state
    FlutterBluetoothSerial.instance.state.then((state) => {
      setState(() {
        _bluetoothState = state;
      })
    });

    _deviceState = 0; // neutral

    // If the Bluetooth of the device is not enabled,
    // then request permission to turn on Bluetooth
    // as the app starts up
    enableBluetooth();

    // Listen for further state changes
    FlutterBluetoothSerial.instance
        .onStateChanged()
        .listen((BluetoothState state) {
      setState(() {
        _bluetoothState = state;
        if (_bluetoothState == BluetoothState.STATE_OFF) {
          _isButtonUnavailable = true;
        }
        // For retrieving the paired devices list
        getPairedDevices();
      });
    });
  }

  @override
  void dispose() {
    if (isConnected) {
      isDisconnecting = true;
      connection.dispose();
      connection = 0 as BluetoothConnection;
    }

    super.dispose();
  }

  // Request Bluetooth permission from the user
  Future<void> enableBluetooth() async {
    // Retrieving the current Bluetooth state
    _bluetoothState = await FlutterBluetoothSerial.instance.state;

    // If the bluetooth is off, then turn it on first
    // and then retrieve the devices that are paired.
    if (_bluetoothState == BluetoothState.STATE_OFF) {
      await FlutterBluetoothSerial.instance.requestEnable();
      await getPairedDevices();
      return;
    } else {
      await getPairedDevices();
    }
    return;
  }

  // Retrieving and storing the paired devices
  // in a list
  Future<void> getPairedDevices() async {
    List<BluetoothDevice> devices = [];

    // To get the list of paired devices
    try {
      devices = await _bluetooth.getBondedDevices();
    } on PlatformException {
      print("Error");
    }

    // It is an error to call [setState] unless [mounted] is true
    if (!mounted) {
      return;
    }

    // Store the [devices] list in the [_devicesList] for accessing
    // the list outside this class
    setState(() {
      _devicesList = devices;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
            title: const Text('Bluetooth Connection',
                style: TextStyle(fontSize: 24)),
            // backgroundColor: Colors.deepPurple,
            actions: [
              TextButton.icon(
                  icon: const Icon(
                    Icons.refresh,
                    color: Colors.white,
                  ),
                  label: const Text("Refresh",
                      style: TextStyle(
                        color: Colors.white,
                      )),
                  // shape: RoundedRectangleBorder(
                  //   borderRadius: BorderRadius.circular(30),
                  // ),
                  // splashColor: Colors.deepPurple,
                  onPressed: () async {
                    // So, that when new devices are paired
                    // while the app is running, user can refresh
                    // the paired devices list.
                    await getPairedDevices().then((_) {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Device list refreshed'),
                      ));
                    });
                  })
            ],
        ),

        body: Container(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: <Widget>[
                Visibility(
                  visible: _isButtonUnavailable &&
                      _bluetoothState == BluetoothState.STATE_ON,
                  child: const LinearProgressIndicator(
                    backgroundColor: Colors.yellow,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.red),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    const Text(
                      'Enable Bluetooth',
                      style: TextStyle(fontSize: 20.0),
                    ),
                    Switch(
                      value: _bluetoothState.isEnabled,
                      onChanged: (bool value) {
                        future() async {
                          if (value) {
                            // Enable Bluetooth
                            await FlutterBluetoothSerial.instance
                                .requestEnable();
                          } else {
                            // Disable Bluetooth
                            await FlutterBluetoothSerial.instance
                                .requestDisable();
                          }

                          // In order to update the devices list
                          await getPairedDevices();
                          _isButtonUnavailable = false;

                          // Disconnect from any device before
                          // turning off Bluetooth
                          if (_connected) {
                            _disconnect();
                          }
                        }

                        future().then((_) {
                          setState(() {});
                        });
                      },
                    )
                  ],
                ),
                const Center(
                  child: Text("PAIRED DEVICES",
                      style: TextStyle(
                          fontSize: 34.0,
                          color: Colors.blue,
                          letterSpacing: 1.0,
                          fontWeight: FontWeight.bold)),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text("Devices:"),
                    DropdownButton(
                      items: _getDeviceItems(),
                      onChanged: (value) =>
                          setState(() => _device = value!),
                      value: _devicesList.isNotEmpty ? _device : null,
                    ),
                    ElevatedButton(
                        onPressed: _isButtonUnavailable
                            ? null
                            : _connected
                            ? _disconnect
                            : _connect,
                        child: Text(_connected ? "Disconnect" : "Connect"))
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Card(
                      shape: RoundedRectangleBorder(
                        side:  BorderSide(
                          color: _deviceState == 0
                              ? Colors.transparent
                              : _deviceState == 1
                              ? Colors.green
                              : Colors.red,
                          width: 3,
                        ),
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      elevation: _deviceState == 0 ? 4 : 0,
                      child: Row(
                        children: <Widget>[
                          Expanded(
                            child: Text(
                              'Device 1',
                              style: TextStyle(
                                fontSize: 20,
                                color: _deviceState == 0
                                    ? colors['neutralTextColor']
                                    : _deviceState == 1
                                    ? colors['onTextColor']
                                    : colors['offTextColor'],
                              ),
                            ),
                          ),
                          TextButton(
                              onPressed: _connected
                                  ? _sendMessageToBluetooth("Turn On")
                                  : null,
                              child: const Text('ON')
                          ),
                          TextButton(
                            onPressed: _connected
                                ? _sendMessageToBluetooth("Turn Off")
                                : null,
                            child: Text('OFF'),
                          ),
                        ],
                      )
                  ),
                ),
                Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          const Text(
                              'NOTE: If you cannot find the device in the list, please pair the device by going to the bluetooth settings',
                              style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.red
                              )
                          ),
                          const SizedBox(height: 15,),
                          ElevatedButton(
                            child: const Text('Bluetooth Settings'),
                            onPressed: () {
                              FlutterBluetoothSerial.instance.openSettings();
                            },
                          ),
                        ],
                      ),
                    )
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Define a new class member variable
  // for storing the devices list
  List<BluetoothDevice> _devicesList = [];

  // Define a member variable to track
  // when the disconnection is in progress
  bool isDisconnecting = false;

  // Create the List of devices to be shown in Dropdown Menu
  List<DropdownMenuItem<BluetoothDevice>> _getDeviceItems() {
    List<DropdownMenuItem<BluetoothDevice>> items = [];
    if (_devicesList.isEmpty) {
      items.add(const DropdownMenuItem(
        child: Text("NONE"),
      ));
    } else {
      for (var device in _devicesList) {
        items.add(DropdownMenuItem(
          value: device,
          child: Text(device.name!),
        ));
      }
    }
    return items;
  }

  // Method to connect to bluetooth
  void _connect() async {
    setState(() {
      _isButtonUnavailable = true;
    });
    if (_device == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('No device selected'),
      ));
    } else {
      // make sure the device is not connected
      if (!isConnected) {
        // Trying to connect to the device using
        // its address
        await BluetoothConnection.toAddress(_device?.address)
            .then((_connection) {
          print('Connected to the device');
          connection = _connection;

          // Updating the device connectivity
          // status to [true]
          setState(() {
            _connected = true;
          });

          // This is for tracking when the disconnecting process
          // is in progress which uses the [isDisconnecting] variable
          // defined before.
          // Whenever we make a disconnection call, this [onDone]
          // method is fired.
          connection.input?.listen(null).onDone(() {
            if (isDisconnecting) {
              print('Disconnecting locallay!');
            } else {
              print('Disconnected remotely!');
            }
            if (mounted) {
              setState(() {});
            }
          });
        }).catchError((error) {
          print('Cannot connect, exception occured');
          print(error);
        });
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Device connected'))
        );
      }
    }
  }

  void _disconnect() async {
    //Closing the Bluetooth connection
    await connection.close();
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Device disconnected'))
    );

    // Update the [_connected] variable
    if (!connection.isConnected) {
      setState(() {
        _connected = false;
        _isButtonUnavailable = false;
      });
    }
  }

  // Method to send message,
  // for turning the Bluetooth device on
  _sendMessageToBluetooth(String message) async {
    if (message.length > 0) {
      try {
        List<int> list = message.codeUnits;
        Uint8List bytes = Uint8List.fromList(list);
        connection.output.add(bytes);
        await connection.output.allSent;
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Message not sent'))
        );
        setState(() {
          _deviceState = 1; // device on
        });
      } catch (e) {
        print(e);
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Message not sent due to error'))
        );
        setState(() {
          _deviceState = 1; // device on
        });
      }
    }
  }

// Method to send message,
// for turning the Bluetooth device off
// void _sendOffMessageToBluetooth() async {
//   connection.output.add(utf8.encode('0' + '\r\n'));
//   await connection.output.allSent;
//   ScaffoldMessenger.of(context).showSnackBar(
//     const SnackBar(content: Text('Device Turned Off'))
//   );
//   setState(() {
//     _deviceState = -1; // device off
//   });
// }
}
