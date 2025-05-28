import 'package:flutter/material.dart';

class LoadingStateWidget extends StatelessWidget {
  final bool isLoading;
  final String? error;
  final Widget child;
  final VoidCallback? onRetry;

  const LoadingStateWidget({
    Key? key,
    required this.isLoading,
    this.error,
    required this.child,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            if (onRetry != null) ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: onRetry,
                child: const Text('Reintentar'),
              ),
            ],
          ],
        ),
      );
    }

    return child;
  }
}
