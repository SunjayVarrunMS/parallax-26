// form pieces: labelled fields, drop-downs and the checks every form uses

import 'package:flutter/material.dart';

import '../theme.dart';

// the message shown under a field that failed its check
String errText(String message) {
  return '[ERR] $message';
}

final RegExp _emailPattern = RegExp(r'^\S+@\S+\.\S+$');

String? validateName(String? value) {
  if ((value ?? '').trim() == '') {
    return errText('Enter your full name.');
  }
  return null;
}

String? validateEmail(String? value) {
  final email = (value ?? '').trim();
  if (email == '') {
    return errText('Enter your email.');
  }
  if (!_emailPattern.hasMatch(email)) {
    return errText('That email does not look right.');
  }
  return null;
}

// the look of every text box and drop-down
InputDecoration plxDecoration(BuildContext context, {String? hint}) {
  final c = PlxColors.of(context);
  OutlineInputBorder border(Color color) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.zero,
      borderSide: BorderSide(color: color, width: 2),
    );
  }

  return InputDecoration(
    hintText: hint,
    hintStyle: monoStyle(size: 14.4, color: c.muted),
    filled: true,
    fillColor: c.paper,
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    border: border(c.lineSoft),
    enabledBorder: border(c.lineSoft),
    focusedBorder: border(c.cyan),
    errorBorder: border(c.error),
    focusedErrorBorder: border(c.error),
    errorStyle: monoStyle(size: 12.5, weight: FontWeight.w700, color: c.error, height: 1.5),
  );
}

// ">> LABEL" above a form control
class FieldBlock extends StatelessWidget {
  const FieldBlock({super.key, required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final c = PlxColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '>> ${label.toUpperCase()}',
          style: monoStyle(size: 12, weight: FontWeight.w800, color: c.cyan, spacing: 0.7, height: 1.4),
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}

// a labelled text box
class PlxTextField extends StatelessWidget {
  const PlxTextField({
    super.key,
    required this.label,
    required this.controller,
    this.validator,
    this.hint,
    this.keyboardType,
    this.maxLines = 1,
    this.onChanged,
  });

  final String label;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final String? hint;
  final TextInputType? keyboardType;
  final int maxLines;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final c = PlxColors.of(context);
    return FieldBlock(
      label: label,
      child: TextFormField(
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        maxLines: maxLines,
        onChanged: onChanged,
        cursorColor: c.cyan,
        style: monoStyle(size: 14.4, color: c.ink, height: 1.4),
        decoration: plxDecoration(context, hint: hint),
      ),
    );
  }
}

// a labelled drop-down that lists text options
class PlxDropdown extends StatelessWidget {
  const PlxDropdown({
    super.key,
    required this.label,
    required this.value,
    required this.options,
    required this.onChanged,
    this.validator,
  });

  final String label;
  final String value;

  // value -> text shown in the list
  final Map<String, String> options;
  final ValueChanged<String> onChanged;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    final c = PlxColors.of(context);
    return FieldBlock(
      label: label,
      child: DropdownButtonFormField<String>(
        initialValue: value,
        isExpanded: true,
        validator: validator,
        dropdownColor: c.surface,
        iconEnabledColor: c.cyan,
        style: monoStyle(size: 14.4, color: c.ink, height: 1.4),
        decoration: plxDecoration(context),
        items: [
          for (final entry in options.entries)
            DropdownMenuItem<String>(
              value: entry.key,
              child: Text(entry.value, overflow: TextOverflow.ellipsis),
            ),
        ],
        onChanged: (picked) {
          if (picked != null) {
            onChanged(picked);
          }
        },
      ),
    );
  }
}
