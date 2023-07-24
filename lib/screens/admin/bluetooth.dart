// import 'dart:async';
// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
//
// class BluetoothScreen extends StatefulWidget {
//   @override
//   _BluetoothScreenState createState() => _BluetoothScreenState();
// }
//
// class _BluetoothScreenState extends State<BluetoothScreen> {
//   // Initializing the Bluetooth connection state to be unknown
//   BluetoothState _bluetoothState = BluetoothState.UNKNOWN;
//
//   late StreamSubscription<BluetoothState> _bluetoothStateSubscription;
//   List<BluetoothDevice> _devicesList = <BluetoothDevice>[];
//   BluetoothDevice? _selectedDevice;
//   bool _isConnected = false;
//   bool _isConnecting = false;
//
//   final _scaffoldKey = GlobalKey<ScaffoldState>();
//   final _pairingTimeout = const Duration(seconds: 30);
//
//   @override
//   void initState() {
//     super.initState();
//     _initBluetooth();
//   }
//
//   @override
//   void dispose() {
//     _disableBluetooth();
//     _bluetoothStateSubscription.cancel();
//     super.dispose();
//   }
//
//   Future<void> _initBluetooth() async {
//     FlutterBluetoothSerial.instance.state.then((state) {
//       setState(() {
//         _bluetoothState = state;
//       });
//     });
//     _bluetoothStateSubscription =
//         FlutterBluetoothSerial.instance.onStateChanged().listen((state) {
//           setState(() {
//             _bluetoothState = state;
//           });
//         });
//     _devicesList = await FlutterBluetoothSerial.instance.getBondedDevices();
//   }
//
//   void _disableBluetooth() async {
//     if (_bluetoothState.isEnabled) {
//       await FlutterBluetoothSerial.instance.requestDisable();
//     }
//   }
//
//   Future<BluetoothConnection> _connectToDevice() async {
//     if (_selectedDevice == null) {
//       _showSnackbar('Please select a device to connect to');
//       // return;
//     }
//     setState(() {
//       _isConnecting = true;
//     });
//     try {
//       BluetoothConnection connection = await BluetoothConnection.toAddress(_selectedDevice?.address)
//       // await FlutterBluetoothSerial.instance
//       //     .connect(_selectedDevice!)
//       //     .timeout(_pairingTimeout);
//       setState(() {
//         _isConnected = true;
//         _isConnecting = false;
//       });
//       _showSnackbar('Connected to ${_selectedDevice!.name}');
//       return connection;
//     } on TimeoutException {
//       setState(() {
//         _isConnecting = false;
//       });
//       _showSnackbar('Connection timed out');
//     } catch (e) {
//       setState(() {
//         _isConnecting = false;
//       });
//       _showSnackbar('Connection failed: ${e.toString()}');
//     }
//   }
//
//   Future<void> _disconnectFromDevice() async {
//     try {
//       await FlutterBluetoothSerial.instance.disconnect();
//       setState(() {
//         _isConnected = false;
//       });
//       _showSnackbar('Disconnected from ${_selectedDevice!.name}');
//     } catch (e) {
//       _showSnackbar('Disconnection failed: ${e.toString()}');
//     }
//   }
//
//   void _openBluetoothSettings() {
//     FlutterBluetoothSerial.instance.openSettings();
//   }
//
//   void _showSnackbar(String message) {
//     ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       key: _scaffoldKey,
//       appBar: AppBar(
//         title: const Text('Bluetooth'),
//         actions: [
//           Switch(
//             value: _bluetoothState.isEnabled,
//             onChanged: (enabled) {
//               if (enabled) {
//                 FlutterBluetoothSerial.instance.requestEnable();
//               } else {
//                 _disableBluetooth();
//               }
//             },
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: EdgeInsets.all(16),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Paired Devices',
//               style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 8),
//             // Row(
//             //   children: [
//             //     ElevatedButton(
//             //       onPressed: _selectedDevice == null
//             //           ? null
//             //           : _isConnected
//             //           ? _disconnectFromDevice
//             //           : _connectToDevice,
//             //       child: _isConnected
//             //           ? Text('Disconnect')
//             //           : _isConnecting
//             //           ? CircularProgressIndicator()
//             //           : Text('Connect'),
//             //     ),
//             //     SizedBox(width: 16),
//             //     Expanded(
//             //       child: DropdownButton<BluetoothDevice>(
//             //         isExpanded: true,
//             //         value: _selectedDevice,
//             //         onChanged: (device) {
//             //           setState(() {
//             //             _selectedDevice = device;
//             //           });
//             //         },
//             //         items: _devicesList
//             //             .map((device) => DropdownMenuItem<BluetoothDevice>(
//             //           value: device,
//             //           child: Text(device.name!),
//             //         ))
//             //             .toList(),
//             //       ),
//             //     ),
//             //   ],
//             // ),
//             Row(
//               children: [
//                 ElevatedButton(
//                   onPressed: _selectedDevice == null
//                       ? null
//                       : _isConnected
//                       ? _disconnectFromDevice
//                       : _connectToDevice,
//                   child: _isConnected
//                       ? const Text('Disconnect')
//                       : _isConnecting
//                       ? Row(
//                     children: [
//                       SizedBox(
//                         height: 16,
//                         width: 16,
//                         child: CircularProgressIndicator(
//                           strokeWidth: 2,
//                           valueColor: AlwaysStoppedAnimation<Color>(
//                               Theme.of(context).textTheme.button!.color!),
//                         ),
//                       ),
//                       const SizedBox(width: 8),
//                       const Text('Connecting'),
//                     ],
//                   )
//                       : const Text('Connect'),
//                 ),
//                 const SizedBox(width: 16),
//                 Expanded(
//                   child: DropdownButton<BluetoothDevice>(
//                     isExpanded: true,
//                     value: _selectedDevice,
//                     onChanged: (device) {
//                       setState(() {
//                         _selectedDevice = device;
//                       });
//                     },
//                     items: _devicesList
//                         .map((device) => DropdownMenuItem<BluetoothDevice>(
//                       value: device,
//                       child: Text(device.name!),
//                     ))
//                         .toList(),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 8),
//             ElevatedButton(
//               onPressed: _openBluetoothSettings,
//               child: const Text('Bluetooth Settings'),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'admin_home.dart';

class BluetoothScreen extends StatelessWidget {
  Future<BluetoothConnection> _connectToDevice() async {
    try {
      // Get a list of available Bluetooth devices
      List<BluetoothDevice> devices = await FlutterBluetoothSerial.instance.getBondedDevices();

      // Find the device you want to connect to
      BluetoothDevice device = devices.firstWhere((device) => device.name == "HC-05");

      // Establish a Bluetooth connection with the device
      BluetoothConnection connection = await BluetoothConnection.toAddress(device.address);

      // Return the connection object
      return connection;
    } catch (e) {
      // Handle errors here
      throw e;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Bluetooth Screen"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            BluetoothConnection connection = await _connectToDevice();
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CourseScreen(connection: connection)),
            );
          },
          child: Text("Connect to device"),
        ),
      ),
    );
  }
}