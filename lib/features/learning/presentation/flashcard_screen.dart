import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:go_router/go_router.dart';

import '../../../app/providers/learning_direction_provider.dart';
import '../../../core/localization/app_copy.dart';
import '../../../core/providers/learning_session_provider.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../core/utils/learning_direction.dart';
import '../../../data/models/sentence_model.dart';
import '../../../data/models/word_model.dart';
import '../../../shared/widgets/app_button.dart';
import '../../../shared/widgets/app_shell.dart';
import '../../../shared/widgets/app_state_views.dart';
import '../../../shared/widgets/learning_direction_nav_button.dart';
import '../../../shared/widgets/session_summary_panel.dart';
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

  @override
  void initState() {
    super.initState();
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
    if (text.trim().isEmpty) return;
    await _tts.setLanguage(isEnglish ? 'en-US' : 'ky-KG');
    await _tts.stop();
    await _tts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    final provider = ref.watch(flashcardProvider);
    final direction = ref.watch(learningDirectionProvider);

    return AppShell(
      title: context.tr(ky: 'Карточкалар', en: 'Flashcards', ru: 'Карточки'),
      subtitle: context.tr(
        ky: 'Сөз байлыгын ритм менен бекемдеңиз',
        en: 'Build vocabulary rhythm',
        ru: 'Укрепляйте словарь в ритме',
      ),
      activeTab: AppTab.learn,
      navigationMode: AppShellNavigationMode.back,
      backFallbackRoute: '/categories',
      showBottomNav: false,
      topNavTrailing: const LearningDirectionNavButton(),
      topNavTrailingWidth: 108,
      child: Builder(
        builder: (context) {
          if (provider.isLoading) {
            return AppLoadingState(
              title: context.tr(
                ky: 'Карточкалар жүктөлүүдө',
                en: 'Flashcards are loading',
                ru: 'Карточки загружаются',
              ),
              message: context.tr(
                ky: 'Сөздөр жана мисалдар даярдалып жатат.',
                en: 'Words and examples are being prepared.',
                ru: 'Подготавливаются слова и примеры.',
              ),
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
                  ? context.tr(
                      ky: 'Кайталоо кезеги бош',
                      en: 'Review queue is empty',
                      ru: 'Очередь повторения пуста',
                    )
                  : context.tr(
                      ky: 'Карточкалар табылган жок',
                      en: 'No flashcards found',
                      ru: 'Карточки не найдены',
                    ),
              message: provider.isReviewQueueSession
                  ? context.tr(
                      ky: 'Бул категорияда азыр кайра карай турган сөз жок.',
                      en: 'There are no words to review in this category right now.',
                      ru: 'В этой категории сейчас нет слов для повторения.',
                    )
                  : context.tr(
                      ky: 'Бул категория үчүн сөздөр табылган жок.',
                      en: 'No words were found for this category.',
                      ru: 'Для этой категории слова не найдены.',
                    ),
              icon: Icons.style_outlined,
              actionLabel: provider.isReviewQueueSession
                  ? context.tr(
                      ky: 'Толук циклди ачуу',
                      en: 'Open full deck',
                      ru: 'Открыть полную колоду',
                    )
                  : context.tr(
                      ky: 'Кайра жүктөө',
                      en: 'Reload',
                      ru: 'Перезагрузить',
                    ),
              onAction: () => provider.load(
                widget.categoryId,
                mode: provider.isReviewQueueSession
                    ? FlashcardSessionMode.fullDeck
                    : widget.mode,
              ),
            );
          }

          final isEnToKy = direction == LearningDirection.enToKy;
          final prompt = isEnToKy ? word.english : word.kyrgyz;
          final translation = isEnToKy ? word.kyrgyz : word.english;
          final total = provider.stage == FlashcardStage.learning
              ? provider.totalWords
              : provider.mistakes.length;
          final speechText = provider.showTranslation ? translation : prompt;
          final speechIsEnglish = provider.showTranslation
              ? !isEnToKy
              : isEnToKy;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.mutedSurface,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    '${provider.index + 1} / $total',
                    style: AppTextStyles.caption.copyWith(
                      color: AppColors.muted,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                provider.stage == FlashcardStage.review
                    ? context.tr(
                        ky: 'Бүтөрдүн алдында татаал сөздөргө кайра келиңиз.',
                        en: 'Return to difficult words before finishing.',
                        ru: 'Перед завершением вернитесь к сложным словам.',
                      )
                    : provider.isReviewQueueSession
                    ? context.tr(
                        ky: 'Бул жерде кайталоону күткөн сөздөр гана көрсөтүлөт.',
                        en: 'Only words waiting for review are shown.',
                        ru: 'Здесь показаны только слова, ожидающие повторения.',
                      )
                    : context.tr(
                        ky: 'Котормосун көрүү үчүн карточканы басыңыз, анан жообуңузду белгилеңиз.',
                        en: 'Tap card to reveal translation, then mark your answer.',
                        ru: 'Нажмите карточку, чтобы открыть перевод, затем отметьте ответ.',
                      ),
                style: AppTextStyles.muted,
              ),
              const SizedBox(height: 12),
              _StageTag(
                text: provider.stage == FlashcardStage.review
                    ? context.tr(
                        ky: 'Кайталоо этабы',
                        en: 'Review stage',
                        ru: 'Этап повторения',
                      )
                    : provider.isReviewQueueSession
                    ? context.tr(
                        ky: 'Кайталоо кезеги',
                        en: 'Review queue',
                        ru: 'Очередь повторения',
                      )
                    : context.tr(
                        ky: 'Үйрөнүү этабы',
                        en: 'Learning stage',
                        ru: 'Этап обучения',
                      ),
              ),
              const SizedBox(height: 8),
              _DirectionHintChip(direction: direction),
              const SizedBox(height: 14),
              Align(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 370),
                  child: AspectRatio(
                    aspectRatio: 3 / 4,
                    child: _FlashcardDeckCard(
                      word: word,
                      sentence: provider.currentSentence,
                      direction: direction,
                      prompt: prompt,
                      showTranslation: provider.showTranslation,
                      onTapCard: provider.reveal,
                      onSpeak: () =>
                          _speak(speechText, isEnglish: speechIsEnglish),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              _DotsPager(total: total, currentIndex: provider.index),
              const SizedBox(height: 16),
              if (!provider.showTranslation)
                AppButton(
                  fullWidth: true,
                  onPressed: provider.reveal,
                  child: Text(
                    context.tr(
                      ky: 'Котормону көрсөтүү',
                      en: 'Reveal translation',
                      ru: 'Показать перевод',
                    ),
                  ),
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        variant: AppButtonVariant.outlined,
                        onPressed: () => provider.markAnswer(false),
                        child: Text(
                          context.tr(ky: 'Кыйын', en: 'Hard', ru: 'Сложно'),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppButton(
                        variant: AppButtonVariant.success,
                        onPressed: () => provider.markAnswer(true),
                        child: Text(
                          context.tr(ky: 'Жеңил', en: 'Easy', ru: 'Легко'),
                        ),
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 12),
              Text(
                context.tr(
                  ky: 'Эс тутумду бекемдөө үчүн шашпай, үн чыгарып кайталап туруңуз.',
                  en: 'Swipe feeling: stay calm and repeat aloud for better memory.',
                  ru: 'Для лучшего запоминания сохраняйте спокойный темп и повторяйте вслух.',
                ),
                style: AppTextStyles.caption,
                textAlign: TextAlign.center,
              ),
            ],
          );
        },
      ),
    );
  }
}

class _FlashcardDeckCard extends StatelessWidget {
  const _FlashcardDeckCard({
    required this.word,
    required this.sentence,
    required this.direction,
    required this.prompt,
    required this.showTranslation,
    required this.onTapCard,
    required this.onSpeak,
  });

  final WordModel word;
  final SentenceModel? sentence;
  final LearningDirection direction;
  final String prompt;
  final bool showTranslation;
  final VoidCallback onTapCard;
  final VoidCallback onSpeak;

  @override
  Widget build(BuildContext context) {
    final isEnToKy = direction == LearningDirection.enToKy;
    final mainTranslation = isEnToKy ? word.kyrgyz : word.english;
    final transcription = isEnToKy
        ? (word.transcriptionKy.isNotEmpty
              ? word.transcriptionKy
              : word.transcription)
        : word.transcription;

    final exampleKy = word.example.trim().isNotEmpty
        ? word.example
        : (sentence?.ky ?? '');
    final exampleEn = sentence?.en ?? '';
    final examplePrimary = isEnToKy ? exampleKy : exampleEn;
    final exampleSecondary = isEnToKy ? exampleEn : exampleKy;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTapCard,
        borderRadius: BorderRadius.circular(28),
        child: Ink(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(28),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: showTranslation
                  ? [
                      AppColors.primary,
                      Color.lerp(AppColors.primary, AppColors.accent, 0.25)!,
                    ]
                  : [AppColors.surface, AppColors.surface],
            ),
            border: Border.all(
              color: showTranslation
                  ? Colors.white.withValues(alpha: 0.16)
                  : AppColors.border,
            ),
            boxShadow: [
              BoxShadow(
                color: showTranslation
                    ? AppColors.primary.withValues(alpha: 0.22)
                    : Colors.black.withValues(alpha: 0.08),
                blurRadius: showTranslation ? 22 : 14,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: GestureDetector(
                  onTap: onSpeak,
                  child: Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: showTranslation
                          ? Colors.white.withValues(alpha: 0.18)
                          : AppColors.primary.withValues(alpha: 0.12),
                    ),
                    child: Icon(
                      Icons.volume_up,
                      color: showTranslation ? Colors.white : AppColors.primary,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              Text(
                prompt,
                style: AppTextStyles.heading.copyWith(
                  fontSize: 40,
                  color: showTranslation ? Colors.white : AppColors.textDark,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              Text(
                transcription.isEmpty ? ' ' : '/$transcription/',
                style: AppTextStyles.muted.copyWith(
                  color: showTranslation
                      ? Colors.white.withValues(alpha: 0.82)
                      : AppColors.muted,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              AnimatedCrossFade(
                duration: const Duration(milliseconds: 220),
                crossFadeState: showTranslation
                    ? CrossFadeState.showSecond
                    : CrossFadeState.showFirst,
                firstChild: Text(
                  context.tr(
                    ky: 'Ачуу үчүн басыңыз',
                    en: 'Tap to reveal',
                    ru: 'Нажмите, чтобы открыть',
                  ),
                  style: AppTextStyles.body.copyWith(color: AppColors.muted),
                  textAlign: TextAlign.center,
                ),
                secondChild: Column(
                  children: [
                    Text(
                      context.tr(
                        ky: 'Котормо',
                        en: 'Translation',
                        ru: 'Перевод',
                      ),
                      style: AppTextStyles.caption.copyWith(
                        color: Colors.white.withValues(alpha: 0.74),
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      mainTranslation,
                      style: AppTextStyles.title.copyWith(
                        color: Colors.white,
                        fontSize: 30,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    if (examplePrimary.isNotEmpty ||
                        exampleSecondary.isNotEmpty) ...[
                      const SizedBox(height: 10),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Column(
                          children: [
                            if (examplePrimary.isNotEmpty)
                              Text(
                                examplePrimary,
                                style: AppTextStyles.body.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            if (exampleSecondary.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                exampleSecondary,
                                style: AppTextStyles.caption.copyWith(
                                  color: Colors.white.withValues(alpha: 0.85),
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StageTag extends StatelessWidget {
  const _StageTag({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.mutedSurface,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          text,
          style: AppTextStyles.caption.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _DirectionHintChip extends StatelessWidget {
  const _DirectionHintChip({required this.direction});

  final LearningDirection direction;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.mutedSurface,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: AppColors.border),
        ),
        child: Text(
          direction.helperTextOf(context),
          style: AppTextStyles.caption.copyWith(
            color: AppColors.textDark,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

class _DotsPager extends StatelessWidget {
  const _DotsPager({required this.total, required this.currentIndex});

  final int total;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    final safeCurrent = currentIndex.clamp(0, total > 0 ? total - 1 : 0);
    final totalDots = total.clamp(0, 24);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(totalDots, (index) {
        final isCurrent = index == safeCurrent;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          margin: const EdgeInsets.symmetric(horizontal: 3),
          width: isCurrent ? 24 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: isCurrent ? AppColors.primary : AppColors.outline,
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
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
        .map((word) => '${word.english} -> ${word.kyrgyz}')
        .toList();
    final hasMistakes = mistakes.isNotEmpty;
    final isReviewQueueSession = provider.isReviewQueueSession;

    final primaryLabel = hasMistakes
        ? context.tr(
            ky: 'Татаал сөздөрдү кайталоо',
            en: 'Review difficult words',
            ru: 'Повторить сложные слова',
          )
        : isReviewQueueSession
        ? context.tr(ky: 'Квизге өтүү', en: 'Go to quiz', ru: 'Перейти к квизу')
        : context.tr(
            ky: 'Сүйлөм курууга өтүү',
            en: 'Build sentences',
            ru: 'Перейти к сборке предложений',
          );
    final primaryAction = hasMistakes
        ? provider.reviewMistakesOnly
        : isReviewQueueSession
        ? () => context.go('/quiz/$categoryId')
        : () => context.go('/sentence-builder/$categoryId');

    final secondaryLabel = hasMistakes
        ? context.tr(ky: 'Квизди ачуу', en: 'Open quiz', ru: 'Открыть квиз')
        : isReviewQueueSession
        ? context.tr(
            ky: 'Сүйлөм курууга өтүү',
            en: 'Build sentences',
            ru: 'Перейти к сборке предложений',
          )
        : context.tr(ky: 'Квизди ачуу', en: 'Open quiz', ru: 'Открыть квиз');
    final secondaryAction = hasMistakes
        ? () => context.go('/quiz/$categoryId')
        : isReviewQueueSession
        ? () => context.go('/sentence-builder/$categoryId')
        : () => context.go('/quiz/$categoryId');

    return SessionSummaryPanel(
      title: isReviewQueueSession
          ? context.tr(
              ky: 'Кайталоо аяктады',
              en: 'Review complete',
              ru: 'Повторение завершено',
            )
          : context.tr(
              ky: 'Колода аяктады',
              en: 'Deck complete',
              ru: 'Колода завершена',
            ),
      headline: _headline(context),
      message: hasMistakes
          ? context.tr(
              ky: 'Бир нече сөздү дагы бекемдөө керек. Дагы бир кыска кайталоо аларды эс тутумга бекемдетет.',
              en: 'A few words still need reinforcement. One more focused pass will lock them in memory.',
              ru: 'Некоторые слова еще нужно закрепить. Еще один короткий проход поможет запомнить их надежно.',
            )
          : context.tr(
              ky: 'Жакшы жыйынтык. Эми сүйлөм куруу же квизге өтүп, пассивдүү таанууну активдүү колдонууга айлантыңыз.',
              en: 'Strong finish. Continue with sentence builder or quiz to convert recognition into active usage.',
              ru: 'Отличный результат. Перейдите к сборке предложений или квизу, чтобы превратить узнавание в активное использование.',
            ),
      metrics: [
        SessionSummaryMetric(
          label: context.tr(ky: 'Карточкалар', en: 'Cards', ru: 'Карточки'),
          value: provider.totalWords.toString(),
        ),
        SessionSummaryMetric(
          label: context.tr(ky: 'Туура', en: 'Correct', ru: 'Верно'),
          value: provider.correctCount.toString(),
          color: AppColors.success,
        ),
        SessionSummaryMetric(
          label: context.tr(ky: 'Ката', en: 'Wrong', ru: 'Ошибки'),
          value: provider.wrongCount.toString(),
          color: AppColors.accent,
        ),
        SessionSummaryMetric(
          label: context.tr(ky: 'Тактык', en: 'Accuracy', ru: 'Точность'),
          value: '${provider.accuracyPercent}%',
          color: AppColors.primary,
        ),
      ],
      noteTitle: context.tr(
        ky: 'Кийинки мыкты кадам',
        en: 'Next best step',
        ru: 'Следующий лучший шаг',
      ),
      noteMessage: hasMistakes
          ? context.tr(
              ky: 'Ката кеткенден кийинки дароо кайталоо эң жакшы эс-тутум эффектин берет.',
              en: 'Repetition right after mistakes gives the highest recall boost.',
              ru: 'Повторение сразу после ошибок дает наибольший эффект запоминания.',
            )
          : context.tr(
              ky: 'Сүйлөм же квиз режимине өтүү сөздөрдү чыныгы колдонууда бекемдейт.',
              en: 'Switching to sentence or quiz mode strengthens real usage memory.',
              ru: 'Переход в режим предложений или квиза укрепляет память для реального использования.',
            ),
      tagsTitle: hasMistakes
          ? context.tr(
              ky: 'Кайра карай турган сөздөр',
              en: 'Words to revisit',
              ru: 'Слова для повторения',
            )
          : null,
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
      tertiaryLabel: context.tr(
        ky: 'Практикага кайтуу',
        en: 'Back to practice',
        ru: 'Назад к практике',
      ),
      onTertiaryTap: () => context.go('/practice'),
    );
  }

  String _headline(BuildContext context) {
    if (provider.wrongCount == 0 && provider.correctCount > 0) {
      return context.tr(
        ky: 'Эң сонун эс тутум',
        en: 'Excellent recall',
        ru: 'Отличное запоминание',
      );
    }
    if (provider.accuracyPercent >= 70) {
      return context.tr(
        ky: 'Жакшы темп',
        en: 'Great pace',
        ru: 'Отличный темп',
      );
    }
    return context.tr(
      ky: 'Дагы бир кайталоо цикли жардам берет',
      en: 'One more review cycle helps',
      ru: 'Еще один цикл повторения поможет',
    );
  }
}
