import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InspectionDataTable extends StatelessWidget {
  const InspectionDataTable({
    super.key,
    required this.rows,
    this.showResetColumn = false,
    this.onReset,
    this.onQuantityChanged,
  });

  final List<InspectionTableRow> rows;
  final bool showResetColumn;
  final ValueChanged<String>? onReset;
  final void Function(String id, int quantity)? onQuantityChanged;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (rows.isEmpty) {
      return const SizedBox.shrink();
    }

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
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.12),
            ),
            children: [
              if (showResetColumn)
                _HeaderCell(
                  label: 'Reset',
                  colorScheme: colorScheme,
                ),
              _HeaderCell(
                label: 'Code',
                colorScheme: colorScheme,
              ),
              _HeaderCell(
                label: 'Quantity',
                colorScheme: colorScheme,
                align: TextAlign.center,
              ),
            ],
          ),
          for (final row in rows)
            TableRow(
              decoration: BoxDecoration(
                color: Colors.white,
              ),
              children: [
                if (showResetColumn)
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: FilledButton.tonal(
                      onPressed:
                          onReset == null ? null : () => onReset!(row.id),
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
                    row.code,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: onQuantityChanged == null
                      ? Center(
                          child: Text(
                            '${row.quantity}',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        )
                      : _QuantityField(
                          quantity: row.quantity,
                          onChanged: (quantity) =>
                              onQuantityChanged!(row.id, quantity),
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
    required this.colorScheme,
    this.align = TextAlign.start,
  });

  final String label;
  final ColorScheme colorScheme;
  final TextAlign align;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      child: Text(
        label,
        textAlign: align,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}

class _QuantityField extends StatefulWidget {
  const _QuantityField({
    required this.quantity,
    required this.onChanged,
  });

  final int quantity;
  final ValueChanged<int> onChanged;

  @override
  State<_QuantityField> createState() => _QuantityFieldState();
}

class _QuantityFieldState extends State<_QuantityField> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '${widget.quantity}');
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
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
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
      onSubmitted: (value) {
        final parsed = int.tryParse(value);
        if (parsed != null && parsed > 0) {
          widget.onChanged(parsed);
        }
      },
      onEditingComplete: () {
        final parsed = int.tryParse(_controller.text);
        if (parsed != null && parsed > 0) {
          widget.onChanged(parsed);
        }
      },
    );
  }
}
