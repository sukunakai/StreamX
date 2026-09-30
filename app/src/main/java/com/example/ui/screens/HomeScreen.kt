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
import androidx.compose.foundation.layout.statusBarsPadding
import androidx.compose.foundation.layout.width
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.AutoAwesome
import androidx.compose.material.icons.filled.Check
import androidx.compose.material.icons.filled.Notifications
import androidx.compose.material.icons.filled.PlayArrow
import androidx.compose.material.icons.filled.PlusOne
import androidx.compose.material.icons.filled.Star
import androidx.compose.material3.Icon
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
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
        listOf("All", "Movies", "Anime", "Drama", "Indian", "Action", "Sci-Fi")
    }

    val heroMovie = movies.firstOrNull()

    val filteredMovies = remember(movies, selectedCategory) {
        if (selectedCategory == "All") movies
        else movies.filter { it.category.equals(selectedCategory, ignoreCase = true) }.ifEmpty { movies }
    }

    Box(
        modifier = modifier
            .fillMaxSize()
            .background(DeepSpaceBlack)
    ) {
        // Scrollable content starting at 0dp (under the floating header)
        LazyColumn(
            modifier = Modifier.fillMaxSize(),
            contentPadding = PaddingValues(bottom = 36.dp)
        ) {
            // Full-Bleed Cinema Hero Image
            if (heroMovie != null) {
                item {
                    val isSaved = watchlistIds.contains(heroMovie.id)
                    ImmersiveHeroSection(
                        movie = heroMovie,
                        isSaved = isSaved,
                        onToggleWatchlist = { onToggleWatchlist(heroMovie.id) },
                        onPlay = { onSelectMovie(heroMovie) }
                    )
                    Spacer(modifier = Modifier.height(24.dp))
                }
            }

            // Trending Worldwide Section
            item {
                MovieRowSection(
                    title = "Trending Worldwide",
                    accentColor = NeonCyan,
                    movies = filteredMovies,
                    onSelectMovie = onSelectMovie
                )
                Spacer(modifier = Modifier.height(30.dp))
            }

            // Indian Blockbusters & Desi Cinema Section
            item {
                val indianMovies = movies.filter { it.category.equals("Indian", ignoreCase = true) || it.category.equals("Drama", ignoreCase = true) }
                MovieRowSection(
                    title = "Indian Blockbusters & Desi Cinema",
                    accentColor = Color(0xFFFF9900),
                    movies = if (selectedCategory == "All") (indianMovies.ifEmpty { movies }) else filteredMovies,
                    onSelectMovie = onSelectMovie
                )
                Spacer(modifier = Modifier.height(30.dp))
            }

            // Anime Universe & Animation Section
            item {
                val animeMovies = movies.filter { it.category.equals("Anime", ignoreCase = true) }
                MovieRowSection(
                    title = "Anime Universe & Animation",
                    accentColor = Color(0xFFBD00FF),
                    movies = if (selectedCategory == "All") (animeMovies.ifEmpty { movies.reversed() }) else filteredMovies,
                    onSelectMovie = onSelectMovie
                )
            }
        }

        // Floating Frosted Header (Apple TV / Netflix style)
        FloatingHeaderOverlay(
            categories = categories,
            selectedCategory = selectedCategory,
            onSelectCategory = { selectedCategory = it }
        )
    }
}

