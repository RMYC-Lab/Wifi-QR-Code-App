import 'dart:convert';
import 'dart:typed_data';

Uint8List simpleDecrypt(Uint8List data) {
  var array = Uint8List(data.length);
  var b = 7;
  for (var i = 0; i < data.length; i++) {
    array[i] = data[i] ^ b;
    b = ((b + 7) ^ 178) % 256;
  }
  return array;
}

Map<String, dynamic> decodeContent(String msg) {
  // Decrypt the Base64 encoded message
  var decryptedArray = simpleDecrypt(base64Decode(msg));

  // Parse out the lengths and flags of each field
  var header = ByteData.view(decryptedArray.buffer).getUint16(0, Endian.little);
  var ssidLen = header & 63;
  var pwdLen = (header >> 6) & 31;
  var bssidExists = ((header >> 11) & 1) > 0;
  var portExists = ((header >> 12) & 1) > 0;

  // Parse out the AppID
  var appId = ByteData.view(decryptedArray.buffer).getUint64(2, Endian.little);

  // Parse out the CC
  var cc = utf8.decode(decryptedArray.sublist(10, 12));

  // Parse out the SSID and Pwd
  var ssidStart = 12;
  var ssidEnd = ssidStart + ssidLen;
  var ssid = utf8.decode(decryptedArray.sublist(ssidStart, ssidEnd));

  var pwdStart = ssidEnd;
  var pwdEnd = pwdStart + pwdLen;
  var pwd = utf8.decode(decryptedArray.sublist(pwdStart, pwdEnd));

  // If BSSID exists, parse out the BSSID
  String? bssid;
  var bssidStart = pwdEnd;
  var bssidEnd = bssidStart + 6;
  if (bssidExists) {
    bssid = decryptedArray
        .sublist(bssidStart, bssidEnd)
        .map((b) => b.toRadixString(16).padLeft(2, '0'))
        .join(':');
  }

  // If Port exists, parse out the Port
  int? port;
  if (portExists) {
    var portStart = bssidExists ? bssidEnd : pwdEnd;
    port = ByteData.view(decryptedArray.buffer).getUint16(portStart, Endian.little);
  }

  return {
    'appId': appId,
    'cc': cc,
    'ssid': ssid,
    'pwd': pwd,
    'bssid': bssid,
    'port': port,
  };
}

bool tryDecode(String value) {
  try {
    decodeContent(value);
    return true;
  } catch (e) {
    return false;
  }
}
