import 'package:hive/hive.dart';

part 'user_profile.g.dart';

@HiveType(typeId: 1)
class UserProfile extends HiveObject {
  @HiveField(0)
  final String username;

  @HiveField(1)
  final int level;

  @HiveField(2)
  final int xp;

  @HiveField(3)
  final int requiredXp;

  @HiveField(4)
  final int coins;

  @HiveField(5)
  final String title;

  @HiveField(6)
  final String avatarBase; // 'knight', 'mage', 'cyberpunk'

  @HiveField(7)
  final String? equippedOutfit; // outfit item id

  @HiveField(8)
  final String? equippedAccessory; // accessory item id

  @HiveField(9)
  final String? equippedBackground; // background item id

  @HiveField(10)
  final int streak;

  @HiveField(11)
  final DateTime? lastActiveDate;

  @HiveField(12)
  final int readingStreak;

  @HiveField(13)
  final int codingStreak;

  @HiveField(14)
  final int fitnessStreak;

  UserProfile({
    required this.username,
    this.level = 1,
    this.xp = 0,
    this.requiredXp = 100,
    this.coins = 0,
    this.title = 'Novice Adventurer',
    required this.avatarBase,
    this.equippedOutfit,
    this.equippedAccessory,
    this.equippedBackground,
    this.streak = 0,
    this.lastActiveDate,
    this.readingStreak = 0,
    this.codingStreak = 0,
    this.fitnessStreak = 0,
  });

  UserProfile copyWith({
    String? username,
    int? level,
    int? xp,
    int? requiredXp,
    int? coins,
    String? title,
    String? avatarBase,
    String? equippedOutfit,
    String? equippedAccessory,
    String? equippedBackground,
    int? streak,
    DateTime? lastActiveDate,
    int? readingStreak,
    int? codingStreak,
    int? fitnessStreak,
  }) {
    return UserProfile(
      username: username ?? this.username,
      level: level ?? this.level,
      xp: xp ?? this.xp,
      requiredXp: requiredXp ?? this.requiredXp,
      coins: coins ?? this.coins,
      title: title ?? this.title,
      avatarBase: avatarBase ?? this.avatarBase,
      equippedOutfit: equippedOutfit ?? this.equippedOutfit,
      equippedAccessory: equippedAccessory ?? this.equippedAccessory,
      equippedBackground: equippedBackground ?? this.equippedBackground,
      streak: streak ?? this.streak,
      lastActiveDate: lastActiveDate ?? this.lastActiveDate,
      readingStreak: readingStreak ?? this.readingStreak,
      codingStreak: codingStreak ?? this.codingStreak,
      fitnessStreak: fitnessStreak ?? this.fitnessStreak,
    );
  }
}
