import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../Application_Tier/UserManager.dart';
import '../../Data_Tier/UserModel.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;

  final TextEditingController NameController = TextEditingController();
  final TextEditingController EmailController = TextEditingController();
  final TextEditingController ContactController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  String? selectedGender;

  final UserManager _userManager = UserManager();
  UserModel? _user;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
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

  Future<void> _loadUserData() async {
    UserModel? user = await _userManager.getUserData();
    if (mounted) {
      setState(() {
        _user = user;
        NameController.text = user!.name;
        EmailController.text = user!.email;
        ContactController.text = user!.contact;
        selectedGender = user!.gender;
        _dateController.text = user!.dob;
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    NameController.dispose();
    EmailController.dispose();
    ContactController.dispose();
    _dateController.dispose();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00224F),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                    Colors.white), // Make the loading indicator white
              ),
            )
          : buildscreen(),
    );
  }

  Widget buildscreen() {
    Future<void> _selectDate(BuildContext context) async {
      DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime.now(),
      );

      if (pickedDate != null) {
        _dateController.text = "${pickedDate.toLocal()}"
            .split(' ')[0]; // Formats the date as YYYY-MM-DD
      }
    }

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
                      'Edit Profile',
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
                          'Edit Profile',
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
                                controller: NameController,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 12),
                                ),
                              ),
                              SizedBox(height: 18),
                              TextField(
                                controller: EmailController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 12),
                                ),
                              ),
                              SizedBox(height: 18),
                              TextField(
                                controller: ContactController,
                                keyboardType: TextInputType.phone,
                                // Brings up the numeric keypad
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 12),
                                ),
                              ),
                              SizedBox(height: 18),
                              DropdownButtonHideUnderline(
                                child: ButtonTheme(
                                  alignedDropdown: true,
                                  child: DropdownButtonFormField<String>(
                                    decoration: InputDecoration(
                                      labelText: 'Gender',
                                      border: OutlineInputBorder(),
                                      contentPadding: EdgeInsets.symmetric(
                                          vertical: 8, horizontal: 12),
                                    ),
                                    value: selectedGender,
                                    items: ['Male', 'Female', 'Other']
                                        .map((String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value),
                                      );
                                    }).toList(),
                                    onChanged: (String? newValue) {
                                      //Handle Changes here
                                      selectedGender = newValue;
                                    },
                                    hint: Text('Select Gender'),
                                    isExpanded:
                                        true, // Makes the dropdown button expand to fill the available width
                                  ),
                                ),
                              ),
                              SizedBox(height: 18),
                              TextField(
                                controller: _dateController,
                                decoration: InputDecoration(
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                      vertical: 8, horizontal: 12),
                                ),
                                readOnly: true, // Prevents manual editing
                                onTap: () => _selectDate(
                                    context), // Opens the date picker
                              ),
                              SizedBox(height: 18),
                              SizedBox(
                                width: double.infinity,
                                // Ensures the button takes the full width
                                child: ElevatedButton(
                                  onPressed: () async {
                                    String name = NameController.text.trim();
                                    String email = EmailController.text.trim();
                                    String contact =
                                        ContactController.text.trim();
                                    String? gender = selectedGender;
                                    String date = _dateController.text.trim();

                                    if (name.isEmpty ||
                                        email.isEmpty ||
                                        contact.isEmpty ||
                                        gender!.isEmpty ||
                                        date.isEmpty) {
                                    } else if (contact.length != 11) {
                                      Fluttertoast.showToast(
                                        msg:
                                            "Please enter a valid contact number.",
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        timeInSecForIosWeb: 1,
                                        backgroundColor: Colors.red,
                                        textColor: Colors.white,
                                        fontSize: 14.0,
                                      );
                                    } else {
                                      UserModel updatedUser = UserModel(
                                        name: name,
                                        email: email,
                                        contact: contact,
                                        dob: date,
                                        gender: gender,
                                      );
                                      bool success = await _userManager
                                          .updateUserData(updatedUser);
                                      if (success) {
                                        Future.delayed(
                                            Duration(milliseconds: 600), () {
                                          Navigator.pop(context);
                                        });
                                      } else {
                                        Fluttertoast.showToast(
                                          msg: 'Unable to update user information',
                                          toastLength: Toast.LENGTH_SHORT,
                                          gravity: ToastGravity.BOTTOM,
                                          timeInSecForIosWeb: 1,
                                          backgroundColor: Colors.red,
                                          textColor: Colors.white,
                                          fontSize: 14.0,
                                        );
                                      }
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
                                    'Edit Profile',
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
