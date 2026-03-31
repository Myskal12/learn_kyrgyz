import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/learning_session_provider.dart';
import '../../../app/providers/learning_direction_provider.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../core/utils/learning_direction.dart';
import '../../../shared/widgets/adaptive_panel_grid.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_shell.dart';
import '../../../shared/widgets/app_state_views.dart';
import '../../../shared/widgets/session_summary_panel.dart';
import '../../../data/models/sentence_model.dart';
import '../../../data/models/word_model.dart';
import '../providers/flashcard_provider.dart';

class FlashcardScreen extends ConsumerStatefulWidget {
  const FlashcardScreen({
    required this.categoryId,
    this.mode = FlashcardSessionMode.fullDeck,
    super.key,
  });
  final String categoryId;
  final FlashcardSessionMode mode;

  @override
  ConsumerState<FlashcardScreen> createState() => _FlashcardScreenState();
}

class _FlashcardScreenState extends ConsumerState<FlashcardScreen> {
  late final FlutterTts _tts;
  late final LearningDirection _direction;

  @override
  void initState() {
    super.initState();
    _direction = ref.read(learningDirectionProvider);
    _tts = FlutterTts()
      ..setLanguage('ky-KG')
      ..setPitch(1.0)
      ..setSpeechRate(0.4);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(learningSessionProvider).setLastCategoryId(widget.categoryId);
      ref.read(flashcardProvider).load(widget.categoryId, mode: widget.mode);
    });
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }

  Future<void> _speak(String text, {required bool isEnglish}) async {
    if (text.isEmpty) return;
    await _tts.setLanguage(isEnglish ? 'en-US' : 'ky-KG');
    await _tts.stop();
    await _tts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      title: 'Карточкалар',
      subtitle: 'Сөздөрдү бекемдөө',
      activeTab: AppTab.learn,
      navigationMode: AppShellNavigationMode.back,
      backFallbackRoute: '/categories',
      showBottomNav: false,
      child: Builder(
        builder: (context) {
          final provider = ref.watch(flashcardProvider);
          if (provider.isLoading) {
            return const AppLoadingState(
              title: 'Карточкалар жүктөлүүдө',
              message: 'Сөздөр жана мисал сүйлөмдөр даярдалып жатат.',
            );
          }
          if (provider.errorMessage != null) {
            return AppErrorState(
              message: provider.errorMessage!,
              onAction: () =>
                  provider.load(widget.categoryId, mode: widget.mode),
            );
          }
          if (provider.stage == FlashcardStage.completed) {
            return _FlashcardSummary(
              provider: provider,
              categoryId: widget.categoryId,
            );
          }
          final word = provider.current;
          if (word == null) {
            return AppEmptyState(
              title: provider.isReviewQueueSession
                  ? 'Кайталоо кезеги бош'
                  : 'Карточкалар табылган жок',
              message: provider.isReviewQueueSession
                  ? 'Бул категорияда азыр кайра бекемдей турган сөздөр жок. Толук циклди баштасаңыз, жаңы материал ачылат.'
                  : 'Бул категория үчүн сөздөр же кэш табылган жок. Кийинчерээк кайра текшерип көрүңүз.',
              icon: Icons.style_outlined,
              actionLabel: provider.isReviewQueueSession
                  ? 'Толук циклди ачуу'
                  : 'Кайра жүктөө',
              onAction: () => provider.load(
                widget.categoryId,
                mode: provider.isReviewQueueSession
                    ? FlashcardSessionMode.fullDeck
                    : widget.mode,
              ),
            );
          }
          final isEnToKy = _direction.isEnToKy;
          final prompt = isEnToKy ? word.english : word.kyrgyz;
          final translation = isEnToKy ? word.kyrgyz : word.english;
          final speechText = provider.showTranslation ? translation : prompt;
          final speechIsEnglish = provider.showTranslation
              ? !isEnToKy
              : isEnToKy;
          final total = provider.stage == FlashcardStage.learning
              ? provider.totalWords
              : provider.mistakes.length;
          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            children: [
              Row(
                children: [
                  Text(
                    'Карточкалар',
                    style: AppTextStyles.heading.copyWith(fontSize: 28),
                  ),
                  const Spacer(),
                  Text(
                    '${provider.index + 1} / $total',
                    style: AppTextStyles.body.copyWith(
                      fontWeight: FontWeight.w600,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                provider.stage == FlashcardStage.review
                    ? 'Ката кеткен сөздөргө кайра келдиңиз'
                    : provider.isReviewQueueSession
                    ? 'Бул жерде кайра бекемдөөнү күткөн сөздөр гана турат'
                    : 'Адегенде эстеп, анан карточканы ачыңыз',
                style: AppTextStyles.muted,
              ),
              const SizedBox(height: 20),
              _FlashcardHintCard(
                showTranslation: provider.showTranslation,
                stage: provider.stage,
                isReviewQueueSession: provider.isReviewQueueSession,
              ),
              const SizedBox(height: 16),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 350),
                child:
                    _Flashcard(
                          key: ValueKey(word.id),
                          word: word,
                          sentence: provider.currentSentence,
                          direction: _direction,
                          prompt: prompt,
                          showTranslation: provider.showTranslation,
                          onReveal: provider.reveal,
                          onSpeak: () =>
                              _speak(speechText, isEnglish: speechIsEnglish),
                        )
                        .animate()
                        .fadeIn(duration: 200.ms, curve: Curves.easeOut)
                        .scale(
                          begin: const Offset(0.98, 0.98),
                          end: const Offset(1.0, 1.0),
                        ),
              ),
              const SizedBox(height: 16),
              _ProgressDots(total: total, currentIndex: provider.index),
              const SizedBox(height: 16),
              AdaptivePanelGrid(
                maxColumns: 2,
                minItemWidth: 152,
                children: [
                  AppButton(
                    variant: AppButtonVariant.outlined,
                    fullWidth: true,
                    disabled: !provider.showTranslation,
                    onPressed: provider.showTranslation
                        ? () => provider.markAnswer(false)
                        : null,
                    child: const Text('Кыйын болду'),
                  ),
                  AppButton(
                    variant: AppButtonVariant.success,
                    fullWidth: true,
                    disabled: !provider.showTranslation,
                    onPressed: provider.showTranslation
                        ? () => provider.markAnswer(true)
                        : null,
                    child: const Text('Түшүндүм'),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Flashcard extends StatelessWidget {
  const _Flashcard({
    super.key,
    required this.word,
    this.sentence,
    required this.direction,
    required this.prompt,
    required this.showTranslation,
    required this.onReveal,
    required this.onSpeak,
  });

  final WordModel word;
  final SentenceModel? sentence;
  final LearningDirection direction;
  final String prompt;
  final bool showTranslation;
  final VoidCallback onReveal;
  final VoidCallback onSpeak;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onReveal,
      child: Container(
        padding: const EdgeInsets.all(28),
        constraints: const BoxConstraints(minHeight: 320),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            colors: [AppColors.primary, AppColors.accent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          boxShadow: [
            BoxShadow(
              color: const Color.fromRGBO(31, 31, 31, 0.16),
              blurRadius: 30,
              offset: Offset(0, 16),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: InkWell(
                onTap: onSpeak,
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.volume_up,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
            Column(
              children: [
                Text(
                  prompt,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                if (showTranslation) ...[
                  const SizedBox(height: 6),
                  Text(
                    direction == LearningDirection.enToKy
                        ? word.transcriptionKy.isNotEmpty
                              ? word.transcriptionKy
                              : word.transcription
                        : word.transcription,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.9),
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 250),
              crossFadeState: showTranslation
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: Text(
                'Басып, котормосун көрөсүз',
                style: AppTextStyles.body.copyWith(color: Colors.white60),
                textAlign: TextAlign.center,
              ),
              secondChild: _TranslationDetails(
                word: word,
                sentence: sentence,
                direction: direction,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TranslationDetails extends StatelessWidget {
  const _TranslationDetails({
    required this.word,
    required this.sentence,
    required this.direction,
  });

  final WordModel word;
  final SentenceModel? sentence;
  final LearningDirection direction;

  @override
  Widget build(BuildContext context) {
    final isEnToKy = direction == LearningDirection.enToKy;
    final exampleKy = word.example.trim().isNotEmpty
        ? word.example
        : (sentence?.ky ?? '');
    final exampleEn = sentence?.en ?? '';
    final primary = isEnToKy ? word.kyrgyz : word.english;
    final examplePrimary = isEnToKy ? exampleKy : exampleEn;
    final exampleSecondary = isEnToKy ? exampleEn : exampleKy;

    return Column(
      children: [
        Text(
          primary,
          style: const TextStyle(color: Colors.white, fontSize: 28),
          textAlign: TextAlign.center,
        ),
        if (examplePrimary.isNotEmpty || exampleSecondary.isNotEmpty) ...[
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                if (examplePrimary.isNotEmpty)
                  Text(
                    examplePrimary,
                    style: AppTextStyles.body.copyWith(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                if (exampleSecondary.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    exampleSecondary,
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
  const _FlashcardSummary({required this.provider, required this.categoryId});

  final FlashcardProvider provider;
  final String categoryId;

  @override
  Widget build(BuildContext context) {
    final mistakes = provider.mistakes
        .take(6)
        .map((word) => '${word.english} → ${word.kyrgyz}')
        .toList();
    final hasMistakes = mistakes.isNotEmpty;
    final isReviewQueueSession = provider.isReviewQueueSession;
    final message = hasMistakes
        ? 'Алсыз сөздөрдү азыр жапсаңыз, кийинки квиз же сүйлөм режими алда канча ишенимдүү өтөт.'
        : isReviewQueueSession
        ? 'Кайталоо кезегин жаптыңыз. Эми ушул теманы текшерүү же колдонуу режими менен бекемдеңиз.'
        : 'Сөздөр жакшы бекеди. Эми ошол эле теманы сүйлөм же квиз менен жандандырыңыз.';
    final noteMessage = hasMistakes
        ? 'Кыйын сөздөрдү ушул замат кайра өтүү эске сактоону тездетет.'
        : isReviewQueueSession
        ? 'Кайталоодон кийин квиз же сүйлөм түзүү пассивдүү таанууну активдүү колдонууга айлантат.'
        : 'Ушул эле категория боюнча сүйлөм түзүү же квиз билимди узагыраак сактайт.';
    final primaryLabel = hasMistakes
        ? 'Кыйын сөздөрдү кайра өтүү'
        : isReviewQueueSession
        ? 'Квиз менен текшерүү'
        : 'Сүйлөм түзүүгө өтүү';
    final primaryAction = hasMistakes
        ? provider.reviewMistakesOnly
        : isReviewQueueSession
        ? () => context.go('/quiz/$categoryId')
        : () => context.go('/sentence-builder/$categoryId');
    final secondaryLabel = hasMistakes
        ? 'Квиз менен текшерүү'
        : isReviewQueueSession
        ? 'Сүйлөм түзүүгө өтүү'
        : 'Квизге өтүү';
    final secondaryAction = hasMistakes
        ? () => context.go('/quiz/$categoryId')
        : isReviewQueueSession
        ? () => context.go('/sentence-builder/$categoryId')
        : () => context.go('/quiz/$categoryId');

    return SessionSummaryPanel(
      title: isReviewQueueSession ? 'Кайталоо аяктады' : 'Карточкалар аяктады',
      headline: _headline(),
      message: message,
      metrics: [
        SessionSummaryMetric(
          label: 'Сөздөр',
          value: provider.totalWords.toString(),
        ),
        SessionSummaryMetric(
          label: 'Түшүнгөндөр',
          value: provider.correctCount.toString(),
          color: AppColors.success,
        ),
        SessionSummaryMetric(
          label: 'Кыйын болгон',
          value: provider.wrongCount.toString(),
          color: AppColors.accent,
        ),
        SessionSummaryMetric(
          label: 'Тактык',
          value: '${provider.accuracyPercent}%',
          color: AppColors.primary,
        ),
      ],
      noteTitle: hasMistakes
          ? 'Кийинки эң жакшы кадам'
          : 'Күчтүү кийинки кадам',
      noteMessage: noteMessage,
      tagsTitle: hasMistakes ? 'Кайра карай турган сөздөр' : null,
      tags: mistakes,
      primaryAction: SessionSummaryAction(
        label: primaryLabel,
        onPressed: primaryAction,
      ),
      secondaryAction: SessionSummaryAction(
        label: secondaryLabel,
        onPressed: secondaryAction,
        variant: AppButtonVariant.outlined,
      ),
      tertiaryLabel: 'Практикага кайтуу',
      onTertiaryTap: () => context.go('/practice'),
    );
  }

  String _headline() {
    if (provider.wrongCount == 0 && provider.correctCount > 0) {
      return 'Сөздөр мыкты бекеди';
    }
    if (provider.accuracyPercent >= 70) {
      return 'Жакшы темп';
    }
    return 'Кайра кароо пайдалуу болот';
  }
}

class _FlashcardHintCard extends StatelessWidget {
  const _FlashcardHintCard({
    required this.showTranslation,
    required this.stage,
    required this.isReviewQueueSession,
  });

  final bool showTranslation;
  final FlashcardStage stage;
  final bool isReviewQueueSession;

  @override
  Widget build(BuildContext context) {
    final isReview = stage == FlashcardStage.review;
    return AppCard(
      padding: const EdgeInsets.all(14),
      backgroundColor: isReview
          ? AppColors.accent.withValues(alpha: 0.06)
          : AppColors.primary.withValues(alpha: 0.05),
      borderColor: isReview
          ? AppColors.accent.withValues(alpha: 0.18)
          : AppColors.primary.withValues(alpha: 0.18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: (isReview ? AppColors.accent : AppColors.primary)
                  .withValues(alpha: 0.12),
            ),
            child: Icon(
              isReview ? Icons.refresh : Icons.lightbulb_outline,
              size: 18,
              color: isReview ? AppColors.accent : AppColors.primary,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isReview
                  ? 'Бул этапта мурун кыйын болгон сөздөр гана калды. Кыска, так жооп берип жабыңыз.'
                  : isReviewQueueSession
                  ? 'Бул цикл жаңы сөздөр үчүн эмес, мурун жооп бербей калган же мөөнөтү жеткен сөздөр үчүн ачылды.'
                  : showTranslation
                  ? 'Эми үнүн угуп, мисалды окуп, анан гана баа бериңиз.'
                  : 'Алгач сөздү өзүңүз эстеп көрүңүз, андан кийин карточканы ачып текшериңиз.',
              style: AppTextStyles.muted,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgressDots extends StatelessWidget {
  const _ProgressDots({required this.total, required this.currentIndex});

  final int total;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(total, (index) {
        final active = index == currentIndex;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 4),
          height: 8,
          width: active ? 28 : 8,
          decoration: BoxDecoration(
            color: active
                ? AppColors.primary
                : AppColors.muted.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );
  }
}
