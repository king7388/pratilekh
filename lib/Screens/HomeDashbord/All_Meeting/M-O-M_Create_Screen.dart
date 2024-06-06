import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../DataBase_Backend/Helpers/Helper.dart';
import '../../../Utils/Contants.dart';
import '../../../Utils/UI_HELPER.dart';
import 'dart:io';
class Create_MOM_Screen extends StatefulWidget {
  var meetingtitle;
  var meetingID;
  var meetingmember;
  var copyto;
  var invitedmember;
  var meetingdate;
  var meetingcode;
  var paragragdata;
  var multispeakerdata;
  var recordfilename;
  var momdata;

  Create_MOM_Screen(
      {required this.copyto,
      required this.invitedmember,
      required this.meetingdate,
      required this.meetingID,
      required this.meetingmember,
      required this.meetingtitle,
      required this.meetingcode,
        required this.recordfilename,
        this.momdata,
      this.multispeakerdata,
      this.paragragdata});

  @override
  State<Create_MOM_Screen> createState() => _Create_MOM_ScreenState();
}

class _Create_MOM_ScreenState extends State<Create_MOM_Screen> {


  List<List<String>> agendaLists = [];
  List<List<String>> dscnLists = [];
  List<List<String>> respLists = [];
  List<List<String>> infoLists = [];
  List<int> Sno = [];


  Map<int, Map<String, List<String>>> allData = {};

  int _selectedIndex = 0; // Variable to track the selected index
  ScrollController _controller = ScrollController(); // Controller for ListView scrolling





  @override
  void initState() {
    Sno.add(1);
    // TODO: implement initState
    super.initState();
    if(widget.momdata!=null){
      convertdata(widget.momdata);
    }
  }

  String _convertToRoman(int number) {
    if (number < 1 || number > 3999) {
      return '';
    }

    // Define the symbols and their values
    const List<String> symbols = [
      'I',
      'IV',
      'V',
      'IX',
      'X',
      'XL',
      'L',
      'XC',
      'C',
      'CD',
      'D',
      'CM',
      'M'
    ];
    const List<int> values = [
      1,
      4,
      5,
      9,
      10,
      40,
      50,
      90,
      100,
      400,
      500,
      900,
      1000
    ];

    // Start with an empty string for the result
    String result = '';

    // Loop through the symbols and their values in reverse order
    for (int i = symbols.length - 1; i >= 0; i--) {
      // Repeat the symbol as many times as it fits into the number
      while (number >= values[i]) {
        result += symbols[i];
        number -= values[i];
      }
    }

    return result;
  }

  String? getDataForIndexAndCategory(int index, String category) {
    if (allData.containsKey(index) && allData[index]!.containsKey(category)) {
      List<String>? dataList = allData[index]![category];
      if (dataList != null && dataList.isNotEmpty) {
        // Convert the index to a Roman numeral
        String romanIndex = _convertToRoman(index + 1);
        // Format the data with the Roman numeral index
        String formattedData = dataList.asMap().entries.map((entry) {
          final romanIndex = _convertToRoman(entry.key + 1);
          return '( $romanIndex ) :  ${entry.value}';
        }).join('\n');
        return formattedData;
      }
    }
    // If data is not found for the index and category, return null
    return null;
  }

  void _addDataInAgenda(String text) {
    setState(() {
      if (!allData.containsKey(_selectedIndex)) {
        allData[_selectedIndex] = {};
      }
      if (!allData[_selectedIndex]!.containsKey('Agenda')) {
        allData[_selectedIndex]?['Agenda'] = [];
      }
      allData[_selectedIndex]?['Agenda']?.add(text);
    });
  }

  void _addDataInDscn(String text) {
    setState(() {
      if (!allData.containsKey(_selectedIndex)) {
        allData[_selectedIndex] = {};
      }
      if (!allData[_selectedIndex]!.containsKey('Discussion')) {
        allData[_selectedIndex]?['Discussion'] = [];
      }
      allData[_selectedIndex]?['Discussion']?.add(text);
    });
  }

  void _addDataInResp(String text) {
    setState(() {
      if (!allData.containsKey(_selectedIndex)) {
        allData[_selectedIndex] = {};
      }
      if (!allData[_selectedIndex]!.containsKey('Responsibility')) {
        allData[_selectedIndex]?['Responsibility'] = [];
      }
      allData[_selectedIndex]?['Responsibility']?.add(text);
    });
  }

