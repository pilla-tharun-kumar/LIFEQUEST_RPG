import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../data/models/inventory_item.dart';
import 'user_provider.dart';

class InventoryNotifier extends Notifier<List<InventoryItem>> {
  @override
  List<InventoryItem> build() {
    final box = Hive.box<InventoryItem>('inventory');
    return box.values.toList();
  }

  Future<bool> purchaseItem(String id) async {
    final box = Hive.box<InventoryItem>('inventory');
    final item = box.get(id);
    if (item == null || item.isPurchased) return false;

    // Deduct coins
    final userNotifier = ref.read(userProfileProvider.notifier);
    final success = await userNotifier.deductCoins(item.cost);
    if (!success) return false; // not enough coins

    final updatedItem = item.copyWith(isPurchased: true);
    await box.put(id, updatedItem);
    
    state = box.values.toList();
    return true;
  }

  Future<void> equipItem(String id) async {
    final box = Hive.box<InventoryItem>('inventory');
    final item = box.get(id);
    if (item == null || !item.isPurchased) return;

    final itemType = item.type;

    // 1. Unequip any currently equipped items of the same type
    for (var key in box.keys) {
      final val = box.get(key);
      if (val != null && val.type == itemType && val.isEquipped && val.id != id) {
        await box.put(key, val.copyWith(isEquipped: false));
      }
    }

    // 2. Equip new item
    final updatedItem = item.copyWith(isEquipped: true);
    await box.put(id, updatedItem);

    // 3. Update User Profile
    await ref.read(userProfileProvider.notifier).equipItem(id, itemType);

    state = box.values.toList();
  }

  Future<void> unequipItem(String id) async {
    final box = Hive.box<InventoryItem>('inventory');
    final item = box.get(id);
    if (item == null || !item.isEquipped) return;

    final updatedItem = item.copyWith(isEquipped: false);
    await box.put(id, updatedItem);

    // Update User Profile
    await ref.read(userProfileProvider.notifier).equipItem('', item.type);

    state = box.values.toList();
  }
}

final inventoryProvider = NotifierProvider<InventoryNotifier, List<InventoryItem>>(InventoryNotifier.new);
