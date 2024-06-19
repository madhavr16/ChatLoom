import 'package:allen/models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService{
  //get instance of firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  //get user stream
  Stream<List<Map<String, dynamic>>> getUsersStream(){
    return _firestore.collection('Users').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        // go through each individual user
        final user = doc.data();

        //return user
        return user;
      }
      ).toList();
    }
    );
  }
  //send messages
  Future<void> sendMessage(String receiverID, message) async{
    // get current user
    final String currentUserID = _auth.currentUser!.uid;
    final String currentUserEmail = _auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();

    // create a new message
    Message newMessage = Message(
      senderID: currentUserID,
      senderEmail: currentUserEmail,
      receiverID: receiverID,
      message: message,
      timestamp: timestamp.toString()
    );

    // construct a chat room id for the 2 users(sorted to ensure sequence)
    List<String> ids = [currentUserID, receiverID];
    ids.sort(); // sort the ids(this is to ensure that the chat room id is the same for the 2 users)
    String chatRoomID = ids.join('_');

    // add message to the database
    await _firestore.collection('Chats').doc(chatRoomID).collection('Messages').add(newMessage.toMap());
  }
  
  //get messages
  Stream<QuerySnapshot> getMessages(String userID, otherUserID){
    // construct a chat room id for the 2 users(sorted to ensure sequence)
    List<String> ids = [userID, otherUserID];
    ids.sort(); // sort the ids(this is to ensure that the chat room id is the same for the 2 users)
    String chatRoomID = ids.join('_');

    // get messages
    return _firestore.collection('Chats').doc(chatRoomID).collection('Messages').orderBy('timestamp', descending: false).snapshots();
  }
}
    
  
