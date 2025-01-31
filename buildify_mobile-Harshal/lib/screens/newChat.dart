import 'package:Buildify_AI/models/user.dart';
import 'package:Buildify_AI/utils/api_calls.dart';
import 'package:Buildify_AI/utils/colors.dart';
import 'package:Buildify_AI/utils/routes.dart';
import 'package:Buildify_AI/utils/socket.dart';
import 'package:Buildify_AI/utils/strings.dart';
import 'package:Buildify_AI/widgets/generalAppBar.dart';
import 'package:Buildify_AI/widgets/generalSearchbar.dart';
import 'package:flutter/material.dart';
import 'package:Buildify_AI/utils/colors.dart';

class Newchat extends StatefulWidget {
  const Newchat({super.key});

  @override
  State<Newchat> createState() => _NewchatState();
}

class _NewchatState extends State<Newchat> {
  ValueNotifier<List<CurrentUser>> userNotifier = ValueNotifier([]);
  final Sockets _socket = Sockets.getInstance();

  getUsers() async {
    userNotifier.value = await fetchallUsers();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBlueTheme,
      appBar: GeneralAppbar(title: "Start a new chat"),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            generalSearchBar(oninit: () {
              getUsers();
            }, onsubmit: (val) {
              print(val);
              if (val == "") {
                getUsers();
              }

              userNotifier.value = userNotifier.value.where((user) {
                return user.name.toLowerCase().contains(val);
              }).toList();
              print(userNotifier.value.length);
            }, onCancel: () {
              getUsers();
            }),
            const SizedBox(
              height: 20,
            ),
            chatUi(
              context,
              createNewGroup: true,
            ),
            const SizedBox(
              height: 20,
            ),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Contacts",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: darkGreenTheme,
                ),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            Expanded(
              child: FutureBuilder(
                  future: getUsers(),
                  builder: (context, snapshot) {
                    // print(snapshot.data);
                    if (snapshot.connectionState == ConnectionState.done) {
                      // print(users);
                      return ValueListenableBuilder(
                          valueListenable: userNotifier,
                          builder: (context, userNotifiervalue, _) {
                            List<CurrentUser> users = userNotifier.value;
                            return ListView.separated(
                              itemCount: users.length,
                              separatorBuilder: (context, index) {
                                return Divider(
                                  color: progressBg,
                                  thickness: 1.5,
                                  height: 0.5,
                                );
                              },
                              itemBuilder: (context, index) {
                                return chatUi(context, user: users[index]);
                              },
                            );
                          });
                    }
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  }),
            )
          ],
        ),
      ),
    );
  }

  Material chatUi(
    context, {
    CurrentUser? user,
    bool createNewGroup = false,
  }) {
    // print(image is String);
    return Material(
      color: lightBlueTheme,
      child: ListTile(
        // dense: true,
        // horizontalTitleGap: 10,
        contentPadding: const EdgeInsets.symmetric(
            // vertical: 15,
            ),
        onTap: () async {
          if (createNewGroup) {
            Navigator.of(context).pushReplacementNamed(Routes.newGroup);
          } else {
            _socket.createOne2OneConversation(user: user!).then((e) {
              print(e);
              Navigator.of(context).pop();
            });
          }
        },
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        leading: createNewGroup
            ? const CircleAvatar(
                radius: 20,
                backgroundColor: headerGradient2,
                child: Center(
                  child: Icon(
                    Icons.group,
                    color: white,
                  ),
                ),
              )
            : CircleAvatar(
                radius: 20,
                backgroundImage: user!.profilePicture != "null"
                    ? NetworkImage(user.profilePicture!)
                    : NetworkImage(
                        "https://images.unsplash.com/photo-1729731321992-5fdb6568816a?q=80&w=1887&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"),
              ),
        title: Text(
          createNewGroup ? "Create a New Group" : user!.name,
          style: TextStyle(
            fontSize: createNewGroup ? 14 : 16,
            fontWeight: FontWeight.w400,
            color: darkGreenTheme,
          ),
        ),
      ),
    );
  }
}
