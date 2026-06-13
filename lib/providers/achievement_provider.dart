import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../data/models/quest.dart';
import 'user_provider.dart';

class Achievement {
  final String id;
  final String title;
  final String description;
  final int targetValue;
  final String category; // 'coding', 'fitness', 'learning', 'streak'
  final bool isUnlocked;
  final int currentValue;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.targetValue,
    required this.category,
    this.isUnlocked = false,
    this.currentValue = 0,
  });

  Achievement copyWith({
    bool? isUnlocked,
    int? currentValue,
  }) {
    return Achievement(
      id: id,
      title: title,
      description: description,
      targetValue: targetValue,
      category: category,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      currentValue: currentValue ?? this.currentValue,
    );
  }
}

class AchievementNotifier extends Notifier<List<Achievement>> {
  @override
  List<Achievement> build() {
    // Schedule check for next frame to avoid state updates during initial build
    Future.microtask(() => checkAchievements());
    return [];
  }

  void checkAchievements() {
    final user = ref.read(userProfileProvider);
    final questsBox = Hive.box<Quest>('quests');
    final achievementsBox = Hive.box<bool>('achievements_status');
    
    if (user == null) return;

    final completedQuests = questsBox.values.where((q) => q.isCompleted).toList();
    
    int codingCount = completedQuests.where((q) => q.category == 'coding').length;
    int fitnessCount = completedQuests.where((q) => q.category == 'fitness').length;
    int learningCount = completedQuests.where((q) => q.category == 'learning').length;
    int streakCount = user.streak;

    final definitions = [
      Achievement(
        id: 'coding_warrior',
        title: 'Coding Warrior',
        description: 'Complete 5 coding tasks (PRD: 50 tasks)',
        targetValue: 5,
        category: 'coding',
        currentValue: codingCount,
      ),
      Achievement(
        id: 'bookworm',
        title: 'Bookworm',
        description: 'Complete 5 learning tasks (PRD: Read 100 pages)',
        targetValue: 5,
        category: 'learning',
        currentValue: learningCount,
      ),
      Achievement(
        id: 'fitness_champion',
        title: 'Fitness Champion',
        description: 'Complete 5 fitness tasks (PRD: 100 workouts)',
        targetValue: 5,
        category: 'fitness',
        currentValue: fitnessCount,
      ),
      Achievement(
        id: 'consistent_hero',
        title: 'Consistent Hero',
        description: 'Maintain a 3-day streak (PRD: 30-day streak)',
        targetValue: 3,
        category: 'streak',
        currentValue: streakCount,
      ),
    ];

    List<Achievement> updated = [];
    for (var ach in definitions) {
      bool alreadyUnlocked = achievementsBox.get(ach.id, defaultValue: false) ?? false;
      bool meetsCondition = ach.currentValue >= ach.targetValue;
      
      if (meetsCondition && !alreadyUnlocked) {
        achievementsBox.put(ach.id, true);
        alreadyUnlocked = true;
        // Award 50 coins as per PRD
        Future.microtask(() {
          ref.read(userProfileProvider.notifier).addCoins(50);
        });
      }

      updated.add(ach.copyWith(isUnlocked: alreadyUnlocked));
    }

    state = updated;
  }
}

final achievementProvider = NotifierProvider<AchievementNotifier, List<Achievement>>(AchievementNotifier.new);
