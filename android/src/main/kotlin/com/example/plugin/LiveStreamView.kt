package com.example.plugin

import android.content.Context
import androidx.constraintlayout.widget.ConstraintLayout

class LiveStreamView(context: Context): ConstraintLayout(context){
    init {
        inflate(context, R.layout.flutter_livestream, this)
    }
}