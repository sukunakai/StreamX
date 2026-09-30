package com.example.model

data class EpisodeItem(
    val episodeNumber: Int,
    val title: String,
    val duration: String,
    val videoUrl: String,
)

data class MovieItem(
    val id: String,
    val title: String,
    val description: String,
    val posterUrl: String,
    val bannerUrl: String,
    val videoUrl: String,
    val category: String,
    val rating: Double,
    val releaseYear: Int,
    val seasonsCount: Int = 3,
    val episodes: List<EpisodeItem> = emptyList(),
)

data class DownloadedItem(
    val id: String,
    val title: String,
    val filePath: String,
    val posterUrl: String,
    val fileSizeMb: Int,
    val progress: Float, // 0.0f to 1.0f
    val isCompleted: Boolean,
)
