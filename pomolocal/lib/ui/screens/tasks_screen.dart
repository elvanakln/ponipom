import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pomolocal/data/models/task_model.dart';
import 'package:pomolocal/logic/providers/task_provider.dart';
import 'package:pomolocal/logic/providers/timer_provider.dart';
import 'package:pomolocal/logic/providers/notes_provider.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, taskProv, _) {
        final tasks = taskProv.tasks;
        final theme = Theme.of(context);

        return SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 12),

              // ── Başlık ──
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Görevler',
                          style: theme.textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${taskProv.completedCount} tamamlandı, ${taskProv.totalCount - taskProv.completedCount} kaldı',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant
                                .withOpacity(0.7),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const Spacer(),
                    // İlerleme göstergesi
                    if (taskProv.totalCount > 0)
                      _ProgressRing(
                        progress: taskProv.totalCount > 0
                            ? taskProv.completedCount / taskProv.totalCount
                            : 0,
                        theme: theme,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // ── Kategori Filtreleri ──
              if (taskProv.categories.isNotEmpty)
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      _FilterChip(
                        label: 'Hepsi',
                        count: taskProv.totalCount,
                        isSelected: taskProv.filterCategory.isEmpty,
                        onTap: () => taskProv.setFilter(''),
                        theme: theme,
                      ),
                      ...taskProv.categories.map((cat) => _FilterChip(
                            label: cat,
                            isSelected: taskProv.filterCategory == cat,
                            onTap: () => taskProv.setFilter(cat),
                            theme: theme,
                          )),
                    ],
                  ),
                ),

              const SizedBox(height: 8),

              // ── Temizle Butonu ──
              if (taskProv.completedCount > 0)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () =>
                          _confirmClearCompleted(context, taskProv),
                      icon: Icon(Icons.delete_sweep_rounded,
                          size: 16,
                          color: theme.colorScheme.error.withOpacity(0.7)),
                      label: Text(
                        'Tamamlananları temizle',
                        style: TextStyle(
                          fontSize: 12,
                          color: theme.colorScheme.error.withOpacity(0.7),
                        ),
                      ),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                      ),
                    ),
                  ),
                ),

              // ── Liste ──
              Expanded(
                child: tasks.isEmpty
                    ? _EmptyState(theme: theme)
                    : ReorderableListView.builder(
                        padding: const EdgeInsets.fromLTRB(20, 4, 20, 80),
                        itemCount: tasks.length,
                        onReorder: taskProv.reorder,
                        proxyDecorator: (child, _, animation) =>
                            AnimatedBuilder(
                          animation: animation,
                          builder: (context, child) => Material(
                            elevation: 8,
                            shadowColor:
                                theme.colorScheme.shadow.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(16),
                            child: child,
                          ),
                          child: child,
                        ),
                        itemBuilder: (context, index) {
                          final task = tasks[index];
                          return _TaskCard(
                            key: ValueKey(task.id),
                            task: task,
                            isActive: taskProv.activeTask?.id == task.id,
                            onToggle: () => taskProv.toggleTask(task),
                            onTapActive: () {
                              final timer = context.read<TimerProvider>();
                              if (taskProv.activeTask?.id == task.id) {
                                taskProv.setActiveTask(null);
                                timer.setActiveTaskDurations(null);
                              } else {
                                taskProv.setActiveTask(task);
                                timer.setActiveTaskDurations(task);
                              }
                            },
                            onEdit: () =>
                                _showEditDialog(context, taskProv, task),
                            onDelete: () => taskProv.deleteTask(task.id),
                          );
                        },
                      ),
              ),

              // ── Ekleme Butonu ──
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton.icon(
                    onPressed: () => _showAddTaskDialog(context, taskProv),
                    icon: const Icon(Icons.add_rounded),
                    label: const Text(
                      'Yeni Görev',
                      style:
                          TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                    ),
                    style: FilledButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ── Görev Ekleme Dialog ──
  void _showAddTaskDialog(BuildContext context, TaskProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => _TaskFormDialog(
        title: 'Yeni Görev',
        onSave: (title, category, target, focus, shortBr, color) {
          provider.addTask(
            title,
            category: category,
            pomodorosTarget: target,
            focusDuration: focus,
            shortBreak: shortBr,
            colorValue: color,
          );
        },
      ),
    );
  }

  // ── Görev Düzenleme Dialog ──
  void _showEditDialog(BuildContext context, TaskProvider provider, Task task) {
    showDialog(
      context: context,
      builder: (ctx) => _TaskFormDialog(
        title: 'Görevi Düzenle',
        initialTitle: task.title,
        initialCategory: task.category,
        initialTarget: task.pomodorosTarget,
        initialFocus: task.focusDuration,
        initialShortBreak: task.shortBreak,
        initialColor: task.colorValue,
        initialNotes: task.notes,
        showNotes: true,
        onSave: (title, category, target, focus, shortBr, color) {
          provider.updateTask(task,
              title: title,
              category: category,
              pomodorosTarget: target,
              focusDuration: focus,
              shortBreak: shortBr,
              colorValue: color);
        },
        onSaveNotes: (notes) {
          provider.updateTask(task, notes: notes);
        },
      ),
    );
  }

  void _confirmClearCompleted(BuildContext context, TaskProvider provider) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Tamamlananları Sil'),
        content: Text(
          '${provider.completedCount} tamamlanmış görev silinecek. Emin misin?',
          style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('İptal'),
          ),
          FilledButton(
            onPressed: () {
              provider.clearCompleted();
              Navigator.pop(ctx);
            },
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }
}

