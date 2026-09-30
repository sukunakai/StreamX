package com.example.ui.screens

import androidx.compose.animation.animateColorAsState
import androidx.compose.foundation.BorderStroke
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.PaddingValues
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.Notifications
import androidx.compose.material.icons.filled.PlayArrow
import androidx.compose.material.icons.filled.PlusOne
import androidx.compose.material.icons.filled.Star
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.OutlinedButton
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
import androidx.compose.ui.draw.clip
import androidx.compose.ui.draw.shadow
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import coil.compose.AsyncImage
import coil.request.ImageRequest
import com.example.model.MovieItem
import com.example.ui.theme.DarkBlueGrey
import com.example.ui.theme.DeepSpaceBlack
import com.example.ui.theme.ElectricBlue
import com.example.ui.theme.NeonCyan
import com.example.ui.theme.StarGold
import com.example.ui.theme.SubtitleGrey

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun HomeScreen(
    movies: List<MovieItem>,
    watchlistIds: Set<String>,
    onToggleWatchlist: (String) -> Unit,
    onSelectMovie: (MovieItem) -> Unit,
    modifier: Modifier = Modifier,
) {
    var selectedCategory by remember { mutableStateOf("All") }
    val categories = remember {
        listOf("All", "Action", "Sci-Fi", "Anime", "Cyberpunk", "Trending")
    }

    val heroMovie = movies.firstOrNull()

    val filteredMovies = remember(movies, selectedCategory) {
        if (selectedCategory == "All") movies
        else movies.filter { it.category.equals(selectedCategory, ignoreCase = true) }.ifEmpty { movies }
    }

    Column(
        modifier = modifier
            .fillMaxSize()
            .background(DeepSpaceBlack)
    ) {
        // App Bar: Logo Text (STREAMX), Notification Bell (NO CAST ICON)
        TopAppBar(
            title = {
                Surface(
                    color = NeonCyan.copy(alpha = 0.12f),
                    shape = RoundedCornerShape(6.dp),
                    border = BorderStroke(1.dp, NeonCyan)
                ) {
                    Text(
                        text = "STREAMX",
                        color = NeonCyan,
                        fontWeight = FontWeight.Black,
                        letterSpacing = 2.2.sp,
                        fontSize = 15.sp,
                        modifier = Modifier.padding(horizontal = 10.dp, vertical = 4.dp)
                    )
                }
            },
            actions = {
                IconButton(onClick = {}) {
                    Icon(
                        imageVector = Icons.Default.Notifications,
                        contentDescription = "Notifications",
                        tint = Color.White,
                        modifier = Modifier.size(20.dp)
                    )
                }
            },
            colors = TopAppBarDefaults.topAppBarColors(
                containerColor = DeepSpaceBlack,
                titleContentColor = Color.White
            )
        )

        // 1. TOP CATEGORIES: Instantly below the AppBar, completely ABOVE Hero Image
        LazyRow(
            contentPadding = PaddingValues(horizontal = 18.dp),
            horizontalArrangement = Arrangement.spacedBy(8.dp),
            modifier = Modifier.padding(bottom = 8.dp)
        ) {
            items(categories) { cat ->
                val isSelected = cat == selectedCategory
                val bgCol by animateColorAsState(
                    if (isSelected) NeonCyan else DarkBlueGrey.copy(alpha = 0.85f),
                    label = "pill_color"
                )
                val textCol by animateColorAsState(
                    if (isSelected) Color.Black else Color.White.copy(alpha = 0.85f),
                    label = "pill_text"
                )
                Surface(
                    shape = RoundedCornerShape(18.dp),
                    color = bgCol,
                    border = BorderStroke(
                        0.8.dp,
                        if (isSelected) NeonCyan else Color(0xFF262638)
                    ),
                    modifier = Modifier.clickable { selectedCategory = cat }
                ) {
                    Text(
                        text = cat,
                        color = textCol,
                        fontWeight = if (isSelected) FontWeight.ExtraBold else FontWeight.Medium,
                        fontSize = 12.sp,
                        modifier = Modifier.padding(horizontal = 14.dp, vertical = 7.dp)
                    )
                }
            }
        }

        LazyColumn(
            modifier = Modifier.fillMaxSize(),
            contentPadding = PaddingValues(bottom = 36.dp)
        ) {
            // 2. EDGE-TO-EDGE HERO IMAGE SECTION
            if (heroMovie != null) {
                item {
                    val isSaved = watchlistIds.contains(heroMovie.id)
                    EdgeToEdgeHeroSection(
                        movie = heroMovie,
                        isSaved = isSaved,
                        onToggleWatchlist = { onToggleWatchlist(heroMovie.id) },
                        onPlay = { onSelectMovie(heroMovie) }
                    )
                    Spacer(modifier = Modifier.height(28.dp))
                }
            }

            // 4. CLEANER ROWS: Trending Worldwide
            item {
                MovieRowSection(
                    title = "Trending Worldwide",
                    movies = filteredMovies,
                    onSelectMovie = onSelectMovie
                )
                Spacer(modifier = Modifier.height(32.dp))
            }

            // 4. CLEANER ROWS: New Releases
            item {
                MovieRowSection(
                    title = "New Releases",
                    movies = filteredMovies.reversed(),
                    onSelectMovie = onSelectMovie
                )
            }
        }
    }
}

