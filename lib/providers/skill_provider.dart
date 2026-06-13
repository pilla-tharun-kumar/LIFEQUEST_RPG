import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../data/models/skill_node.dart';
import 'user_provider.dart';

class SkillNotifier extends Notifier<List<SkillNode>> {
  @override
  List<SkillNode> build() {
    final box = Hive.box<SkillNode>('skills');
    return box.values.toList();
  }

  Future<bool> unlockOrUpgradeSkill(String id) async {
    final box = Hive.box<SkillNode>('skills');
    final node = box.get(id);
    if (node == null) return false;

    // Check level limit
    if (node.level >= node.maxLevel) return false;

    // Upgrade costs coins
    final cost = node.level == 0 
        ? node.requiredCoins 
        : (node.requiredCoins * (node.level + 0.5)).toInt();

    // Check if player has enough coins
    final userNotifier = ref.read(userProfileProvider.notifier);
    final success = await userNotifier.deductCoins(cost);
    if (!success) return false; // not enough coins

    // Update level and unlocked state
    final nextLevel = node.level + 1;
    final updatedNode = node.copyWith(
      level: nextLevel,
      isUnlocked: true,
    );
    await box.put(id, updatedNode);

    // If we unlocked level 1, make direct child nodes "available" for purchase
    if (nextLevel == 1) {
      for (var childId in node.childrenIds) {
        final childNode = box.get(childId);
        if (childNode != null && !childNode.isUnlocked) {
          await box.put(childId, childNode.copyWith(isUnlocked: true));
        }
      }
    }

    state = box.values.toList();
    return true;
  }
}

final skillProvider = NotifierProvider<SkillNotifier, List<SkillNode>>(SkillNotifier.new);
