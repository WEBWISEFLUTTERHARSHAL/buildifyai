import 'dart:async';
import 'package:Buildify_AI/main.dart';
import 'package:Buildify_AI/screens/editToDo.dart';
import 'package:Buildify_AI/screens/home.dart';
import 'package:Buildify_AI/utils/api_calls.dart';
import 'package:Buildify_AI/utils/colors.dart';
import 'package:Buildify_AI/utils/strings.dart';
import 'package:Buildify_AI/widgets/generalPopUp.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  ValueNotifier isClockedIn =
      clockResponse == 0 ? ValueNotifier(false) : ValueNotifier(true);
  ValueNotifier timerState = ValueNotifier(false);
  Timer? timer;
  int hours = clockResponse == 0 ? 0 : clockResponse.inHours;
  int minutes = clockResponse == 0 ? 0 : clockResponse.inMinutes % 60;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    if (timer != null) {
      timer!.cancel();
    }
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      clockInTime = prefs.getString('clockInTime');
      if (clockInTime != null) {
        DateTime clockInT = DateTime.parse(clockInTime.toString());
        Duration diff = DateTime.now().difference(clockInT);
        hours = diff.inHours;
        minutes = diff.inMinutes % 60;
      }
      timerState.value = !timerState.value;
    }
  }

  void startTimer() {
    timer = Timer.periodic(Duration(minutes: 1), (timer) {
      minutes++;
      if (minutes >= 60) {
        minutes = 0;
        hours++;
      }
      timerState.value = !timerState.value;
    });
  }

  void stopTimer() {
    if (timer != null) {
      timer!.cancel();
      hours = 0;
      minutes = 0;
      timerState.value = !timerState.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    isClockedIn.value ? startTimer() : null;
    return CustomScrollView(
      slivers: [
        SliverFillRemaining(
          hasScrollBody: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      strings.showingDetails,
                      style: TextStyle(
                        fontSize: 10,
                        color: lightGreyTheme,
                      ),
                    ),
                    SizedBox(
                      height: 13,
                    ),
                    Text(
                      strings.overview,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Container(
                      padding: EdgeInsets.all(
                        18,
                      ),
                      decoration: BoxDecoration(
                          color: white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 100,
                              offset: Offset(0, 0),
                            ),
                          ]),
                      child: ValueListenableBuilder(
                        valueListenable: globalSelectedProjectId,
                        builder: (context, value, child) {
                          return FutureBuilder(
                              future: fetchOverviewDataPoints(),
                              builder:
                                  (context, AsyncSnapshot<dynamic> snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
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
                                } else if (!snapshot.hasData) {
                                  return Center(
                                    child: Text(
                                        strings.overviewDataPointsFetchError),
                                  );
                                } else if (snapshot.data.runtimeType ==
                                    String) {
                                  return Center(
                                    child: Text(snapshot.data.toString()),
                                  );
                                } else {
                                  return Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          SizedBox(
                                            height: 60,
                                            width: 60,
                                            child: CircularProgressIndicator(
                                              value: (double.parse(snapshot
                                                          .data[
                                                              'Completed Tasks']
                                                          .toString()) /
                                                      double.parse(snapshot
                                                          .data['Total Tasks']
                                                          .toString())) *
                                                  100,
                                              strokeCap: StrokeCap.round,
                                              color: darkBlueTheme,
                                              strokeWidth: 7,
                                              backgroundColor: progressBg,
                                            ),
                                          ),
                                          Text(
                                            ((double.parse(snapshot.data[
                                                                    'Completed Tasks']
                                                                .toString()) /
                                                            double.parse(snapshot
                                                                .data[
                                                                    'Total Tasks']
                                                                .toString())) *
                                                        100)
                                                    .toStringAsFixed(1) +
                                                "%",
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                              color: darkBlueTheme,
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            strings.totalTasks,
                                            style: TextStyle(
                                              color: lightGreyTheme,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          Text(
                                            snapshot.data['Total Tasks']
                                                .toString(),
                                            style: TextStyle(
                                              color: darkBlueTheme,
                                              fontSize: 18,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 6,
                                          ),
                                          Row(
                                            children: [
                                              Text(
                                                "+11.02%",
                                                style: TextStyle(
                                                  color: darkBlueTheme,
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                              SizedBox(
                                                width: 5,
                                              ),
                                              ImageIcon(
                                                AssetImage(
                                                    images.increaseGraphIcon),
                                                color: darkBlueTheme,
                                                size: 12,
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                      SizedBox(
                                        height: 80,
                                        child: VerticalDivider(
                                          color: lightGrey,
                                          thickness: 1,
                                          width: 1,
                                          indent: 0,
                                          endIndent: 0,
                                        ),
                                      ),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            strings.completed,
                                            style: TextStyle(
                                              color: lightGreyTheme,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          Text(
                                            snapshot.data['Completed Tasks']
                                                .toString(),
                                            style: TextStyle(
                                              color: darkBlueTheme,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Text(
                                            strings.remaining,
                                            style: TextStyle(
                                              color: lightGreyTheme,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                          Text(
                                            snapshot.data['Remaining Tasks']
                                                .toString(),
                                            style: TextStyle(
                                              color: darkBlueTheme,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  );
                                }
                              });
                        },
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      strings.subcontractorDetail,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.06),
                              blurRadius: 100,
                              offset: Offset(0, 0),
                            ),
                          ]),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 6),
                                child: Text(
                                  currentUser != null
                                      ? currentUser!.name.toString()
                                      : "",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: darkBlueTheme,
                                  ),
                                ),
                                decoration: BoxDecoration(
                                  color: lightBlueTheme,
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                              IconButton(
                                visualDensity:
                                    VisualDensity(horizontal: -4, vertical: -4),
                                padding: EdgeInsets.zero,
                                style: IconButton.styleFrom(
                                  tapTargetSize:
                                      MaterialTapTargetSize.shrinkWrap,
                                ),
                                onPressed: () {},
                                icon: Icon(
                                  Icons.more_vert_rounded,
                                  size: 20,
                                  color: lightGreyTheme,
                                ),
                              )
                            ],
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 5),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  currentUser != null
                                      ? currentUser!.email.toString()
                                      : "",
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: lightGreyTheme,
                                  ),
                                ),
                                Row(
                                  children: [
                                    Text(
                                      strings.id,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: darkBlueTheme,
                                      ),
                                    ),
                                    Text(
                                      currentUser != null
                                          ? currentUser!.id.toString()
                                          : "",
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        color: darkBlueTheme,
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          strings.timeClock,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            visualDensity:
                                VisualDensity(horizontal: -4, vertical: -4),
                          ),
                          child: Text(
                            strings.viewShifts,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: darkBlueTheme,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    ValueListenableBuilder(
                      valueListenable: isClockedIn,
                      builder: (context, value, child) {
                        return Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                              color: white,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 100,
                                  offset: Offset(0, 0),
                                ),
                              ]),
                          child: Column(
                            children: [
                              ValueListenableBuilder(
                                valueListenable: timerState,
                                builder: (context, value, child) {
                                  return Text(
                                    isClockedIn.value
                                        ? '${hours.toString().padLeft(2, '0')} H : ${minutes.toString().padLeft(2, '0')} Min'
                                        : strings.offTheClock,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: lightGreyTheme,
                                    ),
                                  );
                                },
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              TextButton(
                                onPressed: () async {
                                  var clockResponse;
                                  isClockedIn.value
                                      ? clockResponse = await doClockOut(
                                          dateTime: DateTime.now(),
                                        )
                                      : clockResponse = await doClockIn(
                                          dateTime: DateTime.now(),
                                        );
                                  isClockedIn.value
                                      ? stopTimer()
                                      : startTimer();
                                  if (clockResponse == null) {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return GeneralPopUp(
                                          message: strings.genericError,
                                        );
                                      },
                                    );
                                  } else if (clockResponse != "OK") {
                                    showDialog(
                                      context: context,
                                      builder: (context) {
                                        return GeneralPopUp(
                                          message: clockResponse.toString(),
                                        );
                                      },
                                    );
                                  }
                                  isClockedIn.value = !isClockedIn.value;
                                },
                                style: TextButton.styleFrom(
                                    backgroundColor: lightBlueTheme,
                                    minimumSize: Size(double.infinity, 52),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    )),
                                child: Text(
                                  isClockedIn.value
                                      ? strings.clockOut
                                      : strings.clockIn,
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w700,
                                    color: darkBlueTheme,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 10,
              ),
              Container(
                height: 4,
                width: 75,
                margin: EdgeInsets.only(left: 16),
                decoration: BoxDecoration(
                  color: darkBlueTheme,
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              Divider(
                thickness: 1,
                color: lightGrey,
                height: 0,
              ),
              SizedBox(
                height: 12,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            strings.myToDoS,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          TextButton(
                            onPressed: () {},
                            style: TextButton.styleFrom(
                              visualDensity:
                                  VisualDensity(horizontal: -4, vertical: -4),
                            ),
                            child: Text(
                              strings.viewAll,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: darkBlueTheme,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      ValueListenableBuilder(
                        valueListenable: globalSelectedProjectId,
                        builder: (context, value, child) {
                          return StatefulBuilder(
                            builder: (context, setS) {
                              return FutureBuilder(
                                  future: fetchToDoList(),
                                  builder: (context, AsyncSnapshot snapshot) {
                                    if (snapshot.connectionState ==
                                        ConnectionState.waiting) {
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
                                    } else if (!snapshot.hasData) {
                                      return Center(
                                        child:
                                            Text(strings.genericDataFetchError),
                                      );
                                    } else {
                                      return SizedBox(
                                        height: 300,
                                        child: Material(
                                          color: transparent,
                                          child: ListView.builder(
                                            shrinkWrap: true,
                                            itemCount: snapshot.data.length,
                                            itemBuilder: (context, index) {
                                              String id =
                                                  snapshot.data[index].id;
                                              String itemType =
                                                  snapshot.data[index].itemType;
                                              String description = snapshot
                                                  .data[index].description;
                                              String status =
                                                  snapshot.data[index].status;
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 2.5),
                                                child: ListTile(
                                                  dense: true,
                                                  tileColor: white,
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                          horizontal: 15,
                                                          vertical: 2),
                                                  minLeadingWidth: 15,
                                                  trailing: Row(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    children: [
                                                      Container(
                                                        height: 28,
                                                        width: 80,
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal: 10,
                                                                vertical: 5),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: status ==
                                                                  "Pending"
                                                              ? red
                                                              : (status ==
                                                                      "Approved"
                                                                  ? orange
                                                                  : (status ==
                                                                          "Shipped"
                                                                      ? blue
                                                                      : (status ==
                                                                              "Delivered"
                                                                          ? green
                                                                          : lightBlueTheme))),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5),
                                                        ),
                                                        child: Center(
                                                          child: Text(
                                                            status,
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                              fontSize: 10,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              color: white,
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                      SizedBox(
                                                        width: 10,
                                                      ),
                                                      PopupMenuButton<String>(
                                                        padding:
                                                            EdgeInsets.zero,
                                                        color: white,
                                                        menuPadding:
                                                            EdgeInsets.all(5),
                                                        shape:
                                                            RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(10),
                                                        ),
                                                        elevation: 5,
                                                        offset: Offset(0, 40),
                                                        icon: Icon(
                                                          Icons
                                                              .more_vert_rounded,
                                                          size: 20,
                                                          color: lightGreyTheme,
                                                        ),
                                                        style: ButtonStyle(
                                                          visualDensity:
                                                              VisualDensity(
                                                            horizontal: -4,
                                                            vertical: -4,
                                                          ),
                                                          tapTargetSize:
                                                              MaterialTapTargetSize
                                                                  .shrinkWrap,
                                                        ),
                                                        itemBuilder: (context) {
                                                          return [
                                                            PopupMenuItem(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(5),
                                                              height: 35,
                                                              child: Text(
                                                                strings.edit,
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 12,
                                                                ),
                                                              ),
                                                              value: "Edit",
                                                              onTap: () {
                                                                Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                    builder:
                                                                        (context) =>
                                                                            EditToDo(
                                                                      id: id,
                                                                      punchItemType:
                                                                          itemType,
                                                                      punchItemDesc:
                                                                          description,
                                                                      statusValue:
                                                                          status,
                                                                    ),
                                                                  ),
                                                                ).whenComplete(
                                                                    () {
                                                                  setS(
                                                                    () {},
                                                                  );
                                                                });
                                                              },
                                                            ),
                                                            PopupMenuItem(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(5),
                                                              height: 35,
                                                              child: Text(
                                                                strings.delete,
                                                                style:
                                                                    TextStyle(
                                                                  fontSize: 12,
                                                                  color: red,
                                                                ),
                                                              ),
                                                              value: "Delete",
                                                              onTap: () async {
                                                                var responseMessage =
                                                                    await deleteToDoItem(
                                                                        id);
                                                                if (responseMessage !=
                                                                    "OK") {
                                                                  showDialog(
                                                                    context:
                                                                        context,
                                                                    builder:
                                                                        (context) {
                                                                      return GeneralPopUp(
                                                                        message:
                                                                            responseMessage,
                                                                      );
                                                                    },
                                                                  );
                                                                } else {
                                                                  setS(
                                                                    () {},
                                                                  );
                                                                }
                                                              },
                                                            ),
                                                          ];
                                                        },
                                                      ),
                                                    ],
                                                  ),
                                                  title: Text(
                                                    itemType.toString(),
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      color: darkGreyTheme,
                                                    ),
                                                  ),
                                                  subtitle: Text(
                                                    description,
                                                    style: TextStyle(
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      color: lightGreyTheme,
                                                    ),
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      );
                                    }
                                  });
                            },
                          );
                        },
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
