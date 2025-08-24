import 'dart:typed_data';
import 'package:image_downloader_web/image_downloader_web.dart';
import 'package:intl/intl.dart';

Future<void> saveImage(Uint8List bytes) async {
  await WebImageDownloader.downloadImageFromUInt8List(
    uInt8List: bytes,
    name:
    'Trippy Image from ${DateFormat('dd.MM.yyyy kk:mm').format(DateTime.now())}.png',
  );
}