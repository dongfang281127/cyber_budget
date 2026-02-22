package com.fincore

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.TimeZone

class MainActivity: FlutterActivity() {
    private val TZ_CHANNEL = "com.fincore/timezone"
    private val QA_CHANNEL = "com.fincore/quick_add"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // 1. 保留你之前的时区功能
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, TZ_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getLocalTimezone") {
                result.success(TimeZone.getDefault().id)
            } else {
                result.notImplemented()
            }
        }

        // 2. 快捷记账 (冷启动：App彻底关闭时被唤醒)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, QA_CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "checkQuickAdd") {
                val isQuickAdd = intent?.getBooleanExtra("quick_add", false) ?: false
                intent?.removeExtra("quick_add") // 用完即焚，防止重复弹窗
                result.success(isQuickAdd)
            } else {
                result.notImplemented()
            }
        }
    }

    // 3. 快捷记账 (热启动：App在后台时被唤醒)
    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)
        if (intent.getBooleanExtra("quick_add", false)) {
            flutterEngine?.dartExecutor?.binaryMessenger?.let {
                // 直接向 Flutter 发送弹窗指令
                MethodChannel(it, QA_CHANNEL).invokeMethod("triggerQuickAdd", null)
            }
            intent.removeExtra("quick_add")
        }
    }
}