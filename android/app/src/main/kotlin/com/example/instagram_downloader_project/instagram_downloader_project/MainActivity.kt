package com.example.instagram_downloader_project.instagram_downloader_project

import android.content.Intent
import android.os.Bundle
import android.os.Handler
import android.os.Looper
import android.util.Log
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import kotlinx.coroutines.*

class MainActivity : FlutterActivity() {
    private val CHANNEL = "app.channel.shared.data"
    private val TAG = "MainActivity"
    private var sharedText: String? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Log.d(TAG, "onCreate called")
        Log.e("FlutterReleaseLog", "🔧 Native log test in onCreate") // ✅ Add this line


        handleIntent(intent)
    }

    override fun configureFlutterEngine(flutterEngine: io.flutter.embedding.engine.FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "app.channel.log")
            .setMethodCallHandler { call, _ ->
                if (call.method == "log") {
                    val message = call.argument<String>("message")
                    Log.e("FlutterReleaseLog", message ?: "")
                }
            }
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        Log.d(TAG, "onNewIntent called with intent: $intent")
        setIntent(intent)
        handleIntent(intent)
    }

    private fun handleIntent(intent: Intent?) {
        sharedText = intent?.getStringExtra(Intent.EXTRA_TEXT)
        Log.d(TAG, "handleIntent: sharedText=$sharedText")

        if (!sharedText.isNullOrEmpty()) {
            Handler(Looper.getMainLooper()).postDelayed({
                if (flutterEngine != null) {
                    Log.d(TAG, "Invoking MethodChannel with sharedText: $sharedText")
                    MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL)
                        .invokeMethod("getSharedText", sharedText, object : MethodChannel.Result {
                            override fun success(result: Any?) {
                                Log.d(TAG, "MethodChannel invoke success: result=$result")
                            }

                            override fun error(errorCode: String, errorMessage: String?, errorDetails: Any?) {
                                Log.e(TAG, "MethodChannel invoke error: code=$errorCode, message=$errorMessage, details=$errorDetails")
                            }

                            override fun notImplemented() {
                                Log.e(TAG, "MethodChannel invoke not implemented")
                            }
                        })
                } else {
                    Log.e(TAG, "flutterEngine is null, cannot invoke MethodChannel")
                }
            }, 100)
        } else {
            Log.d(TAG, "No shared text in intent")
        }
    }
}
