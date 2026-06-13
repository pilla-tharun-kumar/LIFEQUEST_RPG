import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme.dart';
import '../providers/user_provider.dart';
import '../providers/quest_provider.dart';
import '../providers/pet_provider.dart';
import '../widgets/pet_painter.dart';

class DashboardTab extends ConsumerWidget {
  const DashboardTab({super.key});

  void _showLevelUpDialog(BuildContext context, int newLevel) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: RpgColors.cardBg,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: RpgColors.accent, width: 2),
            boxShadow: [
              BoxShadow(
                color: RpgColors.accent.withAlpha(50),
                blurRadius: 20,
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.workspace_premium, color: RpgColors.accent, size: 80),
              const SizedBox(height: 16),
              Text(
                'LEVEL UP!',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: RpgColors.accent,
                  fontSize: 28,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You have reached Level $newLevel!',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Rewards Earned:\n+100 Coins\nNew title unlocked!',
                style: TextStyle(color: RpgColors.textSecondary, height: 1.5),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: RpgColors.accent,
                  foregroundColor: Colors.black,
                ),
                child: const Text('CLAIM REWARDS'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(userProfileProvider);
    final pet = ref.watch(petProvider);
    final quests = ref.watch(questProvider);

    if (user == null) return const SizedBox();

    final activeQuests = quests.where((q) => !q.isCompleted).toList();
    final dailyQuests = activeQuests.where((q) => q.type == 'daily').toList();
    final weeklyQuests = activeQuests.where((q) => q.type == 'weekly').toList();

    double xpPercentage = user.xp / user.requiredXp;
    if (xpPercentage.isNaN || xpPercentage.isInfinite) xpPercentage = 0.0;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // XP Card
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: RpgColors.cardBg,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: RpgColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'LEVEL PROGRESSION',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: RpgColors.primary,
                        letterSpacing: 1.2,
                      ),
                    ),
                    Text(
                      '${user.xp} / ${user.requiredXp} XP',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Stack(
                  children: [
                    Container(
                      height: 12,
                      decoration: BoxDecoration(
                        color: RpgColors.background,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 500),
                      width: MediaQuery.of(context).size.width * 0.78 * xpPercentage,
                      height: 12,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [RpgColors.primary, Color(0xff00b0ff)],
                        ),
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: RpgColors.primary.withAlpha(150),
                            blurRadius: 6,
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Pet Summary Panel
          if (pet != null)
            GestureDetector(
              onTap: () {
                // Navigate to pet screen tab (index 2) by triggering action?
                // For simplicity, let's keep it styled and clickable if needed.
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: RpgColors.cardBg,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: RpgColors.border),
                ),
                child: Row(
                  children: [
                    // Mini Pet Render
                    SizedBox(
                      width: 80,
                      height: 80,
                      child: PetWidget(stage: pet.stage, visualType: pet.visualType, size: 80),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pet.name.toUpperCase(),
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          Text(
                            'Evolution Stage: ${pet.stage[0].toUpperCase()}${pet.stage.substring(1)}',
                            style: const TextStyle(fontSize: 12, color: RpgColors.textSecondary),
                          ),
                          const SizedBox(height: 8),
                          
                          // Happiness meter
                          _buildMiniMeter(
                            context: context, 
                            label: 'Happiness', 
                            value: pet.happiness, 
                            color: RpgColors.secondary,
                          ),
                          const SizedBox(height: 6),
                          
                          // Hunger meter
                          _buildMiniMeter(
                            context: context, 
                            label: 'Hunger', 
                            value: pet.hunger, 
                            color: RpgColors.accent,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 20),

          // Active Quests Overview
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'ACTIVE QUESTS (${activeQuests.length})',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 18, letterSpacing: 1),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (activeQuests.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: RpgColors.cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: RpgColors.border, style: BorderStyle.none),
              ),
              child: const Column(
                children: [
                  Icon(Icons.auto_awesome, color: RpgColors.textSecondary, size: 40),
                  SizedBox(height: 12),
                  Text(
                    'All quests cleared! Go plan some new ones.',
                    style: TextStyle(color: RpgColors.textSecondary, fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            )
          else ...[
            if (dailyQuests.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 8, top: 8),
                child: Text('DAILY QUESTS', style: TextStyle(fontSize: 12, color: RpgColors.primary, fontWeight: FontWeight.bold, letterSpacing: 1)),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: dailyQuests.length,
                itemBuilder: (context, index) {
                  final quest = dailyQuests[index];
                  return _buildQuestTile(context, ref, quest);
                },
              ),
            ],
            if (weeklyQuests.isNotEmpty) ...[
              const Padding(
                padding: EdgeInsets.only(left: 4, bottom: 8, top: 12),
                child: Text('WEEKLY QUESTS', style: TextStyle(fontSize: 12, color: RpgColors.secondary, fontWeight: FontWeight.bold, letterSpacing: 1)),
              ),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: weeklyQuests.length,
                itemBuilder: (context, index) {
                  final quest = weeklyQuests[index];
                  return _buildQuestTile(context, ref, quest);
                },
              ),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildMiniMeter({
    required BuildContext context,
    required String label,
    required int value,
    required Color color,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 70,
          child: Text(
            label, 
            style: const TextStyle(fontSize: 10, color: RpgColors.textSecondary),
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: RpgColors.background,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              Container(
                height: 6,
                width: MediaQuery.of(context).size.width * 0.3 * (value / 100),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(3),
                  boxShadow: [
                    BoxShadow(
                      color: color.withAlpha(120),
                      blurRadius: 4,
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '$value%',
          style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildQuestTile(BuildContext context, WidgetRef ref, dynamic quest) {
    Color difficultyColor;
    switch (quest.difficulty) {
      case 'easy':
        difficultyColor = RpgColors.success;
        break;
      case 'medium':
        difficultyColor = RpgColors.accent;
        break;
      default:
        difficultyColor = RpgColors.secondary;
    }

    IconData categoryIcon;
    switch (quest.category) {
      case 'coding':
        categoryIcon = Icons.code;
        break;
      case 'fitness':
        categoryIcon = Icons.fitness_center;
        break;
      case 'learning':
        categoryIcon = Icons.menu_book;
        break;
      default:
        categoryIcon = Icons.business_center;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: RpgColors.border,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(categoryIcon, color: RpgColors.primary, size: 20),
        ),
        title: Text(
          quest.title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
        ),
        subtitle: Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: difficultyColor.withAlpha(30),
                border: Border.all(color: difficultyColor.withAlpha(120)),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                quest.difficulty.toUpperCase(),
                style: TextStyle(fontSize: 8, color: difficultyColor, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '+${quest.xpReward} XP / +${quest.coinReward} G',
              style: const TextStyle(fontSize: 10, color: RpgColors.textSecondary),
            ),
          ],
        ),
        trailing: Checkbox(
          value: quest.isCompleted,
          activeColor: RpgColors.primary,
          checkColor: Colors.black,
          onChanged: (val) {
            if (val == true) {
              ref.read(questProvider.notifier).completeQuest(
                quest.id,
                onLevelUp: (lvl) {
                  _showLevelUpDialog(context, lvl);
                },
              );
            }
          },
        ),
      ),
    );
  }
}
