import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatPage extends StatefulWidget {
  final String myEmail, userEmail;
  const ChatPage({
    super.key,
    required this.myEmail,
    required this.userEmail,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  TextEditingController msgController = TextEditingController();

  String getCombinedEmails() {
    List<String> emails = [widget.myEmail, widget.userEmail];
    emails.sort(); // Sort the emails alphabetically
    return '${emails[0]}-${emails[1]}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.userEmail),
      ),
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('messages')
                    .doc(getCombinedEmails())
                    .collection('sub_collection')
                    .orderBy('date_time', descending: true)
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      shrinkWrap: true,
                      reverse: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        DocumentSnapshot documentSnapshot =
                            snapshot.data!.docs[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            vertical: 20,
                            horizontal: 10,
                          ),
                          child: Wrap(
                            children: [
                              Align(
                                alignment:
                                    documentSnapshot['email'] == widget.myEmail
                                        ? Alignment.centerRight
                                        : Alignment.centerLeft,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: documentSnapshot['email'] ==
                                            widget.myEmail
                                        ? Colors.blue
                                        : Colors.amber,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Text(
                                    documentSnapshot['msg'],
                                    style: const TextStyle(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }
                  return Container();
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 1,
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: msgController,
                        decoration: const InputDecoration(
                          border: InputBorder.none,
                          label: Text('Enter message here'),
                        ),
                      ),
                    ),
                    ActionChip(
                      disabledColor: Colors.green,
                      backgroundColor: Colors.green,
                      label: const Icon(
                        Icons.send,
                        color: Colors.white,
                      ),
                      onPressed: () {
                        FirebaseFirestore.instance
                            .collection('messages')
                            .doc(getCombinedEmails())
                            .collection('sub_collection')
                            .add(
                          {
                            'msg': msgController.text,
                            'email': widget.myEmail,
                            'date_time': DateTime.now().toString(),
                          },
                        ).then(
                          (value) => setState(
                            () => msgController.clear(),
                          ),
                        );
                      },
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
