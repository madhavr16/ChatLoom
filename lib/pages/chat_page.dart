import 'package:allen/components/chat_bubble.dart';
import 'package:allen/components/my_textfield.dart';
import 'package:allen/services/auth/auth_service.dart';
import 'package:allen/services/chat/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  final String receiverMail;
  final String receiverID;

  ChatPage({super.key, required this.receiverMail, required this.receiverID});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  //text controller for the message input field
  final TextEditingController messageController = TextEditingController();

  //chat and authentication services
  final ChatService chatService = ChatService();

  final AuthService authService = AuthService();

  //for text field focus
  final FocusNode focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    focusNode.addListener(() {
      if (!focusNode.hasFocus) {
        Future.delayed(const Duration(milliseconds: 500),
        () => scrollDown()
        );
      }
    });
    //wait a bit for the list to build and then scroll down
    Future.delayed(const Duration(milliseconds: 500), () => scrollDown()); 
  }

  @override
  void dispose() {
    focusNode.dispose();
    messageController.dispose();
    super.dispose();
  }

  //scroll controller
  final ScrollController scrollController = ScrollController();
  void scrollDown() {
    scrollController.animateTo(
      scrollController.position.maxScrollExtent,
      duration: const Duration(seconds: 1),
      curve: Curves.fastOutSlowIn,
    );
  }

  //send message
  void sendMessage() async {
    //if there is some text in the message input field
    if (messageController.text.isNotEmpty) {
      // send the message
      await chatService.sendMessage(widget.receiverID, messageController.text);
      //clear the controller
      messageController.clear();
    }
    scrollDown();  
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          widget.receiverMail,
          style: const TextStyle(
              color: Color.fromARGB(255, 68, 255, 74),
              fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          //display messages
          Expanded(
            child: _buildMessagesList(),
          ),
          //message input field
          _buildUserInput()
        ],
      ),
    );
  }

  //build a list of messages
  Widget _buildMessagesList() {
    String senderID = authService.currentUser!.uid;
    return StreamBuilder(
        stream: chatService.getMessages(widget.receiverID, senderID),
        builder: (context, snapshot) {
          //errors
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
          //return list view
          return ListView(
            controller: scrollController,
            children: snapshot.data!.docs
                .map((doc) => _buildMessageItem(doc))
                .toList(),
          );
        });
  }

  // build individual message item
  Widget _buildMessageItem(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    //if the message is sent by the current user
    bool isCurrentUser = data['senderID'] == authService.currentUser!.uid;

    //display the message on the right, else display it on the left
    var alignment =
        isCurrentUser ? Alignment.centerRight : Alignment.centerLeft;

    return Container(
        alignment: alignment,
        child: Column(
            crossAxisAlignment: isCurrentUser
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              ChatBubble(message: data['message'], isCurrentUser: isCurrentUser)
            ]));
  }

  // build message input field
  Widget _buildUserInput() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(children: [
        Expanded(
          child: MyTextField(
            hintText: 'Type a message',
            controller: messageController,
            obscureText: false,
            focusNode: focusNode,
          ),
        ),
        //send button
        Container(
          decoration:
              BoxDecoration(shape: BoxShape.circle, color: Colors.green[500]),
          margin: const EdgeInsets.only(right: 25),
          child: IconButton(
            icon: const Icon(
              Icons.send,
              color: Colors.white,
            ),
            onPressed: sendMessage,
          ),
        )
      ]),
    );
  }
}
