import 'package:flutter/material.dart';

enum HomePeriod { week, month, year }

class HomePageSoftMockV2 extends StatefulWidget {
  const HomePageSoftMockV2({super.key});

  @override
  State<HomePageSoftMockV2> createState() => _HomePageSoftMockV2State();
}

class _HomePageSoftMockV2State extends State<HomePageSoftMockV2> {
  HomePeriod _period = HomePeriod.week;

  // 브랜드 컬러 (원하는 색으로 변경)
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
                    // 헤더 한 줄
                    // Padding(
                    //   padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
                    //   child: _HeaderLine(
                    //     title: _periodHeaderTitle(_period, s.distanceText),
                    //     subtitle:
                    //     '목표까지 ${(s.goalDistanceTotalKm - s.goalDistanceDoneKm).clamp(0, 999).toStringAsFixed(1)} km 남았어요',
                    //     brand: brand,
                    //   ),
                    // ),

                    // ✅ 통계(1×3)
                    SoftCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _CardTitle(
                            title: '통계',
                            trailing: _PeriodPillGroup(
                              value: _period,
                              brand: brand,
                              onChanged: (p) => setState(() => _period = p),
                            ),
                          ),
                          const SizedBox(height: 16),

                          _BigStat(label: '총 거리', value: s.distanceText),
                          const SizedBox(height: 14),
                          Divider(color: Colors.grey[200], height: 1),
                          const SizedBox(height: 14),

                          _BigStat(label: '평균 페이스', value: s.avgPaceText),
                          const SizedBox(height: 14),
                          Divider(color: Colors.grey[200], height: 1),
                          const SizedBox(height: 14),

                          _BigStat(label: '총 러닝 시간', value: s.totalTimeText),
                        ],
                      ),
                    ),

                    // 목표(한 카드 안에 2줄)
                    SoftCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const _CardTitle(title: '목표'),
                          const SizedBox(height: 12),

                          _GoalLine(
                            label: '거리 목표',
                            leftValue: '${s.goalDistanceDoneKm.toStringAsFixed(1)} km',
                            rightValue: '${s.goalDistanceTotalKm.toStringAsFixed(0)} km',
                            progress: (s.goalDistanceDoneKm / s.goalDistanceTotalKm).clamp(0.0, 1.0),
                            footer:
                            '남은 거리 ${(s.goalDistanceTotalKm - s.goalDistanceDoneKm).clamp(0, 999).toStringAsFixed(1)} km',
                            brand: brand,
                          ),
                          const SizedBox(height: 14),
                          Divider(color: Colors.grey[200], height: 1),
                          const SizedBox(height: 14),

                          _GoalLine(
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
                      child: Column(
                        children: const [
                          _RecentRunTile(
                            title: '아침 러닝',
                            subtitle: '3.4 km · 20:18 · 5\'58"',
                            dateText: '어제',
                          ),
                          Divider(height: 1),
                          _RecentRunTile(
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

            // 하단 floating start bar
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: _FloatingStartBar(
                brand: brand,
                onPressed: () {
                  // TODO: 러닝 시작 (페이지 이동 or WorkoutStartEvent)
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _periodHeaderTitle(HomePeriod p, String distanceText) {
    switch (p) {
      case HomePeriod.week:
        return '이번 주 $distanceText 달렸어요 🔥';
      case HomePeriod.month:
        return '이번 달 $distanceText 달렸어요 💪';
      case HomePeriod.year:
        return '올해 $distanceText 달렸어요 🏁';
    }
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

  _HomeMockStats _mockStats(HomePeriod p) {
    switch (p) {
      case HomePeriod.week:
        return const _HomeMockStats(
          distanceText: '18.6 km',
          avgPaceText: "5'52\"",
          totalTimeText: '01:49:12',
          goalDistanceDoneKm: 18.6,
          goalDistanceTotalKm: 25,
          goalPaceText: "5'40\"",
        );
      case HomePeriod.month:
        return const _HomeMockStats(
          distanceText: '62.3 km',
          avgPaceText: "6'03\"",
          totalTimeText: '06:17:55',
          goalDistanceDoneKm: 62.3,
          goalDistanceTotalKm: 90,
          goalPaceText: "5'50\"",
        );
      case HomePeriod.year:
        return const _HomeMockStats(
          distanceText: '402.8 km',
          avgPaceText: "6'10\"",
          totalTimeText: '41:26:08',
          goalDistanceDoneKm: 402.8,
          goalDistanceTotalKm: 600,
          goalPaceText: "5'55\"",
        );
    }
  }
}

/// -------------------- UI components --------------------

class SoftCard extends StatelessWidget {
  const SoftCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
  });

  final Widget child;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: padding,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _HeaderLine extends StatelessWidget {
  const _HeaderLine({
    required this.title,
    required this.subtitle,
    required this.brand,
  });

  final String title;
  final String subtitle;
  final Color brand;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: brand, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text(subtitle, style: TextStyle(fontSize: 13, color: Colors.grey[700])),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CardTitle extends StatelessWidget {
  const _CardTitle({required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const Spacer(),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class _PeriodPillGroup extends StatelessWidget {
  const _PeriodPillGroup({
    required this.value,
    required this.onChanged,
    required this.brand,
  });

  final HomePeriod value;
  final ValueChanged<HomePeriod> onChanged;
  final Color brand;

  @override
  Widget build(BuildContext context) {
    Widget pill(String label, HomePeriod p) {
      final selected = value == p;
      return InkWell(
        borderRadius: BorderRadius.circular(999),
        onTap: () => onChanged(p),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: selected ? brand : Colors.transparent,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: selected ? brand : Colors.grey[300]!),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: selected ? Colors.white : Colors.black,
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        pill('주', HomePeriod.week),
        const SizedBox(width: 6),
        pill('달', HomePeriod.month),
        const SizedBox(width: 6),
        pill('년', HomePeriod.year),
      ],
    );
  }
}

class _BigStat extends StatelessWidget {
  const _BigStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(fontSize: 34, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}

class _GoalLine extends StatelessWidget {
  const _GoalLine({
    required this.label,
    required this.leftValue,
    required this.rightValue,
    required this.progress,
    required this.footer,
    required this.brand,
  });

  final String label;
  final String leftValue;
  final String rightValue;
  final double progress;
  final String footer;
  final Color brand;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const Spacer(),
            Text(leftValue, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Text(' / $rightValue', style: TextStyle(fontSize: 13, color: Colors.grey[700])),
          ],
        ),
        const SizedBox(height: 10),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            color: brand,
            backgroundColor: Colors.grey[200],
          ),
        ),
        const SizedBox(height: 10),
        Text(footer, style: TextStyle(fontSize: 13, color: Colors.grey[700])),
      ],
    );
  }
}

class _RecentRunTile extends StatelessWidget {
  const _RecentRunTile({
    required this.title,
    required this.subtitle,
    required this.dateText,
  });

  final String title;
  final String subtitle;
  final String dateText;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: const Icon(Icons.directions_run_outlined),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
      trailing: Text(dateText, style: TextStyle(color: Colors.grey[700])),
      onTap: () {},
    );
  }
}

class _FloatingStartBar extends StatelessWidget {
  const _FloatingStartBar({
    required this.brand,
    required this.onPressed,
  });

  final Color brand;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: brand,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: const Text(
          'START',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

/// -------------------- Mock model --------------------

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
