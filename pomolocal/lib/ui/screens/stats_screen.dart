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
        final theme = Theme.of(context);

        return SafeArea(
          child: RefreshIndicator(
            onRefresh: () async => stats.refresh(),
            color: theme.colorScheme.primary,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
              children: [
                // ── Başlık ──
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'İstatistikler',
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Odaklanma performansın',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant
                                  .withOpacity(0.7),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Bugünkü streak badge
                    if (stats.todayFocusCount > 0)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              const Color(0xFFFF9800),
                              const Color(0xFFFF9800).withOpacity(0.8),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFFFF9800).withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.local_fire_department_rounded,
                              size: 18,
                              color: Colors.white,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${stats.todayFocusCount}',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 28),

                // ═══ Bugün ═══
                _StatsSectionLabel(
                  title: 'Bugün',
                  icon: Icons.today_rounded,
                  theme: theme,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _EnhancedStatCard(
                        title: 'Oturumlar',
                        value: '${stats.todayFocusCount}',
                        subtitle: 'tamamlanan odak',
                        icon: Icons.local_fire_department_rounded,
                        color: AppConstants.focusColor,
                        theme: theme,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _EnhancedStatCard(
                        title: 'Dakika',
                        value: '${stats.todayFocusMinutes}',
                        subtitle: 'dakika odaklanma',
                        icon: Icons.schedule_rounded,
                        color: AppConstants.longBreakColor,
                        theme: theme,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // ═══ Bu Hafta ═══
                _StatsSectionLabel(
                  title: 'Bu Hafta',
                  icon: Icons.date_range_rounded,
                  theme: theme,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _EnhancedStatCard(
                        title: 'Oturumlar',
                        value: '${stats.weekFocusCount}',
                        subtitle: 'haftalık toplam',
                        icon: Icons.emoji_events_rounded,
                        color: AppConstants.shortBreakColor,
                        theme: theme,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _EnhancedStatCard(
                        title: 'Dakika',
                        value: '${stats.weekFocusMinutes}',
                        subtitle: 'haftalık toplam',
                        icon: Icons.timer_rounded,
                        color: Colors.deepPurple,
                        theme: theme,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 28),

                // ═══ Haftalık Grafik ═══
                _StatsSectionLabel(
                  title: 'Haftalık Dağılım',
                  icon: Icons.bar_chart_rounded,
                  theme: theme,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerLowest,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: theme.colorScheme.outlineVariant.withOpacity(0.2),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: theme.colorScheme.shadow.withOpacity(0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: WeeklyChart(weeklyData: stats.weeklyBreakdown),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// ── Bölüm Başlığı ──

class _StatsSectionLabel extends StatelessWidget {
  final String title;
  final IconData icon;
  final ThemeData theme;

  const _StatsSectionLabel({
    required this.title,
    required this.icon,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: theme.colorScheme.primary.withOpacity(0.7),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
            letterSpacing: -0.2,
          ),
        ),
      ],
    );
  }
}

// ── Geliştirilmiş İstatistik Kartı ──

class _EnhancedStatCard extends StatelessWidget {
  final String title;
  final String value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final ThemeData theme;

  const _EnhancedStatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withOpacity(0.15),
        ),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.shadow.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(icon, size: 20, color: color),
              ),
              const Spacer(),
              Text(
                title,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.onSurface,
              letterSpacing: -1,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
