import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_text_styles.dart';
import '../providers/quiz_provider.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key, required this.categoryId});
  final String categoryId;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<QuizProvider>().start(widget.categoryId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Квиз')),
      body: SafeArea(
        child: Consumer<QuizProvider>(
          builder: (context, quiz, _) {
            if (quiz.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (quiz.isCompleted) {
              return _QuizResult(score: quiz.score, total: quiz.totalQuestions, onRestart: quiz.restart);
            }
            final word = quiz.currentWord;
            if (word == null) {
              return const Center(child: Text('Бул темада жетиштүү сөздөр жок.'));
            }

            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Text('Суроо ${quiz.index + 1}/${quiz.totalQuestions}', style: AppTextStyles.body),
                      const Spacer(),
                      Text('${(quiz.progress * 100).round()}%', style: AppTextStyles.body.copyWith(color: AppColors.primary)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: quiz.progress,
                    minHeight: 6,
                    backgroundColor: AppColors.bg,
                    valueColor: const AlwaysStoppedAnimation(AppColors.accent),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 18, offset: Offset(0, 8))],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Кайсы сөз англисче кандай айтылат?', style: AppTextStyles.muted),
                        const SizedBox(height: 12),
                        Text(word.kyrgyz, style: AppTextStyles.heading),
                        const SizedBox(height: 6),
                        Text(word.transcription, style: AppTextStyles.muted),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView.separated(
                      itemCount: quiz.options.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final option = quiz.options[index];
                        final selected = quiz.selected == option;
                        final isCorrect = quiz.answered && quiz.currentWord?.english == option;
                        final color = !quiz.answered
                            ? Colors.white
                            : isCorrect
                                ? AppColors.accent.withValues(alpha: 0.2)
                                : selected
                                    ? Colors.red.withValues(alpha: 0.1)
                                    : Colors.white;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          decoration: BoxDecoration(
                            color: color,
                            border: Border.all(
                              color: isCorrect
                                  ? AppColors.accent
                                  : selected
                                      ? Colors.red
                                      : Colors.grey.shade200,
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ListTile(
                            onTap: () => quiz.selectAnswer(option),
                            title: Text(option, style: AppTextStyles.title),
                            trailing: quiz.answered && isCorrect
                                ? const Icon(Icons.check_circle, color: AppColors.accent)
                                : quiz.answered && selected
                                    ? const Icon(Icons.close, color: Colors.red)
                                    : null,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: quiz.answered ? quiz.nextQuestion : null,
                    child: Text(quiz.index == quiz.totalQuestions - 1 ? 'Жыйынтык' : 'Кийинки'),
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

class _QuizResult extends StatelessWidget {
  const _QuizResult({required this.score, required this.total, required this.onRestart});

  final int score;
  final int total;
  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    final accuracy = total == 0 ? 0 : ((score / total) * 100).round();
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('Сын-пикир', style: AppTextStyles.heading),
          const SizedBox(height: 12),
          Text('Сен $total суроонун $score деине туура жооп бердиң.', style: AppTextStyles.body, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          Text('$accuracy%', style: AppTextStyles.heading.copyWith(color: AppColors.accent, fontSize: 48)),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: onRestart,
            icon: const Icon(Icons.refresh),
            label: const Text('Дагы бир жолу'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Башкы бетке кайтуу'),
          )
        ],
      ),
    );
  }
}
