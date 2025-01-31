import 'package:Buildify_AI/utils/api_calls.dart';
import 'package:Buildify_AI/utils/colors.dart';
import 'package:Buildify_AI/utils/strings.dart';
import 'package:Buildify_AI/widgets/generalPopUp.dart';
import 'package:dio/dio.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class GeneralUploadOrBrowseBox extends StatelessWidget {
  GeneralUploadOrBrowseBox({super.key, this.fileObject});

  ValueSetter? fileObject;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () async {
        FormData? formData = FormData();
        var responseMessage;
        try {
          FilePickerResult? result =
              await FilePicker.platform.pickFiles(allowMultiple: true);
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
            Navigator.pop(context);
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
              if (fileObject != null) {
                showDialog(
                  context: context,
                  builder: (context) {
                    return GeneralPopUp(
                      title: strings.success,
                      message: strings.allFilesUploadedSuccessfully,
                    );
                  },
                );
                fileObject!(responseMessage);
              }
            }
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
      child: DottedBorder(
        borderType: BorderType.RRect,
        radius: Radius.circular(5),
        color: lightGrey,
        strokeWidth: 1,
        padding: EdgeInsets.symmetric(
          vertical: 18,
        ),
        dashPattern: [12, 10],
        stackFit: StackFit.loose,
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ImageIcon(
                AssetImage(
                  images.uploadIcon,
                ),
                color: darkBlueTheme,
                size: 40,
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                strings.uploadOrBrowse,
                style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                    color: darkBlueTheme),
              )
            ],
          ),
        ),
      ),
    );
  }
}
