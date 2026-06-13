import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme.dart';
import '../providers/user_provider.dart';
import '../providers/achievement_provider.dart';
import '../providers/quest_provider.dart';
import '../widgets/avatar_painter.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProfileProvider);
    final achievements = ref.watch(achievementProvider);
    final quests = ref.watch(questProvider);

    if (user == null) return const SizedBox();

    final completedCount = quests.where((q) => q.isCompleted).length;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Character Summary Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    AvatarWidget(
                      avatarBase: user.avatarBase,
                      outfitId: user.equippedOutfit,
                      accessoryId: user.equippedAccessory,
                      size: 110,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      user.username.toUpperCase(),
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 22, letterSpacing: 1.2),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.title,
                      style: const TextStyle(color: RpgColors.primary, fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: RpgColors.border),
                    const SizedBox(height: 12),
                    
                    // General Stats Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildStatMetric('QUESTS CLEARED', '$completedCount', Icons.done_all, RpgColors.success),
                        _buildStatMetric('MAIN STREAK', '${user.streak} days', Icons.local_fire_department, RpgColors.secondary),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Streaks breakdown
            Text(
              'DOMAINS CONSISTENCY STREAKS',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 14, letterSpacing: 1, color: RpgColors.primary),
            ),
            const SizedBox(height: 12),
            Card(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  children: [
                    _buildStreakRow('Coding Streaks', '${user.codingStreak} days', Icons.code, Colors.cyan),
                    const Divider(color: RpgColors.border),
                    _buildStreakRow('Fitness Streaks', '${user.fitnessStreak} days', Icons.fitness_center, Colors.green),
                    const Divider(color: RpgColors.border),
                    _buildStreakRow('Learning Streaks', '${user.readingStreak} days', Icons.menu_book, Colors.orange),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Achievements section
            Text(
              'HALL OF HEROIC ACHIEVEMENTS',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 14, letterSpacing: 1, color: RpgColors.primary),
            ),
            const SizedBox(height: 12),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.1,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: achievements.length,
              itemBuilder: (context, index) {
                final ach = achievements[index];
                final isUnlocked = ach.isUnlocked;

                return Card(
                  color: isUnlocked ? RpgColors.cardBg : RpgColors.cardBg.withOpacity(0.4),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: isUnlocked 
                          ? Border.all(color: RpgColors.accent.withAlpha(150), width: 1.5) 
                          : Border.all(color: RpgColors.border),
                    ),
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isUnlocked ? Icons.workspace_premium : Icons.lock_outline,
                          color: isUnlocked ? RpgColors.accent : Colors.grey,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          ach.title,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                            color: isUnlocked ? Colors.white : Colors.grey,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isUnlocked 
                              ? 'CLEARED! (+50G)' 
                              : '${ach.currentValue} / ${ach.targetValue} steps',
                          style: TextStyle(
                            fontSize: 9,
                            color: isUnlocked ? RpgColors.success : RpgColors.textSecondary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatMetric(String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 9, color: RpgColors.textSecondary, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildStreakRow(String title, String val, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ],
          ),
          Text(
            val,
            style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
