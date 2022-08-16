import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatScreen extends StatefulWidget {
  static String id = 'chat_screen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final _fireStore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  late User loggedInUser;
  late String textMessgae;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        loggedInUser = user;
      }
    }
    catch (e) {
      print(e);
    }
  }

  void messageStream() async {
    await for (var snapshot in _fireStore.collection('messages').snapshots()) {
      for (var message in snapshot.docs) {
        print(message.data);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                _auth.signOut();
                Navigator.pop(context);
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            StreamBuilder<QuerySnapshot>(
                stream: _fireStore.collection('messages').snapshots(),
                builder: (context, snapshot) {
                  if(!snapshot.hasData){
                    return Center(child: CircularProgressIndicator(
                      backgroundColor: Colors.lightBlueAccent,
                    ),);
                  }
                    final messages = snapshot.data!.docs;
                  List<MessageBubble> messageBubbles = [];
                  for(var message in messages){
                    final messageText = message.get('text');
                    final messageSender = message.get('sender');

                    final messageBubble = MessageBubble(text: messageText, sender: messageSender);

                    messageBubbles.add(messageBubble);
                  }
                  return Expanded(
                    child: ListView(
                      padding: EdgeInsets.symmetric(horizontal: 10.0,vertical: 20.0),
                      children: messageBubbles,
                    ),
                  );
                }),
            Container(
              decoration: messageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      onChanged: (value) {
                        textMessgae = value;
                      },
                      decoration: messageTextFieldDecoration,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      _fireStore.collection('messages').add({
                        'text': textMessgae,
                        'sender': loggedInUser.email,
                      });
                    },
                    child: Text(
                      'Send',
                      style: sendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class MessageBubble extends StatelessWidget {

  MessageBubble({required this.text,required this.sender});

  late final String text;
  late final String sender;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: <Widget>[
          Text(sender, style:TextStyle(
            fontSize: 12.0,
          color: Colors.black54),
          ),
          Material(
            elevation: 5.0,
            borderRadius: BorderRadius.circular(30.0),
            color: Colors.lightBlueAccent,
           child: Padding(
             padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 20),
             child: Text('$text from $sender',
             style: TextStyle(
               fontSize: 15.0,
               color: Colors.white,
             ),),
           ),
          ),
        ],
      ),
    );
  }
}

