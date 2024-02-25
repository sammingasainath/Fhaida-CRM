import 'package:crmapp/task_management.dart';
import 'package:crmapp/lead_management%20.dart';
import 'package:flutter/material.dart';
import 'navbar_widget.dart';
import 'add_lead.dart';
import 'task_add.dart';
import 'property_management.dart';
import 'socialmediapage.dart';

class HomePage extends StatelessWidget {
  const HomePage({Key? key}) : super(key: key);

  void _showAddOptionsModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Wrap(
          children: <Widget>[
            ListTile(
                leading: Icon(Icons.note_add),
                title: Text('Add Task'),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => TaskManagementPage()));
                }),
            ListTile(
                leading: Icon(Icons.home),
                title: Text('Add Property'),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PropertyManagementPage()));
                }),
            ListTile(
                leading: Icon(Icons.person_add),
                title: Text('Add Lead'),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => LeadManagementPage()));
                }),
            ListTile(
                leading: Icon(Icons.attach_file),
                title: Text('Add Documents'),
                onTap: () {
                  // Navigate to Add Documents Page
                }),
            ListTile(
                leading: Icon(Icons.message),
                title: Text('Marketing'),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SocialMediaManagementPage()));
                }),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home Page'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddOptionsModal(context),
        tooltip: 'Add New',
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: const NavbarWidget(),
      body: Stack(
        children: [
          Container(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                ListTile(
                    leading: const Icon(Icons.view_list),
                    title: const Text('Hot Leads'),
                    subtitle: Text('Hot Leads in the pipeline'),
                    onTap: () {}),
                ListTile(
                    leading: const Icon(Icons.show_chart),
                    title: const Text('Documents'),
                    subtitle: Text('Displays the Documents '),
                    onTap: () {/* react to the tile being tapped */}),
                ListTile(
                    leading: const Icon(Icons.graphic_eq),
                    title: const Text('Reports'),
                    subtitle: Text('AI based Sales reports'),
                    onTap: () {}),
                ListTile(
                    leading: const Icon(Icons.settings),
                    title: const Text('Customize'),
                    subtitle: Text('Customize the App'),
                    onTap: () {}),
              ],
            ),
          ),
          Positioned(
            bottom: 16.0,
            right: 16.0,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                FloatingActionButton(
                  onPressed: () {
                    // Add functionality for the first Mic Icon here
                    print('Mic Icon 1 pressed');
                  },
                  tooltip: 'Mic 1',
                  child: const Icon(Icons.mic),
                ),
                SizedBox(height: 16), // Adjust the spacing as needed
              ],
            ),
          ),
        ],
      ),
    );
  }
}
