import 'package:flutter/material.dart';
import 'tab_page_header.dart';

/// Standard layout for main-shell tabs: fixed title + scrollable body.
class TabPageScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final EdgeInsetsGeometry? bodyPadding;

  const TabPageScaffold({
    super.key,
    required this.title,
    required this.body,
    this.bodyPadding,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TabPageHeader(title: title),
        Expanded(
          child: bodyPadding != null
              ? Padding(padding: bodyPadding!, child: body)
              : body,
        ),
      ],
    );
  }
}
