package com.example.gatherly

import android.content.Context
import android.view.View
import android.widget.VideoView
import io.flutter.plugin.platform.PlatformView

class NativeVideoView(context: Context, creationParams: Map<String, Any>?) : PlatformView {
    private val videoView: VideoView = VideoView(context)

    init {
        val videoPath = creationParams?.get("videoPath") as? String
        val play = creationParams?.get("play") as? Boolean ?: true

        if (videoPath != null) {
            videoView.setVideoPath(videoPath)
            if (play) {
                videoView.start()
            } else {
                videoView.pause()
            }
        }
    }

    override fun getView(): View {
        return videoView
    }

    override fun dispose() {}
}
