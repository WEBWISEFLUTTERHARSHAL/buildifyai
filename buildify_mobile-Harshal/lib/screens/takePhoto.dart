import 'dart:io';
import 'dart:typed_data';

import 'package:Buildify_AI/main.dart';
import 'package:Buildify_AI/utils/api_calls.dart';
import 'package:Buildify_AI/utils/colors.dart';
import 'package:Buildify_AI/utils/strings.dart';
import 'package:Buildify_AI/widgets/generalAppBar.dart';
import 'package:Buildify_AI/widgets/generalButton.dart';
import 'package:Buildify_AI/widgets/generalDropdown.dart';
import 'package:Buildify_AI/widgets/generalPopUp.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class TakePhoto extends StatefulWidget {
  const TakePhoto({super.key});

  @override
  State<TakePhoto> createState() => _TakePhotoState();
}

class _TakePhotoState extends State<TakePhoto> {
  String? projectValue = globalSelectedProjectId.value;
  String? taskValue = null;
  ValueNotifier isUploaded = ValueNotifier(false);
  ValueNotifier isLoading = ValueNotifier(false);
  File? selectedImage;
  var imageObject;
  Uint8List? memoryImage;
  var imageResponseMessage;

  String getDaySuffix(int day) {
    if (day >= 11 && day <= 13) {
      return 'th';
    }
    switch (day % 10) {
      case 1:
        return 'st';
      case 2:
        return 'nd';
      case 3:
        return 'rd';
      default:
        return 'th';
    }
  }

  fetchAllData() async {
    final projectDropdown = fetchProjectDropdown();
    final taskDropdown = fetchTaskDropdown();

    List<dynamic> results = await Future.wait([projectDropdown, taskDropdown]);

    return {
      'projectDropdownData': results[0],
      'taskDropdownData': results[1],
    };
  }

  Future _pickImageFromGallery() async {
    try {
      FormData? formData = FormData();
      final returnImage =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (returnImage == null) return;
      selectedImage = File(returnImage.path);
      memoryImage = File(returnImage.path).readAsBytesSync();
      formData.files.add(
        MapEntry(
          'files',
          await MultipartFile.fromFile(
            selectedImage!.path,
            filename: selectedImage!.path.split('/').last,
          ),
        ),
      );
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
      imageResponseMessage = await uploadFile(formData);
      Navigator.pop(context);
      if (imageResponseMessage.runtimeType == String) {
        showDialog(
          context: context,
          builder: (context) {
            return GeneralPopUp(
              message: imageResponseMessage.toString(),
            );
          },
        );
      } else {
        showDialog(
          context: context,
          builder: (context) {
            return GeneralPopUp(
              title: strings.success,
              message: strings.allFilesUploadedSuccessfully,
            );
          },
        );
      }
      isUploaded.value = true;
    } catch (e) {
      print(e);
      showDialog(
        context: context,
        builder: (context) {
          return GeneralPopUp(
            message: strings.genericError,
          );
        },
      );
    }
  }

