import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/app_text_styles.dart';
import '../../../data/models/word_model.dart';
import '../../learning/repository/words_repository.dart';
import '../../profile/providers/progress_provider.dart';

class QuickQuizScreen extends StatefulWidget {
  const QuickQuizScreen({super.key});

  @override
  State<QuickQuizScreen> createState() => _QuickQuizScreenState();
}

class _QuickQuizScreenState extends State<QuickQuizScreen> {
  late final WordsRepository _repo;
  late final ProgressProvider _progress;
  final _random = Random();

  WordModel? _current;
  List<String> _options = [];
  int _score = 0;
  int _asked = 0;
  bool _answered = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _repo = context.read<WordsRepository>();
    _progress = context.read<ProgressProvider>();
    if (_current == null) {
      _generateQuestion();
    }
  }

  void _generateQuestion() {
    final all = _repo.allWords;
    if (all.length < 4) return;
    _current = all[_random.nextInt(all.length)];
    final distractors = <String>{};
    while (distractors.length < 3) {
      final candidate = all[_random.nextInt(all.length)].english;
      if (candidate != _current!.english) {
        distractors.add(candidate);
      }
    }
    _options = [...distractors, _current!.english]..shuffle();
    _answered = false;
    setState(() {});
  }

  void _answer(String value) {
    if (_answered || _current == null) return;
    _answered = true;
    _asked++;
    final correct = value == _current!.english;
    if (correct) {
      _score++;
      _progress.markWordMastered(_current!.id);
    } else {
      _progress.markWordSeen(_current!.id);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final word = _current;
    if (word == null) {
      return const Scaffold(body: Center(child: Text('Жеткиликтүү сөздөр жок.')));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Тез квиз')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Натыйжа: $_score / $_asked', style: AppTextStyles.body),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                title: Text(word.kyrgyz, style: AppTextStyles.heading),
                subtitle: Text(word.transcription, style: AppTextStyles.muted),
              ),
            ),
            const SizedBox(height: 20),
            ..._options.map(
              (option) => Container(
                margin: const EdgeInsets.only(bottom: 12),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    backgroundColor: !_answered
                        ? null
                        : option == word.english
                            ? Colors.green
                            : Colors.grey.shade400,
                  ),
                  onPressed: () => _answer(option),
                  child: Text(option),
                ),
              ),
            ),
            const Spacer(),
            FilledButton(
              onPressed: () {
                _generateQuestion();
              },
              child: const Text('Кийинки суроо'),
            ),
          ],
        ),
      ),
    );
  }
}
