import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:iconsax_flutter/iconsax_flutter.dart';
import '../bookspage/books_screen.dart';
import '../uploadbook/upload_book_screen.dart';
import '../userprofile/userprofile_screen.dart';
import 'dashboard.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  // List of pages to show when a navigation item is selected
  final List<Widget> _pages = [
    Dashboard(),
    BooksScreen(),
    UploadBookScreen(),
    UserProfileScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF00224F),
      body: _pages[_selectedIndex], // This will show the selected page
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 16.0, left: 18.0, right: 18.0),
        child: Container(
          decoration: BoxDecoration(
            color:Colors.white,
            borderRadius: BorderRadius.circular(40),
            // boxShadow: [
            //   BoxShadow(
            //     color: Colors.grey.withOpacity(0.5),
            //     spreadRadius: 2,
            //     blurRadius: 5,
            //   ),
            // ],
          ),
          padding: EdgeInsets.all(4.0),
          child: GNav(
            rippleColor: Colors.blue,
            hoverColor: Color(0xFF00224F),
            haptic: false,
            tabBorderRadius: 40,
            // tabActiveBorder: Border.all(color: Color(0xFF00224F), width: 1),
            // tabBorder: Border.all(color: Colors.grey, width: 1),
            // tabShadow: [BoxShadow(color: Colors.grey.withOpacity(0.5), blurRadius: 8)],
            // curve: Curves.easeInCubic,
            curve: Curves.easeInOutQuad,

            duration: Duration(milliseconds: 250),
            gap: 8,
            color: Color(0xFF00224F),
            activeColor: Colors.white,
            iconSize: 24,
            tabBackgroundColor: Color(0xFF00224F),
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            onTabChange: _onItemTapped,
            selectedIndex: _selectedIndex,
            tabs: [
              GButton(
                icon: Iconsax.home_1_copy,
                // icon: LineIcons.home,

                text: 'Home',
              ),
              GButton(
                // icon: Iconsax.book_square,
                icon: Iconsax.book_1_copy,
                text: 'Books',
              ),
              GButton(
                icon: Iconsax.add_square_copy,
                text: 'Upload',
              ),
              GButton(
                icon: Iconsax.profile_2user_copy,
                text: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }
}