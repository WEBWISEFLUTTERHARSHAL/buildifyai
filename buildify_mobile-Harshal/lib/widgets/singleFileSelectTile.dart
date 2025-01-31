import 'package:Buildify_AI/utils/api_calls.dart';
import 'package:Buildify_AI/utils/colors.dart';
import 'package:Buildify_AI/utils/download.dart';
import 'package:Buildify_AI/utils/strings.dart';
import 'package:Buildify_AI/widgets/generalDropdown.dart';
import 'package:Buildify_AI/widgets/generalPopUp.dart';
import 'package:Buildify_AI/widgets/generalTextField.dart';
import 'package:flutter/material.dart';

class SingleFileSelectTile extends StatefulWidget {
  String? id;
  String? fileName;
  double? fileSize;
  String? fileId;
  int? uploadedUserId;
  ValueNotifier checkBoxVal = ValueNotifier(false);
  ValueSetter? singleFileDeleteCallback;
  ValueSetter? isCheckBoxValueChanged;
  List<dynamic>? folderList;

  SingleFileSelectTile({
    super.key,
    this.id,
    this.fileName,
    this.fileSize,
    this.fileId,
    this.uploadedUserId,
    required this.checkBoxVal,
    this.singleFileDeleteCallback,
    this.isCheckBoxValueChanged,
    this.folderList,
  });

  @override
  State<SingleFileSelectTile> createState() => _SingleFileSelectTileState();
}

class _SingleFileSelectTileState extends State<SingleFileSelectTile> {
  TextEditingController fileNameController = TextEditingController();
  String? selectedFolderId = null;

