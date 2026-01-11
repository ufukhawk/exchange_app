import 'package:flutter/material.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/utils/turkish_currency_input_formatter.dart';

class ConverterSection extends StatefulWidget {
  const ConverterSection({
    super.key,
    required this.title,
    required this.hint,
    required this.onConvert,
    required this.convertedAmounts,
    this.onFocusChanged,
    this.onSubmit,
  });
  final String title;
  final String hint;
  final void Function(double) onConvert;
  final Map<String, double> convertedAmounts;
  final ValueChanged<bool>? onFocusChanged;
  final VoidCallback? onSubmit;

  @override
  State<ConverterSection> createState() => ConverterSectionState();
}

class ConverterSectionState extends State<ConverterSection> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onFocusChange() {
    widget.onFocusChanged?.call(_focusNode.hasFocus);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          AppSpacing.md.heightBox,
          TextField(
            controller: _controller,
            focusNode: _focusNode,
            keyboardType: TextInputType.number,
            inputFormatters: [
              TurkishCurrencyInputFormatter(),
            ],
            decoration: InputDecoration(
              hintText: widget.hint,
              prefixIcon: const Icon(Icons.currency_lira),
              suffixIcon: IconButton(
                icon: const Icon(Icons.clear),
                onPressed: _handleClear,
              ),
            ),
            onSubmitted: (_) => handleConvert(),
          ),
        ],
      ),
    );
  }

  void handleConvert() {
    final String text = _controller.text;
    if (text.isNotEmpty) {
      // TR formatını parse et: "1.000,50" -> 1000.50
      final String normalized = text.replaceAll('.', '').replaceAll(',', '.');
      final double? amount = double.tryParse(normalized);
      if (amount != null && amount > 0) {
        widget.onConvert(amount);
      } else {
        widget.onConvert(0);
      }
    } else {
      widget.onConvert(0);
    }
  }

  void _handleClear() {
    widget.onConvert(0);
    _controller.clear();
  }
}
