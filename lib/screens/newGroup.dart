import 'dart:io';

import 'package:Buildify_AI/models/user.dart';
import 'package:Buildify_AI/screens/addMembers.dart';
import 'package:Buildify_AI/utils/colors.dart';
import 'package:Buildify_AI/utils/socket.dart';
import 'package:Buildify_AI/utils/strings.dart';
import 'package:Buildify_AI/widgets/generalAppBar.dart';
import 'package:Buildify_AI/widgets/generalButton.dart';
import 'package:Buildify_AI/widgets/generalTextField.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class Newgroup extends StatefulWidget {
  const Newgroup({super.key});

  @override
  State<Newgroup> createState() => _NewgroupState();
}

class _NewgroupState extends State<Newgroup> {
  final Sockets _socket = Sockets.getInstance();
  final ImagePicker _picker = ImagePicker();
  ValueNotifier<File?> selectedImage = ValueNotifier(null);
  ValueNotifier<List<CurrentUser>> groupMembers = ValueNotifier([]);
  TextEditingController groupNamController = TextEditingController();

  _createGroupConversation() {
    String groupName = groupNamController.text.trim();
    if (groupName != "") {
      List<int> participants = groupMembers.value.map((member) {
        return int.parse(member.id);
      }).toList();
      print(participants);
      _socket.createConversations(
          participants: participants,
          groupName: groupName,
          image: selectedImage.value);
    } else {
      print("empty Group Name");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBlueTheme,
      appBar: GeneralAppbar(title: "Create a New Group  "),
      body: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        width: MediaQuery.of(context).size.width,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Stack(
                children: [
                  ValueListenableBuilder(
                      valueListenable: selectedImage,
                      builder: (context, imageFile, child) {
                        return CircleAvatar(
                          radius: 70,
                          backgroundColor: white,
                          backgroundImage:
                              imageFile != null ? FileImage(imageFile) : null,
                        );
                      }),
                  Positioned(
                      bottom: 2,
                      right: 5,
                      child: CircleAvatar(
                          backgroundColor: Color(0xFF3797EF),
                          radius: 20,
                          child: GestureDetector(
                            onTap: () {
                              showDialog(
                                  context: context,
                                  builder: (context) =>
                                      pickprofilepictureDialog());
                            },
                            child: Icon(
                              Icons.camera_alt_rounded,
                              color: white,
                            ),
                          )))
                ],
              ),
              const SizedBox(height: 10),
              Text(
                "Display Image",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Group name",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 5),
                  TextFormField(
                    controller: groupNamController,
                    style: const TextStyle(
                      fontFamily: strings.fontPoppins,
                      fontSize: 12,
                      fontWeight: FontWeight.normal,
                    ),
                    decoration: const InputDecoration(
                        fillColor: white,
                        filled: true,
                        contentPadding:
                            EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                        hintText: "Group Name",
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(width: 0, color: white),
                          borderRadius: BorderRadius.all(Radius.circular(10)),
                        ),
                        hintStyle: TextStyle(
                          fontFamily: strings.fontPoppins,
                          fontSize: 12,
                          fontWeight: FontWeight.normal,
                          color: lightGrey,
                        ),
                        border: InputBorder.none),
                  ),
                ],
              ),
              const SizedBox(height: 50),
              ValueListenableBuilder<List<CurrentUser>>(
                valueListenable: groupMembers,
                builder: (context, members, child) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Members : ${members.length}",
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w400),
                      ),
                      const SizedBox(height: 5),
                      SizedBox(
                        height: 100,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, index) {
                            return this.members(members[index]);
                          },
                          separatorBuilder: (context, index) =>
                              const SizedBox(width: 10),
                          itemCount: members.length,
                        ),
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 50),
              GeneralButton(
                  onPressed: () async {
                    Navigator.of(context)
                        .push(MaterialPageRoute(
                            builder: (context) => addMembers()))
                        .then((e) {
                      groupMembers.value = [...groupMembers.value, e];
                    });
                  },
                  text: "+ Add Members"),
              const SizedBox(height: 8),
              button("Create a Group", () {
                _createGroupConversation();
                Navigator.of(context).pop();
              }),
            ],
          ),
        ),
      ),
    );
  }

  button(String text, VoidCallback onTap) {
    return TextButton(
      style: TextButton.styleFrom(
        backgroundColor: white,
        minimumSize: Size(
          double.infinity,
          52,
        ),
        shape: RoundedRectangleBorder(
          side: BorderSide(width: 1, color: darkBlueTheme),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      onPressed: onTap,
      child: text == ""
          ? SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                backgroundColor: grey,
                color: white,
                strokeCap: StrokeCap.round,
                strokeWidth: 3,
              ),
            )
          : Text(
              text,
              style: TextStyle(
                color: darkBlueTheme,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
    );
  }

  Stack members(CurrentUser user) {
    return Stack(
      children: [
        Container(
          height: 100,
          width: 95,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(10)),
            color: white,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CircleAvatar(
                radius: 25,
                backgroundImage: user.profilePicture != "null"
                    ? NetworkImage(user.profilePicture!)
                    : const NetworkImage(
                        "https://images.unsplash.com/photo-1729731321992-5fdb6568816a?q=80&w=1887&auto=format&fit=crop&ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D"),
              ),
              Text(
                user.name,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              )
            ],
          ),
        ),
        Positioned(
            top: 8,
            right: 3,
            child: GestureDetector(
                child: Icon(
              Icons.more_vert,
              color: grey,
            )))
      ],
    );
  }

  pickprofilepictureDialog() {
    return AlertDialog(
      content: SizedBox(
        height: 120,
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          children: [
            GestureDetector(
              onTap: () => _pickImage(context, ImageSource.camera),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.camera_alt,
                    size: 40,
                    color: headerGradient2,
                  ),
                  SizedBox(height: 8),
                  Text("Camera"),
                ],
              ),
            ),
            GestureDetector(
              onTap: () => _pickImage(context, ImageSource.gallery),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.photo_library,
                    size: 40,
                    color: headerGradient2,
                  ),
                  SizedBox(height: 8),
                  Text("Gallery"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(BuildContext context, ImageSource source) async {
    try {
      final returnImage = await _picker.pickImage(source: source);
      if (returnImage == null) return;
      selectedImage.value = File(returnImage.path);
      // String fileName = selectedImage.uri.pathSegments.last;
      Navigator.pop(context);
      print(
          "got Image Successfully"); // Close the dialog after choosing an option
    } catch (e) {
      print("Error picking image: $e");
    }
  }
}
