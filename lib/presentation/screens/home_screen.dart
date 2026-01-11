import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_constants.dart';
import '../../core/constants/app_sizes.dart';
import '../../core/state/app_state.dart';
import '../../core/state_management/state_manager.dart';
import '../../domain/entities/exchange_rate_entity.dart';
import '../widgets/app_icon.dart';
import '../widgets/converter_section.dart';
import '../widgets/currency_card.dart';
import '../widgets/date_selector.dart';
import '../widgets/keyboard_toolbar.dart';
import '../widgets/no_internet_banner.dart';
import '../widgets/week_calendar.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    super.key,
    required this.stateManager,
    required this.state,
  });
  final StateManager stateManager;
  final AppState state;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final ValueNotifier<bool> _isKeyboardVisible = ValueNotifier<bool>(false);
  final GlobalKey<ConverterSectionState> _converterSectionKey =
      GlobalKey<ConverterSectionState>();

  @override
  void dispose() {
    _isKeyboardVisible.dispose();
    super.dispose();
  }

  void _handleKeyboardDone() {
    // ConverterSection'daki handleConvert'i çağır
    _converterSectionKey.currentState?.handleConvert();
    // Klavyeyi kapat
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            AppIcon(
              iconData: Icons.currency_exchange,
              size: AppIconSize.xl,
              radius: AppRadius.xl,
              backgroundColor: Theme.of(context).colorScheme.onPrimaryContainer,
              iconColor: Theme.of(context).colorScheme.primaryContainer,
            ),
            AppSpacing.sm.widthBox,
            Text(
              l10n.appTitle,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => context.push(RouteConstants.settings),
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              if (!widget.state.isConnected)
                NoInternetBanner(
                  message: l10n.noInternetConnection,
                  onRetry: () => widget.stateManager
                      .loadExchangeRates(widget.state.selectedDate),
                ),
              Expanded(
                child: _buildContent(context, l10n),
              ),
            ],
          ),
          // Klavye toolbar'ı
          ValueListenableBuilder<bool>(
            valueListenable: _isKeyboardVisible,
            builder: (context, isVisible, _) {
              if (!isVisible) {
                return const SizedBox.shrink();
              }
              return Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: KeyboardToolbar(
                  onDone: _handleKeyboardDone,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context, AppLocalizations l10n) {
    final bool hasError = widget.state.errorMessage.isNotEmpty;
    final ExchangeRateEntity? exchangeRate = widget.state.currentExchangeRate;
    final bool isLoading = widget.state.isLoading;

    return ListView(
      children: [
        // Tarih seçiciler HER ZAMAN görünür (loading sırasında bile)
        DateSelector(
          selectedDate: widget.state.selectedDate,
          onDateChanged: (date) => widget.stateManager.loadExchangeRates(date),
          selectDateLabel: l10n.selectDate,
        ),
        WeekCalendar(
          selectedDate: widget.state.selectedDate,
          onDateSelected: (date) => widget.stateManager.loadExchangeRates(date),
        ),

        // Loading göstergesi (tarih seçicilerin altında)
        if (isLoading) _buildLoadingIndicator(context, l10n),

        // Hata mesajı varsa banner göster
        if (hasError && !isLoading) _buildErrorBanner(context, l10n),

        // Veri yoksa ve loading/hata da yoksa placeholder göster
        if (exchangeRate == null && !hasError && !isLoading)
          _buildNoDataPlaceholder(context, l10n)
        else if (exchangeRate != null && !isLoading)
          ..._buildExchangeRateContent(context, l10n, exchangeRate),
      ],
    );
  }

  Widget _buildLoadingIndicator(BuildContext context, AppLocalizations l10n) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            l10n.loadingExchangeRates,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner(BuildContext context, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: Theme.of(context).colorScheme.error.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Theme.of(context).colorScheme.onErrorContainer,
                size: AppIconSize.lg,
              ),
              AppSpacing.md.widthBox,
              Expanded(
                child: Text(
                  l10n.error,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onErrorContainer,
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ),
            ],
          ),
          AppSpacing.sm.heightBox,
          Text(
            widget.state.errorMessage,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onErrorContainer,
                ),
          ),
          AppSpacing.md.heightBox,
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: () => widget.stateManager
                  .loadExchangeRates(widget.state.selectedDate),
              icon: const Icon(Icons.refresh),
              label: Text(l10n.retry),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataPlaceholder(BuildContext context, AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.all(AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.xxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: AppIconSize.huge,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          AppSpacing.lg.heightBox,
          Text(
            l10n.noDataAvailable,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildExchangeRateContent(
    BuildContext context,
    AppLocalizations l10n,
    ExchangeRateEntity exchangeRate,
  ) {
    return [
      AppSpacing.sm.heightBox,
      ConverterSection(
        key: _converterSectionKey,
        title: l10n.fastExchange,
        hint: l10n.enterAmount,
        onConvert: (amount) => widget.stateManager.convertCurrency(amount),
        convertedAmounts: widget.state.convertedAmounts,
        onFocusChanged: (isFocused) {
          _isKeyboardVisible.value = isFocused;
        },
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              l10n.rates,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            Container(
              padding: const EdgeInsets.all(AppSpacing.xs),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Text(
                '${PublicationConstants.publicationTime} ${l10n.lastUpdate}',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ),
          ],
        ),
      ),
      ...exchangeRate.currencies.map((currency) {
        return CurrencyCard(
          currency: currency,
          buyingLabel: l10n.buyingRate,
          sellingLabel: l10n.sellingRate,
          convertedAmount: widget.state.convertedAmounts[currency.currencyCode],
        );
      }),
      AppSpacing.lg.heightBox,
    ];
  }
}
