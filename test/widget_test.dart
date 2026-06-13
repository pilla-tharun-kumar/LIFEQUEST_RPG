import 'package:flutter_test/flutter_test.dart';
import 'package:lifequest_rpg/data/models/user_profile.dart';

void main() {
  group('LifeQuest RPG Logic Tests', () {
    test('XP Level progression calculation', () {
      final user = UserProfile(
        username: 'TestHero',
        avatarBase: 'knight',
        level: 1,
        xp: 80,
        requiredXp: 100,
      );

      // Verify initial fields
      expect(user.level, 1);
      expect(user.xp, 80);

      // Simulate a level up manually using the formula
      int currentXp = user.xp + 50; // gain 50 XP (total 130)
      int level = user.level;
      int reqXp = user.requiredXp;

      if (currentXp >= reqXp) {
        currentXp -= reqXp;
        level++;
        reqXp = level * 100 + 50;
      }

      final updatedUser = user.copyWith(
        xp: currentXp,
        level: level,
        requiredXp: reqXp,
      );

      // Verify level up happened correctly
      expect(updatedUser.level, 2);
      expect(updatedUser.xp, 30);
      expect(updatedUser.requiredXp, 250); // Level 2 required: 2 * 100 + 50 = 250
    });
  });
}
