import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../data/models/quest.dart';
import '../data/services/mongo_sync_service.dart';
import 'user_provider.dart';
import 'pet_provider.dart';
import 'achievement_provider.dart';

class QuestNotifier extends Notifier<List<Quest>> {
  @override
  List<Quest> build() {
    final box = Hive.box<Quest>('quests');
    return box.values.toList();
  }

  Future<void> addQuest({
    required String title,
    required String type, // 'daily', 'weekly'
    required String category, // 'coding', 'fitness', 'learning', 'career'
    required String difficulty, // 'easy', 'medium', 'hard'
    DateTime? dueDate,
  }) async {
    final box = Hive.box<Quest>('quests');
    final id = const Uuid().v4();

    // Reward calculations
    int xpReward = 0;
    int coinReward = 0;

    if (type == 'daily') {
      switch (difficulty) {
        case 'easy':
          xpReward = 30;
          coinReward = 15;
          break;
        case 'medium':
          xpReward = 50;
          coinReward = 20; // 20 standard from PRD
          break;
        case 'hard':
          xpReward = 80;
          coinReward = 30;
          break;
      }
    } else {
      switch (difficulty) {
        case 'easy':
          xpReward = 150;
          coinReward = 60;
          break;
        case 'medium':
          xpReward = 250;
          coinReward = 100; // 100 standard from PRD
          break;
        case 'hard':
          xpReward = 400;
          coinReward = 150;
          break;
      }
    }

    final newQuest = Quest(
      id: id,
      title: title,
      type: type,
      category: category,
      difficulty: difficulty,
      xpReward: xpReward,
      coinReward: coinReward,
      isCompleted: false,
      dueDate: dueDate,
      createdAt: DateTime.now(),
    );

    await box.put(id, newQuest);
    state = [...state, newQuest];

    // Background sync to MongoDB Atlas
    MongoSyncService.syncDocument(
      collection: "quests",
      documentId: id,
      data: {
        "id": id,
        "title": title,
        "type": type,
        "category": category,
        "difficulty": difficulty,
        "xpReward": xpReward,
        "coinReward": coinReward,
        "isCompleted": false,
        "dueDate": dueDate?.toIso8601String(),
        "createdAt": newQuest.createdAt.toIso8601String(),
      },
    );
  }

  Future<void> completeQuest(String id, {required void Function(int newLevel) onLevelUp}) async {
    final box = Hive.box<Quest>('quests');
    final quest = box.get(id);
    if (quest == null || quest.isCompleted) return;

    // 1. Mark quest completed
    quest.isCompleted = true;
    quest.completedAt = DateTime.now();
    await quest.save();

    // Update state
    state = [
      for (final q in state)
        if (q.id == id) quest else q
    ];

    // Background sync update to MongoDB Atlas
    MongoSyncService.syncDocument(
      collection: "quests",
      documentId: id,
      data: {
        "isCompleted": true,
        "completedAt": quest.completedAt?.toIso8601String(),
      },
    );

    // 2. Award User Rewards
    final userNotifier = ref.read(userProfileProvider.notifier);
    await userNotifier.addXp(quest.xpReward, onLevelUp: onLevelUp);
    await userNotifier.addCoins(quest.coinReward);
    await userNotifier.updateStreaks(quest.category);

    // 3. Feed/Reward Pet XP
    final petNotifier = ref.read(petProvider.notifier);
    // Complete quest gives pet some happiness and small pet XP
    await petNotifier.feedOrRewardPet(xpGained: quest.type == 'daily' ? 10 : 25, happinessGained: 10);

    // 4. Trigger Achievement Checks
    ref.read(achievementProvider.notifier).checkAchievements();
  }

  Future<void> deleteQuest(String id) async {
    final box = Hive.box<Quest>('quests');
    await box.delete(id);
    state = state.where((q) => q.id != id).toList();

    // Background delete from MongoDB Atlas
    MongoSyncService.deleteDocument(
      collection: "quests",
      documentId: id,
    );
  }
}

final questProvider = NotifierProvider<QuestNotifier, List<Quest>>(QuestNotifier.new);
