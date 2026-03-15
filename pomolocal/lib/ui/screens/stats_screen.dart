import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pomolocal/core/constants.dart';
import 'package:pomolocal/logic/providers/stats_provider.dart';
import 'package:pomolocal/ui/widgets/stat_card.dart';
import 'package:pomolocal/ui/widgets/weekly_chart.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<StatsProvider>(
      builder: (context, stats, _) {
        return SafeArea(
          child: RefreshIndicator(
            onRefresh: () async => stats.refresh(),
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const SizedBox(height: 8),
                Text(
                  'İstatistikler',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 24),

                Text(
                  'Bugün',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        title: 'Oturumlar',
                        value: '${stats.todayFocusCount}',
                        subtitle: 'tamamlanan odak oturumu',
                        icon: Icons.local_fire_department_rounded,
                        color: AppConstants.focusColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatCard(
                        title: 'Dakika',
                        value: '${stats.todayFocusMinutes}',
                        subtitle: 'dakika odaklanma',
                        icon: Icons.schedule_rounded,
                        color: AppConstants.longBreakColor,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                Text(
                  'Bu Hafta',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        title: 'Oturumlar',
                        value: '${stats.weekFocusCount}',
                        subtitle: 'haftalık toplam',
                        icon: Icons.emoji_events_rounded,
                        color: AppConstants.shortBreakColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatCard(
                        title: 'Dakika',
                        value: '${stats.weekFocusMinutes}',
                        subtitle: 'haftalık toplam',
                        icon: Icons.timer_rounded,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                WeeklyChart(weeklyData: stats.weeklyBreakdown),
              ],
            ),
          ),
        );
      },
    );
  }
}
