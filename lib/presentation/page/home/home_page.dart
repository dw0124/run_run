import 'package:flutter/material.dart';
import 'package:run_run/presentation/bloc/workout_history_bloc.dart';
import 'package:run_run/presentation/page/home/widgets/home_big_stat.dart';
import 'package:run_run/presentation/page/home/widgets/home_card_title.dart';
import 'package:run_run/presentation/page/home/widgets/home_floating_start_bar.dart';
import 'package:run_run/presentation/page/home/widgets/home_goal_line.dart';
import 'package:run_run/presentation/page/home/widgets/home_period_pill_group.dart';
import 'package:run_run/presentation/page/home/widgets/home_recent_run_tile.dart';
import 'package:run_run/presentation/widgets/soft_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  WorkoutPeriod _period = WorkoutPeriod.week;

  final Color brand = const Color(0xFF2F80FF);

  @override
  Widget build(BuildContext context) {
    final s = _mockStats(_period);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F9),
      appBar: AppBar(
        title: const Text('홈'),
        elevation: 0,
        backgroundColor: const Color(0xFFF6F7F9),
        foregroundColor: Colors.black,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.settings_outlined)),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 110),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 통계(1×3)
                    SoftCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          HomeCardTitle(
                            title: '통계',
                            trailing: HomePeriodPillGroup(
                              value: _period,
                              brand: brand,
                              onChanged: (p) => setState(() => _period = p),
                            ),
                          ),
                          const SizedBox(height: 16),

                          HomeBigStat(label: '총 거리', value: s.distanceText),
                          const SizedBox(height: 14),
                          Divider(color: Colors.grey[200], height: 1),
                          const SizedBox(height: 14),

                          HomeBigStat(label: '평균 페이스', value: s.avgPaceText),
                          const SizedBox(height: 14),
                          Divider(color: Colors.grey[200], height: 1),
                          const SizedBox(height: 14),

                          HomeBigStat(label: '총 러닝 시간', value: s.totalTimeText),
                        ],
                      ),
                    ),

                    // 목표
                    SoftCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const HomeCardTitle(title: '목표'),
                          const SizedBox(height: 12),

                          HomeGoalLine(
                            label: '거리 목표',
                            leftValue: '${s.goalDistanceDoneKm.toStringAsFixed(1)} km',
                            rightValue: '${s.goalDistanceTotalKm.toStringAsFixed(0)} km',
                            progress: (s.goalDistanceDoneKm / s.goalDistanceTotalKm).clamp(0.0, 1.0),
                            footer: '남은 거리 ${(s.goalDistanceTotalKm - s.goalDistanceDoneKm).clamp(0, 999).toStringAsFixed(1)} km',
                            brand: brand,
                          ),
                          const SizedBox(height: 14),
                          Divider(color: Colors.grey[200], height: 1),
                          const SizedBox(height: 14),

                          HomeGoalLine(
                            label: '페이스 목표',
                            leftValue: s.avgPaceText,
                            rightValue: s.goalPaceText,
                            progress: _paceProgress(s.avgPaceText, s.goalPaceText),
                            footer: '현재 평균 vs 목표',
                            brand: brand,
                          ),
                        ],
                      ),
                    ),

                    // 최근 러닝
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 6, 16, 4),
                      child: Row(
                        children: [
                          const Text(
                            '최근 러닝',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const Spacer(),
                          TextButton(onPressed: () {}, child: const Text('전체 보기')),
                        ],
                      ),
                    ),
                    SoftCard(
                      padding: EdgeInsets.zero,
                      child: const Column(
                        children: [
                          HomeRecentRunTile(
                            title: '아침 러닝',
                            subtitle: '3.4 km · 20:18 · 5\'58"',
                            dateText: '어제',
                          ),
                          Divider(height: 1),
                          HomeRecentRunTile(
                            title: '저녁 러닝',
                            subtitle: '5.1 km · 29:40 · 5\'49"',
                            dateText: '3일 전',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 12),
                  ],
                ),
              ),
            ),

            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: HomeFloatingStartBar(
                brand: brand,
                onPressed: () {
                  // TODO: 러닝 시작
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  double _paceProgress(String current, String goal) {
    int toSec(String pace) {
      final m = RegExp(r"(\d+)'(\d+)").firstMatch(pace);
      if (m == null) return 0;
      final min = int.tryParse(m.group(1) ?? '') ?? 0;
      final sec = int.tryParse(m.group(2) ?? '') ?? 0;
      return min * 60 + sec;
    }

    final c = toSec(current);
    final g = toSec(goal);
    if (c <= 0 || g <= 0) return 0.0;
    return (g / c).clamp(0.0, 1.0);
  }

  _HomeMockStats _mockStats(WorkoutPeriod p) {
    return switch (p) {
      WorkoutPeriod.week => const _HomeMockStats(
        distanceText: '18.6 km',
        avgPaceText: "5'52\"",
        totalTimeText: '01:49:12',
        goalDistanceDoneKm: 18.6,
        goalDistanceTotalKm: 25,
        goalPaceText: "5'40\"",
      ),
      WorkoutPeriod.month => const _HomeMockStats(
        distanceText: '62.3 km',
        avgPaceText: "6'03\"",
        totalTimeText: '06:17:55',
        goalDistanceDoneKm: 62.3,
        goalDistanceTotalKm: 90,
        goalPaceText: "5'50\"",
      ),
      WorkoutPeriod.year => const _HomeMockStats(
        distanceText: '402.8 km',
        avgPaceText: "6'10\"",
        totalTimeText: '41:26:08',
        goalDistanceDoneKm: 402.8,
        goalDistanceTotalKm: 600,
        goalPaceText: "5'55\"",
      ),
    };
  }
}

class _HomeMockStats {
  const _HomeMockStats({
    required this.distanceText,
    required this.avgPaceText,
    required this.totalTimeText,
    required this.goalDistanceDoneKm,
    required this.goalDistanceTotalKm,
    required this.goalPaceText,
  });

  final String distanceText;
  final String avgPaceText;
  final String totalTimeText;
  final double goalDistanceDoneKm;
  final double goalDistanceTotalKm;
  final String goalPaceText;
}
