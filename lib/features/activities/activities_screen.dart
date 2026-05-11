import 'package:flutter/material.dart';

import 'widgets/activity_card.dart';

class ActivitiesScreen extends StatelessWidget {
  const ActivitiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Activities')),
      body: const Padding(
        padding: EdgeInsets.all(20),
        child: ActivityCard(
          icon: Icons.list_alt,
          title: 'Add something when you are ready.',
          subtitle:
              'Reusable activity management will be added in a later step.',
        ),
      ),
    );
  }
}
