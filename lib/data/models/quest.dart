import 'package:hive/hive.dart';

part 'quest.g.dart';

@HiveType(typeId: 0)
class Quest extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String type; // 'daily' or 'weekly'

  @HiveField(3)
  final String category; // 'coding', 'fitness', 'learning', 'career'

  @HiveField(4)
  final String difficulty; // 'easy', 'medium', 'hard'

  @HiveField(5)
  final int xpReward;

  @HiveField(6)
  final int coinReward;

  @HiveField(7)
  bool isCompleted;

  @HiveField(8)
  final DateTime? dueDate;

  @HiveField(9)
  final DateTime createdAt;

  @HiveField(10)
  DateTime? completedAt;

  Quest({
    required this.id,
    required this.title,
    required this.type,
    required this.category,
    required this.difficulty,
    required this.xpReward,
    required this.coinReward,
    this.isCompleted = false,
    this.dueDate,
    required this.createdAt,
    this.completedAt,
  });

  Quest copyWith({
    String? title,
    String? type,
    String? category,
    String? difficulty,
    int? xpReward,
    int? coinReward,
    bool? isCompleted,
    DateTime? dueDate,
    DateTime? completedAt,
  }) {
    return Quest(
      id: id,
      title: title ?? this.title,
      type: type ?? this.type,
      category: category ?? this.category,
      difficulty: difficulty ?? this.difficulty,
      xpReward: xpReward ?? this.xpReward,
      coinReward: coinReward ?? this.coinReward,
      isCompleted: isCompleted ?? this.isCompleted,
      dueDate: dueDate ?? this.dueDate,
      createdAt: createdAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }
}
