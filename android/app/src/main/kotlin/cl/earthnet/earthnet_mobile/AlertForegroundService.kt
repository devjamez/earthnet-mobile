package cl.earthnet.earthnet_mobile

import android.app.Notification
import android.app.NotificationChannel
import android.app.NotificationManager
import android.app.Service
import android.content.Intent
import android.content.pm.ServiceInfo
import android.os.Build
import android.os.IBinder

/**
 * Keeps the app process alive (and exempt from background execution limits) so
 * the Dart isolate holding the relay WebSocket keeps receiving alerts with the
 * screen off. The service itself only owns the persistent notification.
 */
class AlertForegroundService : Service() {
    override fun onBind(intent: Intent?): IBinder? = null

    override fun onStartCommand(intent: Intent?, flags: Int, startId: Int): Int {
        val manager = getSystemService(NotificationManager::class.java)
        val channel = NotificationChannel(
            CHANNEL_ID,
            "EarthNet early warning",
            NotificationManager.IMPORTANCE_LOW,
        )
        manager.createNotificationChannel(channel)

        val notification: Notification = Notification.Builder(this, CHANNEL_ID)
            .setContentTitle("EarthNet active")
            .setContentText("Listening for earthquake early warnings")
            .setSmallIcon(android.R.drawable.ic_dialog_alert)
            .setOngoing(true)
            .build()

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            startForeground(NOTIFICATION_ID, notification, ServiceInfo.FOREGROUND_SERVICE_TYPE_DATA_SYNC)
        } else {
            startForeground(NOTIFICATION_ID, notification)
        }
        // Restart if the system kills us; the network it watches is long-lived.
        return START_STICKY
    }

    companion object {
        private const val CHANNEL_ID = "earthnet_alerts"
        private const val NOTIFICATION_ID = 1
    }
}
