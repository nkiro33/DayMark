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
  static const _createCategoryId = '__create_category__';

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
  _DurationCreditUnit _durationCreditUnit = _DurationCreditUnit.minute;
  late final Set<int> _daysOfWeek;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.initialTitle);
    _descriptionController = TextEditingController(
      text: widget.initialDescription,
    );
    _customCategoryController = TextEditingController();
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
    _activityType = _categoryActivityType ?? _activityType;
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
    final colorScheme = theme.colorScheme;
    final keyboardOpen = MediaQuery.viewInsetsOf(context).bottom > 0;

    return SafeArea(
      child: Container(
        color: colorScheme.surface,
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
                  Row(
                    children: [
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        tooltip: 'Close',
                        icon: const Icon(Icons.arrow_back),
                      ),
                      Expanded(
                        child: Text(
                          widget.title,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Expanded(
                    child: ListView(
                      key: const ValueKey('activity-form-scroll'),
                      children: [
                        _FormSection(
                          children: [
                            _FieldWithTitle(
                              label: 'Activity Name',
                              child: TextFormField(
                                key: ValueKey(
                                  widget.isRecurring
                                      ? 'recurring-title-field'
                                      : 'one-time-title-field',
                                ),
                                controller: _titleController,
                                autofocus: true,
                                textInputAction: TextInputAction.next,
                                decoration: _inputDecoration(
                                  context,
                                  hintText: 'e.g., Morning run',
                                ),
                                validator: _requiredText,
                              ),
                            ),
                            const SizedBox(height: 16),
                            _FieldWithTitle(
                              label: 'Description',
                              trailingLabel: 'Optional',
                              child: TextFormField(
                                controller: _descriptionController,
                                textInputAction: TextInputAction.next,
                                minLines: 2,
                                maxLines: 3,
                                decoration: _inputDecoration(
                                  context,
                                  hintText: 'Add some details...',
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            _CategoryMenu(
                              selectedCategoryId: _categoryId,
                              categories: widget.categories,
                              onSelected: _setCategory,
                            ),
                            if (_categoryId == _createCategoryId) ...[
                              const SizedBox(height: 16),
                              _FieldWithTitle(
                                label: 'Category Name',
                                child: TextFormField(
                                  key: const ValueKey('custom-category-field'),
                                  controller: _customCategoryController,
                                  textInputAction: TextInputAction.next,
                                  decoration: _inputDecoration(
                                    context,
                                    hintText: 'e.g., Music',
                                  ),
                                  validator: _requiredCustomCategory,
                                ),
                              ),
                            ],
                          ],
                        ),
                        const SizedBox(height: 24),
                        _FormSection(
                          children: [
                            if (!_categorySetsActivityType) ...[
                              _FieldWithTitle(
                                label: 'Activity Type',
                                child: SizedBox(
                                  width: double.infinity,
                                  child: SegmentedButton<ActivityType>(
                                    segments: const [
                                      ButtonSegment(
                                        value: ActivityType.positive,
                                        label: Text('Good Habit'),
                                      ),
                                      ButtonSegment(
                                        value: ActivityType.negative,
                                        label: Text('Bad Habit'),
                                      ),
                                    ],
                                    selected: {_activityType},
                                    onSelectionChanged: (selection) {
                                      setState(
                                        () => _activityType = selection.single,
                                      );
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                            ],
                            _MenuSelectField<TrackingType>(
                              key: const ValueKey('tracking-type-menu-field'),
                              label: 'Recording Method',
                              value: _trackingType,
                              options: const [
                                _MenuSelectOption(
                                  value: TrackingType.boolean,
                                  label: 'Completion',
                                  icon: Icons.task_alt_outlined,
                                ),
                                _MenuSelectOption(
                                  value: TrackingType.duration,
                                  label: 'Duration',
                                  icon: Icons.timer_outlined,
                                ),
                                _MenuSelectOption(
                                  value: TrackingType.quantity,
                                  label: 'Quantity',
                                  icon: Icons.tag_outlined,
                                ),
                                _MenuSelectOption(
                                  value: TrackingType.level,
                                  label: 'Level',
                                  icon: Icons.tune_outlined,
                                ),
                                _MenuSelectOption(
                                  value: TrackingType.milestone,
                                  label: 'Milestone',
                                  icon: Icons.flag_outlined,
                                ),
                                _MenuSelectOption(
                                  value: TrackingType.categorical,
                                  label: 'Custom options',
                                  icon: Icons.category_outlined,
                                ),
                              ],
                              onChanged: (value) {
                                setState(() => _trackingType = value);
                              },
                            ),
                            if (widget.isRecurring) ...[
                              const SizedBox(height: 16),
                              _MenuSelectField<ScheduleFrequency>(
                                key: const ValueKey('schedule-menu-field'),
                                label: 'Schedule',
                                value: _frequency,
                                options: const [
                                  _MenuSelectOption(
                                    value: ScheduleFrequency.daily,
                                    label: 'Every day',
                                    icon: Icons.calendar_today_outlined,
                                  ),
                                  _MenuSelectOption(
                                    value: ScheduleFrequency.weekly,
                                    label: 'Selected days',
                                    icon: Icons.event_available_outlined,
                                  ),
                                  _MenuSelectOption(
                                    value: ScheduleFrequency.manual,
                                    label: 'Only when I add it',
                                    icon: Icons.add_task_outlined,
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() => _frequency = value);
                                },
                              ),
                              if (_frequency == ScheduleFrequency.weekly) ...[
                                const SizedBox(height: 12),
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
                                const SizedBox(height: 16),
                                _FieldWithTitle(
                                  label: 'Expected Minutes',
                                  child: TextFormField(
                                    controller: _expectedDurationController,
                                    keyboardType: TextInputType.number,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    decoration: _inputDecoration(context),
                                  ),
                                ),
                              ],
                            ],
                          ],
                        ),
                        const SizedBox(height: 24),
                        if (_trackingType == TrackingType.categorical) ...[
                          _FormSection(
                            children: [
                              _CategoricalOptionsEditor(
                                options: _categoricalOptions,
                                onChanged: () => setState(() {}),
                                onAddOption: _addCategoricalOption,
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                        ],
                        _FormSection(
                          title: 'Rewards',
                          icon: Icons.toll_outlined,
                          children: [
                            _CreditFields(
                              trackingType: _trackingType,
                              durationCreditUnit: _durationCreditUnit,
                              baseCreditController: _baseCreditController,
                              creditPerMinuteController:
                                  _creditPerMinuteController,
                              creditPerUnitController: _creditPerUnitController,
                              maxDailyCreditController:
                                  _maxDailyCreditController,
                              penaltyCreditController: _penaltyCreditController,
                              onDurationCreditUnitChanged:
                                  _setDurationCreditUnit,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (!keyboardOpen) ...[
                    const SizedBox(height: 16),
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
                          flex: 2,
                          child: FilledButton.icon(
                            key: ValueKey(
                              widget.isRecurring
                                  ? 'save-recurring-activity'
                                  : 'save-one-time-activity',
                            ),
                            onPressed: _submit,
                            icon: const Icon(Icons.save_outlined),
                            label: Text(widget.submitLabel),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String? get _customCategoryName {
    if (_categoryId == _otherCategoryId) {
      return 'Other';
    }
    if (_categoryId != _createCategoryId) {
      return null;
    }
    final trimmed = _customCategoryController.text.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  ActivityType get _effectiveActivityType {
    return _categoryActivityType ?? _activityType;
  }

  bool get _categorySetsActivityType {
    return _categoryActivityType != null;
  }

  ActivityType? get _categoryActivityType {
    if (_categoryId == _otherCategoryId || _categoryId == _createCategoryId) {
      return null;
    }
    final category = widget.categories
        .where((category) => category.id == _categoryId)
        .firstOrNull;
    return switch (category?.code) {
      'good_habit' => ActivityType.positive,
      'bad_habit' => ActivityType.negative,
      _ => null,
    };
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
        activityType: _effectiveActivityType,
        trackingType: _trackingType,
        baseCredit: _parseDouble(_baseCreditController.text),
        creditPerMinute: _durationCreditPerMinuteForSubmit,
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

  void _setCategory(String value) {
    setState(() {
      _categoryId = value;
      _activityType = _categoryActivityType ?? _activityType;
      if (value != _createCategoryId) {
        _customCategoryController.clear();
      }
    });
  }

  double get _durationCreditPerMinuteForSubmit {
    final value = _parseDouble(_creditPerMinuteController.text);
    if (_trackingType != TrackingType.duration) {
      return value;
    }
    return _durationCreditUnit == _DurationCreditUnit.hour ? value / 60 : value;
  }

  void _setDurationCreditUnit(_DurationCreditUnit unit) {
    if (unit == _durationCreditUnit) {
      return;
    }

    final currentValue = _parseOptionalDouble(_creditPerMinuteController.text);
    setState(() {
      if (currentValue != null) {
        final converted = unit == _DurationCreditUnit.hour
            ? currentValue * 60
            : currentValue / 60;
        _creditPerMinuteController.text = _formatInitialNumber(converted);
      }
      _durationCreditUnit = unit;
    });
  }

  String? _requiredText(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Add a name first.';
    }
    return null;
  }

  String? _requiredCustomCategory(String? value) {
    if (_categoryId != _createCategoryId) {
      return null;
    }
    if (value == null || value.trim().isEmpty) {
      return 'Add a category name.';
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

class _FormSection extends StatelessWidget {
  const _FormSection({required this.children, this.title, this.icon});

  final List<Widget> children;
  final String? title;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow.withValues(alpha: 0.64),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: colorScheme.onSurface.withValues(alpha: 0.05),
        ),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.06),
            blurRadius: 26,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Row(
              children: [
                if (icon != null) ...[
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: colorScheme.tertiaryContainer.withValues(
                      alpha: 0.28,
                    ),
                    foregroundColor: colorScheme.tertiary,
                    child: Icon(icon, size: 21),
                  ),
                  const SizedBox(width: 12),
                ],
                Text(
                  title!,
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
                ),
              ],
            ),
            const SizedBox(height: 18),
          ],
          ...children,
        ],
      ),
    );
  }
}

class _CategoryMenu extends StatefulWidget {
  const _CategoryMenu({
    required this.selectedCategoryId,
    required this.categories,
    required this.onSelected,
  });

  final String selectedCategoryId;
  final List<ActivityCategory> categories;
  final ValueChanged<String> onSelected;

  @override
  State<_CategoryMenu> createState() => _CategoryMenuState();
}

class _CategoryMenuState extends State<_CategoryMenu> {
  bool _isOpen = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final selectedLabel = _selectedLabel;
    final selectedIcon = _selectedIcon;

    return _FieldWithTitle(
      label: 'Category',
      child: LayoutBuilder(
        builder: (context, constraints) {
          return MenuAnchor(
            crossAxisUnconstrained: false,
            onOpen: () => setState(() => _isOpen = true),
            onClose: () => setState(() => _isOpen = false),
            style: _menuStyle(context),
            menuChildren: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: 320,
                  minWidth: constraints.maxWidth,
                  maxWidth: constraints.maxWidth,
                ),
                child: SingleChildScrollView(
                  primary: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final category in widget.categories)
                        _MenuSelectItem(
                          label: category.name,
                          selected: category.id == widget.selectedCategoryId,
                          icon: _categoryIcon(category.code),
                          onPressed: () => widget.onSelected(category.id),
                        ),
                      const _MenuDivider(),
                      _MenuSelectItem(
                        label: 'Other',
                        selected:
                            widget.selectedCategoryId ==
                            _ActivityFormSheetState._otherCategoryId,
                        icon: Icons.category_outlined,
                        onPressed: () => widget.onSelected(
                          _ActivityFormSheetState._otherCategoryId,
                        ),
                      ),
                      _MenuSelectItem(
                        label: 'Create new category',
                        selected:
                            widget.selectedCategoryId ==
                            _ActivityFormSheetState._createCategoryId,
                        icon: Icons.add,
                        onPressed: () => widget.onSelected(
                          _ActivityFormSheetState._createCategoryId,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            builder: (context, controller, child) {
              return _MenuFieldButton(
                key: const ValueKey('category-menu-field'),
                controller: controller,
                isOpen: _isOpen,
                child: Row(
                  children: [
                    _MenuIconBadge(icon: selectedIcon, selected: true),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        selectedLabel,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    Icon(
                      _isOpen
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: _isOpen
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  String get _selectedLabel {
    if (widget.selectedCategoryId == _ActivityFormSheetState._otherCategoryId) {
      return 'Other';
    }
    if (widget.selectedCategoryId ==
        _ActivityFormSheetState._createCategoryId) {
      return 'Create new category';
    }
    return widget.categories
            .where((category) => category.id == widget.selectedCategoryId)
            .firstOrNull
            ?.name ??
        'Select a category';
  }

  IconData get _selectedIcon {
    if (widget.selectedCategoryId == _ActivityFormSheetState._otherCategoryId) {
      return Icons.category_outlined;
    }
    if (widget.selectedCategoryId ==
        _ActivityFormSheetState._createCategoryId) {
      return Icons.add;
    }
    final category = widget.categories
        .where((category) => category.id == widget.selectedCategoryId)
        .firstOrNull;
    return _categoryIcon(category?.code);
  }
}

class _MenuSelectOption<T> {
  const _MenuSelectOption({
    required this.value,
    required this.label,
    this.icon,
  });

  final T value;
  final String label;
  final IconData? icon;
}

class _MenuSelectField<T> extends StatefulWidget {
  const _MenuSelectField({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
  });

  final String label;
  final T value;
  final List<_MenuSelectOption<T>> options;
  final ValueChanged<T> onChanged;

  @override
  State<_MenuSelectField<T>> createState() => _MenuSelectFieldState<T>();
}

class _MenuSelectFieldState<T> extends State<_MenuSelectField<T>> {
  bool _isOpen = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final selectedOption = widget.options.firstWhere(
      (option) => option.value == widget.value,
    );

    return _FieldWithTitle(
      label: widget.label,
      child: LayoutBuilder(
        builder: (context, constraints) {
          return MenuAnchor(
            crossAxisUnconstrained: false,
            onOpen: () => setState(() => _isOpen = true),
            onClose: () => setState(() => _isOpen = false),
            style: _menuStyle(context),
            menuChildren: [
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: 320,
                  minWidth: constraints.maxWidth,
                  maxWidth: constraints.maxWidth,
                ),
                child: SingleChildScrollView(
                  primary: false,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (final option in widget.options)
                        _MenuSelectItem(
                          label: option.label,
                          selected: option.value == widget.value,
                          icon: option.icon,
                          onPressed: () => widget.onChanged(option.value),
                        ),
                    ],
                  ),
                ),
              ),
            ],
            builder: (context, controller, child) {
              return _MenuFieldButton(
                controller: controller,
                isOpen: _isOpen,
                child: Row(
                  children: [
                    if (selectedOption.icon != null) ...[
                      _MenuIconBadge(
                        icon: selectedOption.icon!,
                        selected: true,
                      ),
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: Text(
                        selectedOption.label,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: colorScheme.onSurface,
                        ),
                      ),
                    ),
                    Icon(
                      _isOpen
                          ? Icons.keyboard_arrow_up
                          : Icons.keyboard_arrow_down,
                      color: _isOpen
                          ? colorScheme.primary
                          : colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _MenuFieldButton extends StatelessWidget {
  const _MenuFieldButton({
    super.key,
    required this.controller,
    required this.isOpen,
    required this.child,
  });

  final MenuController controller;
  final bool isOpen;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          FocusManager.instance.primaryFocus?.unfocus();
          controller.isOpen ? controller.close() : controller.open();
        },
        borderRadius: BorderRadius.circular(16),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          constraints: const BoxConstraints(minHeight: 58),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          decoration: BoxDecoration(
            color: isOpen
                ? colorScheme.surfaceContainerHigh
                : const Color(0xFF050505),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isOpen ? colorScheme.primary : colorScheme.outlineVariant,
              width: isOpen ? 2 : 1,
            ),
            boxShadow: [
              if (isOpen)
                BoxShadow(
                  color: colorScheme.primary.withValues(alpha: 0.15),
                  blurRadius: 24,
                ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class _MenuSelectItem extends StatelessWidget {
  const _MenuSelectItem({
    required this.label,
    required this.selected,
    required this.onPressed,
    this.icon,
  });

  final String label;
  final bool selected;
  final VoidCallback onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return MenuItemButton(
      onPressed: onPressed,
      leadingIcon: _MenuIconBadge(icon: icon, selected: selected),
      trailingIcon: selected ? const Icon(Icons.check) : null,
      style: ButtonStyle(
        minimumSize: const WidgetStatePropertyAll(Size.fromHeight(58)),
        padding: const WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (selected) {
            return colorScheme.primary.withValues(alpha: 0.10);
          }
          if (states.contains(WidgetState.hovered) ||
              states.contains(WidgetState.focused)) {
            return colorScheme.surfaceContainerHighest;
          }
          return Colors.transparent;
        }),
        foregroundColor: WidgetStatePropertyAll(
          selected ? colorScheme.primary : colorScheme.onSurface,
        ),
        iconColor: WidgetStatePropertyAll(
          selected ? colorScheme.primary : colorScheme.onSurfaceVariant,
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        textStyle: WidgetStatePropertyAll(
          Theme.of(
            context,
          ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
      child: Text(label),
    );
  }
}

class _MenuIconBadge extends StatelessWidget {
  const _MenuIconBadge({required this.icon, required this.selected});

  final IconData? icon;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final foreground = selected
        ? colorScheme.primary
        : colorScheme.onSurfaceVariant;
    final background = selected
        ? colorScheme.primary.withValues(alpha: 0.20)
        : colorScheme.surfaceContainerHighest;

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(color: background, shape: BoxShape.circle),
      child: Icon(icon ?? Icons.circle_outlined, color: foreground, size: 22),
    );
  }
}

class _MenuDivider extends StatelessWidget {
  const _MenuDivider();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Divider(
        height: 1,
        thickness: 1,
        color: colorScheme.outlineVariant.withValues(alpha: 0.3),
      ),
    );
  }
}

class _FieldWithTitle extends StatelessWidget {
  const _FieldWithTitle({
    required this.label,
    required this.child,
    this.trailingLabel,
  });

  final String label;
  final Widget child;
  final String? trailingLabel;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final labelStyle = Theme.of(context).textTheme.labelMedium?.copyWith(
      color: colorScheme.onSurfaceVariant,
      fontWeight: FontWeight.w800,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: Text(label, style: labelStyle)),
            if (trailingLabel != null)
              Text(
                trailingLabel!,
                style: labelStyle?.copyWith(
                  color: colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

MenuStyle _menuStyle(BuildContext context) {
  final colorScheme = Theme.of(context).colorScheme;
  return MenuStyle(
    backgroundColor: WidgetStatePropertyAll(
      colorScheme.surfaceContainer.withValues(alpha: 0.94),
    ),
    elevation: const WidgetStatePropertyAll(16),
    shadowColor: WidgetStatePropertyAll(Colors.black.withValues(alpha: 0.40)),
    padding: const WidgetStatePropertyAll(EdgeInsets.all(8)),
    side: WidgetStatePropertyAll(
      BorderSide(color: colorScheme.outlineVariant.withValues(alpha: 0.2)),
    ),
    shape: WidgetStatePropertyAll(
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
  );
}

IconData _categoryIcon(String? code) {
  return switch (code) {
    'good_habit' => Icons.auto_awesome_outlined,
    'work' => Icons.work_outline,
    'study' => Icons.menu_book_outlined,
    'course' => Icons.school_outlined,
    'project' => Icons.rocket_launch_outlined,
    'bad_habit' => Icons.block_outlined,
    'health' => Icons.favorite_border,
    'personal' => Icons.person_outline,
    'to_do' => Icons.check_circle_outline,
    _ => Icons.category_outlined,
  };
}

InputDecoration _inputDecoration(BuildContext context, {String? hintText}) {
  final colorScheme = Theme.of(context).colorScheme;
  final border = OutlineInputBorder(
    borderRadius: BorderRadius.circular(16),
    borderSide: BorderSide(color: colorScheme.outlineVariant),
  );

  return InputDecoration(
    hintText: hintText,
    filled: true,
    fillColor: const Color(0xFF050505),
    border: border,
    enabledBorder: border,
    focusedBorder: border.copyWith(
      borderSide: BorderSide(color: colorScheme.primary, width: 1.4),
    ),
  );
}

class _CreditFields extends StatelessWidget {
  const _CreditFields({
    required this.trackingType,
    required this.durationCreditUnit,
    required this.baseCreditController,
    required this.creditPerMinuteController,
    required this.creditPerUnitController,
    required this.maxDailyCreditController,
    required this.penaltyCreditController,
    required this.onDurationCreditUnitChanged,
  });

  final TrackingType trackingType;
  final _DurationCreditUnit durationCreditUnit;
  final TextEditingController baseCreditController;
  final TextEditingController creditPerMinuteController;
  final TextEditingController creditPerUnitController;
  final TextEditingController maxDailyCreditController;
  final TextEditingController penaltyCreditController;
  final ValueChanged<_DurationCreditUnit> onDurationCreditUnitChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (trackingType == TrackingType.categorical)
          const SizedBox.shrink()
        else if (trackingType == TrackingType.duration) ...[
          SegmentedButton<_DurationCreditUnit>(
            segments: const [
              ButtonSegment(
                value: _DurationCreditUnit.minute,
                label: Text('Per minute'),
              ),
              ButtonSegment(
                value: _DurationCreditUnit.hour,
                label: Text('Per hour'),
              ),
            ],
            selected: {durationCreditUnit},
            onSelectionChanged: (selection) {
              onDurationCreditUnitChanged(selection.single);
            },
          ),
          const SizedBox(height: 12),
          _NumberField(
            key: const ValueKey('duration-credit-field'),
            controller: creditPerMinuteController,
            label: durationCreditUnit == _DurationCreditUnit.hour
                ? 'Credits per hour'
                : 'Credits per minute',
            hintText: durationCreditUnit == _DurationCreditUnit.hour
                ? '6'
                : '0.1',
          ),
        ] else if (trackingType == TrackingType.quantity)
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
                child: _FieldWithTitle(
                  label: 'Option ${indexedOption.$1 + 1}',
                  child: TextFormField(
                    controller: indexedOption.$2.labelController,
                    decoration: _inputDecoration(context),
                    onChanged: (_) => onChanged(),
                  ),
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
    super.key,
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
    return _FieldWithTitle(
      label: label,
      child: TextFormField(
        controller: controller,
        keyboardType: const TextInputType.numberWithOptions(decimal: true),
        inputFormatters: [
          FilteringTextInputFormatter.allow(
            RegExp(allowNegative ? r'^-?\d*\.?\d*' : r'^\d*\.?\d*'),
          ),
        ],
        decoration: _inputDecoration(context, hintText: hintText),
      ),
    );
  }
}

enum _DurationCreditUnit { minute, hour }

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
