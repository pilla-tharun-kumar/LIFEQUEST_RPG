import 'package:hive/hive.dart';

part 'skill_node.g.dart';

@HiveType(typeId: 4)
class SkillNode extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String category; // 'coding', 'fitness', 'learning', 'career'

  @HiveField(3)
  final int level;

  @HiveField(4)
  final int maxLevel;

  @HiveField(5)
  final int requiredCoins;

  @HiveField(6)
  final bool isUnlocked;

  @HiveField(7)
  final String description;

  @HiveField(8)
  final List<String> childrenIds;

  SkillNode({
    required this.id,
    required this.title,
    required this.category,
    this.level = 0,
    this.maxLevel = 5,
    required this.requiredCoins,
    this.isUnlocked = false,
    this.description = '',
    this.childrenIds = const [],
  });

  SkillNode copyWith({
    int? level,
    bool? isUnlocked,
  }) {
    return SkillNode(
      id: id,
      title: title,
      category: category,
      level: level ?? this.level,
      maxLevel: maxLevel,
      requiredCoins: requiredCoins,
      isUnlocked: isUnlocked ?? this.isUnlocked,
      description: description,
      childrenIds: childrenIds,
    );
  }
}