@Composable
fun FloatingHeaderOverlay(
    categories: List<String>,
    selectedCategory: String,
    onSelectCategory: (String) -> Unit,
    modifier: Modifier = Modifier,
) {
    Box(
        modifier = modifier
            .fillMaxWidth()
            .background(
                Brush.verticalGradient(
                    colors = listOf(
                        DeepSpaceBlack.copy(alpha = 0.95f),
                        DeepSpaceBlack.copy(alpha = 0.70f),
                        Color.Transparent
                    ),
                    startY = 0f,
                    endY = 320f
                )
            )
            .statusBarsPadding()
    ) {
        Column(modifier = Modifier.fillMaxWidth()) {
            // Branding & Action Bar (Clean, premium logo without ugly box)
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(horizontal = 20.dp, vertical = 8.dp),
                horizontalArrangement = Arrangement.SpaceBetween,
                verticalAlignment = Alignment.CenterVertically
            ) {
                // Logo: Glowing gradient emblem + STREAM in White + X in Radiant Cyan
                Row(verticalAlignment = Alignment.CenterVertically) {
                    Box(
                        modifier = Modifier
                            .size(32.dp)
                            .shadow(12.dp, CircleShape, spotColor = NeonCyan)
                            .background(
                                Brush.linearGradient(listOf(NeonCyan, ElectricBlue)),
                                CircleShape
                            ),
                        contentAlignment = Alignment.Center
                    ) {
                        Icon(
                            imageVector = Icons.Default.PlayArrow,
                            contentDescription = null,
                            tint = Color.Black,
                            modifier = Modifier.size(18.dp)
                        )
                    }

                    Spacer(modifier = Modifier.width(10.dp))

                    Row(verticalAlignment = Alignment.CenterVertically) {
                        Text(
                            text = "STREAM",
                            color = Color.White,
                            fontSize = 20.sp,
                            fontWeight = FontWeight.Black,
                            letterSpacing = 2.sp
                        )
                        Text(
                            text = "X",
                            color = NeonCyan,
                            fontSize = 22.sp,
                            fontWeight = FontWeight.Black,
                            letterSpacing = 2.sp
                        )
                    }
                }

                // Circular Glass Notification Button
                Box(
                    modifier = Modifier
                        .size(36.dp)
                        .clip(CircleShape)
                        .background(Color.White.copy(alpha = 0.12f))
                        .clickable {},
                    contentAlignment = Alignment.Center
                ) {
                    Icon(
                        imageVector = Icons.Default.Notifications,
                        contentDescription = "Notifications",
                        tint = Color.White,
                        modifier = Modifier.size(17.dp)
                    )
                    // Notification dot
                    Box(
                        modifier = Modifier
                            .size(7.dp)
                            .align(Alignment.TopEnd)
                            .padding(top = 4.dp, end = 4.dp)
                            .background(NeonCyan, CircleShape)
                    )
                }
            }

            Spacer(modifier = Modifier.height(4.dp))

            // Frosted Glass Category Pills Row
            LazyRow(
                contentPadding = PaddingValues(horizontal = 20.dp),
                horizontalArrangement = Arrangement.spacedBy(8.dp),
                modifier = Modifier.padding(bottom = 12.dp)
            ) {
                items(categories) { cat ->
                    val isSelected = cat == selectedCategory
                    val bgCol by animateColorAsState(
                        if (isSelected) NeonCyan else Color.Black.copy(alpha = 0.45f),
                        label = "pill_bg"
                    )
                    val textCol by animateColorAsState(
                        if (isSelected) Color.Black else Color.White.copy(alpha = 0.9f),
                        label = "pill_text"
                    )

                    Surface(
                        shape = RoundedCornerShape(18.dp),
                        color = bgCol,
                        border = BorderStroke(
                            if (isSelected) 1.2.dp else 0.8.dp,
                            if (isSelected) NeonCyan else Color.White.copy(alpha = 0.2f)
                        ),
                        modifier = Modifier
                            .then(
                                if (isSelected) Modifier.shadow(10.dp, RoundedCornerShape(18.dp), spotColor = NeonCyan)
                                else Modifier
                            )
                            .clickable { onSelectCategory(cat) }
                    ) {
                        Text(
                            text = cat,
                            color = textCol,
                            fontWeight = if (isSelected) FontWeight.ExtraBold else FontWeight.SemiBold,
                            fontSize = 12.sp,
                            letterSpacing = 0.4.sp,
                            modifier = Modifier.padding(horizontal = 16.dp, vertical = 7.dp)
                        )
                    }
                }
            }
        }
    }
}

