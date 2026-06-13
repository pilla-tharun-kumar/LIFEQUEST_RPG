import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme.dart';
import '../providers/pet_provider.dart';
import '../providers/user_provider.dart';
import '../widgets/pet_painter.dart';

class PetScreen extends ConsumerStatefulWidget {
  const PetScreen({super.key});

  @override
  ConsumerState<PetScreen> createState() => _PetScreenState();
}

class _PetScreenState extends ConsumerState<PetScreen> {
  bool _isPlayingAnimation = false;
  String _floatingMessage = '';

  void _playWithPet() async {
    if (_isPlayingAnimation) return;

    setState(() {
      _isPlayingAnimation = true;
      _floatingMessage = '+15 Happiness! (Pet XP +10)';
    });

    final success = await ref.read(petProvider.notifier).playWithPet();
    if (success) {
      await ref.read(petProvider.notifier).feedOrRewardPet(xpGained: 10);
    }

    await Future.delayed(const Duration(seconds: 1500));
    
    if (mounted) {
      setState(() {
        _isPlayingAnimation = false;
        _floatingMessage = '';
      });
    }
  }

  void _feedPet(String foodId, String foodName, int cost, int hungerVal, int happinessVal) async {
    final user = ref.read(userProfileProvider);
    if (user == null) return;

    if (user.coins < cost) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not enough coins to buy this food item!'), backgroundColor: Colors.redAccent),
      );
      return;
    }

    setState(() {
      _isPlayingAnimation = true;
      _floatingMessage = 'Yum! +$hungerVal Hunger restored!';
    });

    await ref.read(petProvider.notifier).feedPetWithFood(foodId, cost, hungerVal, happinessVal);

    await Future.delayed(const Duration(seconds: 1500));

    if (mounted) {
      setState(() {
        _isPlayingAnimation = false;
        _floatingMessage = '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final pet = ref.watch(petProvider);
    final user = ref.watch(userProfileProvider);

    if (pet == null || user == null) {
      return const Scaffold(
        body: Center(child: Text('No pet companions found!')),
      );
    }

    double petXpPercent = pet.xp / pet.requiredXp;
    if (petXpPercent.isNaN || petXpPercent.isInfinite) petXpPercent = 0.0;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Evolution Stage Display
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: RpgColors.primary.withAlpha(20),
                  border: Border.all(color: RpgColors.primary.withAlpha(100)),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'STAGE: ${pet.stage.toUpperCase()}',
                  style: TextStyle(
                    color: RpgColors.primary,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    fontSize: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Pet Canvas Render & Floating Msg
            SizedBox(
              height: 220,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Hovering message
                  if (_floatingMessage.isNotEmpty)
                    Positioned(
                      top: 10,
                      child: AnimatedOpacity(
                        opacity: _floatingMessage.isNotEmpty ? 1.0 : 0.0,
                        duration: const Duration(milliseconds: 300),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black87,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: RpgColors.success),
                          ),
                          child: Text(
                            _floatingMessage,
                            style: const TextStyle(color: RpgColors.success, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                      ),
                    ),
                  
                  // Interactive Pet render
                  GestureDetector(
                    onTap: _playWithPet,
                    child: Hero(
                      tag: 'pet_render',
                      child: PetWidget(
                        stage: pet.stage,
                        visualType: pet.visualType,
                        size: 200,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Center(
              child: Text(
                pet.name.toUpperCase(),
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  fontSize: 24,
                  letterSpacing: 1.5,
                  shadows: [
                    Shadow(color: RpgColors.primary.withAlpha(120), blurRadius: 10),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Evolution / Level XP progress
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Evolution Progress', style: TextStyle(fontWeight: FontWeight.bold)),
                        Text('${pet.xp} / ${pet.requiredXp} XP'),
                      ],
                    ),
                    const SizedBox(height: 8),
                    LinearProgressIndicator(
                      value: petXpPercent,
                      backgroundColor: RpgColors.background,
                      color: RpgColors.primary,
                      minHeight: 8,
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Stats Panels
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: 'HAPPINESS',
                    value: pet.happiness,
                    icon: Icons.favorite,
                    color: RpgColors.secondary,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    title: 'HUNGER',
                    value: pet.hunger,
                    icon: Icons.restaurant,
                    color: RpgColors.accent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Interaction Controls
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _playWithPet,
                    icon: const Icon(Icons.videogame_asset, color: Colors.black),
                    label: const Text('PLAY (+15 HP)'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: RpgColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _showFeedMenu();
                    },
                    icon: const Icon(Icons.fastfood, color: Colors.black),
                    label: const Text('FEED PET'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: RpgColors.accent,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required int value,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 10, color: RpgColors.textSecondary, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              '$value%',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }

  void _showFeedMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: RpgColors.cardBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'FEED YOUR COMPANION',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(color: RpgColors.accent, letterSpacing: 1),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              const Text(
                'Select a food treat. Costs coins but keeps your companion healthy!',
                style: TextStyle(color: RpgColors.textSecondary, fontSize: 12),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              _buildFoodOption(
                id: 'food_apple',
                name: 'Golden Apple',
                cost: 10,
                hungerRestore: 20,
                happinessRestore: 10,
                desc: 'Restores 20 Hunger & 10 Happiness',
                icon: Icons.apple,
                color: Colors.red,
              ),
              const SizedBox(height: 12),
              _buildFoodOption(
                id: 'food_cookie',
                name: 'Star Cookie',
                cost: 15,
                hungerRestore: 15,
                happinessRestore: 25,
                desc: 'Restores 15 Hunger & 25 Happiness',
                icon: Icons.cookie,
                color: Colors.orange,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFoodOption({
    required String id,
    required String name,
    required int cost,
    required int hungerRestore,
    required int happinessRestore,
    required String desc,
    required IconData icon,
    required Color color,
  }) {
    return Card(
      color: RpgColors.background,
      child: ListTile(
        leading: Icon(icon, color: color, size: 28),
        title: Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('$desc\nCost: $cost Coins', style: const TextStyle(fontSize: 10)),
        isThreeLine: true,
        trailing: ElevatedButton(
          onPressed: () {
            Navigator.of(context).pop();
            _feedPet(id, name, cost, hungerRestore, happinessRestore);
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: RpgColors.accent,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          ),
          child: const Text('FEED', style: TextStyle(fontSize: 12)),
        ),
      ),
    );
  }
}
