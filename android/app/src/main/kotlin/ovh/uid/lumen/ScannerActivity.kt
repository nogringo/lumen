package ovh.uid.lumen

import android.Manifest
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.graphics.Color
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import android.util.Size
import android.view.HapticFeedbackConstants
import android.view.View
import android.view.ViewGroup
import android.widget.Button
import android.widget.ImageButton
import android.widget.TextView
import androidx.activity.ComponentActivity
import androidx.activity.SystemBarStyle
import androidx.activity.enableEdgeToEdge
import androidx.activity.result.contract.ActivityResultContracts
import androidx.camera.core.Camera
import androidx.camera.core.CameraSelector
import androidx.camera.core.ImageAnalysis
import androidx.camera.core.ImageProxy
import androidx.camera.core.Preview
import androidx.camera.core.TorchState
import androidx.camera.core.resolutionselector.ResolutionSelector
import androidx.camera.core.resolutionselector.ResolutionStrategy
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.camera.view.PreviewView
import androidx.core.content.ContextCompat
import androidx.core.view.ViewCompat
import androidx.core.view.WindowInsetsCompat
import androidx.core.view.updateLayoutParams
import androidx.core.view.updatePadding
import com.google.zxing.BinaryBitmap
import com.google.zxing.DecodeHintType
import com.google.zxing.LuminanceSource
import com.google.zxing.PlanarYUVLuminanceSource
import com.google.zxing.ReaderException
import com.google.zxing.common.HybridBinarizer
import com.google.zxing.qrcode.QRCodeReader
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors

/** Reads one QR code with the camera and returns its text in [EXTRA_TEXT]. */
class ScannerActivity : ComponentActivity() {
    private lateinit var preview: PreviewView
    private lateinit var torch: ImageButton
    private lateinit var messagePanel: View
    private lateinit var message: TextView
    private lateinit var messageAction: Button

    private lateinit var analysis: ExecutorService
    private var camera: Camera? = null
    private var found = false
    private var waitingForPermission = false

    private val askCamera =
        registerForActivityResult(ActivityResultContracts.RequestPermission()) { granted ->
            if (granted) startCamera() else showCameraNeeded()
        }

    override fun onCreate(savedInstanceState: Bundle?) {
        enableEdgeToEdge(
            statusBarStyle = SystemBarStyle.dark(Color.TRANSPARENT),
            navigationBarStyle = SystemBarStyle.dark(Color.TRANSPARENT),
        )
        super.onCreate(savedInstanceState)
        setContentView(R.layout.activity_scanner)
        analysis = Executors.newSingleThreadExecutor()

        preview = findViewById(R.id.preview)
        torch = findViewById(R.id.torch)
        messagePanel = findViewById(R.id.message_panel)
        message = findViewById(R.id.message)
        messageAction = findViewById(R.id.message_action)

        title = text("title")
        findViewById<TextView>(R.id.title).text = title
        findViewById<TextView>(R.id.hint).text = text("hint")
        findViewById<ImageButton>(R.id.close).apply {
            contentDescription = text("close")
            setOnClickListener { finish() }
        }
        showTorch(on = false)
        torch.setOnClickListener {
            val camera = camera ?: return@setOnClickListener
            camera.cameraControl.enableTorch(camera.cameraInfo.torchState.value != TorchState.ON)
        }
        fitSystemBars()

        when {
            !packageManager.hasSystemFeature(PackageManager.FEATURE_CAMERA_ANY) -> showNoCamera()
            hasCameraPermission() -> startCamera()
            // After a rotation, a pending request still answers askCamera.
            savedInstanceState == null -> askCamera.launch(Manifest.permission.CAMERA)
            else -> showCameraNeeded()
        }
    }

    override fun onResume() {
        super.onResume()
        // Back from the app settings, where the camera may have been allowed.
        if (waitingForPermission && hasCameraPermission()) {
            startCamera()
        }
    }

    override fun onDestroy() {
        super.onDestroy()
        analysis.shutdown()
    }

    private fun text(key: String): String = intent.getStringExtra(key) ?: ""

    private fun hasCameraPermission() =
        ContextCompat.checkSelfPermission(this, Manifest.permission.CAMERA) ==
            PackageManager.PERMISSION_GRANTED

    private fun fitSystemBars() {
        val topBar = findViewById<View>(R.id.top_bar)
        val hint = findViewById<View>(R.id.hint)
        val hintMargin = resources.getDimensionPixelSize(R.dimen.scanner_hint_margin)
        ViewCompat.setOnApplyWindowInsetsListener(findViewById(R.id.root)) { _, insets ->
            val bars = insets.getInsets(
                WindowInsetsCompat.Type.systemBars() or WindowInsetsCompat.Type.displayCutout(),
            )
            topBar.updatePadding(left = bars.left, top = bars.top, right = bars.right)
            hint.updateLayoutParams<ViewGroup.MarginLayoutParams> {
                bottomMargin = bars.bottom + hintMargin
            }
            insets
        }
    }

