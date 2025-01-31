import 'dart:convert';

import 'dart:typed_data';

import 'package:Buildify_AI/main.dart';
import 'package:Buildify_AI/models/dropdownMap.dart';
import 'package:Buildify_AI/models/singleFile.dart';
import 'package:Buildify_AI/models/toDoListItem.dart';
import 'package:Buildify_AI/models/user.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

final dio = Dio();
String baseUrl = "https://my-express-app-767851496729.us-south1.run.app";
int? clockInId;
String? clockInTime;

// Upload File
uploadFile(FormData formData) async {
  String uploadFileEndpoint = "/api/upload";
  List<dynamic> responseMap;
  Response response;
  try {
    response = await dio.post(
      baseUrl + uploadFileEndpoint,
      data: formData,
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
      onSendProgress: (int sent, int total) {
        print('$sent $total');
      },
    );
    if (response.statusCode == 200) {
      responseMap = response.data;
      responseMap.forEach(
        (element) {
          print("${element['original_name']} uploaded successfully.");
        },
      );
      // print(response.data.toString());
      // print(response.statusMessage.toString());
      return responseMap;
    } else {
      return response.statusMessage.toString();
    }
  } on DioException catch (e) {
    // The request was made and the server responded with a status code
    // that falls out of the range of 2xx and is also not 304.
    if (e.response != null) {
      // print(
      //     "Exception, response not null : Data = ${e.response!.data.toString().substring(
      //           e.response!.data.toString().indexOf(':') + 2,
      //           e.response!.data.toString().indexOf('}'),
      //         )}");
      return e.response!.data.toString().substring(
            e.response!.data.toString().indexOf(':') + 2,
            e.response!.data.toString().indexOf('}'),
          );
    } else {
      // Something happened in setting up or sending the request that triggered an Error
      print("Exception, response null : Message = ${e.message.toString()}");
    }
    return e.message.toString();
  }
}

// Login Screen
loginPostAPI(String email, String password, bool toRemember) async {
  String loginEndpoint = "/api/auth/login";
  Map<String, dynamic> responseMap;
  Response response;
  try {
    response = await dio.post(baseUrl + loginEndpoint, data: {
      "email": email,
      "password": password,
    });
    if (response.statusCode == 200) {
      responseMap = response.data;
      if (toRemember) {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', responseMap['token'].toString());
        await prefs.setString('expiresAt', responseMap['expiresAt'].toString());
        await prefs.setString(
            'user_id', responseMap['user']['body']['data']['id'].toString());
        await prefs.setInt('creator_id',
            responseMap['user']['body']['data']['attributes']['creator_id']);
        await prefs.setString(
          'business_info',
          json.encode(
            responseMap['user']['body']['data']['attributes']['business_info'],
          ),
        );
      }
      token = responseMap['token'].toString();
      currentUser = CurrentUser(
        id: responseMap['user']['body']['data']['id'].toString(),
        name: responseMap['user']['body']['data']['attributes']['name']
            .toString(),
        email: responseMap['user']['body']['data']['attributes']['email']
            .toString(),
      );
      // print(response.data.toString());
      // print(response.statusMessage.toString());
      return response.statusMessage.toString();
    } else {
      return response.statusMessage.toString();
    }
  } on DioException catch (e) {
    // The request was made and the server responded with a status code
    // that falls out of the range of 2xx and is also not 304.
    if (e.response != null) {
      // print(
      //     "Exception, response not null : Data = ${e.response!.data.toString().substring(
      //           e.response!.data.toString().indexOf(':') + 2,
      //           e.response!.data.toString().indexOf('}'),
      //         )}");
      return e.response!.data.toString().substring(
            e.response!.data.toString().indexOf(':') + 2,
            e.response!.data.toString().indexOf('}'),
          );
    } else {
      // Something happened in setting up or sending the request that triggered an Error
      print("Exception, response null : Message = ${e.message.toString()}");
    }
    return e.message.toString();
  }
}

// Home Screen
fetchUserDetails() async {
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  String? user_id = await prefs.getString('user_id');
  if (user_id != null) {
    String userDataEndpoint = "/api/zen/user/$user_id";
    Map<String, dynamic> responseMap;
    Response response;
    try {
      response = await dio.get(
        baseUrl + userDataEndpoint,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
          },
        ),
      );
      if (response.statusCode == 200) {
        responseMap = response.data;
        currentUser = CurrentUser(
          id: responseMap['body']['data']['id'].toString(),
          name: responseMap['body']['data']['attributes']['name'].toString(),
          email: responseMap['body']['data']['attributes']['email'].toString(),
        );
        // print(response.data.toString());
        // print(response.statusMessage.toString());
        return response.statusMessage.toString();
      } else {
        return response.statusMessage.toString();
      }
    } on DioException catch (e) {
      // The request was made and the server responded with a status code
      // that falls out of the range of 2xx and is also not 304.
      if (e.response != null) {
        // print(
        //     "Exception, response not null : Data = ${e.response!.data.toString().substring(
        //           e.response!.data.toString().indexOf(':') + 2,
        //           e.response!.data.toString().indexOf('}'),
        //         )}");
        return e.response!.data.toString().substring(
              e.response!.data.toString().indexOf(':') + 2,
              e.response!.data.toString().indexOf('}'),
            );
      } else {
        // Something happened in setting up or sending the request that triggered an Error
        print("Exception, response null : Message = ${e.message.toString()}");
      }
      return e.message.toString();
    }
  }
  return;
}

