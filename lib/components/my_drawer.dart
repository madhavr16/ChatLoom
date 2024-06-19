import 'package:allen/services/auth/auth_service.dart';
import 'package:allen/pages/settings_page.dart';
import 'package:flutter/material.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  void logout(){
    //get auth service
    final authService = AuthService();
    authService.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          //logo
          Column(
            children: [
              DrawerHeader(
            child: Center(
              child: Icon(
                Icons.message,
                size: 60,
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
            ),
          ),
          //home list tile
          Padding(
            padding: const EdgeInsets.only(left: 25.0),
            child: ListTile(
              title: Text('H O M E', style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary)),
              leading: Icon(Icons.home, color: Theme.of(context).colorScheme.inversePrimary),
              onTap: () {
                //pop the drawer
                Navigator.pop(context);
              },
            ),
          ),

          //settings list tile
           Padding(
            padding: const EdgeInsets.only(left: 25.0),
            child: ListTile(
              title: Text('S E T T I N G S',style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),),
              leading: Icon(Icons.settings, color: Theme.of(context).colorScheme.inversePrimary),
              onTap: () {
                //pop the drawer
                Navigator.pop(context);
                //navigate to settings page
                Navigator.push(context, MaterialPageRoute(builder: (context) => const SettingsPage()));
              },
            ),
          ),


            ],
          ),
          //logout list tile
          Padding(
            padding: const EdgeInsets.only(left: 25.0, bottom: 25.0),
            child: ListTile(
              title: Text('L O G O U T', style: TextStyle(color: Theme.of(context).colorScheme.inversePrimary),),
              leading: Icon(Icons.logout, color: Theme.of(context).colorScheme.inversePrimary,),
              onTap: logout,
            ),
          ),
        ],
      ),
    );
  }
}