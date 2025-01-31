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

class PunchItem extends StatefulWidget {
  PunchItem({super.key});

  @override
  State<PunchItem> createState() => _PunchItemState();
}

class _PunchItemState extends State<PunchItem> {
  String? statusValue = null;
  String? userValue = currentUser!.id;
  String? taskValue = null;
  ValueNotifier activeBool = ValueNotifier(false);
  List<dynamic>? pickedFilesListObject;
  TextEditingController punchItemTypeController = TextEditingController();
  TextEditingController punchItemDescController = TextEditingController();
  ValueNotifier isLoading = ValueNotifier(false);

  fetchAllData() async {
    final userDropdown = fetchUserDropdown();
    final taskDropdown = fetchTaskDropdown();

    List<dynamic> results = await Future.wait([userDropdown, taskDropdown]);

    return {
      'userDropdownData': results[0],
      'taskDropdownData': results[1],
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBlueTheme,
      appBar: GeneralAppbar(title: strings.punchItem),
      body: Padding(
        padding: const EdgeInsets.all(15),
        child: FutureBuilder(
            future: fetchAllData(),
            builder: (context, AsyncSnapshot<dynamic> snapshot) {
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
                  snapshot.data['userDropdownData'] == null ||
                  snapshot.data['taskDropdownData'] == null ||
                  snapshot.data['userDropdownData'].isEmpty ||
                  snapshot.data['taskDropdownData'].isEmpty) {
                return Center(
                  child: Text(strings.genericDataFetchError),
                );
              } else if (snapshot.data['userDropdownData'].runtimeType ==
                  String) {
                return Center(
                  child: Text(snapshot.data['userDropdownData'].toString()),
                );
              } else if (snapshot.data['taskDropdownData'].runtimeType ==
                  String) {
                return Center(
                  child: Text(snapshot.data['taskDropdownData'].toString()),
                );
              } else {
                return CustomScrollView(
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
                            strings.addPunchItem,
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
                            strings.punchItemType,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          GeneralTextField(
                            hintText: strings.punchItem,
                            controller: punchItemTypeController,
                            maxLines: 1,
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Text(
                            strings.punchItemDescription,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          GeneralTextField(
                            hintText: strings.writeDescription,
                            controller: punchItemDescController,
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          Text(
                            strings.task,
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
                            selectedValue: ValueNotifier(taskValue),
                            onChanged: (value) {
                              taskValue = value.toString();
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
                            height: 15,
                          ),
                          Text(
                            strings.user,
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
                            selectedValue: ValueNotifier(userValue),
                            onChanged: (value) {
                              userValue = value.toString();
                            },
                            items: snapshot.data['userDropdownData']
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
                            height: 15,
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
                            items: statusDropdownItems.map(
                              (e) {
                                return DropdownMenuItem(
                                  value: e,
                                  child: Text(e),
                                );
                              },
                            ).toList(),
                          ),
                          SizedBox(
                            height: 15,
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
                            },
                          ),
                          SizedBox(
                            height: 25,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    strings.active,
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                      color: darkBlueTheme,
                                    ),
                                  ),
                                  Text(
                                    strings.activeStatus,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: lightGreyTheme,
                                    ),
                                  ),
                                ],
                              ),
                              ValueListenableBuilder(
                                valueListenable: activeBool,
                                builder: (context, value, child) {
                                  return Switch.adaptive(
                                    value: value,
                                    onChanged: (val) {
                                      activeBool.value = val;
                                    },
                                    activeColor: white,
                                    activeTrackColor: darkBlueTheme,
                                    trackOutlineWidth:
                                        WidgetStatePropertyAll<double>(1),
                                  );
                                },
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          ValueListenableBuilder(
                            valueListenable: isLoading,
                            builder: (context, value, child) {
                              return Flexible(
                                child: Align(
                                  alignment: Alignment.bottomCenter,
                                  child: GeneralButton(
                                    onPressed: () async {
                                      if (userValue == "" ||
                                          statusValue == "" ||
                                          taskValue == "" ||
                                          punchItemTypeController.text == "" ||
                                          punchItemDescController.text == "" ||
                                          punchItemTypeController
                                              .text.isEmpty ||
                                          punchItemDescController
                                              .text.isEmpty) {
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
                                            projectId:
                                                globalSelectedProjectId.value,
                                            fileId: pickedFilesListObject![i]
                                                    ['id']
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
                                      var responseMessage =
                                          await createPunchItem(
                                        punchItemType:
                                            punchItemTypeController.text,
                                        description:
                                            punchItemDescController.text,
                                        taskId: int.parse(taskValue.toString()),
                                        assigneeToId:
                                            int.parse(userValue.toString()),
                                        status: statusValue,
                                        active: activeBool.value,
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
                                          punchItemTypeController.text = "";
                                          punchItemDescController.text = "";
                                          activeBool.value = false;
                                          userValue = currentUser!.id;
                                          taskValue = null;
                                          statusValue = null;
                                        });
                                        showDialog(
                                          context: context,
                                          builder: (context) {
                                            return GeneralPopUp(
                                              title: strings.success,
                                              message: strings
                                                  .punchItemCreatedSuccessfully,
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
                          )
                        ],
                      ),
                    )
                  ],
                );
              }
            }),
      ),
    );
  }
}