fetchProjectDropdown() async {
  String projectDropdownEndpoint = "/api/zen/project";
  Map<String, dynamic> responseMap;
  Response response;
  try {
    response = await dio.get(
      baseUrl + projectDropdownEndpoint,
      // queryParameters: {
      //   "filter[home_owner]": currentUser!.id,
      // },
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );
    if (response.statusCode == 200) {
      responseMap = response.data;
      return responseMap['body']['data']
          .map(
            (e) => DropDownMap(
              id: e['id'].toString(),
              name: e['attributes']['name'].toString(),
            ),
          )
          .toList();
      // print(response.data.toString());
      // print(response.statusMessage.toString());
      // return response.statusMessage.toString();
    } else {
      return response.statusMessage.toString();
    }
  } on DioException catch (e) {
    // The request was made and the server responded with a status code
    // that falls out of the range of 2xx and is also not 304.
    if (e.response != null) {
      // print(
      //     "Exception, response not null : Data = ${e.response!.data.toString().substring(
      //           e.response!.data.toString().indexOf(':') + 2,
      //           e.response!.data.toString().indexOf('}'),
      //         )}");
      return e.response!.data.toString().substring(
            e.response!.data.toString().indexOf(':') + 2,
            e.response!.data.toString().indexOf('}'),
          );
    } else {
      // Something happened in setting up or sending the request that triggered an Error
      print("Exception, response null : Message = ${e.message.toString()}");
    }
    return e.message.toString();
  }
}

