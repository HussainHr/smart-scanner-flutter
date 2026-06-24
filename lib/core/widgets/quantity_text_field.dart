import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:smart_scanner/core/theme/app_theme.dart';

class QuantityTextField extends StatefulWidget {
  const QuantityTextField({
    super.key,
    required this.quantity,
    required this.onChanged,
    this.onFocus,
    this.showBorder = false,
    this.textAlign = TextAlign.center,
    this.darkStyle = false,
  });

  final int quantity;
  final ValueChanged<int> onChanged;
  final VoidCallback? onFocus;
  final bool showBorder;
  final TextAlign textAlign;
  final bool darkStyle;

  @override
  State<QuantityTextField> createState() => _QuantityTextFieldState();
}

class _QuantityTextFieldState extends State<QuantityTextField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '${widget.quantity}');
    _focusNode = FocusNode()
      ..addListener(() {
        if (_focusNode.hasFocus) {
          widget.onFocus?.call();
        }
      });
  }

  @override
  void didUpdateWidget(covariant QuantityTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.quantity != widget.quantity &&
        _controller.text != '${widget.quantity}') {
      _controller.text = '${widget.quantity}';
    }
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void _commitValue() {
    final parsed = int.tryParse(_controller.text);
    if (parsed != null && parsed > 0) {
      widget.onChanged(parsed);
    }
    FocusScope.of(context).unfocus();
  }

  void _handleChanged(String value) {
    final parsed = int.tryParse(value);
    if (parsed != null && parsed > 0) {
      widget.onChanged(parsed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textColor = widget.darkStyle ? Colors.white : null;
    final borderColor = widget.darkStyle
        ? AppTheme.scannerInputBorder
        : colorScheme.outlineVariant;

    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      textAlign: widget.textAlign,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.done,
      maxLines: 1,
      style: textColor == null
          ? null
          : Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: textColor,
                fontWeight: FontWeight.w600,
              ),
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.symmetric(
          horizontal: widget.showBorder ? 8 : 0,
          vertical: widget.showBorder ? 10 : 0,
        ),
        border: widget.showBorder
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: borderColor),
              )
            : InputBorder.none,
        enabledBorder: widget.showBorder
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: borderColor),
              )
            : InputBorder.none,
        focusedBorder: widget.showBorder
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(
                  color: widget.darkStyle
                      ? AppTheme.scannerMint
                      : colorScheme.primary,
                ),
              )
            : InputBorder.none,
      ),
      onChanged: _handleChanged,
      onSubmitted: (_) => _commitValue(),
      onEditingComplete: _commitValue,
    );
  }
}
