import 'package:Buildify_AI/main.dart';
import 'package:Buildify_AI/utils/api_calls.dart';
import 'package:Buildify_AI/utils/colors.dart';
import 'package:Buildify_AI/utils/strings.dart';
import 'package:Buildify_AI/widgets/generalAppBar.dart';
import 'package:Buildify_AI/widgets/generalButton.dart';
import 'package:Buildify_AI/widgets/generalPopUp.dart';
import 'package:Buildify_AI/widgets/generalTextField.dart';
import 'package:Buildify_AI/widgets/generalDropdown.dart';
import 'package:flutter/material.dart';

class EditToDo extends StatefulWidget {
  String? id;
  String? statusValue;
  String? punchItemType;
  String? punchItemDesc;
  EditToDo(
      {super.key,
      this.id,
      this.statusValue,
      this.punchItemType,
      this.punchItemDesc});

  @override
  State<EditToDo> createState() => _EditToDoState();
}

class _EditToDoState extends State<EditToDo> {
  String? statusValue = null;
  TextEditingController punchItemTypeController = TextEditingController();
  TextEditingController punchItemDescController = TextEditingController();
  ValueNotifier isLoading = ValueNotifier(false);

  @override
  void initState() {
    super.initState();
    punchItemTypeController.text = widget.punchItemType!;
    punchItemDescController.text = widget.punchItemDesc!;
    statusValue = widget.statusValue;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: lightBlueTheme,
      appBar: GeneralAppbar(title: strings.punchItem),
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
                    strings.editPunchItem,
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
                  ValueListenableBuilder(
                    valueListenable: isLoading,
                    builder: (context, value, child) {
                      return Flexible(
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: GeneralButton(
                            onPressed: () async {
                              if (statusValue == "" ||
                                  punchItemTypeController.text == "" ||
                                  punchItemDescController.text == "" ||
                                  punchItemTypeController.text.isEmpty ||
                                  punchItemDescController.text.isEmpty) {
                                return;
                              }
                              isLoading.value = true;
                              var responseMessage = await updateToDoItem(
                                id: widget.id,
                                punchItemType: punchItemTypeController.text,
                                description: punchItemDescController.text,
                                status: statusValue,
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
                                Navigator.of(context).pop();
                              }
                            },
                            text: isLoading.value ? "" : strings.update,
                          ),
                        ),
                      );
                    },
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
