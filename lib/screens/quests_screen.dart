import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme.dart';
import '../providers/quest_provider.dart';

class QuestsScreen extends ConsumerStatefulWidget {
  const QuestsScreen({super.key});

  @override
  ConsumerState<QuestsScreen> createState() => _QuestsScreenState();
}

class _QuestsScreenState extends ConsumerState<QuestsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showAddQuestDialog() {
    final titleController = TextEditingController();
    String type = 'daily';
    String category = 'coding';
    String difficulty = 'medium';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(
            'NEW QUEST BOARD',
            style: TextStyle(color: RpgColors.primary, fontWeight: FontWeight.bold, letterSpacing: 1),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Quest Title',
                    hintText: 'e.g., Learn recursion in Dart',
                  ),
                ),
                const SizedBox(height: 16),
                
                // Quest Type Dropdown
                DropdownButtonFormField<String>(
                  value: type,
                  decoration: const InputDecoration(labelText: 'Quest Type'),
                  items: const [
                    DropdownMenuItem(value: 'daily', child: Text('Daily Quest')),
                    DropdownMenuItem(value: 'weekly', child: Text('Weekly Quest')),
                  ],
                  onChanged: (val) {
                    if (val != null) setDialogState(() => type = val);
                  },
                ),
                const SizedBox(height: 16),

                // Category Dropdown
                DropdownButtonFormField<String>(
                  value: category,
                  decoration: const InputDecoration(labelText: 'Life Domain'),
                  items: const [
                    DropdownMenuItem(value: 'coding', child: Text('Coding / Tech')),
                    DropdownMenuItem(value: 'fitness', child: Text('Fitness / Gym')),
                    DropdownMenuItem(value: 'learning', child: Text('Learning / Reading')),
                    DropdownMenuItem(value: 'career', child: Text('Career / CV')),
                  ],
                  onChanged: (val) {
                    if (val != null) setDialogState(() => category = val);
                  },
                ),
                const SizedBox(height: 16),

                // Difficulty Dropdown
                DropdownButtonFormField<String>(
                  value: difficulty,
                  decoration: const InputDecoration(labelText: 'Quest Difficulty'),
                  items: const [
                    DropdownMenuItem(value: 'easy', child: Text('Easy (+XP / G)')),
                    DropdownMenuItem(value: 'medium', child: Text('Medium (++XP / G)')),
                    DropdownMenuItem(value: 'hard', child: Text('Hard (+++XP / G)')),
                  ],
                  onChanged: (val) {
                    if (val != null) setDialogState(() => difficulty = val);
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('ABANDON', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                final title = titleController.text.trim();
                if (title.isEmpty) return;

                ref.read(questProvider.notifier).addQuest(
                  title: title,
                  type: type,
                  category: category,
                  difficulty: difficulty,
                );

                Navigator.of(context).pop();
              },
              child: const Text('CREATE'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final quests = ref.watch(questProvider);
    final activeQuests = quests.where((q) => !q.isCompleted).toList();
    final completedQuests = quests.where((q) => q.isCompleted).toList();

    return Scaffold(
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            indicatorColor: RpgColors.primary,
            labelColor: RpgColors.primary,
            unselectedLabelColor: RpgColors.textSecondary,
            tabs: const [
              Tab(text: 'ACTIVE QUESTS'),
              Tab(text: 'COMPLETED'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildQuestList(activeQuests, isActive: true),
                _buildQuestList(completedQuests, isActive: false),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddQuestDialog,
        backgroundColor: RpgColors.primary,
        foregroundColor: Colors.black,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildQuestList(List<dynamic> list, {required bool isActive}) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isActive ? Icons.explore_off_outlined : Icons.history_toggle_off,
              size: 60,
              color: RpgColors.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              isActive 
                  ? 'No active quests. Add a new task!' 
                  : 'No completed quests yet.',
              style: const TextStyle(color: RpgColors.textSecondary),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: list.length,
      itemBuilder: (context, index) {
        final quest = list[index];
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
          margin: const EdgeInsets.only(bottom: 12),
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
              style: TextStyle(
                fontWeight: FontWeight.bold, 
                fontSize: 14,
                decoration: quest.isCompleted ? TextDecoration.lineThrough : null,
                color: quest.isCompleted ? RpgColors.textSecondary : RpgColors.textPrimary,
              ),
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
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isActive)
                  Checkbox(
                    value: quest.isCompleted,
                    activeColor: RpgColors.primary,
                    checkColor: Colors.black,
                    onChanged: (val) {
                      if (val == true) {
                        ref.read(questProvider.notifier).completeQuest(
                          quest.id,
                          onLevelUp: (lvl) {
                            // Celebration dialog managed by dashboard, but we can also trigger snackbars here.
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Quest Completed! +${quest.xpReward} XP, +${quest.coinReward} Gold!'),
                                backgroundColor: RpgColors.success.withAlpha(100),
                              ),
                            );
                          },
                        );
                      }
                    },
                  ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.grey, size: 20),
                  onPressed: () {
                    ref.read(questProvider.notifier).deleteQuest(quest.id);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
