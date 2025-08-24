import 'dart:io';
import 'dart:typed_data';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

Future<void> saveImage(Uint8List bytes) async {
  final directory = await getApplicationDocumentsDirectory();
  final file = File(
    '${directory.path}/drawing_${DateTime.now().millisecondsSinceEpoch}.png',
  );
  await file.writeAsBytes(bytes);
  print('Saved to ${file.path}');

  final params = ShareParams(
    text:
    'Trippy Image from ${DateFormat('dd.MM.yyyy kk:mm').format(DateTime.now())}',
    files: [XFile(file.path)],
  );

  final result = await SharePlus.instance.share(params);

  if (result.status == ShareResultStatus.success) {
    print('Thank you for sharing the picture!');
  } else if (result.status == ShareResultStatus.dismissed) {
    print('Sharing was dismissed');
  } else {
    print('Sharing went wrong');
  }
}