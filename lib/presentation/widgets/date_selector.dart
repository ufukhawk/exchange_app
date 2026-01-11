import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/utils/date_formatter.dart';

class DateSelector extends StatelessWidget {
  const DateSelector({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
    required this.selectDateLabel,
  });
  final DateTime selectedDate;
  final void Function(DateTime) onDateChanged;
  final String selectDateLabel;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Container(
      margin: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                selectDateLabel,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              AppSpacing.xs.heightBox,
              Text(
                DateFormatter.formatToDisplay(selectedDate),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
              ),
            ],
          ),
          ElevatedButton.icon(
            onPressed: () => _showDatePicker(context),
            icon: const Icon(Icons.calendar_month, size: AppIconSize.sm),
            label: Text(
              l10n.changeDate,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
            style: ElevatedButton.styleFrom(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                side: BorderSide(
                  color: Theme.of(context).colorScheme.surfaceVariant,
                ),
              ),
              backgroundColor: Theme.of(context).colorScheme.surface,
              iconColor: Theme.of(context).colorScheme.primaryContainer,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showDatePicker(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != selectedDate) {
      onDateChanged(picked);
    }
  }
}
