import 'package:hive/hive.dart';

part 'inventory_item.g.dart';

@HiveType(typeId: 3)
class InventoryItem extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String type; // 'outfit', 'accessory', 'food', 'theme'

  @HiveField(3)
  final int cost;

  @HiveField(4)
  final bool isEquipped;

  @HiveField(5)
  final bool isPurchased;

  @HiveField(6)
  final String assetPath;

  @HiveField(7)
  final String rarity; // 'common', 'rare', 'epic', 'legendary'

  @HiveField(8)
  final String description;

  InventoryItem({
    required this.id,
    required this.name,
    required this.type,
    required this.cost,
    this.isEquipped = false,
    this.isPurchased = false,
    required this.assetPath,
    required this.rarity,
    this.description = '',
  });

  InventoryItem copyWith({
    bool? isEquipped,
    bool? isPurchased,
  }) {
    return InventoryItem(
      id: id,
      name: name,
      type: type,
      cost: cost,
      isEquipped: isEquipped ?? this.isEquipped,
      isPurchased: isPurchased ?? this.isPurchased,
      assetPath: assetPath,
      rarity: rarity,
      description: description,
    );
  }
}
