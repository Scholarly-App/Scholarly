import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import '/Presentation_Tier/authentication/login_signup_screen.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '/Presentation_Tier/homepage/home_screen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoAnimationController;
  late AnimationController _textAnimationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _blurAnimation;
  late Animation<double> _textRevealAnimation;

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _initializeAnimations();

    // Perform the asynchronous task
    _performAsyncTasks();
  }

  void _initializeAnimations() {
    // Initialize the AnimationController for the logo
    _logoAnimationController = AnimationController(
      duration: Duration(seconds: 2),
      vsync: this,
    );

    // Initialize the scale animation (large to normal size)
    _scaleAnimation = Tween<double>(begin: 2.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _logoAnimationController, curve: Curves.easeInOut),
    );

    // Initialize the blur animation (blurry to clear)
    _blurAnimation = Tween<double>(begin: 10.0, end: 0.0).animate(
      CurvedAnimation(
          parent: _logoAnimationController, curve: Curves.easeInOut),
    );

    // Start the logo animation
    _logoAnimationController.forward();

    // Initialize a second AnimationController for the text
    _textAnimationController = AnimationController(
      duration: Duration(seconds: 1),
      vsync: this,
    );

    // Initialize the text reveal animation (for ShaderMask)
    _textRevealAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
          parent: _textAnimationController, curve: Curves.easeInOut),
    );

    // Delay the start of the text animation until the logo animation is done
    _logoAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _textAnimationController.forward();
      }
    });
  }

// Perform the async tasks like checking Firebase configuration
  void _performAsyncTasks() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        // User is logged in, navigate to HomeScreen
        Timer(Duration(milliseconds: 3500), () {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              transitionDuration: Duration(milliseconds: 1010),
              pageBuilder: (context, animation, secondaryAnimation) =>
                  HomeScreen(), // Go to HomeScreen
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.easeInOut;
                var tween = Tween(begin: begin, end: end)
                    .chain(CurveTween(curve: curve));
                var offsetAnimation = animation.drive(tween);
                return SlideTransition(position: offsetAnimation, child: child);
              },
            ),
          );
        });
      } else {
        // User is not logged in, navigate to LoginPage
        Timer(Duration(milliseconds: 3500), () {
          Navigator.pushReplacement(
            context,
            PageRouteBuilder(
              transitionDuration: Duration(milliseconds: 1300),
              pageBuilder: (context, animation, secondaryAnimation) =>
                  LoginSignupScreen(), // Go to LoginSignupScreen
              transitionsBuilder:
                  (context, animation, secondaryAnimation, child) {
                const begin = Offset(1.0, 0.0);
                const end = Offset.zero;
                const curve = Curves.easeInOut;
                var tween = Tween(begin: begin, end: end)
                    .chain(CurveTween(curve: curve));
                var offsetAnimation = animation.drive(tween);
                return SlideTransition(position: offsetAnimation, child: child);
              },
            ),
          );
        });
      }
    } catch (e) {
      debugPrint("Firebase initialization error: $e");
      if (e is FirebaseException) {
        debugPrint("FirebaseException code: ${e.code}, message: ${e.message}");
      }

      Fluttertoast.showToast(
        msg: "Firebase initialization error. Please try again.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 14.0,
      );
    }
  }

  @override
  void dispose() {
    _logoAnimationController.dispose();
    _textAnimationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF00224F),
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: Transform.translate(
                offset: Offset(0, -40),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AnimatedBuilder(
                      animation: _logoAnimationController,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _scaleAnimation.value,
                          child: ImageFiltered(
                            imageFilter: ImageFilter.blur(
                              sigmaX: _blurAnimation.value,
                              sigmaY: _blurAnimation.value,
                            ),
                            child: Image.asset(
                              'assets/icon/app_icon.png',
                              width: 220,
                              height: 220,
                            ),
                          ),
                        );
                      },
                    ),
                    AnimatedBuilder(
                      animation: _textRevealAnimation,
                      builder: (context, child) {
                        return ShaderMask(
                          shaderCallback: (bounds) {
                            return LinearGradient(
                              begin: Alignment.centerLeft,
                              end: Alignment.centerRight,
                              stops: [
                                _textRevealAnimation.value,
                                _textRevealAnimation.value
                              ],
                              colors: [Colors.white, Colors.transparent],
                            ).createShader(
                              Rect.fromLTWH(0, 0, bounds.width, bounds.height),
                            );
                          },
                          blendMode: BlendMode.srcIn,
                          child: Text(
                            ' SCHOLARLY ',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontFamily: 'DancingScript',
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 30.0),
            child: Text(
              'AI Driven Smart Learning Assistant',
              style: TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontFamily: 'San Francisco',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
