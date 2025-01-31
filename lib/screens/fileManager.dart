import 'package:Buildify_AI/main.dart';
import 'package:Buildify_AI/utils/api_calls.dart';
import 'package:Buildify_AI/utils/colors.dart';
import 'package:Buildify_AI/utils/strings.dart';
import 'package:Buildify_AI/widgets/generalAppBar.dart';
import 'package:Buildify_AI/widgets/generalButton.dart';
import 'package:Buildify_AI/widgets/generalPopUp.dart';
import 'package:Buildify_AI/widgets/generalSearchbar.dart';
import 'package:Buildify_AI/widgets/generalTextField.dart';
import 'package:Buildify_AI/widgets/singleFileManagerTile.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class FileManager extends StatefulWidget {
  const FileManager({super.key});

  @override
  State<FileManager> createState() => _FileManagerState();
}

class _FileManagerState extends State<FileManager> {
  ValueNotifier isAllFilesSelected = ValueNotifier(false);
  ValueNotifier fetchList = ValueNotifier(false);
  ValueNotifier updateListData = ValueNotifier(false);
  ValueNotifier buttonName = ValueNotifier(false);
  TextEditingController folderNameController = TextEditingController();
  List<String> selectedFileIds = [];
  List<String> selectedFolderIds = [];

  fetchFoldersAndFiles() async {
    final fetchFolders = fetchFoldersList();
    final fetchFiles = fetchFilesList(
      parentFolderId: null,
    );

    List<dynamic> results = await Future.wait([fetchFolders, fetchFiles]);

    return {
      'foldersList': results[0],
      'filesList': results[1],
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBlueTheme,
      appBar: GeneralAppbar(
        title: strings.fileManager,
      ),
      body: Padding(
        padding: const EdgeInsets.all(25),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            generalSearchBar(
              onChanged: (value) {
                updateListData.value = !updateListData.value;
              },
              onCancel: () {
                searchController.text = "";
                updateListData.value = !updateListData.value;
              },
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              "Files & Folders",
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            Row(
              children: [
                ValueListenableBuilder(
                  valueListenable: isAllFilesSelected,
                  builder: (context, value, child) {
                    return Checkbox(
                      value: isAllFilesSelected.value,
                      onChanged: (value) {
                        isAllFilesSelected.value = value!;
                        buttonName.value = value;
                      },
                      fillColor: isAllFilesSelected.value
                          ? WidgetStatePropertyAll(darkBlueTheme)
                          : WidgetStatePropertyAll(
                              white,
                            ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3),
                      ),
                      side: BorderSide.none,
                      splashRadius: 1,
                    );
                  },
                ),
                const SizedBox(
                  width: 5,
                ),
                Text(
                  "Name",
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF575757)),
                ),
              ],
            ),
            ValueListenableBuilder(
              valueListenable: fetchList,
              builder: (context, value, child) {
                return FutureBuilder(
                  future: fetchFoldersAndFiles(),
                  builder: (context, AsyncSnapshot snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Expanded(
                        child: Center(
                          child: SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              backgroundColor: progressBg,
                              color: darkBlueTheme,
                              strokeCap: StrokeCap.round,
                              strokeWidth: 3,
                            ),
                          ),
                        ),
                      );
                    } else if (snapshot.hasError) {
                      return Center(
                        child: Text('Error: ${snapshot.error}'),
                      );
                    } else if (!snapshot.hasData ||
                        snapshot.data['foldersList'] == null ||
                        snapshot.data['filesList'] == null) {
                      return Center(
                        child: Text(strings.genericDataFetchError),
                      );
                    } else if (snapshot.data['foldersList'].runtimeType ==
                        String) {
                      return Center(
                        child: Text(snapshot.data['foldersList'].toString()),
                      );
                    } else if (snapshot.data['filesList'].runtimeType ==
                        String) {
                      return Center(
                        child: Text(snapshot.data['filesList'].toString()),
                      );
                    } else if (snapshot.data['foldersList'].isEmpty &&
                        snapshot.data['filesList'].isEmpty) {
                      return Expanded(
                        child: Center(
                          child: Text(strings.noDataFound),
                        ),
                      );
                    } else {
                      return Expanded(
                        child: ValueListenableBuilder(
                          valueListenable: updateListData,
                          builder: (context, value, child) {
                            return ListView(
                              physics: ScrollPhysics(),
                              children: [
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: ScrollPhysics(),
                                  itemBuilder: (context, index) =>
                                      ValueListenableBuilder(
                                    valueListenable: isAllFilesSelected,
                                    builder: (context, valueT, child) {
                                      if (isAllFilesSelected.value) {
                                        selectedFolderIds.add(snapshot
                                            .data['foldersList'][index].id);
                                      } else {
                                        selectedFolderIds.remove(snapshot
                                            .data['foldersList'][index].id);
                                      }
                                      if (searchController.text.isNotEmpty &&
                                          searchController.text != "") {
                                        if (snapshot
                                            .data['foldersList'][index].name
                                            .toLowerCase()
                                            .contains(searchController.text
                                                .toLowerCase())) {
                                          return SingleFileManagerTile(
                                            id: snapshot
                                                .data['foldersList'][index].id,
                                            name: snapshot
                                                .data['foldersList'][index]
                                                .name,
                                            checkBoxVal: ValueNotifier(
                                                isAllFilesSelected.value),
                                            icon: Icons.folder_rounded,
                                            isCheckBoxValueChanged: (value) {
                                              if (value) {
                                                selectedFolderIds.add(snapshot
                                                    .data['foldersList'][index]
                                                    .id);
                                              } else {
                                                selectedFolderIds.remove(
                                                    snapshot
                                                        .data['foldersList']
                                                            [index]
                                                        .id);
                                              }
                                              buttonName.value = selectedFileIds
                                                      .isNotEmpty ||
                                                  selectedFolderIds.isNotEmpty;
                                            },
                                            singleTileDeleteCallback: (value) {
                                              fetchList.value =
                                                  !fetchList.value;
                                            },
                                            folderList:
                                                snapshot.data['foldersList'],
                                          );
                                        }
                                      } else {
                                        return SingleFileManagerTile(
                                          id: snapshot
                                              .data['foldersList'][index].id,
                                          name: snapshot
                                              .data['foldersList'][index].name,
                                          checkBoxVal: ValueNotifier(
                                              isAllFilesSelected.value),
                                          icon: Icons.folder_rounded,
                                          isCheckBoxValueChanged: (value) {
                                            if (value) {
                                              selectedFolderIds.add(snapshot
                                                  .data['foldersList'][index]
                                                  .id);
                                            } else {
                                              selectedFolderIds.remove(snapshot
                                                  .data['foldersList'][index]
                                                  .id);
                                            }
                                            buttonName.value = selectedFileIds
                                                    .isNotEmpty ||
                                                selectedFolderIds.isNotEmpty;
                                          },
                                          singleTileDeleteCallback: (value) {
                                            fetchList.value = !fetchList.value;
                                          },
                                          folderList:
                                              snapshot.data['foldersList'],
                                        );
                                      }
                                      return SizedBox.shrink();
                                    },
                                  ),
                                  itemCount:
                                      snapshot.data['foldersList'].length,
                                ),
                                ListView.builder(
                                  shrinkWrap: true,
                                  physics: ScrollPhysics(),
                                  itemBuilder: (context, index) =>
                                      ValueListenableBuilder(
                                    valueListenable: isAllFilesSelected,
                                    builder: (context, valueT, child) {
                                      if (isAllFilesSelected.value) {
                                        selectedFileIds.add(snapshot
                                            .data['filesList'][index].id);
                                      } else {
                                        selectedFileIds.remove(snapshot
                                            .data['filesList'][index].id);
                                      }
                                      if (searchController.text.isNotEmpty &&
                                          searchController.text != "") {
                                        if (snapshot
                                            .data['filesList'][index].name
                                            .toLowerCase()
                                            .contains(searchController.text
                                                .toLowerCase())) {
                                          return SingleFileManagerTile(
                                            id: snapshot
                                                .data['filesList'][index].id,
                                            name: snapshot
                                                .data['filesList'][index].name,
                                            checkBoxVal: ValueNotifier(
                                                isAllFilesSelected.value),
                                            icon:
                                                Icons.insert_drive_file_rounded,
                                            fileId: snapshot
                                                .data['filesList'][index]
                                                .fileId,
                                            isCheckBoxValueChanged: (value) {
                                              if (value) {
                                                selectedFileIds.add(snapshot
                                                    .data['filesList'][index]
                                                    .id);
                                              } else {
                                                selectedFileIds.remove(snapshot
                                                    .data['filesList'][index]
                                                    .id);
                                              }
                                              buttonName
                                                  .value = selectedFolderIds
                                                      .isNotEmpty ||
                                                  selectedFileIds.isNotEmpty;
                                            },
                                            singleTileDeleteCallback: (value) {
                                              fetchList.value =
                                                  !fetchList.value;
                                            },
                                          );
                                        }
                                      } else {
                                        return SingleFileManagerTile(
                                          id: snapshot
                                              .data['filesList'][index].id,
                                          name: snapshot
                                              .data['filesList'][index].name,
                                          checkBoxVal: ValueNotifier(
                                              isAllFilesSelected.value),
                                          icon: Icons.insert_drive_file_rounded,
                                          fileId: snapshot
                                              .data['filesList'][index].fileId,
                                          isCheckBoxValueChanged: (value) {
                                            if (value) {
                                              selectedFileIds.add(snapshot
                                                  .data['filesList'][index].id);
                                            } else {
                                              selectedFileIds.remove(snapshot
                                                  .data['filesList'][index].id);
                                            }
                                            buttonName.value =
                                                selectedFolderIds.isNotEmpty ||
                                                    selectedFileIds.isNotEmpty;
                                          },
                                          singleTileDeleteCallback: (value) {
                                            fetchList.value = !fetchList.value;
                                          },
                                        );
                                      }
                                      return SizedBox.shrink();
                                    },
                                  ),
                                  itemCount: snapshot.data['filesList'].length,
                                ),
                              ],
                            );
                          },
                        ),
                      );
                    }
                  },
                );
              },
            ),
            const SizedBox(
              height: 20,
            ),
            ValueListenableBuilder(
              valueListenable: buttonName,
              builder: (context, value, child) {
                return GeneralButton(
                  onPressed: buttonName.value
                      ? () async {
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
                          for (var i = 0; i < selectedFileIds.length; i++) {
                            var responseMessage = await deleteFile(
                              fileId: selectedFileIds[i].toString(),
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
                          }
                          for (var i = 0; i < selectedFolderIds.length; i++) {
                            var responseMessage = await deleteFolder(
                              folderId: selectedFolderIds[i].toString(),
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
                          }
                          Navigator.pop(context);
                          isAllFilesSelected.value = false;
                          buttonName.value = false;
                          selectedFileIds.clear();
                          selectedFolderIds.clear();
                          fetchList.value = !fetchList.value;
                        }
                      : () async {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                backgroundColor: popUpDialog,
                                alignment: Alignment.center,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                contentPadding: EdgeInsets.all(20),
                                content: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Material(
                                      color: white,
                                      borderRadius: BorderRadius.circular(15),
                                      child: InkWell(
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
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                  horizontal: 20,
                                                  vertical: 30,
                                                ),
                                                title: Text(
                                                  strings.folderName,
                                                ),
                                                content: Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    SizedBox(
                                                      width: 200,
                                                      child: GeneralTextField(
                                                        controller:
                                                            folderNameController,
                                                        hintText: strings
                                                            .enterFolderName,
                                                        maxLines: 1,
                                                      ),
                                                    ),
                                                    SizedBox(
                                                      width: 10,
                                                    ),
                                                    IconButton(
                                                      onPressed: () async {
                                                        if (folderNameController
                                                                    .text !=
                                                                "" &&
                                                            folderNameController
                                                                    .text
                                                                    .length >
                                                                0) {
                                                          var responseMessage =
                                                              await createFolder(
                                                            folderName:
                                                                folderNameController
                                                                    .text
                                                                    .toString(),
                                                          );
                                                          if (responseMessage !=
                                                              "OK") {
                                                            showDialog(
                                                              context: context,
                                                              builder:
                                                                  (context) {
                                                                return GeneralPopUp(
                                                                  message:
                                                                      responseMessage,
                                                                );
                                                              },
                                                            );
                                                          }
                                                          folderNameController
                                                              .clear();
                                                          Navigator.pop(
                                                              context);
                                                          Navigator.pop(
                                                              context);
                                                          fetchList.value =
                                                              !fetchList.value;
                                                        }
                                                      },
                                                      icon: Icon(
                                                        Icons.check_rounded,
                                                      ),
                                                      style:
                                                          IconButton.styleFrom(
                                                        backgroundColor:
                                                            lightBlueTheme,
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                        ),
                                                        foregroundColor:
                                                            darkBlueTheme,
                                                        padding:
                                                            EdgeInsets.zero,
                                                        visualDensity:
                                                            VisualDensity(
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
                                        borderRadius: BorderRadius.circular(15),
                                        child: Container(
                                          height: 120,
                                          width: 120,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              CircleAvatar(
                                                radius: 30,
                                                backgroundColor: lightBlueTheme,
                                                child: Icon(
                                                  Icons
                                                      .create_new_folder_rounded,
                                                  size: 25,
                                                ),
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Text(
                                                strings.createFolder,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w700,
                                                  color: darkGreyTheme,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 16,
                                    ),
                                    Material(
                                      color: white,
                                      borderRadius: BorderRadius.circular(15),
                                      child: InkWell(
                                        onTap: () async {
                                          FormData? formData = FormData();
                                          var responseMessage;
                                          try {
                                            FilePickerResult? result =
                                                await FilePicker.platform
                                                    .pickFiles(
                                                        allowMultiple: true);
                                            if (result != null) {
                                              List<PlatformFile> pickedFiles =
                                                  result.files;
                                              if (pickedFiles.isEmpty) {
                                                return;
                                              }
                                              for (PlatformFile file
                                                  in pickedFiles) {
                                                if (file.path != null) {
                                                  formData.files.add(
                                                    MapEntry(
                                                      'files',
                                                      await MultipartFile
                                                          .fromFile(
                                                        file.path!,
                                                        filename: file.name,
                                                      ),
                                                    ),
                                                  );
                                                }
                                              }
                                              showDialog(
                                                context: context,
                                                builder: (context) {
                                                  return AlertDialog(
                                                    contentPadding:
                                                        EdgeInsets.all(40),
                                                    backgroundColor:
                                                        popUpDialog,
                                                    title: Text(
                                                        strings.uploadingFiles),
                                                    content: SizedBox(
                                                      height: 50,
                                                      width: 50,
                                                      child: FittedBox(
                                                        fit: BoxFit.contain,
                                                        child:
                                                            CircularProgressIndicator(
                                                          backgroundColor:
                                                              progressBg,
                                                          color: darkBlueTheme,
                                                          strokeCap:
                                                              StrokeCap.round,
                                                          strokeWidth: 2.5,
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              );
                                              responseMessage =
                                                  await uploadFile(formData);
                                              if (responseMessage != null &&
                                                  responseMessage.length > 0) {
                                                for (int i = 0;
                                                    i < responseMessage.length;
                                                    i++) {
                                                  var patchResponseMessage =
                                                      await updateFileDetails(
                                                    projectId:
                                                        globalSelectedProjectId
                                                            .value,
                                                    fileId: responseMessage[i]
                                                            ['id']
                                                        .toString(),
                                                    folderCodeId: "null",
                                                  );
                                                  if (patchResponseMessage !=
                                                      "OK") {
                                                    showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        return GeneralPopUp(
                                                          message:
                                                              patchResponseMessage,
                                                        );
                                                      },
                                                    );
                                                  }
                                                }
                                              }
                                              if (responseMessage.runtimeType ==
                                                  String) {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return GeneralPopUp(
                                                      message: responseMessage
                                                          .toString(),
                                                    );
                                                  },
                                                );
                                              } else {
                                                Navigator.pop(context);
                                                Navigator.pop(context);
                                                showDialog(
                                                  context: context,
                                                  builder: (context) {
                                                    return GeneralPopUp(
                                                      title: strings.success,
                                                      message: strings
                                                          .allFilesUploadedSuccessfully,
                                                    );
                                                  },
                                                );
                                              }
                                              fetchList.value =
                                                  !fetchList.value;
                                            } else {
                                              return;
                                            }
                                          } catch (e) {
                                            print(e);
                                            showDialog(
                                              context: context,
                                              builder: (context) {
                                                return GeneralPopUp(
                                                  message: e.toString(),
                                                );
                                              },
                                            );
                                          }
                                        },
                                        borderRadius: BorderRadius.circular(15),
                                        child: Container(
                                          height: 120,
                                          width: 120,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              CircleAvatar(
                                                radius: 30,
                                                backgroundColor: lightBlueTheme,
                                                child: Icon(
                                                  Icons.upload_file_rounded,
                                                  size: 25,
                                                ),
                                              ),
                                              SizedBox(
                                                height: 10,
                                              ),
                                              Text(
                                                strings.uploadFile,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w700,
                                                  color: darkGreyTheme,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                  text: buttonName.value ? "Delete" : "Add",
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
