import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';

import 'main.dart';
import 'admin_creator_studio.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  void _showEditProfileDialog(BuildContext context, String currentName) {
    final textController = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF14141E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: const Text('Edit Display Name', style: TextStyle(color: Colors.white, fontSize: 18)),
          content: TextField(
            controller: textController,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Enter new display name',
              hintStyle: const TextStyle(color: Color(0xFF6B7280)),
              enabledBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Color(0xFF262638)),
                borderRadius: BorderRadius.circular(10),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Color(0xFF00F0FF)),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.white60)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00F0FF),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                final newName = textController.text.trim();
                if (newName.isNotEmpty) {
                  context.read<AppAuthProvider>().updateProfileName(newName);
                }
                Navigator.pop(context);
              },
              child: const Text('Save', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  void _showEmailSwitcherDialog(BuildContext context, String currentEmail) {
    final textController = TextEditingController(text: currentEmail);
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF14141E),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          title: const Text('Switch Email (Admin Gate Test)', style: TextStyle(color: Colors.white, fontSize: 18)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Enter verseshow94@gmail.com to unlock Creator Studio, or any other email to lock it.',
                style: TextStyle(color: Color(0xFF7E849E), fontSize: 12),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: textController,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Email address',
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFF262638)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Color(0xFF00F0FF)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                context.read<AppAuthProvider>().switchEmailForTesting('user@streamx.io');
                Navigator.pop(context);
              },
              child: const Text('Regular User', style: TextStyle(color: Colors.white60)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00F0FF),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              onPressed: () {
                context.read<AppAuthProvider>().switchEmailForTesting(textController.text.trim());
                Navigator.pop(context);
              },
              child: const Text('Set Email', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AppAuthProvider>();
    final userEmail = auth.email.trim();
    // Admin Gate Logic: Strictly equals verseshow94@gmail.com
    final bool isAdmin = userEmail == 'verseshow94@gmail.com';

    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0F),
      appBar: AppBar(
        title: const Text('Account Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.logOut, color: Colors.white70),
            onPressed: () => auth.signOut(),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        physics: const BouncingScrollPhysics(),
        children: [
          // User Avatar & Info Card
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFF14141E),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color(0xFF1E1E2C)),
            ),
            child: Row(
              children: [
                // Avatar with glowing border
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00F0FF), Color(0xFF0080FF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF00F0FF).withValues(alpha: 0.35),
                        blurRadius: 16,
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      auth.displayName.isNotEmpty ? auth.displayName[0].toUpperCase() : 'U',
                      style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 26),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        auth.displayName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        userEmail,
                        style: const TextStyle(color: Color(0xFF7E849E), fontSize: 13),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isAdmin
                              ? const Color(0xFF00F0FF).withValues(alpha: 0.15)
                              : Colors.white.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: isAdmin ? const Color(0xFF00F0FF) : Colors.white24,
                            width: 1,
                          ),
                        ),
                        child: Text(
                          isAdmin ? 'ULTRA ADMIN' : 'PREMIUM VIP',
                          style: TextStyle(
                            color: isAdmin ? const Color(0xFF00F0FF) : Colors.white70,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // Edit Profile Action Tile
          _ProfileOptionTile(
            icon: LucideIcons.userCheck,
            title: 'Edit Profile Name',
            subtitle: 'Update your public streaming handle',
            onTap: () => _showEditProfileDialog(context, auth.displayName),
          ),
          const SizedBox(height: 10),

          _ProfileOptionTile(
            icon: LucideIcons.keyRound,
            title: 'Test Email Switcher',
            subtitle: 'Toggle between admin ($userEmail) & standard user',
            onTap: () => _showEmailSwitcherDialog(context, userEmail),
          ),
          const SizedBox(height: 10),

          _ProfileOptionTile(
            icon: LucideIcons.sliders,
            title: 'Playback & Refresh Rate',
            subtitle: 'Enforced 120Hz SilkFPS & 4K Ultra Bitrate',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Display engine tuned to 120Hz maximum hardware refresh rate.'),
                  backgroundColor: Color(0xFF14141E),
                ),
              );
            },
          ),

          const SizedBox(height: 32),

          // -------------------------------------------------------------
          // SECRET ADMIN GATE: Render IF AND ONLY IF email == verseshow94@gmail.com
          // -------------------------------------------------------------
          if (isAdmin) ...[
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(18),
                gradient: const LinearGradient(
                  colors: [Color(0xFF00F0FF), Color(0xFF00A2FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF00F0FF).withValues(alpha: 0.5),
                    blurRadius: 26,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const AdminCreatorStudioScreen()),
                    );
                  },
                  borderRadius: BorderRadius.circular(18),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(LucideIcons.sparkles, color: Colors.black, size: 26),
                        SizedBox(width: 12),
                        Text(
                          'CREATOR STUDIO',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.0,
                          ),
                        ),
                        SizedBox(width: 12),
                        Icon(LucideIcons.arrowRight, color: Colors.black, size: 22),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Center(
              child: Text(
                'SECURITY CLEARANCE VERIFIED · verseshow94@gmail.com',
                style: TextStyle(
                  color: Color(0xFF00F0FF),
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),
            ),
          ] else ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF14141E),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFF1E1E2C)),
              ),
              child: const Row(
                children: [
                  Icon(LucideIcons.lock, color: Color(0xFF7E849E), size: 20),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Creator Studio is restricted to authorized studio admins.',
                      style: TextStyle(color: Color(0xFF7E849E), fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ProfileOptionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ProfileOptionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF14141E),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF1E1E2C)),
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF1E1E2C),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: const Color(0xFF00F0FF), size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: Color(0xFF7E849E), fontSize: 12),
        ),
        trailing: const Icon(LucideIcons.chevronRight, color: Color(0xFF7E849E), size: 18),
      ),
    );
  }
}
