import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:get/get.dart';
import 'qr_code_content.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:wifi_iot/wifi_iot.dart';

class QRPage extends StatelessWidget {
  const QRPage({super.key});

  @override
  Widget build(BuildContext context) {
    final data = Get.arguments.toString();

    final context = decodeContent(data);

    Rx<Matrix4> qrImageTransform = (Matrix4.identity()..scale(1.0, -1.0)).obs;
    bool qrImageTransformed = true;

    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code'),
      ),
      body: Column(
        // mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            child: Obx(
              () => Transform(
                transform: qrImageTransform.value,
                alignment: Alignment.center,
                child: QrImageView(
                  data: data,
                  // version: 3,
                  padding: const EdgeInsets.all(5),
                  // size: 400,
                  backgroundColor: Colors.white,
                ),
              ),
            ),
            onTap: () {
              if (qrImageTransformed) {
                // qrImageTransform = Matrix4.identity()..scale(1.0, -1.0);
                qrImageTransform.value = Matrix4.identity()..scale(1.0, -1.0);
                qrImageTransformed = false;
              } else {
                // qrImageTransform = Matrix4.identity();
                qrImageTransform.value = Matrix4.identity();
                qrImageTransformed = true;
              }
            },
          ),
          const Divider(),
          Container(
            margin: const EdgeInsets.all(16),
            // padding: const EdgeInsets.all(30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Origin Data: $data",
                ),
                Text(
                  "SSID: ${context['ssid']}",
                ),
                Text(
                  "Password: ${context['pwd']}",
                ),
                Text(
                  "BSSID: ${context['bssid']}",
                ),
                Text(
                  "Port: ${context['port']}",
                ),
                Text(
                  "AppID: ${context['appId']}",
                ),
                const SizedBox(
                  height: 20,
                ),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      Get.back();
                    },
                    child: const Text('Back'),
                  ),
                ),
                const SizedBox(
                  height: 14,
                ),
                Center(
                  child: ElevatedButton(
                    onPressed: () async {
                      bool isEnabled = await WiFiForIoTPlugin.isEnabled();
                      if (!isEnabled) {
                        Fluttertoast.showToast(msg: "Please enable WiFi");
                        WiFiForIoTPlugin.setEnabled(true, shouldOpenSettings: true);
                        return;
                      }
                      WiFiForIoTPlugin.findAndConnect(
                        context['ssid'],
                        password: context['pwd'],
                        joinOnce: false,
                        timeoutInSeconds: 15,
                      ).then((value) {
                        if (value) {
                          Fluttertoast.showToast(msg: "Connected to ${context['ssid']}");
                        } else {
                          Fluttertoast.showToast(msg: "Failed to connect to ${context['ssid']}");
                        }
                      });
                    },
                    child: const Text("Connect"),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
