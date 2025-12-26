import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/services/firebase_service.dart';
import '../../../core/utils/app_colors.dart';
import '../../../core/utils/app_text_styles.dart';
import '../../../data/models/user_profile_model.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  late Future<List<UserProfileModel>> _future;

  @override
  void initState() {
    super.initState();
    final service = Provider.of<FirebaseService>(context, listen: false);
    _future = service.fetchLeaderboard(limit: 30);
  }

  Future<void> _refresh() async {
    final service = Provider.of<FirebaseService>(context, listen: false);
    final data = await service.fetchLeaderboard(limit: 30);
    if (!mounted) return;
    setState(() {
      _future = Future.value(data);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Лидерборд')),
      body: FutureBuilder<List<UserProfileModel>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data ?? const [];
          if (data.isEmpty) {
            return const Center(
              child: Text(
                'Лидерборд азыр бош. Жаңы жыйынтыктарды күтүп жатабыз.',
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: data.length,
              itemBuilder: (context, index) {
                final user = data[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.surface,
                      child: Text(
                        user.avatar,
                        style: const TextStyle(fontSize: 20),
                      ),
                    ),
                    title: Text('${index + 1}. ${user.nickname}'),
                    subtitle: Text(
                      'Үйрөнгөн: ${user.totalMastered} | Кайталоо: ${user.totalSessions} | Тактык: ${user.accuracy}%',
                      style: AppTextStyles.muted.copyWith(fontSize: 13),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
