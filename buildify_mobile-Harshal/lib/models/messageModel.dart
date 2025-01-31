import 'dart:convert';

class FileInfoModel {
  final String? originalName;
  final String? fileUrl;
  final String? downloadUrl;

  FileInfoModel({this.originalName, this.fileUrl, this.downloadUrl});

  factory FileInfoModel.fromJson(Map<String, dynamic> json) {
    return FileInfoModel(
      originalName: json['original_name'],
      fileUrl: json['file_url'],
      downloadUrl: json['download_url'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'original_name': originalName,
      'file_url': fileUrl,
      'download_url': downloadUrl,
    };
  }
}

class MessageModel {
  int? id;
  int? creatorId;
  int? updaterId;
  DateTime? createdAt;
  DateTime? updatedAt;
  bool active;
  String? content;
  int? senderId;
  String? senderName; // Added senderName property
  int? conversationId;
  List<FileInfoModel>? fileInfo; // Updated to List<FileInfoModel>
  String? reactions; // Assuming reactions can be null or some other type
  int? parentMessageId;

  // Constructor
  MessageModel({
    this.id,
    this.creatorId,
    this.updaterId,
    this.createdAt,
    this.updatedAt,
    this.active = true,
    this.content,
    this.senderId,
    this.senderName, // Added senderName parameter
    this.conversationId,
    this.fileInfo, // Updated to accept a List<FileInfoModel>
    this.reactions,
    this.parentMessageId,
  });

  // Factory constructor to create a MessageModel instance from a JSON map
  factory MessageModel.fromJson(Map<String, dynamic> json) {
    List<FileInfoModel>? fileInfoList;

    // Check if 'file_info' is a List
    if (json['file_info'] is List) {
    } else if (json['file_info'] is String) {
      // Handle the case where file_info is a string
      var fileInfo = jsonDecode(json['file_info']);
      // print(fileInfo is List);
      fileInfoList = (fileInfo as List<dynamic>)
          .map((item) => FileInfoModel.fromJson(item))
          .toList();
    }

    return MessageModel(
      id: json['id'],
      creatorId: json['creator_id'],
      updaterId: json['updater_id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      active: json['active'],
      content: json['content'],
      senderId: json['sender_id'],
      senderName: json['sender']['name'],
      conversationId: json['conversation_id'],
      fileInfo: fileInfoList, // Assign the parsed file info list
      reactions: json['reactions'],
      parentMessageId: json['parent_message_id'],
    );
  }

  // Method to convert a MessageModel instance to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'creator_id': creatorId,
      'updater_id': updaterId,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'active': active,
      'content': content,
      'sender_id': senderId,
      'sender_name': senderName, // Include senderName in JSON
      'conversation_id': conversationId,
      'file_info': fileInfo
          ?.map((file) => file.toJson())
          .toList(), // Convert list to JSON
      'reactions': reactions,
      'parent_message_id': parentMessageId,
    };
  }

  @override
  String toString() {
    return 'MessageModel(id: $id, creatorId: $creatorId, updaterId: $updaterId, createdAt: $createdAt, updatedAt: $updatedAt, active: $active, content: $content, senderId: $senderId, senderName: $senderName, conversationId: $conversationId, fileInfo: $fileInfo, reactions: $reactions, parentMessageId: $parentMessageId)';
  }
}
