// createConversation --no Ui --done and working
// getConversations --List Chat Page --done and working
// joinConversation --No Ui --done
// leaveConversation --No Ui --done
// sendMessage -- compose Message page --done and working
// getMessages -- compose Message page -- done and working -- Ui part Left
// markMessagesAsRead -- compose Message page --done
// getUnreadCount --list Message page --done and working -- mapping and showing in Ui Left
// deleteMessage -- compose Message Page --done
// searchMessages -- List chat Page --done
// editMessage -- Compose Message Page --inclomplete
// addReaction -- compose Message Page --done
// getConversation --List chat page --incomplete  -- ASK?? same as getConversations but why
// deleteReaction --compose Message Page --done
// getThreadMessages --compose Message Page -- incomplete
// deleteConversation --no Ui --done and Working
// updateGroupProfilePicture --no Ui --incomplete

import 'dart:io';

import 'package:Buildify_AI/models/chatModel.dart';
import 'package:Buildify_AI/models/messageModel.dart';
import 'package:Buildify_AI/models/user.dart';
import 'package:Buildify_AI/screens/newChat.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:shared_preferences/shared_preferences.dart';

class Sockets {
  static final Sockets _instance = Sockets._internal();
  final String _socketURL =
      "https://my-express-app-767851496729.us-south1.run.app";
  // static const String token =
  //     "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpZCI6NTksImlhdCI6MTcyODMxMjY5NSwiZXhwIjoxNzI4Mzk5MDk1fQ.HknupoEbqZl4mRtA4hhQwugDYfsDVEyoF_OBUD07DTM"; // gaurang //
  String? token;
  IO.Socket? _socket;
  Sockets._internal();
  static Sockets getInstance() {
    return _instance;
  }

