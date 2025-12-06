import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../data/models/word_model.dart';
import '../providers/flashcard_provider.dart';

class FlashcardScreen extends StatefulWidget {
  const FlashcardScreen({required this.categoryId, super.key});
  final String categoryId;

  @override
  State<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends State<FlashcardScreen> {
  late final FlutterTts _tts;

  @override
  void initState() {
    super.initState();
    _tts = FlutterTts()
      ..setLanguage('ky-KG')
      ..setPitch(1.0)
      ..setSpeechRate(0.4);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FlashcardProvider>().load(widget.categoryId);
    });
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  Future<void> _speak(String text) async {
    if (text.isEmpty) return;
    await _tts.stop();
    await _tts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Карточкалар')),
      body: SafeArea(
        child: Consumer<FlashcardProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            final word = provider.current;
            if (word == null) {
              return const Center(child: Text('Бул темада сөздөр жок.'));
            }
            final total = provider.words.length;
            final position = '${provider.index + 1}/$total';

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text('Прогресс', style: AppTextStyles.body.copyWith(color: AppColors.muted)),
                      const Spacer(),
                      Text(position, style: AppTextStyles.title.copyWith(color: AppColors.primary)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: total == 0 ? 0 : (provider.index + 1) / total,
                    backgroundColor: AppColors.bg,
                    valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 350),
                      child: _Flashcard(
                        key: ValueKey(word.id),
                        word: word,
                        showTranslation: provider.showTranslation,
                        onReveal: provider.toggleTranslation,
                        onSpeak: () => _speak(word.kyrgyz),
                      ),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _CircleButton(icon: Icons.arrow_back_ios_new_rounded, onTap: provider.previous),
                      _CircleButton(icon: Icons.translate_rounded, onTap: provider.toggleTranslation),
                      _CircleButton(icon: Icons.arrow_forward_ios_rounded, onTap: provider.next),
                    ],
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () {
                        provider.markMastered();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Азамат! Бул сөздү өздөштүрдүң.')),
                        );
                      },
                      icon: const Icon(Icons.emoji_events_rounded),
                      label: const Text('Бул сөздү өздөштүрдүм'),
                      style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _Flashcard extends StatelessWidget {
  const _Flashcard({
    super.key,
    required this.word,
    required this.showTranslation,
    required this.onReveal,
    required this.onSpeak,
  });

  final WordModel word;
  final bool showTranslation;
  final VoidCallback onReveal;
  final VoidCallback onSpeak;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onReveal,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: const LinearGradient(
            colors: [AppColors.primary, Color(0xFF312E81)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 20, offset: Offset(0, 10))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.volume_up, color: Colors.white),
                  onPressed: onSpeak,
                  tooltip: 'Угуу',
                )
              ],
            ),
            const SizedBox(height: 12),
            Text(
              word.english,
              style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 300),
              crossFadeState: showTranslation ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              firstChild: Text(
                'Таптап котормосун көрүңүз',
                style: AppTextStyles.body.copyWith(color: Colors.white70),
              ),
              secondChild: Column(
                children: [
                  Text(word.kyrgyz, style: const TextStyle(color: Colors.white, fontSize: 26)),
                  const SizedBox(height: 6),
                  Text(word.transcription, style: const TextStyle(color: Colors.white70)),
                  const SizedBox(height: 12),
                  Text(
                    word.example,
                    style: AppTextStyles.body.copyWith(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CircleButton extends StatefulWidget {
  const _CircleButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  State<_CircleButton> createState() => _CircleButtonState();
}

class _CircleButtonState extends State<_CircleButton> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 180));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleTap() {
    _controller.forward(from: 0).then((_) => _controller.reverse());
    widget.onTap();
  }

  @override
  Widget build(BuildContext context) {
    final scale = Tween(begin: 1.0, end: 0.88).animate(_controller);
    return GestureDetector(
      onTap: _handleTap,
      child: AnimatedBuilder(
        animation: scale,
        builder: (context, child) => Transform.scale(scale: scale.value, child: child),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
            boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
          ),
          child: Icon(widget.icon, color: Colors.white),
        ),
      ),
    );
  }
}
