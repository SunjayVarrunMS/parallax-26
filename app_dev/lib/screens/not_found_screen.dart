// shown when the address does not match any screen

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme.dart';
import '../widgets/buttons.dart';
import '../widgets/page_heading.dart';
import '../widgets/page_shell.dart';
import '../widgets/panels.dart';

class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final c = PlxColors.of(context);
    final message = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Let's get you back.", style: monoStyle(size: 17.6, weight: FontWeight.w800, color: c.ink)),
        const SizedBox(height: 6),
        Text(
          'The page may have moved, or the address might have a typo.',
          style: monoStyle(size: 13.6, color: c.muted),
        ),
      ],
    );
    final mark = Text('>_', style: displayStyle(size: 32, color: c.accent, height: 1));
    final button = PlxButton(
      label: 'Back to base',
      kind: ButtonKind.outline,
      onPressed: () => context.go('/'),
    );

    return PageShell(
      currentPath: '',
      child: PageContainer(
        child: Padding(
          padding: const EdgeInsets.only(bottom: 80),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const PageHeading(
                eyebrow: '>> PARALLAX / 404',
                title: 'Signal lost',
                description: 'This page is not on the programme.',
              ),
              const SizedBox(height: 40),
              PlxPanel(
                barLeft: '>STATUS',
                barRight: '[STANDBY]',
                padding: const EdgeInsets.all(24),
                child: Wrap(
                  spacing: 24,
                  runSpacing: 16,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [mark, ConstrainedBox(constraints: const BoxConstraints(maxWidth: 520), child: message), button],
                ),
              ),
              const SizedBox(height: 120),
            ],
          ),
        ),
      ),
    );
  }
}