  Future _pickImageFromCamera() async {
    try {
      FormData? formData = FormData();
      final returnImage =
          await ImagePicker().pickImage(source: ImageSource.camera);
      if (returnImage == null) return;
      selectedImage = File(returnImage.path);
      memoryImage = File(returnImage.path).readAsBytesSync();
      formData.files.add(
        MapEntry(
          'files',
          await MultipartFile.fromFile(
            selectedImage!.path,
            filename: selectedImage!.path.split('/').last,
          ),
        ),
      );
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
      imageResponseMessage = await uploadFile(formData);
      Navigator.pop(context);
      if (imageResponseMessage.runtimeType == String) {
        showDialog(
          context: context,
          builder: (context) {
            return GeneralPopUp(
              message: imageResponseMessage.toString(),
            );
          },
        );
      } else {
        showDialog(
          context: context,
          builder: (context) {
            return GeneralPopUp(
              title: strings.success,
              message: strings.allFilesUploadedSuccessfully,
            );
          },
        );
      }
      isUploaded.value = true;
    } catch (e) {
      print(e);
      showDialog(
        context: context,
        builder: (context) {
          return GeneralPopUp(
            message: strings.genericError,
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBlueTheme,
      appBar: GeneralAppbar(
        title: strings.takeAPhoto,
      ),
      body: FutureBuilder(
          future: fetchAllData(),
          builder: (context, AsyncSnapshot snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
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
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            } else if (!snapshot.hasData ||
                snapshot.data['projectDropdownData'] == null ||
                snapshot.data['taskDropdownData'] == null ||
                snapshot.data['projectDropdownData'].isEmpty ||
                snapshot.data['taskDropdownData'].isEmpty) {
              return Center(
                child: Text(strings.genericDataFetchError),
              );
            } else if (snapshot.data['projectDropdownData'].runtimeType ==
                    String ||
                snapshot.data['taskDropdownData'].runtimeType == String) {
              return Center(
                child: Text(snapshot.data.toString()),
              );
            } else {
              return CustomScrollView(
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            strings.attachDetails,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: darkGreyTheme,
                            ),
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          Text(
                            strings.selectProject,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          GeneralDropdown(
                            hintText: strings.project,
                            selectedValue: ValueNotifier(projectValue),
                            onChanged: (value) {
                              projectValue = value;
                            },
                            items: snapshot.data['projectDropdownData']
                                .map((e) {
                                  return DropdownMenuItem(
                                    value: e.id,
                                    child: Text(e.name),
                                  );
                                })
                                .toList()
                                .cast<DropdownMenuItem>(),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          Text(
                            strings.selectTask,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          GeneralDropdown(
                            hintText: strings.task,
                            selectedValue: ValueNotifier(taskValue),
                            onChanged: (value) {
                              taskValue = value;
                            },
                            items: snapshot.data['taskDropdownData']
                                .map(
                                  (e) {
                                    return DropdownMenuItem(
                                      value: e.id,
                                      child: Text(e.name),
                                    );
                                  },
                                )
                                .toList()
                                .cast<DropdownMenuItem>(),
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          Text(
                            strings.select,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: darkGreyTheme,
                            ),
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          ValueListenableBuilder(
                            valueListenable: isUploaded,
                            builder: (context, value, child) {
                              return isUploaded.value
                                  ? Container(
                                      padding: const EdgeInsets.all(10),
                                      height: 280,
                                      width: double.infinity,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(5),
                                        color: white,
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          SizedBox(
                                            width: double.infinity,
                                            height: 210,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(5),
                                              child: Image.file(selectedImage!),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 10,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                "${DateTime.now().day}${getDaySuffix(DateTime.now().day)} ${DateFormat('MMMM, yyyy').format(DateTime.now())}",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: darkGreyTheme,
                                                ),
                                              ),
                                              Text(
                                                "ByCrownTechSol",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w600,
                                                  color: darkGreyTheme,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Text(
                                                DateFormat('hh:mm a').format(
                                                  DateTime.now(),
                                                ),
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w400,
                                                  color: lightGreyTheme,
                                                ),
                                              ),
                                              Text(
                                                "38.8951 | -77.0364",
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w400,
                                                  color: lightGreyTheme,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    )
                                  : Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        Material(
                                          color: white,
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          child: InkWell(
                                            onTap: () {
                                              _pickImageFromCamera();
                                            },
                                            child: Container(
                                              height: 160,
                                              width: 160,
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  CircleAvatar(
                                                    radius: 40,
                                                    backgroundColor:
                                                        lightBlueTheme,
                                                    child: ImageIcon(
                                                      AssetImage(
                                                          images.takePhotoIcon),
                                                      size: 25,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 15,
                                                  ),
                                                  Text(
                                                    strings.takePhoto,
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: darkGreyTheme,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        Material(
                                          color: white,
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          child: InkWell(
                                            onTap: () {
                                              _pickImageFromGallery();
                                            },
                                            child: Container(
                                              height: 160,
                                              width: 160,
                                              child: Column(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                children: [
                                                  CircleAvatar(
                                                    radius: 40,
                                                    backgroundColor:
                                                        lightBlueTheme,
                                                    child: ImageIcon(
                                                      AssetImage(
                                                          images.uploadIcon),
                                                      size: 30,
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 15,
                                                  ),
                                                  Text(
                                                    strings.upload,
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w700,
                                                      color: darkGreyTheme,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    );
                            },
                          ),
                          SizedBox(
                            height: 30,
                          ),
                          ValueListenableBuilder(
                            valueListenable: isLoading,
                            builder: (context, value, child) {
                              return Flexible(
                                child: Align(
                                  alignment: Alignment.bottomCenter,
                                  child: GeneralButton(
                                    onPressed: () async {
                                      if (projectValue == "" ||
                                          taskValue == "" ||
                                          projectValue == null ||
                                          taskValue == null ||
                                          imageResponseMessage == null) {
                                        return;
                                      }
                                      isLoading.value = true;
                                      var responseMessage =
                                          await updateFileDetails(
                                        projectId: projectValue,
                                        taskId: taskValue,
                                        fileId: imageResponseMessage[0]['id']
                                            .toString(),
                                      );
                                      isLoading.value = false;
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
                                        setState(() {
                                          projectValue =
                                              globalSelectedProjectId.value;
                                          taskValue = null;
                                          isUploaded.value = false;
                                          imageResponseMessage = null;
                                        });
                                      }
                                    },
                                    text: isLoading.value ? "" : strings.add,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }
          }),
    );
  }
}
