import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../providers/app_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: ListView(
        children: [
          _buildSectionTitle('数据管理'),
          ListTile(
            leading: const Icon(Icons.backup),
            title: const Text('导出数据备份'),
            subtitle: const Text('将所有数据导出为JSON文件'),
            onTap: () => _exportData(context),
          ),
          ListTile(
            leading: const Icon(Icons.share),
            title: const Text('分享应用'),
            subtitle: const Text('分享 Dolphin Health 给朋友'),
            onTap: () => _shareApp(context),
          ),
          const Divider(),
          _buildSectionTitle('关于'),
          const ListTile(
            leading: Icon(Icons.info),
            title: Text('版本'),
            subtitle: Text('1.0.0'),
          ),
          const ListTile(
            leading: Icon(Icons.favorite),
            title: Text('开发者'),
            subtitle: Text('饭饭 🍚'),
          ),
          const ListTile(
            leading: Icon(Icons.water),
            title: Text('项目'),
            subtitle: Text('Ocean 系列 🌊'),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }

  Future<void> _exportData(BuildContext context) async {
    try {
      final provider = Provider.of<AppProvider>(context, listen: false);
      
      // 准备导出数据
      final exportData = {
        'exportDate': DateTime.now().toIso8601String(),
        'appName': 'Dolphin Health',
        'version': '1.0.0',
        'data': {
          'transactions': provider.transactions.map((t) => t.toMap()).toList(),
          'weightRecords': provider.weightRecords.map((w) => w.toMap()).toList(),
          'dietRecords': provider.dietRecords.map((d) => d.toMap()).toList(),
          'userHeight': provider.userHeight,
          'goalWeight': provider.goalWeight,
        },
      };

      final jsonString = const JsonEncoder.withIndent('  ').convert(exportData);
      
      // 保存到临时文件
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/dolphin_health_backup.json');
      await file.writeAsString(jsonString);

      // 分享文件
      await Share.shareXFiles(
        [XFile(file.path)],
        subject: 'Dolphin Health 数据备份',
        text: '这是我的 Dolphin Health 数据备份',
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('数据导出成功')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导出失败: $e')),
        );
      }
    }
  }

  void _shareApp(BuildContext context) {
    Share.share(
      '推荐使用 🐬 Dolphin Health 海豚健康管家！\n'
      '一个简洁好用的个人健康管理 APP，支持收支记录、体重追踪和饮食规划。\n'
      'Ocean 系列项目 🌊',
      subject: '分享 Dolphin Health',
    );
  }
}
