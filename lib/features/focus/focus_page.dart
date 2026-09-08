import 'package:flutter/material.dart';

import '../../widgets/placeholder_page.dart';

class FocusPage extends StatelessWidget {
  const FocusPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderPage(
      icon: Icons.timer,
      title: 'تمرکز',
      subtitle: 'پومودورو، جلسات تمرکز و عادت‌ها در این بخش قرار می‌گیرند.',
    );
  }
}
