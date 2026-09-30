package com.example.ui.theme

import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.darkColorScheme
import androidx.compose.runtime.Composable
import androidx.compose.ui.graphics.Color

private val StreamXColorScheme = darkColorScheme(
    primary = NeonCyan,
    onPrimary = Color.Black,
    primaryContainer = DarkBlueGrey,
    onPrimaryContainer = NeonCyan,
    secondary = ElectricBlue,
    onSecondary = Color.Black,
    surface = DarkBlueGrey,
    onSurface = Color.White,
    surfaceVariant = SurfaceContainerHigh,
    onSurfaceVariant = SubtitleGrey,
    background = DeepSpaceBlack,
    onBackground = Color.White,
)

@Composable
fun MyApplicationTheme(
    darkTheme: Boolean = true,
    dynamicColor: Boolean = false,
    content: @Composable () -> Unit,
) {
    MaterialTheme(
        colorScheme = StreamXColorScheme,
        typography = Typography,
        content = content,
    )
}
