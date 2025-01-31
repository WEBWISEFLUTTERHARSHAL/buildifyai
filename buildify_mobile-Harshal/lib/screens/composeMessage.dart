import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:Buildify_AI/main.dart';
import 'package:Buildify_AI/models/chatModel.dart';
import 'package:Buildify_AI/models/messageModel.dart';
import 'package:Buildify_AI/models/user.dart';
import 'package:Buildify_AI/utils/api_calls.dart';
import 'package:Buildify_AI/utils/colors.dart';
import 'package:Buildify_AI/utils/download.dart';
import 'package:Buildify_AI/utils/routes.dart';
import 'package:Buildify_AI/utils/socket.dart';
import 'package:Buildify_AI/utils/strings.dart';
import 'package:Buildify_AI/utils/time.dart';
import 'package:Buildify_AI/widgets/generalAppBar.dart';
import 'package:dio/dio.dart';
import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:open_file/open_file.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:flutter/services.dart';

class ComposeMessage extends StatefulWidget {
  const ComposeMessage({super.key});

  @override
  State<ComposeMessage> createState() => _ComposeMessageState();
}

class _ComposeMessageState extends State<ComposeMessage> {
  final Sockets _socket = Sockets.getInstance();
  int? userID;
  String? authToken;
  int selectedMessage = -1;
  ValueNotifier<bool> isLoading = ValueNotifier(true);
  ValueNotifier<List<MessageModel>> messagesNotifier = ValueNotifier([]);
  ValueNotifier showEmojiPicker = ValueNotifier(true);
  final TextEditingController _messageController = TextEditingController();
  final _scrollController = ScrollController();
  Chatmodel? chat;
  Set<int> selectedMessages = {};
  bool selectMode = false;
  OverlayEntry? _attachmentOverlayEntry;
  MessageModel? replyMessage;
  final FocusNode _messageFocusNode = FocusNode();

  _getMessages(int id) async {
    print("Fetching messages...");
    final List<MessageModel> newMessages = await _socket.getMessages(id);
    _socket.markMessagesAsRead(id);
    messagesNotifier.value = newMessages;
    isLoading.value = false; // Update the ValueNotifier
    // _scrollToBottom(); // Scroll to the bottom after updating
  }

  _fetchUser(int userID) async {
    String userDataEndpoint = "/api/zen/user/$userID";
    String baseUrl = "https://backend-api-topaz.vercel.app";

    Map<String, dynamic> responseMap;
    Response response;
    try {
      response = await Dio().get(
        baseUrl + userDataEndpoint,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      if (response.statusCode == 200) {
        responseMap = response.data;
        currentUser = CurrentUser(
          id: responseMap['body']['data']['id'].toString(),
          name: responseMap['body']['data']['attributes']['name'].toString(),
          email: responseMap['body']['data']['attributes']['email'].toString(),
        );
        // print(response.data.toString());
        // print(response.statusMessage.toString());
        return currentUser;
      } else {
        return null;
      }
    } on DioException catch (e) {
      // The request was made and the server responded with a status code
      // that falls out of the range of 2xx and is also not 304.
      if (e.response != null) {
        // print(
        //     "Exception, response not null : Data = ${e.response!.data.toString().substring(
        //           e.response!.data.toString().indexOf(':') + 2,
        //           e.response!.data.toString().indexOf('}'),
        //         )}");
        // return e.response!.data.toString().substring(
        //       e.response!.data.toString().indexOf(':') + 2,
        //       e.response!.data.toString().indexOf('}'),
        return null;
        // );
      } else {
        // Something happened in setting up or sending the request that triggered an Error
        print("Exception, response null : Message = ${e.message.toString()}");
      }
      return e.message.toString();
    }
  }

  _getID() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String id = prefs.getString('user_id')!;
    authToken = prefs.getString('token')!;
    userID = int.parse(id);
    print(token);
    // await _getFileBytes();
  }

  MessageModel _getrepliedMessage(id) {
    return messagesNotifier.value.where((e) => e.id == id).toList()[0];
  }

