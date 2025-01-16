import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tiktok/controllers/auth_controller.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authController = ref.read(authControllerProvider.notifier);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Center(
          child: Text(
            authController.currentUser?.name ?? "",
            style: const TextStyle(color: Colors.black),
          ),
        ),
        actions: const [
          Icon(Icons.menu, color: Colors.black),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 16),
            CircleAvatar(
              radius: 40,
              backgroundColor: Colors.blue,
              child: CircleAvatar(
                radius: 38,
                backgroundImage: authController.currentUser?.profileImage !=
                            null &&
                        authController.currentUser!.profileImage.isNotEmpty
                    ? NetworkImage(authController.currentUser!.profileImage)
                    : const AssetImage('assets/tiktok.jpg') as ImageProvider,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              authController.currentUser?.email ?? "",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Text('31', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('Following', style: TextStyle(color: Colors.grey)),
                  ],
                ),
                SizedBox(width: 24),
                Column(
                  children: [
                    Text('11', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('Followers', style: TextStyle(color: Colors.grey)),
                  ],
                ),
                SizedBox(width: 24),
                Column(
                  children: [
                    Text('84', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('Likes', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: null,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.grey.shade200,
                    disabledForegroundColor: Colors.black45,
                    disabledBackgroundColor: Colors.grey.shade100,
                  ),
                  child: const Text('Edit Profile'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: null,
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.grey.shade200,
                    disabledForegroundColor: Colors.black45,
                    disabledBackgroundColor: Colors.grey.shade100,
                  ),
                  child: const Text('Share Profile'),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    authController.logoutUser(context);
                  },
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.black,
                    backgroundColor: Colors.grey.shade200,
                  ),
                  child: const Icon(Icons.logout),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text('+ Add bio', style: TextStyle(color: Colors.blue)),
            const SizedBox(height: 16),
            const Divider(),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 6, // Adjust for the number of videos
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 9 / 16,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Center(
                        child: Text(
                          'Video $index',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const Positioned(
                      bottom: 8,
                      left: 8,
                      child: Row(
                        children: [
                          Icon(Icons.play_arrow, color: Colors.white, size: 16),
                          Text(
                            '1,448',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
