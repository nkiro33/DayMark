import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../data/mock_daymark_data.dart';
import '../../../models/models.dart';
import '../daily_formatters.dart';
import '../daily_log_request.dart';

class DailyLogDetailsSheet extends StatefulWidget {
  const DailyLogDetailsSheet({
    super.key,
    required this.entry,
    required this.category,
    required this.options,
    required this.expectedDurationMinutes,
    required this.isFutureDate,
    required this.previewCredits,
    required this.onSaveLog,
    required this.onClearLog,
    required this.onPlanActivity,
  });

  final DailyActivityEntry entry;
  final ActivityCategory category;
  final List<ActivityOption> options;
  final int? expectedDurationMinutes;
  final bool isFutureDate;
  final double Function(DailyLogRequest request) previewCredits;
  final DailyActivityLog Function(DailyLogRequest request) onSaveLog;
  final VoidCallback onClearLog;
  final VoidCallback onPlanActivity;

  @override
  State<DailyLogDetailsSheet> createState() => _DailyLogDetailsSheetState();
}

class _DailyLogDetailsSheetState extends State<DailyLogDetailsSheet> {
  late final TextEditingController _noteController;
  late final TextEditingController _durationHoursController;
  late final TextEditingController _durationMinutesController;
  late final TextEditingController _quantityController;
  late DailyActivityLog? _log;
  late DailyLogStatus _draftStatus;
  double? _draftValue;
  int? _draftDurationMinutes;

  @override
  void initState() {
    super.initState();
    _log = widget.entry.log;
    _draftStatus = _log?.status ?? DailyLogStatus.planned;
    _draftValue = _log?.value;
    _draftDurationMinutes = _log?.durationMinutes;
    _noteController = TextEditingController(text: _log?.notes);
    _durationHoursController = TextEditingController(
      text: _draftDurationMinutes == null
          ? ''
          : '${_draftDurationMinutes! ~/ 60}',
    );
    _durationMinutesController = TextEditingController(
      text: _draftDurationMinutes == null
          ? ''
          : '${_draftDurationMinutes! % 60}',
    );
    _quantityController = TextEditingController(
      text: _draftValue == null ? '' : formatCredit(_draftValue!),
    );
    _durationHoursController.addListener(_refreshDraftFromText);
    _durationMinutesController.addListener(_refreshDraftFromText);
    _quantityController.addListener(_refreshDraftFromText);
  }