  _addReaction(int messageID, int conversationId, String reaction) async {
    await _socket.addReaction(messageID, conversationId, reaction);
    _getMessages(conversationId);
  }

  _deleteReaction(int messageID, int conversationId, String reaction) async {
    await _socket.deleteReaction(messageID, conversationId, reaction);
    _getMessages(conversationId);
  }

  _sendMessage({File? image, String? imageNmae}) async {
    if (image != null) {
      // print(imageNmae);
      await _socket.sendMessage(chat!.chatID!, "",
          image: image, imageNmae: imageNmae);
      _getMessages(chat!.chatID!);
    } else {
      String message = _messageController.text.trim();
      if (message.isEmpty) return; // Don't send empty messages
      _messageController.clear(); // Clear the text field
      await _socket.sendMessage(chat!.chatID!, message);
      _getMessages(chat!.chatID!);
    }
  }

  _sendMessagewithReply({File? image, String? imageNmae}) async {
    if (image != null) {
      // print(imageNmae);
      await _socket.sendMessagewithReply(chat!.chatID!, "", replyMessage!.id!,
          image: image, imageNmae: imageNmae);
      _getMessages(chat!.chatID!);
    } else {
      String message = _messageController.text.trim();
      if (message.isEmpty) return; // Don't send empty messages
      _messageController.clear(); // Clear the text field
      await _socket.sendMessagewithReply(
          chat!.chatID!, message, replyMessage!.id!);
      _getMessages(chat!.chatID!);
    }
  }

