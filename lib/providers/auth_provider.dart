import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';
import '../core/config.dart';
import '../data/models/user_profile.dart';
import '../data/models/quest.dart';
import '../data/models/pet.dart';
import '../data/models/inventory_item.dart';
import '../data/models/skill_node.dart';

enum AuthState {
  unauthenticated,
  onboarding,
  authenticated,
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() {
    final profileBox = Hive.box<UserProfile>('profile');
    if (profileBox.isNotEmpty) {
      return AuthState.authenticated;
    } else {
      return AuthState.unauthenticated;
    }
  }

  Future<bool> login(String email, String password) async {
    if (RpgConfig.isFirebaseEnabled) {
      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      } catch (e) {
        rethrow;
      }
    } else {
      // Simulated firebase/database authentication
      await Future.delayed(const Duration(milliseconds: 800));
    }

    final profileBox = Hive.box<UserProfile>('profile');
    if (profileBox.isNotEmpty) {
      state = AuthState.authenticated;
      return true;
    } else {
      // If authentic but no profile, go to onboarding
      state = AuthState.onboarding;
      return true;
    }
  }

  Future<void> signup(String email, String password) async {
    if (RpgConfig.isFirebaseEnabled) {
      try {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
      } catch (e) {
        rethrow;
      }
    } else {
      await Future.delayed(const Duration(milliseconds: 800));
    }
    state = AuthState.onboarding;
  }

  Future<void> completeOnboarding({
    required String username,
    required String avatarBase,
    required String petName,
    required String petType,
    required List<String> startingSkills,
  }) async {
    // 1. Create and Save User Profile
    final profile = UserProfile(
      username: username,
      avatarBase: avatarBase,
      coins: 100, // starting coins bonus
      level: 1,
      xp: 0,
      requiredXp: 100,
    );
    final profileBox = Hive.box<UserProfile>('profile');
    await profileBox.put('current_user', profile);

    // 2. Initialize Pet
    final pet = Pet(
      name: petName,
      visualType: petType,
      stage: 'egg',
      happiness: 90,
      hunger: 90,
    );
    final petBox = Hive.box<Pet>('pet');
    await petBox.put('current_pet', pet);

    // 3. Initialize default inventory items (e.g. food and starter outfits)
    final inventoryBox = Hive.box<InventoryItem>('inventory');
    final starterItems = [
      InventoryItem(id: 'food_apple', name: 'Golden Apple', type: 'food', cost: 10, isPurchased: true, assetPath: 'assets/items/apple.png', rarity: 'common', description: 'Restores 20 Hunger & 10 Happiness'),
      InventoryItem(id: 'food_cookie', name: 'Star Cookie', type: 'food', cost: 15, isPurchased: true, assetPath: 'assets/items/cookie.png', rarity: 'common', description: 'Restores 15 Hunger & 25 Happiness'),
      InventoryItem(id: 'outfit_hoodie', name: 'Coder Hoodie', type: 'outfit', cost: 50, isPurchased: true, assetPath: 'assets/outfits/hoodie.png', rarity: 'common', description: 'Classic grey coding hoodie'),
      InventoryItem(id: 'outfit_armor', name: 'Knight Armor', type: 'outfit', cost: 120, isPurchased: false, assetPath: 'assets/outfits/armor.png', rarity: 'rare', description: 'Shiny iron chestplate'),
      InventoryItem(id: 'outfit_robe', name: 'Wizard Robe', type: 'outfit', cost: 150, isPurchased: false, assetPath: 'assets/outfits/robe.png', rarity: 'epic', description: 'Deep purple wizard robe'),
      InventoryItem(id: 'acc_glasses', name: 'Cyber Goggles', type: 'accessory', cost: 80, isPurchased: false, assetPath: 'assets/accessories/goggles.png', rarity: 'rare', description: 'Neon glowing goggles'),
      InventoryItem(id: 'acc_sword', name: 'Buster Sword', type: 'accessory', cost: 200, isPurchased: false, assetPath: 'assets/accessories/sword.png', rarity: 'legendary', description: 'An oversized legendary blade'),
    ];
    for (var item in starterItems) {
      await inventoryBox.put(item.id, item);
    }

    // 4. Initialize Skill Nodes
    final skillsBox = Hive.box<SkillNode>('skills');
    
    // Coding Branch
    final codingNodes = [
      SkillNode(id: 'coding_1', title: 'Variables & Logic', category: 'coding', requiredCoins: 10, description: 'Learn conditional statements and variable declarations.', isUnlocked: true, childrenIds: ['coding_2']),
      SkillNode(id: 'coding_2', title: 'Data Structures', category: 'coding', requiredCoins: 30, description: 'Master lists, maps, sets, and algorithms.', childrenIds: ['coding_3']),
      SkillNode(id: 'coding_3', title: 'OOP & Architecture', category: 'coding', requiredCoins: 50, description: 'Understand classes, clean architecture, and design patterns.'),
    ];
    
    // Fitness Branch
    final fitnessNodes = [
      SkillNode(id: 'fitness_1', title: 'Stretching & Cardio', category: 'fitness', requiredCoins: 10, description: 'Basic daily exercises and flexibility training.', isUnlocked: true, childrenIds: ['fitness_2']),
      SkillNode(id: 'fitness_2', title: 'Strength Training', category: 'fitness', requiredCoins: 30, description: 'Calisthenics, weights, and muscle building.', childrenIds: ['fitness_3']),
      SkillNode(id: 'fitness_3', title: 'Endurance Mastery', category: 'fitness', requiredCoins: 50, description: 'Long runs, high intensity cardiovascular training.'),
    ];

    // Learning Branch
    final learningNodes = [
      SkillNode(id: 'learning_1', title: 'Focused Reading', category: 'learning', requiredCoins: 10, description: 'Read books daily and take notes.', isUnlocked: true, childrenIds: ['learning_2']),
      SkillNode(id: 'learning_2', title: 'Speed Learning', category: 'learning', requiredCoins: 30, description: 'Synthesize complex information rapidly.', childrenIds: ['learning_3']),
      SkillNode(id: 'learning_3', title: 'Public Speaking', category: 'learning', requiredCoins: 50, description: 'Communicate and present ideas flawlessly.'),
    ];

    // Career Branch
    final careerNodes = [
      SkillNode(id: 'career_1', title: 'Resume Building', category: 'career', requiredCoins: 10, description: 'Draft a perfect CV and portfolio site.', isUnlocked: true, childrenIds: ['career_2']),
      SkillNode(id: 'career_2', title: 'Networking', category: 'career', requiredCoins: 30, description: 'Build relationships on LinkedIn and communities.', childrenIds: ['career_3']),
      SkillNode(id: 'career_3', title: 'Interview Cracking', category: 'career', requiredCoins: 50, description: 'Technical coding interviews and behaviorals.'),
    ];

    for (var node in [...codingNodes, ...fitnessNodes, ...learningNodes, ...careerNodes]) {
      // If starting skill was selected, make it unlocked immediately
      if (startingSkills.contains(node.category) && node.id.endsWith('_1')) {
        await skillsBox.put(node.id, node.copyWith(level: 1, isUnlocked: true));
      } else {
        await skillsBox.put(node.id, node);
      }
    }

    state = AuthState.authenticated;
  }

  Future<void> logout() async {
    if (RpgConfig.isFirebaseEnabled) {
      await FirebaseAuth.instance.signOut();
    }

    final profileBox = Hive.box<UserProfile>('profile');
    final petBox = Hive.box<Pet>('pet');
    final questsBox = Hive.box<Quest>('quests');
    final inventoryBox = Hive.box<InventoryItem>('inventory');
    final skillsBox = Hive.box<SkillNode>('skills');

    await profileBox.clear();
    await petBox.clear();
    await questsBox.clear();
    await inventoryBox.clear();
    await skillsBox.clear();

    state = AuthState.unauthenticated;
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