// ── İlerleme Halkası ──

class _ProgressRing extends StatelessWidget {
  final double progress;
  final ThemeData theme;

  const _ProgressRing({required this.progress, required this.theme});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 44,
      child: Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: progress,
            strokeWidth: 3.5,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation(theme.colorScheme.primary),
            strokeCap: StrokeCap.round,
          ),
          Text(
            '${(progress * 100).round()}%',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Filtre Chip ──

class _FilterChip extends StatelessWidget {
  final String label;
  final int? count;
  final bool isSelected;
  final VoidCallback onTap;
  final ThemeData theme;

  const _FilterChip({
    required this.label,
    this.count,
    required this.isSelected,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.colorScheme.surfaceContainerHighest.withOpacity(0.5),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outlineVariant.withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? theme.colorScheme.onPrimary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                if (count != null) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.colorScheme.onPrimary.withOpacity(0.2)
                          : theme.colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$count',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: isSelected
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Boş Durum ──

class _EmptyState extends StatelessWidget {
  final ThemeData theme;
  const _EmptyState({required this.theme});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.4),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.checklist_rounded,
              size: 32,
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Henüz görev yok',
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.6),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Aşağıdaki butonla ekleyin',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════
// Görev Formu Dialog
// ══════════════════════════════════════

class _TaskFormDialog extends StatefulWidget {
  final String title;
  final String initialTitle;
  final String initialCategory;
  final int initialTarget;
  final int initialFocus;
  final int initialShortBreak;
  final int initialColor;
  final String initialNotes;
  final bool showNotes;
  final void Function(String title, String category, int target, int focus,
      int shortBreak, int color) onSave;
  final void Function(String notes)? onSaveNotes;

  const _TaskFormDialog({
    required this.title,
    this.initialTitle = '',
    this.initialCategory = '',
    this.initialTarget = 4,
    this.initialFocus = 0,
    this.initialShortBreak = 0,
    this.initialColor = 0,
    this.initialNotes = '',
    this.showNotes = false,
    required this.onSave,
    this.onSaveNotes,
  });

  @override
  State<_TaskFormDialog> createState() => _TaskFormDialogState();
}

class _TaskFormDialogState extends State<_TaskFormDialog> {
  late final TextEditingController _titleC;
  late final TextEditingController _catC;
  late final TextEditingController _notesC;
  late int _target;
  late int _focus;
  late int _shortBreak;
  late int _color;

  @override
  void initState() {
    super.initState();
    _titleC = TextEditingController(text: widget.initialTitle);
    _catC = TextEditingController(text: widget.initialCategory);
    _notesC = TextEditingController(text: widget.initialNotes);
    _target = widget.initialTarget;
    _focus = widget.initialFocus;
    _shortBreak = widget.initialShortBreak;
    _color = widget.initialColor;
  }

  @override
  void dispose() {
    _titleC.dispose();
    _catC.dispose();
    _notesC.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Başlık
            Text(
              widget.title,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 20),

            // Görev adı
            _StyledTextField(
              controller: _titleC,
              label: 'Görev adı',
              autofocus: true,
              theme: theme,
            ),
            const SizedBox(height: 14),

            // Kategori
            _StyledTextField(
              controller: _catC,
              label: 'Kategori',
              hint: 'örn. Mat, Fizik',
              theme: theme,
            ),
            const SizedBox(height: 20),

            // Renk seçimi
            _SectionLabel('Renk', theme: theme),
            const SizedBox(height: 10),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: List.generate(TaskColors.presets.length, (i) {
                final cv = TaskColors.presets[i];
                final isSelected = _color == cv;
                final displayColor =
                    cv == 0 ? theme.colorScheme.primary : Color(cv);
                return GestureDetector(
                  onTap: () => setState(() => _color = cv),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: displayColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? theme.colorScheme.onSurface
                            : Colors.transparent,
                        width: 2.5,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: displayColor.withOpacity(0.4),
                                blurRadius: 8,
                              ),
                            ]
                          : null,
                    ),
                    child: isSelected
                        ? Icon(Icons.check_rounded,
                            size: 16,
                            color: cv == 0
                                ? theme.colorScheme.onPrimary
                                : Colors.white)
                        : null,
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),

            // Hedef pomodoro
            _SectionLabel('Hedef Pomodoro', theme: theme),
            const SizedBox(height: 8),
            _StepperRow(
              value: _target,
              min: 1,
              max: 20,
              onChanged: (v) => setState(() => _target = v),
              theme: theme,
            ),
            const SizedBox(height: 16),

            // Odak süresi
            _SectionLabel('Odak Süresi (dk)', theme: theme),
            const SizedBox(height: 4),
            Text(
              '0 = genel ayarı kullan',
              style: TextStyle(
                fontSize: 11,
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
              ),
            ),
            const SizedBox(height: 8),
            _StepperRow(
              value: _focus,
              min: 0,
              max: 90,
              displayText: _focus == 0 ? 'Genel' : '$_focus dk',
              onChanged: (v) => setState(() => _focus = v),
              theme: theme,
            ),
            const SizedBox(height: 16),

            // Kısa mola
            _SectionLabel('Kısa Mola (dk)', theme: theme),
            const SizedBox(height: 8),
            _StepperRow(
              value: _shortBreak,
              min: 0,
              max: 30,
              displayText: _shortBreak == 0 ? 'Genel' : '$_shortBreak dk',
              onChanged: (v) => setState(() => _shortBreak = v),
              theme: theme,
            ),

            // Notlar
            if (widget.showNotes) ...[
              const SizedBox(height: 20),
              _SectionLabel('Notlar', theme: theme),
              const SizedBox(height: 8),
              _StyledTextField(
                controller: _notesC,
                hint: 'Mat 3. bölüm bitti, 4. bölüme geçtim...',
                maxLines: 4,
                theme: theme,
              ),
            ],

            const SizedBox(height: 24),

            // Butonlar
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      side: BorderSide(color: theme.colorScheme.outlineVariant),
                    ),
                    child: Text(
                      'İptal',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: FilledButton(
                    onPressed: () {
                      final title = _titleC.text.trim();
                      if (title.isEmpty) return;
                      widget.onSave(title, _catC.text.trim(), _target, _focus,
                          _shortBreak, _color);
                      if (widget.showNotes && widget.onSaveNotes != null) {
                        widget.onSaveNotes!(_notesC.text);
                      }
                      Navigator.pop(context);
                    },
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: const Text(
                      'Kaydet',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Dialog Yardımcı Widget'lar ──

class _SectionLabel extends StatelessWidget {
  final String text;
  final ThemeData theme;
  const _SectionLabel(this.text, {required this.theme});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: theme.colorScheme.primary,
        letterSpacing: 0.3,
      ),
    );
  }
}

class _StyledTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? label;
  final String? hint;
  final bool autofocus;
  final int maxLines;
  final ThemeData theme;

  const _StyledTextField({
    required this.controller,
    this.label,
    this.hint,
    this.autofocus = false,
    this.maxLines = 1,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      autofocus: autofocus,
      maxLines: maxLines,
      style: const TextStyle(fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        hintStyle: TextStyle(
          color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
        ),
        filled: true,
        fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: theme.colorScheme.outlineVariant.withOpacity(0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: theme.colorScheme.primary,
            width: 1.5,
          ),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }
}

class _StepperRow extends StatelessWidget {
  final int value;
  final int min;
  final int max;
  final String? displayText;
  final ValueChanged<int> onChanged;
  final ThemeData theme;

  const _StepperRow({
    required this.value,
    required this.min,
    required this.max,
    this.displayText,
    required this.onChanged,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.3),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _StepperButton(
            icon: Icons.remove_rounded,
            enabled: value > min,
            onTap: () => onChanged(value - 1),
            theme: theme,
          ),
          SizedBox(
            width: 56,
            child: Text(
              displayText ?? '$value',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurface,
              ),
            ),
          ),
          _StepperButton(
            icon: Icons.add_rounded,
            enabled: value < max,
            onTap: () => onChanged(value + 1),
            theme: theme,
          ),
        ],
      ),
    );
  }
}

