import 'package:flutter/material.dart';

/// Simulates auth API latency until PocketBase is integrated.
Future<void> runMockAuth(
  BuildContext context, {
  required VoidCallback onComplete,
}) async {
  await Future.delayed(const Duration(seconds: 2));
  if (!context.mounted) return;
  onComplete();
}
