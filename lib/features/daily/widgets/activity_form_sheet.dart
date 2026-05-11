import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../models/models.dart';
import '../activity_form_result.dart';

class ActivityFormSheet extends StatefulWidget {
  const ActivityFormSheet({
    super.key,
    required this.title,
    required this.submitLabel,
    required this.categories,
    required this.isRecurring,
    required this.onSave,
    this.initialTitle,
    this.initialDescription,
    this.initialCategoryId,
    this.initialActivityType,
    this.initialTrackingType,
    this.initialFrequency,
    this.initialDaysOfWeek,
    this.initialExpectedDurationMinutes,
    this.initialBaseCredit,
    this.initialCreditPerMinute,
    this.initialCreditPerUnit,
    this.initialMaxDailyCredit,
    this.initialPenaltyCredit,
    this.initialCategoricalOptions,
  });

  final String title;
  final String submitLabel;
  final List<ActivityCategory> categories;
  final bool isRecurring;
  final ValueChanged<ActivityFormResult> onSave;
  final String? initialTitle;
  final String? initialDescription;
  final String? initialCategoryId;
  final ActivityType? initialActivityType;
  final TrackingType? initialTrackingType;
  final ScheduleFrequency? initialFrequency;
  final List<int>? initialDaysOfWeek;
  final int? initialExpectedDurationMinutes;
  final double? initialBaseCredit;
  final double? initialCreditPerMinute;
  final double? initialCreditPerUnit;
  final double? initialMaxDailyCredit;
  final double? initialPenaltyCredit;
  final List<ActivityOptionInput>? initialCategoricalOptions;

  @override
  State<ActivityFormSheet> createState() => _ActivityFormSheetState();
}

class _ActivityFormSheetState extends State<ActivityFormSheet> {
  static const _otherCategoryId = '__other_category__';

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _titleController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _customCategoryController;
  late final TextEditingController _baseCreditController;
  late final TextEditingController _creditPerMinuteController;
  late final TextEditingController _creditPerUnitController;
  late final TextEditingController _maxDailyCreditController;
  late final TextEditingController _penaltyCreditController;
  late final TextEditingController _expectedDurationController;
  final List<_CategoricalOptionControllers> _categoricalOptions = [];

  late String _categoryId;
  late ActivityType _activityType;
  late TrackingType _trackingType;
  late ScheduleFrequency _frequency;
  late final Set<int> _daysOfWeek;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _descriptionController = TextEditingController(
      text: widget.initialDescription,
    );
    _customCategoryController = TextEditingController(text: 'Other');
    _baseCreditController = TextEditingController(
      text: _formatInitialNumber(widget.initialBaseCredit ?? 1),
    );
    _creditPerMinuteController = TextEditingController(
      text: _formatOptionalInitialNumber(widget.initialCreditPerMinute),
    );
    _creditPerUnitController = TextEditingController(
      text: _formatOptionalInitialNumber(widget.initialCreditPerUnit),
    );
    _maxDailyCreditController = TextEditingController(
      text: _formatOptionalInitialNumber(widget.initialMaxDailyCredit),
    );
    _penaltyCreditController = TextEditingController(
      text: _formatInitialNumber(widget.initialPenaltyCredit ?? 0),
    );
    _expectedDurationController = TextEditingController(
      text: widget.initialExpectedDurationMinutes?.toString(),
    );
    _categoryId =
        widget.initialCategoryId ??
        (widget.categories.isNotEmpty ? widget.categories.last.id : '');
    _activityType = widget.initialActivityType == ActivityType.negative
        ? ActivityType.negative
        : ActivityType.positive;
    _trackingType = widget.initialTrackingType ?? TrackingType.boolean;
    _frequency = widget.initialFrequency ?? ScheduleFrequency.daily;
    _daysOfWeek = {
      ...(widget.initialDaysOfWeek?.isNotEmpty == true
          ? widget.initialDaysOfWeek!
          : const [1, 2, 3, 4, 5]),
    };