  @override
  void dispose() {
    _durationHoursController.removeListener(_refreshDraftFromText);
    _durationMinutesController.removeListener(_refreshDraftFromText);
    _quantityController.removeListener(_refreshDraftFromText);
    _noteController.dispose();
    _durationHoursController.dispose();
    _durationMinutesController.dispose();
    _quantityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final activity = widget.entry.activity;
    final status = widget.isFutureDate
        ? DailyLogStatus.planned
        : _statusForDisplay;
    final draftCredits = _draftCredits;

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 8,
          bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
        ),
        child: ListView(
          shrinkWrap: true,
          children: [
            Text(activity.title, style: theme.textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              '${widget.category.name} · ${statusLabel(status)} · '
              '${formatCredit(draftCredits)} credits',
              style: theme.textTheme.bodyMedium,
            ),
            if (activity.description != null) ...[
              const SizedBox(height: 8),
              Text(activity.description!, style: theme.textTheme.bodyMedium),
            ],
            const SizedBox(height: 16),
            _trackingDetails(activity),
            const SizedBox(height: 16),
            TextField(
              key: const ValueKey('daily-log-note-field'),
              controller: _noteController,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Note',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            if (!widget.isFutureDate)
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      key: const ValueKey('cancel-daily-log'),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      key: const ValueKey('save-daily-log'),
                      onPressed: _saveDraft,
                      child: const Text('Save Log'),
                    ),
                  ),
                ],
              ),
            if (_log != null) ...[
              const SizedBox(height: 8),
              OutlinedButton.icon(
                key: const ValueKey('clear-daily-log'),
                onPressed: _clearLog,
                icon: const Icon(Icons.undo_outlined),
                label: const Text('Clear Log'),
              ),
            ] else if (widget.isFutureDate) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: widget.onPlanActivity,
                      icon: const Icon(Icons.add_task),
                      label: const Text('Plan Activity'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _trackingDetails(ActivityTemplate activity) {
    if (widget.isFutureDate) {
      return const Text(
        'Future activities can be planned, but not logged yet.',
      );
    }

    return switch (activity.trackingType) {
      TrackingType.boolean => _BooleanChoices(
        isBadHabit: activity.activityType == ActivityType.negative,
        status: _draftStatus,
        onChanged: _setBooleanStatus,
      ),
      TrackingType.milestone => _BooleanChoices(
        isBadHabit: false,
        status: _draftStatus,
        onChanged: _setBooleanStatus,
      ),
      TrackingType.duration => _DurationFields(
        hoursController: _durationHoursController,
        minutesController: _durationMinutesController,
      ),
      TrackingType.quantity => _QuantityField(controller: _quantityController),
      TrackingType.level => _LevelChoices(
        selectedValue: _draftValue,
        onChanged: (status, value) {
          setState(() {
            _draftStatus = status;
            _draftValue = value;
          });
        },
      ),
      TrackingType.categorical => _CategoricalChoices(
        options: widget.options,
        selectedValue: _draftValue,
        onChanged: (option) {
          setState(() {
            _draftStatus = option.creditValue < 0
                ? DailyLogStatus.missed
                : DailyLogStatus.completed;
            _draftValue = option.value;
          });
        },
      ),
    };
  }

  double get _draftCredits {
    if (widget.isFutureDate) {
      return 0;
    }
    final request = _previewRequest();
    return request == null ? 0 : widget.previewCredits(request);
  }

  DailyLogStatus get _statusForDisplay {
    final request = _previewRequest();
    return request?.status ?? _draftStatus;
  }

  DailyLogRequest? _previewRequest() {
    final activity = widget.entry.activity;
    return switch (activity.trackingType) {
      TrackingType.duration => _durationPreviewRequest(),
      TrackingType.quantity => _quantityPreviewRequest(),
      _ => DailyLogRequest(
        status: _draftStatus,
        value: _draftValue,
        notes: _cleanNote,
      ),
    };
  }

  DailyLogRequest? _durationPreviewRequest() {
    final hours = int.tryParse(_durationHoursController.text.trim()) ?? 0;
    final minutes = int.tryParse(_durationMinutesController.text.trim()) ?? 0;
    final totalMinutes = hours * 60 + minutes;
    if (minutes < 0 || minutes > 59 || totalMinutes <= 0) {
      return const DailyLogRequest(status: DailyLogStatus.planned);
    }
    return DailyLogRequest(
      status: _statusForDuration(totalMinutes),
      durationMinutes: totalMinutes,
      notes: _cleanNote,
    );
  }

  DailyLogRequest? _quantityPreviewRequest() {
    final value = double.tryParse(_quantityController.text.trim());
    if (value == null || value <= 0) {
      return const DailyLogRequest(status: DailyLogStatus.planned);
    }
    return DailyLogRequest(
      status: DailyLogStatus.completed,
      value: value,
      notes: _cleanNote,
    );
  }

  void _refreshDraftFromText() {
    if (!mounted) {
      return;
    }
    setState(() {});
  }

  void _setBooleanStatus(DailyLogStatus status, double? value) {
    setState(() {
      _draftStatus = status;
      _draftValue = value;
    });
  }

  void _saveDraft() {
    final activity = widget.entry.activity;
    final request = switch (activity.trackingType) {
      TrackingType.duration => _durationRequest(),
      TrackingType.quantity => _quantityRequest(),
      _ => DailyLogRequest(
        status: _draftStatus,
        value: _draftValue,
        notes: _cleanNote,
      ),
    };
    if (request == null) {
      return;
    }

    final savedLog = widget.onSaveLog(request);
    setState(() {
      _log = savedLog;
      _draftStatus = savedLog.status;
      _draftValue = savedLog.value;
      _draftDurationMinutes = savedLog.durationMinutes;
    });
  }

  DailyLogRequest? _durationRequest() {
    final hours = int.tryParse(_durationHoursController.text.trim()) ?? 0;
    final minutes = int.tryParse(_durationMinutesController.text.trim()) ?? 0;
    if (minutes < 0 || minutes > 59) {
      _showMessage('Use 0-59 minutes.');
      return null;
    }
    final totalMinutes = hours * 60 + minutes;
    if (totalMinutes <= 0) {
      _showMessage('Enter a duration above 0 minutes.');
      return null;
    }
    return DailyLogRequest(
      status: _statusForDuration(totalMinutes),
      durationMinutes: totalMinutes,
      notes: _cleanNote,
    );
  }

  DailyLogRequest? _quantityRequest() {
    final value = double.tryParse(_quantityController.text.trim());
    if (value == null || value <= 0) {
      _showMessage('Enter a number above 0.');
      return null;
    }
    return DailyLogRequest(
      status: DailyLogStatus.completed,
      value: value,
      notes: _cleanNote,
    );
  }

  DailyLogStatus _statusForDuration(int minutes) {
    final expectedMinutes = widget.expectedDurationMinutes;
    if (expectedMinutes == null || expectedMinutes <= 0) {
      return DailyLogStatus.completed;
    }
    return minutes >= expectedMinutes
        ? DailyLogStatus.completed
        : DailyLogStatus.partiallyCompleted;
  }

  void _clearLog() {
    widget.onClearLog();
    setState(() {
      _log = null;
      _draftStatus = DailyLogStatus.planned;
      _draftValue = null;
      _draftDurationMinutes = null;
      _noteController.clear();
      _durationHoursController.clear();
      _durationMinutesController.clear();
      _quantityController.clear();
    });
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String? get _cleanNote {
    final note = _noteController.text.trim();
    return note.isEmpty ? null : note;
  }
}

class _BooleanChoices extends StatelessWidget {
  const _BooleanChoices({
    required this.isBadHabit,
    required this.status,
    required this.onChanged,
  });

  final bool isBadHabit;
  final DailyLogStatus status;
  final void Function(DailyLogStatus status, double? value) onChanged;

  @override
  Widget build(BuildContext context) {
    final didHappen = isBadHabit
        ? status == DailyLogStatus.missed
        : status == DailyLogStatus.completed;
    final didNotHappen = isBadHabit
        ? status == DailyLogStatus.completed
        : status == DailyLogStatus.missed;

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        ChoiceChip(
          label: Text(isBadHabit ? 'Did not happen' : 'Done'),
          avatar: const Icon(Icons.check, size: 18),
          selected: isBadHabit ? didNotHappen : didHappen,
          onSelected: (_) {
            onChanged(DailyLogStatus.completed, isBadHabit ? 0 : null);
          },
        ),
        ChoiceChip(
          label: Text(isBadHabit ? 'Happened' : 'Not done'),
          avatar: const Icon(Icons.close, size: 18),
          selected: isBadHabit ? didHappen : didNotHappen,
          onSelected: (_) {
            onChanged(DailyLogStatus.missed, isBadHabit ? 1 : null);
          },
        ),
      ],
    );
  }
}

