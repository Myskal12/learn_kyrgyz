import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/learning_session_provider.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../data/models/sentence_model.dart';
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
      context.read<LearningSessionProvider>().setLastCategoryId(
        widget.categoryId,
      );
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
            if (provider.stage == FlashcardStage.completed) {
              return _FlashcardSummary(provider: provider);
            }
            final word = provider.current;
            if (word == null) {
              return const Center(child: Text('Сөздөр табылган жок.'));
            }
            final total = provider.stage == FlashcardStage.learning
                ? provider.totalWords
                : provider.mistakes.length;
            final progressValue = total == 0
                ? 0.0
                : (provider.index + 1) / total.toDouble();

            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        provider.stage == FlashcardStage.learning
                            ? '1-айлампа'
                            : 'Ката сөздөр',
                        style: AppTextStyles.body,
                      ),
                      const Spacer(),
                      Text(
                        '${provider.index + 1}/$total',
                        style: AppTextStyles.title,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: progressValue,
                    minHeight: 8,
                    backgroundColor: AppColors.background,
                    valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 350),
                      child: _Flashcard(
                        key: ValueKey(word.id),
                        word: word,
                        sentence: provider.currentSentence,
                        showTranslation: provider.showTranslation,
                        onReveal: provider.reveal,
                        onSpeak: () => _speak(word.kyrgyz),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => provider.markAnswer(false),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('Кыйын болду'),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () => provider.markAnswer(true),
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child: const Text('Түшүндүм'),
                        ),
                      ),
                    ],
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
    this.sentence,
    required this.showTranslation,
    required this.onReveal,
    required this.onSpeak,
  });

  final WordModel word;
  final SentenceModel? sentence;
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
            colors: [AppColors.primary, Color(0xFF7F0E12)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.volume_up, color: Colors.white),
                onPressed: onSpeak,
                tooltip: 'Угуу',
              ),
            ),
            const SizedBox(height: 12),
            Text(
              word.english,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 36,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 250),
              crossFadeState: showTranslation
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: Text(
                'Таптап котормосун көрүү үчүн карточканы басыңыз.',
                style: AppTextStyles.body.copyWith(color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              secondChild: _TranslationDetails(word: word, sentence: sentence),
            ),
          ],
        ),
      ),
    );
  }
}

class _TranslationDetails extends StatelessWidget {
  const _TranslationDetails({required this.word, required this.sentence});

  final WordModel word;
  final SentenceModel? sentence;

  @override
  Widget build(BuildContext context) {
    final transcription = word.transcriptionKy.isNotEmpty
        ? word.transcriptionKy
        : word.transcription;
    final exampleKy = word.example.trim().isNotEmpty
        ? word.example
        : (sentence?.ky ?? '');
    final exampleEn = sentence?.en ?? '';

    return Column(
      children: [
        Text(
          word.kyrgyz,
          style: const TextStyle(color: Colors.white, fontSize: 28),
          textAlign: TextAlign.center,
        ),
        if (transcription.isNotEmpty) ...[
          const SizedBox(height: 6),
          Text(
            transcription,
            style: const TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
        ],
        if (exampleKy.isNotEmpty || exampleEn.isNotEmpty) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
            ),
            child: Column(
              children: [
                if (exampleKy.isNotEmpty)
                  Text(
                    exampleKy,
                    style: AppTextStyles.body.copyWith(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                if (exampleEn.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    exampleEn,
                    style: AppTextStyles.muted.copyWith(
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ],
      ],
    );
  }
}

class _FlashcardSummary extends StatelessWidget {
  const _FlashcardSummary({required this.provider});

  final FlashcardProvider provider;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Сессия аяктады', style: AppTextStyles.heading),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: const [
                BoxShadow(
                  color: AppColors.cardShadow,
                  blurRadius: 20,
                  offset: Offset(0, 12),
                ),
              ],
            ),
            child: Column(
              children: [
                _SummaryRow(
                  label: 'Сөздөр',
                  value: provider.totalWords.toString(),
                ),
                const SizedBox(height: 8),
                _SummaryRow(
                  label: 'Түшүнгөндөр',
                  value: provider.correctCount.toString(),
                ),
                const SizedBox(height: 8),
                _SummaryRow(
                  label: 'Кыйын болгон',
                  value: provider.wrongCount.toString(),
                ),
                if (provider.mistakes.isNotEmpty) ...[
                  const Divider(height: 32),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Кийинчерээк кайталаңыз:',
                      style: AppTextStyles.body,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: provider.mistakes
                        .map(
                          (word) => Chip(
                            label: Text('${word.english} → ${word.kyrgyz}'),
                          ),
                        )
                        .toList(),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: provider.restart,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 14),
              child: Text('Карточкаларды кайра өтүү'),
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Категорияга кайтуу'),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTextStyles.body),
        Text(value, style: AppTextStyles.title),
      ],
    );
  }
}
