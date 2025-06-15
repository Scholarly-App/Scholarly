import 'package:flutter/material.dart';
import 'package:scholarly_app/Presentation_Tier/userprofile/edit_profile_screen.dart';
import 'package:scholarly_app/Presentation_Tier/userprofile/terms_conditions_screen.dart';
import 'package:scholarly_app/Presentation_Tier/userprofile/update_password_screen.dart';
import '../authentication/login_signup_screen.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:scholarly_app/Application_Tier/AuthenticationHandler.dart';
import 'package:scholarly_app/Data_Tier/UserModel.dart';
import 'package:scholarly_app/Application_Tier/UserManager.dart';

class UserProfileScreen extends StatefulWidget {
  @override
  _UserProfileScreenState createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  final TextEditingController NameController =
      TextEditingController(text: "....");
  final TextEditingController EmailController =
      TextEditingController(text: ".......");
  final TextEditingController TypeController =
      TextEditingController(text: "...");

  final authHandler = AuthenticationHandler();

  final UserManager _userManager = UserManager();
  UserModel? _user;

  Future<void> _confirmLogout() async {
    bool? shouldLogout = await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(20), // Optional: Rounded corners
          ),
          contentPadding: EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          title: Text("Logout", textAlign: TextAlign.center),
          content: SizedBox(
            width:
                MediaQuery.of(context).size.width * 0.7, // 70% of screen width
            child: Text(
              "Are you sure you want to logout?",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16),
            ),
          ),
          actionsAlignment: MainAxisAlignment.spaceEvenly,
          // Center the buttons
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context)
                    .pop(false); // Dismiss dialog, don't logout
              },
              child: Text("Cancel", style: TextStyle(color: Colors.grey[700])),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true); // Confirm logout
              },
              child: Text("Logout", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) {
      _logout(); // Call the actual logout function if confirmed
    }
  }

  // Logout function
  Future<void> _logout() async {
    try {
      bool logoutStatus = await authHandler.logoutUser();
      if (logoutStatus == true) {
        Fluttertoast.showToast(
          msg: 'User Logged out',
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 2,
          backgroundColor: Colors.green,
          textColor: Colors.white,
          fontSize: 14.0,
        );

        Navigator.pushReplacement(
          context,
          PageRouteBuilder(
            // transitionDuration: Duration(milliseconds: 1000), // Adjust transition time here
            transitionDuration: Duration(seconds: 1),
            // Adjust transition time here
            // pageBuilder: (context, animation, secondaryAnimation) => HomeScreen(),
            pageBuilder: (context, animation, secondaryAnimation) =>
                LoginSignupScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
              const begin = Offset(0.0, 1.0); // Start off-screen at the bottom
              // const begin = Offset(1.0, 0.0); // Start off-screen to the right
              const end = Offset.zero; // End at the normal position
              const curve = Curves.easeInOut; // Transition curve

              var tween =
                  Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
              var offsetAnimation = animation.drive(tween);

              return SlideTransition(position: offsetAnimation, child: child);
            },
          ),
        );
      }
    } catch (e) {
      debugPrint("Logout failed: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 540),
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.5), // Start further down for a more noticeable slide
      end: Offset(0, 0), // Slide to original position
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutQuad, // Very smooth curve
      // curve: Curves.easeOutCubic, // Very smooth curve
    ));

    // Start the animation when the screen opens
    _controller.forward();
  }

  Future<void> _loadUserData() async {

    UserModel? user = await _userManager.getUserData();
    if (mounted) {
      setState(() {
        _user = user;
        NameController.text = user!.name;
        EmailController.text = user!.email;
        TypeController.text = "Student";
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    NameController.dispose();
    EmailController.dispose();
    TypeController.dispose();
    super.dispose();
  }

  Widget _animatedBox({required Widget child}) {
    return AnimatedBuilder(
      animation: _slideAnimation,
      builder: (context, childWidget) {
        return SlideTransition(
          position: _slideAnimation,
          child: childWidget,
        );
      },
      child: child,
    );
  }

  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Color(0xFF00224F),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(screenHeight * 0.11),
        // Responsive height
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Color(0xFF00224F),
          elevation: 0,
          flexibleSpace: Padding(
            padding: EdgeInsets.only(bottom: screenHeight * 0.02),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    // onTap: () => Navigator.pop(context),
                    child: Container(
                      margin: EdgeInsets.only(left: screenWidth * 0.05),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      padding: EdgeInsets.all(screenWidth * 0.03),
                      child: const Icon(
                        Icons.chevron_left,
                        color: Color(0xFF00224F),
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: screenWidth * 0.1),
                    child: Text(
                      'User Profile',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'San Fransisco',
                        fontWeight: FontWeight.w500,
                        fontSize: screenWidth * 0.054, // Responsive font size
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Center(
            child: SingleChildScrollView(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Profile Section
                  _animatedBox(
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.04,
                          vertical: screenWidth * 0.08),
                      // padding: EdgeInsets.all(screenWidth * 0.08),
                      decoration: BoxDecoration(
                        color: Color(0xFFFFD233),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 10,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: Colors.white, width: 2.0),
                                ),
                                child: CircleAvatar(
                                  radius: screenWidth * 0.1, // Responsive size
                                  backgroundImage:
                                      AssetImage('assets/icon/app_icon.png'),
                                  backgroundColor: Colors.black,
                                ),
                              ),
                              SizedBox(width: screenWidth * 0.04),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      NameController.text,
                                      style: TextStyle(
                                        fontSize: screenWidth * 0.05,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.black,
                                      ),
                                      softWrap: true,
                                    ),
                                    Text(
                                      EmailController.text,
                                      style: TextStyle(
                                        fontSize: screenWidth * 0.037,
                                        color: Colors.black,
                                      ),
                                      softWrap: true,
                                    ),
                                    Text(
                                      TypeController.text,
                                      style: TextStyle(
                                        fontSize: screenWidth * 0.04,
                                        color: Colors.black,
                                      ),
                                      softWrap: true,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),

                  // User Settings Section
                  SizedBox(height: screenHeight * 0.02),
                  _buildSettingsContainer(context, 'User Settings', [
                    _buildSettingsOption(
                      context,
                      Icons.edit,
                      'Edit Profile',
                      Colors.blue,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => EditProfileScreen()),
                      ),
                    ),
                    _buildSettingsOption(
                      context,
                      Icons.article,
                      'Terms and Conditions',
                      Color(0xFFFFD233),
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => TermsConditionsScreen()),
                      ),
                    ),
                    _buildSettingsOption(
                      context,
                      Icons.password_rounded,
                      'Update Password',
                      Colors.grey,
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => UpdatePasswordScreen()),
                      ),
                    ),
                  ]),

                  // _buildSettingsContainer(context, 'User Settings', [
                  //   _buildSettingsOption(context, Icons.edit, 'Edit Profile',
                  //       Colors.blue, () {}),
                  //   _buildSettingsOption(context, Icons.article,
                  //       'Terms and Conditions', Color(0xFFFFD233), () {}),
                  //   _buildSettingsOption(context, Icons.password_rounded,
                  //       'Update Password', Colors.grey, () {}),
                  // ]),

                  // My Account Section
                  SizedBox(height: screenHeight * 0.02),
                  _buildSettingsContainer(context, 'My Account', [
                    SizedBox(height: screenHeight * 0.006),
                    GestureDetector(
                      onTap: _confirmLogout,
                      child: Padding(
                        padding: EdgeInsets.only(left: screenWidth * 0.04),
                        child: Text(
                          'Switch to another account',
                          style: TextStyle(
                            fontSize: screenWidth * 0.042,
                            color: Colors.blue,
                            fontWeight: FontWeight.bold,
                          ),
                          softWrap: true,
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.006),
                    GestureDetector(
                      onTap: _confirmLogout,
                      child: Padding(
                        padding: EdgeInsets.only(left: screenWidth * 0.04),
                        child: Text(
                          'Logout Account',
                          style: TextStyle(
                            fontSize: screenWidth * 0.042,
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                          softWrap: true,
                        ),
                      ),
                    ),
                  ]),

                  SizedBox(height: screenHeight * 0.02),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSettingsContainer(
      BuildContext context, String title, List<Widget> children) {
    final screenWidth = MediaQuery.of(context).size.width - 20;
    return _animatedBox(
      child: Container(
        width: screenWidth - screenWidth * 0.1,
        // Ensures all containers have the same width
        padding: EdgeInsets.all(screenWidth * 0.06),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: screenWidth * 0.045,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: screenWidth * 0.02),
            ...children,
          ],
        ),
      ),
    );
  }

  /// Builds a single settings option with an icon
  Widget _buildSettingsOption(BuildContext context, IconData icon, String text,
      Color iconColor, VoidCallback onTap) {
    final screenWidth = MediaQuery.of(context).size.width - 30;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        highlightColor: Colors.blue.withOpacity(0.2),
        splashColor: Colors.blue.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding:
              EdgeInsets.only(left: screenWidth * 0.04, top: 8.0, bottom: 8.0),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(screenWidth * 0.02),
                decoration: BoxDecoration(
                  color: iconColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                ),
              ),
              SizedBox(width: screenWidth * 0.04),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: screenWidth * 0.043,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                  softWrap: true,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
