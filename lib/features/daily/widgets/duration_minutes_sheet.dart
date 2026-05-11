import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class DurationMinutesSheet extends StatefulWidget {
  const DurationMinutesSheet({
    super.key,
    required this.title,
    required this.initialMinutes,
    required this.onSave,
    this.saveLabel = 'Save',
    this.keyPrefix = 'duration',
    this.maxMinutes,
    this.noteLabel,
    this.initialNote,
  });

  final String title;
  final int? initialMinutes;
  final ValueChanged<DurationMinutesResult> onSave;
  final String saveLabel;
  final String keyPrefix;
  final int? maxMinutes;
  final String? noteLabel;
  final String? initialNote;

  @override
  State<DurationMinutesSheet> createState() => _DurationMinutesSheetState();
}

class _DurationMinutesSheetState extends State<DurationMinutesSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _hoursController;
  late final TextEditingController _minutesController;
  late final TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    final initialMinutes = widget.initialMinutes;
    _hoursController = TextEditingController(
      text: initialMinutes == null ? '' : '${initialMinutes ~/ 60}',
    );
    _minutesController = TextEditingController(
      text: initialMinutes == null ? '' : '${initialMinutes % 60}',
    );
    _noteController = TextEditingController(text: widget.initialNote);
  }

  @override
  void dispose() {
    _hoursController.dispose();
    _minutesController.dispose();
    _noteController.dispose();
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
        child: Form(
          key: _formKey,
          child: ListView(
            shrinkWrap: true,
            children: [
              Text(widget.title, style: theme.textTheme.titleLarge),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      key: ValueKey('${widget.keyPrefix}-hours-field'),
                      controller: _hoursController,
                      autofocus: true,
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
                    child: TextFormField(
                      key: ValueKey('${widget.keyPrefix}-minutes-field'),
                      controller: _minutesController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        labelText: 'Minutes',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        final minutes = int.tryParse(value?.trim() ?? '') ?? 0;
                        if (minutes < 0 || minutes > 59) {
                          return 'Use 0-59.';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              if (widget.noteLabel != null) ...[
                const SizedBox(height: 12),
                TextFormField(
                  key: ValueKey('${widget.keyPrefix}-note-field'),
                  controller: _noteController,
                  minLines: 2,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: widget.noteLabel,
                    border: const OutlineInputBorder(),
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      key: ValueKey('cancel-${widget.keyPrefix}-duration'),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      key: ValueKey('save-${widget.keyPrefix}-duration'),
                      onPressed: _submit,
                      child: Text(widget.saveLabel),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final hours = int.tryParse(_hoursController.text.trim()) ?? 0;
    final minutes = int.tryParse(_minutesController.text.trim()) ?? 0;
    final totalMinutes = hours * 60 + minutes;
    final maxMinutes = widget.maxMinutes;
    if (totalMinutes <= 0 ||
        (maxMinutes != null && totalMinutes > maxMinutes)) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(SnackBar(content: Text(_validationMessage(maxMinutes))));
      return;
    }

    widget.onSave(
      DurationMinutesResult(totalMinutes: totalMinutes, note: _cleanNote),
    );
  }

  String _validationMessage(int? maxMinutes) {
    if (maxMinutes == null) {
      return 'Enter a duration above 0 minutes.';
    }
    return 'Enter a duration between 1 minute and ${maxMinutes ~/ 60}h.';
  }

  String? get _cleanNote {
    final note = _noteController.text.trim();
    return note.isEmpty ? null : note;
  }
}

class DurationMinutesResult {
  const DurationMinutesResult({required this.totalMinutes, this.note});

  final int totalMinutes;
  final String? note;
}
