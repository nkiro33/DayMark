import 'package:flutter/material.dart';

class ActivitySearchBar extends StatelessWidget {
  const ActivitySearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    return SearchBar(
      controller: controller,
      hintText: 'Search activities',
      leading: const Icon(Icons.search),
      onChanged: onChanged,
    );
  }
}
