import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/theme.dart';
import '../providers/auth_provider.dart';
import '../widgets/avatar_painter.dart';
import '../widgets/pet_painter.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _pageController = PageController();
  int _currentStep = 0;

  // Selections
  final _usernameController = TextEditingController();
  String _selectedAvatar = 'knight'; // 'knight', 'mage', 'cyberpunk'
  
  final _petNameController = TextEditingController();
  String _selectedPetType = 'slime'; // 'slime', 'dragon'

  final List<String> _selectedSkills = [];

  @override
  void dispose() {
    _pageController.dispose();
    _usernameController.dispose();
    _petNameController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentStep == 0 && _usernameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter an adventurer username!')),
      );
      return;
    }
    if (_currentStep == 1 && _petNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please name your virtual companion pet!')),
      );
      return;
    }

    if (_currentStep < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _prevPage() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _finishOnboarding() async {
    await ref.read(authProvider.notifier).completeOnboarding(
          username: _usernameController.text.trim(),
          avatarBase: _selectedAvatar,
          petName: _petNameController.text.trim(),
          petType: _selectedPetType,
          startingSkills: _selectedSkills,
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CREATE ADVENTURER', style: TextStyle(color: RpgColors.primary, fontWeight: FontWeight.bold, letterSpacing: 1.5)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: _currentStep > 0 
            ? IconButton(icon: const Icon(Icons.arrow_back, color: RpgColors.primary), onPressed: _prevPage)
            : null,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Step Indicators
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
              child: Row(
                children: List.generate(3, (index) {
                  return Expanded(
                    child: Container(
                      height: 4,
                      margin: const EdgeInsets.symmetric(horizontal: 4.0),
                      decoration: BoxDecoration(
                        color: index <= _currentStep ? RpgColors.primary : RpgColors.border,
                        borderRadius: BorderRadius.circular(2),
                        boxShadow: index <= _currentStep 
                            ? [BoxShadow(color: RpgColors.primary.withAlpha(200), blurRadius: 4)]
                            : null,
                      ),
                    ),
                  );
                }),
              ),
            ),
            
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) {
                  setState(() {
                    _currentStep = page;
                  });
                },
                children: [
                  _buildAvatarStep(),
                  _buildPetStep(),
                  _buildSkillsStep(),
                ],
              ),
            ),

            // Navigation Button
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: ElevatedButton(
                onPressed: _nextPage,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size.fromHeight(50),
                  backgroundColor: RpgColors.primary,
                  shadowColor: RpgColors.primary,
                  elevation: 5,
                ),
                child: Text(
                  _currentStep == 2 ? 'BEGIN QUEST' : 'NEXT STEP',
                  style: const TextStyle(letterSpacing: 1.2),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatarStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Who are you, Adventurer?',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 24),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Choose a username and your starter avatar class.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Username Text Field
          TextField(
            controller: _usernameController,
            decoration: const InputDecoration(
              labelText: 'Character Name',
              hintText: 'Enter your username...',
              prefixIcon: Icon(Icons.person, color: RpgColors.primary),
            ),
          ),
          const SizedBox(height: 36),

          Text(
            'Select Class:',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),

          // Horizontal Class Picker
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildAvatarCard('knight', 'Knight', 'Strong and disciplined. Built for gym & physical habits.'),
              _buildAvatarCard('mage', 'Mage', 'Wise and research-focused. Built for coding & learning.'),
              _buildAvatarCard('cyberpunk', 'Hacker', 'Techno-master. Built for productivity & career growth.'),
            ],
          ),

          const SizedBox(height: 36),
          Center(
            child: AvatarWidget(
              avatarBase: _selectedAvatar,
              size: 150,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarCard(String id, String label, String desc) {
    final isSelected = _selectedAvatar == id;
    return GestureDetector(
      onTap: () => setState(() => _selectedAvatar = id),
      child: Container(
        width: 100,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? RpgColors.primary.withAlpha(25) : RpgColors.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? RpgColors.primary : RpgColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              id == 'knight' 
                  ? Icons.shield 
                  : id == 'mage' 
                      ? Icons.auto_stories 
                      : Icons.terminal,
              color: isSelected ? RpgColors.primary : RpgColors.textSecondary,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? RpgColors.primary : RpgColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPetStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Adopt Your Virtual Companion',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 24),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Your pet will grow, evolve, and stay happy as you complete real-world quests.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          // Pet Name Field
          TextField(
            controller: _petNameController,
            decoration: const InputDecoration(
              labelText: 'Pet Name',
              hintText: 'Enter pet name...',
              prefixIcon: Icon(Icons.pets, color: RpgColors.primary),
            ),
          ),
          const SizedBox(height: 36),

          Text(
            'Select Companion Type:',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),

          // Companion Types
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildPetCard('slime', 'Jelly Slime', 'Cute, squishy, and hyper-reactive.'),
              _buildPetCard('dragon', 'Fire Dragon', 'Proud, powerful, and breathes fire.'),
            ],
          ),

          const SizedBox(height: 48),
          Center(
            child: PetWidget(
              stage: 'egg',
              visualType: _selectedPetType,
              size: 150,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPetCard(String id, String label, String desc) {
    final isSelected = _selectedPetType == id;
    return GestureDetector(
      onTap: () => setState(() => _selectedPetType = id),
      child: Container(
        width: 140,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? RpgColors.primary.withAlpha(25) : RpgColors.cardBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? RpgColors.primary : RpgColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              id == 'slime' ? Icons.bubble_chart : Icons.local_fire_department,
              color: isSelected ? RpgColors.primary : RpgColors.textSecondary,
              size: 32,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? RpgColors.primary : RpgColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              desc,
              style: const TextStyle(fontSize: 10, color: RpgColors.textSecondary),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSkillsStep() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Select Your Focus Life Domains',
            style: Theme.of(context).textTheme.displayLarge?.copyWith(fontSize: 24),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Unlock starter skill points in the domains you want to level up in real life.',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),

          _buildSkillTile('coding', 'Coding & Tech', 'Java, Dart, Python, Web Development.', Icons.code),
          _buildSkillTile('fitness', 'Fitness & Health', 'Gym, cardio, flexibility, stamina.', Icons.fitness_center),
          _buildSkillTile('learning', 'Learning & Reading', 'Books, research, memory, public speaking.', Icons.menu_book),
          _buildSkillTile('career', 'Career & Finance', 'Resume building, interviews, networking.', Icons.business_center),
        ],
      ),
    );
  }

  Widget _buildSkillTile(String id, String label, String desc, IconData icon) {
    final isSelected = _selectedSkills.contains(id);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedSkills.remove(id);
          } else {
            _selectedSkills.add(id);
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? RpgColors.primary.withAlpha(20) : RpgColors.cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? RpgColors.primary : RpgColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected ? RpgColors.primary.withAlpha(30) : RpgColors.border,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: isSelected ? RpgColors.primary : RpgColors.textSecondary),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    desc,
                    style: const TextStyle(color: RpgColors.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            ),
            Checkbox(
              value: isSelected,
              activeColor: RpgColors.primary,
              checkColor: Colors.black,
              onChanged: (val) {
                setState(() {
                  if (isSelected) {
                    _selectedSkills.remove(id);
                  } else {
                    _selectedSkills.add(id);
                  }
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