@Composable
fun ImmersiveHeroSection(
    movie: MovieItem,
    isSaved: Boolean,
    onToggleWatchlist: () -> Unit,
    onPlay: () -> Unit,
    modifier: Modifier = Modifier,
) {
    val context = LocalContext.current

    Box(
        modifier = modifier
            .fillMaxWidth()
            .height(520.dp)
            .background(DarkBlueGrey)
    ) {
        // Full bleed background art
        AsyncImage(
            model = ImageRequest.Builder(context)
                .data(movie.bannerUrl)
                .crossfade(true)
                .build(),
            contentDescription = movie.title,
            contentScale = ContentScale.Crop,
            modifier = Modifier.fillMaxSize()
        )

        // Seamless multi-layer cinema gradient
        Box(
            modifier = Modifier
                .fillMaxSize()
                .background(
                    Brush.verticalGradient(
                        colors = listOf(
                            DeepSpaceBlack.copy(alpha = 0.75f),
                            Color.Transparent,
                            Color.Transparent,
                            DeepSpaceBlack.copy(alpha = 0.5f),
                            DeepSpaceBlack.copy(alpha = 0.92f),
                            DeepSpaceBlack
                        ),
                        startY = 0f,
                        endY = Float.POSITIVE_INFINITY
                    )
                )
        )

        // Hero Details & Sleek Action Buttons
        Column(
            modifier = Modifier
                .align(Alignment.BottomStart)
                .padding(horizontal = 20.dp, vertical = 12.dp)
        ) {
            // STREAMX ORIGINAL Tag
            Surface(
                color = NeonCyan.copy(alpha = 0.18f),
                shape = RoundedCornerShape(4.dp),
                border = BorderStroke(0.8.dp, NeonCyan.copy(alpha = 0.8f))
            ) {
                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    modifier = Modifier.padding(horizontal = 8.dp, vertical = 3.dp)
                ) {
                    Icon(
                        imageVector = Icons.Default.AutoAwesome,
                        contentDescription = null,
                        tint = NeonCyan,
                        modifier = Modifier.size(10.dp)
                    )
                    Spacer(modifier = Modifier.width(4.dp))
                    Text(
                        text = "STREAMX ORIGINAL · ${movie.category.uppercase()}",
                        color = NeonCyan,
                        fontSize = 10.sp,
                        fontWeight = FontWeight.ExtraBold,
                        letterSpacing = 1.2.sp
                    )
                }
            }

            Spacer(modifier = Modifier.height(10.dp))

            // Cinematic Title
            Text(
                text = movie.title,
                color = Color.White,
                fontSize = 28.sp,
                fontWeight = FontWeight.Black,
                letterSpacing = (-0.5).sp,
                lineHeight = 32.sp,
                maxLines = 1,
                overflow = TextOverflow.Ellipsis
            )

            Spacer(modifier = Modifier.height(6.dp))

            // Metadata Row: Rating, Badges, Year
            Row(verticalAlignment = Alignment.CenterVertically) {
                Icon(
                    imageVector = Icons.Default.Star,
                    contentDescription = null,
                    tint = StarGold,
                    modifier = Modifier.size(13.dp)
                )
                Spacer(modifier = Modifier.width(4.dp))
                Text(
                    text = "${movie.rating}",
                    color = Color.White,
                    fontSize = 12.sp,
                    fontWeight = FontWeight.Bold
                )
                Spacer(modifier = Modifier.width(10.dp))
                Surface(
                    color = Color.White.copy(alpha = 0.15f),
                    shape = RoundedCornerShape(3.dp)
                ) {
                    Text(
                        text = "4K ULTRA HD",
                        color = Color.White,
                        fontSize = 9.sp,
                        fontWeight = FontWeight.Bold,
                        letterSpacing = 0.6.sp,
                        modifier = Modifier.padding(horizontal = 5.dp, vertical = 2.dp)
                    )
                }
                Spacer(modifier = Modifier.width(6.dp))
                Surface(
                    color = Color.White.copy(alpha = 0.15f),
                    shape = RoundedCornerShape(3.dp)
                ) {
                    Text(
                        text = "DOLBY ATMOS",
                        color = Color.White,
                        fontSize = 9.sp,
                        fontWeight = FontWeight.Bold,
                        letterSpacing = 0.6.sp,
                        modifier = Modifier.padding(horizontal = 5.dp, vertical = 2.dp)
                    )
                }
                Spacer(modifier = Modifier.width(8.dp))
                Text(
                    text = "${movie.releaseYear}",
                    color = Color.White.copy(alpha = 0.6f),
                    fontSize = 11.5.sp,
                    fontWeight = FontWeight.Medium
                )
            }

            Spacer(modifier = Modifier.height(8.dp))

            // Plot Description
            Text(
                text = movie.description,
                color = Color.White.copy(alpha = 0.72f),
                fontSize = 12.sp,
                lineHeight = 16.5.sp,
                maxLines = 2,
                overflow = TextOverflow.Ellipsis
            )

            Spacer(modifier = Modifier.height(16.dp))

            // Apple TV / Netflix signature button row
            Row(verticalAlignment = Alignment.CenterVertically) {
                // Primary "Play Now" Button (Crisp White Pill)
                Surface(
                    shape = RoundedCornerShape(22.dp),
                    color = Color.White,
                    modifier = Modifier
                        .height(40.dp)
                        .shadow(12.dp, RoundedCornerShape(22.dp), spotColor = Color.White.copy(alpha = 0.35f))
                        .clickable { onPlay() }
                ) {
                    Row(
                        modifier = Modifier.padding(horizontal = 22.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Icon(
                            imageVector = Icons.Default.PlayArrow,
                            contentDescription = null,
                            tint = Color.Black,
                            modifier = Modifier.size(16.dp)
                        )
                        Spacer(modifier = Modifier.width(8.dp))
                        Text(
                            text = "Play Now",
                            color = Color.Black,
                            fontWeight = FontWeight.Black,
                            fontSize = 13.5.sp,
                            letterSpacing = 0.3.sp
                        )
                    }
                }

                Spacer(modifier = Modifier.width(12.dp))

                // Secondary "My List" Button (Frosted Glass Pill)
                Surface(
                    shape = RoundedCornerShape(22.dp),
                    color = Color.White.copy(alpha = 0.12f),
                    border = BorderStroke(
                        1.dp,
                        if (isSaved) NeonCyan else Color.White.copy(alpha = 0.25f)
                    ),
                    modifier = Modifier
                        .height(40.dp)
                        .clickable { onToggleWatchlist() }
                ) {
                    Row(
                        modifier = Modifier.padding(horizontal = 18.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        Icon(
                            imageVector = if (isSaved) Icons.Default.Check else Icons.Default.PlusOne,
                            contentDescription = null,
                            tint = if (isSaved) NeonCyan else Color.White,
                            modifier = Modifier.size(15.dp)
                        )
                        Spacer(modifier = Modifier.width(7.dp))
                        Text(
                            text = if (isSaved) "In List" else "My List",
                            color = if (isSaved) NeonCyan else Color.White,
                            fontWeight = FontWeight.Bold,
                            fontSize = 13.sp,
                            letterSpacing = 0.2.sp
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
    accentColor: Color = NeonCyan,
    movies: List<MovieItem>,
    onSelectMovie: (MovieItem) -> Unit,
    modifier: Modifier = Modifier,
) {
    val context = LocalContext.current

    Column(modifier = modifier.fillMaxWidth()) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(horizontal = 20.dp),
            horizontalArrangement = Arrangement.SpaceBetween,
            verticalAlignment = Alignment.CenterVertically
        ) {
            Row(verticalAlignment = Alignment.CenterVertically) {
                Box(
                    modifier = Modifier
                        .size(width = 3.5.dp, height = 16.dp)
                        .shadow(8.dp, RoundedCornerShape(2.dp), spotColor = accentColor)
                        .background(accentColor, RoundedCornerShape(2.dp))
                )
                Spacer(modifier = Modifier.width(8.dp))
                Text(
                    text = title,
                    color = Color.White,
                    fontSize = 17.sp,
                    fontWeight = FontWeight.ExtraBold,
                    letterSpacing = 0.3.sp
                )
            }
            Text(
                text = "See All",
                color = accentColor,
                fontSize = 12.sp,
                fontWeight = FontWeight.SemiBold
            )
        }

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