@Composable
fun EdgeToEdgeHeroSection(
    movie: MovieItem,
    isSaved: Boolean,
    onToggleWatchlist: () -> Unit,
    onPlay: () -> Unit,
    modifier: Modifier = Modifier,
) {
    val context = LocalContext.current

    // Edge-to-edge: no horizontal margin/padding
    Box(
        modifier = modifier
            .fillMaxWidth()
            .height(470.dp)
            .background(DarkBlueGrey)
    ) {
        AsyncImage(
            model = ImageRequest.Builder(context)
                .data(movie.bannerUrl)
                .crossfade(true)
                .build(),
            contentDescription = movie.title,
            contentScale = ContentScale.Crop,
            modifier = Modifier.fillMaxSize()
        )

        // Smooth cinematic multi-stop gradient seamlessly fading into DeepSpaceBlack (0xFF0A0A0F)
        Box(
            modifier = Modifier
                .fillMaxSize()
                .background(
                    Brush.verticalGradient(
                        colors = listOf(
                            DeepSpaceBlack.copy(alpha = 0.35f),
                            Color.Transparent,
                            DeepSpaceBlack.copy(alpha = 0.45f),
                            DeepSpaceBlack.copy(alpha = 0.85f),
                            DeepSpaceBlack
                        ),
                        startY = 0f,
                        endY = Float.POSITIVE_INFINITY
                    )
                )
        )

        // Hero Content Details & Sleek Buttons
        Column(
            modifier = Modifier
                .align(Alignment.BottomStart)
                .padding(horizontal = 20.dp, vertical = 12.dp)
        ) {
            // Badges
            Row(verticalAlignment = Alignment.CenterVertically) {
                Surface(
                    color = NeonCyan.copy(alpha = 0.18f),
                    shape = RoundedCornerShape(4.dp),
                    border = BorderStroke(0.8.dp, NeonCyan)
                ) {
                    Text(
                        text = movie.category.uppercase(),
                        color = NeonCyan,
                        fontSize = 10.sp,
                        fontWeight = FontWeight.ExtraBold,
                        letterSpacing = 1.2.sp,
                        modifier = Modifier.padding(horizontal = 7.dp, vertical = 2.5.dp)
                    )
                }
                Spacer(modifier = Modifier.width(8.dp))
                Icon(
                    imageVector = Icons.Default.Star,
                    contentDescription = null,
                    tint = StarGold,
                    modifier = Modifier.size(13.dp)
                )
                Spacer(modifier = Modifier.width(4.dp))
                Text(
                    text = "${movie.rating} IMDB",
                    color = Color.White,
                    fontSize = 12.sp,
                    fontWeight = FontWeight.SemiBold
                )
                Spacer(modifier = Modifier.width(8.dp))
                Text(
                    text = "·  ${movie.releaseYear}  ·  Ultra 4K",
                    color = Color.White.copy(alpha = 0.6f),
                    fontSize = 11.sp
                )
            }

            Spacer(modifier = Modifier.height(8.dp))

            // Title
            Text(
                text = movie.title,
                color = Color.White,
                fontSize = 26.sp,
                fontWeight = FontWeight.Black,
                letterSpacing = (-0.3).sp,
                lineHeight = 30.sp,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis
            )
            Spacer(modifier = Modifier.height(6.dp))

            // Description
            Text(
                text = movie.description,
                color = Color.White.copy(alpha = 0.72f),
                fontSize = 12.5.sp,
                lineHeight = 17.sp,
                maxLines = 2,
                overflow = TextOverflow.Ellipsis
            )
            Spacer(modifier = Modifier.height(16.dp))

            // 3. SLEEKER, SMALLER, REFINED BUTTON STYLING (Apple TV / Netflix style)
            Row(verticalAlignment = Alignment.CenterVertically) {
                // Sleek "Watch Now" Button
                Surface(
                    shape = RoundedCornerShape(20.dp),
                    color = NeonCyan,
                    modifier = Modifier
                        .height(38.dp)
                        .shadow(12.dp, RoundedCornerShape(20.dp), spotColor = NeonCyan)
                        .clickable { onPlay() }
                ) {
                    Row(
                        modifier = Modifier
                            .background(
                                Brush.horizontalGradient(listOf(NeonCyan, ElectricBlue))
                            )
                            .padding(horizontal = 18.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Icon(
                            imageVector = Icons.Default.PlayArrow,
                            contentDescription = null,
                            tint = Color.Black,
                            modifier = Modifier.size(16.dp)
                        )
                        Spacer(modifier = Modifier.width(6.dp))
                        Text(
                            text = "Watch Now",
                            color = Color.Black,
                            fontWeight = FontWeight.ExtraBold,
                            fontSize = 13.sp,
                            letterSpacing = 0.2.sp
                        )
                    }
                }

                Spacer(modifier = Modifier.width(12.dp))

                // Sleek "My List" Button
                Surface(
                    shape = RoundedCornerShape(20.dp),
                    color = DarkBlueGrey.copy(alpha = 0.7f),
                    border = BorderStroke(
                        0.9.dp,
                        if (isSaved) NeonCyan else Color.White.copy(alpha = 0.25f)
                    ),
                    modifier = Modifier
                        .height(38.dp)
                        .clickable { onToggleWatchlist() }
                ) {
                    Row(
                        modifier = Modifier.padding(horizontal = 16.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Icon(
                            imageVector = if (isSaved) Icons.Default.Check else Icons.Default.PlusOne,
                            contentDescription = null,
                            tint = if (isSaved) NeonCyan else Color.White,
                            modifier = Modifier.size(15.dp)
                        )
                        Spacer(modifier = Modifier.width(6.dp))
                        Text(
                            text = if (isSaved) "In List" else "My List",
                            color = if (isSaved) NeonCyan else Color.White,
                            fontWeight = FontWeight.SemiBold,
                            fontSize = 13.sp
                        )
                    }
                }
            }
        }
    }
}

@Composable
fun MovieRowSection(
    title: String,
    movies: List<MovieItem>,
    onSelectMovie: (MovieItem) -> Unit,
    modifier: Modifier = Modifier,
) {
    val context = LocalContext.current

    Column(modifier = modifier.fillMaxWidth()) {
        // Section Header with proper padding & margins
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 20.dp),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Text(
                text = title,
                color = Color.White,
                fontSize = 17.sp,
                fontWeight = FontWeight.ExtraBold,
                letterSpacing = 0.3.sp
            )
            Text(
                text = "See All",
                color = NeonCyan,
                fontSize = 12.sp,
                fontWeight = FontWeight.SemiBold
            )
        }

        // Ample spacing between title and movie cards
        Spacer(modifier = Modifier.height(14.dp))

        LazyRow(
            contentPadding = PaddingValues(horizontal = 20.dp),
            horizontalArrangement = Arrangement.spacedBy(14.dp)
        ) {
            items(movies) { movie ->
                Column(
                    modifier = Modifier
                        .width(125.dp)
                        .clickable { onSelectMovie(movie) }
                ) {
                    // Subtle border radius (10dp) on posters
                    Box(
                        modifier = Modifier
                            .fillMaxWidth()
                            .height(180.dp)
                            .clip(RoundedCornerShape(10.dp))
                            .background(DarkBlueGrey)
                    ) {
                        AsyncImage(
                            model = ImageRequest.Builder(context)
                                .data(movie.posterUrl)
                                .crossfade(true)
                                .build(),
                            contentDescription = movie.title,
                            contentScale = ContentScale.Crop,
                            modifier = Modifier.fillMaxSize()
                        )

                        // Rating badge
                        Surface(
                            color = Color.Black.copy(alpha = 0.78f),
                            shape = RoundedCornerShape(4.dp),
                            modifier = Modifier
                                .align(Alignment.TopEnd)
                                .padding(6.dp)
                        ) {
                            Row(
                                verticalAlignment = Alignment.CenterVertically,
                                modifier = Modifier.padding(horizontal = 5.dp, vertical = 2.dp)
                            ) {
                                Icon(
                                    imageVector = Icons.Default.Star,
                                    contentDescription = null,
                                    tint = StarGold,
                                    modifier = Modifier.size(9.dp)
                                )
                                Spacer(modifier = Modifier.width(2.dp))
                                Text(
                                    text = "${movie.rating}",
                                    color = Color.White,
                                    fontSize = 9.5.sp,
                                    fontWeight = FontWeight.Bold
                                )
                            }
                        }
                    }

                    Spacer(modifier = Modifier.height(7.dp))
                    Text(
                        text = movie.title,
                        color = Color.White,
                        fontSize = 12.5.sp,
                        fontWeight = FontWeight.SemiBold,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis
                    )
                    Spacer(modifier = Modifier.height(2.dp))
                    Text(
                        text = "${movie.releaseYear} · ${movie.category}",
                        color = SubtitleGrey,
                        fontSize = 10.5.sp
                    )
                }
            }
        }
    }
}
