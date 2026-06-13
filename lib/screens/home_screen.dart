import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme.dart';
import '../providers/auth_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/avatar_painter.dart';
import 'dashboard_tab.dart';
import 'quests_screen.dart';
import 'pet_screen.dart';
import 'skills_screen.dart';
import 'inventory_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    const DashboardTab(),
    const QuestsScreen(),
    const PetScreen(),
    const SkillsScreen(),
    const InventoryScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(userProfileProvider);


    if (user == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            AvatarWidget(avatarBase: user.avatarBase, outfitId: user.equippedOutfit, accessoryId: user.equippedAccessory, size: 36),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  user.username.toUpperCase(),
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, letterSpacing: 1),
                ),
                Text(
                  'Lvl ${user.level} - ${user.title}',
                  style: const TextStyle(fontSize: 10, color: RpgColors.primary),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // Coins Info
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            margin: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: RpgColors.cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: RpgColors.accent.withAlpha(120), width: 1),
            ),
            child: Row(
              children: [
                const Icon(Icons.monetization_on, color: RpgColors.accent, size: 16),
                const SizedBox(width: 4),
                Text(
                  '${user.coins}',
                  style: const TextStyle(color: RpgColors.accent, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          
          // Streak Info
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            margin: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: RpgColors.cardBg,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: RpgColors.secondary.withAlpha(120), width: 1),
            ),
            child: Row(
              children: [
                const Icon(Icons.local_fire_department, color: RpgColors.secondary, size: 16),
                const SizedBox(width: 4),
                Text(
                  '${user.streak}D',
                  style: const TextStyle(color: RpgColors.secondary, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          
          // Logout
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.grey, size: 20),
            onPressed: () {
              ref.read(authProvider.notifier).logout();
            },
          ),
        ],
        backgroundColor: RpgColors.cardBg,
        elevation: 2,
      ),
      body: _tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: RpgColors.cardBg,
        selectedItemColor: RpgColors.primary,
        unselectedItemColor: RpgColors.textSecondary,
        selectedLabelStyle: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
        unselectedLabelStyle: const TextStyle(fontSize: 10),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.checklist_outlined), activeIcon: Icon(Icons.checklist), label: 'Quests'),
          BottomNavigationBarItem(icon: Icon(Icons.pets_outlined), activeIcon: Icon(Icons.pets), label: 'Companion'),
          BottomNavigationBarItem(icon: Icon(Icons.account_tree_outlined), activeIcon: Icon(Icons.account_tree), label: 'Skills'),
          BottomNavigationBarItem(icon: Icon(Icons.storefront_outlined), activeIcon: Icon(Icons.storefront), label: 'Shop'),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
