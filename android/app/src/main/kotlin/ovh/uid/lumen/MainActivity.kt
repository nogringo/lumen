package ovh.uid.lumen

import android.content.Intent
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var pendingScan: MethodChannel.Result? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "lumen/scanner")
            .setMethodCallHandler { call, result ->
                if (call.method != "scan") return@setMethodCallHandler result.notImplemented()
                if (pendingScan != null) return@setMethodCallHandler result.success(null)
                pendingScan = result
                @Suppress("UNCHECKED_CAST")
                val strings = call.arguments as? Map<String, String> ?: emptyMap()
                startActivityForResult(ScannerActivity.intent(this, strings), SCAN_REQUEST)
            }
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "lumen/screen")
            .setMethodCallHandler { call, result ->
                if (call.method != "setPrivate") return@setMethodCallHandler result.notImplemented()
                val flag = WindowManager.LayoutParams.FLAG_SECURE
                if (call.arguments == true) window.addFlags(flag) else window.clearFlags(flag)
                result.success(null)
            }
    }

    @Deprecated("Deprecated in Java")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (requestCode != SCAN_REQUEST) return super.onActivityResult(requestCode, resultCode, data)
        val text = if (resultCode == RESULT_OK) data?.getStringExtra(ScannerActivity.EXTRA_TEXT) else null
        pendingScan?.success(text)
        pendingScan = null
    }

    private companion object {
        const val SCAN_REQUEST = 7301
    }
}
