import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:get/get.dart';
import 'qr_code_content.dart';

class QRPage extends StatelessWidget {
  const QRPage({super.key});

  @override
  Widget build(BuildContext context) {
    final data = Get.arguments.toString();

    final context = decodeContent(data);

    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code'),
      ),
      body: Column(
        // mainAxisAlignment: MainAxisAlignment.center,
        children: [
          QrImageView(
            data: data,
            version: 3,
            padding: const EdgeInsets.all(5),
            // size: 400,
            backgroundColor: Colors.white,
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
                ElevatedButton(
                  onPressed: () {
                    Get.back();
                  },
                  child: const Text('Back'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
