import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class UpdatePasswordScreen extends StatefulWidget {
  @override
  _UpdatePasswordScreenState createState() => _UpdatePasswordScreenState();
}

class _UpdatePasswordScreenState extends State<UpdatePasswordScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  bool _isPasswordVisible_1 = false;
  bool _isPasswordVisible_2 = false;
  bool _isPasswordVisible_3 = false;

  // Controllers for login fields
  final TextEditingController EmailController = TextEditingController();
  final TextEditingController ConfirmEmailController = TextEditingController();
  final TextEditingController OldPasswordController = TextEditingController();
  final TextEditingController NewPasswordController = TextEditingController();
  final TextEditingController ConfirmNewPasswordController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.1), // Start further down for a more noticeable slide
      end: Offset(0, 0), // Slide to original position
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutQuad, // Very smooth curve
      // curve: Curves.easeOutCubic, // Very smooth curve
    ));

    // Start the animation when the screen opens
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    EmailController.dispose();
    ConfirmEmailController.dispose();
    OldPasswordController.dispose();
    NewPasswordController.dispose();
    ConfirmNewPasswordController.dispose();
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
    return Scaffold(
      backgroundColor: Color(0xFF00224F),
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100.0), // Adjust the height as needed
        child: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Color(0xFF00224F), // Custom background color
          elevation: 0, // Remove the shadow
          flexibleSpace: Padding(
            padding: EdgeInsets.only(bottom: 20.0),
            // Bottom padding for the row
            child: Align(
              alignment: Alignment.bottomCenter,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Custom back button
                  GestureDetector(
                    onTap: () {
                      Navigator.pop(context); // Navigate back on tap
                    },
                    child: Container(
                      margin: EdgeInsets.only(left: 26.0),
                      // Left margin for spacing
                      decoration: BoxDecoration(
                        color: Colors.white, // Button background color
                        borderRadius:
                            BorderRadius.circular(12.0), // Rounded corners
                      ),
                      padding: EdgeInsets.symmetric(
                          horizontal: 12.0, vertical: 12.0),
                      child: Icon(
                        Icons.chevron_left, // Back arrow icon
                        color: Color(0xFF00224F), // Icon color
                      ),
                    ),
                  ),
                  // Profile text on the far right
                  Padding(
                    padding: EdgeInsets.only(right: 46.0),
                    // Right margin for spacing
                    child: Text(
                      'Update Password',
                      style: TextStyle(
                        color: Colors.white, // Text color
                        fontFamily: 'San Fransisco',
                        fontWeight: FontWeight.w500,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.only(left: 20.0, right: 20.0, top: 8.0),
            // Apply padding equally on both sides
            child: Container(
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
              width: (MediaQuery.of(context).size.width - 56),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(
                        left: 20.0, right: 20.0, top: 24.0, bottom: 28.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Update Password',
                          style: TextStyle(
                            color: Color(0xFF00224F), // Text color
                            fontFamily: 'San Fransisco',
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(left: 4.0, top: 10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              TextField(
                                controller: EmailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  labelText: 'Enter your email',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 12),
                                ),
                              ),
                              SizedBox(height: 18),
                              TextField(
                                controller: ConfirmEmailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  labelText: 'Re-enter your email',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 12),
                                ),
                              ),
                              SizedBox(height: 18),
                              TextField(
                                controller: OldPasswordController,
                                obscureText: !_isPasswordVisible_1,
                                // Toggle visibility based on state
                                decoration: InputDecoration(
                                  labelText: 'Enter Old Password',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 12),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isPasswordVisible_1
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isPasswordVisible_1 =
                                            !_isPasswordVisible_1;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(height: 18),
                              TextField(
                                controller: NewPasswordController,
                                obscureText: !_isPasswordVisible_2,
                                // Toggle visibility based on state
                                decoration: InputDecoration(
                                  labelText: 'Enter New Password',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 12),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isPasswordVisible_2
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isPasswordVisible_2 =
                                            !_isPasswordVisible_2;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(height: 18),
                              TextField(
                                controller: ConfirmNewPasswordController,
                                obscureText: !_isPasswordVisible_3,
                                // Toggle visibility based on state
                                decoration: InputDecoration(
                                  labelText: 'Re-enter New Password',
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 12),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isPasswordVisible_3
                                          ? Icons.visibility
                                          : Icons.visibility_off,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isPasswordVisible_3 =
                                            !_isPasswordVisible_3;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(height: 18),
                              SizedBox(
                                width: double.infinity,
                                // Ensures the button takes the full width
                                child: ElevatedButton(
                                  onPressed: () {
                                    String email = EmailController.text.trim();
                                    String Cofirmemail =
                                        ConfirmEmailController.text.trim();
                                    String OldPassword =
                                        OldPasswordController.text.trim();
                                    String NewPassword =
                                        NewPasswordController.text.trim();
                                    String ConfirmNewPassword =
                                        ConfirmNewPasswordController.text
                                            .trim();

                                    if (email.isEmpty ||
                                        Cofirmemail.isEmpty ||
                                        OldPassword.isEmpty ||
                                        NewPassword.isEmpty ||
                                        ConfirmNewPassword.isEmpty) {
                                      Fluttertoast.showToast(
                                        msg: "Please enter all fields",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        timeInSecForIosWeb: 1,
                                        backgroundColor: Colors.red,
                                        textColor: Colors.white,
                                        fontSize: 14.0,
                                      );
                                    } else if (email != Cofirmemail) {
                                      Fluttertoast.showToast(
                                        msg: "Emails do not match",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        timeInSecForIosWeb: 1,
                                        backgroundColor: Colors.red,
                                        textColor: Colors.white,
                                        fontSize: 14.0,
                                      );
                                    } else if (NewPassword !=
                                        ConfirmNewPassword) {
                                      Fluttertoast.showToast(
                                        msg: "Passwords do not match",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        timeInSecForIosWeb: 1,
                                        backgroundColor: Colors.red,
                                        textColor: Colors.white,
                                        fontSize: 14.0,
                                      );
                                    } else {
                                      Fluttertoast.showToast(
                                        msg:
                                            "Update Email will be sent to you shortly",
                                        toastLength: Toast.LENGTH_LONG,
                                        gravity: ToastGravity.BOTTOM,
                                        timeInSecForIosWeb: 1,
                                        backgroundColor: Colors.green,
                                        textColor: Colors.white,
                                        fontSize: 14.0,
                                      );

                                      Future.delayed(
                                          Duration(milliseconds: 200), () {
                                        Navigator.pop(
                                            context); // Pop after animation completes
                                      });
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Color(0xFF00224F),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    padding: EdgeInsets.symmetric(vertical: 14),
                                  ),
                                  child: Text(
                                    'Update Password',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
