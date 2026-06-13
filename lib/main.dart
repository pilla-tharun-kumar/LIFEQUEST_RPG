import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'core/theme.dart';
import 'data/models/quest.dart';
import 'data/models/user_profile.dart';
import 'data/models/pet.dart';
import 'data/models/inventory_item.dart';
import 'data/models/skill_node.dart';
import 'providers/auth_provider.dart';
import 'screens/login_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart';
import 'data/services/firebase_service.dart';
import 'data/services/mongo_sync_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Register Hive Adapters
  Hive.registerAdapter(QuestAdapter());
  Hive.registerAdapter(UserProfileAdapter());
  Hive.registerAdapter(PetAdapter());
  Hive.registerAdapter(InventoryItemAdapter());
  Hive.registerAdapter(SkillNodeAdapter());

  // Open Boxes
  await Hive.openBox<Quest>('quests');
  await Hive.openBox<UserProfile>('profile');
  await Hive.openBox<Pet>('pet');
  await Hive.openBox<InventoryItem>('inventory');
  await Hive.openBox<SkillNode>('skills');
  await Hive.openBox<bool>('achievements_status');

  // Initialize Remote Services (Firebase & MongoDB Atlas Sync)
  await FirebaseService.initialize();
  await MongoSyncService.initialize();

  runApp(
    const ProviderScope(
      child: LifeQuestApp(),
    ),
  );
}

class LifeQuestApp extends ConsumerWidget {
  const LifeQuestApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    Widget screen;
    switch (authState) {
      case AuthState.unauthenticated:
        screen = const LoginScreen();
        break;
      case AuthState.onboarding:
        screen = const OnboardingScreen();
        break;
      case AuthState.authenticated:
        screen = const HomeScreen();
        break;
    }

    return MaterialApp(
      title: 'LifeQuest RPG',
      debugShowCheckedModeBanner: false,
      theme: RpgTheme.darkTheme,
      home: screen,
    );
  }
}
