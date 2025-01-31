import 'dart:ui';
import 'package:Buildify_AI/main.dart';
import 'package:Buildify_AI/pages/homepage.dart';
import 'package:Buildify_AI/utils/api_calls.dart';
import 'package:Buildify_AI/utils/colors.dart';
import 'package:Buildify_AI/utils/routes.dart';
import 'package:Buildify_AI/utils/strings.dart';
import 'package:Buildify_AI/widgets/generalPopUp.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

var clockResponse;

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with SingleTickerProviderStateMixin {
  int _selectedPageIndex = 0;
  ValueNotifier<bool> _popupOpened = ValueNotifier(false);
  late AnimationController _controller;
  late Animation<double> _rotationAnimation;
  String? authToken;
  int? userID;
  static const List<Widget> _pages = <Widget>[
    HomePage(),
    HomePage(),
    HomePage(),
    HomePage(),
    HomePage(),
  ];

  _getID() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String id = prefs.getString('user_id')!;
    authToken = prefs.getString('token')!;
    userID = int.parse(id);
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _getID();
    _controller = AnimationController(
      duration: const Duration(microseconds: 10),
      vsync: this,
    );
    _rotationAnimation = Tween<double>(begin: 0, end: 45).animate(_controller);
  }

  fetchInitialData() async {
    var userResponse;
    var projectResponse;
    if (currentUser == null) {
      userResponse = await fetchUserDetails();
      if (userResponse == null) {
        showDialog(
          context: context,
          builder: (context) {
            return GeneralPopUp(message: strings.userDataFetchError);
          },
        );
      } else if (userResponse != "OK") {
        showDialog(
          context: context,
          builder: (context) {
            return GeneralPopUp(message: userResponse.toString());
          },
        );
      }
    }
    projectResponse = await fetchProjectDropdown();
    if (projectResponse == null) {
      showDialog(
        context: context,
        builder: (context) {
          return GeneralPopUp(message: strings.projectDropdownFetchError);
        },
      );
    } else if (projectResponse.runtimeType == String) {
      showDialog(
        context: context,
        builder: (context) {
          return GeneralPopUp(message: projectResponse.toString());
        },
      );
    } else {
      projectDropdownItems = projectResponse;
      globalSelectedProjectId.value = projectResponse[0].id;
    }
    clockResponse = await fetchClockDetails(dateTime: DateTime.now());
    if (clockResponse == null) {
      showDialog(
        context: context,
        builder: (context) {
          return GeneralPopUp(message: strings.userDataFetchError);
        },
      );
    } else if (clockResponse.runtimeType == String) {
      showDialog(
        context: context,
        builder: (context) {
          return GeneralPopUp(message: clockResponse.toString());
        },
      );
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: white,
      child: FutureBuilder(
        future: fetchInitialData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Container(
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  color: Colors.black38,
                ),
                child: SizedBox(
                  height: 50,
                  width: 50,
                  child: CircularProgressIndicator(
                    backgroundColor: progressBg,
                    color: darkBlueTheme,
                    strokeCap: StrokeCap.round,
                    strokeWidth: 2.5,
                  ),
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            return Scaffold(
              backgroundColor: lightBlueTheme,
              appBar: AppBar(
                flexibleSpace: Container(
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      ),
                      gradient: LinearGradient(
                        colors: [
                          headerGradient2,
                          headerGradient1,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 20,
                          offset: const Offset(0, -7),
                        ),
                      ]),
                ),
                leading: Padding(
                  padding: const EdgeInsets.only(
                    left: 10,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.menu,
                      color: white,
                      weight: 18,
                    ),
                    onPressed: () {},
                  ),
                ),
                title: Text(
                  "Buildify AI",
                  style: TextStyle(
                    color: white,
                    fontSize: 20,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                titleSpacing: 5,
                actionsIconTheme: IconThemeData(
                  color: white,
                ),
                actions: [
                  IconButton(
                    visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                    icon: ImageIcon(
                      AssetImage(images.searchIcon),
                      size: 18,
                    ),
                    onPressed: () {},
                  ),
                  IconButton(
                    visualDensity: VisualDensity(horizontal: -4, vertical: -4),
                    icon: ImageIcon(
                      AssetImage(images.chatIcon),
                      size: 18,
                    ),
                    onPressed: () {
                      Navigator.of(context).pushNamed(Routes.listChats);
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(
                      right: 15,
                    ),
                    child: IconButton(
                      visualDensity:
                          VisualDensity(horizontal: -4, vertical: -4),
                      icon: Image.asset(
                        images.notifyBellIcon,
                        height: 21,
                        width: 21,
                      ),
                      onPressed: () {},
                    ),
                  ),
                ],
                toolbarHeight: 50,
                bottom: PreferredSize(
                  preferredSize: Size.fromHeight(60),
                  child: Container(
                    margin: EdgeInsets.fromLTRB(
                      25,
                      10,
                      25,
                      20,
                    ),
                    padding: EdgeInsets.symmetric(
                      vertical: 7,
                      horizontal: 20,
                    ),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white.withOpacity(0.2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 100,
                            offset: const Offset(0, 0),
                          ),
                        ]),
                    child: ValueListenableBuilder(
                      valueListenable: globalSelectedProjectId,
                      builder: (context, globalSelectedProjectIdValue, child) {
                        return DropdownButton<String>(
                          dropdownColor: Colors.black87,
                          menuMaxHeight: 250,
                          items: projectDropdownItems!.map((e) {
                            return DropdownMenuItem<String>(
                              value: e.id,
                              child: Text(
                                e.name,
                                style: TextStyle(
                                  color: white,
                                  fontSize: 14,
                                ),
                              ),
                            );
                          }).toList(),
                          style: const TextStyle(
                            color: white,
                            fontSize: 14,
                          ),
                          value: globalSelectedProjectIdValue,
                          isDense: true,
                          isExpanded: true,
                          onChanged: (value) {
                            globalSelectedProjectId.value = value!;
                          },
                          borderRadius: BorderRadius.circular(10),
                          hint: Text(
                            strings.project,
                            style: TextStyle(
                              color: white,
                              fontSize: 14,
                            ),
                          ),
                          icon: Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: white,
                          ),
                          underline: SizedBox.shrink(),
                        );
                      },
                    ),
                  ),
                ),
              ),
              floatingActionButton: ValueListenableBuilder(
                valueListenable: _popupOpened,
                builder: (context, popupOpenedValue, child) => AnimatedBuilder(
                    animation: _rotationAnimation,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: _rotationAnimation.value * (3.14159 / 180),
                        child: BackdropFilter(
                          filter: _popupOpened.value
                              ? ImageFilter.blur(sigmaX: 8, sigmaY: 8)
                              : ImageFilter.blur(sigmaX: 0, sigmaY: 0),
                          child: Container(
                            height: 60,
                            width: 60,
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const LinearGradient(
                                  colors: [
                                    floatingButtonGradient1,
                                    floatingButtonGradient2,
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 20,
                                    offset: const Offset(0, 5),
                                  ),
                                ]),
                            child: PopupMenuButton(
                                offset: Offset(-5, -450),
                                popUpAnimationStyle: AnimationStyle(
                                  curve: Curves.linear,
                                  duration: Duration(milliseconds: 200),
                                  reverseCurve: Curves.ease,
                                  reverseDuration: Duration(milliseconds: 200),
                                ),
                                child: Center(
                                  child: Icon(
                                    Icons.add_rounded,
                                    color: white,
                                    size: 40,
                                  ),
                                ),
                                constraints: BoxConstraints(
                                  minWidth:
                                      MediaQuery.of(context).size.width * .9,
                                ),
                                onOpened: () {
                                  _controller.forward();
                                  _popupOpened.value = true;
                                },
                                onCanceled: () {
                                  _controller.reverse();
                                  _popupOpened.value = false;
                                },
                                shape: CustomShapeBorder(),
                                elevation: 3,
                                color: white,
                                itemBuilder: (context) => [
                                      PopupMenuItem(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 15),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              popupField(strings.popuptakePhoto,
                                                  images.cameraIcon, () {
                                                Navigator.of(context).pop();
                                                Navigator.of(context).pushNamed(
                                                    Routes.takePhotoRoute);
                                              }),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              popupField(
                                                  strings.popupchoosePhoto,
                                                  images.photoIcon, () {
                                                Navigator.of(context).pop();
                                                Navigator.of(context).pushNamed(
                                                    Routes.takePhotoRoute);
                                              }),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              popupField(
                                                  strings.popupUploadFiles,
                                                  images.popUpUploadIcon, () {
                                                Navigator.of(context).pop();
                                                Navigator.of(context).pushNamed(
                                                    Routes.fileManagerRoute);
                                              }),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              popupField(
                                                  strings.popupAddDailyLogs,
                                                  images.rightIcon, () {
                                                Navigator.of(context).pop();
                                                Navigator.of(context).pushNamed(
                                                    Routes.dailyLogRoute);
                                              }),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              popupField(strings.popupAddTodo,
                                                  images.aiButtonIcon, () {
                                                Navigator.of(context).pop();
                                                Navigator.of(context)
                                                    .pushNamed(
                                                        Routes.punchItemRoute)
                                                    .whenComplete(() {
                                                  setState(() {});
                                                });
                                              }),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              popupField(
                                                  strings.popupComposeMessage,
                                                  images.chatIcon, () {
                                                Navigator.of(context).pop();
                                                Navigator.of(context).pushNamed(
                                                    Routes.listChats);
                                              }),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              popupField(strings.popupScanBill,
                                                  images.sacnIcon, () {
                                                Navigator.of(context).pop();
                                                Navigator.of(context).pushNamed(
                                                    Routes.scanQrRoute);
                                              }),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ]),
                          ),
                        ),
                      );
                    }),
              ),
              bottomNavigationBar: Stack(
                children: [
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 0,
                      decoration: BoxDecoration(
                        color: transparent,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(1),
                            spreadRadius: 3,
                            blurRadius: 120,
                            offset: Offset(0, -10),
                          ),
                        ],
                      ),
                    ),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(15),
                      topRight: Radius.circular(15),
                    ),
                    child: Container(
                      padding: EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(15),
                          topRight: Radius.circular(15),
                        ),
                      ),
                      child: Theme(
                        data: Theme.of(context).copyWith(
                          splashFactory:
                              NoSplash.splashFactory, // Disables splash effect
                          highlightColor:
                              Colors.transparent, // Removes highlight effect
                        ),
                        child: BottomNavigationBar(
                          type: BottomNavigationBarType.fixed,
                          elevation: 0,
                          currentIndex: _selectedPageIndex,
                          backgroundColor: white,
                          selectedItemColor: darkBlueTheme,
                          unselectedItemColor: Colors.grey,
                          iconSize: 20,
                          unselectedLabelStyle: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 10,
                          ),
                          selectedLabelStyle: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 12,
                          ),
                          onTap: _onItemTapped,
                          items: [
                            BottomNavigationBarItem(
                              icon: ImageIcon(
                                AssetImage(
                                  images.homeIcon,
                                ),
                              ),
                              label: strings.home,
                            ),
                            BottomNavigationBarItem(
                              icon: ImageIcon(
                                AssetImage(
                                  images.scheduleIcon,
                                ),
                              ),
                              label: strings.schedule,
                            ),
                            BottomNavigationBarItem(
                              icon: ImageIcon(
                                AssetImage(
                                  images.progressionIcon,
                                ),
                              ),
                              label: strings.progression,
                            ),
                            BottomNavigationBarItem(
                              icon: ImageIcon(
                                AssetImage(
                                  images.aiButtonIcon,
                                ),
                              ),
                              label: strings.aiButton,
                            ),
                            BottomNavigationBarItem(
                              icon: ImageIcon(
                                AssetImage(
                                  images.profileIcon,
                                ),
                              ),
                              label: strings.profile,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              body: _pages[_selectedPageIndex],
            );
          }
        },
      ),
    );
  }

  InkWell popupField(String text, icon, ontap, {double size = 15}) {
    return InkWell(
      onTap: ontap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
            color: white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                offset: Offset(0, 0),
                blurRadius: 50,
                spreadRadius: 0,
                color: Colors.black.withOpacity(0.08),
              ),
            ]),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ImageIcon(
              AssetImage(icon),
              size: size,
              color: Color(0xFF002E77),
            ),
            SizedBox(
              width: 10,
            ),
            Text(
              text,
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            )
          ],
        ),
      ),
    );
  }
}

class CustomShapeBorder extends ShapeBorder {
  @override
  EdgeInsetsGeometry get dimensions => EdgeInsets.all(0);

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    final path = Path()
      ..addRRect(RRect.fromRectAndCorners(
        rect,
        topLeft: const Radius.circular(20),
        topRight: const Radius.circular(20),
        bottomLeft: const Radius.circular(20),
      ))
      // ..close();
      ..moveTo(rect.bottomRight.dx, rect.bottomRight.dy)
      ..relativeLineTo(-50, 0)
      ..quadraticBezierTo(rect.bottomRight.dx - 40, rect.bottomRight.dy,
          rect.bottomRight.dx - 15, rect.bottomRight.dy + 40)
      ..lineTo(rect.bottomRight.dx, rect.bottomRight.dy + 50)
      ..close();

    return path;
  }

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path();
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final paint = Paint()
      ..color = Colors.transparent
      ..style = PaintingStyle.fill;

    canvas.drawPath(getOuterPath(rect, textDirection: textDirection), paint);
  }

  @override
  ShapeBorder scale(double t) => CustomShapeBorder();
}
