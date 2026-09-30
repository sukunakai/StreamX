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
import androidx.compose.foundation.shape.CircleShape
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.automirrored.filled.ArrowForward
import androidx.compose.material.icons.filled.AutoAwesome
import androidx.compose.material.icons.filled.ChevronRight
import androidx.compose.material.icons.filled.Lock
import androidx.compose.material.icons.filled.ManageAccounts
import androidx.compose.material.icons.filled.Speed
import androidx.compose.material.icons.filled.SwitchAccount
import androidx.compose.material3.AlertDialog
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Icon
import androidx.compose.material3.OutlinedTextField
import androidx.compose.material3.OutlinedTextFieldDefaults
import androidx.compose.material3.Surface
import androidx.compose.material3.Text
import androidx.compose.material3.TextButton
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
import androidx.compose.ui.graphics.vector.ImageVector
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.ui.theme.DarkBlueGrey
import com.example.ui.theme.DeepSpaceBlack
import com.example.ui.theme.ElectricBlue
import com.example.ui.theme.NeonCyan
import com.example.ui.theme.SubtitleGrey

@Composable
fun ProfileScreen(
    userEmail: String,
    displayName: String,
    onUpdateDisplayName: (String) -> Unit,
    onSwitchEmail: (String) -> Unit,
    onOpenCreatorStudio: () -> Unit,
    modifier: Modifier = Modifier,
) {
    // Admin Gate Logic: IF AND ONLY IF email strictly equals verseshow94@gmail.com
    val isAdmin = userEmail.trim() == "verseshow94@gmail.com"

    var showEditProfileDialog by remember { mutableStateOf(false) }
    var showEmailSwitcherDialog by remember { mutableStateOf(false) }

    Column(
        modifier = modifier
            .fillMaxSize()
            .background(DeepSpaceBlack)
            .padding(16.dp)
    ) {
        Text(
            text = "Account Dashboard",
            color = Color.White,
            fontWeight = FontWeight.Bold,
            fontSize = 22.sp
        )

        Spacer(modifier = Modifier.height(16.dp))

        LazyColumn(
            verticalArrangement = Arrangement.spacedBy(14.dp),
            modifier = Modifier.fillMaxSize()
        ) {
            // User Avatar & Info Card
            item {
                Surface(
                    color = DarkBlueGrey,
                    shape = RoundedCornerShape(20.dp),
                    border = BorderStroke(1.dp, Color(0xFF1E1E2C)),
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Row(
                        modifier = Modifier.padding(20.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        // Glowing Avatar
                        Box(
                            modifier = Modifier
                                .size(64.dp)
                                .shadow(16.dp, CircleShape, spotColor = NeonCyan)
                                .background(
                                    Brush.linearGradient(listOf(NeonCyan, ElectricBlue)),
                                    CircleShape
                                ),
                            contentAlignment = Alignment.Center
                        ) {
                            Text(
                                text = displayName.take(1).uppercase(),
                                color = Color.Black,
                                fontWeight = FontWeight.Black,
                                fontSize = 26.sp
                            )
                        }

                        Spacer(modifier = Modifier.width(16.dp))

                        Column {
                            Text(
                                text = displayName,
                                color = Color.White,
                                fontSize = 18.sp,
                                fontWeight = FontWeight.Bold
                            )
                            Spacer(modifier = Modifier.height(3.dp))
                            Text(
                                text = userEmail,
                                color = SubtitleGrey,
                                fontSize = 13.sp
                            )
                            Spacer(modifier = Modifier.height(6.dp))
                            Surface(
                                color = if (isAdmin) NeonCyan.copy(alpha = 0.15f) else Color.White.copy(alpha = 0.08f),
                                shape = RoundedCornerShape(6.dp),
                                border = BorderStroke(1.dp, if (isAdmin) NeonCyan else Color.White.copy(alpha = 0.2f))
                            ) {
                                Text(
                                    text = if (isAdmin) "ULTRA ADMIN" else "PREMIUM VIP",
                                    color = if (isAdmin) NeonCyan else Color.White.copy(alpha = 0.8f),
                                    fontSize = 10.sp,
                                    fontWeight = FontWeight.Bold,
                                    letterSpacing = 1.sp,
                                    modifier = Modifier.padding(horizontal = 8.dp, vertical = 3.dp)
                                )
                            }
                        }
                    }
                }
            }

            // Edit Profile Name
            item {
                ProfileOptionCard(
                    icon = Icons.Default.ManageAccounts,
                    title = "Edit Profile Name",
                    subtitle = "Update your public streaming handle",
                    onClick = { showEditProfileDialog = true }
                )
            }

            // Test Email Switcher (Demonstrating Admin Gate)
            item {
                ProfileOptionCard(
                    icon = Icons.Default.SwitchAccount,
                    title = "Test Email Switcher",
                    subtitle = "Toggle admin ($userEmail) vs regular user",
                    onClick = { showEmailSwitcherDialog = true }
                )
            }

            // 120Hz Hardware Status
            item {
                ProfileOptionCard(
                    icon = Icons.Default.Speed,
                    title = "Playback & Refresh Rate",
                    subtitle = "Enforced 120Hz SilkFPS & 4K Ultra Bitrate",
                    onClick = {}
                )
            }

            // -------------------------------------------------------------
            // SECRET ADMIN GATE: Render IF AND ONLY IF email == verseshow94@gmail.com
            // -------------------------------------------------------------
            item {
                Spacer(modifier = Modifier.height(10.dp))
                if (isAdmin) {
                    Column {
                        // Massive, glowing Neon Cyan button titled "CREATOR STUDIO"
                        Surface(
                            shape = RoundedCornerShape(18.dp),
                            color = NeonCyan,
                            modifier = Modifier
                                .fillMaxWidth()
                                .height(64.dp)
                                .shadow(24.dp, RoundedCornerShape(18.dp), spotColor = NeonCyan)
                                .clickable { onOpenCreatorStudio() }
                        ) {
                            Row(
                                modifier = Modifier
                                    .fillMaxSize()
                                    .background(
                                        Brush.horizontalGradient(
                                            listOf(NeonCyan, ElectricBlue)
                                        )
                                    ),
                                horizontalArrangement = Arrangement.Center,
                                verticalAlignment = Alignment.CenterVertically
                            ) {
                                Icon(
                                    imageVector = Icons.Default.AutoAwesome,
                                    contentDescription = null,
                                    tint = Color.Black,
                                    modifier = Modifier.size(26.dp)
                                )
                                Spacer(modifier = Modifier.width(12.dp))
                                Text(
                                    text = "CREATOR STUDIO",
                                    color = Color.Black,
                                    fontSize = 18.sp,
                                    fontWeight = FontWeight.Black,
                                    letterSpacing = 2.sp
                                )
                                Spacer(modifier = Modifier.width(12.dp))
                                Icon(
                                    imageVector = Icons.AutoMirrored.Filled.ArrowForward,
                                    contentDescription = null,
                                    tint = Color.Black,
                                    modifier = Modifier.size(22.dp)
                                )
                            }
                        }

                        Spacer(modifier = Modifier.height(8.dp))
                        Text(
                            text = "SECURITY CLEARANCE VERIFIED · verseshow94@gmail.com",
                            color = NeonCyan,
                            fontSize = 11.sp,
                            fontWeight = FontWeight.Bold,
                            letterSpacing = 1.2.sp,
                            modifier = Modifier.align(Alignment.CenterHorizontally)
                        )
                    }
                } else {
                    Surface(
                        color = DarkBlueGrey,
                        shape = RoundedCornerShape(14.dp),
                        border = BorderStroke(1.dp, Color(0xFF1E1E2C)),
                        modifier = Modifier.fillMaxWidth()
                    ) {
                        Row(
                            modifier = Modifier.padding(16.dp),
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            Icon(
                                imageVector = Icons.Default.Lock,
                                contentDescription = null,
                                tint = SubtitleGrey,
                                modifier = Modifier.size(20.dp)
                            )
                            Spacer(modifier = Modifier.width(12.dp))
                            Text(
                                text = "Creator Studio is restricted to authorized studio admins.",
                                color = SubtitleGrey,
                                fontSize = 12.sp
                            )
                        }
                    }
                }
            }
        }
    }

    // Edit Profile Dialog
    if (showEditProfileDialog) {
        var tempName by remember { mutableStateOf(displayName) }
        AlertDialog(
            onDismissRequest = { showEditProfileDialog = false },
            containerColor = DarkBlueGrey,
            title = { Text(text = "Edit Profile Name", color = Color.White) },
            text = {
                OutlinedTextField(
                    value = tempName,
                    onValueChange = { tempName = it },
                    singleLine = true,
                    colors = OutlinedTextFieldDefaults.colors(
                        focusedBorderColor = NeonCyan,
                        unfocusedBorderColor = Color(0xFF262638),
                        focusedTextColor = Color.White,
                        unfocusedTextColor = Color.White
                    )
                )
            },
            confirmButton = {
                Button(
                    onClick = {
                        if (tempName.isNotBlank()) onUpdateDisplayName(tempName)
                        showEditProfileDialog = false
                    },
                    colors = ButtonDefaults.buttonColors(containerColor = NeonCyan, contentColor = Color.Black)
                ) {
                    Text("Save", fontWeight = FontWeight.Bold)
                }
            },
            dismissButton = {
                TextButton(onClick = { showEditProfileDialog = false }) {
                    Text("Cancel", color = Color.White.copy(alpha = 0.7f))
                }
            }
        )
    }

    // Email Switcher Dialog for testing Admin Gate
    if (showEmailSwitcherDialog) {
        var tempEmail by remember { mutableStateOf(userEmail) }
        AlertDialog(
            onDismissRequest = { showEmailSwitcherDialog = false },
            containerColor = DarkBlueGrey,
            title = { Text(text = "Admin Gate Email Switcher", color = Color.White) },
            text = {
                Column {
                    Text(
                        text = "Set verseshow94@gmail.com to unlock Creator Studio, or any other email to lock it.",
                        color = SubtitleGrey,
                        fontSize = 12.sp
                    )
                    Spacer(modifier = Modifier.height(10.dp))
                    OutlinedTextField(
                        value = tempEmail,
                        onValueChange = { tempEmail = it },
                        singleLine = true,
                        colors = OutlinedTextFieldDefaults.colors(
                            focusedBorderColor = NeonCyan,
                            unfocusedBorderColor = Color(0xFF262638),
                            focusedTextColor = Color.White,
                            unfocusedTextColor = Color.White
                        )
                    )
                }
            },
            confirmButton = {
                Button(
                    onClick = {
                        onSwitchEmail(tempEmail)
                        showEmailSwitcherDialog = false
                    },
                    colors = ButtonDefaults.buttonColors(containerColor = NeonCyan, contentColor = Color.Black)
                ) {
                    Text("Apply Email", fontWeight = FontWeight.Bold)
                }
            },
            dismissButton = {
                TextButton(
                    onClick = {
                        onSwitchEmail("user@streamx.io")
                        showEmailSwitcherDialog = false
                    }
                ) {
                    Text("Set Standard User", color = Color.White.copy(alpha = 0.7f))
                }
            }
        )
    }
}

@Composable
fun ProfileOptionCard(
    icon: ImageVector,
    title: String,
    subtitle: String,
    onClick: () -> Unit,
    modifier: Modifier = Modifier,
) {
    Surface(
        color = DarkBlueGrey,
        shape = RoundedCornerShape(16.dp),
        border = BorderStroke(1.dp, Color(0xFF1E1E2C)),
        modifier = modifier
            .fillMaxWidth()
            .clickable { onClick() }
    ) {
        Row(
            modifier = Modifier.padding(16.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            Box(
                modifier = Modifier
                    .size(42.dp)
                    .background(Color(0xFF1E1E2C), RoundedCornerShape(12.dp)),
                contentAlignment = Alignment.Center
            ) {
                Icon(
                    imageVector = icon,
                    contentDescription = null,
                    tint = NeonCyan,
                    modifier = Modifier.size(20.dp)
                )
            }

            Spacer(modifier = Modifier.width(14.dp))

            Column(modifier = Modifier.weight(1f)) {
                Text(
                    text = title,
                    color = Color.White,
                    fontWeight = FontWeight.Bold,
                    fontSize = 14.sp
                )
                Spacer(modifier = Modifier.height(2.dp))
                Text(
                    text = subtitle,
                    color = SubtitleGrey,
                    fontSize = 12.sp
                )
            }

            Icon(
                imageVector = Icons.Default.ChevronRight,
                contentDescription = null,
                tint = SubtitleGrey,
                modifier = Modifier.size(18.dp)
            )
        }
    }
}
