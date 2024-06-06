import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppString {
  static const Addmeeting = 'Add Meeting';
  static const Allmeeting = 'All Meetings';
  static const LiveTrancreption = 'Live Transcription';
  static const meetingtitle = 'Meeting Title';
  static const meetingheldby = 'Meeting Held By';
  static const MeetingDate = 'Meeting Date';
  static const memberlist = 'Member list';
  static const Invitemember = 'Invite/ Other Member';
  static const addmeetngtitlehint = 'Add Meeting Title Here...';
  static const Addmeetingmemberhint = 'Add Meeting Title Here..';
  static const Addinviteshint = 'Invite Meeting member';
  static const Codeno = 'Code No';
  static const Cotyto = 'Copy to';
  static const errormessageforProcessdata='Data Not Available if you want proceed then Process here ';
  static const Update_Data_msg='Your data have been successfully Updated , Now You can see on click View ';
  static const summersucess='Meeting of minutes (M-O-M) has been successfully generated';
  static const process_sucess='Your process are successful';
  static const process_error='Your process failed Please try again';
  static const Meeting_save_success='Your  meeting Successfully saved';
  static const Meeting_save_failed='Failed to save   meeting try again...';
}


 TextStyle myBoldBlueStyle = const TextStyle(
  fontSize: 15,
  fontWeight: FontWeight.w400,
  color: Colors.blue,
  decoration: TextDecoration.none,
   fontFamily: "Montserrat-Regular",
);



TextStyle myBoldblackStyle = const TextStyle(
  fontSize: 15,
  color: Colors.black,
  fontWeight: FontWeight.w200,
  decoration: TextDecoration.none,
  fontFamily: "Montserrat-Regular",
);


TextStyle TextStyleForTitle = const TextStyle(
  fontSize: 15,
  color: Colors.blue,
  fontWeight: FontWeight.bold,
  fontFamily: "Montserrat-Regular",
);



TextStyle TextStyleForhint = const TextStyle(
  fontSize: 12,
  color: Colors.grey,
  fontWeight: FontWeight.bold,
  fontFamily: "Montserrat-Regular",
);
TextStyle TextStyleForDropdown = const TextStyle(
  fontSize: 15,
  color: Colors.blue,
  fontWeight: FontWeight.bold,
  fontFamily: "Montserrat-Regular",
);
class ScreenUtil {
  static double getScreenHeight(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    // Check platform and adjust screen height accordingly
    if (Theme.of(context).platform == TargetPlatform.iOS) {
      // Adjust height for iOS
      screenHeight -=
          kBottomNavigationBarHeight; // Subtract bottom navigation bar height
    } else if (Theme.of(context).platform == TargetPlatform.android) {
      // screenHeight -= kBottomNavigationBarHeight*.01;

      // Adjust height for Android
      // You can apply additional adjustments if needed
    }

    return screenHeight;
  }

  static double getScreenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }
}
