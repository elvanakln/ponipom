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

        return SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    Text(
                      'Görevler',
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color:
                            Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${taskProv.completedCount}/${taskProv.totalCount}',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context)
                              .colorScheme
                              .onPrimaryContainer,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (taskProv.completedCount > 0)
                      TextButton.icon(
                        onPressed: () =>
                            _confirmClearCompleted(context, taskProv),
                        icon: const Icon(Icons.delete_sweep_rounded,
                            size: 18),
                        label: const Text('Temizle'),
                        style: TextButton.styleFrom(
                          foregroundColor:
                              Theme.of(context).colorScheme.error,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),

              // Kategori filtreleri
              if (taskProv.categories.isNotEmpty)
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    children: [
                      _chip(context, 'Hepsi',
                          taskProv.filterCategory.isEmpty,
                          () => taskProv.setFilter('')),
                      ...taskProv.categories.map((cat) => _chip(
                          context,
                          cat,
                          taskProv.filterCategory == cat,
                          () => taskProv.setFilter(cat))),
                    ],
                  ),
                ),

              const SizedBox(height: 8),

              // Liste
              Expanded(
                child: tasks.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.checklist_rounded,
                                size: 48,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant
                                    .withOpacity(0.3)),
                            const SizedBox(height: 12),
                            Text('Henüz görev yok',
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurfaceVariant)),
                          ],
                        ),
                      )
                    : ReorderableListView.builder(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: tasks.length,
                        onReorder: taskProv.reorder,
                        proxyDecorator: (child, _, __) => Material(
                          elevation: 4,
                          borderRadius: BorderRadius.circular(12),
                          child: child,
                        ),
                        itemBuilder: (context, index) {
                          final task = tasks[index];
                          return _TaskCard(
                            key: ValueKey(task.id),
                            task: task,
                            isActive:
                                taskProv.activeTask?.id == task.id,
                            onToggle: () =>
                                taskProv.toggleTask(task),
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
                            onEdit: () => _showEditDialog(
                                context, taskProv, task),
                            onDelete: () =>
                                taskProv.deleteTask(task.id),
                          );
                        },
                      ),
              ),

              // Ekleme butonu
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
                child: SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () =>
                        _showAddTaskDialog(context, taskProv),
                    icon: const Icon(Icons.add),
                    label: const Text('Yeni Görev'),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _chip(BuildContext ctx, String label, bool selected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
        showCheckmark: false,
      ),
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
  void _showEditDialog(
      BuildContext context, TaskProvider provider, Task task) {
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
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Tamamlananları Sil'),
        content: Text(
            '${provider.completedCount} tamamlanmış görev silinecek. Emin misin?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('İptal')),
          FilledButton(
            onPressed: () {
              provider.clearCompleted();
              Navigator.pop(ctx);
            },
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Sil'),
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

    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Görev adı
            TextField(
              controller: _titleC,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Görev adı',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),

            // Kategori
            TextField(
              controller: _catC,
              decoration: const InputDecoration(
                labelText: 'Kategori',
                hintText: 'örn. Mat, Fizik',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Renk seçimi
            Text('Renk', style: TextStyle(
              fontSize: 13, fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            )),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: List.generate(TaskColors.presets.length, (i) {
                final cv = TaskColors.presets[i];
                final isSelected = _color == cv;
                final displayColor = cv == 0
                    ? theme.colorScheme.primary
                    : Color(cv);
                return GestureDetector(
                  onTap: () => setState(() => _color = cv),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: displayColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? theme.colorScheme.onSurface
                            : Colors.transparent,
                        width: 2.5,
                      ),
                    ),
                    child: isSelected
                        ? Icon(Icons.check,
                            size: 16,
                            color: cv == 0
                                ? theme.colorScheme.onPrimary
                                : Colors.white)
                        : null,
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),

            // Hedef pomodoro
            Text('Hedef Pomodoro', style: TextStyle(
              fontSize: 13, fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            )),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed:
                      _target > 1 ? () => setState(() => _target--) : null,
                ),
                SizedBox(
                  width: 40,
                  child: Text('$_target',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed:
                      _target < 20 ? () => setState(() => _target++) : null,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Odak süresi
            Text('Odak Süresi (dk)', style: TextStyle(
              fontSize: 13, fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            )),
            const SizedBox(height: 4),
            Text('0 = genel ayarı kullan',
                style: TextStyle(
                    fontSize: 11,
                    color: theme.colorScheme.onSurfaceVariant)),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed:
                      _focus > 0 ? () => setState(() => _focus--) : null,
                ),
                SizedBox(
                  width: 50,
                  child: Text(
                      _focus == 0 ? 'Genel' : '$_focus dk',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed:
                      _focus < 90 ? () => setState(() => _focus++) : null,
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Kısa mola
            Text('Kısa Mola (dk)', style: TextStyle(
              fontSize: 13, fontWeight: FontWeight.w600,
              color: theme.colorScheme.primary,
            )),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline),
                  onPressed: _shortBreak > 0
                      ? () => setState(() => _shortBreak--)
                      : null,
                ),
                SizedBox(
                  width: 50,
                  child: Text(
                      _shortBreak == 0 ? 'Genel' : '$_shortBreak dk',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                ),
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: _shortBreak < 30
                      ? () => setState(() => _shortBreak++)
                      : null,
                ),
              ],
            ),

            // Notlar (sadece düzenlemede)
            if (widget.showNotes) ...[
              const SizedBox(height: 16),
              Text('Notlar', style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              )),
              const SizedBox(height: 8),
              TextField(
                controller: _notesC,
                maxLines: 4,
                decoration: const InputDecoration(
                  hintText: 'Mat 3. bölüm bitti, 4. bölüme geçtim...',
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('İptal'),
        ),
        FilledButton(
          onPressed: () {
            final title = _titleC.text.trim();
            if (title.isEmpty) return;
            widget.onSave(
                title, _catC.text.trim(), _target, _focus, _shortBreak, _color);
            if (widget.showNotes && widget.onSaveNotes != null) {
              widget.onSaveNotes!(_notesC.text);
            }
            Navigator.pop(context);
          },
          child: const Text('Kaydet'),
        ),
      ],
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

    return Card(
      margin: const EdgeInsets.only(bottom: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isActive
            ? BorderSide(color: color, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTapActive,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 10),
          child: Row(
            children: [
              // Renk şeridi
              Container(
                width: 4,
                height: 48,
                margin: const EdgeInsets.only(left: 4, right: 4),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),

              // Checkbox
              Checkbox(
                value: task.completed,
                onChanged: (_) => onToggle(),
                activeColor: color,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),

              // İçerik
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      task.title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        decoration: task.completed
                            ? TextDecoration.lineThrough
                            : null,
                        color: task.completed
                            ? theme.colorScheme.onSurfaceVariant
                            : theme.colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        // Kategori
                        if (task.category.isNotEmpty)
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: color.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(task.category,
                                style: TextStyle(
                                    fontSize: 11,
                                    color: color,
                                    fontWeight: FontWeight.w600)),
                          ),
                        // Pomodoro ilerleme
                        Icon(Icons.timer_outlined,
                            size: 13,
                            color: theme.colorScheme.onSurfaceVariant),
                        const SizedBox(width: 3),
                        Text(
                          '${task.pomodorosSpent}/${task.pomodorosTarget}',
                          style: TextStyle(
                            fontSize: 12,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        // Özel süre varsa göster
                        if (task.focusDuration > 0) ...[
                          const SizedBox(width: 8),
                          Text(
                            '${task.focusDuration}dk',
                            style: TextStyle(
                              fontSize: 11,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                        // Not varsa ikon
                        if (task.notes.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Icon(Icons.note_outlined,
                              size: 14,
                              color: theme.colorScheme.onSurfaceVariant),
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
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text('AKTİF',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                ),

              // Menü
              PopupMenuButton<String>(
                itemBuilder: (_) => const [
                  PopupMenuItem(value: 'edit', child: Text('Düzenle')),
                  PopupMenuItem(value: 'notes', child: Text('Notlar')),
                  PopupMenuItem(value: 'delete', child: Text('Sil')),
                ],
                onSelected: (v) {
                  if (v == 'edit') onEdit();
                  if (v == 'notes') _showNotesSheet(context);
                  if (v == 'delete') onDelete();
                },
                icon: Icon(Icons.more_vert,
                    size: 18,
                    color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNotesSheet(BuildContext context) {
    final controller = TextEditingController(text: task.notes);
    final taskProv = context.read<TaskProvider>();
    final notesProv = context.read<NotesProvider>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
              20, 20, 20, MediaQuery.of(ctx).viewInsets.bottom + 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(task.title,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                maxLines: 6,
                decoration: const InputDecoration(
                  hintText: 'Notlarını buraya yaz...\nörn. Mat 3. bölüm bitti',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Takvime de kaydet
                        final text = controller.text.trim();
                        if (text.isNotEmpty) {
                          notesProv.addNote('${task.title}: $text');
                        }
                        Navigator.pop(ctx);
                      },
                      icon: const Icon(Icons.calendar_month, size: 18),
                      label: const Text('Takvime Kaydet'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        taskProv.updateTask(task, notes: controller.text);
                        Navigator.pop(ctx);
                      },
                      child: const Text('Kaydet'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