    private fun startCamera() {
        waitingForPermission = false
        messagePanel.visibility = View.GONE
        val providerFuture = ProcessCameraProvider.getInstance(this)
        providerFuture.addListener({
            if (isDestroyed) return@addListener
            val provider = providerFuture.get()
            val selector = listOf(
                CameraSelector.DEFAULT_BACK_CAMERA,
                CameraSelector.DEFAULT_FRONT_CAMERA,
            ).firstOrNull { provider.hasCamera(it) }
            if (selector == null) return@addListener showNoCamera()

            val previewCase = Preview.Builder().build()
            previewCase.setSurfaceProvider(preview.surfaceProvider)
            val analysisCase = ImageAnalysis.Builder()
                .setResolutionSelector(
                    ResolutionSelector.Builder()
                        .setResolutionStrategy(
                            ResolutionStrategy(
                                Size(1280, 720),
                                ResolutionStrategy.FALLBACK_RULE_CLOSEST_HIGHER_THEN_LOWER,
                            ),
                        )
                        .build(),
                )
                .setBackpressureStrategy(ImageAnalysis.STRATEGY_KEEP_ONLY_LATEST)
                .build()
            analysisCase.setAnalyzer(analysis, QrAnalyzer { text -> runOnUiThread { onFound(text) } })

            val camera = try {
                provider.unbindAll()
                provider.bindToLifecycle(this, selector, previewCase, analysisCase)
            } catch (e: Exception) {
                return@addListener showNoCamera()
            }
            this.camera = camera
            if (camera.cameraInfo.hasFlashUnit()) {
                torch.visibility = View.VISIBLE
                camera.cameraInfo.torchState.observe(this) { showTorch(on = it == TorchState.ON) }
            }
        }, ContextCompat.getMainExecutor(this))
    }

    private fun showTorch(on: Boolean) {
        torch.setImageResource(if (on) R.drawable.ic_scanner_light_off else R.drawable.ic_scanner_light_on)
        torch.contentDescription = text(if (on) "lightOff" else "lightOn")
    }

    private fun onFound(text: String) {
        if (found || isFinishing) return
        found = true
        preview.performHapticFeedback(
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
                HapticFeedbackConstants.CONFIRM
            } else {
                HapticFeedbackConstants.VIRTUAL_KEY
            },
        )
        setResult(RESULT_OK, Intent().putExtra(EXTRA_TEXT, text))
        finish()
    }

    private fun showCameraNeeded() {
        // Android stops showing its prompt once the user has refused twice.
        val canAsk = shouldShowRequestPermissionRationale(Manifest.permission.CAMERA)
        waitingForPermission = true
        showMessage(text("cameraNeeded"), text(if (canAsk) "allowCamera" else "openSettings")) {
            if (canAsk) {
                askCamera.launch(Manifest.permission.CAMERA)
            } else {
                startActivity(
                    Intent(
                        Settings.ACTION_APPLICATION_DETAILS_SETTINGS,
                        Uri.fromParts("package", packageName, null),
                    ),
                )
            }
        }
    }

    private fun showNoCamera() = showMessage(text("noCamera"))

    private fun showMessage(text: String, action: String? = null, onAction: (() -> Unit)? = null) {
        messagePanel.visibility = View.VISIBLE
        message.text = text
        messageAction.visibility = if (action == null) View.GONE else View.VISIBLE
        messageAction.text = action
        messageAction.setOnClickListener { onAction?.invoke() }
    }

    companion object {
        const val EXTRA_TEXT = "text"

        /** [strings] holds the localized texts, by key. */
        fun intent(context: Context, strings: Map<String, String>): Intent =
            Intent(context, ScannerActivity::class.java).apply {
                strings.forEach { (key, value) -> putExtra(key, value) }
            }
    }
}

private class QrAnalyzer(private val onFound: (String) -> Unit) : ImageAnalysis.Analyzer {
    private val reader = QRCodeReader()
    private val hints = mapOf(DecodeHintType.TRY_HARDER to true)

    override fun analyze(image: ImageProxy) {
        image.use {
            // The Y plane alone is the grayscale image ZXing needs.
            val plane = it.planes[0]
            val buffer = plane.buffer
            val data = ByteArray(buffer.remaining()).also(buffer::get)
            val source = PlanarYUVLuminanceSource(
                data, plane.rowStride, it.height, 0, 0, it.width, it.height, false,
            )
            // Inverted for light codes on a dark background.
            (decode(source) ?: decode(source.invert()))?.let(onFound)
        }
    }

    private fun decode(source: LuminanceSource): String? =
        try {
            reader.decode(BinaryBitmap(HybridBinarizer(source)), hints).text
        } catch (e: ReaderException) {
            null
        } finally {
            reader.reset()
        }
}
