package chesstraps.achrafcyber.com

import android.os.Process
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    // Android keeps the process when this activity is destroyed (Back on the
    // root screen, for one), and the next launch starts a new Dart isolate in
    // it. The native Stockfish is process-wide and still running, unreachable
    // from the new isolate, so it refuses to start again until the process dies.
    // Ending the process here means every launch gets a clean engine.
    override fun onDestroy() {
        super.onDestroy()
        if (!isChangingConfigurations) Process.killProcess(Process.myPid())
    }
}
