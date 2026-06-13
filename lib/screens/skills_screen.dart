import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme.dart';
import '../providers/skill_provider.dart';
import '../providers/user_provider.dart';

class SkillsScreen extends ConsumerWidget {
  const SkillsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final skills = ref.watch(skillProvider);
    final user = ref.watch(userProfileProvider);

    if (user == null) return const SizedBox();

    // Group skills by category
    final codingNodes = skills.where((node) => node.category == 'coding').toList();
    final fitnessNodes = skills.where((node) => node.category == 'fitness').toList();
    final learningNodes = skills.where((node) => node.category == 'learning').toList();
    final careerNodes = skills.where((node) => node.category == 'career').toList();

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Screen explanation
            const Text(
              'SKILL TREE BRANCHES',
              style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1, color: RpgColors.primary, fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'Deduct coins to unlock nodes and level up skills, boosting your real-life performance!',
              style: TextStyle(color: RpgColors.textSecondary, fontSize: 11),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            _buildBranchSection(context, ref, 'CODING BRANCH', codingNodes, user.coins, Colors.cyan),
            const SizedBox(height: 24),
            _buildBranchSection(context, ref, 'FITNESS BRANCH', fitnessNodes, user.coins, Colors.green),
            const SizedBox(height: 24),
            _buildBranchSection(context, ref, 'LEARNING BRANCH', learningNodes, user.coins, Colors.orange),
            const SizedBox(height: 24),
            _buildBranchSection(context, ref, 'CAREER BRANCH', careerNodes, user.coins, Colors.purple),
          ],
        ),
      ),
    );
  }

  Widget _buildBranchSection(
    BuildContext context, 
    WidgetRef ref, 
    String title, 
    List<dynamic> nodes, 
    int userCoins,
    Color branchColor,
  ) {
    // Sort nodes to make sure Node 1 is first, Node 2 is second, etc.
    nodes.sort((a, b) => a.id.compareTo(b.id));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4.0, bottom: 12),
          child: Text(
            title,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, letterSpacing: 1.2, color: branchColor),
          ),
        ),
        
        // Renders nodes with line connectives in between
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: nodes.length,
          separatorBuilder: (context, index) {
            final nextNode = nodes[index + 1];
            final isNextUnlocked = nextNode.isUnlocked;

            return Center(
              child: Container(
                width: 3,
                height: 20,
                color: isNextUnlocked ? branchColor : RpgColors.border,
              ),
            );
          },
          itemBuilder: (context, index) {
            final node = nodes[index];
            final isMaxLevel = node.level >= node.maxLevel;
            final cost = node.level == 0 
                ? node.requiredCoins 
                : (node.requiredCoins * (node.level + 0.5)).toInt();

            // Node is unlockable if unlocked == true
            final canUnlock = node.isUnlocked;

            return Card(
              color: node.level > 0 ? RpgColors.cardBg : RpgColors.cardBg.withOpacity(0.5),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: node.level > 0 ? branchColor : Colors.grey.shade800,
                  radius: 18,
                  child: Text(
                    '${index + 1}',
                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      node.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: node.level > 0 ? Colors.white : Colors.grey,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: node.level > 0 ? branchColor.withAlpha(30) : Colors.transparent,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'LV ${node.level}/${node.maxLevel}',
                        style: TextStyle(
                          fontSize: 9, 
                          color: node.level > 0 ? branchColor : Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                subtitle: Text(
                  '${node.description}\nUpgrade: $cost Coins',
                  style: const TextStyle(fontSize: 11, color: RpgColors.textSecondary, height: 1.3),
                ),
                isThreeLine: true,
                trailing: isMaxLevel
                    ? const Icon(Icons.stars, color: RpgColors.accent)
                    : ElevatedButton(
                        onPressed: (!canUnlock || userCoins < cost)
                            ? null
                            : () async {
                                final success = await ref.read(skillProvider.notifier).unlockOrUpgradeSkill(node.id);
                                if (success) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('${node.title} leveled up!')),
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: branchColor,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          disabledBackgroundColor: Colors.grey.shade800,
                        ),
                        child: Text(
                          node.level == 0 ? 'UNLOCK' : 'UPGRADE',
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ),
              ),
            );
          },
        ),
      ],
    );
  }
}