  void _addDataInInfo(String text) {
    setState(() {
      if (!allData.containsKey(_selectedIndex)) {
        allData[_selectedIndex] = {};
      }
      if (!allData[_selectedIndex]!.containsKey('Info')) {
        allData[_selectedIndex]?['Info'] = [];
      }
      allData[_selectedIndex]?['Info']?.add(text);
    });
  }

 void convertdata(String momdata){

       if (momdata != null) {
         // Decode the retrieved JSON string
         Map<String, dynamic> decodedData = jsonDecode(momdata);

         // Convert the keys to integers
         Map<int, Map<String, List<String>>> allData = {};
         decodedData.forEach((key, value) {
           Map<String, List<String>> innerMap = {};
           value.forEach((innerKey, innerValue) {
             innerMap[innerKey] = List<String>.from(innerValue);
           });
           allData[int.parse(key)] = innerMap;
         });

         // Set the state with the converted data
         setState(() {
           this.allData = allData;
           Sno = List<int>.generate(allData.length, (index) => index + 1);
         });

       } else {

       }
 }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 208.0, vertical: 50),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Meeting Details:',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                        fontFamily: "Montserrat-Regular",
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: RichText(
                      text: TextSpan(
                        style: DefaultTextStyle.of(context).style,
                        children: <TextSpan>[
                          TextSpan(
                            text: 'Meeting Title  :  ',
                            style: myBoldBlueStyle,
                          ),
                          TextSpan(
                              text: widget.meetingtitle,
                              style: myBoldblackStyle),
                        ],
                      ),
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,

                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: RichText(
                          text: TextSpan(
                            style: DefaultTextStyle.of(context).style,
                            children: <TextSpan>[
                              TextSpan(
                                text: 'Meeting Code No  : ',
                                style: myBoldBlueStyle,
                              ),
                              TextSpan(
                                  text: widget.meetingcode,
                                  style: myBoldblackStyle),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: RichText(
                          text: TextSpan(
                            style: DefaultTextStyle.of(context).style,
                            children: <TextSpan>[
                              TextSpan(
                                text: 'Meeting Date  :- ',
                                style: myBoldBlueStyle,
                              ),
                              TextSpan(
                                  text: widget.meetingdate,
                                  style: myBoldblackStyle),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: RichText(
                          text: TextSpan(
                            style: DefaultTextStyle.of(context).style,
                            children: <TextSpan>[
                              TextSpan(
                                text: 'Meeting Member List :- ',
                                style: myBoldBlueStyle,
                              ),
                              ..._buildMemberList(widget.meetingmember),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: RichText(
                          text: TextSpan(
                            style: DefaultTextStyle.of(context).style,
                            children: <TextSpan>[
                              TextSpan(
                                text: 'Invited Member List :- ',
                                style: myBoldBlueStyle,
                              ),
                              ..._buildMemberList(widget.invitedmember),
                            ],
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: RichText(
                          text: TextSpan(
                            style: DefaultTextStyle.of(context).style,
                            children: <TextSpan>[
                              TextSpan(
                                text: 'Copy to  :- ',
                                style: myBoldBlueStyle,
                              ),
                              ..._buildMemberList(widget.copyto),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0,vertical: 10),
              child: Align(
                alignment: Alignment.centerRight,
                child:
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 48.0),
                      child: InkWell(
                        onTap:
                            ()
                        async {
                          String currentDate =
                          DateFormat('dd-MM-yyyy HH:mm:ss').format(DateTime.now());
                          Map<String, Map<String, dynamic>> _convertKeysToString(Map<int, Map<String, dynamic>> originalMap) {
                            Map<String, Map<String, dynamic>> newMap = {};
                            originalMap.forEach((key, value) {
                              newMap[key.toString()] = value;
                            });
                            return newMap;
                          }

                          var jsonData = jsonEncode(_convertKeysToString(allData));

                          bool success = await DatabaseHelper.insertMeetingRecord(
                              widget.meetingID,
                              widget.recordfilename,
                              false,
                              true,
                              false,
                              null,
                              null,
                              null,
                              jsonData,
                              currentDate);


                          if (success) {
                            SnackBarHelper.showFailedInsertionSnackbar(context, 'M-O-M created successfully . Now you can download M-O-M');
                            Navigator.pop(context);
                            // Insertion or update was successful
                          } else {
                            SnackBarHelper.showFailedInsertionSnackbar(context, 'Something went wrong ....');
                            // Insertion or update failed
                          }
                          //DatabaseHelper.insertMOM_Data(jsonData,widget.meetingID,widget.recordfilename);
                        },
                        child: Container(
                            width: 170,
                            height: 35,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                  color: Colors
                                      .grey), // Add border color
                              borderRadius: BorderRadius.circular(
                                  5.0), // Add border radius
                            ),
                            child: const Center(child: Text('Save   M-O-M',style: TextStyle(fontWeight: FontWeight.bold),))

                        ),
                      ),
                    ),
                    Container(
                      width: 170,
                      height: 35,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        border: Border.all(
                            color: Colors
                                .grey), // Add border color
                        borderRadius: BorderRadius.circular(
                            5.0), // Add border radius
                      ),
                      child: DropdownButton<int>(
                        underline: Container(),
                        value: _selectedIndex,
                        items: List.generate(
                          Sno.length,
                              (index) =>
                              DropdownMenuItem<int>(
                                value: index,
                                child: Text('      S. No.  ${Sno[index]}'),
                              ),
                        ),
                        onChanged: (int? newIndex) {
                          setState(() {
                            _selectedIndex = newIndex!;
                            _controller.animateTo(
                              _selectedIndex * 400.0, // Adjust 100.0 as needed based on item height
                              duration: Duration(milliseconds: 500),
                              curve: Curves.easeInOut,
                            );
                          });
                        },
                      ),
                    ),
                    SizedBox(width: 50,),
                    InkWell(
                      onTap:
                        ()
                        {
                          setState(() {
                            // Increment values in Sno list
                            Sno.add(Sno.length + 1);
                          });
                        },
                      child: Container(
                        width: 170,
                        height: 35,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                              color: Colors
                                  .grey), // Add border color
                          borderRadius: BorderRadius.circular(
                              5.0), // Add border radius
                        ),
                        child: Center(child: Text('Add New Table',style: TextStyle(fontWeight: FontWeight.bold),))

                      ),
                    ),
                  ],
                )
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(18.0),
              child: Row(
                children: [
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.4,
                    child: Container(
                        height: 600,
                        decoration: containerDecorationgrayoutline,
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              for (var message
                                  in widget.multispeakerdata['messages'])
                                Row(
                                  children: [
                                    Expanded(
                                      child: ListTile(
                                        title: Text(
                                            '${message['speaker']} (${message['time']})'),
                                        subtitle: Text(message['text']),
                                      ),
                                    ),
                                    Container(
                                      width: 170,
                                      height: 35,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        border: Border.all(
                                            color: Colors
                                                .grey), // Add border color
                                        borderRadius: BorderRadius.circular(
                                            5.0), // Add border radius
                                      ),
                                      child: DropdownButton<String>(
                                        icon: Container(), // Set the default icon
                                        hint: const Row(
                                          children: [
                                            Text('   Add  Data'),
                                            SizedBox(
                                              width: 30,
                                            ),
                                            Icon(Icons.arrow_drop_down_outlined)
                                          ],
                                        ),
                                        underline: Container(),
                                        onChanged: (value) {
                                          // Implement the logic when dropdown value changes
                                          if (value == 'Agenda Pt') {
                                            _addDataInAgenda(message['text']);
                                          } else if (value == 'Dscn') {
                                            _addDataInDscn(message['text']);
                                          } else if (value == 'Resp') {
                                            _addDataInResp(message['text']);
                                          } else if (value == 'Info') {
                                            _addDataInInfo(message['text']);
                                          }
                                          setState(() {

                                          });
                                        },
                                        items: const [
                                          DropdownMenuItem(
                                            value: 'Agenda Pt',
                                            child: Text(' Agenda Pt'),
                                          ),
                                          DropdownMenuItem(
                                            value: 'Dscn',
                                            child: Text('Dscn'),
                                          ),
                                          DropdownMenuItem(
                                            value: 'Resp',
                                            child: Text('Resp'),
                                          ),
                                          DropdownMenuItem(
                                            value: 'Info',
                                            child: Text('Info'),
                                          ),
                                        ],
                                      ),

                                    ),
                                    const SizedBox(
                                      width: 5,
                                    )
                                  ],
                                ),
                            ],
                          ),
                        )),
                  ),
                  const SizedBox(
                    width: 50,
                  ),
                  Expanded(
                    child: Container(
                      height: 620,
                      child: ListView.builder(
                        controller: _controller,
                          shrinkWrap: true,
                          itemCount: Sno.length,
                          itemBuilder: (context, index) {


                            return  Padding(
                              padding: const EdgeInsets.only(top: 8.0),
                              child: Container(
                                height: 400,
                                decoration: containerDecorationgrayoutline,
                                child: Column(
                                  children: [
                                    const Padding(
                                      padding:
                                      EdgeInsets.only(left: 18.0, top: 18),
                                      child: Row(
                                        children: [
                                          SizedBox(
                                            width: 40,
                                            child: Column(
                                              children: [
                                                Text('S.No.'),
                                                Divider(),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            width: 350,
                                            child: Column(
                                              children: [
                                                Text('Agenda Pt'),
                                                Divider(),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            width: 300,
                                            child: Column(
                                              children: [
                                                Text('Dscn / Decision'),
                                                Divider(),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            width: 230,
                                            child: Column(
                                              children: [
                                                Text('Resp'),
                                                Divider(),
                                              ],
                                            ),
                                          ),
                                          SizedBox(
                                            width: 120,
                                            child: Column(
                                              children: [
                                                Text('Info'),
                                                Divider(),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding:
                                      EdgeInsets.symmetric(horizontal: 18.0),
                                      child: Row(
                                        crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                        children: [
                                          Text((index + 1 ).toString()),
                                          SizedBox(
                                            width: 30,
                                          ),
                                          Container(
                                            height: 340,
                                            color: Colors.black,
                                            width: 1,
                                          ),
                                          Container(
                                            width: 350, // Set a fixed width for the container
                                            height: 340,
                                            child: SingleChildScrollView(
                                              child: SizedBox(
                                                width: 350,
                                                child: TextFormField(
                                                  controller: TextEditingController(text: getDataForIndexAndCategory(index, 'Agenda')),
                                                  maxLines: null, // Set to null for unlimited lines, or any desired number
                                                  keyboardType: TextInputType.multiline,
                                                  textInputAction: TextInputAction.newline,
                                                  decoration: const InputDecoration(
                                                    border: InputBorder.none, // Remove underline
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),

                                          Container(
                                            height: 340,
                                            color: Colors.black,
                                            width: 1,
                                          ),
                                          Container(
                                            width: 300,
                                            height: 340,
                                            child: SingleChildScrollView(
                                              child: SizedBox(
                                                width: 300,
                                                child: TextField(
                                                  controller: TextEditingController(text: getDataForIndexAndCategory(index, 'Discussion')),
                                                  maxLines:
                                                  null, // Set to null for unlimited lines, or any desired number
                                                  keyboardType:
                                                  TextInputType.multiline,
                                                  textInputAction:
                                                  TextInputAction.newline,
                                                  decoration: InputDecoration(
                                                    border: InputBorder
                                                        .none, // Remove underline
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            height: 340,
                                            color: Colors.black,
                                            width: 1,
                                          ),
                                          Container(
                                            width: 215,
                                            height: 340,
                                            child: SingleChildScrollView (
                                              child: SizedBox(
                                                width: 215,
                                                child: TextField(
                                                  controller: TextEditingController(text: getDataForIndexAndCategory(index, 'Responsibility')),
                                                  maxLines:
                                                  null, // Set to null for unlimited lines, or any desired number
                                                  keyboardType:
                                                  TextInputType.multiline,
                                                  textInputAction:
                                                  TextInputAction.newline,
                                                  decoration: InputDecoration(
                                                    border: InputBorder
                                                        .none, // Remove underline
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            height: 340,
                                            color: Colors.black,
                                            width: 1,
                                          ),
                                          Container(
                                            width: 100,
                                            height: 340,
                                            child: SingleChildScrollView(
                                              child: SizedBox(
                                                width: 100,
                                                child: TextField(
                                                  controller: TextEditingController(text: getDataForIndexAndCategory(index, 'Info')),
                                                  maxLines:
                                                  null, // Set to null for unlimited lines, or any desired number
                                                  keyboardType:
                                                  TextInputType.multiline,
                                                  textInputAction:
                                                  TextInputAction.newline,
                                                  decoration:
                                                  const InputDecoration(
                                                    border: InputBorder
                                                        .none, // Remove underline
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),

                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 100,
            )
          ],
        ),
      ),
    );
  }

  List<TextSpan> _buildMemberList(String? members) {
    if (members == null) {
      return [
        TextSpan(text: '\nNo data', style: TextStyle(color: Colors.grey))
      ];
    }

    try {
      List<dynamic> decodedList = jsonDecode(members);
      List<String> memberList = decodedList.cast<String>();
      List<TextSpan> memberSpans = [];

      for (String member in memberList) {
        memberSpans.add(
          TextSpan(
              text: '\n\u2022 $member', // Bullet point for each member
              style: myBoldblackStyle),
        );
      }
      return memberSpans;
    } catch (e) {

      return []; // Return empty list if there's an error decoding the JSON string
    }
  }
}
