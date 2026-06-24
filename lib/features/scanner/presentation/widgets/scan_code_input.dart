import 'package:flutter/material.dart';

class ScanCodeInput extends StatefulWidget {
  const ScanCodeInput({
    super.key,
    required this.code,
    required this.enabled,
    required this.onChanged,
    this.darkStyle = false,
  });

  final String code;
  final bool enabled;
  final ValueChanged<String> onChanged;
  final bool darkStyle;

  @override
  State<ScanCodeInput> createState() => _ScanCodeInputState();
}

class _ScanCodeInputState extends State<ScanCodeInput> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.code);
  }

  @override
  void didUpdateWidget(covariant ScanCodeInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.code != widget.code && _controller.text != widget.code) {
      _controller.text = widget.code;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textColor = widget.darkStyle ? Colors.white : colorScheme.onSurface;
    final placeholderColor = widget.darkStyle
        ? Colors.white.withValues(alpha: 0.35)
        : colorScheme.onSurface.withValues(alpha: 0.35);

    if (!widget.enabled) {
      return Text(
        widget.code,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: widget.code.isEmpty ? placeholderColor : textColor,
            ),
      );
    }

    return TextField(
      controller: _controller,
      maxLines: 1,
      textInputAction: TextInputAction.done,
      decoration: const InputDecoration(
        isDense: true,
        border: InputBorder.none,
        contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
      ),
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
      onChanged: widget.onChanged,
      onSubmitted: (_) => FocusScope.of(context).unfocus(),
      onEditingComplete: () => FocusScope.of(context).unfocus(),
    );
  }
}