class _StepperButton extends StatelessWidget {
  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;
  final ThemeData theme;

  const _StepperButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: enabled
                ? theme.colorScheme.primary.withOpacity(0.1)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 20,
            color: enabled
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant.withOpacity(0.3),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════
// Görev Kartı
// ══════════════════════════════════════

class _TaskCard extends StatelessWidget {
  final Task task;
  final bool isActive;
  final VoidCallback onToggle;
  final VoidCallback onTapActive;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _TaskCard({
    super.key,
    required this.task,
    required this.isActive,
    required this.onToggle,
    required this.onTapActive,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = task.taskColor != null
        ? Color(task.taskColor!)
        : theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTapActive,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerLowest,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isActive
                    ? color
                    : theme.colorScheme.outlineVariant.withOpacity(0.15),
                width: isActive ? 2 : 1,
              ),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: color.withOpacity(0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: theme.colorScheme.shadow.withOpacity(0.03),
                        blurRadius: 8,
                        offset: const Offset(0, 1),
                      ),
                    ],
            ),
            child: Row(
              children: [
                // Renk şeridi
                Container(
                  width: 4,
                  height: 48,
                  margin: const EdgeInsets.only(left: 4, right: 6),
                  decoration: BoxDecoration(
                    color: task.completed ? color.withOpacity(0.3) : color,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Checkbox
                Transform.scale(
                  scale: 1.1,
                  child: Checkbox(
                    value: task.completed,
                    onChanged: (_) => onToggle(),
                    activeColor: color,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),

                const SizedBox(width: 4),

                // İçerik
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        task.title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          decoration: task.completed
                              ? TextDecoration.lineThrough
                              : null,
                          color: task.completed
                              ? theme.colorScheme.onSurfaceVariant
                                  .withOpacity(0.5)
                              : theme.colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          if (task.category.isNotEmpty)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                task.category,
                                style: TextStyle(
                                  fontSize: 11,
                                  color: color,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          Icon(Icons.timer_outlined,
                              size: 13,
                              color: theme.colorScheme.onSurfaceVariant
                                  .withOpacity(0.5)),
                          const SizedBox(width: 3),
                          Text(
                            '${task.pomodorosSpent}/${task.pomodorosTarget}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: theme.colorScheme.onSurfaceVariant
                                  .withOpacity(0.6),
                            ),
                          ),
                          if (task.focusDuration > 0) ...[
                            const SizedBox(width: 8),
                            Text(
                              '${task.focusDuration}dk',
                              style: TextStyle(
                                fontSize: 11,
                                color: theme.colorScheme.onSurfaceVariant
                                    .withOpacity(0.5),
                              ),
                            ),
                          ],
                          if (task.notes.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Icon(Icons.note_outlined,
                                size: 14,
                                color: theme.colorScheme.onSurfaceVariant
                                    .withOpacity(0.5)),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Aktif badge
                if (isActive)
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color, color.withOpacity(0.8)],
                      ),
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.3),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: const Text(
                      'AKTİF',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),

                // Menü
                PopupMenuButton<String>(
                  itemBuilder: (_) => [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit_rounded,
                              size: 16,
                              color: theme.colorScheme.onSurfaceVariant),
                          const SizedBox(width: 8),
                          const Text('Düzenle'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'notes',
                      child: Row(
                        children: [
                          Icon(Icons.note_alt_outlined,
                              size: 16,
                              color: theme.colorScheme.onSurfaceVariant),
                          const SizedBox(width: 8),
                          const Text('Notlar'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete_outline_rounded,
                              size: 16, color: theme.colorScheme.error),
                          const SizedBox(width: 8),
                          Text('Sil',
                              style: TextStyle(color: theme.colorScheme.error)),
                        ],
                      ),
                    ),
                  ],
                  onSelected: (v) {
                    if (v == 'edit') onEdit();
                    if (v == 'notes') _showNotesSheet(context);
                    if (v == 'delete') onDelete();
                  },
                  icon: Icon(
                    Icons.more_horiz_rounded,
                    size: 18,
                    color: theme.colorScheme.onSurfaceVariant.withOpacity(0.5),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showNotesSheet(BuildContext context) {
    final controller = TextEditingController(text: task.notes);
    final taskProv = context.read<TaskProvider>();
    final notesProv = context.read<NotesProvider>();
    final theme = Theme.of(context);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final bottomInset = MediaQuery.of(ctx).viewInsets.bottom;
        return Container(
          margin: EdgeInsets.only(bottom: bottomInset),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, -4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.outlineVariant.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  task.title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: controller,
                  maxLines: 6,
                  style: const TextStyle(fontSize: 15, height: 1.5),
                  decoration: InputDecoration(
                    hintText:
                        'Notlarını buraya yaz...\nörn. Mat 3. bölüm bitti',
                    hintStyle: TextStyle(
                      color:
                          theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
                    ),
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest
                        .withOpacity(0.3),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                        color: theme.colorScheme.primary,
                        width: 1.5,
                      ),
                    ),
                    contentPadding: const EdgeInsets.all(16),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          final text = controller.text.trim();
                          if (text.isNotEmpty) {
                            notesProv.addNote('${task.title}: $text');
                          }
                          Navigator.pop(ctx);
                        },
                        icon: const Icon(Icons.calendar_month, size: 18),
                        label: const Text('Takvime Kaydet'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: () {
                          taskProv.updateTask(task, notes: controller.text);
                          Navigator.pop(ctx);
                        },
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                        child: const Text(
                          'Kaydet',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// AnimatedBuilder yardımcı (proxyDecorator için)
class AnimatedBuilder extends StatelessWidget {
  final Animation<double> animation;
  final Widget Function(BuildContext, Widget?) builder;
  final Widget? child;

  const AnimatedBuilder({
    super.key,
    required this.animation,
    required this.builder,
    this.child,
  });

  @override
  Widget build(BuildContext context) => builder(context, child);
}
