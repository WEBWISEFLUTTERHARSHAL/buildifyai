import 'package:Buildify_AI/main.dart';
import 'package:Buildify_AI/utils/api_calls.dart';
import 'package:Buildify_AI/utils/colors.dart';
import 'package:Buildify_AI/utils/strings.dart';
import 'package:Buildify_AI/widgets/generalAppBar.dart';
import 'package:Buildify_AI/widgets/generalButton.dart';
import 'package:Buildify_AI/widgets/generalPopUp.dart';
import 'package:Buildify_AI/widgets/generalTextField.dart';
import 'package:Buildify_AI/widgets/generalDropdown.dart';
import 'package:Buildify_AI/widgets/generalUploadOrBrowseBox.dart';
import 'package:flutter/material.dart';

class DailyLog extends StatefulWidget {
  DailyLog({super.key});

  @override
  State<DailyLog> createState() => _DailyLogState();
}

class _DailyLogState extends State<DailyLog> {
  String? statusValue;
  TextEditingController progressionMessageController = TextEditingController();
  List<dynamic>? pickedFilesListObject;
  ValueNotifier isLoading = ValueNotifier(false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBlueTheme,
      appBar: GeneralAppbar(title: strings.dailyLog),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: CustomScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    strings.addDailyLog,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: darkGreyTheme,
                    ),
                  ),
                  SizedBox(
                    height: 35,
                  ),
                  Text(
                    strings.status,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  GeneralDropdown(
                    hintText: strings.select,
                    selectedValue: ValueNotifier(statusValue),
                    onChanged: (value) {
                      statusValue = value.toString();
                    },
                    items: statusDropdownItems.map((e) {
                      return DropdownMenuItem(
                        value: e,
                        child: Text(e),
                      );
                    }).toList(),
                  ),
                  SizedBox(
                    height: 15,
                  ),
                  Text(
                    strings.progressionMessage,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  GeneralTextField(
                    controller: progressionMessageController,
                    hintText: strings.enterYourMessageHere,
                  ),
                  SizedBox(
                    height: 30,
                  ),
                  Text(
                    strings.documentURLs,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  GeneralUploadOrBrowseBox(
                    fileObject: (value) {
                      pickedFilesListObject = value;
                      print(pickedFilesListObject.toString());
                    },
                  ),
                  SizedBox(
                    height: 50,
                  ),
                  ValueListenableBuilder(
                    valueListenable: isLoading,
                    builder: (context, value, child) {
                      return Flexible(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: GeneralButton(
                            onPressed: () async {
                              if (progressionMessageController.text.isEmpty ||
                                  progressionMessageController.text == "" ||
                                  statusValue == null ||
                                  statusValue == "") {
                                return;
                              }
                              isLoading.value = true;
                              if (pickedFilesListObject != null &&
                                  pickedFilesListObject!.length > 0) {
                                for (int i = 0;
                                    i < pickedFilesListObject!.length;
                                    i++) {
                                  var patchResponseMessage =
                                      await updateFileDetails(
                                    projectId: globalSelectedProjectId.value,
                                    fileId: pickedFilesListObject![i]['id']
                                        .toString(),
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
                              var responseMessage = await createDailyLog(
                                description: progressionMessageController.text,
                                status: statusValue,
                                files: pickedFilesListObject,
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
                                  progressionMessageController.text = "";
                                  statusValue = null;
                                });
                                showDialog(
                                  context: context,
                                  builder: (context) {
                                    return GeneralPopUp(
                                      title: strings.success,
                                      message:
                                          strings.dailyLogCreatedSuccessfully,
                                    );
                                  },
                                );
                              }
                            },
                            text: isLoading.value ? "" : strings.create,
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
