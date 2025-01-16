import 'package:flutter/material.dart';

class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        title: const TextField(
          decoration: InputDecoration(
            hintText: '3 missed calls',
            border: InputBorder.none,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text(
              'Search',
              style: TextStyle(color: Colors.red, fontSize: 16),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'You may like',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.refresh, size: 16, color: Colors.grey),
                  label: const Text(
                    'Refresh',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView(
                children: const [
                  SuggestionItem(
                    title: '3 missed calls',
                    isHighlighted: true,
                  ),
                  SuggestionItem(
                    title: '16 Missed Calls',
                    isHighlighted: true,
                  ),
                  SuggestionItem(title: 'xxl bed'),
                  SuggestionItem(title: '16 missed calls'),
                  SuggestionItem(
                    title: 'd letter signature',
                    subtitle: 'Just watched',
                  ),
                  SuggestionItem(
                    title: 'R letter signature',
                    subtitle: 'Just watched',
                  ),
                  SuggestionItem(
                    title: 'j letter signature',
                    subtitle: 'Just watched',
                  ),
                  SuggestionItem(title: '1000 million followers on tiktok'),
                  SuggestionItem(title: 'viral tiktok song'),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: const Padding(
        padding: EdgeInsets.all(16),
        child: Text(
          'Help us improve | Learn more',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey),
        ),
      ),
    );
  }
}

class SuggestionItem extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool isHighlighted;

  const SuggestionItem({
    super.key,
    required this.title,
    this.subtitle,
    this.isHighlighted = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            Icons.circle,
            size: 8,
            color: isHighlighted ? Colors.red : Colors.grey,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight:
                        isHighlighted ? FontWeight.bold : FontWeight.normal,
                    color: isHighlighted ? Colors.red : Colors.black,
                  ),
                ),
                if (subtitle != null)
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
