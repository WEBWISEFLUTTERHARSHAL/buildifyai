import 'dart:async';
import 'dart:convert';
import 'package:Buildify_AI/models/chatModel.dart';
import 'package:Buildify_AI/models/messageModel.dart';
import 'package:Buildify_AI/utils/api_calls.dart';
import 'package:Buildify_AI/utils/colors.dart';
import 'package:Buildify_AI/utils/routes.dart';
import 'package:Buildify_AI/utils/socket.dart';
import 'package:Buildify_AI/utils/strings.dart';
import 'package:Buildify_AI/utils/time.dart';
import 'package:Buildify_AI/widgets/generalAppBar.dart';
import 'package:Buildify_AI/widgets/generalSearchbar.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ForwardMessage extends StatefulWidget {
  const ForwardMessage({super.key});

  @override
  State<ForwardMessage> createState() => _ForwardMessageState();
}

class _ForwardMessageState extends State<ForwardMessage> {
  // Create a ValueNotifier for chats

  final Sockets _socket = Sockets.getInstance();
  String? authToken;
  int? userID;
  List<MessageModel> forwardedMessages = [];
  Future<void> _getConversation() async {
    List<Chatmodel> newChats = await _socket.getConversations();
    chatsNotifier.value = newChats; // Update ValueNotifier
  }

  Future<void> _getID() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String id = prefs.getString('user_id')!;
    authToken = prefs.getString('token')!;
    userID = int.parse(id);
    _socket.connect(authToken!);

    print(unreadCount);
    await _getConversation();
  }

  int? unreadCount;
  @override
  void initState() {
    super.initState();

    _getID().then((e) {
      forwardedMessages =
          ModalRoute.of(context)?.settings.arguments as List<MessageModel>;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  void navigate(context, String route, {arguments}) async {
    if (arguments != null) {
      await Navigator.of(context).pushNamed(route, arguments: arguments);
    } else {
      Navigator.of(context).pushNamed(route).then((e) {
        _getConversation();
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // print(forwardedMessages);
    return Scaffold(
      appBar: GeneralAppbar(title: "Forward Message"),
      floatingActionButton: GestureDetector(
        onTap: () {
          navigate(context, Routes.newChat);
        },
        child: Container(
          height: 60,
          width: 60,
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [
                  floatingButtonGradient1,
                  floatingButtonGradient2,
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 5),
                ),
              ]),
          child: Center(
            child: Icon(
              Icons.chat_rounded,
              color: white,
            ),
          ),
        ),
      ),
      body: Container(
        padding: EdgeInsets.all(15),
        color: lightBlueTheme,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            generalSearchBar(oninit: () {
              _getConversation();
            }, onsubmit: (String val) {
              print(val);
              if (val == "") {
                _getConversation();
              }
              print("new Group".contains(val));
              chatsNotifier.value = chatsNotifier.value
                  .where((chat) => chat.groupName!.contains(val))
                  .toList();

              // print(list.length);
            }, onCancel: () {
              _getConversation();
            }),
            const SizedBox(
              height: 25,
            ),
            Text(
              "Recent Conversations",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: darkGreenTheme,
              ),
            ),
            Expanded(
              child: FutureBuilder(
                future: _getID(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (snapshot.connectionState == ConnectionState.done ||
                      snapshot.connectionState == ConnectionState.active) {
                    return ValueListenableBuilder<List<Chatmodel>>(
                      valueListenable: chatsNotifier,
                      builder: (context, chats, child) {
                        if (chats.isEmpty) {
                          return Center(
                            child: Text("No conversations found."),
                          );
                        }
                        return ListView.separated(
                          shrinkWrap: true,
                          physics: ScrollPhysics(),
                          itemCount: chats.length,
                          separatorBuilder: (context, index) {
                            return Divider(
                              color: progressBg,
                              thickness: 1.5,
                              height: 0,
                            );
                          },
                          itemBuilder: (context, index) {
                            return chatUi(chats[index]);
                          },
                        );
                      },
                    );
                  } else {
                    return Center(
                      child: Text("Some Error"),
                    );
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Material chatUi(Chatmodel chat) {
    return Material(
      color: lightBlueTheme,
      child: ListTile(
        dense: true,
        horizontalTitleGap: 10,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 15,
        ),
        onTap: () {
          print(forwardedMessages);
          forwardedMessages.forEach((message) {});
          // navigate(context, Routes.composeMessageRoute, arguments: chat);
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        leading: Stack(
          children: [
            chat.profilePicture != null
                ? FutureBuilder(
                    future: getFileBytes(chat.profilePicture!),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        return CircleAvatar(
                          radius: 26,
                          backgroundImage: MemoryImage(snapshot.data!),
                        );
                      }
                      return CircleAvatar(
                        radius: 26,
                      );
                    })
                : CircleAvatar(
                    radius: 26,
                  ),
            const Positioned(
              bottom: 0,
              right: 5,
              child: Icon(
                Icons.circle,
                color: green,
                size: 10,
              ),
            ),
          ],
        ),
        title: Text(
          chat.groupName ?? "Null Group Name",
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w400,
            color: darkGreenTheme,
          ),
        ),
        subtitle: Text(
          chat.lastMessage!,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: lightGreyTheme,
          ),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              chat.lastMessageTime != "" ? timeAgo(chat.lastMessageTime!) : "",
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w400,
                color: lightGreyTheme,
              ),
            ),
            chat.unreadCount != null && chat.unreadCount != 0
                ? Container(
                    height: 25,
                    width: 25,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: darkBlueTheme,
                    ),
                    child: Text(
                      chat.unreadCount!.toString(),
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: white,
                      ),
                    ),
                  )
                : const SizedBox(),
          ],
        ),
      ),
    );
  }
}
