import 'package:Buildify_AI/screens/fileSelect.dart';
import 'package:Buildify_AI/utils/api_calls.dart';
import 'package:Buildify_AI/utils/colors.dart';
import 'package:Buildify_AI/utils/download.dart';
import 'package:Buildify_AI/widgets/generalPopUp.dart';
import 'package:Buildify_AI/widgets/generalTextField.dart';
import 'package:flutter/material.dart';
import '../utils/strings.dart';

class SingleFileManagerTile extends StatefulWidget {
  String? id;
  String? name;
  IconData? icon;
  String? fileId;
  ValueNotifier checkBoxVal = ValueNotifier(false);
  ValueSetter? singleTileDeleteCallback;
  ValueSetter? isCheckBoxValueChanged;
  List<dynamic>? folderList;

  SingleFileManagerTile({
    super.key,
    this.id,
    this.name,
    this.icon,
    this.fileId,
    required this.checkBoxVal,
    this.singleTileDeleteCallback,
    this.isCheckBoxValueChanged,
    this.folderList,
  });

  @override
  State<SingleFileManagerTile> createState() => _SingleFileManagerTileState();
}

class _SingleFileManagerTileState extends State<SingleFileManagerTile>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

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
    TextEditingController nameController = TextEditingController();

    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Material(
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: widget.icon == Icons.folder_rounded
              ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FileSelect(
                        parentFolderId: widget.id,
                        folderList: widget.folderList,
                      ),
                    ),
                  );
                }
              : null,
          borderRadius: BorderRadius.circular(10),
          child: Ink(
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
                        widget.icon,
                        color: Color(0xFF002E77),
                        size: 20,
                      ),
                      SizedBox(
                        width: 10,
                      ),
                      Flexible(
                        child: Text(
                          widget.name.toString(),
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
                        widget.icon == Icons.folder_rounded
                            ? PopupMenuItem(
                                padding: EdgeInsets.all(5),
                                height: 35,
                                child: Text(
                                  strings.view,
                                  style: TextStyle(
                                    fontSize: 12,
                                  ),
                                ),
                                value: "View",
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => FileSelect(
                                        parentFolderId: widget.id,
                                        folderList: widget.folderList,
                                      ),
                                    ),
                                  );
                                },
                              )
                            : PopupMenuItem(
                                height: 0,
                                enabled: false,
                                child: SizedBox.shrink(),
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
                            nameController.text = widget.name.toString();
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  backgroundColor: popUpDialog,
                                  alignment: Alignment.center,
                                  scrollable: true,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 30,
                                  ),
                                  title: Text(
                                    widget.icon == Icons.folder_rounded
                                        ? strings.folderName
                                        : strings.fileName,
                                  ),
                                  content: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        width: 200,
                                        child: GeneralTextField(
                                          controller: nameController,
                                          hintText: widget.icon ==
                                                  Icons.folder_rounded
                                              ? strings.enterFolderName
                                              : strings.enterFileName,
                                          maxLines: 1,
                                        ),
                                      ),
                                      SizedBox(
                                        width: 10,
                                      ),
                                      IconButton(
                                        onPressed: () async {
                                          var responseMessage;
                                          if (nameController.text != "" &&
                                              nameController.text.length > 0) {
                                            widget.icon == Icons.folder_rounded
                                                ? responseMessage =
                                                    await updateFolderDetails(
                                                        folderId: widget.id,
                                                        folderName:
                                                            nameController.text)
                                                : responseMessage =
                                                    await updateFileDetails(
                                                    fileId: widget.id,
                                                    fileName:
                                                        nameController.text,
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
                                            setState(() {
                                              widget.icon ==
                                                      Icons.folder_rounded
                                                  ? widget.name = nameController
                                                      .text
                                                      .toLowerCase()
                                                      .replaceFirst(
                                                        nameController.text[0]
                                                            .toLowerCase(),
                                                        nameController.text[0]
                                                            .toUpperCase(),
                                                      )
                                                  : widget.name =
                                                      nameController.text;
                                            });
                                            nameController.clear();
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
                            strings.download,
                            style: TextStyle(
                              fontSize: 12,
                            ),
                          ),
                          value: "Download",
                          onTap: () async {
                            if (widget.icon == Icons.folder_rounded) {
                              var bytes = await getFileBytes(
                                  "https://backend-api-topaz.vercel.app/api/download-folder/${widget.id}");
                              await downloadFile(context, widget.name!, bytes!,
                                  type: 'folder');
                            } else {
                              var bytes = await getFileBytes(
                                  "https://backend-api-topaz.vercel.app/api/download/${widget.fileId}");
                              await downloadFile(context, widget.name!, bytes!);
                            }
                          },
                        ),
                        PopupMenuItem(
                          padding: EdgeInsets.all(5),
                          height: 35,
                          child: Text(
                            strings.delete,
                            style: TextStyle(
                              color: red,
                              fontSize: 12,
                            ),
                          ),
                          value: "Delete",
                          onTap: () async {
                            var deleteResponse;
                            showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  contentPadding: EdgeInsets.all(40),
                                  backgroundColor: popUpDialog,
                                  title: Text(
                                      widget.icon == Icons.folder_rounded
                                          ? strings.deletingFolder
                                          : strings.deletingFiles),
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
                            widget.icon == Icons.folder_rounded
                                ? {
                                    deleteResponse = await deleteFolder(
                                      folderId: widget.id.toString(),
                                    ),
                                  }
                                : {
                                    deleteResponse = await deleteFile(
                                      fileId: widget.id.toString(),
                                    ),
                                  };
                            Navigator.pop(context);
                            if (deleteResponse != "OK") {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return GeneralPopUp(
                                    message: deleteResponse,
                                  );
                                },
                              );
                            } else {
                              widget.singleTileDeleteCallback!(true);
                            }
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
      ),
    );
  }
}
