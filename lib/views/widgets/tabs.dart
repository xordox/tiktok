import 'package:flutter/material.dart';

class Tabs extends StatefulWidget {
  const Tabs({super.key});

  @override
  State<Tabs> createState() => _TabsExampleState();
}

class _TabsExampleState extends State<Tabs> {
  int _selectedIndex = 1;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: () {
            setState(() {
              _selectedIndex = 0;
            });
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Following',
                style: TextStyle(
                  color: _selectedIndex == 0 ? Colors.white : Colors.grey,
                  fontSize: 16,
                  fontWeight:
                      _selectedIndex == 0 ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              const SizedBox(height: 4),
              if (_selectedIndex == 0)
                Container(
                  height: 2,
                  width: 30,
                  color: Colors.white,
                ),
            ],
          ),
        ),
        const SizedBox(width: 20),
        GestureDetector(
          onTap: () {
            setState(() {
              _selectedIndex = 1;
            });
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'For You',
                style: TextStyle(
                  color: _selectedIndex == 1 ? Colors.white : Colors.grey,
                  fontSize: 16,
                  fontWeight:
                      _selectedIndex == 1 ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              const SizedBox(height: 4),
              if (_selectedIndex == 1)
                Container(
                  height: 2,
                  width: 30,
                  color: Colors.white,
                ),
            ],
          ),
        ),
      ],
    );
  }
}
