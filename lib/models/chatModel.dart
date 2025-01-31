import 'package:Buildify_AI/models/user.dart';
import 'package:Buildify_AI/models/userModel.dart';
import 'package:Buildify_AI/models/messageModel.dart';
import 'package:flutter/material.dart'; // Make sure to import the MessageModel

class Chatmodel {
  int? chatID;
  int? createrID;
  int? updaterID;
  bool active = true;
  String? type;
  String? profilePicture;
  String? groupName;
  int? unreadCount;
  String? lastMessage;
  String? lastMessageTime;
  List<CurrentUser> participants; // List of participants

  // Constructor
  Chatmodel({
    this.chatID,
    this.createrID,
    this.updaterID,
    this.active = true,
    this.type,
    this.groupName,
    this.profilePicture,
    this.unreadCount,
    this.lastMessage,
    this.lastMessageTime,
    List<CurrentUser>? participants, // Initialize with an empty list if null
    List<MessageModel>? messages, // Initialize with an empty list if null
  }) : participants = participants ?? [];

  // Factory constructor to create a Chatmodel instance from a JSON map
  factory Chatmodel.fromJson(Map<String, dynamic> json) {
    var participantsJson = json['participants'] as List<dynamic>?;
    List<CurrentUser> participantsList = participantsJson != null
        ? participantsJson.map((e) => CurrentUser.fromJson(e)).toList()
        : [];

    var messagesJson = json['messages'] as List<dynamic>?;
    // List<MessageModel> messagesList = messagesJson != null
    //     ? messagesJson.map((e) => MessageModel.fromJson(e)).toList()
    //     : [];
    if (json['type'] == "ONE_TO_ONE") {
      return Chatmodel(
        chatID: json['id'],
        createrID: json['creator_id'],
        updaterID: json['updater_id'],
        active: json['active'],
        type: json['type'],
        groupName: participantsList[0].name,
        unreadCount: json['unreadCount'],
        participants: participantsList,
        lastMessage:
            json['messages'].length != 0 ? json['messages'][0]['content'] : "",
        lastMessageTime: json['messages'].length != 0
            ? json['messages'][0]['created_at']
            : "",
        // messages: messagesList,
        profilePicture: participantsList[0].profilePicture,
      );
    }
    return Chatmodel(
      chatID: json['id'],
      createrID: json['creator_id'],
      updaterID: json['updater_id'],
      active: json['active'],
      type: json['type'],
      groupName: json['group_name'],
      unreadCount: json['unreadCount'],
      participants: participantsList,
      lastMessage:
          json['messages'].length != 0 ? json['messages'][0]['content'] : "",
      lastMessageTime:
          json['messages'].length != 0 ? json['messages'][0]['created_at'] : "",
      // messages: messagesList,
      profilePicture: json['profile_picture'],
    );
  }

  // Method to convert a Chatmodel instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'chatID': chatID,
      'createrID': createrID,
      'updaterID': updaterID,
      'active': active,
      'type': type,
      'groupName': groupName,
      'participants': participants
          .map((e) => e.toJson())
          .toList(), // Convert each Usermodel to JSON
      'profile_picture': profilePicture,
      'unreadCount': unreadCount,
      // Convert each MessageModel to JSON
    };
  }

  // Override the toString method for better string representation
  @override
  String toString() {
    return 'Chatmodel(chatID: $chatID, createrID: $createrID, updaterID: $updaterID, active: $active, type: $type, groupName: $groupName, participants: ${participants.length}, profilePicture: ${profilePicture})';
  }
}

ValueNotifier<List<Chatmodel>> chatsNotifier = ValueNotifier([]);
