import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:scan/scan.dart';

import 'qr_page.dart';
import 'qr_code_content.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'RMYC Wifi',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  final ImagePicker _picker = ImagePicker();
  final ScanController controller = ScanController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("RMYC Wifi"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
              onPressed: () {
                Get.changeThemeMode(Get.isDarkMode ? ThemeMode.light : ThemeMode.dark);
              },
              icon: const Icon(Icons.settings_brightness))
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: ScanView(
              controller: controller,
              scanAreaScale: 0.9,
              scanLineColor: Colors.blue,
              onCapture: (data) async {
                if (tryDecode(data)) {
                  controller.pause();
                  await Get.to(() => const QRPage(), arguments: data);
                  controller.resume();
                } else {
                  Fluttertoast.showToast(msg: "Invalid QR code");
                  controller.resume();
                }
              },
            ),
          ),
          Positioned(
            bottom: 30,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // FloatingActionButton(
                //   heroTag: "btn1",
                //   onPressed: () => controller?.flipCamera(),
                //   child: const Icon(Icons.cameraswitch),
                // ),
                FloatingActionButton(
                  heroTag: "btn2",
                  onPressed: () => controller.toggleTorchMode(),
                  child: const Icon(Icons.flash_on),
                ),
                FloatingActionButton(
                  heroTag: "btn3",
                  onPressed: () {
                    controller.pause();
                    _picker.pickImage(source: ImageSource.gallery).then((value) async {
                      if (value == null) {
                        controller.resume();
                        return;
                      }
                      String? result = await Scan.parse(value.path);
                      if (result == null) {
                        Fluttertoast.showToast(msg: "Cannot find QR code in the image");
                        controller.resume();
                        return;
                      }
                      if (!tryDecode(result)) {
                        await Fluttertoast.showToast(msg: "Invalid QR code");
                        controller.resume();
                        return;
                      }
                      await Get.to(() => const QRPage(), arguments: result);
                      controller.resume();
                    });
                  },
                  child: const Icon(Icons.photo_library),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