    final initialOptions = widget.initialCategoricalOptions;
    if (initialOptions != null && initialOptions.isNotEmpty) {
      _categoricalOptions.addAll([
        for (final option in initialOptions)
          _CategoricalOptionControllers(
            label: option.label,
            creditValue: _formatInitialNumber(option.creditValue),
          ),
      ]);
    } else {
      _categoricalOptions.addAll([
        _CategoricalOptionControllers(label: 'Too little', creditValue: '0'),
        _CategoricalOptionControllers(label: 'Normal', creditValue: '1'),
        _CategoricalOptionControllers(label: 'Too much', creditValue: '0'),
      ]);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _customCategoryController.dispose();
    _baseCreditController.dispose();
    _creditPerMinuteController.dispose();
    _creditPerUnitController.dispose();
    _maxDailyCreditController.dispose();
    _penaltyCreditController.dispose();
    _expectedDurationController.dispose();
    for (final option in _categoricalOptions) {
      option.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 8,
          bottom: MediaQuery.viewInsetsOf(context).bottom + 20,
        ),
        child: SizedBox(
          height: MediaQuery.sizeOf(context).height * 0.88,
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Expanded(
                  child: ListView(
                    key: const ValueKey('activity-form-scroll'),
                    children: [
                      Text(widget.title, style: theme.textTheme.titleLarge),
                      const SizedBox(height: 16),
                      TextFormField(
                        key: ValueKey(
                          widget.isRecurring
                              ? 'recurring-title-field'
                              : 'one-time-title-field',
                        ),
                        controller: _titleController,
                        autofocus: true,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Activity name',
                          border: OutlineInputBorder(),
                        ),
                        validator: _requiredText,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _descriptionController,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        initialValue: _categoryId,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(),
                        ),
                        items: [
                          for (final category in widget.categories)
                            DropdownMenuItem(
                              value: category.id,
                              child: Text(category.name),
                            ),
                          const DropdownMenuItem(
                            value: _otherCategoryId,
                            child: Text('Other'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _categoryId = value);
                          }
                        },
                      ),
                      if (_categoryId == _otherCategoryId) ...[
                        const SizedBox(height: 12),
                        TextFormField(
                          key: const ValueKey('custom-category-field'),
                          controller: _customCategoryController,
                          textInputAction: TextInputAction.next,
                          decoration: const InputDecoration(
                            labelText: 'Category name',
                            hintText: 'Other',
                            border: OutlineInputBorder(),
                          ),
                        ),
                      ],
                      const SizedBox(height: 12),
                      SegmentedButton<ActivityType>(
                        segments: const [
                          ButtonSegment(
                            value: ActivityType.positive,
                            label: Text('Good'),
                          ),
                          ButtonSegment(
                            value: ActivityType.negative,
                            label: Text('Bad'),
                          ),
                        ],
                        selected: {_activityType},
                        onSelectionChanged: (selection) {
                          setState(() => _activityType = selection.single);
                        },
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<TrackingType>(
                        initialValue: _trackingType,
                        decoration: const InputDecoration(
                          labelText: 'How you record it',
                          border: OutlineInputBorder(),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: TrackingType.boolean,
                            child: Text('Check off when done'),
                          ),
                          DropdownMenuItem(
                            value: TrackingType.duration,
                            child: Text('Track time spent'),
                          ),
                          DropdownMenuItem(
                            value: TrackingType.quantity,
                            child: Text('Track a number'),
                          ),
                          DropdownMenuItem(
                            value: TrackingType.level,
                            child: Text('Choose a level'),
                          ),
                          DropdownMenuItem(
                            value: TrackingType.milestone,
                            child: Text('Reach a milestone'),
                          ),
                          DropdownMenuItem(
                            value: TrackingType.categorical,
                            child: Text('Choose from custom options'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value != null) {
                            setState(() => _trackingType = value);
                          }
                        },
                      ),
                      if (widget.isRecurring) ...[
                        const SizedBox(height: 16),
                        DropdownButtonFormField<ScheduleFrequency>(
                          initialValue: _frequency,
                          decoration: const InputDecoration(
                            labelText: 'Schedule',
                            border: OutlineInputBorder(),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: ScheduleFrequency.daily,
                              child: Text('Every day'),
                            ),
                            DropdownMenuItem(
                              value: ScheduleFrequency.weekly,
                              child: Text('Selected days'),
                            ),
                            DropdownMenuItem(
                              value: ScheduleFrequency.manual,
                              child: Text('Only when I add it'),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() => _frequency = value);
                            }
                          },
                        ),
                        if (_frequency == ScheduleFrequency.weekly) ...[
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (var day = 1; day <= 7; day++)
                                FilterChip(
                                  label: Text(_weekdayLabel(day)),
                                  selected: _daysOfWeek.contains(day),
                                  onSelected: (selected) {
                                    setState(() {
                                      if (selected) {
                                        _daysOfWeek.add(day);
                                      } else {
                                        _daysOfWeek.remove(day);
                                      }
                                    });
                                  },
                                ),
                            ],
                          ),
                        ],
                        if (_trackingType == TrackingType.duration) ...[
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _expectedDurationController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            decoration: const InputDecoration(
                              labelText: 'Expected minutes',
                              border: OutlineInputBorder(),
                            ),
                          ),
                        ],
                      ],
                      const SizedBox(height: 16),
                      if (_trackingType == TrackingType.categorical) ...[
                        _CategoricalOptionsEditor(
                          options: _categoricalOptions,
                          onChanged: () => setState(() {}),
                          onAddOption: _addCategoricalOption,
                        ),
                        const SizedBox(height: 16),
                      ],
                      _CreditFields(
                        trackingType: _trackingType,
                        baseCreditController: _baseCreditController,
                        creditPerMinuteController: _creditPerMinuteController,
                        creditPerUnitController: _creditPerUnitController,
                        maxDailyCreditController: _maxDailyCreditController,
                        penaltyCreditController: _penaltyCreditController,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        key: const ValueKey('cancel-activity-form'),
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        key: ValueKey(
                          widget.isRecurring
                              ? 'save-recurring-activity'
                              : 'save-one-time-activity',
                        ),
                        onPressed: _submit,
                        child: Text(widget.submitLabel),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String? get _customCategoryName {
    if (_categoryId != _otherCategoryId) {
      return null;
    }
    final trimmed = _customCategoryController.text.trim();
    return trimmed.isEmpty ? 'Other' : trimmed;
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    widget.onSave(
      ActivityFormResult(
        title: _titleController.text.trim(),
        description: _emptyToNull(_descriptionController.text),
        categoryId: _categoryId,
        customCategoryName: _customCategoryName,
        activityType: _activityType,
        trackingType: _trackingType,
        baseCredit: _parseDouble(_baseCreditController.text),
        creditPerMinute: _parseDouble(_creditPerMinuteController.text),
        creditPerUnit: _parseDouble(_creditPerUnitController.text),
        maxDailyCredit: _parseOptionalDouble(_maxDailyCreditController.text),
        penaltyCredit: _parseDouble(_penaltyCreditController.text),
        frequency: widget.isRecurring ? _frequency : ScheduleFrequency.manual,
        daysOfWeek: _frequency == ScheduleFrequency.weekly
            ? (_daysOfWeek.toList()..sort())
            : const [],
        categoricalOptions: _categoricalOptionInputs(),
        expectedDurationMinutes: _parseOptionalInt(
          _expectedDurationController.text,
        ),
      ),
    );
  }

  String? _requiredText(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Add a name first.';
    }
    return null;
  }

  void _addCategoricalOption() {
    setState(() {
      _categoricalOptions.add(
        _CategoricalOptionControllers(
          label: 'Option ${_categoricalOptions.length + 1}',
          creditValue: '0',
        ),
      );
    });
  }

  List<ActivityOptionInput> _categoricalOptionInputs() {
    if (_trackingType != TrackingType.categorical) {
      return const [];
    }

    final inputs = <ActivityOptionInput>[];
    for (final indexedOption in _categoricalOptions.indexed) {
      final index = indexedOption.$1;
      final option = indexedOption.$2;
      final label = option.labelController.text.trim();
      if (label.isEmpty) {
        continue;
      }
      inputs.add(
        ActivityOptionInput(
          label: label,
          value: index + 1,
          creditValue: _parseDouble(option.creditController.text),
        ),
      );
    }
    return inputs;
  }
}

