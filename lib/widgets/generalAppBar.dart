import 'package:Buildify_AI/utils/colors.dart';
import 'package:flutter/material.dart';

class GeneralAppbar extends StatelessWidget implements PreferredSizeWidget {
  String title;
  GeneralAppbar({
    super.key,
    required this.title,
  });

  @override
  Size get preferredSize => const Size.fromHeight(95);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      flexibleSpace: Container(
        decoration: BoxDecoration(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(10),
              bottomRight: Radius.circular(10),
            ),
            gradient: LinearGradient(
              colors: [
                headerGradient2,
                headerGradient1,
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 20,
                offset: const Offset(0, -7),
              ),
            ]),
      ),
      leading: Padding(
        padding: const EdgeInsets.only(left: 10),
        child: IconButton(
          padding: EdgeInsets.zero,
          icon: const Icon(
            Icons.close_rounded,
            color: lightGrey,
            size: 30,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      toolbarHeight: 95,
      centerTitle: true,
      title: Text(
        title,
        style: TextStyle(
          color: white,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

selectedMessageAppbar(BuildContext context, String title,
    {VoidCallback? onCancel,
    VoidCallback? onReply,
    VoidCallback? onCopy,
    VoidCallback? onForward,
    VoidCallback? onDelete,
    required bool showReply}) {
  return AppBar(
    flexibleSpace: Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(10),
          bottomRight: Radius.circular(10),
        ),
        gradient: LinearGradient(
          colors: [
            headerGradient2,
            headerGradient1,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, -7),
          ),
        ],
      ),
    ),
    leading: Padding(
      padding: const EdgeInsets.only(left: 10),
      child: IconButton(
        padding: EdgeInsets.zero,
        icon: const Icon(
          Icons.close_rounded,
          color: lightGrey,
          size: 30,
        ),
        onPressed: onCancel, // Function to cancel selection
      ),
    ),
    toolbarHeight: 95,
    centerTitle: true,
    actions: [
      showReply
          ? IconButton(
              icon: Icon(
                Icons.reply_rounded,
                color: white,
                size: 24,
              ),
              onPressed:
                  onReply, // Define the onReply function for reply action
            )
          : const SizedBox(),
      IconButton(
        icon: Icon(
          Icons.forward_rounded,
          color: white,
          size: 24,
        ),
        onPressed:
            onForward, // Define the onForward function for forward action
      ),
      IconButton(
        icon: Icon(
          Icons.copy_rounded,
          color: white,
          size: 24,
        ),
        onPressed: onCopy, // Define the onCopy function for copy action
      ),
      IconButton(
        icon: Icon(
          Icons.delete_rounded,
          color: white,
          size: 24,
        ),
        onPressed: onDelete, // Define the onCopy function for copy action
      ),
      const SizedBox(width: 10), // Optional spacing after icons
    ],
  );
}
