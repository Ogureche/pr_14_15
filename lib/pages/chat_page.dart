import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:rxdart/rxdart.dart';
import 'package:pr_14_15/models/note.dart';

class ChatPage extends StatefulWidget {
  ChatPage({super.key, required this.receiver_username, required this.receiver_id, required String sellerId});
  final String receiver_username;
  final String receiver_id;
  @override
  State<ChatPage> createState() => _ChatPageState(receiver_username: receiver_username, receiver_id: receiver_id);
}



class _ChatPageState extends State<ChatPage> {
  _ChatPageState({required this.receiver_username, required this.receiver_id});
  final String receiver_username;
  String sender_username = '';
  final String receiver_id;
  late Stream<List<Map<String, dynamic>>> chat;
  late Future<List<Note>> savedItems;
  final user = Supabase.instance.client.auth.currentUser!;
  final TextEditingController _messageController = TextEditingController();
  late List<Note> g;

  //Функция чтения json файла
  Future<void> readFromSB() async {
    try {
      final senderStream = Supabase.instance.client.from('chat').stream(primaryKey: ['id']).eq('sender_id', receiver_id).order('created_at', ascending: true);
      final receiverStream = Supabase.instance.client.from('chat').stream(primaryKey: ['id']).eq('receiver_id', receiver_id).order('created_at', ascending: true);
      chat = Rx.combineLatest2<List<Map<String, dynamic>>, List<Map<String, dynamic>>, List<Map<String, dynamic>>>(
        senderStream,
        receiverStream,
            (senderMessages, receiverMessages) {
          final combined = [...senderMessages, ...receiverMessages];
          combined.sort((a, b) => a['created_at'].compareTo(b['created_at']));
          return combined;
        },
      );
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  void getUsername() async {
    try {
      final res = await Supabase.instance.client.from('users').select('name').eq('user_id', user.id.toString());
      setState(() {

      });
      sender_username = res[0]['name'].toString();
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future<void> sendMessage() async {
    final message = _messageController.text;
    if (message.isEmpty) {
      return;
    }

    // Debugging: Print sender_id and receiver_id values
    print("Sender ID: ${user.id.toString()}");
    print("Receiver ID: $receiver_id");

    // Check if either ID is invalid
    if (receiver_id.isEmpty || user.id.toString().isEmpty) {
      print("Error: Invalid sender or receiver ID");
      return;
    }

    try {
      await Supabase.instance.client.from('chat').insert({
        'sender_id': user.id.toString(),
        'receiver_id': receiver_id,
        'message': message,
      });
      setState(() {
        readFromSB();
      });
    } catch (e) {
      print('Error sending message: $e');
    }
  }



  @override
  void initState() {
    super.initState();
    readFromSB();
    getUsername();
    setState(() {

    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Center(child: Text("Чат", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 35))),
        leading: IconButton(
          onPressed: () {
            setState(() {
              Navigator.pop(context);
            });
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
                stream: chat,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    debugPrint(snapshot.error.toString());
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text("Сообщений нет."));
                  }
                  final messages = snapshot.data as List<dynamic>;
                  debugPrint(messages.toString());
                  return ListView.builder(
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[index];
                      final isMine = message['sender_id'] == user.id.toString();
                      return ListTile(
                        title: Align(
                          alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
                          child: Column(
                            crossAxisAlignment: isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                            children: [
                              Text(isMine ? sender_username : receiver_username, textAlign: isMine ? TextAlign.right: TextAlign.left,),
                              Container(
                                  padding: EdgeInsets.all(8),
                                  color: isMine ? Colors.blueAccent : Colors.grey[300],
                                  child: Text(message['message'], style: TextStyle(color: isMine? Colors.white : Colors.black))
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                }
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              children: [
                Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        hintText: 'Введите сообщение',
                        border: OutlineInputBorder(),
                      ),
                    )
                ),
                IconButton(
                  onPressed: () async {await sendMessage(); _messageController.clear();},
                  icon: const Icon(Icons.send),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}