package com.example.data

import com.example.model.DownloadedItem
import com.example.model.EpisodeItem
import com.example.model.MovieItem
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.update

class MovieRepository {
    private val _movies = MutableStateFlow<List<MovieItem>>(emptyList())
    val movies: StateFlow<List<MovieItem>> = _movies.asStateFlow()

    private val _watchlistIds = MutableStateFlow<Set<String>>(emptySet())
    val watchlistIds: StateFlow<Set<String>> = _watchlistIds.asStateFlow()

    private val _downloads = MutableStateFlow<List<DownloadedItem>>(emptyList())
    val downloads: StateFlow<List<DownloadedItem>> = _downloads.asStateFlow()

    private val _recentSearches = MutableStateFlow<List<String>>(
        listOf("Cyberpulse", "Quantum Abyss", "Chrono Blade", "4K Ultra")
    )
    val recentSearches: StateFlow<List<String>> = _recentSearches.asStateFlow()

    private val _userEmail = MutableStateFlow("verseshow94@gmail.com")
    val userEmail: StateFlow<String> = _userEmail.asStateFlow()

    private val _displayName = MutableStateFlow("CyberStreamer")
    val displayName: StateFlow<String> = _displayName.asStateFlow()

    init {
        initSeedData()
    }

    private fun initSeedData() {
        val initialList = listOf(
            MovieItem(
                id = "streamx_indian_1",
                title = "RRR: Rise of the Revolution",
                description = "Two legendary revolutionaries embark on an epic fight against ruthless colonial rulers in an electrifying, action-packed spectacle.",
                posterUrl = "https://images.unsplash.com/photo-1517604931442-7e0c8ed2963c?w=800&auto=format&fit=crop&q=80",
                bannerUrl = "https://images.unsplash.com/photo-1485846234645-a62644f84728?w=1200&auto=format&fit=crop&q=80",
                videoUrl = "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
                category = "Indian",
                rating = 9.8,
                releaseYear = 2025,
                seasonsCount = 1,
                episodes = listOf(
                    EpisodeItem(1, "The Fire Within", "182m", "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"),
                )
            ),
            MovieItem(
                id = "streamx_indian_2",
                title = "Cyber Mirzapur: King of Underworld",
                description = "Rule, power, and high-stakes revenge collide in the ruthless digital crime syndicate of Uttar Pradesh.",
                posterUrl = "https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=800&auto=format&fit=crop&q=80",
                bannerUrl = "https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=1200&auto=format&fit=crop&q=80",
                videoUrl = "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4",
                category = "Drama",
                rating = 9.4,
                releaseYear = 2026,
                seasonsCount = 3,
                episodes = listOf(
                    EpisodeItem(1, "Kahin Ka Badla", "52m", "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4"),
                    EpisodeItem(2, "Bhaukaal Reloaded", "56m", "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4"),
                )
            ),
            MovieItem(
                id = "streamx_movie_1",
                title = "Oppenheimer: The Atomic Core",
                description = "The pulse-pounding true paradox of the enigmatic man who risked destroying the world in order to save it.",
                posterUrl = "https://images.unsplash.com/photo-1440404653325-ab127d49abc1?w=800&auto=format&fit=crop&q=80",
                bannerUrl = "https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=1200&auto=format&fit=crop&q=80",
                videoUrl = "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4",
                category = "Movies",
                rating = 9.6,
                releaseYear = 2025,
                seasonsCount = 1,
                episodes = listOf(
                    EpisodeItem(1, "Trinity Test", "180m", "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4"),
                )
            ),
            MovieItem(
                id = "streamx_anime_2",
                title = "Attack on Titan: The Final Blitz",
                description = "Humanity's desperate fight for freedom against gigantic humanoid Titans reaches its earth-shattering climax.",
                posterUrl = "https://images.unsplash.com/photo-1563089145-599997674d42?w=800&auto=format&fit=crop&q=80",
                bannerUrl = "https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=1200&auto=format&fit=crop&q=80",
                videoUrl = "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4",
                category = "Anime",
                rating = 9.9,
                releaseYear = 2026,
                seasonsCount = 4,
                episodes = listOf(
                    EpisodeItem(1, "Rumbling of Heaven", "28m", "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4"),
                    EpisodeItem(2, "Freedom or Death", "29m", "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"),
                )
            ),
            MovieItem(
                id = "streamx_1",
                title = "Cyberpulse: Neo Tokyo",
                description = "In 2099, an underground neon synthesis hacker discovers a rogue neural core threatening the mega-metropolis.",
                posterUrl = "https://images.unsplash.com/photo-1578632767115-351597cf2477?w=800&auto=format&fit=crop&q=80",
                bannerUrl = "https://images.unsplash.com/photo-1542751371-adc38448a05e?w=1200&auto=format&fit=crop&q=80",
                videoUrl = "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4",
                category = "Sci-Fi",
                rating = 9.6,
                releaseYear = 2026,
                seasonsCount = 4,
                episodes = listOf(
                    EpisodeItem(1, "Neural Boot", "48m", "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"),
                    EpisodeItem(2, "Ghost in Grid", "52m", "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4"),
                    EpisodeItem(3, "Zero Day Override", "45m", "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4"),
                    EpisodeItem(4, "Cybernetic Echoes", "50m", "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4"),
                )
            ),
            MovieItem(
                id = "streamx_2",
                title = "Quantum Abyss",
                description = "Deep sea explorers uncover an ancient extraterrestrial monolith radiating temporal anomalies off the Mariana Trench.",
                posterUrl = "https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=800&auto=format&fit=crop&q=80",
                bannerUrl = "https://images.unsplash.com/photo-1509198397868-475647b2a1e5?w=1200&auto=format&fit=crop&q=80",
                videoUrl = "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4",
                category = "Action",
                rating = 9.2,
                releaseYear = 2025,
                seasonsCount = 2,
                episodes = listOf(
                    EpisodeItem(1, "Descent 11000m", "54m", "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4"),
                    EpisodeItem(2, "Black Current", "49m", "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4"),
                    EpisodeItem(3, "The Monolith", "58m", "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"),
                )
            ),
            MovieItem(
                id = "streamx_3",
                title = "Chrono Blade: Ronin",
                description = "A time-traveling samurai armed with an ionized katana tracks an immortal syndicate across three centuries.",
                posterUrl = "https://images.unsplash.com/photo-1534447677768-be436bb09401?w=800&auto=format&fit=crop&q=80",
                bannerUrl = "https://images.unsplash.com/photo-1511512578047-dfb367046420?w=1200&auto=format&fit=crop&q=80",
                videoUrl = "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4",
                category = "Anime",
                rating = 9.4,
                releaseYear = 2026,
                seasonsCount = 3,
                episodes = listOf(
                    EpisodeItem(1, "Blade of Dawn", "24m", "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4"),
                    EpisodeItem(2, "Kyoto Paradox", "24m", "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4"),
                    EpisodeItem(3, "Infinite Slash", "26m", "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"),
                )
            ),
            MovieItem(
                id = "streamx_4",
                title = "Solaris Protocol",
                description = "When the first orbital dyson ring malfunctions, a lone repair engineer must confront an artificial consciousness with a soul.",
                posterUrl = "https://images.unsplash.com/photo-1451187580459-43490279c0fa?w=800&auto=format&fit=crop&q=80",
                bannerUrl = "https://images.unsplash.com/photo-1446776811953-b23d57bd21aa?w=1200&auto=format&fit=crop&q=80",
                videoUrl = "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4",
                category = "Sci-Fi",
                rating = 8.9,
                releaseYear = 2024,
                seasonsCount = 1,
                episodes = listOf(
                    EpisodeItem(1, "Coronal Flare", "47m", "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4"),
                    EpisodeItem(2, "Stellar Heartbeat", "51m", "https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4"),
                )
            )
        )
        _movies.value = initialList

        _downloads.value = listOf(
            DownloadedItem(
                id = "dl_1",
                title = "Cyberpulse: Neo Tokyo - E1",
                filePath = "local_storage/cyberpulse_e1.mp4",
                posterUrl = "https://images.unsplash.com/photo-1578632767115-351597cf2477?w=800",
                fileSizeMb = 420,
                progress = 1.0f,
                isCompleted = true,
            ),
            DownloadedItem(
                id = "dl_2",
                title = "Quantum Abyss - E1",
                filePath = "local_storage/quantum_abyss_e1.mp4",
                posterUrl = "https://images.unsplash.com/photo-1518709268805-4e9042af9f23?w=800",
                fileSizeMb = 680,
                progress = 0.74f,
                isCompleted = false,
            )
        )
    }

