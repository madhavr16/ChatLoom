import 'package:allen/components/my_drawer.dart';
import 'package:allen/components/user_tile.dart';
import 'package:allen/pages/chat_page.dart';
import 'package:allen/services/auth/auth_service.dart';
import 'package:allen/services/chat/chat_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  HomePage({super.key});

  //chat and user service
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();

  //get current user
  User? get currentUser => _authService.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text(
          'ChatLoom',
          style: TextStyle(
              color: Color.fromARGB(255, 68, 255, 74),
              fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey,
        elevation: 0,
        centerTitle: true,
      ),
      drawer: const MyDrawer(),
      body: _buildUsersList(),
    );
  }

  //build a list of users except the current user
  Widget _buildUsersList() {
    return StreamBuilder(
        stream: _chatService.getUsersStream(),
        builder: (context, snapshot) {
          //error
          if (snapshot.hasError) {
            return const Center(
              child: Text('An error occurred'),
            );
          }
          //loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          // return list view
          return ListView(
            children: snapshot.data!
                .map<Widget>(
                    (userData) => _buildUsersListItem(userData, context))
                .toList(),
          );
        });
  }

  //build individual list tile for users
  Widget _buildUsersListItem(
      Map<String, dynamic> userData, BuildContext context) {
    //display only users that are not the current user
    if (userData['email'] != currentUser!.email) {
      return UserTile(
        text: userData["email"],
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatPage(
                receiverMail: userData["email"],
                receiverID: userData["uid"],
              ),
            ),
          );
        },
      );
    } else {
      return Container();
    }
  }
}
