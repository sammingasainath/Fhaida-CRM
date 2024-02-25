import 'package:crmapp/community.dart';
import 'package:flutter/material.dart';
import 'contact_home.dart'; // Adjust the import based on your project structure
// import 'social_widget.dart'; // Adjust the import based on your project structure
// import 'contacthome_widget.dart'; // Adjust the import based on your project structure

class NavbarWidget extends StatelessWidget {
  const NavbarWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: CircularNotchedRectangle(),
      notchMargin: 6.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          IconButton(
            icon: Icon(Icons.group_work_sharp, color: Color(0xFF9299A1)),
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => FullScreenImagePage()));
            },
          ),
          IconButton(
            icon: Icon(Icons.chat_bubble_rounded, color: Color(0xFF9299A1)),
            onPressed: () {
              // Define action
            },
          ),
          SizedBox(width: 48), // The dummy child for the notch
          IconButton(
            icon: Icon(Icons.headphones, color: Color(0xFF9299A1)),
            onPressed: () {
              // Define action
            },
          ),
          IconButton(
            icon: Icon(Icons.contact_mail, color: Color(0xFF9299A1)),
            onPressed: () {
              Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ContactSearchPage()));
            },
          ),
        ],
      ),
    );
  }
}
