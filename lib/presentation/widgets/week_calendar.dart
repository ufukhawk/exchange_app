import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_sizes.dart';
import '../../core/utils/date_utils.dart';

class WeekCalendar extends StatelessWidget {
  const WeekCalendar({
    super.key,
    required this.selectedDate,
    required this.onDateSelected,
  });
  final DateTime selectedDate;
  final void Function(DateTime) onDateSelected;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final String locale = l10n.localeName; // 'tr' veya 'en'
    final List<DateTime> weekDays = AppDateUtils.getWeekDays(selectedDate);

    return Container(
      height: AppContainerSize.weekCalendarHeight,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: weekDays.length,
        itemBuilder: (context, index) {
          final DateTime date = weekDays[index];
          final bool isSelected = date.day == selectedDate.day &&
              date.month == selectedDate.month &&
              date.year == selectedDate.year;
          return GestureDetector(
            onTap: () => onDateSelected(date),
            child: Container(
              width: AppContainerSize.weekCalendarItemWidth,
              margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
              decoration: BoxDecoration(
                color: isSelected
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat.E(locale)
                        .format(date)
                        .substring(0, 3)
                        .toUpperCase(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isSelected
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                  ),
                  AppSpacing.xs.heightBox,
                  Text(
                    date.day.toString(),
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isSelected
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
