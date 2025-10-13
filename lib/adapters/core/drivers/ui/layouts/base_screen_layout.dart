import 'package:flutter/material.dart';

class BaseScreenLayout extends StatelessWidget {
  final Widget child;
  final String title;
  final Widget? floatingActionButton;
  const BaseScreenLayout({super.key, required this.child, required this.title, this.floatingActionButton});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            Text(
              title,
              style: textTheme.displayMedium,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: child,
            ),
          ],
        ),
      ),
      floatingActionButton: floatingActionButton,
    );
  }
}
