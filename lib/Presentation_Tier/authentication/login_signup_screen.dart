import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:scholarly_app/Application_Tier/NotificationManager.dart';
import '../../Application_Tier/AuthenticationHandler.dart';
import '/Presentation_Tier/homepage/home_screen.dart';

class CustomToggleButton extends StatefulWidget {
  final ValueChanged<bool> onToggle;

  CustomToggleButton({required this.onToggle});

  @override
  _CustomToggleButtonState createState() => _CustomToggleButtonState();
}

class _CustomToggleButtonState extends State<CustomToggleButton> {
  bool isLoginSelected = true;

  static final GlobalKey<_CustomToggleButtonState> globalKey =
      GlobalKey<_CustomToggleButtonState>();

  void _toggle(bool isLogin) {
    setState(() {
      isLoginSelected = isLogin;
    });
    widget.onToggle(isLogin);
  }

  @override
  Widget build(BuildContext context) {
    double containerWidth = MediaQuery.of(context).size.width - 100;
    double buttonWidth = containerWidth / 2;

    return Container(
      height: 50,
      width: double.infinity,
      padding: EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Color(0xFF00224F),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Stack(
        children: [
          AnimatedAlign(
            duration: Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment:
                isLoginSelected ? Alignment.centerLeft : Alignment.centerRight,
            child: Container(
              width: buttonWidth,
              height: 50,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => _toggle(true),
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      'Log in',
                      style: TextStyle(
                        color: isLoginSelected ? Colors.black : Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: GestureDetector(
                  onTap: () => _toggle(false),
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      'Register',
                      style: TextStyle(
                        color: isLoginSelected ? Colors.white : Colors.black,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class LoginSignupScreen extends StatefulWidget {
  @override
  _LoginSignupScreenState createState() => _LoginSignupScreenState();
}

class _LoginSignupScreenState extends State<LoginSignupScreen> {
  //Firebase Authentication Handler
  final authHandler = AuthenticationHandler();

  // Controllers for login fields
  final TextEditingController loginEmailController = TextEditingController();
  final TextEditingController loginPasswordController = TextEditingController();

  // Controllers for registration fields (Step 1)
  final TextEditingController registerNameController = TextEditingController();
  final TextEditingController registerEmailController = TextEditingController();

  // Controllers for registration fields (Step 2)
  final TextEditingController registerPasswordController =
      TextEditingController();
  final TextEditingController registerConfirmPasswordController =
      TextEditingController();

  // Controllers for registration fields (Step 3)
  final TextEditingController registerContactController =
      TextEditingController();
  String? genderValue;
  final TextEditingController registerDateController = TextEditingController();

  final TextEditingController registerConfirmationCodeController =
      TextEditingController();

  @override
  void dispose() {
    // Dispose controllers
    loginEmailController.dispose();
    loginPasswordController.dispose();
    registerNameController.dispose();
    registerEmailController.dispose();
    registerPasswordController.dispose();
    registerContactController.dispose();
    registerConfirmPasswordController.dispose();
    registerDateController.dispose();
    registerConfirmationCodeController.dispose();
    super.dispose();
  }

  bool isLoginSelected = true;
  int registerStep = 1;
  bool _isLoginPasswordVisible = false;
  bool _isRegPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  void _handleToggle(bool isLogin) {
    setState(() {
      isLoginSelected = isLogin;
      registerStep = 1; // Reset step when switching to register
    });
  }

  void _nextStep() {
    setState(() {
      registerStep++;
    });
  }

  void _backStep() {
    setState(() {
      registerStep--;
    });
  }

  void resetLogin() {
    registerStep = 1;
  }

  Widget _buildLoginForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Login via Email',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontFamily: "Arial",
            ),
          ),
        ),
        SizedBox(height: 18),
        TextField(
          controller: loginEmailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: 'Enter your email',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          ),
        ),
        SizedBox(height: 18),
        TextField(
          controller: loginPasswordController,
          obscureText: !_isLoginPasswordVisible,
          // Toggle visibility based on state
          decoration: InputDecoration(
            labelText: 'Enter Password',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            suffixIcon: IconButton(
              icon: Icon(
                _isLoginPasswordVisible
                    ? Icons.visibility
                    : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  _isLoginPasswordVisible = !_isLoginPasswordVisible;
                });
              },
            ),
          ),
        ),
        SizedBox(height: 12),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            GestureDetector(
              onTap: () {
                authHandler.showForgotPasswordDialog(context);
              },
              child: Text(
                'Forgot Password ?  ',
                style: TextStyle(
                  color: Colors.blue,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 22),
        ElevatedButton(
          onPressed: () async {
            String email = loginEmailController.text; // Get the entered email
            String password =
                loginPasswordController.text; // Get the entered password

            // Validate Email and Password
            bool emailValidation = authHandler.validateEmail(email);
            bool passwordValidation = authHandler.validatePassword(password);

            // If either email and password are invalid
            if (emailValidation == true && passwordValidation == true) {
              Fluttertoast.showToast(
                msg: 'Verifying Credentials',
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.green,
                textColor: Colors.white,
                fontSize: 14.0,
              );

              bool loginStatus = await authHandler.loginUser(email, password);
              if (loginStatus == true) {
                // If login is successful, navigate to HomeScreen

                //Show Welcome Notification
                await NotificationManager.initialize();
                NotificationManager.showWelcomeNotification();

                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    transitionDuration: Duration(seconds: 1),
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        HomeScreen(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      const begin = Offset(0.0, 1.0); // Start from the bottom
                      const end = Offset.zero; // End at the normal position
                      const curve = Curves.easeInOut;

                      var tween = Tween(begin: begin, end: end)
                          .chain(CurveTween(curve: curve));
                      var offsetAnimation = animation.drive(tween);

                      return SlideTransition(
                          position: offsetAnimation, child: child);
                    },
                  ),
                );
              }
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF00224F),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: EdgeInsets.symmetric(vertical: 10),
          ),
          child: Text(
            'Login',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterFormStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      key: ValueKey(1),
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Register with Email - Step 1',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontFamily: "Arial",
            ),
          ),
        ),
        SizedBox(height: 18),
        TextField(
          controller: registerNameController,
          decoration: InputDecoration(
            labelText: 'Enter name',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          ),
        ),
        SizedBox(height: 18),
        TextField(
          controller: registerEmailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: 'Enter your email',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          ),
        ),
        SizedBox(height: 54),
        ElevatedButton(
          onPressed: () {
            String name =
                registerNameController.text.trim(); // Get the entered name
            String email =
                registerEmailController.text.trim(); // Get the entered email

            // If either email or name are invalid, show the respective error message
            if (name.isEmpty) {
              Fluttertoast.showToast(
                msg: "Enter your Name",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 14.0,
              );
            } else if (name.length < 3) {
              Fluttertoast.showToast(
                msg: "Please enter a valid name",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 14.0,
              );
            } else {
              // Check if the email is valid
              bool emailValidation = authHandler.validateEmail(email);

              if (emailValidation == true) {
                // If both email and name are valid
                Fluttertoast.showToast(
                  msg: "Email and Name are valid!",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.BOTTOM,
                  timeInSecForIosWeb: 1,
                  backgroundColor: Colors.green,
                  textColor: Colors.white,
                  fontSize: 14.0,
                );
                _nextStep(); // Handle the next action
              }
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF00224F),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: EdgeInsets.symmetric(vertical: 10),
          ),
          child: Text(
            'Next',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterFormStep2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      key: ValueKey(2),
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Register with Email - Step 2',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontFamily: "Arial",
            ),
          ),
        ),
        SizedBox(height: 18),
        TextField(
          controller: registerPasswordController,
          obscureText: !_isRegPasswordVisible,
          // Toggle visibility based on state
          decoration: InputDecoration(
            labelText: 'Enter Password',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            suffixIcon: IconButton(
              icon: Icon(
                _isRegPasswordVisible ? Icons.visibility : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  _isRegPasswordVisible = !_isRegPasswordVisible;
                });
              },
            ),
          ),
        ),
        SizedBox(height: 22),
        TextField(
          controller: registerConfirmPasswordController,
          obscureText: !_isConfirmPasswordVisible,
          // Toggle visibility based on state
          decoration: InputDecoration(
            labelText: 'Confirm Password',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
            suffixIcon: IconButton(
              icon: Icon(
                _isConfirmPasswordVisible
                    ? Icons.visibility
                    : Icons.visibility_off,
              ),
              onPressed: () {
                setState(() {
                  _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                });
              },
            ),
          ),
        ),
        SizedBox(height: 50),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: _backStep, // Handle the back action
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF00224F),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 10),
                ),
                child: Text(
                  'Back',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12), // Small space between buttons
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  String password1 = registerPasswordController.text;
                  String password2 = registerConfirmPasswordController.text;

                  // If either of the password is invalid, show the respective error message
                  if (password1 != password2) {
                    Fluttertoast.showToast(
                      msg: "Passwords do not match, try again",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 14.0,
                    );
                  } else if (password1.isEmpty || password2.isEmpty) {
                    Fluttertoast.showToast(
                      msg: "Please enter a password",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.BOTTOM,
                      timeInSecForIosWeb: 1,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                      fontSize: 14.0,
                    );
                  } else {
                    // Check if the password is valid
                    bool passwordValidation =
                        authHandler.validatePassword(password1);

                    if (passwordValidation == true) {
                      // If both passwords are valid
                      Fluttertoast.showToast(
                        msg: "Both Passwords are valid!",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        timeInSecForIosWeb: 1,
                        backgroundColor: Colors.green,
                        textColor: Colors.white,
                        fontSize: 14.0,
                      );
                      _nextStep(); // Handle the next action
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF00224F),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 10),
                ),
                child: Text(
                  'Next',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRegisterFormStep3() {
    Future<void> _selectDate(BuildContext context) async {
      DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1900),
        lastDate: DateTime.now(),
      );

      if (pickedDate != null) {
        registerDateController.text = "${pickedDate.toLocal()}"
            .split(' ')[0]; // Formats the date as YYYY-MM-DD
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      key: ValueKey(3),
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Register with Email - Step 3',
            style: TextStyle(
              fontSize: 16,
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontFamily: "Arial",
            ),
          ),
        ),
        SizedBox(height: 12),
        TextField(
          controller: registerContactController,
          keyboardType: TextInputType.phone, // Brings up the numeric keypad
          decoration: InputDecoration(
            labelText: 'Enter Contact Number',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          ),
          // maxLength: 11, // Optional: limit the length of the contact number
          // inputFormatters: [
          //   // Optional: Use this to restrict input to digits only
          //   FilteringTextInputFormatter.digitsOnly,
          // ],
        ),
        SizedBox(height: 10),
        DropdownButtonHideUnderline(
          child: ButtonTheme(
            alignedDropdown: true,
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Gender',
                border: OutlineInputBorder(),
                contentPadding:
                    EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              ),
              items: ['Male', 'Female', 'Other'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(value),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  genderValue =
                      newValue; // Update genderValue with the selected option
                });
              },
              value: genderValue,
              hint: Text('Select Gender'),
              isExpanded:
                  true, // Makes the dropdown button expand to fill the available width
            ),
          ),
        ),
        SizedBox(height: 10),
        TextField(
          controller: registerDateController,
          decoration: InputDecoration(
            labelText: 'Date of Birth',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          ),
          readOnly: true, // Prevents manual editing
          onTap: () => _selectDate(context), // Opens the date picker
        ),
        SizedBox(height: 10),
        ElevatedButton(
          onPressed: () async {
            String dob = registerDateController.text;
            String contact = registerContactController.text;
            String? gender = genderValue;

            if (contact.length != 11) {
              Fluttertoast.showToast(
                msg: "Please enter a valid contact number.",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 14.0,
              );
            } else if (gender == null) {
              Fluttertoast.showToast(
                msg: "Please select Gender",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 14.0,
              );
            } else if (dob.isEmpty) {
              Fluttertoast.showToast(
                msg: "Please enter your Date of Birth",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 14.0,
              );
            } else {
              String email = registerEmailController.text.trim();
              String password = registerPasswordController.text.trim();

              Fluttertoast.showToast(
                msg: "Creating New User, Please Wait...",
                toastLength: Toast.LENGTH_SHORT,
                gravity: ToastGravity.BOTTOM,
                timeInSecForIosWeb: 1,
                backgroundColor: Colors.green,
                textColor: Colors.white,
                fontSize: 14.0,
              );

              String name =
                  registerNameController.text.trim(); // Get the entered name
              String dob = registerDateController.text;
              String contact = registerContactController.text;
              String? gender = genderValue;

              bool registerStatus = await authHandler.registerUser(
                  email, password, name, dob, contact, gender);

              if (registerStatus == true) {
                // Navigating to the Login Screen with Bottom-Up Transition

                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    transitionDuration: Duration(seconds: 1),
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        HomeScreen(),
                    transitionsBuilder:
                        (context, animation, secondaryAnimation, child) {
                      const begin = Offset(0.0, 1.0); // Start from the bottom
                      const end = Offset.zero; // End at the normal position
                      const curve = Curves.easeInOut;

                      var tween = Tween(begin: begin, end: end)
                          .chain(CurveTween(curve: curve));
                      var offsetAnimation = animation.drive(tween);

                      return SlideTransition(
                          position: offsetAnimation, child: child);
                    },
                  ),
                );
              }
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF00224F),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: EdgeInsets.symmetric(vertical: 10),
          ),
          child: Text(
            'Register',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Color(0xFF00224F),
      resizeToAvoidBottomInset: true,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
              height: MediaQuery.of(context).size.height * 0.35,
              child: Center(
                child: Image.asset(
                  'assets/icon/app_icon.png',
                  width: 220,
                  height: 220,
                ),
              ),
            ),
            Container(
              width: screenWidth - 60,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CustomToggleButton(onToggle: _handleToggle),
                    SizedBox(height: 20),
                    AnimatedSwitcher(
                      duration: Duration(milliseconds: 300),
                      child: isLoginSelected
                          ? _buildLoginForm()
                          : registerStep == 1
                              ? _buildRegisterFormStep1()
                              : registerStep == 2
                                  ? _buildRegisterFormStep2()
                                  : _buildRegisterFormStep3(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
