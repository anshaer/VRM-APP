import 'dart:io';
import 'package:archive/archive.dart';
import 'package:path_provider/path_provider.dart';

/// 負責把使用者選擇的 .zip（內含 .vrm 檔）解壓縮到 App 私有目錄，
/// 並回傳解壓後 .vrm 檔案的完整路徑，供 WebView 載入使用。
class VrmLoaderService {
  static Future<String> extractVrmFromZip(String zipPath) async {
    final bytes = File(zipPath).readAsBytesSync();
    final archive = ZipDecoder().decodeBytes(bytes);

    final appDir = await getApplicationDocumentsDirectory();
    final extractDir = Directory('${appDir.path}/vrm_models');
    if (!extractDir.existsSync()) {
      extractDir.createSync(recursive: true);
    }

    String? vrmFilePath;

    for (final file in archive) {
      final outPath = '${extractDir.path}/${file.name}';
      if (file.isFile) {
        final outFile = File(outPath);
        await outFile.create(recursive: true);
        await outFile.writeAsBytes(file.content as List<int>);

        if (file.name.toLowerCase().endsWith('.vrm')) {
          vrmFilePath = outPath;
        }
      }
    }

    if (vrmFilePath == null) {
      throw Exception('zip 檔案內找不到 .vrm 模型檔，請確認壓縮包內容');
    }

    return vrmFilePath;
  }
}