class _DurationFields extends StatelessWidget {
  const _DurationFields({
    required this.hoursController,
    required this.minutesController,
  });

  final TextEditingController hoursController;
  final TextEditingController minutesController;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            key: const ValueKey('daily-log-duration-hours-field'),
            controller: hoursController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'Hours',
              border: OutlineInputBorder(),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            key: const ValueKey('daily-log-duration-minutes-field'),
            controller: minutesController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'Minutes',
              border: OutlineInputBorder(),
            ),
          ),
        ),
      ],
    );
  }
}

class _QuantityField extends StatelessWidget {
  const _QuantityField({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      key: const ValueKey('daily-log-amount-field'),
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
      decoration: const InputDecoration(
        labelText: 'Amount',
        border: OutlineInputBorder(),
      ),
    );
  }
}

class _LevelChoices extends StatelessWidget {
  const _LevelChoices({required this.selectedValue, required this.onChanged});

  final double? selectedValue;
  final void Function(DailyLogStatus status, double value) onChanged;

  @override
  Widget build(BuildContext context) {
    final selected = selectedValue?.round();

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _LogChoiceChip(
          label: 'Good control',
          selected: selected == 1,
          onSelected: () => onChanged(DailyLogStatus.completed, 1),
        ),
        _LogChoiceChip(
          label: 'Some scrolling',
          selected: selected == 2,
          onSelected: () => onChanged(DailyLogStatus.partiallyCompleted, 2),
        ),
        _LogChoiceChip(
          label: 'Bad day',
          selected: selected == 3,
          onSelected: () => onChanged(DailyLogStatus.missed, 3),
        ),
      ],
    );
  }
}

class _CategoricalChoices extends StatelessWidget {
  const _CategoricalChoices({
    required this.options,
    required this.selectedValue,
    required this.onChanged,
  });

  final List<ActivityOption> options;
  final double? selectedValue;
  final ValueChanged<ActivityOption> onChanged;

  @override
  Widget build(BuildContext context) {
    if (options.isEmpty) {
      return const Text('No options added yet.');
    }

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final option in options)
          _LogChoiceChip(
            label: option.label,
            selected: selectedValue == option.value,
            onSelected: () => onChanged(option),
          ),
      ],
    );
  }
}

class _LogChoiceChip extends StatelessWidget {
  const _LogChoiceChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => onSelected(),
    );
  }
}
