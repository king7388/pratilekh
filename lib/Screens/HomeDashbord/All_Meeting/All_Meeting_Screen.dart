import 'dart:convert';


import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../../DataBase_Backend/Helpers/Helper.dart';
import '../../../DataBase_Backend/Models/MeetingsModel.dart';
import '../../../Utils/Contants.dart';
import '../../../Utils/UI_HELPER.dart';
import '../Add_Meeting_Screen/Add_Meeting_Screen.dart';
import 'Transcript_Using_Audio.dart';
import 'ViewAll_Details.dart';

class All_Meeting_Screen extends StatefulWidget {
  All_Meeting_Screen({Key? key}) : super(key: key);

  @override
  State<All_Meeting_Screen> createState() => _All_Meeting_ScreenState();
}

class _All_Meeting_ScreenState extends State<All_Meeting_Screen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 80.0),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 100.0),
              child: Container(
                height: MediaQuery.of(context).size.height,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(AppString.Allmeeting, style: TextStyleForTitle),
                      ],
                    ),
                    const Divider(),
                    FutureBuilder<List<Map<String, dynamic>>>(
                      future: DatabaseHelper.getAllMeetings(),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          // While data is loading, show a loading indicator
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (snapshot.hasError) {
                          // If an error occurs while loading data, show an error message
                          return Center(
                            child: Text(
                                'Error loading meetings: ${snapshot.error}'),
                          );
                        } else {
                          List<Map<String, dynamic>>? meetings = snapshot.data;

                          if (meetings == null || meetings.isEmpty) {
                            return const Center(
                              child: Text('No meetings available'),
                            );
                          }
                          return Expanded(
                            child: ListView.builder(
                              itemCount: meetings.length,
                              itemBuilder: (context, index) {
                                final meeting = meetings[
                                    index]; // Assuming meetings is a list of Map<String, dynamic>
                                String jsonMeeting = jsonEncode(
                                    meeting); // Convert the meeting map to a JSON string


// Now deserialize the JSON string to a Meeting object
                                Meeting newMeeting =
                                    Meeting.fromJson(meetings[index]);



                                return Column(
                                  children: [
                                    ListTile(
                                      leading: Text(
                                        '${index + 1}.',
                                        style: TextStyleForTitle,
                                      ),
                                      title: Text(
                                          '${meeting['title'] ?? 'Title not available'}'),
                                      subtitle: Text(meeting['meetingDate'] ??
                                          'Date not available'),
                                      trailing: SizedBox(
                                        // Wrap the Row with a SizedBox
                                        width:
                                            300, // Set the width according to your requirement
                                        child: Row(
                                          children: [
                                            ElevatedButton(
                                                onPressed: () {
                                                  DatabaseHelper
                                                      .getMeetingRecords(
                                                          meeting[
                                                              'meeting_id']);
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              Meeting_DetailsScreen(
                                                                meetingId: meeting[
                                                                    'meeting_id'],
                                                              )));
                                                },
                                                child: Text('View')),
                                            Spacer(),
                                            ElevatedButton(
                                                onPressed: () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              Add_Meeting_Screen(
                                                                ispadding: true,
                                                                meetingheld: meeting[
                                                                'meeting_held'],
                                                                meeting:
                                                                    newMeeting,
                                                                addmember: meeting[
                                                                    'memberList'],
                                                                invitedmember:
                                                                    meeting[
                                                                        'inviteMemberList'],
                                                                copyto: meeting[
                                                                    'copyto'],
                                                              )));
                                                },
                                                child: Text('Edit')),
                                            Spacer(),
                                            ElevatedButton(
                                                onPressed: () {
                                                  Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                          builder: (context) =>
                                                              Voice_Transcreption_For_Audio(
                                                                  meeting_id:
                                                                      meeting[
                                                                          'meeting_id'])));
                                                },
                                                child: Text('Process')),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Divider()
                                  ],
                                );
                              },
                            ),
                          );
                        }
                      },
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