fetchOverviewDataPoints() async {
  String overviewDataPointsEndpoint = "/api/zen/task";
  Map<String, dynamic> responseMap;
  Response response;
  try {
    response = await dio.get(
      baseUrl + overviewDataPointsEndpoint,
      queryParameters: {
        "filter[project]": globalSelectedProjectId.value,
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );
    if (response.statusCode == 200) {
      responseMap = response.data;
      return {
        "Total Tasks": responseMap['body']['data'].length,
        "Completed Tasks": responseMap['body']['data']
            .where((element) => element['attributes']['status'] == "Completed")
            .length,
        "Remaining Tasks": responseMap['body']['data']
            .where(
                (element) => element['attributes']['status'] == "Yet to Start")
            .length
      };
      // print(response.data.toString());
      // print(response.statusMessage.toString());
      // return response.statusMessage.toString();
    } else {
      return response.statusMessage.toString();
    }
  } on DioException catch (e) {
    // The request was made and the server responded with a status code
    // that falls out of the range of 2xx and is also not 304.
    if (e.response != null) {
      // print(
      //     "Exception, response not null : Data = ${e.response!.data.toString().substring(
      //           e.response!.data.toString().indexOf(':') + 2,
      //           e.response!.data.toString().indexOf('}'),
      //         )}");
      return e.response!.data.toString().substring(
            e.response!.data.toString().indexOf(':') + 2,
            e.response!.data.toString().indexOf('}'),
          );
    } else {
      // Something happened in setting up or sending the request that triggered an Error
      print("Exception, response null : Message = ${e.message.toString()}");
    }
    return e.message.toString();
  }
}

fetchToDoList() async {
  String toDoListEndpoint = "/api/zen/punch_List";
  Map<String, dynamic> responseMap;
  Response response;
  try {
    response = await dio.get(
      baseUrl + toDoListEndpoint,
      queryParameters: {
        "filter[project]": globalSelectedProjectId.value,
        "filter[creator_id]": currentUser!.id,
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );
    if (response.statusCode == 200) {
      responseMap = response.data;
      print(response.data.toString());
      return responseMap['body']['data']
          .map((e) => ToDoListItem(
                id: e['id'].toString(),
                itemType: e['attributes']['punch_item_type'].toString(),
                description: e['attributes']['description'].toString(),
                status: e['attributes']['status'].toString(),
              ))
          .toList()
          .reversed
          .toList()
          .cast<ToDoListItem>();
      // print(response.statusMessage.toString());
      // return response.statusMessage.toString();
    } else {
      return response.statusMessage.toString();
    }
  } on DioException catch (e) {
    // The request was made and the server responded with a status code
    // that falls out of the range of 2xx and is also not 304.
    if (e.response != null) {
      // print(
      //     "Exception, response not null : Data = ${e.response!.data.toString().substring(
      //           e.response!.data.toString().indexOf(':') + 2,
      //           e.response!.data.toString().indexOf('}'),
      //         )}");
      return e.response!.data.toString().substring(
            e.response!.data.toString().indexOf(':') + 2,
            e.response!.data.toString().indexOf('}'),
          );
    } else {
      // Something happened in setting up or sending the request that triggered an Error
      print("Exception, response null : Message = ${e.message.toString()}");
    }
    return e.message.toString();
  }
}

updateToDoItem({
  String? id,
  String? punchItemType,
  String? description,
  String? status,
}) async {
  String updateToDoItemEndpoint = "/api/zen/punch_List/${id}";
  Response response;
  try {
    response = await dio.patch(
      baseUrl + updateToDoItemEndpoint,
      data: {
        "data": {
          "type": "punch_List",
          "attributes": {
            "punch_item_type": punchItemType,
            "description": description,
            "status": status,
          },
        },
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );
    if (response.statusCode == 200) {
      // print(response.data.toString());
      // print(response.statusMessage.toString());
      return response.statusMessage.toString();
    } else {
      return response.statusMessage.toString();
    }
  } on DioException catch (e) {
    // The request was made and the server responded with a status code
    // that falls out of the range of 2xx and is also not 304.
    if (e.response != null) {
      // print(
      //     "Exception, response not null : Data = ${e.response!.data.toString().substring(
      //           e.response!.data.toString().indexOf(':') + 2,
      //           e.response!.data.toString().indexOf('}'),
      //         )}");
      return e.response!.data.toString().substring(
            e.response!.data.toString().indexOf(':') + 2,
            e.response!.data.toString().indexOf('}'),
          );
    } else {
      // Something happened in setting up or sending the request that triggered an Error
      print("Exception, response null : Message = ${e.message.toString()}");
    }
    return e.message.toString();
  }
}

deleteToDoItem(String? toDoId) async {
  String deleteToDoItemEndpoint = "/api/zen/punch_List/${toDoId}";
  Response response;
  try {
    response = await dio.delete(
      baseUrl + deleteToDoItemEndpoint,
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );
    if (response.statusCode == 200) {
      // print(response.data.toString());
      // print(response.statusMessage.toString());
      return response.statusMessage.toString();
    } else {
      return response.statusMessage.toString();
    }
  } on DioException catch (e) {
    // The request was made and the server responded with a status code
    // that falls out of the range of 2xx and is also not 304.
    if (e.response != null) {
      // print(
      //     "Exception, response not null : Data = ${e.response!.data.toString().substring(
      //           e.response!.data.toString().indexOf(':') + 2,
      //           e.response!.data.toString().indexOf('}'),
      //         )}");
      return e.response!.data.toString().substring(
            e.response!.data.toString().indexOf(':') + 2,
            e.response!.data.toString().indexOf('}'),
          );
    } else {
      // Something happened in setting up or sending the request that triggered an Error
      print("Exception, response null : Message = ${e.message.toString()}");
    }
    return e.message.toString();
  }
}

fetchClockDetails({DateTime? dateTime}) async {
  String fetchClockDetailsEndpoint = "/api/zen/time_Entry";
  Map<String, dynamic> responseMap;
  Response response;
  try {
    response = await dio.get(
      baseUrl + fetchClockDetailsEndpoint,
      queryParameters: {
        "filter[user]": int.parse(currentUser!.id),
        "filter[status]": "open",
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );
    if (response.statusCode == 200) {
      responseMap = response.data;
      print(response.data.toString());
      if (responseMap['body']['data'].length == 0) {
        return 0;
      }
      clockInId = responseMap['body']['data'][0]['id'];
      clockInTime =
          responseMap['body']['data'][0]['attributes']['clock_in'].toString();
      Duration? durationDiff;
      DateTime storedDateTime = DateTime.parse(
          responseMap['body']['data'][0]['attributes']['clock_in'].toString());
      durationDiff = DateTime.now().toUtc().difference(storedDateTime);
      return durationDiff;
      // print(response.statusMessage.toString());
      // return response.statusMessage.toString();
    } else {
      return response.statusMessage.toString();
    }
  } on DioException catch (e) {
    // The request was made and the server responded with a status code
    // that falls out of the range of 2xx and is also not 304.
    if (e.response != null) {
      // print(
      //     "Exception, response not null : Data = ${e.response!.data.toString().substring(
      //           e.response!.data.toString().indexOf(':') + 2,
      //           e.response!.data.toString().indexOf('}'),
      //         )}");
      return e.response!.data.toString().substring(
            e.response!.data.toString().indexOf(':') + 2,
            e.response!.data.toString().indexOf('}'),
          );
    } else {
      // Something happened in setting up or sending the request that triggered an Error
      print("Exception, response null : Message = ${e.message.toString()}");
    }
    return e.message.toString();
  }
}

doClockIn({
  DateTime? dateTime,
}) async {
  String clockInEndpoint = "/api/zen/time_Entry";
  Response response;
  try {
    response = await dio.post(
      baseUrl + clockInEndpoint,
      data: {
        "data": {
          "type": "time_Entry",
          "attributes": {
            "user_id": int.parse(currentUser!.id),
            "clock_in": dateTime!.toUtc().toIso8601String(),
            "project_id": int.parse(globalSelectedProjectId.value),
            "status": "open",
          },
        }
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );
    if (response.statusCode == 200) {
      // print(response.data.toString());
      // print(response.statusMessage.toString());
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('clockInTime', dateTime.toUtc().toIso8601String());
      return response.statusMessage.toString();
    } else {
      return response.statusMessage.toString();
    }
  } on DioException catch (e) {
    // The request was made and the server responded with a status code
    // that falls out of the range of 2xx and is also not 304.
    if (e.response != null) {
      // print(
      //     "Exception, response not null : Data = ${e.response!.data.toString().substring(
      //           e.response!.data.toString().indexOf(':') + 2,
      //           e.response!.data.toString().indexOf('}'),
      //         )}");
      return e.response!.data.toString().substring(
            e.response!.data.toString().indexOf(':') + 2,
            e.response!.data.toString().indexOf('}'),
          );
    } else {
      // Something happened in setting up or sending the request that triggered an Error
      print("Exception, response null : Message = ${e.message.toString()}");
    }
    return e.message.toString();
  }
}

doClockOut({DateTime? dateTime}) async {
  String clockOutEndpoint = "/api/zen/time_Entry/${clockInId}";
  Response response;
  DateTime clockInT = DateTime.parse(clockInTime.toString());
  int hours = dateTime!
      .difference(
        clockInT,
      )
      .inHours;
  try {
    response = await dio.patch(
      baseUrl + clockOutEndpoint,
      data: {
        "data": {
          "type": "time_Entry",
          "attributes": {
            "clock_out": dateTime.toUtc().toIso8601String(),
            "total_hours": hours,
            "status": "close",
          },
        }
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );
    if (response.statusCode == 200) {
      // print(response.data.toString());
      // print(response.statusMessage.toString());
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.remove('clockInTime');
      return response.statusMessage.toString();
    } else {
      return response.statusMessage.toString();
    }
  } on DioException catch (e) {
    // The request was made and the server responded with a status code
    // that falls out of the range of 2xx and is also not 304.
    if (e.response != null) {
      // print(
      //     "Exception, response not null : Data = ${e.response!.data.toString().substring(
      //           e.response!.data.toString().indexOf(':') + 2,
      //           e.response!.data.toString().indexOf('}'),
      //         )}");
      return e.response!.data.toString().substring(
            e.response!.data.toString().indexOf(':') + 2,
            e.response!.data.toString().indexOf('}'),
          );
    } else {
      // Something happened in setting up or sending the request that triggered an Error
      print("Exception, response null : Message = ${e.message.toString()}");
    }
    return e.message.toString();
  }
}

// Punch Item Screen
fetchUserDropdown() async {
  String fetchUserDropdownEndpoint = "/api/zen/user";
  Map<String, dynamic> responseMap;
  Response response;
  try {
    response = await dio.get(
      baseUrl + fetchUserDropdownEndpoint,
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );
    if (response.statusCode == 200) {
      responseMap = response.data;
      return responseMap['body']['data']
          .map(
            (e) => DropDownMap(
              id: e['id'].toString(),
              name: e['attributes']['name'].toString(),
            ),
          )
          .toList()
          .cast<DropDownMap>();
      // print(response.data.toString());
      // print(response.statusMessage.toString());
      // return response.statusMessage.toString();
    } else {
      return response.statusMessage.toString();
    }
  } on DioException catch (e) {
    // The request was made and the server responded with a status code
    // that falls out of the range of 2xx and is also not 304.
    if (e.response != null) {
      // print(
      //     "Exception, response not null : Data = ${e.response!.data.toString().substring(
      //           e.response!.data.toString().indexOf(':') + 2,
      //           e.response!.data.toString().indexOf('}'),
      //         )}");
      return e.response!.data.toString().substring(
            e.response!.data.toString().indexOf(':') + 2,
            e.response!.data.toString().indexOf('}'),
          );
    } else {
      // Something happened in setting up or sending the request that triggered an Error
      print("Exception, response null : Message = ${e.message.toString()}");
    }
    return e.message.toString();
  }
}

fetchallUsers() async {
  String fetchallUsersEndpoint = "/api/zen/user";
  Map<String, dynamic> responseMap;
  Response response;
  try {
    response = await dio.get(
      baseUrl + fetchallUsersEndpoint,
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );
    if (response.statusCode == 200) {
      responseMap = response.data;
      print(responseMap['body']['data'][0]["attributes"]["image"] is String);
      return responseMap['body']['data']
          .map(
            (e) => CurrentUser(
                id: e['id'].toString(),
                name: e['attributes']['name'].toString(),
                email: e['attributes']['email'].toString(),
                profilePicture: e['attributes']['image'].toString()),
          )
          .toList()
          .cast<CurrentUser>();
      // print(response.data.toString());
      // print(response.statusMessage.toString());
      // return response.statusMessage.toString();
    } else {
      return response.statusMessage.toString();
    }
  } on DioException catch (e) {
    // The request was made and the server responded with a status code
    // that falls out of the range of 2xx and is also not 304.
    if (e.response != null) {
      // print(
      //     "Exception, response not null : Data = ${e.response!.data.toString().substring(
      //           e.response!.data.toString().indexOf(':') + 2,
      //           e.response!.data.toString().indexOf('}'),
      //         )}");
      return e.response!.data.toString().substring(
            e.response!.data.toString().indexOf(':') + 2,
            e.response!.data.toString().indexOf('}'),
          );
    } else {
      // Something happened in setting up or sending the request that triggered an Error
      print("Exception, response null : Message = ${e.message.toString()}");
    }
    return e.message.toString();
  }
}

fetchTaskDropdown() async {
  String fetchTaskDropdownEndpoint = "/api/zen/task";
  Map<String, dynamic> responseMap;
  Response response;
  try {
    response = await dio.get(
      baseUrl + fetchTaskDropdownEndpoint,
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );
    if (response.statusCode == 200) {
      responseMap = response.data;
      return responseMap['body']['data']
          .map(
            (e) => DropDownMap(
              id: e['id'].toString(),
              name: e['attributes']['task_name'].toString(),
            ),
          )
          .toList()
          .cast<DropDownMap>();
      // print(response.data.toString());
      // print(response.statusMessage.toString());
      // return response.statusMessage.toString();
    } else {
      return response.statusMessage.toString();
    }
  } on DioException catch (e) {
    // The request was made and the server responded with a status code
    // that falls out of the range of 2xx and is also not 304.
    if (e.response != null) {
      // print(
      //     "Exception, response not null : Data = ${e.response!.data.toString().substring(
      //           e.response!.data.toString().indexOf(':') + 2,
      //           e.response!.data.toString().indexOf('}'),
      //         )}");
      return e.response!.data.toString().substring(
            e.response!.data.toString().indexOf(':') + 2,
            e.response!.data.toString().indexOf('}'),
          );
    } else {
      // Something happened in setting up or sending the request that triggered an Error
      print("Exception, response null : Message = ${e.message.toString()}");
    }
    return e.message.toString();
  }
}

createPunchItem({
  int? taskId,
  String? punchItemType,
  String? description,
  int? assigneeToId,
  String? status,
  bool? active,
  List<dynamic>? files,
}) async {
  String createPunchItemEndpoint = "/api/zen/punch_List";
  Map<String, dynamic> responseMap;
  Response response;
  try {
    response = await dio.post(
      baseUrl + createPunchItemEndpoint,
      data: {
        "data": {
          "type": "punch_List",
          "attributes": {
            "task_id": taskId,
            "punch_item_type": punchItemType,
            "description": description,
            "assignee_to_id": assigneeToId,
            "status": status,
            "file_info": files,
            "active": active,
            "project_id": int.parse(globalSelectedProjectId.value),
          }
        }
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );
    if (response.statusCode == 200) {
      responseMap = response.data;
      // print(responseMap.toString());
      // print(response.data.toString());
      // print(response.statusMessage.toString());
      return response.statusMessage.toString();
    } else {
      return response.statusMessage.toString();
    }
  } on DioException catch (e) {
    // The request was made and the server responded with a status code
    // that falls out of the range of 2xx and is also not 304.
    if (e.response != null) {
      // print(
      //     "Exception, response not null : Data = ${e.response!.data.toString().substring(
      //           e.response!.data.toString().indexOf(':') + 2,
      //           e.response!.data.toString().indexOf('}'),
      //         )}");
      return e.response!.data.toString().substring(
            e.response!.data.toString().indexOf(':') + 2,
            e.response!.data.toString().indexOf('}'),
          );
    } else {
      // Something happened in setting up or sending the request that triggered an Error
      print("Exception, response null : Message = ${e.message.toString()}");
    }
    return e.message.toString();
  }
}

// Daily Log Screen
createDailyLog({
  String? description,
  String? status,
  List<dynamic>? files,
}) async {
  String createDailyLogEndpoint = "/api/zen/progression_Notes";
  Response response;
  try {
    response = await dio.post(
      baseUrl + createDailyLogEndpoint,
      data: {
        "data": {
          "type": "progression_Notes",
          "attributes": {
            "description": description,
            "project_id": int.parse(globalSelectedProjectId.value),
            "user_id": int.parse(currentUser!.id),
            "notes_type": status,
            "file_info": files,
          }
        }
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );
    if (response.statusCode == 200) {
      // print(response.data.toString());
      // print(response.statusMessage.toString());
      return response.statusMessage.toString();
    } else {
      return response.statusMessage.toString();
    }
  } on DioException catch (e) {
    // The request was made and the server responded with a status code
    // that falls out of the range of 2xx and is also not 304.
    if (e.response != null) {
      // print(
      //     "Exception, response not null : Data = ${e.response!.data.toString().substring(
      //           e.response!.data.toString().indexOf(':') + 2,
      //           e.response!.data.toString().indexOf('}'),
      //         )}");
      return e.response!.data.toString().substring(
            e.response!.data.toString().indexOf(':') + 2,
            e.response!.data.toString().indexOf('}'),
          );
    } else {
      // Something happened in setting up or sending the request that triggered an Error
      print("Exception, response null : Message = ${e.message.toString()}");
    }
    return e.message.toString();
  }
}

// File Select Screen
fetchFilesList({String? parentFolderId}) async {
  String fetchFilesListEndpoint = "/api/zen/file";
  Map<String, dynamic> responseMap;
  Response response;
  try {
    response = await dio.get(
      baseUrl + fetchFilesListEndpoint,
      queryParameters: parentFolderId == "null"
          ? {
              "filter[project_id]": globalSelectedProjectId.value,
            }
          : {
              "filter[project_id]": globalSelectedProjectId.value,
              "filter[folder_code_id]":
                  parentFolderId == null ? null : int.parse(parentFolderId),
            },
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );
    if (response.statusCode == 200) {
      responseMap = response.data;
      print(response.data.toString());
      // print(response.statusMessage.toString());
      return responseMap["body"]["data"]
          .map(
            (e) => SingleFile(
              id: e["id"].toString(),
              name: e["attributes"]["original_name"].toString(),
              size: double.parse(e["attributes"]["file_size"].toString()),
              fileId: e["attributes"]["file_id"].toString(),
              uploadedUserId: e["attributes"]["uploaded_user_id"],
            ),
          )
          .toList()
          .reversed
          .toList()
          .cast<SingleFile>();
    } else {
      return response.statusMessage.toString();
    }
  } on DioException catch (e) {
    // The request was made and the server responded with a status code
    // that falls out of the range of 2xx and is also not 304.
    if (e.response != null) {
      // print(
      //     "Exception, response not null : Data = ${e.response!.data.toString().substring(
      //           e.response!.data.toString().indexOf(':') + 2,
      //           e.response!.data.toString().indexOf('}'),
      //         )}");
      return e.response!.data.toString().substring(
            e.response!.data.toString().indexOf(':') + 2,
            e.response!.data.toString().indexOf('}'),
          );
    } else {
      // Something happened in setting up or sending the request that triggered an Error
      print("Exception, response null : Message = ${e.message.toString()}");
    }
    return e.message.toString();
  }
}

updateFileDetails({
  String? fileId,
  String? projectId,
  String? taskId = null,
  String? folderCodeId = null,
  String? fileName = null,
}) async {
  String updateFileDetailsEndpoint = "/api/zen/file/${fileId}";
  Response response;
  try {
    response = await dio.patch(
      baseUrl + updateFileDetailsEndpoint,
      data: {
        "data": {
          "type": "file",
          "attributes": (fileName != null)
              ? {
                  "original_name": fileName,
                }
              : (taskId != null && folderCodeId != null)
                  ? {
                      "project_id": int.parse(projectId!),
                      "task_id": int.parse(taskId),
                      "folder_code_id": folderCodeId == "null"
                          ? null
                          : int.parse(folderCodeId),
                    }
                  : (taskId != null)
                      ? {
                          "project_id": int.parse(projectId!),
                          "task_id": int.parse(taskId),
                        }
                      : (folderCodeId != null)
                          ? {
                              "project_id": int.parse(projectId!),
                              "folder_code_id": folderCodeId == "null"
                                  ? null
                                  : int.parse(folderCodeId),
                            }
                          : {
                              "project_id": int.parse(projectId!),
                            },
        },
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );
    if (response.statusCode == 200) {
      // print(response.data.toString());
      // print(response.statusMessage.toString());
      return response.statusMessage.toString();
    } else {
      return response.statusMessage.toString();
    }
  } on DioException catch (e) {
    // The request was made and the server responded with a status code
    // that falls out of the range of 2xx and is also not 304.
    if (e.response != null) {
      // print(
      //     "Exception, response not null : Data = ${e.response!.data.toString().substring(
      //           e.response!.data.toString().indexOf(':') + 2,
      //           e.response!.data.toString().indexOf('}'),
      //         )}");
      return e.response!.data.toString().substring(
            e.response!.data.toString().indexOf(':') + 2,
            e.response!.data.toString().indexOf('}'),
          );
    } else {
      // Something happened in setting up or sending the request that triggered an Error
      print("Exception, response null : Message = ${e.message.toString()}");
    }
    return e.message.toString();
  }
}

moveToFolder({String? fileId, String? parentFolderId}) async {
  String moveToFolderEndpoint = "/api/zen/file/$fileId";
  Response response;
  try {
    response = await dio.patch(
      baseUrl + moveToFolderEndpoint,
      data: {
        "data": {
          "type": "file",
          "attributes": {
            "folder_code_id":
                parentFolderId == "null" ? null : int.parse(parentFolderId!),
          }
        },
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );
    if (response.statusCode == 200) {
      // print(response.data.toString());
      // print(response.statusMessage.toString());
      return response.statusMessage.toString();
    } else {
      return response.statusMessage.toString();
    }
  } on DioException catch (e) {
    // The request was made and the server responded with a status code
    // that falls out of the range of 2xx and is also not 304.
    if (e.response != null) {
      // print(
      //     "Exception, response not null : Data = ${e.response!.data.toString().substring(
      //           e.response!.data.toString().indexOf(':') + 2,
      //           e.response!.data.toString().indexOf('}'),
      //         )}");
      return e.response!.data.toString().substring(
            e.response!.data.toString().indexOf(':') + 2,
            e.response!.data.toString().indexOf('}'),
          );
    } else {
      // Something happened in setting up or sending the request that triggered an Error
      print("Exception, response null : Message = ${e.message.toString()}");
    }
    return e.message.toString();
  }
}

deleteFile({String? fileId}) async {
  String updateFileDetailsEndpoint = "/api/zen/file/${fileId}";
  Response response;
  try {
    response = await dio.delete(
      baseUrl + updateFileDetailsEndpoint,
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );
    if (response.statusCode == 200) {
      // print(response.data.toString());
      // print(response.statusMessage.toString());
      return response.statusMessage.toString();
    } else {
      return response.statusMessage.toString();
    }
  } on DioException catch (e) {
    // The request was made and the server responded with a status code
    // that falls out of the range of 2xx and is also not 304.
    if (e.response != null) {
      // print(
      //     "Exception, response not null : Data = ${e.response!.data.toString().substring(
      //           e.response!.data.toString().indexOf(':') + 2,
      //           e.response!.data.toString().indexOf('}'),
      //         )}");
      return e.response!.data.toString().substring(
            e.response!.data.toString().indexOf(':') + 2,
            e.response!.data.toString().indexOf('}'),
          );
    } else {
      // Something happened in setting up or sending the request that triggered an Error
      print("Exception, response null : Message = ${e.message.toString()}");
    }
    return e.message.toString();
  }
}

// File Manager Screen
fetchFoldersList() async {
  String fetchFolderListEndpoint = "/api/zen/folder_Codes";
  Map<String, dynamic> responseMap;
  Response response;
  try {
    response = await dio.get(
      baseUrl + fetchFolderListEndpoint,
      queryParameters: {
        "filter[project_id]": globalSelectedProjectId.value,
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );
    if (response.statusCode == 200) {
      responseMap = response.data;
      // print(response.data.toString());
      // print(response.statusMessage.toString());
      return responseMap["body"]["data"]
          .map(
            (e) => DropDownMap(
              id: e["id"].toString(),
              name: e["attributes"]["folder_display_name"].toString(),
            ),
          )
          .toList()
          .reversed
          .toList()
          .cast<DropDownMap>();
    } else {
      return response.statusMessage.toString();
    }
  } on DioException catch (e) {
    // The request was made and the server responded with a status code
    // that falls out of the range of 2xx and is also not 304.
    if (e.response != null) {
      // print(
      //     "Exception, response not null : Data = ${e.response!.data.toString().substring(
      //           e.response!.data.toString().indexOf(':') + 2,
      //           e.response!.data.toString().indexOf('}'),
      //         )}");
      return e.response!.data.toString().substring(
            e.response!.data.toString().indexOf(':') + 2,
            e.response!.data.toString().indexOf('}'),
          );
    } else {
      // Something happened in setting up or sending the request that triggered an Error
      print("Exception, response null : Message = ${e.message.toString()}");
    }
    return e.message.toString();
  }
}

createFolder({
  String? folderName,
}) async {
  String createFolderEndpoint = "/api/zen/folder_Codes";
  Response response;
  try {
    response = await dio.post(
      baseUrl + createFolderEndpoint,
      data: {
        "data": {
          "type": "/zen/folder_Codes",
          "attributes": {
            "creator_id": creatorId,
            "business_id":
                businessInfo != null ? businessInfo!["business_id"] : null,
            "folder_name": folderName,
            "folder_display_name": folderName!.toLowerCase().replaceFirst(
                  folderName[0].toLowerCase(),
                  folderName[0].toUpperCase(),
                ),
            "description": "",
            "project_id": int.parse(globalSelectedProjectId.value),
          },
        }
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );
    if (response.statusCode == 200) {
      return response.statusMessage.toString();
      // print(response.data.toString());
      // print(response.statusMessage.toString());
      // return responseMap["body"]["data"]
      //     .map(
      //       (e) => DropDownMap(
      //         id: e["id"].toString(),
      //         name: e["attributes"]["folder_display_name"].toString(),
      //       ),
      //     )
      //     .toList()
      //     .reversed
      //     .toList()
      //     .cast<DropDownMap>();
    } else {
      return response.statusMessage.toString();
    }
  } on DioException catch (e) {
    // The request was made and the server responded with a status code
    // that falls out of the range of 2xx and is also not 304.
    if (e.response != null) {
      // print(
      //     "Exception, response not null : Data = ${e.response!.data.toString().substring(
      //           e.response!.data.toString().indexOf(':') + 2,
      //           e.response!.data.toString().indexOf('}'),
      //         )}");
      return e.response!.data.toString().substring(
            e.response!.data.toString().indexOf(':') + 2,
            e.response!.data.toString().indexOf('}'),
          );
    } else {
      // Something happened in setting up or sending the request that triggered an Error
      print("Exception, response null : Message = ${e.message.toString()}");
    }
    return e.message.toString();
  }
}

updateFolderDetails({
  String? folderId,
  String? folderName,
}) async {
  String updateFolderDetailsEndpoint = "/api/zen/folder_Codes/${folderId}";
  Response response;
  try {
    response = await dio.patch(
      baseUrl + updateFolderDetailsEndpoint,
      data: {
        "data": {
          "type": "/zen/folder_Codes",
          "attributes": {
            "folder_name": folderName,
            "folder_display_name": folderName!.toLowerCase().replaceFirst(
                  folderName[0].toLowerCase(),
                  folderName[0].toUpperCase(),
                ),
          }
        },
      },
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );
    if (response.statusCode == 200) {
      // print(response.data.toString());
      // print(response.statusMessage.toString());
      return response.statusMessage.toString();
    } else {
      return response.statusMessage.toString();
    }
  } on DioException catch (e) {
    // The request was made and the server responded with a status code
    // that falls out of the range of 2xx and is also not 304.
    if (e.response != null) {
      // print(
      //     "Exception, response not null : Data = ${e.response!.data.toString().substring(
      //           e.response!.data.toString().indexOf(':') + 2,
      //           e.response!.data.toString().indexOf('}'),
      //         )}");
      return e.response!.data.toString().substring(
            e.response!.data.toString().indexOf(':') + 2,
            e.response!.data.toString().indexOf('}'),
          );
    } else {
      // Something happened in setting up or sending the request that triggered an Error
      print("Exception, response null : Message = ${e.message.toString()}");
    }
    return e.message.toString();
  }
}

deleteFolder({String? folderId}) async {
  try {
    var filesResponse = await fetchFilesList(
      parentFolderId: folderId,
    );

    if (filesResponse != null) {
      for (var file in filesResponse) {
        await deleteFile(fileId: file.id);
      }
    }
  } catch (e) {
    print(e);
    return e.toString();
  }

  String deleteFolderEndpoint = "/api/zen/folder_Codes/${folderId}";
  Response response;
  try {
    response = await dio.delete(
      baseUrl + deleteFolderEndpoint,
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
      ),
    );
    if (response.statusCode == 200) {
      // print(response.statusMessage.toString());
      return response.statusMessage.toString();
    } else {
      return response.statusMessage.toString();
    }
  } on DioException catch (e) {
    // The request was made and the server responded with a status code
    // that falls out of the range of 2xx and is also not 304.
    if (e.response != null) {
      // print(
      //     "Exception, response not null : Data = ${e.response!.data.toString().substring(
      //           e.response!.data.toString().indexOf(':') + 2,
      //           e.response!.data.toString().indexOf('}'),
      //         )}");
      return e.response!.data.toString().substring(
            e.response!.data.toString().indexOf(':') + 2,
            e.response!.data.toString().indexOf('}'),
          );
    } else {
      // Something happened in setting up or sending the request that triggered an Error
      print("Exception, response null : Message = ${e.message.toString()}");
    }
    return e.message.toString();
  }
}

downloadFolder({String? folderId}) async {
  String downloadFolderEndpoint = "/download-folder/${folderId}";
  Response response;
  try {
    response = await dio.get(
      baseUrl + downloadFolderEndpoint,
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
          'responseType': 'arraybuffer'
        },
      ),
    );
    if (response.statusCode == 200) {
      print(response.data.toString());
      // print(response.statusMessage.toString());
      return response.statusMessage.toString();
    } else {
      return response.statusMessage.toString();
    }
  } on DioException catch (e) {
    // The request was made and the server responded with a status code
    // that falls out of the range of 2xx and is also not 304.
    if (e.response != null) {
      // print(
      //     "Exception, response not null : Data = ${e.response!.data.toString().substring(
      //           e.response!.data.toString().indexOf(':') + 2,
      //           e.response!.data.toString().indexOf('}'),
      //         )}");
      return e.response!.data.toString().substring(
            e.response!.data.toString().indexOf(':') + 2,
            e.response!.data.toString().indexOf('}'),
          );
    } else {
      // Something happened in setting up or sending the request that triggered an Error
      print("Exception, response null : Message = ${e.message.toString()}");
    }
    return e.message.toString();
  }
}

// Helper functions
Future<Uint8List?> getFileBytes(String download_url) async {
  try {
    var response = await dio.get(
      download_url,
      options: Options(
        headers: {
          'Authorization': 'Bearer $token',
        },
        responseType: ResponseType.bytes,
      ),
      // Response type is set to bytes to get raw binary data
    );

    // Check if the response status is OK
    if (response.statusCode == 200) {
      // Return the image data as a Uint8List
      return response.data;
    } else {
      print('Error fetching image: ${response.statusCode}');
      return null;
    }
  } catch (e) {
    print('Exception: $e');
    return null;
  }
}