  String formatFileSize(double fileSizeInBytes) {
    double sizeInKB = fileSizeInBytes / 1024;
    double sizeInMB = sizeInKB / 1024;
    double sizeInGB = sizeInMB / 1024;

    if (sizeInKB < 1024) {
      return "${sizeInKB.toStringAsFixed(1)} KB";
    } else if (sizeInMB < 1024) {
      return "${sizeInMB.toStringAsFixed(1)} MB";
    } else {
      return "${sizeInGB.toStringAsFixed(1)} GB";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(widget.id.toString()),
      confirmDismiss: (direction) {
        return showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text("Delete File"),
            content: const Text(
              "Are you sure you want to delete this file?",
              style: TextStyle(
                fontSize: 16,
              ),
            ),
            backgroundColor: popUpDialog,
            actions: [
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: darkBlueTheme,
                  foregroundColor: white,
                ),
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text("No"),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  backgroundColor: darkBlueTheme,
                  foregroundColor: white,
                ),
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text("Yes"),
              ),
            ],
          ),
        );
      },
      onDismissed: (direction) async {
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              contentPadding: EdgeInsets.all(40),
              backgroundColor: popUpDialog,
              title: Text(strings.deletingFiles),
              content: SizedBox(
                height: 50,
                width: 50,
                child: FittedBox(
                  fit: BoxFit.contain,
                  child: CircularProgressIndicator(
                    backgroundColor: progressBg,
                    color: darkBlueTheme,
                    strokeCap: StrokeCap.round,
                    strokeWidth: 2.5,
                  ),
                ),
              ),
            );
          },
        );
        var responseMessage = await deleteFile(
          fileId: widget.id.toString(),
        );
        Navigator.pop(context);
        if (responseMessage != "OK") {
          showDialog(
            context: context,
            builder: (context) {
              return GeneralPopUp(
                message: responseMessage,
              );
            },
          );
        } else {
          widget.singleFileDeleteCallback!(true);
        }
      },
      direction: DismissDirection.endToStart,
      background: Container(
        margin: EdgeInsets.only(bottom: 5),
        decoration: BoxDecoration(
          color: darkBlueTheme,
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: EdgeInsets.all(12.0),
            child: Icon(Icons.delete_sweep_rounded, color: white),
          ),
        ),
      ),
      child: Container(
        color: transparent,
        child: Container(
          margin: EdgeInsets.only(bottom: 5),
          height: 50,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(
              Radius.circular(10),
            ),
            color: white,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ValueListenableBuilder(
                  valueListenable: widget.checkBoxVal,
                  builder: (context, value, child) {
                    return Checkbox(
                      value: widget.checkBoxVal.value,
                      onChanged: (value) {
                        widget.checkBoxVal.value = value!;
                        widget.isCheckBoxValueChanged!(value);
                      },
                      fillColor: widget.checkBoxVal.value
                          ? WidgetStatePropertyAll(darkBlueTheme)
                          : WidgetStatePropertyAll(
                              Color(0xFFF1F4FD),
                            ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3),
                      ),
                      side: BorderSide.none,
                      splashRadius: 1,
                    );
                  }),
              const SizedBox(
                width: 5,
              ),
              Flexible(
                child: Row(
                  children: [
                    Icon(
                      Icons.insert_drive_file_rounded,
                      color: Color(0xFF002E77),
                      size: 18,
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Flexible(
                      child: Text(
                        widget.fileName.toString(),
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF575757),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                width: 5,
              ),
              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: 180,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        fit: FlexFit.tight,
                        child: Text(
                          widget.uploadedUserId.toString(),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF575757)),
                        ),
                      ),
                      Flexible(
                        fit: FlexFit.tight,
                        child: Text(
                          formatFileSize(widget.fileSize!),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF575757)),
                        ),
                      ),
                      Flexible(
                        fit: FlexFit.tight,
                        child: PopupMenuButton<String>(
                          padding: EdgeInsets.zero,
                          color: white,
                          menuPadding: EdgeInsets.all(5),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 5,
                          offset: Offset(0, 40),
                          icon: Icon(
                            Icons.more_vert,
                            size: 18,
                          ),
                          itemBuilder: (context) {
                            return [
                              PopupMenuItem(
                                padding: EdgeInsets.all(5),
                                height: 35,
                                child: Text(
                                  strings.downloadFile,
                                  style: TextStyle(
                                    fontSize: 12,
                                  ),
                                ),
                                value: "Download File",
                                onTap: () async {
                                  var bytes = await getFileBytes(
                                      "https://backend-api-topaz.vercel.app/api/download/${widget.fileId}");
                                  await downloadFile(
                                      context, widget.fileName!, bytes!);
                                },
                              ),
                              PopupMenuItem(
                                padding: EdgeInsets.all(5),
                                height: 35,
                                child: Text(
                                  strings.rename,
                                  style: TextStyle(
                                    fontSize: 12,
                                  ),
                                ),
                                value: "Rename",
                                onTap: () {
                                  fileNameController.text = widget.fileName!;
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        backgroundColor: popUpDialog,
                                        alignment: Alignment.center,
                                        scrollable: true,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 30,
                                        ),
                                        title: Text(
                                          strings.fileName,
                                        ),
                                        content: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            SizedBox(
                                              width: 200,
                                              child: GeneralTextField(
                                                controller: fileNameController,
                                                hintText: strings.enterFileName,
                                                maxLines: 1,
                                              ),
                                            ),
                                            SizedBox(
                                              width: 10,
                                            ),
                                            IconButton(
                                              onPressed: () async {
                                                if (fileNameController.text !=
                                                        "" &&
                                                    fileNameController
                                                            .text.length >
                                                        0) {
                                                  var responseMessage =
                                                      await updateFileDetails(
                                                    fileId: widget.id,
                                                    fileName:
                                                        fileNameController.text,
                                                  );
                                                  if (responseMessage != "OK") {
                                                    showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        return GeneralPopUp(
                                                          message:
                                                              responseMessage,
                                                        );
                                                      },
                                                    );
                                                  }
                                                  setState(() {
                                                    widget.fileName =
                                                        fileNameController.text;
                                                  });
                                                  fileNameController.clear();
                                                  Navigator.pop(context);
                                                }
                                              },
                                              icon: Icon(
                                                Icons.check_rounded,
                                              ),
                                              style: IconButton.styleFrom(
                                                backgroundColor: lightBlueTheme,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                foregroundColor: darkBlueTheme,
                                                padding: EdgeInsets.zero,
                                                visualDensity: VisualDensity(
                                                  horizontal: -1,
                                                  vertical: -1,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  );
                                },
                              ),
                              PopupMenuItem(
                                padding: EdgeInsets.all(5),
                                height: 35,
                                child: Text(
                                  strings.moveToFolder,
                                  style: TextStyle(
                                    fontSize: 12,
                                  ),
                                ),
                                value: "Move To Folder",
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) {
                                      return AlertDialog(
                                        backgroundColor: popUpDialog,
                                        alignment: Alignment.center,
                                        scrollable: true,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        contentPadding: EdgeInsets.symmetric(
                                          horizontal: 20,
                                          vertical: 30,
                                        ),
                                        title: Text(
                                          strings.moveToFolder,
                                        ),
                                        content: GeneralDropdown(
                                          hintText: "Select Folder",
                                          selectedValue:
                                              ValueNotifier(selectedFolderId),
                                          onChanged: (value) {
                                            selectedFolderId = value!;
                                          },
                                          items: widget.folderList!
                                              .map(
                                                (e) => DropdownMenuItem(
                                                  value: e.id,
                                                  child: Text(
                                                    e.name,
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                        ),
                                        actions: [
                                          TextButton(
                                            style: TextButton.styleFrom(
                                              backgroundColor: darkBlueTheme,
                                              foregroundColor: white,
                                            ),
                                            onPressed: () async {
                                              var responseMessage =
                                                  await moveToFolder(
                                                fileId: widget.id,
                                                parentFolderId:
                                                    selectedFolderId,
                                              );
                                              if (responseMessage != "OK") {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return GeneralPopUp(
                                                      message: responseMessage,
                                                    );
                                                  },
                                                );
                                              }
                                              widget.singleFileDeleteCallback!(
                                                  true);
                                              Navigator.of(context).pop();
                                            },
                                            child: Text(strings.ok),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                              ),
                            ];
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
