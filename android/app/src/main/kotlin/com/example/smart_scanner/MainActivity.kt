package com.example.smart_scanner

import android.content.Intent
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CHANNEL_GMAIL,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                METHOD_SHARE_FILE -> {
                    val path = call.argument<String>(ARG_PATH)
                    val mimeType = call.argument<String>(ARG_MIME_TYPE)
                    val subject = call.argument<String>(ARG_SUBJECT) ?: ""
                    val body = call.argument<String>(ARG_BODY) ?: ""

                    if (path.isNullOrBlank() || mimeType.isNullOrBlank()) {
                        result.error(
                            "INVALID_ARGS",
                            "File path and mime type are required.",
                            null,
                        )
                        return@setMethodCallHandler
                    }

                    try {
                        shareWithGmail(path, mimeType, subject, body)
                        result.success(null)
                    } catch (error: Exception) {
                        result.error(
                            "GMAIL_ERROR",
                            error.message,
                            null,
                        )
                    }
                }

                else -> result.notImplemented()
            }
        }
    }

    private fun shareWithGmail(
        filePath: String,
        mimeType: String,
        subject: String,
        body: String,
    ) {
        val file = File(filePath)
        if (!file.exists()) {
            throw IllegalStateException("Attachment file was not found.")
        }

        val uri = FileProvider.getUriForFile(
            this,
            "${applicationContext.packageName}.fileprovider",
            file,
        )

        val intent = Intent(Intent.ACTION_SEND).apply {
            type = mimeType
            setPackage(GMAIL_PACKAGE)
            putExtra(Intent.EXTRA_STREAM, uri)
            putExtra(Intent.EXTRA_SUBJECT, subject)
            putExtra(Intent.EXTRA_TEXT, body)
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }

        startActivity(intent)
    }

    companion object {
        private const val CHANNEL_GMAIL = "com.example.smart_scanner/gmail"
        private const val METHOD_SHARE_FILE = "shareFile"
        private const val ARG_PATH = "path"
        private const val ARG_MIME_TYPE = "mimeType"
        private const val ARG_SUBJECT = "subject"
        private const val ARG_BODY = "body"
        private const val GMAIL_PACKAGE = "com.google.android.gm"
    }
}
