import 'package:flutter/material.dart';

import 'tag_chip.dart';

const int kMaxTagsPerItem = 8;

class TagsInputField extends StatefulWidget {
  final List<String> suggestedTags;
  final ValueChanged<List<String>> onChanged;
  final List<String> initialTags;

  const TagsInputField({
    super.key,
    required this.suggestedTags,
    required this.onChanged,
    this.initialTags = const [],
  });

  @override
  State<TagsInputField> createState() => _TagsInputFieldState();
}

class _TagsInputFieldState extends State<TagsInputField> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final List<String> _tags = [];

  String _previousRawValue = '';
  bool _isSyncingText = false;

  @override
  void initState() {
    super.initState();
    _addTags(widget.initialTags, notify: false);
    _focusNode.addListener(() {
      if (mounted) {
        if (!_focusNode.hasFocus && _controller.text.trim().isNotEmpty) {
          setState(_commitCurrentInput);
        }
        setState(() {});
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onChanged(List<String>.unmodifiable(_tags));
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  String _normalizeTag(String raw) {
    return raw.trim().replaceAll(RegExp(r'\s+'), ' ');
  }

  String _tagKey(String raw) {
    return _normalizeTag(raw).toLowerCase();
  }

  bool _containsTag(String tag) {
    final key = _tagKey(tag);
    return _tags.any((current) => _tagKey(current) == key);
  }

  void _notify() {
    widget.onChanged(List<String>.unmodifiable(_tags));
  }

  void _replaceText(String value) {
    _isSyncingText = true;
    _controller.value = TextEditingValue(
      text: value,
      selection: TextSelection.collapsed(offset: value.length),
    );
    _previousRawValue = value;
    _isSyncingText = false;
  }

  void _addTags(Iterable<String> values, {bool notify = true}) {
    var changed = false;

    for (final raw in values) {
      if (_tags.length >= kMaxTagsPerItem) {
        break;
      }
      final normalized = _normalizeTag(raw);
      if (normalized.isEmpty || _containsTag(normalized)) {
        continue;
      }
      _tags.add(normalized);
      changed = true;
    }

    if (changed && notify) {
      _notify();
    }
  }

  void _commitCurrentInput() {
    final value = _controller.text;
    if (value.trim().isEmpty) {
      _replaceText('');
      return;
    }

    _addTags([value]);
    _replaceText('');
  }

  void _removeTag(String tag) {
    _tags.removeWhere((current) => _tagKey(current) == _tagKey(tag));
    _notify();
  }

  void _toggleSuggestedTag(String tag) {
    if (_containsTag(tag)) {
      _tags.removeWhere((current) => _tagKey(current) == _tagKey(tag));
    } else if (_tags.length < kMaxTagsPerItem) {
      _tags.add(_normalizeTag(tag));
    }
    _notify();
    _focusNode.requestFocus();
  }

  void _handleChanged(String value) {
    if (_isSyncingText) return;

    final previous = _previousRawValue;
    _previousRawValue = value;

    if (!value.contains(RegExp(r'[,;\n]'))) {
      return;
    }

    final parts = value.split(RegExp(r'[,;\n]'));
    final looksLikePaste = value.length - previous.length > 1;
    final endsWithSeparator = RegExp(r'[,;\n]\s*$').hasMatch(value);

    if (looksLikePaste) {
      setState(() {
        _addTags(parts);
      });
      _replaceText('');
      return;
    }

    final completed = endsWithSeparator ? parts : parts.take(parts.length - 1);
    final remaining = endsWithSeparator || parts.isEmpty ? '' : parts.last;

    setState(() {
      _addTags(completed);
    });
    _replaceText(remaining);
  }

  @override
  Widget build(BuildContext context) {
    final hasTags = _tags.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InputDecorator(
          decoration: _tagsInputDecoration(),
          isFocused: _focusNode.hasFocus,
          isEmpty: !hasTags && _controller.text.isEmpty,
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              ..._tags.map(
                (tag) => InputChip(
                  label: Text(tag),
                  onDeleted: () => setState(() => _removeTag(tag)),
                  backgroundColor: const Color(0xFFFFF7FB),
                  deleteIconColor: const Color(0xFF6A645C),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                    side: const BorderSide(color: Color(0xFFE7D9E1)),
                  ),
                ),
              ),
              ConstrainedBox(
                constraints: const BoxConstraints(minWidth: 120, maxWidth: 260),
                child: TextField(
                  controller: _controller,
                  focusNode: _focusNode,
                  decoration: const InputDecoration(
                    hintText: 'Agregá etiquetas',
                    border: InputBorder.none,
                    isCollapsed: true,
                  ),
                  textInputAction: TextInputAction.done,
                  onChanged: _handleChanged,
                  onSubmitted: (_) => setState(_commitCurrentInput),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Confirmá cada etiqueta con coma, enter o punto y coma. Máximo $kMaxTagsPerItem.',
          style: TextStyle(
            fontSize: 12,
            color: Colors.black.withValues(alpha: 0.58),
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: widget.suggestedTags.map((tag) {
            final selected = _containsTag(tag);
            return TagChip(
              label: tag,
              selected: selected,
              onTap: () => setState(() => _toggleSuggestedTag(tag)),
            );
          }).toList(),
        ),
      ],
    );
  }
}

InputDecoration _tagsInputDecoration() {
  return InputDecoration(
    labelText: 'Etiquetas',
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Color(0xFFE7D9E1)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Color(0xFFE7D9E1)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Color(0xFFC695B2), width: 1.5),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
  );
}