  @override
  void initState() {
    super.initState();
    _getID().then((_) {
      chat = ModalRoute.of(context)?.settings.arguments as Chatmodel?;
      _socket.connect(authToken!);
      // _socket.deleteMessage(chatid, 623);
      _getMessages(chat!.chatID!);
    });

    // Socket listeners
    _socket.getSocket().on("newMessage", (e) {
      print("Message received");
      _getMessages(chat!.chatID!); // Fetch messages when a new one arrives
    });
    _socket.getSocket().on("connect", (e) {
      print("Connected to socket");
    });
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    }
  }

  @override
  void dispose() {
    _socket.dispose();
    super.dispose();
  }

  String formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date).inDays;

    if (difference == 0) {
      return "Today";
    } else if (difference == 1) {
      return "Yesterday";
    } else if (difference < 7) {
      return DateFormat('EEEE').format(date); // Day of the week
    } else {
      return DateFormat('dd/MM/yy').format(date); // dd/MM/yy format
    }
  }

  void clearReply() {
    setState(() {
      replyMessage = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    print(selectMode);
    return Scaffold(
      appBar: selectMode
          ? selectedMessageAppbar(context, "Selected Message",
              showReply: selectMode && selectedMessages.length == 1,
              onCancel: () {
              setState(() {
                selectMode = !selectMode;
                selectedMessages.clear();
              });
            }, onReply: () {
              replyMessage = messagesNotifier.value
                  .where((e) => selectedMessages.first == e.id)
                  .toList()[0];
              setState(() {
                selectMode = !selectMode;
                selectedMessages.clear();
              });
              _messageFocusNode.requestFocus();
            }, onCopy: () {
              String copyContent = "";
              selectedMessages.forEach((item) {
                copyContent +=
                    _getrepliedMessage(selectedMessages.first).content!;
              });
              Clipboard.setData(ClipboardData(text: copyContent)).then((_) {
                setState(() {
                  selectMode = !selectMode;
                  selectedMessages.clear();
                });
              });
            }, onDelete: () {
              selectedMessages.forEach((item) {
                _socket!.deleteMessage(chat!.chatID, item);
                messagesNotifier.value.removeWhere((e) => e.id! == item);
                setState(() {});
              });
              setState(() {
                selectMode = !selectMode;
                selectedMessages.clear();
              });
              // _getMessages()
            }, onForward: () {
              print("onForward");
              List<MessageModel> forwardMessages = [];
              selectedMessages.forEach((item) {
                forwardMessages.add(_getrepliedMessage(item));
              });
              Navigator.of(context).pushReplacementNamed(Routes.forwardMessage,
                  arguments: forwardMessages);
            })
          : GeneralAppbar(title: "Compose Message"),
      backgroundColor: lightBlueTheme,
      body: GestureDetector(
        onTap: () {
          showEmojiPicker.value = true;
          setState(() {
            selectMode = !selectMode;
            selectedMessages.clear();
          });
        },
        child: Column(
          children: [
            const SizedBox(height: 20),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: ValueListenableBuilder<bool>(
                  valueListenable: isLoading,
                  builder: (context, loading, _) {
                    if (loading) {
                      // Display a CircularProgressIndicator while loading the first time
                      return const Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(headerGradient2),
                        ),
                      );
                    }

                    return ValueListenableBuilder<List<MessageModel>>(
                      valueListenable: messagesNotifier,
                      builder: (context, messages, _) {
                        return ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          controller: _scrollController,
                          reverse: true,
                          itemCount: messagesNotifier.value.length,
                          itemBuilder: (context, index) {
                            MessageModel currentMessage = messages[index];
                            print(currentMessage);
                            bool showDateWidget = index ==
                                    (messages.length - 1) ||
                                (messages[index].createdAt != null &&
                                    messages[index + 1].createdAt != null &&
                                    formatDate(currentMessage.createdAt!) !=
                                        formatDate(
                                            messages[index + 1].createdAt!));
                            // print(chat!.unreadCount);
                            if (index < chat!.unreadCount!) {}
                            return Column(
                              children: [
                                if (showDateWidget)
                                  dayWidget(
                                      formatDate(currentMessage.createdAt!)),
                                chat!.unreadCount! - 1 == index
                                    ? unreadWidget()
                                    : const SizedBox(),
                                const SizedBox(
                                  height: 10,
                                ),
                                messageWidget(
                                  text: messages[index].content!,
                                  name: messages[index].senderName!,
                                  message: messages[index],
                                  recieved: messages[index].senderId != userID,
                                  firstRecieved:
                                      messages[index].senderId != userID &&
                                          (index == messages.length - 1 ||
                                              messages[index].senderId !=
                                                  messages[index + 1].senderId),
                                ),
                              ],
                            );
                          },
                        );
                      },
                    );
                  },
                ),
              ),
            ),
            Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            children: [
                              if (replyMessage != null)
                                Container(
                                  decoration: const BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(10),
                                          topRight: Radius.circular(10))),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 8),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  const BorderRadius.all(
                                                      Radius.circular(10)),
                                              color: grey.withOpacity(0.2)),
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 8, vertical: 5),
                                          child: Stack(
                                            children: [
                                              Text(
                                                replyMessage!.content!,
                                                style: const TextStyle(
                                                  fontSize: 14,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w400,
                                                ),
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              Positioned(
                                                top: 0,
                                                right: 0,
                                                child: GestureDetector(
                                                  onTap: () {
                                                    clearReply();
                                                  },
                                                  child: Icon(
                                                    Icons.close_rounded,
                                                    size: 15,
                                                  ),
                                                ),
                                              )
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              Material(
                                elevation: 4,
                                color: lightBlueTheme,
                                shadowColor: Colors.black.withOpacity(0.25),
                                child: TextField(
                                  onSubmitted: (value) => replyMessage != null
                                      ? _sendMessagewithReply()
                                      : _sendMessage(),
                                  onEditingComplete: () {
                                    debugPrint("stopped typing");
                                  },
                                  onTap: () async {
                                    print("typing");
                                    await _socket.userTyping(chat!.chatID!);
                                  },
                                  controller: _messageController,
                                  focusNode: _messageFocusNode,
                                  decoration: InputDecoration(
                                    isDense: true,
                                    hintText: "Write your Message",
                                    hintStyle: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                      color: lightGreyTheme,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 10,
                                    ),
                                    filled: true,
                                    fillColor: white,
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: replyMessage != null
                                          ? const BorderRadius.only(
                                              bottomLeft: Radius.circular(10),
                                              bottomRight: Radius.circular(10))
                                          : BorderRadius.circular(10),
                                      borderSide: BorderSide.none,
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: replyMessage != null
                                          ? const BorderRadius.only(
                                              bottomLeft: Radius.circular(10),
                                              bottomRight: Radius.circular(10))
                                          : BorderRadius.circular(10),
                                      borderSide: BorderSide.none,
                                    ),
                                    suffixIcon: Padding(
                                      padding: const EdgeInsets.only(right: 10),
                                      child: TextButton(
                                        onPressed: () {
                                          replyMessage != null
                                              ? _sendMessagewithReply()
                                              : _sendMessage();
                                          clearReply();
                                        },
                                        child: const Text(
                                          "Send",
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w400,
                                            color: headerGradient1,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            if (_attachmentOverlayEntry == null) {
                              _showAttachmentOverlay(context);
                            } else {
                              _removeAttachmentOverlay();
                            }
                          },
                          icon: const ImageIcon(
                            AssetImage(images.attachmentIcon),
                            size: 24,
                            color: headerGradient2,
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: const ImageIcon(
                            AssetImage(images.copyIcon),
                            size: 24,
                            color: headerGradient2,
                          ),
                        ),
                      ],
                    ),
                  ],
                )),
            const SizedBox(height: 20),
            ValueListenableBuilder(
              valueListenable: showEmojiPicker,
              builder: (context, showEmojiPickerValue, child) {
                return GestureDetector(
                  onTap: () {
                    if (showEmojiPicker.value) {
                      showEmojiPicker.value = true;
                    }
                  },
                  child: Offstage(
                    offstage: showEmojiPicker.value,
                    child: EmojiPicker(
                      onEmojiSelected: (category, emoji) {
                        if (selectedMessage != -1) {
                          _addReaction(
                              selectedMessage, chat!.chatID!, emoji.emoji);
                          showEmojiPicker.value = true;
                        }
                      },
                      onBackspacePressed: () {},
                      config: Config(
                        emojiTextStyle: const TextStyle(fontSize: 18),
                        bottomActionBarConfig: BottomActionBarConfig(
                          backgroundColor: white,
                          buttonColor: white,
                          buttonIconColor: black,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Align dayWidget(String date) {
    return Align(
      alignment: Alignment.center,
      child: Container(
        decoration: BoxDecoration(
          color: headerGradient2,
          borderRadius: BorderRadius.circular(5),
        ),
        height: 25,
        width: 75,
        child: Center(
          child: Text(
            date,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 12,
              color: white,
            ),
          ),
        ),
      ),
    );
  }

  Align unreadWidget() {
    return Align(
      alignment: Alignment.center,
      child: Container(
        decoration: BoxDecoration(
          color: headerGradient2,
          borderRadius: BorderRadius.circular(5),
        ),
        height: 25,
        width: 150,
        child: Center(
          child: Text(
            "unread Message",
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 12,
              color: white,
            ),
          ),
        ),
      ),
    );
  }

  // ... (Other methods remain unchanged)

  void _showReactionOverlay(
      BuildContext context, GlobalKey key, bool isfirst, int message_id) {
    final overlay = Overlay.of(context);
    final renderBox = key.currentContext!.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);

    final overlayEntry = OverlayEntry(
      builder: (context) => GestureDetector(
        onTap: () {},
        child: Stack(
          children: [
            Positioned(
              top: isfirst
                  ? position.dy - 30
                  : position.dy - 60, // Adjust the position as needed
              left: position.dx + 50,
              // bottom: position.dy - 55,
              child: Material(
                borderRadius: BorderRadius.all(Radius.circular(14)),
                color: Colors.white,
                child: Row(
                  children: [
                    _reactionButton(context, '👍', message_id),
                    _reactionButton(context, '❤️', message_id),
                    _reactionButton(context, '😂', message_id),
                    _reactionButton(context, '😮', message_id),
                    _reactionButton(context, '😢', message_id),
                    _reactionButton(context, '+', message_id),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );

    overlay.insert(overlayEntry);

    // Remove the overlay when a reaction is selected or tapped outside
    Future.delayed(const Duration(seconds: 3), () {
      overlayEntry.remove();
    });
  }

  InkWell messageWidget({
    required String text,
    required String name,
    required MessageModel message,
    bool recieved = false,
    bool firstRecieved = false,
  }) {
    final GlobalKey messageKey = GlobalKey(); // Key to track position

    return InkWell(
      key: messageKey,
      onLongPress: () {
        setState(() {
          // Enter selection mode and toggle selection of the message
          selectMode = true;
          if (selectedMessages.contains(message.id!)) {
            selectedMessages.remove(message.id!);
          } else {
            selectedMessages.add(message.id!);
          }
        });
        _showReactionOverlay(
          context,
          messageKey,
          firstRecieved,
          message.id!,
        ); // Show reaction overlay on long press
      },
      onTap: () {
        if (selectMode) {
          if (selectedMessages.contains(message.id!)) {
            selectedMessages.remove(message.id!);
          } else {
            selectedMessages.add(message.id!);
          }
          setState(() {});
        }
      },
      child: Container(
        color: selectMode && selectedMessages.contains(message.id)
            ? headerGradient2.withOpacity(0.3)
            : null,
        child: Column(
          children: [
            Row(
              mainAxisAlignment:
                  recieved ? MainAxisAlignment.start : MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                recieved
                    ? firstRecieved
                        ? const CircleAvatar(
                            radius: 20,
                            child: Icon(Icons.person),
                          )
                        : const SizedBox(
                            width: 40,
                          )
                    : const SizedBox(),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: recieved
                        ? CrossAxisAlignment.start
                        : CrossAxisAlignment.end,
                    children: [
                      if (recieved && firstRecieved) ...[
                        Text(
                          name,
                          style: const TextStyle(
                              fontWeight: FontWeight.w400,
                              fontSize: 14,
                              color: Colors.black),
                        ),
                        const SizedBox(height: 12),
                      ],
                      Stack(
                        children: [
                          IntrinsicWidth(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 5,
                                  ),
                                  decoration: BoxDecoration(
                                    color: recieved
                                        ? Colors.white
                                        : headerGradient2,
                                    borderRadius: BorderRadius.only(
                                      topRight: recieved
                                          ? const Radius.circular(10)
                                          : const Radius.circular(0),
                                      topLeft: recieved
                                          ? const Radius.circular(0)
                                          : const Radius.circular(10),
                                      bottomLeft: const Radius.circular(10),
                                      bottomRight: const Radius.circular(10),
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      message.parentMessageId != null
                                          ? Container(
                                              decoration: BoxDecoration(
                                                  color: white.withOpacity(0.2),
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(8))),
                                              padding: const EdgeInsets.all(5),
                                              child: Text(
                                                _getrepliedMessage(
                                                        message.parentMessageId)
                                                    .content!,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  color: recieved
                                                      ? Colors.black
                                                      : Colors.white,
                                                  fontSize: 12,
                                                ),
                                              ))
                                          : const SizedBox(),
                                      message.content != ""
                                          ? Text(
                                              text,
                                              overflow: TextOverflow.fade,
                                              maxLines: 10,
                                              style: TextStyle(
                                                fontWeight: FontWeight.w400,
                                                fontSize: 12,
                                                color: recieved
                                                    ? Colors.black
                                                    : Colors.white,
                                              ),
                                            )
                                          : const SizedBox(),

                                      // Display file information if available
                                      if (message.fileInfo != null &&
                                          message.fileInfo!.isNotEmpty)
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          children:
                                              message.fileInfo!.map((file) {
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 4.0),
                                              child: Column(
                                                // crossAxisAlignment:
                                                //     CrossAxisAlignment.end,
                                                children: [
                                                  // Display the image
                                                  FutureBuilder<Uint8List?>(
                                                      future: getFileBytes(
                                                          file.downloadUrl!),
                                                      builder:
                                                          (context, snapshot) {
                                                        if (snapshot
                                                                .connectionState ==
                                                            ConnectionState
                                                                .waiting) {
                                                          return const Center(
                                                              child:
                                                                  CircularProgressIndicator(
                                                            color: white,
                                                          )); // Show loading
                                                        } else if (snapshot
                                                                .hasError ||
                                                            snapshot.data ==
                                                                null) {
                                                          return const Text(
                                                              "Image not found");
                                                        } else {
                                                          String extension = file
                                                              .originalName!
                                                              .split('.')
                                                              .last
                                                              .toLowerCase();
                                                          if (extension == 'png' ||
                                                              extension ==
                                                                  'jpg' ||
                                                              extension ==
                                                                  'jpeg') {
                                                            return GestureDetector(
                                                              onTap: () {
                                                                downloadFile(
                                                                    context,
                                                                    file
                                                                        .originalName!,
                                                                    snapshot
                                                                        .data!);
                                                              },
                                                              child: Column(
                                                                children: [
                                                                  Image.memory(
                                                                    snapshot
                                                                        .data!,
                                                                    width: 100,
                                                                    height: 100,
                                                                    fit: BoxFit
                                                                        .cover,
                                                                  ),
                                                                ],
                                                              ),
                                                            );
                                                          } else {
                                                            return Container(
                                                              decoration: BoxDecoration(
                                                                  color: white
                                                                      .withOpacity(
                                                                          0.2),
                                                                  borderRadius:
                                                                      const BorderRadius
                                                                          .all(
                                                                          Radius.circular(
                                                                              8))),
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(5),
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Text(
                                                                    file.originalName ??
                                                                        "File",
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                    style:
                                                                        TextStyle(
                                                                      color: recieved
                                                                          ? Colors
                                                                              .black
                                                                          : Colors
                                                                              .white,
                                                                      fontSize:
                                                                          12,
                                                                    ),
                                                                  ),
                                                                  IconButton(
                                                                    icon: const Icon(
                                                                        Icons
                                                                            .file_download_outlined,
                                                                        color: Colors
                                                                            .white),
                                                                    onPressed:
                                                                        () async {
                                                                      await downloadFile(
                                                                          context,
                                                                          file
                                                                              .originalName!,
                                                                          snapshot
                                                                              .data!);
                                                                    },
                                                                  ),
                                                                ],
                                                              ),
                                                            );
                                                          }
                                                        }
                                                      }),
                                                  //
                                                ],
                                              ),
                                            );
                                          }).toList(),
                                        ),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: Text(
                                          formatDateTimeToTime(
                                              message.createdAt!),
                                          style: TextStyle(
                                            fontSize: 7,
                                            fontWeight: FontWeight.w400,
                                            color: recieved
                                                ? Color(0xFF797C7B)
                                                : Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 5),
                                const SizedBox(height: 12),
                              ],
                            ),
                          ),
                          if (message.reactions != null &&
                              message.reactions!.isNotEmpty)
                            Positioned(
                              bottom: 2,
                              left: recieved ? 2 : null,
                              right: recieved ? null : 3,
                              child: GestureDetector(
                                onTap: () {
                                  _showReactionModal(
                                      context,
                                      jsonDecode(message.reactions!),
                                      message.id!);
                                },
                                child: Container(
                                  padding: EdgeInsets.all(1),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)),
                                  ),
                                  child: Row(
                                    children: [
                                      const SizedBox(width: 5),
                                      _buildReactions(
                                          jsonDecode(message.reactions!)),
                                      if (jsonDecode(message.reactions!)
                                              .length >
                                          1) ...[
                                        Text(
                                          jsonDecode(message.reactions!)
                                              .length
                                              .toString(),
                                          style: TextStyle(fontSize: 12),
                                        ),
                                        const SizedBox(width: 5),
                                      ],
                                    ],
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReactions(List<dynamic> reactions) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: reactions.map<Widget>((reaction) {
        return Padding(
          padding: const EdgeInsets.only(right: 4.0),
          child: Container(
            child: Text(
              reaction['reaction'],
              style: const TextStyle(fontSize: 12),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _showReactionModal(
      BuildContext context, List<dynamic> reactions, int messageID) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent, // To make the background transparent
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Reactions",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              // const SizedBox(height: 20),
              // Display user reactions
              ListView.builder(
                shrinkWrap:
                    true, // Makes sure the ListView doesn't take up the full screen
                itemCount: reactions.length,
                itemBuilder: (context, index) {
                  final userReaction = reactions[index];
                  print(userReaction);
                  return FutureBuilder(
                      future: _fetchUser(userReaction["userId"]),
                      builder: (context, snapshot) {
                        print(snapshot.connectionState);
                        if (snapshot.connectionState == ConnectionState.done) {
                          CurrentUser? usr = snapshot.data as CurrentUser;
                          return ListTile(
                            onTap: () {
                              print(usr.id is String);
                              print(userID!);
                              if (int.parse(usr.id) == userID!) {
                                print("delete reaction called");
                                _deleteReaction(messageID, chat!.chatID!,
                                    userReaction['reaction']);
                              }
                            },
                            leading: const CircleAvatar(
                                // backgroundImage:
                                //     NetworkImage(userReaction['profilePicUrl']),
                                ),
                            title: Text(usr.name ?? " "),
                            subtitle: usr.id == userID.toString()
                                ? Text("Tap to Remove")
                                : null,
                            trailing: Text(
                              userReaction['reaction'],
                              style: TextStyle(
                                  fontSize: 14), // Emoji or reaction size
                            ),
                          );
                        }
                        return const Center(
                          child: CircularProgressIndicator(
                            color: headerGradient2,
                          ),
                        );
                      });
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _reactionButton(BuildContext context, String emoji, int messageId) {
    return GestureDetector(
      onTap: () {
        if (emoji == "+") {
          selectedMessage = messageId;
          // Show the emoji picker
          showEmojiPicker.value = false;
        } else {
          _addReaction(messageId, chat!.chatID!, emoji);
        }
      },
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Text(
          emoji,
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }

  void _showAttachmentOverlay(BuildContext context) {
    if (_attachmentOverlayEntry != null) {
      return; // Don't create a new overlay if one already exists
    }

    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox;
    final position = renderBox.localToGlobal(Offset.zero);

    _attachmentOverlayEntry = OverlayEntry(
      builder: (context) => Positioned(
        bottom: MediaQuery.of(context).viewInsets.bottom +
            100, // Position above the message bar
        left: 20,
        right: 20,
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _attachmentOption(Icons.camera_alt, "Camera", () async {
                  final returnImage = await ImagePicker().pickImage(
                    source: ImageSource.camera,
                    maxHeight: 1000,
                    maxWidth: 1000,
                  );
                  if (returnImage == null) return;
                  var selectedImage = File(returnImage.path);
                  String fileName = selectedImage.uri.pathSegments.last;
                  print(selectedImage.readAsBytesSync());
                  print(fileName);
                  _sendMessage(image: selectedImage, imageNmae: fileName);
                  _removeAttachmentOverlay(); // Close overlay after selectionverlay after selection
                }),
                _attachmentOption(Icons.photo, "Gallery", () async {
                  final returnImage = await ImagePicker()
                      .pickImage(source: ImageSource.gallery);
                  if (returnImage == null) return;
                  var selectedImage = File(returnImage.path);
                  String fileName = selectedImage.uri.pathSegments.last;
                  _sendMessage(image: selectedImage, imageNmae: fileName);
                  _removeAttachmentOverlay(); // Close overlay after selection
                }),
                _attachmentOption(Icons.insert_drive_file, "Documents",
                    () async {
                  final result = await FilePicker.platform.pickFiles(
                    allowMultiple:
                        false, // Set to true if you want to allow multiple files
                    type: FileType
                        .any, // You can specify the type of files allowed
                  );
                  if (result != null && result.files.isNotEmpty) {
                    // Get the file from the result
                    final file = File(result.files.single.path!);
                    String fileName = result.files.single.name;

                    // You can send the file if needed
                    _sendMessage(image: file, imageNmae: fileName);
                  }

                  _removeAttachmentOverlay(); // Close overlay after selection
                }),
              ],
            ),
          ),
        ),
      ),
    );

    overlay.insert(_attachmentOverlayEntry!);
  }

  Widget _attachmentOption(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: headerGradient2, size: 27),
          const SizedBox(height: 5),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  void _removeAttachmentOverlay() {
    if (_attachmentOverlayEntry != null) {
      _attachmentOverlayEntry!.remove();
      _attachmentOverlayEntry = null;
    }
  }
}
