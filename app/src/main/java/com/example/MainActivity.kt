package com.example

import android.os.Build
import android.os.Bundle
import android.view.WindowManager
import androidx.activity.ComponentActivity
import androidx.activity.compose.BackHandler
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.CloudDownload
import androidx.compose.material.icons.filled.Home
import androidx.compose.material.icons.filled.Person
import androidx.compose.material.icons.filled.Search
import androidx.compose.material3.Icon
import androidx.compose.material3.NavigationBar
import androidx.compose.material3.NavigationBarItem
import androidx.compose.material3.NavigationBarItemDefaults
import androidx.compose.material3.Scaffold
import androidx.compose.material3.SnackbarHost
import androidx.compose.material3.SnackbarHostState
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableIntStateOf
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.data.MovieRepository
import com.example.model.MovieItem
import com.example.ui.components.VideoPlayerScreen
import com.example.ui.screens.CreatorStudioScreen
import com.example.ui.screens.DownloadsScreen
import com.example.ui.screens.HomeScreen
import com.example.ui.screens.ProfileScreen
import com.example.ui.screens.SearchScreen
import com.example.ui.theme.DarkBlueGrey
import com.example.ui.theme.DeepSpaceBlack
import com.example.ui.theme.MyApplicationTheme
import com.example.ui.theme.NeonCyan
import com.example.ui.theme.SubtitleGrey
import kotlinx.coroutines.launch

class MainActivity : ComponentActivity() {
    private val repository = MovieRepository()

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()

        // Enable high refresh rate (120Hz) on supported Android displays
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            val modes = display?.supportedModes
            val highRefreshMode = modes?.maxByOrNull { it.refreshRate }
            if (highRefreshMode != null && highRefreshMode.refreshRate >= 90f) {
                val params = window.attributes
                params.preferredDisplayModeId = highRefreshMode.modeId
                window.attributes = params
            }
        }

        setContent {
            MyApplicationTheme {
                StreamXMainApp(repository = repository)
            }
        }
    }
}

