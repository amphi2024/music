package com.amphi.music;

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.os.IBinder

class MediaButtonReceiver : BroadcastReceiver() {
    override fun onReceive(context: Context?, intent: Intent?) {
        val serviceIntent = Intent(context, MediaPlayerService::class.java)

        intent?.let {
            serviceIntent.action = it.action
            context?.startService(serviceIntent)
        }
    }

    override fun peekService(myContext: Context?, service: Intent?): IBinder {
        return super.peekService(myContext, service)
    }

    override fun getSentFromUid(): Int {
        return super.getSentFromUid()
    }

    override fun getSentFromPackage(): String? {
        return super.getSentFromPackage()
    }
}