class _CreditFields extends StatelessWidget {
  const _CreditFields({
    required this.trackingType,
    required this.baseCreditController,
    required this.creditPerMinuteController,
    required this.creditPerUnitController,
    required this.maxDailyCreditController,
    required this.penaltyCreditController,
  });

  final TrackingType trackingType;
  final TextEditingController baseCreditController;
  final TextEditingController creditPerMinuteController;
  final TextEditingController creditPerUnitController;
  final TextEditingController maxDailyCreditController;
  final TextEditingController penaltyCreditController;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (trackingType == TrackingType.categorical)
          const SizedBox.shrink()
        else if (trackingType == TrackingType.duration)
          _NumberField(
            controller: creditPerMinuteController,
            label: 'Credits per minute',
            hintText: '0.1',
          )
        else if (trackingType == TrackingType.quantity)
          _NumberField(
            controller: creditPerUnitController,
            label: 'Credits per item',
            hintText: '1',
          )
        else
          _NumberField(
            controller: baseCreditController,
            label: 'Credits when logged',
            hintText: '1',
          ),
        const SizedBox(height: 12),
        _NumberField(
          controller: maxDailyCreditController,
          label: 'Daily credit limit',
          hintText: 'Optional',
        ),
        if (trackingType == TrackingType.level) ...[
          const SizedBox(height: 12),
          _NumberField(
            controller: penaltyCreditController,
            label: 'Lowest level credits',
            hintText: '-5',
            allowNegative: true,
          ),
        ],
      ],
    );
  }
}

