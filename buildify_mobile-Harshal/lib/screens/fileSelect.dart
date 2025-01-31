import 'package:Buildify_AI/main.dart';
import 'package:Buildify_AI/utils/api_calls.dart';
import 'package:Buildify_AI/utils/colors.dart';
import 'package:Buildify_AI/utils/strings.dart';
import 'package:Buildify_AI/widgets/generalAppBar.dart';
import 'package:Buildify_AI/widgets/generalButton.dart';
import 'package:Buildify_AI/widgets/generalPopUp.dart';
import 'package:Buildify_AI/widgets/generalSearchbar.dart';
import 'package:Buildify_AI/widgets/singleFileSelectTile.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class FileSelect extends StatefulWidget {
  String? parentFolderId;
  List<dynamic>? folderList;
  FileSelect({super.key, required this.parentFolderId, this.folderList});

  @override
  State<FileSelect> createState() => _FileSelectState();
}

class _FileSelectState extends State<FileSelect> {
  ValueNotifier isAllFilesSelected = ValueNotifier(false);
  ValueNotifier fetchList = ValueNotifier(false);
  ValueNotifier updateListData = ValueNotifier(false);
  ValueNotifier buttonName = ValueNotifier(false);
  List<String> selectedFileIds = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBlueTheme,
      appBar: GeneralAppbar(
        title: "File Select",
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
              "Files",
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
                  "File Name",
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF575757)),
                ),
                Spacer(),
                Text(
                  "User",
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF575757)),
                ),
                const SizedBox(
                  width: 30,
                ),
                Text(
                  "Size",
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF575757)),
                ),
                const SizedBox(
                  width: 30,
                ),
                Text(
                  "Action",
                  style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF575757)),
                ),
                const SizedBox(
                  width: 15,
                )
              ],
            ),
            ValueListenableBuilder(
              valueListenable: fetchList,
              builder: (context, value, child) {
                return FutureBuilder(
                  future: fetchFilesList(
                    parentFolderId: widget.parentFolderId,
                  ),
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
                    } else if (!snapshot.hasData || snapshot.data == null) {
                      return Center(
                        child: Text(strings.genericDataFetchError),
                      );
                    } else if (snapshot.data.runtimeType == String) {
                      return Center(
                        child: Text(snapshot.data.toString()),
                      );
                    } else if (snapshot.data!.isEmpty) {
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
                            return ListView.builder(
                              itemBuilder: (context, index) =>
                                  ValueListenableBuilder(
                                builder: (context, valueT, child) {
                                  if (isAllFilesSelected.value) {
                                    selectedFileIds
                                        .add(snapshot.data![index].id);
                                  } else {
                                    selectedFileIds
                                        .remove(snapshot.data![index].id);
                                  }
                                  if (searchController.text.isNotEmpty &&
                                      searchController.text != "") {
                                    if (snapshot.data![index].name
                                        .toLowerCase()
                                        .contains(searchController.text
                                            .toLowerCase())) {
                                      return SingleFileSelectTile(
                                        id: snapshot.data![index].id,
                                        fileName: snapshot.data![index].name,
                                        fileSize: snapshot.data![index].size,
                                        fileId: snapshot.data![index].fileId,
                                        uploadedUserId: snapshot
                                            .data![index].uploadedUserId,
                                        checkBoxVal: ValueNotifier(
                                            isAllFilesSelected.value),
                                        isCheckBoxValueChanged: (value) {
                                          if (value) {
                                            selectedFileIds
                                                .add(snapshot.data![index].id);
                                          } else {
                                            selectedFileIds.remove(
                                                snapshot.data![index].id);
                                          }
                                          buttonName.value =
                                              selectedFileIds.isNotEmpty;
                                        },
                                        singleFileDeleteCallback: (value) {
                                          fetchList.value = !fetchList.value;
                                        },
                                        folderList: widget.folderList,
                                      );
                                    }
                                  } else {
                                    return SingleFileSelectTile(
                                      id: snapshot.data![index].id,
                                      fileName: snapshot.data![index].name,
                                      fileSize: snapshot.data![index].size,
                                      fileId: snapshot.data![index].fileId,
                                      uploadedUserId:
                                          snapshot.data![index].uploadedUserId,
                                      checkBoxVal: ValueNotifier(
                                          isAllFilesSelected.value),
                                      isCheckBoxValueChanged: (value) {
                                        if (value) {
                                          selectedFileIds
                                              .add(snapshot.data![index].id);
                                        } else {
                                          selectedFileIds
                                              .remove(snapshot.data![index].id);
                                        }
                                        buttonName.value =
                                            selectedFileIds.isNotEmpty;
                                      },
                                      singleFileDeleteCallback: (value) {
                                        fetchList.value = !fetchList.value;
                                      },
                                      folderList: widget.folderList,
                                    );
                                  }
                                  return SizedBox.shrink();
                                },
                                valueListenable: isAllFilesSelected,
                              ),
                              itemCount: snapshot.data!.length,
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
                          Navigator.pop(context);
                          isAllFilesSelected.value = false;
                          buttonName.value = false;
                          selectedFileIds.clear();
                          fetchList.value = !fetchList.value;
                        }
                      : () async {
                          FormData? formData = FormData();
                          var responseMessage;
                          try {
                            FilePickerResult? result = await FilePicker.platform
                                .pickFiles(allowMultiple: true);
                            if (result != null) {
                              List<PlatformFile> pickedFiles = result.files;
                              if (pickedFiles.isEmpty) {
                                return;
                              }
                              for (PlatformFile file in pickedFiles) {
                                if (file.path != null) {
                                  formData.files.add(
                                    MapEntry(
                                      'files',
                                      await MultipartFile.fromFile(
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
                                    contentPadding: EdgeInsets.all(40),
                                    backgroundColor: popUpDialog,
                                    title: Text(strings.uploadingFiles),
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
                              responseMessage = await uploadFile(formData);
                              if (responseMessage != null &&
                                  responseMessage.length > 0) {
                                for (int i = 0;
                                    i < responseMessage.length;
                                    i++) {
                                  var patchResponseMessage =
                                      await updateFileDetails(
                                    projectId: globalSelectedProjectId.value,
                                    fileId: responseMessage[i]['id'].toString(),
                                    folderCodeId: widget.parentFolderId,
                                  );
                                  if (patchResponseMessage != "OK") {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return GeneralPopUp(
                                          message: patchResponseMessage,
                                        );
                                      },
                                    );
                                  }
                                }
                              }
                              if (responseMessage.runtimeType == String) {
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return GeneralPopUp(
                                      message: responseMessage.toString(),
                                    );
                                  },
                                );
                              } else {
                                Navigator.pop(context);
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return GeneralPopUp(
                                      title: strings.success,
                                      message:
                                          strings.allFilesUploadedSuccessfully,
                                    );
                                  },
                                );
                              }
                              fetchList.value = !fetchList.value;
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
