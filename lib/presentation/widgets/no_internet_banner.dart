import 'package:flutter/material.dart';

class NoInternetBanner extends StatelessWidget {
  const NoInternetBanner({
    super.key,
    required this.message,
    this.onRetry,
  });
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return MaterialBanner(
      content: Text(message),
      backgroundColor: Theme.of(context).colorScheme.errorContainer,
      leading: Icon(
        Icons.wifi_off,
        color: Theme.of(context).colorScheme.onErrorContainer,
      ),
      actions: [
        if (onRetry != null)
          TextButton(
            onPressed: onRetry,
            child: const Text('Retry'),
          ),
      ],
    );
  }
}
