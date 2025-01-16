import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tiktok/constants.dart';
import 'package:tiktok/views/widgets/custom_icon.dart';

// State provider for managing the current page index
final pageIndexProvider = StateProvider<int>((ref) => 0);

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Access the current page index from the provider
    final pageIndex = ref.watch(pageIndexProvider);

    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        onTap: (index) {
          // Update the page index in the provider
          ref.read(pageIndexProvider.notifier).state = index;
        },
        backgroundColor: Colors.transparent,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white,
        currentIndex: pageIndex,
        items: [
          BottomNavigationBarItem(
            icon: Icon(
              pageIndex == 0 ? Icons.home : Icons.home_outlined,
              size: 30,
            ),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              pageIndex == 1 ? Icons.people : Icons.people_alt_outlined,
            ),
            label: "Friends",
          ),
          const BottomNavigationBarItem(
            icon: CustomIcon(),
            label: "",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              pageIndex == 3 ? Icons.message : Icons.message_outlined,
              size: 30,
            ),
            label: "Messages",
          ),
          BottomNavigationBarItem(
            icon: Icon(
              pageIndex == 4 ? Icons.person : Icons.person_outline,
              size: 30,
            ),
            label: "Profile",
          ),
        ],
      ),
      body: pages[pageIndex],
    );
  }
}
