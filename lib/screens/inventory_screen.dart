import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme.dart';
import '../providers/inventory_provider.dart';
import '../providers/user_provider.dart';

class InventoryScreen extends ConsumerStatefulWidget {
  const InventoryScreen({super.key});

  @override
  ConsumerState<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends ConsumerState<InventoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final inventory = ref.watch(inventoryProvider);
    final user = ref.watch(userProfileProvider);

    if (user == null) return const SizedBox();

    final shopItems = inventory.where((item) => !item.isPurchased).toList();
    final ownedItems = inventory.where((item) => item.isPurchased && item.type != 'food').toList();

    return Scaffold(
      body: Column(
        children: [
          TabBar(
            controller: _tabController,
            indicatorColor: RpgColors.primary,
            labelColor: RpgColors.primary,
            unselectedLabelColor: RpgColors.textSecondary,
            tabs: const [
              Tab(text: 'COSMETIC SHOP'),
              Tab(text: 'MY EQUIPMENT'),
            ],
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildShopTab(shopItems, user.coins),
                _buildOwnedTab(ownedItems),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShopTab(List<dynamic> items, int userCoins) {
    if (items.isEmpty) {
      return const Center(
        child: Text('You have bought out the shop! Check back later.'),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.72,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        Color rarityColor;
        switch (item.rarity) {
          case 'common':
            rarityColor = RpgColors.common;
            break;
          case 'rare':
            rarityColor = RpgColors.rare;
            break;
          case 'epic':
            rarityColor = RpgColors.epic;
            break;
          default:
            rarityColor = RpgColors.legendary;
        }

        IconData typeIcon = Icons.help_outline;
        if (item.type == 'outfit') typeIcon = Icons.checkroom;
        if (item.type == 'accessory') typeIcon = Icons.auto_awesome;
        if (item.type == 'theme') typeIcon = Icons.brush;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Rarity tag
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: rarityColor.withAlpha(30),
                        border: Border.all(color: rarityColor.withAlpha(120)),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        item.rarity.toUpperCase(),
                        style: TextStyle(fontSize: 8, color: rarityColor, fontWeight: FontWeight.bold),
                      ),
                    ),
                    Icon(typeIcon, size: 14, color: RpgColors.textSecondary),
                  ],
                ),
                const SizedBox(height: 12),
                
                // Visual representation
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: RpgColors.background,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Icon(
                        item.type == 'outfit' 
                            ? Icons.shield_outlined 
                            : item.type == 'accessory' 
                                ? Icons.videogame_asset_outlined 
                                : Icons.style_outlined,
                        size: 40,
                        color: rarityColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),

                Text(
                  item.name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  item.description,
                  style: const TextStyle(fontSize: 9, color: RpgColors.textSecondary),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),

                ElevatedButton(
                  onPressed: () async {
                    if (userCoins < item.cost) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Not enough Gold to buy this!')),
                      );
                      return;
                    }

                    final success = await ref.read(inventoryProvider.notifier).purchaseItem(item.id);
                    if (success) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${item.name} purchased! Check Equipment.')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: RpgColors.accent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.monetization_on, size: 14),
                      const SizedBox(width: 4),
                      Text('${item.cost}', style: const TextStyle(fontSize: 12)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOwnedTab(List<dynamic> items) {
    if (items.isEmpty) {
      return const Center(
        child: Text('No custom equipment owned yet. Purchase items in the Shop!'),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        Color rarityColor;
        switch (item.rarity) {
          case 'common':
            rarityColor = RpgColors.common;
            break;
          case 'rare':
            rarityColor = RpgColors.rare;
            break;
          case 'epic':
            rarityColor = RpgColors.epic;
            break;
          default:
            rarityColor = RpgColors.legendary;
        }

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: rarityColor.withAlpha(40),
              child: Icon(
                item.type == 'outfit' ? Icons.checkroom : Icons.auto_awesome,
                color: rarityColor,
              ),
            ),
            title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('${item.description}\nRarity: ${item.rarity.toUpperCase()}', style: const TextStyle(fontSize: 10)),
            isThreeLine: true,
            trailing: OutlinedButton(
              onPressed: () {
                if (item.isEquipped) {
                  ref.read(inventoryProvider.notifier).unequipItem(item.id);
                } else {
                  ref.read(inventoryProvider.notifier).equipItem(item.id);
                }
              },
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: item.isEquipped ? RpgColors.secondary : RpgColors.primary,
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: Text(
                item.isEquipped ? 'UNEQUIP' : 'EQUIP',
                style: TextStyle(
                  color: item.isEquipped ? RpgColors.secondary : RpgColors.primary,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
