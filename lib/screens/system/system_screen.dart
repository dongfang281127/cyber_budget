import 'package:flutter/material.dart';

// 引入拆分出来的积木组件
import 'widgets/system_header.dart';
import 'widgets/interface_settings_card.dart';
import 'widgets/notification_settings_card.dart';
import 'widgets/data_management_section.dart';
// 🔴 1. 引入新组件
import 'widgets/version_info_card.dart';

class SystemScreen extends StatelessWidget {
  const SystemScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: const [
            SystemHeader(),
            SizedBox(height: 30),

            InterfaceSettingsCard(),
            SizedBox(height: 20),

            NotificationSettingsCard(),
            SizedBox(height: 20),

            DataManagementSection(),
            SizedBox(height: 20), // 留出一点间距

            // 🔴 2. 把它放在最下面
            VersionInfoCard(),

            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}