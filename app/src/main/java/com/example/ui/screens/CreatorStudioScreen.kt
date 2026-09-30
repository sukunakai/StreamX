package com.example.ui.screens

import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowBack
import androidx.compose.material.icons.filled.AutoFixHigh
import androidx.compose.material.icons.filled.CheckCircle
import androidx.compose.material.icons.filled.Podcasts
import androidx.compose.material.icons.filled.Search
import androidx.compose.material.icons.filled.VideoLibrary
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.HorizontalDivider
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.OutlinedTextFieldDefaults
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.material3.TopAppBarDefaults
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.model.EpisodeItem
import com.example.model.MovieItem
import com.example.ui.theme.DarkBlueGrey
import com.example.ui.theme.DeepSpaceBlack
import com.example.ui.theme.ElectricBlue
import com.example.ui.theme.NeonCyan
import com.example.ui.theme.SubtitleGrey

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun CreatorStudioScreen(
    onBack: () -> Unit,
    onPublishMovie: (MovieItem) -> Unit,
    modifier: Modifier = Modifier,
) {
    var tmdbQuery by remember { mutableStateOf("") }
    var title by remember { mutableStateOf("") }
    var category by remember { mutableStateOf("Sci-Fi") }
    var posterUrl by remember { mutableStateOf("") }
    var description by remember { mutableStateOf("") }
    var mediaUrl by remember {
        mutableStateOf("https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4")
    }

    var showSuccessDialog by remember { mutableStateOf(false) }

    // Instant TMDB Presets for 1-tap auto-fill
    val tmdbPresets = remember {
        listOf(
            Triple(
                "Dune: Awakening",
                "Paul Atreides confronts the shifting sands of Arrakis.",
                "https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=800"
            ),
            Triple(
                "Cyberpunk: Neon Horizon",
                "A high-octane mercenary crew executes an orbital biometric heist.",
                "https://images.unsplash.com/photo-1542751371-adc38448a05e?w=800"
            ),
            Triple(
                "Blade of Nebula",
                "In the deep gravity well of Saturn, an exiled cyber-samurai is summoned.",
                "https://images.unsplash.com/photo-1578632767115-351597cf2477?w=800"
            )
        )
    }

    Column(
        modifier = modifier
            .fillMaxSize()
            .background(DeepSpaceBlack)
    ) {
        TopAppBar(
            title = {
                Text(
                    text = "Creator Studio (CMS)",
                    color = Color.White,
                    fontWeight = FontWeight.Bold,
                    fontSize = 18.sp
                )
            },
            navigationIcon = {
                IconButton(onClick = onBack) {
                    Icon(
                        imageVector = Icons.AutoMirrored.Filled.ArrowBack,
                        contentDescription = "Back",
                        tint = Color.White
                    )
                }
            },
            colors = TopAppBarDefaults.topAppBarColors(
                containerColor = DarkBlueGrey,
                titleContentColor = Color.White
            )
        )

        LazyColumn(
            modifier = Modifier
                .fillMaxSize()
                .padding(20.dp),
            verticalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            // TMDB AUTO-METADATA LOOKUP
            item {
                Text(
                    text = "TMDB AUTO-METADATA LOOKUP",
                    color = NeonCyan,
                    fontSize = 12.sp,
                    fontWeight = FontWeight.Bold,
                    letterSpacing = 1.2.sp
                )
                Spacer(modifier = Modifier.height(8.dp))

                OutlinedTextField(
                    value = tmdbQuery,
                    onValueChange = { tmdbQuery = it },
                    placeholder = {
                        Text("Search TMDB titles...", color = Color(0xFF6B7280), fontSize = 13.sp)
                    },
                    leadingIcon = {
                        Icon(imageVector = Icons.Default.Search, contentDescription = null, tint = NeonCyan)
                    },
                    colors = OutlinedTextFieldDefaults.colors(
                        focusedBorderColor = NeonCyan,
                        unfocusedBorderColor = Color(0xFF262638),
                        focusedContainerColor = DarkBlueGrey,
                        unfocusedContainerColor = DarkBlueGrey,
                        focusedTextColor = Color.White,
                        unfocusedTextColor = Color.White
                    ),
                    shape = RoundedCornerShape(12.dp),
                    modifier = Modifier.fillMaxWidth()
                )

                Spacer(modifier = Modifier.height(10.dp))
                Text(
                    text = "1-Tap Curated Autofill:",
                    color = SubtitleGrey,
                    fontSize = 11.sp
                )
                Spacer(modifier = Modifier.height(6.dp))

                Row(horizontalArrangement = Arrangement.spacedBy(8.dp)) {
                    tmdbPresets.forEach { preset ->
                        Surface(
                            color = Color(0xFF1E1E2C),
                            shape = RoundedCornerShape(16.dp),
                            border = BorderStroke(1.dp, Color(0xFF2E2E42)),
                            modifier = Modifier.clickable {
                                title = preset.first
                                description = preset.second
                                posterUrl = preset.third
                            }
                        ) {
                            Row(
                                verticalAlignment = Alignment.CenterVertically,
                                modifier = Modifier.padding(horizontal = 10.dp, vertical = 6.dp)
                            ) {
                                Icon(
                                    imageVector = Icons.Default.AutoFixHigh,
                                    contentDescription = null,
                                    tint = NeonCyan,
                                    modifier = Modifier.size(12.dp)
                                )
                                Spacer(modifier = Modifier.width(4.dp))
                                Text(
                                    text = preset.first.split(":").first(),
                                    color = Color.White,
                                    fontSize = 11.sp
                                )
                            }
                        }
                    }
                }
            }

            item {
                HorizontalDivider(color = Color(0xFF1E1E2C))
            }

            // Stream Metadata Inputs
            item {
                Text(
                    text = "STREAM METADATA",
                    color = NeonCyan,
                    fontSize = 12.sp,
                    fontWeight = FontWeight.Bold,
                    letterSpacing = 1.2.sp
                )
                Spacer(modifier = Modifier.height(10.dp))

                StudioTextField(label = "Title", value = title, onValueChange = { title = it }, hint = "Movie or Series title")
                Spacer(modifier = Modifier.height(12.dp))
                StudioTextField(label = "Category", value = category, onValueChange = { category = it }, hint = "Sci-Fi, Action, Anime, Cyberpunk...")
                Spacer(modifier = Modifier.height(12.dp))
                StudioTextField(label = "Poster URL", value = posterUrl, onValueChange = { posterUrl = it }, hint = "Direct image link")
                Spacer(modifier = Modifier.height(12.dp))
                StudioTextField(label = "Description", value = description, onValueChange = { description = it }, hint = "Synopsis & plot", maxLines = 3)
            }

            // Specific Media Streaming Input
            item {
                Text(
                    text = "MEDIA STREAMING INPUT",
                    color = NeonCyan,
                    fontSize = 12.sp,
                    fontWeight = FontWeight.Bold,
                    letterSpacing = 1.2.sp
                )
                Spacer(modifier = Modifier.height(8.dp))
                StudioTextField(
                    label = "HLS / MP4 Stream URL (BunnyCDN)",
                    value = mediaUrl,
                    onValueChange = { mediaUrl = it },
                    hint = "https://bunnycdn.com/stream/video.mp4 or .m3u8"
                )
            }

            // PUBLISH TO APP Button
            item {
                Spacer(modifier = Modifier.height(12.dp))
                Button(
                    onClick = {
                        val finalTitle = title.ifBlank { "Neon Odyssey 4K" }
                        val finalPoster = posterUrl.ifBlank { "https://images.unsplash.com/photo-1542751371-adc38448a05e?w=800" }
                        val movie = MovieItem(
                            id = "movie_${System.currentTimeMillis()}",
                            title = finalTitle,
                            description = description.ifBlank { "Ultra cinema 4K release on StreamX." },
                            posterUrl = finalPoster,
                            bannerUrl = finalPoster,
                            videoUrl = mediaUrl.ifBlank { "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4" },
                            category = category.ifBlank { "Sci-Fi" },
                            rating = 9.8,
                            releaseYear = 2026,
                            seasonsCount = 1,
                            episodes = listOf(
                                EpisodeItem(
                                    episodeNumber = 1,
                                    title = "Pilot Premiere",
                                    duration = "48m",
                                    videoUrl = mediaUrl.ifBlank { "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4" }
                                )
                            )
                        )
                        onPublishMovie(movie)
                        showSuccessDialog = true
                    },
                    colors = ButtonDefaults.buttonColors(
                        containerColor = NeonCyan,
                        contentColor = Color.Black
                    ),
                    shape = RoundedCornerShape(16.dp),
                    modifier = Modifier
                        .fillMaxWidth()
                        .height(56.dp)
                        .shadow(20.dp, RoundedCornerShape(16.dp), spotColor = NeonCyan)
                ) {
                    Icon(imageVector = Icons.Default.Podcasts, contentDescription = null)
                    Spacer(modifier = Modifier.width(10.dp))
                    Text(
                        text = "PUBLISH TO APP",
                        fontWeight = FontWeight.Black,
                        fontSize = 16.sp,
                        letterSpacing = 1.5.sp
                    )
                }
                Spacer(modifier = Modifier.height(30.dp))
            }
        }
    }

    if (showSuccessDialog) {
        AlertDialog(
            onDismissRequest = {
                showSuccessDialog = false
                onBack()
            },
            containerColor = DarkBlueGrey,
            title = {
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Icon(imageVector = Icons.Default.CheckCircle, contentDescription = null, tint = NeonCyan)
                    Spacer(modifier = Modifier.width(10.dp))
                    Text("Broadcast Live!", color = Color.White, fontWeight = FontWeight.Bold)
                }
            },
            text = {
                Text(
                    text = "\"$title\" is now immediately live on StreamX home screens for all viewers.",
                    color = Color.White.copy(alpha = 0.8f)
                )
            },
            confirmButton = {
                Button(
                    onClick = {
                        showSuccessDialog = false
                        onBack()
                    },
                    colors = ButtonDefaults.buttonColors(containerColor = NeonCyan, contentColor = Color.Black)
                ) {
                    Text("Back to App", fontWeight = FontWeight.Bold)
                }
            }
        )
    }
}

@Composable
fun StudioTextField(
    label: String,
    value: String,
    onValueChange: (String) -> Unit,
    hint: String,
    maxLines: Int = 1,
) {
    Column {
        Text(text = label, color = Color.White, fontWeight = FontWeight.Bold, fontSize = 13.sp)
        Spacer(modifier = Modifier.height(6.dp))
        OutlinedTextField(
            value = value,
            onValueChange = onValueChange,
            placeholder = { Text(text = hint, color = Color(0xFF6B7280), fontSize = 13.sp) },
            maxLines = maxLines,
            shape = RoundedCornerShape(12.dp),
            colors = OutlinedTextFieldDefaults.colors(
                focusedBorderColor = NeonCyan,
                unfocusedBorderColor = Color(0xFF262638),
                focusedContainerColor = DarkBlueGrey,
                unfocusedContainerColor = DarkBlueGrey,
                focusedTextColor = Color.White,
                unfocusedTextColor = Color.White
            ),
            modifier = Modifier.fillMaxWidth()
        )
    }
}
