import 'package:flutter/material.dart';

class TermsConditionsScreen extends StatelessWidget {
  @override
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
                      'Terms and Condition',
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
          child: Column(
            children: [
              Padding(
                padding: EdgeInsets.only(top: 20, bottom: 30),
                child: Container(
                  width: MediaQuery.of(context).size.width -
                      56, // Screen width minus padding (28 * 2)
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Conditions and Attending',
                        style: TextStyle(
                          color: Colors.white, // Text color
                          fontFamily: 'San Fransisco',
                          fontWeight: FontWeight.w500,
                          fontSize: 20,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore veritatis et quasi architecto beatae vitae dicta sunt explicabo. Nemo enim ipsam voluptatem quia voluptas sit aspernatur aut odit aut fugit, sed quia consequuntur magni dolores eos qui ratione voluptatem sequi nesciunt. Neque porro quisquam est, qui dolorem ipsum quia dolor sit amet, consectetur, adipisci velit.',
                          textAlign: TextAlign.justify,
                          style: TextStyle(
                            color: Colors.white, // Text color
                            fontFamily: 'San Fransisco',
                            fontSize: 16,
                          ),
                        ),
                      ),
                      SizedBox(height: 20,),
                      Text(
                        'Terms & Use',
                        style: TextStyle(
                          color: Colors.white, // Text color
                          fontFamily: 'San Fransisco',
                          fontWeight: FontWeight.w500,
                          fontSize: 20,
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum. Sed ut perspiciatis unde omnis iste natus error sit voluptatem accusantium doloremque laudantium, totam rem aperiam, eaque ipsa quae ab illo inventore.',
                          textAlign: TextAlign.justify,
                          style: TextStyle(
                            color: Colors.white, // Text color
                            fontFamily: 'San Fransisco',
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