@Composable
fun StreamXMainApp(repository: MovieRepository) {
    var currentTab by remember { mutableIntStateOf(0) }
    var selectedPlayerMovie by remember { mutableStateOf<MovieItem?>(null) }
    var showCreatorStudio by remember { mutableStateOf(false) }

    val movies by repository.movies.collectAsState()
    val watchlistIds by repository.watchlistIds.collectAsState()
    val downloads by repository.downloads.collectAsState()
    val recentSearches by repository.recentSearches.collectAsState()
    val userEmail by repository.userEmail.collectAsState()
    val displayName by repository.displayName.collectAsState()

    val snackbarHostState = remember { SnackbarHostState() }
    val scope = rememberCoroutineScope()

    // Handle back button when player or creator studio is active
    BackHandler(enabled = selectedPlayerMovie != null || showCreatorStudio) {
        if (selectedPlayerMovie != null) {
            selectedPlayerMovie = null
        } else if (showCreatorStudio) {
            showCreatorStudio = false
        }
    }

    Box(modifier = Modifier.fillMaxSize().background(DeepSpaceBlack)) {
        Scaffold(
            snackbarHost = { SnackbarHost(snackbarHostState) },
            bottomBar = {
                // Bottom Navigation Bar is ALWAYS visible across the 4 main tabs
                if (selectedPlayerMovie == null && !showCreatorStudio) {
                    NavigationBar(
                        containerColor = DeepSpaceBlack,
                        contentColor = SubtitleGrey,
                        tonalElevation = 8.dp
                    ) {
                        NavigationBarItem(
                            selected = currentTab == 0,
                            onClick = { currentTab = 0 },
                            icon = { Icon(Icons.Default.Home, contentDescription = "Home") },
                            label = { Text("Home", fontSize = 11.sp) },
                            colors = NavigationBarItemDefaults.colors(
                                selectedIconColor = NeonCyan,
                                selectedTextColor = NeonCyan,
                                indicatorColor = NeonCyan.copy(alpha = 0.15f),
                                unselectedIconColor = SubtitleGrey,
                                unselectedTextColor = SubtitleGrey
                            )
                        )
                        NavigationBarItem(
                            selected = currentTab == 1,
                            onClick = { currentTab = 1 },
                            icon = { Icon(Icons.Default.Search, contentDescription = "Search") },
                            label = { Text("Search", fontSize = 11.sp) },
                            colors = NavigationBarItemDefaults.colors(
                                selectedIconColor = NeonCyan,
                                selectedTextColor = NeonCyan,
                                indicatorColor = NeonCyan.copy(alpha = 0.15f),
                                unselectedIconColor = SubtitleGrey,
                                unselectedTextColor = SubtitleGrey
                            )
                        )
                        NavigationBarItem(
                            selected = currentTab == 2,
                            onClick = { currentTab = 2 },
                            icon = { Icon(Icons.Default.CloudDownload, contentDescription = "Offline") },
                            label = { Text("Offline", fontSize = 11.sp) },
                            colors = NavigationBarItemDefaults.colors(
                                selectedIconColor = NeonCyan,
                                selectedTextColor = NeonCyan,
                                indicatorColor = NeonCyan.copy(alpha = 0.15f),
                                unselectedIconColor = SubtitleGrey,
                                unselectedTextColor = SubtitleGrey
                            )
                        )
                        NavigationBarItem(
                            selected = currentTab == 3,
                            onClick = { currentTab = 3 },
                            icon = { Icon(Icons.Default.Person, contentDescription = "Profile") },
                            label = { Text("Profile", fontSize = 11.sp) },
                            colors = NavigationBarItemDefaults.colors(
                                selectedIconColor = NeonCyan,
                                selectedTextColor = NeonCyan,
                                indicatorColor = NeonCyan.copy(alpha = 0.15f),
                                unselectedIconColor = SubtitleGrey,
                                unselectedTextColor = SubtitleGrey
                            )
                        )
                    }
                }
            }
        ) { innerPadding ->
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .padding(innerPadding)
            ) {
                when (currentTab) {
                    0 -> HomeScreen(
                        movies = movies,
                        watchlistIds = watchlistIds,
                        onToggleWatchlist = { id -> repository.toggleWatchlist(id) },
                        onSelectMovie = { movie -> selectedPlayerMovie = movie }
                    )
                    1 -> SearchScreen(
                        movies = movies,
                        recentSearches = recentSearches,
                        onAddRecentSearch = { q -> repository.addRecentSearch(q) },
                        onRemoveRecentSearch = { q -> repository.removeRecentSearch(q) },
                        onClearRecentSearches = { repository.clearRecentSearches() },
                        onSelectMovie = { movie -> selectedPlayerMovie = movie }
                    )
                    2 -> DownloadsScreen(
                        downloads = downloads,
                        onDeleteDownload = { id -> repository.removeDownload(id) },
                        onPlayDownloaded = { movie -> selectedPlayerMovie = movie }
                    )
                    3 -> ProfileScreen(
                        userEmail = userEmail,
                        displayName = displayName,
                        onUpdateDisplayName = { name -> repository.setDisplayName(name) },
                        onSwitchEmail = { email -> repository.setUserEmail(email) },
                        onOpenCreatorStudio = { showCreatorStudio = true }
                    )
                }
            }
        }

        // Fullscreen Overlays: Pro Video Player
        if (selectedPlayerMovie != null) {
            VideoPlayerScreen(
                movie = selectedPlayerMovie!!,
                onBack = { selectedPlayerMovie = null },
                onDownloadEpisode = { title ->
                    repository.startDownload(
                        title = title,
                        posterUrl = selectedPlayerMovie!!.posterUrl,
                        videoUrl = selectedPlayerMovie!!.videoUrl
                    )
                    scope.launch {
                        snackbarHostState.showSnackbar("Downloading $title for offline viewing...")
                    }
                }
            )
        }

        // Creator Studio Overlay
        if (showCreatorStudio) {
            CreatorStudioScreen(
                onBack = { showCreatorStudio = false },
                onPublishMovie = { newMovie ->
                    repository.addMovie(newMovie)
                }
            )
        }
    }
}
