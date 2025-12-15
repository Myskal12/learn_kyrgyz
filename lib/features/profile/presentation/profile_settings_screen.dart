import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/app_text_styles.dart';
import '../providers/user_profile_provider.dart';

class ProfileSettingsScreen extends StatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  State<ProfileSettingsScreen> createState() => _ProfileSettingsScreenState();
}

class _ProfileSettingsScreenState extends State<ProfileSettingsScreen> {
  late final TextEditingController _controller;
  String? _selectedAvatar;
  final List<String> _avatars = [
    '🙂',
    '😎',
    '🦊',
    '🐻',
    '🐱',
    '🦁',
    '🐢',
    '🐦',
  ];

  @override
  void initState() {
    super.initState();
    final profile = Provider.of<UserProfileProvider>(
      context,
      listen: false,
    ).profile;
    _controller = TextEditingController(text: profile.nickname);
    _selectedAvatar = profile.avatar;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UserProfileProvider>();
    final disabled = provider.isGuest;
    return Scaffold(
      appBar: AppBar(title: const Text('Профиль орнотуулары')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: disabled
            ? Center(
                child: Text(
                  'Профилди өзгөртүү үчүн аккаунтка кирүү керек.',
                  style: AppTextStyles.muted,
                  textAlign: TextAlign.center,
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Никнейм', style: AppTextStyles.body),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Никнеймиңизди жазыңыз',
                      filled: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text('Аватар', style: AppTextStyles.body),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: _avatars
                        .map(
                          (emoji) => ChoiceChip(
                            label: Text(
                              emoji,
                              style: const TextStyle(fontSize: 20),
                            ),
                            selected: _selectedAvatar == emoji,
                            onSelected: (value) {
                              if (!value) return;
                              setState(() {
                                _selectedAvatar = emoji;
                              });
                            },
                          ),
                        )
                        .toList(),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: () async {
                      await provider.updateNickname(_controller.text);
                      if (_selectedAvatar != null) {
                        await provider.updateAvatar(_selectedAvatar!);
                      }
                      if (!context.mounted) return;
                      Navigator.pop(context);
                    },
                    child: const Padding(
                      padding: EdgeInsets.symmetric(vertical: 14),
                      child: Text('Сактоо'),
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
