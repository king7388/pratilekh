import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import '../../../DataBase_Backend/Helpers/Helper.dart';
import '../../../DataBase_Backend/Models/MeetingsModel.dart';
import '../../../Record_Directory/audio_player.dart';
import '../../../Record_Directory/audio_recorder.dart';
import '../../../Utils/UI_HELPER.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../Utils/Utils.dart';

/// Large Screen
class Voice_Transcreption_For_Audio extends StatefulWidget {
  var meeting_id;
  Voice_Transcreption_For_Audio({Key? key, required this.meeting_id})
      : super(key: key);

  @override
  State<Voice_Transcreption_For_Audio> createState() =>
      _Voice_Transcreption_For_AudioState();
}

class _Voice_Transcreption_For_AudioState
    extends State<Voice_Transcreption_For_Audio> {
  bool isChecked1 = false;
  bool isChecked2 = false;
  bool isChecked3 = false;
  bool isChecked4 = false;
  bool isChecked5 = false;
  bool webshocket = false;
  Map<String, dynamic>? Data;
  String? data;
  bool showPlayer = false;
  File? audioPath;
  Map<String, dynamic> jsonData = {};
  ScrollController _controller = ScrollController();
  Future<void> pickAudio() async {
    audioPath = null;
    showPlayer = false;
    setState(() {

    });
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: [
        'mp3',
        'wav',
        'aac',
        'flac',
        'ogg',
        'm4a',
        'opus'
      ], // Add more audio file formats if needed
    );

    if (result != null) {
      setState(() {
        audioPath = File(result.files.single.path!);
        print(audioPath);
        setState(() {

        });
        showPlayer = true;
      });
    } else {
      // User canceled the picker
    }
  }

  void sendAudioSingle() async {
    String currentDate =
        DateFormat('dd-MM-yyyy HH:mm:ss').format(DateTime.now());

    webshocket = false;
    setState(() {});
    // Get the path of the audio file if it is not null
    if (audioPath != null) {
      String audioFilePath = audioPath!.path;

      // Create a multipart request
      var request = http.MultipartRequest(
          'POST', Uri.parse('http://127.0.0.1:5000/process_audio'));

      // Add the audio file to the request
      request.files
          .add(await http.MultipartFile.fromPath('audio', audioFilePath));

      // Add check button states to the request as form fields
      request.fields['single_speaker'] = isChecked1
          .toString(); // Replace 'true' with the actual state of button 1
      // request.fields['multiple_speaker'] = isChecked2.toString(); // Replace 'false' with the actual state of button 2

      // Send the request
      try {
        Utils.isloading = true;
        UI_Componenet.scrollToBottom(_controller);
        setState(() {});
        var streamedResponse = await request.send();

        // Read response from stream
        var response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode == 200) {
          // Parse the JSON response
          var jsonData = json.decode(response.body);

          Data = jsonData;

          Utils.isloading = false;
          setState(() {});
          // Handle the response data as needed
          List<String> data = [];
          if (jsonData['result'] != null) {
            data.add(jsonData['result']);
          }
          DatabaseHelper.insertMeetingRecord(
              widget.meeting_id,
              audioFilePath,
              isChecked1,
              isChecked2,
              isChecked3,
              data.toString(),
              null,
              null,
              null,
              currentDate);
          // Generate a unique filename
          final folderName = 'Pratilekh_TXT_Files';
          final downloadsDirectory = await getDownloadsDirectory();
          final folderPath =
              '${downloadsDirectory?.path}\\Pratilekh\\$folderName';

          String filename =
              '_audio_${DateTime.now().millisecondsSinceEpoch.toString()}.txt';
          // Create the directory if it doesn't exist
          Directory(folderPath).createSync(recursive: true);

          // Write the response body to a file
          File file = File('$folderPath\\$filename');
          await file.writeAsString(data.join('\n'));
          print(file.path);
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('File Downloaded'),
                content: Text('File downloaded to: ${file.path}'),
                actions: <Widget>[
                  ElevatedButton(
                    onPressed: () async {
                      await Process.run('cmd', ['/c', 'start', file.path]);
                    },
                    child: Text('Open'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        } else {
          Utils.isloading = false;
          setState(() {});

          return UI_Componenet.showError(
              context, '${response.body.toString()}');
        }
      } catch (e) {
        Utils.isloading = false;
        setState(() {});
        return UI_Componenet.showError(context, '${e.toString()}');
      }
    } else {
      return UI_Componenet.showAudio(
          context, 'Please select Audio File to proceed');
    }
  }

  void SendAudioMultple() async {
    String currentDate =
        DateFormat('dd-MM-yyyy HH:mm:ss').format(DateTime.now());
    webshocket = false;
    setState(() {});
    // Get the path of the audio file if it is not null
    if (audioPath != null) {
      String audioFilePath = audioPath!.path;

      final newDirectory = Directory('${pratlekhpath}\\Voice_Sample');
      if (!await newDirectory.exists()) {
        await newDirectory.create(recursive: true);
      }
      // Create a multipart request
      var request = http.MultipartRequest(
          'POST', Uri.parse('http://127.0.0.1:5000/process_audio_speaker'));
      // Add the audio file to the request
      request.files
          .add(await http.MultipartFile.fromPath('audio', audioFilePath));

      // Add check button states to the request as form fields
      //request.fields['single_speaker'] = isChecked1.toString(); // Replace 'true' with the actual state of button 1
      request.fields['multiple_speaker'] = isChecked2
          .toString(); // Replace 'false' with the actual state of button 2
      request.fields['audio_segment_dir'] = newDirectory
          .path; // Replace 'false' with the actual state of button 2
      request.fields['all_folder_names'] = Allmembername!;
      // Send the request
      try {
        Utils.isloading = true;
        UI_Componenet.scrollToBottom(_controller);
        setState(() {});
        var streamedResponse = await request.send();

        // Read response from stream
        var response = await http.Response.fromStream(streamedResponse);
        if (response.statusCode == 200) {
          Utils.isloading = false;

          // Parse the JSON response
          jsonData = json.decode(response.body);
          var databasedata;

          setState(() {
            Data = jsonData;
            databasedata = json.encode(Data);
          });

          DatabaseHelper.insertMeetingRecord(
              widget.meeting_id,
              audioFilePath,
              isChecked1,
              isChecked2,
              isChecked3,
              null,
              databasedata.toString(),
              null,
              null,
              currentDate);
          setState(() {});
        } else {
          Utils.isloading = false;
          setState(() {});
          return UI_Componenet.showError(
              context, '${response.body.toString()}');
        }
      } catch (e) {
        Utils.isloading = false;
        setState(() {});
        return UI_Componenet.showError(context, "${e.toString()}");
      }
    } else {
      return UI_Componenet.showAudio(
          context, 'Please select Audio File to proceed');
    }
  }

  final List<String> messages = [];

  bool isWebSocketConnected = false;

  List<dynamic>? worldfiledata;

  Future<void> _saveMessages(Map<String, dynamic> jsonData) async {
    final folderName = 'Pratilekh_TXT_Files';
    final downloadsDirectory = await getDownloadsDirectory();
    final folderPath = '${downloadsDirectory?.path}\\Pratilekh\\$folderName';

    Directory directory = Directory(folderPath);
    if (await directory.exists()) {
    } else {
      // If directory doesn't exist, create it
      directory.create(recursive: true).then((Directory directory) {});
    }
    String speakersFolderPath =
        '$folderPath\\speakers${DateTime.now().millisecondsSinceEpoch.toString()}';
    Map<String, List<String>> speakerMessages = {};

    if (jsonData['messages'] != null) {
      List<dynamic> messages = jsonData['messages'];

      for (var message in messages) {
        if (message['speaker'] != null &&
            message['text'] != null &&
            message['time'] != null) {
          String speaker = message['speaker'];
          String text = message['text'];

          // Create separate list for each speaker
          if (!speakerMessages.containsKey(speaker)) {
            speakerMessages[speaker] = [];
          }
          speakerMessages[speaker]!.add(
              '${message['speaker']} (${message['time']}): ${message['text']}');
        }
      }

      if (isChecked3 == true) {
        // Save each speaker's messages to a separate file
        for (String speaker in speakerMessages.keys) {
          // Create directory for each speaker
          String speakerFolderPath = '$speakersFolderPath\\$speaker';
          Directory(speakerFolderPath).createSync(recursive: true);

          // Create a file for speaker's messages
          File file = File('$speakerFolderPath\\messages.txt');
          await file.writeAsString(speakerMessages[speaker]!.join('\n'));
        }
      } else if (isChecked3 == false) {
        List<String> data = [];
        // Handle the response data as needed
        if (jsonData['messages'] != null) {
          List<dynamic> messages = jsonData['messages'];
          for (var message in messages) {
            if (message['speaker'] != null &&
                message['text'] != null &&
                message['time'] != null) {
              String messageData =
                  '${message['speaker']} (${message['time']}): ${message['text']}';
              data.add(messageData);
            } else {
              // Handle the case where any of the fields are null
              // For example, you can skip adding such messages or add a placeholder
            }
          }
        }

        String filename =
            'audio_${DateTime.now().millisecondsSinceEpoch.toString()}.txt';
        String speakerFolderPath = '$speakersFolderPath';
        Directory(speakerFolderPath).createSync(recursive: true);

        // Write the response body to a file
        File file = File('$speakerFolderPath\\$filename');
        await file.writeAsString(data.join('\n'));
      }
    }

    // Show a pop-up displaying the downloaded file's path
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Files Downloaded'),
          content: Text('Files downloaded to: $speakersFolderPath'),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () async {
                // Open folder in file explorer
                await Process.run('explorer.exe', [speakersFolderPath]);
              },
              child: Text('Open'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleResponseDataAndSaveAsPdf(
      Map<String, dynamic> jsonData) async {
    // Extract messages from JSON data
    List<dynamic> messages = jsonData['messages'];
    if (isChecked3 == false) {
      List<String> allMessages = [];

      // Combine all messages into a single list
      for (var message in messages) {
        if (message['speaker'] != null &&
            message['text'] != null &&
            message['time'] != null) {
          String messageText =
              '${message['speaker']} (${message['time']}): ${message['text']}';
          allMessages.add(messageText);
        }
      }

      // Generate a unique folder name based on the current timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final folderName = 'Pratilekh_PDF_Files';
      final downloadsDirectory = await getDownloadsDirectory();
      final folderPath = '${downloadsDirectory?.path}\\Pratilekh\\$folderName';

      Directory directory = Directory(folderPath);
      if (await directory.exists()) {
      } else {
        // If directory doesn't exist, create it
        directory.create(recursive: true).then((Directory directory) {});
      }
      // Create a directory for saving the PDF files
      final folder = Directory(folderPath);
      await folder.create();

      // Save all messages in a single PDF file
      final pdf = pw.Document();

      // Add pages to the PDF for all messages
      for (int i = 0; i < allMessages.length; i += 40) {
        final pageMessages = allMessages.sublist(
            i, i + 40 < allMessages.length ? i + 40 : allMessages.length);
        pdf.addPage(
          pw.Page(
            build: (pw.Context context) {
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Text(pageMessages.join('\n')),
                  ),
                ],
              );
            },
          ),
        );
      }

      // Generate a unique filename for the PDF file
      final pdfFilename = 'all_messages$timestamp.pdf';
      final pdfFilePath = '$folderPath\\$pdfFilename';

      // Save the PDF to a file
      final pdfFile = File(pdfFilePath);
      await pdfFile.writeAsBytes(await pdf.save());

      // Show a pop-up displaying the folder's path
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('PDFs Saved'),
            content: Text('PDFs saved to: $folderPath'),
            actions: <Widget>[
              ElevatedButton(
                onPressed: () async {
                  // Open folder in file explorer
                  await Process.run('explorer.exe', [folderPath]);
                },
                child: Text('Open '),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    } else if (isChecked3 == true) {
      Map<String, List<String>> speakerMessages = {};

      // Generate a unique folder name based on the current timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final folderName = 'Pratilekh_PDF_Files';
      final downloadsDirectory = await getDownloadsDirectory();
      final folderPath =
          '${downloadsDirectory?.path}\\Pratilekh\\$folderName\\Speaker_wise_Data_$timestamp';

      Directory directory = Directory(folderPath);
      if (await directory.exists()) {
      } else {
        // If directory doesn't exist, create it
        directory.create(recursive: true).then((Directory directory) {});
      }
      // Create a directory for saving the PDF files
      final folder = Directory(folderPath);
      await folder.create();

      await folder.create();
      // Iterate through each message
      for (var message in messages) {
        if (message['speaker'] != null &&
            message['text'] != null &&
            message['time'] != null) {
          String speaker = message['speaker'];
          String text = message['text'];

          // Create separate list for each speaker
          if (!speakerMessages.containsKey(speaker)) {
            speakerMessages[speaker] = [];
          }
          speakerMessages[speaker]!.add(
              '${message['speaker']} (${message['time']}): ${message['text']}');
        }
      }

      // Save messages in PDF files
      for (var entry in speakerMessages.entries) {
        final speaker = entry.key;
        final messages = entry.value;

        final pdf = pw.Document();

        // Add pages to the PDF for each speaker's messages
        for (int i = 0; i < messages.length; i += 20) {
          final pageMessages = messages.sublist(
              i, i + 20 < messages.length ? i + 20 : messages.length);
          pdf.addPage(
            pw.Page(
              build: (pw.Context context) {
                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(speaker,
                        style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(
                        height:
                            5), // Add space between speaker name and messages
                    pw.Expanded(
                      child: pw.Text(pageMessages.join('\n')),
                    ),
                  ],
                );
              },
            ),
          );
        }

        // Generate a unique filename for the PDF file
        final pdfFilename = '$speaker.pdf';
        final pdfFilePath = '$folderPath/$pdfFilename';

        // Save the PDF to a file
        final pdfFile = File(pdfFilePath);
        await pdfFile.writeAsBytes(await pdf.save());
      }
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('PDFs Saved'),
            content: Text('PDFs saved to: $folderPath'),
            actions: <Widget>[
              ElevatedButton(
                onPressed: () async {
                  // Open folder in file explorer
                  await Process.run('explorer.exe', [folderPath]);
                },
                child: Text('Open '),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  List<Widget> _buildSpeakerTextFields(Map<String, dynamic>? Data) {
    List<Widget> textFields = [];
    Map<String, TextEditingController> textEditingControllers = {};
    Set<String> uniqueSpeakers = {};

    if (Data != null && Data['messages'] != null) {
      List<dynamic> messages = Data['messages'];
      worldfiledata = Data['messages'];
      for (var message in messages) {
        if (message['speaker'] != null) {
          String speaker = message['speaker'];
          // Check if the speaker has been encountered before
          if (!uniqueSpeakers.contains(speaker)) {
            uniqueSpeakers.add(speaker);

            // Create a TextEditingController for the speaker if it doesn't exist
            if (!textEditingControllers.containsKey(speaker)) {
              textEditingControllers[speaker] =
                  TextEditingController(text: speaker);
            }

            // Add speaker details to the list of text fields
            textFields.add(
              Row(
                children: [
                  SizedBox(
                    width: 200,
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        'Speaker: $speaker',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Spacer(),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.3,
                    height: MediaQuery.of(context).size.height * 0.06,
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        style: const TextStyle(
                          // Customize the text style for the entered text
                          color: Colors.black, // Change color to black
                          fontSize: 12, // Change font size to 16
                          // fontWeight: FontWeight.bold, // Make it bold
                        ),
                        controller: textEditingControllers[speaker],
                        decoration: const InputDecoration(
                          hintText: 'Enter speaker name',
                          border: OutlineInputBorder(),
                        ),
                        onChanged: (value) {
                          // Handle onChanged event if needed
                        },
                      ),
                    ),
                  ),
                  Spacer(),
                ],
              ),
            );
          }
        }
      }

      // Add save button to the list of text fields
      textFields.add(
        Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton(
              onPressed: () {
                String currentDate =
                    DateFormat('dd-MM-yyyy HH:mm:ss').format(DateTime.now());
                // Save changes made to speaker names
                Data['messages'].forEach((message) {
                  String oldSpeaker = message['speaker'];
                  String newSpeaker =
                      textEditingControllers[oldSpeaker]?.text ?? oldSpeaker;
                  message['speaker'] = newSpeaker;
                });
                // Convert the modified Data to JSON
                worldfiledata = Data['messages'];
                var dbdata;
                setState(() {
                  dbdata = json.encode(Data);
                });
                DatabaseHelper.insertMeetingRecord(
                    widget.meeting_id,
                    audioPath!.path,
                    isChecked1,
                    isChecked2,
                    isChecked3,
                    null,
                    dbdata.toString(),
                    null,
                    null,
                    currentDate);
                // Call setState to update the UI
                setState(() {});
              },
              child: Text('Save Speaker Names'),
            ),
          ),
        ),
      );
    }

    // Wrap all speaker details in a single container
    return [
      Container(
        width: MediaQuery.of(context).size.width * 0.5,
        margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20),
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.5),
              spreadRadius: 5,
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: textFields,
        ),
      ),
    ];
  }

  Future<void> sendDatatoSaveInWorldFile() async {
    try {
      //List<dynamic> messages = Data?['messages'];
      // Create the JSON object to hold the data
      Map<String, dynamic> jsonData = {
        "messages": worldfiledata,
        "separate_speaker_files": isChecked3
      };

      var response = await http.post(
        Uri.parse('http://localhost:5000/append_to_word'),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(jsonData), // Convert data to JSON format
      );

      if (response.statusCode == 200) {
        var responseBody = json.decode(response.body);

        if (responseBody['message'] == true) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: Text('Word File  Saved'),
                content:
                    Text('Word File  saved to: ${responseBody['file_path']}'),
                actions: <Widget>[
                  ElevatedButton(
                    onPressed: () async {
                      // Open folder in file explorer
                      await Process.run(
                          'explorer.exe', [responseBody['file_path']]);
                    },
                    child: Text('Open '),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Something went wrong.....'),
                // content: Text('PDFs saved to: ${responseBody['file_path']}'),
                actions: <Widget>[
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('OK'),
                  ),
                ],
              );
            },
          );
        }
      } else {}
    } catch (e) {}
  }

  String? Allmembername;
  String? pratlekhpath;
  Future<Directory?> getDirectory(String directoryPath) async {
    final Directory dir = Directory(directoryPath);

    if (await dir.exists()) {
      //  print('Directory exists: ${dir.path}');
      setState(() {
        pratlekhpath = dir.path;
      });
      return dir;
    } else {
      //print('Directory does not exist');
      return null;
    }
  }
  @override
  void initState() {
    getDirectory('C:\\Pratilekh');
    Utils.isloading = false;
    // TODO: implement initState

    super.initState();

    fetchMeetingData(widget.meeting_id);
  }

  void fetchMeetingData(String meetingID) async {
    List<Map<String, dynamic>> meetingData =
        await DatabaseHelper.getMeetingDataById(widget.meeting_id);

    if (meetingData.isNotEmpty) {
      String memberListJson = meetingData[0]['memberList'];
      String inviteMemberListJson = meetingData[0]['inviteMemberList'];

      // Handle your memberListJson and inviteMemberListJson data here
      List<dynamic> memberList = json.decode(memberListJson);
      List<dynamic> inviteMemberList = json.decode(inviteMemberListJson);

      List<dynamic> combinedList = [...memberList, ...inviteMemberList];

      // Encode combined list back to JSON string
      Allmembername = json.encode(combinedList);
      print(Allmembername);
      print(Allmembername.runtimeType);
      // Use memberList and inviteMemberList as needed
      print('Member List: $memberList');
      print('Invite Member List: $inviteMemberList');
    } else {
      print('Meeting with ID $meetingID not found');
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
          icon: Icon(
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
      body: Padding(
        padding: const EdgeInsets.only(left: 50.0, right: 50),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Text(
                      'Input Source ',
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Montserrat-Regular"),
                    ),
                    Text(
                      'Select option to process ',
                      style: TextStyle(
                          fontSize: 20,
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Montserrat-Regular"),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 18.0, right: 18),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Expanded(
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.35,
                        decoration: BoxDecoration(
                          color:
                              Colors.white, // Background color of the container
                          borderRadius: BorderRadius.circular(
                              10), // Optional: Add border radius to the container
                          boxShadow: [
                            BoxShadow(
                              color:
                                  Colors.grey.withOpacity(0.5), // Shadow color
                              spreadRadius: 5, // Spread radius
                              blurRadius: 10, // Blur radius
                              offset:
                                  const Offset(0, 2), // Offset in the y-axis
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(top: 68.0),
                          child: Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (audioPath != null)
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.27,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        gradient: const LinearGradient(
                                            colors: [Colors.grey, Colors.grey],
                                            begin: Alignment.bottomRight,
                                            end: Alignment.topLeft),
                                      ),
                                      child: Center(
                                        child: Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text(
                                            audioPath!
                                                .toString(), // Show the path of the audio file
                                            style: const TextStyle(
                                                fontSize: 12,
                                                color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    )
                                  else
                                    Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.25,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        gradient: const LinearGradient(
                                            colors: [Colors.grey, Colors.grey],
                                            begin: Alignment.bottomRight,
                                            end: Alignment.topLeft),
                                      ),
                                      child: const Center(
                                        child: Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text(
                                            "Please select Audio",
                                            style: TextStyle(
                                                fontSize: 14,
                                                color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ),
                                  SizedBox(width: 10),
                                  InkWell(
                                    onTap: pickAudio,
                                    child: Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.1,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        gradient: const LinearGradient(
                                            colors: [Colors.blue, Colors.blue],
                                            begin: Alignment.bottomRight,
                                            end: Alignment.topLeft),
                                      ),
                                      child: const Center(
                                        child: Padding(
                                          padding: EdgeInsets.all(8.0),
                                          child: Text(
                                            "Browse",
                                            style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.white),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 32,
                              ),
                              const Padding(
                                padding: EdgeInsets.only(left: 58.0, right: 58),
                                child: Divider(),
                              ),
                              const Text(
                                "You can also proceed by voice record",
                                style: TextStyle(
                                    fontSize: 20,
                                    color: Color(0xFF8591B0),
                                    fontWeight: FontWeight.bold,
                                    fontFamily: "Montserrat-Regular"),
                              ),
                              Visibility(
                                visible: showPlayer,
                                child: const SizedBox(
                                  height: 32,
                                ),
                              ),
                              Align(
                                alignment: Alignment.center,
                                child: SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.1,
                                  width:
                                      MediaQuery.of(context).size.width * 0.36,
                                  child: Center(
                                    child: showPlayer
                                        ? Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 25),
                                            child: AudioPlayer(
                                              source: audioPath!.path,
                                              onDelete: () {
                                                setState(
                                                    () => showPlayer = false);
                                              },
                                            ),
                                          )
                                        : Recorder(
                                            onStop: (path) {
                                              setState(() {
                                                audioPath = File(path);
                                                showPlayer = true;
                                              });
                                            },
                                          ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 20,
                    ),
                    Expanded(
                      child: Container(
                        height: MediaQuery.of(context).size.height * 0.35,
                        decoration: BoxDecoration(
                          color:
                              Colors.white, // Background color of the container
                          borderRadius: BorderRadius.circular(
                              10), // Optional: Add border radius to the container
                          boxShadow: [
                            BoxShadow(
                              color:
                                  Colors.grey.withOpacity(0.5), // Shadow color
                              spreadRadius: 5, // Spread radius
                              blurRadius: 10, // Blur radius
                              offset:
                                  const Offset(0, 2), // Offset in the y-axis
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.only(left: 30.0, top: 20),
                              child: Column(
                                children: [
                                  const SizedBox(
                                    height: 52,
                                  ),
                                  Row(
                                    children: [
                                      Checkbox.adaptive(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(3),
                                        ),
                                        side: const BorderSide(
                                          width: 1,
                                          //color: borderColor, // Specify the color of the border
                                        ),
                                        checkColor: Colors.white,
                                        fillColor: MaterialStateProperty
                                            .resolveWith<Color?>(
                                                (Set<MaterialState> states) {
                                          if (states.contains(
                                              MaterialState.selected)) {
                                            return Colors
                                                .blue; // The color when checkbox is selected
                                          }
                                          return null; // Use the default color when checkbox is not selected
                                        }),
                                        value: isChecked1,
                                        onChanged: (bool? value) {
                                          if (value != null) {
                                            setState(() {
                                              isChecked1 = value;
                                              isChecked2 = false;
                                              isChecked3 = false;
                                            });
                                          }
                                        },
                                      ),
                                      const Text(
                                          'Presentation/Speech ( Output Consolidated : Single Speaker ) ')
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Checkbox.adaptive(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(3),
                                        ),
                                        side: const BorderSide(
                                          width: 1,
                                          //color: borderColor, // Specify the color of the border
                                        ),
                                        checkColor: Colors.white,
                                        fillColor: MaterialStateProperty
                                            .resolveWith<Color?>(
                                                (Set<MaterialState> states) {
                                          if (states.contains(
                                              MaterialState.selected)) {
                                            return Colors
                                                .blue; // The color when checkbox is selected
                                          }
                                          return null; // Use the default color when checkbox is not selected
                                        }),
                                        value: isChecked2,
                                        onChanged: (bool? value) {
                                          if (value != null) {
                                            setState(() {
                                              isChecked1 = false;
                                              isChecked2 = value;
                                              //isChecked3=true;
                                            });
                                          }
                                        },
                                      ),
                                      const Text(
                                          'Discussion Type Meeting ( Output Split By Speakers : Multiple Speakers )')
                                    ],
                                  ),
                                  Row(
                                    children: [
                                      Checkbox.adaptive(
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(3),
                                        ),
                                        side: const BorderSide(
                                          width: 1,
                                          //color: borderColor, // Specify the color of the border
                                        ),
                                        checkColor: Colors.white,
                                        fillColor: MaterialStateProperty
                                            .resolveWith<Color?>(
                                                (Set<MaterialState> states) {
                                          if (states.contains(
                                              MaterialState.selected)) {
                                            return Colors
                                                .blue; // The color when checkbox is selected
                                          }
                                          return null; // Use the default color when checkbox is not selected
                                        }),
                                        value: isChecked3,
                                        onChanged: (bool? value) {
                                          if (value != null) {
                                            setState(() {
                                              isChecked3 = value;
                                              isChecked1 = false;
                                              isChecked2 = true;
                                            });
                                          }
                                        },
                                      ),
                                      const Text(
                                          'Specific Speaker ( Output : Points By Each Speaker )')
                                    ],
                                  ),

                                  // Row(
                                  //   children: [
                                  //     Checkbox.adaptive(
                                  //       shape: RoundedRectangleBorder(
                                  //         borderRadius: BorderRadius.circular(3),
                                  //       ),
                                  //       side: const BorderSide(
                                  //         width: 1,
                                  //         //color: borderColor, // Specify the color of the border
                                  //       ),
                                  //       checkColor: Colors.white,
                                  //       fillColor: MaterialStateProperty
                                  //           .resolveWith<Color?>(
                                  //               (Set<MaterialState> states) {
                                  //             if (states
                                  //                 .contains(MaterialState.selected)) {
                                  //               return Colors
                                  //                   .blue; // The color when checkbox is selected
                                  //             }
                                  //             return null; // Use the default color when checkbox is not selected
                                  //           }),
                                  //       value: isChecked5,
                                  //       onChanged: (bool? value) {
                                  //         if (value != null) {
                                  //           setState(() {
                                  //             isChecked5 = value;
                                  //             //isChecked1=false;
                                  //             //isChecked2=true;
                                  //           });
                                  //         }
                                  //       },
                                  //     ),
                                  //     const Text(
                                  //         'Record Voice Sample ( Input : Speaker Voice Sample )')
                                  //   ],
                                  // ),
                                ],
                              ),
                            ),
                            //Search(),
                            const SizedBox(
                              height: 30,
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: InkWell(
                                onTap: () {
                                  if (isChecked1 == true ||
                                      isChecked2 == true && audioPath != null) {
                                    if (isChecked1 == true) {
                                      sendAudioSingle();
                                    } else if (isChecked2 == true) {
                                      SendAudioMultple();
                                    } else {
                                      return UI_Componenet.show(
                                          context, 'Something went wrong');
                                    }
                                  } else {
                                    UI_Componenet.show(context,
                                        'Please Select Check Box  to Continue to process');
                                  }
                                },
                                child: Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.4,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      gradient: const LinearGradient(
                                          colors: [
                                            Colors.blue,
                                            Colors.blue,
                                          ],
                                          begin: Alignment.bottomRight,
                                          end: Alignment.topLeft)),
                                  child: const Center(
                                    child: Padding(
                                      padding: EdgeInsets.all(8.0),
                                      child: Text("Process",
                                          style: TextStyle(
                                              fontSize: 12,
                                              color: Colors.white)),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(
                              height: 60,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (Utils.isloading == false && Data!=null) ..._buildSpeakerTextFields(Data),
              const Padding(
                padding: EdgeInsets.only(top: 28.0),
                child: Text(
                  'Output Box ',
                  style: TextStyle(
                      fontSize: 20,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                      fontFamily: "Montserrat-Regular"),
                ),
              ),
              UI_Componenet.Costom_Container_output(context, Data),
              if (Data!=null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 600.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton(
                          onPressed: () {
                            if (jsonData['messages'] != null) {
                              _handleResponseDataAndSaveAsPdf(jsonData);
                            }
                          },
                          child: Text('Save As PDF')),
                      ElevatedButton(
                          onPressed: () {
                            sendDatatoSaveInWorldFile();
                          },
                          child: Text('Save As Word')),
                      ElevatedButton(
                          onPressed: () {
                            if (jsonData['messages'] != null) {
                              _saveMessages(jsonData);
                            }
                          },
                          child: Text('Save As TXT')),
                    ],
                  ),
                ),
              const SizedBox(
                height: 100,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
