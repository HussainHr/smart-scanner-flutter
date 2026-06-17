import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InspectionDataTable extends StatelessWidget {
  const InspectionDataTable({
    super.key,
    required this.rows,
    this.showResetColumn = false,
    this.onReset,
    this.onQuantityChanged,
    this.onRowSelected,
    this.previewStyle = false,
  });

  final List<InspectionTableRow> rows;
  final bool showResetColumn;
  final ValueChanged<String>? onReset;
  final void Function(String id, int quantity)? onQuantityChanged;
  final ValueChanged<String>? onRowSelected;
  final bool previewStyle;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (rows.isEmpty) {
      return const SizedBox.shrink();
    }

    final headerColor = previewStyle
        ? const Color(0xFF0E7490)
        : colorScheme.primary.withValues(alpha: 0.12);
    final headerTextColor =
        previewStyle ? Colors.white : colorScheme.primary;

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Table(
        border: TableBorder.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
        columnWidths: showResetColumn
            ? const {
                0: FixedColumnWidth(72),
                1: FlexColumnWidth(),
                2: FixedColumnWidth(88),
              }
            : const {
                0: FlexColumnWidth(),
                1: FixedColumnWidth(88),
              },
        children: [
          TableRow(
            decoration: BoxDecoration(color: headerColor),
            children: [
              if (showResetColumn)
                _HeaderCell(
                  label: 'Reset',
                  textColor: headerTextColor,
                  previewStyle: previewStyle,
                ),
              _HeaderCell(
                label: 'Code',
                textColor: headerTextColor,
                previewStyle: previewStyle,
              ),
              _HeaderCell(
                label: 'Quantity',
                textColor: headerTextColor,
                previewStyle: previewStyle,
                align: TextAlign.center,
              ),
            ],
          ),
          for (var index = 0; index < rows.length; index++)
            TableRow(
              decoration: BoxDecoration(
                color: previewStyle && index.isEven
                    ? const Color(0xFFF1F5F9)
                    : Colors.white,
              ),
              children: [
                if (showResetColumn)
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: FilledButton.tonal(
                      onPressed:
                          onReset == null ? null : () => onReset!(rows[index].id),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(0, 34),
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        textStyle: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      child: const Text('Reset'),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                  child: Text(
                    rows[index].code,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: previewStyle ? 13 : null,
                        ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: onQuantityChanged == null
                      ? Center(
                          child: Text(
                            '${rows[index].quantity}',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        )
                      : _QuantityField(
                          quantity: rows[index].quantity,
                          onChanged: (quantity) =>
                              onQuantityChanged!(rows[index].id, quantity),
                          onFocus: onRowSelected == null
                              ? null
                              : () => onRowSelected!(rows[index].code),
                        ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class InspectionTableRow {
  const InspectionTableRow({
    required this.id,
    required this.code,
    required this.quantity,
  });

  final String id;
  final String code;
  final int quantity;
}

class _HeaderCell extends StatelessWidget {
  const _HeaderCell({
    required this.label,
    required this.textColor,
    this.previewStyle = false,
    this.align = TextAlign.start,
  });

  final String label;
  final Color textColor;
  final bool previewStyle;
  final TextAlign align;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: 12,
        vertical: previewStyle ? 14 : 12,
      ),
      child: Text(
        label,
        textAlign: align,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w700,
              fontSize: previewStyle ? 13 : null,
            ),
      ),
    );
  }
}

class _QuantityField extends StatefulWidget {
  const _QuantityField({
    required this.quantity,
    required this.onChanged,
    this.onFocus,
  });

  final int quantity;
  final ValueChanged<int> onChanged;
  final VoidCallback? onFocus;

  @override
  State<_QuantityField> createState() => _QuantityFieldState();
}

class _QuantityFieldState extends State<_QuantityField> {
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
  void didUpdateWidget(covariant _QuantityField oldWidget) {
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

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      textAlign: TextAlign.center,
      keyboardType: TextInputType.number,
      textInputAction: TextInputAction.done,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onChanged: (value) {
        final parsed = int.tryParse(value);
        if (parsed != null && parsed > 0) {
          widget.onChanged(parsed);
        }
      },
      onSubmitted: (_) => _commitValue(),
      onEditingComplete: _commitValue,
    );
  }
}
