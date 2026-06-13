import 'package:hive/hive.dart';

part 'pet.g.dart';

@HiveType(typeId: 2)
class Pet extends HiveObject {
  @HiveField(0)
  final String name;

  @HiveField(1)
  final String stage; // 'egg', 'baby', 'young', 'adult', 'legendary'

  @HiveField(2)
  final int happiness; // 0 to 100

  @HiveField(3)
  final int hunger; // 0 to 100 (0 is full, 100 is starving, or vice versa. Let's treat 100 as Full, 0 as Starving)

  @HiveField(4)
  final int xp;

  @HiveField(5)
  final int requiredXp;

  @HiveField(6)
  final String visualType; // 'slime', 'dragon', 'griffin'

  Pet({
    required this.name,
    this.stage = 'egg',
    this.happiness = 80,
    this.hunger = 80, // 80/100 full
    this.xp = 0,
    this.requiredXp = 50,
    required this.visualType,
  });

  Pet copyWith({
    String? name,
    String? stage,
    int? happiness,
    int? hunger,
    int? xp,
    int? requiredXp,
    String? visualType,
  }) {
    return Pet(
      name: name ?? this.name,
      stage: stage ?? this.stage,
      happiness: happiness ?? this.happiness,
      hunger: hunger ?? this.hunger,
      xp: xp ?? this.xp,
      requiredXp: requiredXp ?? this.requiredXp,
      visualType: visualType ?? this.visualType,
    );
  }
}
