import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../data/models/pet.dart';
import '../data/services/mongo_sync_service.dart';
import 'user_provider.dart';

class PetNotifier extends Notifier<Pet?> {
  @override
  Pet? build() {
    final box = Hive.box<Pet>('pet');
    if (box.isNotEmpty) {
      final pet = box.get('current_pet');
      // Delay decay until next frame to avoid state updates during build
      if (pet != null) {
        Future.microtask(() => _decayStatsOnLoad());
      }
      return pet;
    }
    return null;
  }

  Future<void> _decayStatsOnLoad() async {
    if (state == null) return;
    
    // Calculate decay based on days missed (simulated or real)
    final user = ref.read(userProfileProvider);
    if (user != null && user.lastActiveDate != null) {
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);
      final lastActiveDay = DateTime(user.lastActiveDate!.year, user.lastActiveDate!.month, user.lastActiveDate!.day);
      final daysMissed = todayDate.difference(lastActiveDay).inDays;

      if (daysMissed > 1) {
        // Decay pet happiness/hunger based on missed days
        int happinessDecay = (daysMissed - 1) * 15;
        int hungerDecay = (daysMissed - 1) * 15;

        state = state!.copyWith(
          happiness: max(0, state!.happiness - happinessDecay),
          hunger: max(0, state!.hunger - hungerDecay),
        );
        await Hive.box<Pet>('pet').put('current_pet', state!);
        _syncToRemote();
      }
    }
  }

  Future<void> feedOrRewardPet({
    int xpGained = 0,
    int happinessGained = 0,
    int hungerRestored = 0,
  }) async {
    if (state == null) return;

    int newXp = state!.xp + xpGained;
    int newHappiness = min(100, state!.happiness + happinessGained);
    int newHunger = min(100, state!.hunger + hungerRestored);
    String newStage = state!.stage;
    int newRequiredXp = state!.requiredXp;

    while (newXp >= newRequiredXp) {
      newXp -= newRequiredXp;
      
      if (newStage == 'egg') {
        newStage = 'baby';
        newRequiredXp = 100;
      } else if (newStage == 'baby') {
        newStage = 'young';
        newRequiredXp = 200;
      } else if (newStage == 'young') {
        newStage = 'adult';
        newRequiredXp = 400;
      } else if (newStage == 'adult') {
        newStage = 'legendary';
        newRequiredXp = 1000;
      } else {
        // Legendary is maxed
        newXp = newRequiredXp; // lock at max
        break;
      }
    }

    state = state!.copyWith(
      xp: newXp,
      happiness: newHappiness,
      hunger: newHunger,
      stage: newStage,
      requiredXp: newRequiredXp,
    );
    await Hive.box<Pet>('pet').put('current_pet', state!);
    _syncToRemote();
  }

  Future<bool> playWithPet() async {
    if (state == null) return false;

    // Playing increases happiness but makes pet slightly hungry
    int newHappiness = min(100, state!.happiness + 15);
    int newHunger = max(0, state!.hunger - 8);

    state = state!.copyWith(
      happiness: newHappiness,
      hunger: newHunger,
    );
    await Hive.box<Pet>('pet').put('current_pet', state!);
    _syncToRemote();
    return true;
  }

  Future<bool> feedPetWithFood(String foodId, int cost, int hungerRestore, int happinessRestore) async {
    if (state == null) return false;
    
    // Deduct coins from user
    final userNotifier = ref.read(userProfileProvider.notifier);
    final success = await userNotifier.deductCoins(cost);
    if (!success) return false; // not enough coins

    // Feed pet
    await feedOrRewardPet(
      xpGained: 15, // feeding gives small bonus pet XP
      happinessGained: happinessRestore,
      hungerRestored: hungerRestore,
    );

    return true;
  }

  void _syncToRemote() {
    if (state == null) return;
    MongoSyncService.syncDocument(
      collection: "pets",
      documentId: "current_pet",
      data: {
        "name": state!.name,
        "stage": state!.stage,
        "happiness": state!.happiness,
        "hunger": state!.hunger,
        "xp": state!.xp,
        "requiredXp": state!.requiredXp,
        "visualType": state!.visualType,
      },
    );
  }
}

final petProvider = NotifierProvider<PetNotifier, Pet?>(PetNotifier.new);
