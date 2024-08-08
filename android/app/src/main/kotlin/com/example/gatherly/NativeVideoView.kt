package com.example.gatherly

import android.content.Context
import android.view.View
import android.widget.VideoView
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView

class NativeVideoView(context: Context, creationParams: Map<String, Any>?, id: Int, binaryMessenger: io.flutter.plugin.common.BinaryMessenger) : PlatformView {
    private val videoView: VideoView = VideoView(context)
    private var isPlaying = true

    init {
        val videoPath = creationParams?.get("videoPath") as? String
        if (videoPath != null) {
            videoView.setVideoPath(videoPath)
            videoView.start()
        }

        
        MethodChannel(binaryMessenger, "native_video_view_$id").setMethodCallHandler { call, result ->
            when (call.method) {
                "togglePlayPause" -> {
                    togglePlayPause()
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun togglePlayPause() {
        if (isPlaying) {
            videoView.pause()
        } else {
            videoView.start()
        }
        isPlaying = !isPlaying
    }

    override fun getView(): View {
        return videoView
    }

    override fun dispose() {}
}
