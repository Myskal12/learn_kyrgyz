import 'package:flutter/material.dart';

import '../../../core/utils/app_text_styles.dart';

class StudyPlanScreen extends StatelessWidget {
  const StudyPlanScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tasks = [
      _StudyTask(
        title: 'Карточкаларды кайталоо',
        description: 'Күнүнө 10 жаңы сөздү кайталаңыз.',
        duration: '10 мүнөт',
      ),
      _StudyTask(
        title: 'Жазуу',
        description: 'Жаңы сөздөр менен 2-3 сүйлөм түзүңүз.',
        duration: '5 мүнөт',
      ),
      _StudyTask(
        title: 'Угуу',
        description: 'Аудио угуп, айтылышын кайталаңыз.',
        duration: '7 мүнөт',
      ),
      _StudyTask(
        title: 'Квиз',
        description: 'Кыска квиз менен өзүңүздү текшериңиз.',
        duration: '5 мүнөт',
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Күнүмдүк план')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          final task = tasks[index];
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(18),
            ),
            child: ListTile(
              title: Text(task.title, style: AppTextStyles.title),
              subtitle: Text(task.description),
              trailing: Chip(label: Text(task.duration)),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(height: 10),
        itemCount: tasks.length,
      ),
    );
  }
}

class _StudyTask {
  const _StudyTask({
    required this.title,
    required this.description,
    required this.duration,
  });
  final String title;
  final String description;
  final String duration;
}
