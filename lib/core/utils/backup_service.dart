import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:file_picker/file_picker.dart';
import 'package:file_saver/file_saver.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart'; // 🔴 必须引入这个
import 'package:permission_handler/permission_handler.dart';
import '../../models/transaction_model.dart';
import '../../models/savings_goal_model.dart';

class BackupService {

  // 固定文件名 (保证每次覆盖)
  static const String _fixedFileName = "FinCore_Data.json";

  // 1. 导出数据 (Export) - 静默覆盖版
  static Future<String?> exportData() async {
    try {
      // A. 准备数据
      final txBox = await Hive.openBox<Transaction>('transactions');
      final vaultBox = await Hive.openBox<SavingsGoal>('vault_goals');

      final List<Transaction> txList = txBox.values.toList();
      final List<SavingsGoal> goalList = vaultBox.values.toList();

      if (txList.isEmpty && goalList.isEmpty) return "NO_DATA";

      // 组装 JSON
      final Map<String, dynamic> backupData = {
        'version': 2,
        'timestamp': DateTime.now().toIso8601String(),
        'transactions': txList.map((e) => e.toMap()).toList(),
        'vault': goalList.map((e) => e.toMap()).toList(),
      };
      String jsonString = jsonEncode(backupData);
      Uint8List fileBytes = Uint8List.fromList(utf8.encode(jsonString));

      // B. 执行保存
      if (kIsWeb) {
        // Web 还是得下载，没法静默写入用户硬盘
        await FileSaver.instance.saveFile(
          name: "CyberBudget_WebBackup", // Web端还是改个名吧
          bytes: fileBytes,
          ext: 'json',
          mimeType: MimeType.json,
        );
        return "DOWNLOAD_STARTED";
      } else {
        // 🔴 Android/iOS 核心修改：直接存入 App 专属文件夹，不弹窗

        // 1. 获取路径: /storage/emulated/0/Android/data/com.xxx/files/
        // 这种路径不需要任何权限即可读写
        Directory? directory;
        if (Platform.isAndroid) {
          directory = await getExternalStorageDirectory();
        } else if (Platform.isIOS) {
          directory = await getApplicationDocumentsDirectory();
        }

        if (directory == null) return "DIR_ERROR";

        // 2. 拼接固定路径
        final File file = File('${directory.path}/$_fixedFileName');

        // 3. 写入 (默认模式就是覆盖 WriteMode.write)
        await file.writeAsBytes(fileBytes);

        return file.path; // 返回绝对路径给 UI 显示
      }
    } catch (e) {
      return "ERROR: $e";
    }
  }

  // 2. 导入数据 (Import) - 依旧保留手动选择，方便你把文件拷来拷去
  static Future<String?> importData() async {
    try {
      // Android 13+ 有些选文件操作不需要权限，但保险起见还是检查一下
      // 注意：如果是从 App 自己的文件夹选，其实也不要权限，但 FilePicker 比较通用
      if (!kIsWeb && await Permission.storage.request().isDenied) {
        // 如果被拒了，还是尝试继续，因为 System Picker 可能不需要权限
      }

      // A. 选文件
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: true,
      );

      if (result == null) return null;

      String jsonString;
      if (kIsWeb) {
        Uint8List? bytes = result.files.first.bytes;
        if (bytes == null) return "READ_ERROR";
        jsonString = utf8.decode(bytes);
      } else {
        File file = File(result.files.single.path!);
        jsonString = await file.readAsString();
      }

      // B. 解析 JSON
      dynamic decodedData = jsonDecode(jsonString);

      // C. 写入数据库 (保持原有逻辑)
      final txBox = await Hive.openBox<Transaction>('transactions');
      final vaultBox = await Hive.openBox<SavingsGoal>('vault_goals');

      // 兼容旧版本 (List) 和新版本 (Map)
      if (decodedData is List) {
        await txBox.clear();
        List<Transaction> newTransactions = (decodedData)
            .map((item) => Transaction.fromMap(item))
            .toList();
        await txBox.addAll(newTransactions);
      } else if (decodedData is Map<String, dynamic>) {
        if (decodedData.containsKey('transactions')) {
          await txBox.clear();
          List<dynamic> txJsonList = decodedData['transactions'];
          await txBox.addAll(txJsonList.map((item) => Transaction.fromMap(item)));
        }
        if (decodedData.containsKey('vault')) {
          await vaultBox.clear();
          List<dynamic> vaultJsonList = decodedData['vault'];
          await vaultBox.addAll(vaultJsonList.map((item) => SavingsGoal.fromMap(item)));
        }
      } else {
        return "INVALID_FORMAT";
      }

      return "SUCCESS";
    } catch (e) {
      return "ERROR: ${e.toString()}";
    }
  }
}