    fun toggleWatchlist(movieId: String) {
        _watchlistIds.update { set ->
            if (set.contains(movieId)) set - movieId else set + movieId
        }
    }

    fun addMovie(movie: MovieItem) {
        _movies.update { listOf(movie) + it }
    }

    fun addRecentSearch(query: String) {
        val trimmed = query.trim()
        if (trimmed.isEmpty()) return
        _recentSearches.update { list ->
            (listOf(trimmed) + (list - trimmed)).take(8)
        }
    }

    fun removeRecentSearch(query: String) {
        _recentSearches.update { it - query }
    }

    fun clearRecentSearches() {
        _recentSearches.value = emptyList()
    }

    fun startDownload(title: String, posterUrl: String, videoUrl: String) {
        val newId = "dl_${System.currentTimeMillis()}"
        val newItem = DownloadedItem(
            id = newId,
            title = title,
            filePath = "downloads/$newId.mp4",
            posterUrl = posterUrl,
            fileSizeMb = 450,
            progress = 0.25f,
            isCompleted = false,
        )
        _downloads.update { listOf(newItem) + it }
    }

    fun removeDownload(id: String) {
        _downloads.update { it.filterNot { item -> item.id == id } }
    }

    fun setUserEmail(email: String) {
        _userEmail.value = email.trim()
    }

    fun setDisplayName(name: String) {
        _displayName.value = name.trim()
    }
}
