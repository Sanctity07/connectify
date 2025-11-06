import 'package:flutter/material.dart';
import 'package:stylish_bottom_bar/stylish_bottom_bar.dart';
import '../view/feed/feed_view.dart';
import '../view/feed/add_post_view.dart';
import '../view/marketplace/marketplace_view.dart';
import '../view/chat/chat_list_view.dart';
import '../view/profile/profile_view.dart';

class BottomNavigation extends StatefulWidget {
  const BottomNavigation({super.key});

  @override
  State<BottomNavigation> createState() => _BottomNavigationState();
}

class _BottomNavigationState extends State<BottomNavigation> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    _pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        onPageChanged: (index) => setState(() => _selectedIndex = index),
        children: const [
          FeedView(),
          MarketplaceView(),
          AddPostView(),
          ChatListView(),
          ProfileView(),
        ],
      ),

      bottomNavigationBar: StylishBottomBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        backgroundColor: const Color.fromARGB(255, 51, 33, 243),
        elevation: 8,
        option: BubbleBarOptions(
          barStyle: BubbleBarStyle.horizontal,
          opacity: 0.2,
          padding: const EdgeInsets.symmetric(vertical: 4),
          borderRadius: BorderRadius.circular(10),
        ),
        items: [
          BottomBarItem(
            icon: const Icon(Icons.home_outlined),
            selectedIcon: const Icon(Icons.home),
            title: const Text('Feed', style: TextStyle(fontSize: 13)),
            selectedColor: Colors.white,
            unSelectedColor: Colors.white70,
          ),
          BottomBarItem(
            icon: const Icon(Icons.store_outlined),
            selectedIcon: const Icon(Icons.store),
            title: const Text('Market', style: TextStyle(fontSize: 13)),
            selectedColor: Colors.white,
            unSelectedColor: Colors.white70,
          ),
          BottomBarItem(
            icon: const Icon(Icons.add_circle_outline),
            selectedIcon: const Icon(Icons.add_circle),
            title: const Text('Post', style: TextStyle(fontSize: 13)),
            selectedColor: Colors.white,
            unSelectedColor: Colors.white70,
          ),
          BottomBarItem(
            icon: const Icon(Icons.chat_bubble_outline),
            selectedIcon: const Icon(Icons.chat),
            title: const Text('Chat', style: TextStyle(fontSize: 13)),
            selectedColor: Colors.white,
            unSelectedColor: Colors.white70,
          ),
          BottomBarItem(
            icon: const Icon(Icons.person_outline),
            selectedIcon: const Icon(Icons.person),
            title: const Text('Profile', style: TextStyle(fontSize: 13)),
            selectedColor: Colors.white,
            unSelectedColor: Colors.white70,
          ),
        ],
      ),
    );
  }
}
