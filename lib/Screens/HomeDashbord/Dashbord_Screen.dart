
import 'package:easy_sidemenu/easy_sidemenu.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_window_close/flutter_window_close.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:web_socket_channel/io.dart';
import 'dart:io';
import '../../Utils/Contants.dart';
import 'Add_Meeting_Screen/Add_Meeting_Screen.dart';
import 'All_Meeting/All_Meeting_Screen.dart';
import 'All_Meeting/Transcript_Using_Audio.dart';
import 'All_Meeting/ViewAll_Details.dart';
import 'Voice_Transcretion_Screen/Live_Transcreption_Page.dart';

class DashBoard_Screen extends StatefulWidget {
  const DashBoard_Screen({super.key});

  @override
  State<DashBoard_Screen> createState() => _DashBoard_ScreenState();
}

class _DashBoard_ScreenState extends State<DashBoard_Screen> {
  PageController pageController = PageController();
  SideMenuController sideMenu = SideMenuController();

  int currentPageIndex = 0;

  void toggleExtraPageVisibility() {
    setState(() {
      currentPageIndex = 1; // Show the extra page
      sideMenu.changePage(currentPageIndex);
    });
  }
  var _alertShowing = false;
  var _index = 0;
  @override
  void initState() {
    super.initState();
    pageController.addListener(() {
      int newIndex = pageController.page!.round();
      if (newIndex != currentPageIndex) {
        setState(() {
          currentPageIndex = newIndex;
          sideMenu.changePage(newIndex);
        });
      }
    });
    if (Platform.isWindows) {
      FlutterWindowClose.setWindowShouldCloseHandler(() async {
        if (_index == 0) {
          if (_alertShowing) return false;
          _alertShowing = true;
          return await showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                    title: const Text('Do you really want to quit?'),
                    actions: [
                      ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop(true);
                            _alertShowing = false;
                          },
                          child: const Text('Yes')),
                      ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop(false);
                            _alertShowing = false;
                          },
                          child: const Text('No'))
                    ]);
              });
        } else if (_index == 1) {
          if (_alertShowing) return false;
          _alertShowing = true;

          return await showDialog(
              context: context,
              builder: (context) {
                return AlertDialog(
                    title: const Text('Do you really want to quit?'),
                    actions: [
                      ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop(true);
                            _alertShowing = false;
                          },
                          child: const Text('Yes')),
                      ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop(false);
                            _alertShowing = false;
                          },
                          child: const Text('No'))
                    ]);
              });
        } else if (_index == 3) {
          return await Future.delayed(const Duration(seconds: 1), () => true);
        }
        return true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        titleSpacing: 00.0,
        centerTitle: true,
        toolbarHeight: 50.2,
        toolbarOpacity: 0.8,
        // shape: const RoundedRectangleBorder(
        //   borderRadius: BorderRadius.only(
        //       bottomRight: Radius.circular(25),
        //       bottomLeft: Radius.circular(25)),
        // ),
        elevation: 0.00,
        backgroundColor: Colors.blueAccent.shade200,
        //elevation: 10,
        title: Text(
          'PRATILEKH',
          style: GoogleFonts.jost(
            textStyle: const TextStyle(
                color: Colors.white,
                letterSpacing: .5,
                fontSize: 30,
                fontWeight: FontWeight.w500),
          ),
        ),
      ),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SizedBox(
            width: 210,
            child: SideMenu(
              controller: sideMenu,
              style: SideMenuStyle(
                // showTooltip: false,
                displayMode: SideMenuDisplayMode.auto,
                showHamburger: false,
                hoverColor: Colors.blue[100],
                selectedHoverColor: Colors.blue[100],
                selectedColor: Colors.lightBlue,
                selectedTitleTextStyle: const TextStyle(color: Colors.white),
                selectedIconColor: Colors.white,
                // decoration: BoxDecoration(
                //   borderRadius: BorderRadius.all(Radius.circular(10)),
                // ),
                // backgroundColor: Colors.grey[200]
              ),
              title: Column(
                children: [
                  Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 38.0, vertical: 10),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxHeight: 80,
                            maxWidth: 80,
                          ),
                          child: Image.asset(
                            'assets/images/army.png',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(
                    indent: 8.0,
                    endIndent: 8.0,
                  ),
                ],
              ),
              items: [
                SideMenuItem(
                  title: AppString.Addmeeting,
                  onTap: (index, _) {
                    pageController.jumpToPage(index);
                  },
                  icon: const Icon(Icons.supervisor_account),
                ),
                SideMenuItem(
                  title: AppString.Allmeeting,
                  onTap: (index, _) {
                    pageController.jumpToPage(index);
                  },
                  icon: const Icon(Icons.supervisor_account),
                ),
                SideMenuItem(
                  title: AppString.LiveTrancreption,
                  onTap: (index, _) {
                    pageController.jumpToPage(index);
                  },
                  icon: const Icon(Icons.mic),
                ),
              ],
            ),
          ),
          const VerticalDivider(
            width: 2,
          ),
          Expanded(
            child: PageView(
              controller: pageController,
              onPageChanged: (index) {
                setState(() {
                  currentPageIndex = index;
                  sideMenu.changePage(index);
                });
              },
              children: [
                Add_Meeting_Screen(),
                All_Meeting_Screen(),
                Live_Transcripton_Screen(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
