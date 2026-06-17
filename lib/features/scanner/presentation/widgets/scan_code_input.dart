import 'package:flutter/material.dart';

class ScanCodeInput extends StatefulWidget {
  const ScanCodeInput({
    super.key,
    required this.code,
    required this.enabled,
    required this.onChanged,
  });

  final String code;
  final bool enabled;
  final ValueChanged<String> onChanged;

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

    if (!widget.enabled) {
      return Text(
        widget.code,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: widget.code.isEmpty
                  ? colorScheme.onSurface.withValues(alpha: 0.35)
                  : null,
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
        contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 0),
      ),
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
      onChanged: widget.onChanged,
      onSubmitted: (_) => FocusScope.of(context).unfocus(),
      onEditingComplete: () => FocusScope.of(context).unfocus(),
    );
  }
}
