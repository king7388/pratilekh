import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import '../../../DataBase_Backend/Helpers/Helper.dart';
import '../../../DataBase_Backend/Models/MeetingsModel.dart';
import '../../../Utils/Contants.dart';
import '../../../Utils/UI_HELPER.dart';
import '../../../Utils/responsive.dart';
import '../All_Meeting/Transcript_Using_Audio.dart';




class Add_Meeting_Screen extends StatefulWidget {
  Meeting? meeting;
  var ispadding;
  var addmember;
  var invitedmember;
  var copyto;
  var meetingheld;

   Add_Meeting_Screen({super.key,this.meeting,this.ispadding,this.invitedmember,this.copyto,this.addmember,this.meetingheld});

  @override
  State<Add_Meeting_Screen> createState() => _Add_Meeting_ScreenState();
}

class _Add_Meeting_ScreenState extends State<Add_Meeting_Screen> {
  TextEditingController meetingheld = TextEditingController();
  TextEditingController Meetingtitle = TextEditingController();
  TextEditingController Addmettingmenber = TextEditingController();
  TextEditingController invitemeetingmember = TextEditingController();
  TextEditingController Copyto = TextEditingController();
  TextEditingController Codeno = TextEditingController();
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _textController.text =  DateFormat('yyyy-MM-dd').format(DateTime.now());
    Meetingtitle.text=widget.meeting?.title??'';
    Codeno.text=widget.meeting?.codeNo??'';
    meetingheld.text= widget.meetingheld ??'';
    if(widget.ispadding==true){
      buildMemberListforaddmember(widget.addmember);
      buildMemberListforinvited(widget.invitedmember);
      buildMemberListforcopy(widget.copyto);
    }

  }
  buildMemberListforaddmember(String members) {
    if (members == 'null') {
      return null;
    }else {
      List<dynamic> decodedList = jsonDecode(members);
      List<String> memberList = decodedList.cast<String>();
      addedMembersList.addAll(memberList);
    }
  }

  buildMemberListforinvited(String members) {

    if (members == 'null') {
      return null;
    }else{
      List<dynamic> decodedList = jsonDecode(members);
      List<String> memberList = decodedList.cast<String>();
      InvitememberList.addAll(memberList);
    }

  }
  buildMemberListforcopy(String members) {

    if (members == 'null') {
      return null;
    }else {
      List<dynamic> decodedList = jsonDecode(members);
      List<String> memberList = decodedList.cast<String>();
      Copytolist.addAll(memberList);
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        _textController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    } else {
      _textController.text = 'not found';
    }
  }
  List<String> addedMembersList = [];
  List<String> InvitememberList = [];
  List<String> Copytolist = [];


  @override
  Widget build(BuildContext context) {
    final screenHeight = ScreenUtil.getScreenHeight(context);
    final screenWidth = ScreenUtil.getScreenWidth(context);
    return Scaffold(
      appBar: AppBar(
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 130.0),
          child: Column(
            children: [
              Row(
                children: [
                  Padding(
                    padding: widget.ispadding==null?const EdgeInsets.only(top: 58.0,bottom: 5,left: 5):const EdgeInsets.only(top: 58.0,bottom: 5,left: 5),
                    child: Text(
                      AppString.meetingtitle,
                      style: TextStyleForTitle,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 40,
               // width: widget.ispadding==null?1500:1350,
                child: SizedBox(
                  height: 40,
                  child: Container(
                    decoration: containerDecorationgrayoutline,
                    child: TextFormField(
                      cursorHeight: 20,
                      controller: Meetingtitle,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.only(bottom: 5,left: 5),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),

                // Custom_TextFormFields.CustomTextFormField(
                //     context, Meetingtitle, 'Add meeting title', false, ''),
              ),
              Row(
                children: [
                  Padding(
                    padding: widget.ispadding==null?const EdgeInsets.only(top: 28.0,bottom: 5,left: 5):const EdgeInsets.only(top: 58.0,bottom: 5,left: 5),
                    child: Text(
                      AppString.meetingheldby,
                      style: TextStyleForTitle,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 40,
                //width: widget.ispadding==null?1500:1350,
                child: SizedBox(
                  height: 40,
                  child: Container(
                    decoration: containerDecorationgrayoutline,
                    child: TextFormField(
                      cursorHeight: 20,
                      controller: meetingheld,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.only(bottom: 5,left: 5),
                        border: InputBorder.none,
                      ),
                    ),
                  ),
                ),

                // Custom_TextFormFields.CustomTextFormField(
                //     context, Meetingtitle, 'Add meeting title', false, ''),
              ),

              const SizedBox(
                height: 30,
              ),
              Padding(
                padding:widget.ispadding==null?const EdgeInsets.symmetric(horizontal: .0):const EdgeInsets.symmetric(horizontal: 5.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 5,left: 5),
                          child: Text(
                            AppString.MeetingDate,
                            style: TextStyleForTitle,
                          ),
                        ),
                        Container(
                          width: screenWidth * 0.2,
                          height: 40,
                          decoration: containerDecorationgrayoutline,
                          child: Center(
                            child: TextFormField(
                              readOnly: true,
                              //initialValue: _textController.text,
                              controller: _textController,
                              onTap: () {
                                _selectDate(context);
                              },
                              decoration: InputDecoration(
                                contentPadding: const EdgeInsets.only(
                                    top: 5.0,left: 20 ),
                                border: InputBorder
                                    .none, // Remove underline border from TextFormField
                                suffixIcon: IconButton(
                                  icon: const Icon(
                                    Icons.calendar_today,
                                    size: 18,
                                  ),
                                  onPressed: () {
                                    _selectDate(context);
                                  },
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(bottom: 5,left: 5),
                          child: Text(
                            AppString.Codeno,
                            style: TextStyleForTitle,
                          ),
                        ),
                        Container(
                          width: screenWidth * .34,
                          child: SizedBox(
                            height: 40,
                            child:Container(
                              decoration: containerDecorationgrayoutline,
                              child: TextFormField(
                                cursorHeight: 20,
                                controller: Codeno,
                                decoration: const InputDecoration(
                                  contentPadding: EdgeInsets.only(bottom: 5,left: 5),
                                  border: InputBorder.none,
                                ),
                              ),
                            ),

                            // Custom_TextFormFields.CustomTextFormField(
                            //     context, Codeno, 'Add meeting title', false, ''),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 30,
              ),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                // crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    decoration: containerDecorationgrayoutline,
                    child: SizedBox(
                      width: screenWidth * 0.2,
                      height: 500,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 18.0,top: 10,bottom: 5),
                                child: Text(
                                  AppString.memberlist,
                                  style: TextStyleForhint,
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child:SizedBox(
                                    height: 40,
                                    child: Container(
                                      decoration: containerDecorationgrayoutline,
                                      child: TextFormField(
                                        cursorHeight: 20,
                                        controller: Addmettingmenber,
                                        decoration: const InputDecoration(
                                          contentPadding: EdgeInsets.only(bottom: 5,left: 5),
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Custom_TextFormFields
                                  //     .CustomTextFormField(
                                  //         context,
                                  //         Addmettingmenber,
                                  //         'Add member',
                                  //         false,
                                  //         'Member '),
                                ),
                                const SizedBox(
                                  width: 20,
                                ),
                                OutlinedButton(
                                    onPressed: () {
                                      // Add the entered member to the list
                                      String member = Addmettingmenber.text;
                                      if (member.isNotEmpty) {
                                        setState(() {
                                          addedMembersList.add(member);
                                        });
                                        // Clear the text field after adding the member
                                        Addmettingmenber.clear();
                                      }
                                    }, child: Text('Add'),
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(color: Colors.blue), // Set the color of the outline
                                      foregroundColor: Colors.blue, // Set the color of the text
                                    )
                                )
                              ],
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: addedMembersList.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  title: Text(addedMembersList[index]),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.highlight_remove,size: 18,),
                                    onPressed: () {
                                      setState(() {
                                        // Remove the member from the list
                                        addedMembersList.removeAt(index);
                                      });
                                    },
                                  ),
                                  // You can add more customization to the list tiles as needed
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Container(
                    decoration: containerDecorationgrayoutline,
                    child: SizedBox(
                      width: screenWidth * 0.2,
                      height: 500,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 18.0,top: 10,bottom: 5),
                                child: Text(
                                  AppString.Invitemember,
                                  style: TextStyleForhint,
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child:
                                  SizedBox(
                                    height: 40,
                                    child: Container(
                                      decoration: containerDecorationgrayoutline,
                                      child: TextFormField(
                                        cursorHeight: 20,
                                        controller: invitemeetingmember,
                                        decoration: const InputDecoration(
                                          contentPadding: EdgeInsets.only(bottom: 5,left: 5),
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Custom_TextFormFields.CustomTextFormField(
                                  //   context,
                                  //   invitemeetingmember,
                                  //   'Add member',
                                  //   false,
                                  //   'Member',
                                  // ),
                                ),
                                SizedBox(width: 20),
                                OutlinedButton(
                                  onPressed: () {
                                    // Add the entered member to the list
                                    String member = invitemeetingmember.text;
                                    if (member.isNotEmpty) {
                                      setState(() {
                                        // Add the member to the list
                                        InvitememberList.add(member);
                                        // Clear the text field after adding the member
                                        invitemeetingmember.clear();
                                      });
                                    }
                                  },
                                  child: const Text('Add'),
                                    style: OutlinedButton.styleFrom(
                                      side: BorderSide(color: Colors.blue), // Set the color of the outline
                                      foregroundColor: Colors.blue, // Set the color of the text
                                    )
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: InvitememberList.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  title: Text(InvitememberList[index]),
                                  trailing: IconButton(
                                    icon: Icon(Icons.highlight_remove,size: 18,),
                                    onPressed: () {
                                      setState(() {
                                        // Remove the member from the list
                                        InvitememberList.removeAt(index);
                                      });
                                    },
                                  ),
                                  // You can add more customization to the list tiles as needed
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(
                    width: 20,
                  ),
                  Container(
                    decoration: containerDecorationgrayoutline,
                    child: SizedBox(
                      width: screenWidth * 0.2,
                      height: 500,
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 18.0,top: 10,bottom: 5),
                                child: Text(
                                  AppString.Cotyto,
                                  style: TextStyleForhint,
                                ),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    height: 40,
                                    child: Container(
                                      decoration: containerDecorationgrayoutline,
                                      child: TextFormField(
                                        cursorHeight: 20,
                                        controller: Copyto,
                                        decoration: const InputDecoration(
                                          contentPadding: EdgeInsets.only(bottom: 5,left: 5),
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Custom_TextFormFields.CustomTextFormField(
                                  //   context,
                                  //   Copyto,
                                  //   'Add member',
                                  //   false,
                                  //   'Member ',
                                  // ),
                                ),
                                const SizedBox(width: 20),
                                OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                  side: BorderSide(color: Colors.blue), // Set the color of the outline
                                  foregroundColor: Colors.blue, // Set the color of the text
                                ),onPressed: () {
                                  String member = Copyto.text;
                                  if (member.isNotEmpty) {
                                    setState(() {
                                      // Add the member to the list
                                      Copytolist.add(member);
                                      // Clear the text field after adding the member
                                      Copyto.clear();
                                    });
                                  }
                                },
                                  child: const Text('Add'),)

                              ],
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: Copytolist.length,
                              itemBuilder: (context, index) {
                                return ListTile(
                                  title: Text(Copytolist[index]),
                                  trailing: IconButton(
                                    icon: Icon(Icons.highlight_remove,size: 18,),
                                    onPressed: () {
                                      setState(() {
                                        // Remove the member from the list
                                        Copytolist.removeAt(index);
                                      });
                                    },
                                  ),
                                  // You can add more customization to the list tiles as needed
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                ],
              ),

              const SizedBox(
                height: 30,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  SizedBox(
                      width: 200,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.blue), // Set the color of the outline
                          foregroundColor: Colors.blue, // Set the color of the text
                        ),
                        onPressed: () async {
                          //  Gather data from text controllers and lists
                          String title = Meetingtitle.text;
                          String meeting_held=meetingheld.text;
                          String codeNo = Codeno.text;
                          if (title.isEmpty || codeNo.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Title and CodeNo cannot be empty'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                            return; // Stop execution if title or codeNo is empty
                          }
                          List<String>? memberList = addedMembersList.isNotEmpty ? List.from(addedMembersList) : null;
                          List<String>? inviteMemberList = InvitememberList.isNotEmpty ? List.from(InvitememberList) : null;
                          List<String>? copyto = Copytolist.isNotEmpty ? List.from(Copytolist) : null;
                          // Insert meeting data into the database
                          String? insertedMeetingID =  await DatabaseHelper.insertOrUpdateMeeting(
                            meetingID: widget.meeting?.meetingID,
                            meeting_held: meeting_held,
                            title: title,
                            codeNo: codeNo,
                            memberList: memberList,
                            inviteMemberList: inviteMemberList,
                            copyto: copyto,
                          );
                          if (insertedMeetingID != null) {

                            SnackBarHelper.showFailedInsertionSnackbar(context, AppString.Meeting_save_success);
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Failed to insert meeting'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                          // Clear text controllers and lists after saving
                          Meetingtitle.clear();
                          meetingheld.clear();
                          Codeno.clear();
                          Addmettingmenber.clear();
                          invitemeetingmember.clear();
                          Copyto.clear();
                          addedMembersList.clear();
                          InvitememberList.clear();
                          Copytolist.clear();
                          setState(() {

                          });

                        },
                        child: const Text('Save'),
                      )
                  ),
                  SizedBox(
                      width: 200,
                      child: OutlinedButton(
                          onPressed: () async {
                            // Gather data from text controllers and lists
                            String title = Meetingtitle.text;
                            String meeting_held=meetingheld.text;
                            String codeNo = Codeno.text;
                            if (title.isEmpty || codeNo.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Title and CodeNo cannot be empty'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                              return; // Stop execution if title or codeNo is empty
                            }
                            List<String>? memberList = addedMembersList.isNotEmpty ? List.from(addedMembersList) : null;
                            List<String>? inviteMemberList = InvitememberList.isNotEmpty ? List.from(InvitememberList) : null;
                            List<String>? copyto = Copytolist.isNotEmpty ? List.from(Copytolist) : null;

                            // Insert meeting data into the database
                            String? insertedMeetingID =  await DatabaseHelper.insertOrUpdateMeeting(
                              meetingID: widget.meeting?.meetingID,
                              title: title,
                              meeting_held: meeting_held,
                              codeNo: codeNo,
                              memberList: memberList,
                              inviteMemberList: inviteMemberList,
                              copyto: copyto,
                            );
                            if (insertedMeetingID != null) {
                              SnackBarHelper.showFailedInsertionSnackbar(context, AppString.Meeting_save_success);
                              Navigator.push(context, MaterialPageRoute(builder: (context)=>Voice_Transcreption_For_Audio(meeting_id: insertedMeetingID,)));
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Failed to insert meeting'),
                                  duration: Duration(seconds: 2),
                                ),
                              );

                            }
                            // Clear text controllers and lists after saving
                            Meetingtitle.clear();
                            meetingheld.clear();
                            Codeno.clear();
                            Addmettingmenber.clear();
                            invitemeetingmember.clear();
                            Copyto.clear();
                            addedMembersList.clear();
                            InvitememberList.clear();
                            Copytolist.clear();

                            setState(() {

                            });
                            // DatabaseHelper.getAllMeetingRecords();
                          },
                          style: OutlinedButton.styleFrom(
                            side: BorderSide(color: Colors.blue), // Set the color of the outline
                            foregroundColor: Colors.blue, // Set the color of the text
                          ),

                          child: const Text('Save And Process'))),

                ],
              ),
              const SizedBox(height: 100,)
            ],
          ),
        ),
      ),
    );
  }

}


