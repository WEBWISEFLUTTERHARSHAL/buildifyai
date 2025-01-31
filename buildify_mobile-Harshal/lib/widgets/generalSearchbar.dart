import 'package:Buildify_AI/utils/colors.dart';
import 'package:Buildify_AI/utils/strings.dart';
import 'package:flutter/material.dart';

TextEditingController searchController = TextEditingController();

SearchBar generalSearchBar({
  VoidCallback? oninit,
  Function? onChanged,
  Function? onsubmit,
  VoidCallback? onCancel,
}) {
  return SearchBar(
    controller: searchController,
    hintText: "Search",
    hintStyle: const WidgetStatePropertyAll(
      TextStyle(color: Color(0xFF9a9a9a), fontSize: 12),
    ),
    textStyle: const WidgetStatePropertyAll(
      TextStyle(fontSize: 12),
    ),
    constraints: const BoxConstraints(
      minHeight: 50,
      maxHeight: 50,
    ),
    onTap: oninit,
    onChanged: (value) {
      if (onChanged != null) onChanged(value);
    },
    onSubmitted: (value) {
      if (onsubmit != null) onsubmit(value);
      searchController.text = "";
    },
    backgroundColor: const WidgetStatePropertyAll(white),
    elevation: const WidgetStatePropertyAll(0),
    shape: WidgetStatePropertyAll(
      RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
    leading: const ImageIcon(
      AssetImage(images.searchIcon),
      color: Color(0xff002E77),
      size: 18,
    ),
    trailing: [
      IconButton(
        onPressed: () {
          searchController.text = "";
          onCancel!();
        },
        icon: const Icon(
          Icons.close_rounded,
          color: grey,
          size: 18,
        ),
      ),
    ],
    padding: const WidgetStatePropertyAll(
      EdgeInsets.only(
        left: 20,
      ),
    ),
  );
}