  _getToken() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    token = prefs.getString("token");
  }

  on(event, callback) {
    _socket!.on(event, callback);
  }

  getSocket() {
    return _socket!;
  }

  void connect(String authToken) async {
    token = authToken;
    _socket = IO.io(
        "https://my-express-app-767851496729.us-south1.run.app",
        <String, dynamic>{
          "auth": {
            'token': token,
          },
          "transports": ['websocket'],
          "autoConnect": false,
          "setTimeout": 30000
        });
    _socket!.connect();
    _socket!.on("newConversation", (e) {
      print("newConverersation recieved");
      chatsNotifier.value.add(e);
    });
    _socket!.on("newMessage", (e) {
      print("new message recieved");
      print(e);
    });
    _socket!.onConnect((data) => print("connected"));
    _socket!.onConnectError((e) {
      print(e);
    });
    _socket!.on("userTyping", (e) {
      print(" opposite user typing");
    });
  }

  // listenConversation() {
  //   _socket!.on("newConversation", handler);
  // }

  getConversations() async {
    List<Chatmodel> chats = [];
    var response = await _socket!.emitWithAckAsync("getConversations", {});
    var unreadCount =
        await _socket!.emitWithAckAsync("getConversationsWithUnreadCounts", {});
    print(response['data'] is List);
    print(response['data']);
    print(unreadCount);
    for (int i = 0; i < response['data'].length; i++) {
      if (response['data'][i] is Map<String, dynamic>) ;
      print(response['data'][i]);
      Chatmodel chat = Chatmodel.fromJson(response['data'][i]);
      chat.unreadCount = unreadCount['data'][i]['unreadCount'];
      chats.add(chat);
      // print(chat);
    }
    print(chats[0]);
    return chats;
  }

  emitToRoom() {
    _socket!.on("emitToRoom", (e) {
      print(e);
    });
  }

  createOne2OneConversation({required CurrentUser user}) async {
    var response = await _socket!.emitWithAckAsync("createConversation", {
      "authToken": token,
      "type": 'ONE_TO_ONE',
      "participantIds": [int.parse(user.id)],
      "groupName": user.name,
      // "profilePicture": {
      //   "buffer":
      //       "https://images.unsplash.com/photo-1720048169707-a32d6dfca0b3?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDF8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
      //   "originalname": "file.jpg"
      // },
    });
    print(response);
  }

  createConversations(
      {required List<int> participants,
      required String groupName,
      File? image}) async {
    var response;
    if (image != null) {
      response = await _socket!.emitWithAckAsync("createConversation", {
        "authToken": token,
        "type": 'GROUP',
        "participantIds": participants,
        "groupName": groupName,
        "profilePicture": {
          "buffer": image.readAsBytesSync(),
          "originalname": "${groupName}.jpeg"
        },
      });
    } else {
      response = await _socket!.emitWithAckAsync("createConversation", {
        "authToken": token,
        "type": 'GROUP',
        "participantIds": participants,
        "groupName": groupName,
        // "profilePicture": {
        //   "buffer":
        //       "https://images.unsplash.com/photo-1720048169707-a32d6dfca0b3?q=80&w=2070&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDF8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D",
        //   "originalname": "file.jpg"
        // },
      });
    }

    // chatsNotifier.value.add(Chatmodel.fromJson(response['data']));
    print(response);
  }

  deleteConversation(int conversationId) async {
    var deletedId = await _socket!.emitWithAckAsync("deleteConversation", {
      "authToken": token,
      "conversation_id": conversationId,
    });
    print(deletedId);
  }

  sendMessage(int conversationID, String message,
      {File? image, String? imageNmae}) async {
    var response;
    if (image == null) {
      response = await _socket!.emitWithAckAsync("sendMessage", {
        "authToken": token,
        "conversation_id": conversationID,
        "content": message,
        // "message_type": "Text",
      });
    } else {
      print(message);

      response = await _socket!.emitWithAckAsync("sendMessage", {
        "authToken": token,
        "conversation_id": conversationID,
        "content": message,
        // "message_type": image != null ? "Image" : "Text",
        "files": [
          {
            "buffer": image.readAsBytesSync(),
            "originalname": imageNmae,
          },
        ],
      });
    }

    print(response);
  }

  sendMessagewithReply(int conversationID, String message, int parrentId,
      {File? image, String? imageNmae}) async {
    print("with replky");
    var response;
    if (image == null) {
      response = await _socket!.emitWithAckAsync("sendMessage", {
        "authToken": token,
        "conversation_id": conversationID,
        "content": message,
        "parent_message_id": parrentId,
        // "message_type": "Text",
      });
    } else {
      response = await _socket!.emitWithAckAsync("sendMessage", {
        "authToken": token,
        "conversation_id": conversationID,
        "content": message,
        "parent_message_id": parrentId,
        // "message_type": image != null ? "Image" : "Text",
        "files": [
          {
            "buffer": image.readAsBytesSync(),
            "originalname": imageNmae,
          },
        ],
      });
    }

    print(response);
  }

  getMessages(chatid) async {
    List<MessageModel> messages = [];
    var response = await _socket!.emitWithAckAsync("getMessages", {
      "authToken": token,
      "conversation_id": chatid,
    });

    // print(response);
    // print(response['data'][0]);
    print(response['data'] is List);
    for (int i = 0; i < response['data'].length; i++) {
      if (response['data'][i] is Map<String, dynamic>) ;
      MessageModel message = MessageModel.fromJson(response['data'][i]);
      messages.add(message);
      // print(chat);
    }
    // print(messages[0]);
    return messages;
  }

  bool isConnected() {
    return _socket!.connected;
  }

  getUnreadCount(userId) async {
    var response = await _socket!.emitWithAckAsync("getUnreadCount", {
      // "authToken": token,
      "userId": 100002,
    });
    print(response);
  }

  joinConversation(conversationId) async {
    var response =
        await _socket!.emitWithAckAsync("joinConversation", conversationId);
    print(response);
  }

  leaveConversation(conversationId) async {
    var response =
        await _socket!.emitWithAckAsync("leaveConversation", conversationId);
    print(response);
  }

  markMessagesAsRead(conversationId) async {
    var response = await _socket!.emitWithAckAsync("markMessagesAsRead", {
      "conversation_id": conversationId,
    });
    print(response);
  }

  userTyping(conversationId) async {
    var response = await _socket!.emitWithAckAsync("userTyping", {
      "conversation_id": conversationId,
    });
    print(response);
  }

  userStoppedTyping(conversationId) async {
    var response = await _socket!.emitWithAckAsync("userStoppedTyping", {
      "conversation_id": conversationId,
    });
    print(response);
  }

  deleteMessage(conversationId, messageId) async {
    var response = await _socket!.emitWithAckAsync("deleteMessage", {
      "conversation_id": conversationId,
      "message_id": messageId,
      "authToken": token,
    });
    print(response);
  }

  searchMessages(conversationId, query) async {
    var response = await _socket!.emitWithAckAsync("searchMessages", {
      "conversation_id": conversationId,
      "query": query,
    });
    print(response);
  }

  addReaction(messageID, conversationId, reaction) async {
    var response = await _socket!.emitWithAckAsync("addReaction", {
      "conversation_id": conversationId,
      "reaction": reaction,
      "message_id": messageID,
      "authToken": token,
    });
    print(response);
  }

  deleteReaction(messageID, conversationId, reaction) async {
    var response = await _socket!.emitWithAckAsync("deleteReaction", {
      "conversation_id": conversationId,
      "reaction": reaction,
      "message_id": messageID,
      "authToken": token,
    });
    print(response);
  }

  getConversationsWithUnreadCounts() async {
    print("blah");
    var response =
        await _socket!.emitWithAckAsync("getConversationsWithUnreadCounts", {
      // "authToken": token,
    });
    print(response['data'] is List);
    print(response['data'].length);
    for (int i = 0; i < response['data'].length; i++) {
      if (response['data'][i] is Map<String, dynamic>) ;
      print(response['data'][i]["unreadCount"]);
      Chatmodel chat = Chatmodel.fromJson(response['data'][i]);
      // chats.add(chat);
      // print(chat);
    }
    // print(chats[0]);
    print(response);
  }

  dispose() {
    _socket!.close();
  }
}
