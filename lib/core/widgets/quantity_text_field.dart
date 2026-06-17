import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class QuantityTextField extends StatefulWidget {
  const QuantityTextField({
    super.key,
    required this.quantity,
    required this.onChanged,
    this.onFocus,
    this.showBorder = false,
    this.textAlign = TextAlign.center,
  });

  final int quantity;
  final ValueChanged<int> onChanged;
  final VoidCallback? onFocus;
  final bool showBorder;
  final TextAlign textAlign;

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
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      textAlign: widget.textAlign,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.done,
      maxLines: 1,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        isDense: true,
        contentPadding: EdgeInsets.symmetric(
          horizontal: widget.showBorder ? 8 : 10,
          vertical: widget.showBorder ? 10 : 0,
        ),
        border: widget.showBorder
            ? OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              )
            : InputBorder.none,
      ),
      onChanged: _handleChanged,
      onSubmitted: (_) => _commitValue(),
      onEditingComplete: _commitValue,
    );
  }
}