class _CategoricalOptionsEditor extends StatelessWidget {
  const _CategoricalOptionsEditor({
    required this.options,
    required this.onChanged,
    required this.onAddOption,
  });

  final List<_CategoricalOptionControllers> options;
  final VoidCallback onChanged;
  final VoidCallback onAddOption;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Options', style: theme.textTheme.titleSmall),
        const SizedBox(height: 8),
        for (final indexedOption in options.indexed) ...[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: indexedOption.$2.labelController,
                  decoration: InputDecoration(
                    labelText: 'Option ${indexedOption.$1 + 1}',
                    border: const OutlineInputBorder(),
                  ),
                  onChanged: (_) => onChanged(),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _NumberField(
                  controller: indexedOption.$2.creditController,
                  label: 'Credits',
                  hintText: '0',
                  allowNegative: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        Align(
          alignment: Alignment.centerLeft,
          child: TextButton.icon(
            onPressed: onAddOption,
            icon: const Icon(Icons.add),
            label: const Text('Add option'),
          ),
        ),
      ],
    );
  }
}

class _CategoricalOptionControllers {
  _CategoricalOptionControllers({
    required String label,
    required String creditValue,
  }) : labelController = TextEditingController(text: label),
       creditController = TextEditingController(text: creditValue);

  final TextEditingController labelController;
  final TextEditingController creditController;

  void dispose() {
    labelController.dispose();
    creditController.dispose();
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.controller,
    required this.label,
    required this.hintText,
    this.allowNegative = false,
  });

  final TextEditingController controller;
  final String label;
  final String hintText;
  final bool allowNegative;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(
          RegExp(allowNegative ? r'^-?\d*\.?\d*' : r'^\d*\.?\d*'),
        ),
      ],
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        border: const OutlineInputBorder(),
      ),
    );
  }
}

String? _emptyToNull(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : trimmed;
}

double _parseDouble(String value) {
  return double.tryParse(value.trim()) ?? 0;
}

double? _parseOptionalDouble(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : double.tryParse(trimmed);
}

int? _parseOptionalInt(String value) {
  final trimmed = value.trim();
  return trimmed.isEmpty ? null : int.tryParse(trimmed);
}

String _formatInitialNumber(double value) {
  if (value == value.roundToDouble()) {
    return value.toInt().toString();
  }
  return value.toString();
}

String _formatOptionalInitialNumber(double? value) {
  if (value == null || value == 0) {
    return '';
  }
  return _formatInitialNumber(value);
}

String _weekdayLabel(int day) {
  return const ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][day - 1];
}
