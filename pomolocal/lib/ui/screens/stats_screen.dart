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
                  'Statistics',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 24),

                // Today stats
                Text(
                  'Today',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        title: 'Sessions',
                        value: '${stats.todayFocusCount}',
                        subtitle: 'focus sessions completed',
                        icon: Icons.local_fire_department_rounded,
                        color: AppConstants.focusColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatCard(
                        title: 'Minutes',
                        value: '${stats.todayFocusMinutes}',
                        subtitle: 'minutes of focus',
                        icon: Icons.schedule_rounded,
                        color: AppConstants.longBreakColor,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Week stats
                Text(
                  'This Week',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        title: 'Sessions',
                        value: '${stats.weekFocusCount}',
                        subtitle: 'total this week',
                        icon: Icons.emoji_events_rounded,
                        color: AppConstants.shortBreakColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatCard(
                        title: 'Minutes',
                        value: '${stats.weekFocusMinutes}',
                        subtitle: 'total this week',
                        icon: Icons.timer_rounded,
                        color: Colors.deepPurple,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Weekly chart
                WeeklyChart(weeklyData: stats.weeklyBreakdown),
              ],
            ),
          ),
        );
      },
    );
  }
}
