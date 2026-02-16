package com.fincore

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.TimeZone

class MainActivity: FlutterActivity() {
    // 定义通讯频道名称，要和 Dart 端保持一致
    private val CHANNEL = "com.fincore/timezone"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getLocalTimezone") {
                // 🔴 核心逻辑：用原生 Java 代码获取时区 ID
                val timeZoneId = TimeZone.getDefault().id
                result.success(timeZoneId)
            } else {
                result.notImplemented()
            }
        }
    }
}
