import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../DataBase_Backend/Helpers/Helper.dart';
import '../../../Utils/Contants.dart';
import 'package:http/http.dart' as http;

import '../../../Utils/UI_HELPER.dart';
import 'M-O-M_Create_Screen.dart';


class Meeting_DetailsScreen extends StatefulWidget {
  var meetingId;
  Meeting_DetailsScreen({
    super.key,
    required this.meetingId,
  });
  @override
  State<Meeting_DetailsScreen> createState() => _Meeting_DetailsScreenState();
}

class _Meeting_DetailsScreenState extends State<Meeting_DetailsScreen> {
  bool isloading = false;
  // Future<void> _saveMessages(
  //   Map<String, dynamic> jsonData,
  //   String p2,
  //   String p3,
  // ) async {
  //   // Create a directory to store files
  //   Directory? downloadDir = await getDownloadsDirectory();
  //   String? documentsPath = downloadDir?.path;
  //   String speakersFolderPath =
  //       '$documentsPath\\speakers${DateTime.now().millisecondsSinceEpoch.toString()}';
  //   Map<String, List<String>> speakerMessages = {};
  //
  //   if (jsonData['messages'] != null) {
  //     List<dynamic> messages = jsonData['messages'];
  //
  //     for (var message in messages) {
  //       if (message['speaker'] != null &&
  //           message['text'] != null &&
  //           message['time'] != null) {
  //         String speaker = message['speaker'];
  //         String text = message['text'];
  //
  //         // Create separate list for each speaker
  //         if (!speakerMessages.containsKey(speaker)) {
  //           speakerMessages[speaker] = [];
  //         }
  //         speakerMessages[speaker]!.add(
  //             '${message['speaker']} (${message['time']}): ${message['text']}');
  //       }
  //     }
  //
  //     if (p3 == '1') {
  //       // Save each speaker's messages to a separate file
  //       for (String speaker in speakerMessages.keys) {
  //         // Create directory for each speaker
  //         String speakerFolderPath = '$speakersFolderPath/$speaker';
  //         Directory(speakerFolderPath).createSync(recursive: true);
  //
  //         // Create a file for speaker's messages
  //         File file = File('$speakerFolderPath/messages.txt');
  //         await file.writeAsString(speakerMessages[speaker]!.join('\n'));
  //       }
  //     } else {
  //       List<String> data = [];
  //       // Handle the response data as needed
  //       if (jsonData['messages'] != null) {
  //         List<dynamic> messages = jsonData['messages'];
  //         for (var message in messages) {
  //           if (message['speaker'] != null &&
  //               message['text'] != null &&
  //               message['time'] != null) {
  //             String messageData =
  //                 '${message['speaker']} (${message['time']}): ${message['text']}';
  //             data.add(messageData);
  //           } else {
  //             // Handle the case where any of the fields are null
  //             // For example, you can skip adding such messages or add a placeholder
  //           }
  //         }
  //       }
  //
  //       String filename =
  //           'audio_${DateTime.now().millisecondsSinceEpoch.toString()}.txt';
  //       String speakerFolderPath = '$speakersFolderPath';
  //       Directory(speakerFolderPath).createSync(recursive: true);
  //
  //       // Write the response body to a file
  //       File file = File('$speakerFolderPath$filename');
  //       await file.writeAsString(data.join('\n'));
  //     }
  //   }
  //
  //   // Show a pop-up displaying the downloaded file's path
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text('Files Downloaded'),
  //         content: Text('Files downloaded to: $speakersFolderPath'),
  //         actions: <Widget>[
  //           ElevatedButton(
  //             onPressed: () async {
  //               // Open folder in file explorer
  //               await Process.run('explorer.exe', [speakersFolderPath]);
  //             },
  //             child: Text('Open Folder'),
  //           ),
  //           ElevatedButton(
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //             child: Text('OK'),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  ///
  Future<void> _handleResponseDataAndSaveAsPdf(
    Map<String, dynamic> jsonData,
    String p2,
    String p3,
  ) async
  {
    // Extract messages from JSON data
    List<dynamic> messages = jsonData['messages'];
    if (p3 == '1') {
      List<String> allMessages = [];
      // Combine all messages into a single list
      for (var message in messages) {
        if (message['speaker'] != null &&
            message['text'] != null &&
            message['start_time'] != null) {
          String messageText =
              '${message['speaker']} (${message['start_time']}): ${message['text']}';
          allMessages.add(messageText);
        }
      }

      final folderName = 'Pratilekh_PDF_Files';
      final downloadsDirectory = await getDownloadsDirectory();
      final folderPath = '${downloadsDirectory?.path}\\Pratilekh\\$folderName';

      Directory directory = Directory(folderPath);

      // Check if the directory exists
      if (await directory.exists()) {

      } else {
        // If directory doesn't exist, create it
        directory.create(recursive: true).then((Directory directory) {

        });
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
      final pdfFilename =
          'all_messages${DateTime.now().millisecondsSinceEpoch}.pdf';
      final pdfFilePath = '$folderPath/$pdfFilename';

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
                child: Text('Open Folder'),
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
      Map<String, List<String>> speakerMessages = {};

      // Generate a unique folder name based on the current timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final folderName = 'Speaker_Wise_Data_$timestamp';
      final downloadsDirectory = await getDownloadsDirectory();
      final folderPath = '${downloadsDirectory?.path}\\Pratilekh\\$folderName';
      Directory directory = Directory(folderPath);

      // Check if the directory exists
      if (await directory.exists()) {

      } else {
        // If directory doesn't exist, create it
        directory.create(recursive: true).then((Directory directory) {

        });
      }

      // Create a directory for saving the PDF files
      final folder = Directory(folderPath);
      await folder.create();
      // Iterate through each message
      for (var message in messages) {
        if (message['speaker'] != null &&
            message['text'] != null &&
            message['start_time'] != null) {
          String speaker = message['speaker'];
          String text = message['text'];

          // Create separate list for each speaker
          if (!speakerMessages.containsKey(speaker)) {
            speakerMessages[speaker] = [];
          }
          speakerMessages[speaker]!.add(
              '${message['speaker']} (${message['start_time']}): ${message['text']}');
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
                child: Text('Open Folder'),
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

  ///
  Future<void> sendDatatoSaveInWorldFile(
      List<dynamic>? worldfiledata, bool pointwise) async {
    try {
      //List<dynamic> messages = Data?['messages'];
      // Create the JSON object to hold the data
      Map<String, dynamic> jsonData = {
        "messages": worldfiledata,
        "separate_speaker_files": pointwise
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
                    child: Text('Open Folder'),
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

      } else {

      }
    } catch (e) {

    }
  }

  void sendAudioSingle(File file, String meeting_id) async {
    UI_Componenet.Showloadingpop(context);
    Map<String, dynamic>? Data;
    String currentDate =
        DateFormat('dd-MM-yyyy HH:mm:ss').format(DateTime.now());

    if (file != null) {
      String audioFilePath = file!.path;

      // Create a multipart request
      var request = http.MultipartRequest(
          'POST', Uri.parse('http://127.0.0.1:5000/process_audio'));

      // Add the audio file to the request
      request.files
          .add(await http.MultipartFile.fromPath('audio', audioFilePath));

      // Add check button states to the request as form fields
      request.fields['single_speaker'] =
          true.toString(); // Replace 'true' with the actual state of button 1
      // request.fields['multiple_speaker'] = isChecked2.toString(); // Replace 'false' with the actual state of button 2

      // Send the request
      try {
        var streamedResponse = await request.send();

        // Read response from stream
        var response = await http.Response.fromStream(streamedResponse);


        if (response.statusCode == 200) {
          Navigator.pop(context);
          _reloadMeetingDetails();
          // Parse the JSON response
          var jsonData = json.decode(response.body);

          Data = jsonData;

          List<String> data = [];
          if (jsonData['result'] != null) {
            data.add(jsonData['result']);
          }
          DatabaseHelper.insertMeetingRecord(meeting_id, audioFilePath, true,
              false, false, data.toString(), null, null, null, currentDate);
          SnackBarHelper.showFailedInsertionSnackbar(
              context, AppString.process_sucess);
        } else {
          SnackBarHelper.showFailedInsertionSnackbar(
              context, AppString.process_error);
          Navigator.pop(context);

          return UI_Componenet.showError(
              context, '${response.body.toString()}');
        }
      } catch (e) {
        SnackBarHelper.showFailedInsertionSnackbar(
            context, AppString.process_error);
        Navigator.pop(context);
        return UI_Componenet.showError(context, '${e.toString()}');

      }
    } else {
      SnackBarHelper.showFailedInsertionSnackbar(
          context, AppString.process_error);
      Navigator.pop(context);
      return UI_Componenet.showAudio(
          context, 'Please select Audio File to proceed');

    }
  }

  void SendAudioMultple(File file, String meeting_id) async {
    UI_Componenet.Showloadingpop(context);
    String currentDate =
        DateFormat('dd-MM-yyyy HH:mm:ss').format(DateTime.now());
    // Get the path of the audio file if it is not null
    if (file != null) {
      String audioFilePath = file!.path;
      // Create a multipart request
      var request = http.MultipartRequest(
          'POST', Uri.parse('http://127.0.0.1:5000/process_audio_speaker'));

      // Add the audio file to the request
      request.files
          .add(await http.MultipartFile.fromPath('audio', audioFilePath));

      // Add check button states to the request as form fields
      //request.fields['single_speaker'] = isChecked1.toString(); // Replace 'true' with the actual state of button 1
      request.fields['multiple_speaker'] =
          true.toString(); // Replace 'false' with the actual state of button 2
      // Send the request
      try {
        var streamedResponse = await request.send();
        // Read response from stream
        var response = await http.Response.fromStream(streamedResponse);

        if (response.statusCode == 200) {
          SnackBarHelper.showFailedInsertionSnackbar(
              context, AppString.process_sucess);
          Navigator.pop(context);
          _reloadMeetingDetails();
          // Parse the JSON response
          var jsonData = json.decode(response.body);
          var databasedata;

          setState(() {
            var Data = jsonData;
            databasedata = json.encode(Data);
          });
          DatabaseHelper.insertMeetingRecord(
              meeting_id,
              audioFilePath,
              false,
              true,
              false,
              null,
              databasedata.toString(),
              null,
              null,
              currentDate);
          setState(() {});
        } else {
          SnackBarHelper.showFailedInsertionSnackbar(
              context, AppString.process_error);
          Navigator.pop(context);
          return UI_Componenet.showError(
              context, '${response.body.toString()}');

        }
      } catch (e) {
        SnackBarHelper.showFailedInsertionSnackbar(
            context, AppString.process_error);
        Navigator.pop(context);
        setState(() {});
        return UI_Componenet.showError(context, "${e.toString()}");

      }
    } else {
      SnackBarHelper.showFailedInsertionSnackbar(
          context, AppString.process_error);
      Navigator.pop(context);
      return UI_Componenet.showAudio(
          context, 'Please select Audio File to proceed');

    }
  }

  Future<void> summerise(String text, String file, String meeting_id) async {
    String currentDate =
        DateFormat('dd-MM-yyyy HH:mm:ss').format(DateTime.now());
    UI_Componenet.Showloadingpop(context);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const AlertDialog();
      },
    );
    try {
      Map<String, dynamic> jsonData = {
        "text": text,
      };

      var response = await http.post(
        Uri.parse('http://127.0.0.1:5000/summarize'),
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(jsonData), // Convert data to JSON format
      );
      if (response.statusCode == 200) {
        _reloadMeetingDetails();
        SnackBarHelper.showFailedInsertionSnackbar(
            context, AppString.summersucess);
        var responseBody = json.decode(response.body);


        DatabaseHelper.insertMeetingRecord(
            meeting_id,
            file,
            false,
            true,
            false,
            null,
            null,
            null,
            responseBody['summaries'].toString(),
            currentDate);
        Navigator.pop(context);
      } else {
        Navigator.pop(context);
      }
    } catch (e) {
      Navigator.pop(context);

    }
  }

  Future<Map<String, dynamic>>? _meetingDetailsFuture;

  @override
  void initState() {
    super.initState();
    _meetingDetailsFuture =
        DatabaseHelper.getMeetingDetailsAndRecords(widget.meetingId);
    fetchMeetingData();
  }

  Future<void> _reloadMeetingDetails() async {
    setState(() {
      _meetingDetailsFuture =
          DatabaseHelper.getMeetingDetailsAndRecords(widget.meetingId);
    });
  }

  Future<void> sendDataToApiFor_SaveMOMpdf(
    String refNo,
    String meetingDate,
    String meetingTitle,
    String members,
    String attendees,
    List<String> summaries,
    String copyTo,
  ) async {
    final folderName = 'Pratilekh_PDF_M-O-M_Files';
    final downloadsDirectory = await getDownloadsDirectory();
    final folderPath = '${downloadsDirectory?.path}\\Pratilekh\\$folderName';

    Directory directory = Directory(folderPath);

    // Check if the directory exists
    if (await directory.exists()) {

    } else {
      // If directory doesn't exist, create it
      directory.create(recursive: true).then((Directory directory) {

      });
    }

    // Create a directory for saving the PDF files
    final folder = Directory(folderPath);
    await folder.create();
    final pdf = pw.Document();

    List<String> invitedlist = [];
    List<String> memberList = [];
    List<String> cotytolist = [];
    if (members != 'null') {
      List<dynamic> decodedList = jsonDecode(members);
      memberList = decodedList.cast<String>();
    }

    if (attendees != 'null') {
      List<dynamic> invited = jsonDecode(attendees);
      invitedlist = invited.cast<String>();
    }

    //List<String> invitedlist = invited.cast<String>();
    if (copyTo != 'null') {
      List<dynamic> copy = jsonDecode(copyTo);
      cotytolist = copy.cast<String>();
    }

    // Add content to the PDF
    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Padding(
                padding: const pw.EdgeInsets.only(
                  left: 20,
                  bottom: 20,
                ), // Add bottom padding
                child: pw.Center(
                  child: pw.DecoratedBox(
                    decoration: const pw.BoxDecoration(
                      border: pw.Border(
                        bottom: pw.BorderSide(
                          color: PdfColors.black, // Color of the underline
                          width: 1, // Width of the underline
                        ),
                      ),
                    ),
                    child: pw.Text(meetingTitle,
                        style: pw.TextStyle(
                            fontSize: 20,
                            fontWeight: pw.FontWeight.bold,
                            color: PdfColors.blue800)),
                  ),
                ),
              ),
              pw.Padding(
                padding: const pw.EdgeInsets.only(
                  top: 20,
                  bottom: 20,
                ),
                child: pw.Text('Meetings Minutes ',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.blue800,
                    )),
              ),
              pw.Row(
                children: [
                  pw.Text('Ref co : ',
                      style: pw.TextStyle(
                        color: PdfColors.black,
                        fontSize: 13,
                        fontWeight: pw.FontWeight.bold,
                      )),
                  pw.Text(refNo, textAlign: pw.TextAlign.right),
                  pw.Spacer(), // Add a spacer to separate the texts
                  pw.Text('Meeting Date : ',
                      style: pw.TextStyle(
                        color: PdfColors.black,
                        fontSize: 13,
                        fontWeight: pw.FontWeight.bold,
                      )),
                  pw.Text(meetingDate, textAlign: pw.TextAlign.right),
                ],
              ),
              if (memberList.isNotEmpty)
                pw.Padding(
                  padding: pw.EdgeInsets.only(
                    top: 20,
                    bottom: 10,
                  ), // Add bottom padding
                  child: pw.Text('Members:',
                      style: pw.TextStyle(
                        color: PdfColors.black,
                        fontSize: 13,
                        fontWeight: pw.FontWeight.bold,
                      )),
                ),
              for (var member in memberList) pw.Bullet(text: member),
              if (invitedlist.isNotEmpty)
                pw.Padding(
                  padding: pw.EdgeInsets.only(
                      top: 20, bottom: 10), // Add bottom padding
                  child: pw.Text('Attendees:',
                      style: pw.TextStyle(
                        color: PdfColors.black,
                        fontSize: 13,
                        fontWeight: pw.FontWeight.bold,
                      )),
                ),
              for (var attendee in invitedlist) pw.Bullet(text: attendee),
              pw.Padding(
                padding: pw.EdgeInsets.only(
                    top: 20, bottom: 10), // Add bottom padding
                child: pw.Text('Summaries:',
                    style: pw.TextStyle(
                      color: PdfColors.black,
                      fontSize: 13,
                      fontWeight: pw.FontWeight.bold,
                    )),
              ),
              for (var summary in summaries) pw.Text(summary),
              if (cotytolist.isNotEmpty)
                pw.Padding(
                  padding: pw.EdgeInsets.only(
                      top: 20, bottom: 10), // Add bottom padding
                  child: pw.Text('Copy To:',
                      style: pw.TextStyle(
                        color: PdfColors.black,
                        fontSize: 13,
                        fontWeight: pw.FontWeight.bold,
                      )),
                ),
              for (var recipient in cotytolist) pw.Bullet(text: recipient),
            ],
          );
        },
      ),
    );
    final pdfFilename = '$meetingTitle.pdf';
    final pdfFilePath = '$folderPath\\$pdfFilename';
    // Save the PDF to a file
    // Save the PDF to a file
    final pdfFile = File(pdfFilePath);
    await pdfFile.writeAsBytes(await pdf.save());

    // Check if PDF was saved successfully
    if (await pdfFile.exists()) {
      // Show a pop-up dialog upon successful saving
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Success'),
            content:
                Text('PDF generated and saved successfully at: $pdfFilePath'),
            actions: <Widget>[
              TextButton(
                onPressed: () async {
                  await Process.run('explorer.exe', [pdfFilePath]);
                },
                child: Text('Open'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Close'),
              ),
            ],
          );
        },
      );
    } else {
      // Show an error message if PDF saving failed
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content: Text('Failed to save PDF.'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('Close'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> sendDataToApiFor_SaveMOM(
    String refNo,
    String meetingDate,
    String meetingTitle,
    String members,
    String attendees,
    String summaries,
    String copyTo,
      String meetingheldby
  ) async {
    List<String> listofmember = [];
    List<String> listofinvidedmember = [];
    List<String> listofcopyto = [];
    if (attendees != 'null') {
      String invitedlist = attendees.substring(1, attendees.length - 1);
      List<dynamic> invitedList = jsonDecode("[$invitedlist]");
      for (String member in invitedList) {
        listofinvidedmember.add(member.toString());

      }
    }
    if (copyTo != 'null') {
      String copytolist = copyTo.substring(1, copyTo.length - 1);
      List<dynamic> copytoList = jsonDecode("[$copytolist]");
      for (String member in copytoList) {
        listofcopyto.add(member.toString());

      }
    }

    if (members != 'null') {
      String memeberlist = members.substring(1, members.length - 1);
      List<dynamic> memberList = jsonDecode("[$memeberlist]");

      for (String member in memberList) {
        listofmember.add(member.toString());

      }
    }

    final String apiUrl = 'http://127.0.0.1:5000/create-document';


    final Map<String, dynamic> meetingData = {
      "ref_no": refNo,
      "meeting_date": meetingDate,
      "meeting_title": meetingTitle,
      "meeting_held_by": meetingheldby.toString(),
      "members": listofmember,
      "invitees": listofinvidedmember,
      "agenda_points": summaries,
      "copy_to": listofcopyto,
    };

    final http.Response response = await http.post(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(meetingData),
    );


    if (response.statusCode == 200) {
      var responseBody = json.decode(response.body);

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Word File  Saved'),
            content: Text('Word File  saved to: ${responseBody['file_path']}'),
            actions: <Widget>[
              ElevatedButton(
                onPressed: () async {
                  // Open folder in file explorer
                  await Process.run(
                      'explorer.exe', [responseBody['file_path']]);
                },
                child: Text('Open Folder'),
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
print(response.body);
    }
  }
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!mounted) return; // Prevent building the UI when the screen is not visible


    // Check if there's a previous route in the Navigator's history
    if (ModalRoute.of(context)?.isCurrent == true) {
      // Add a post-frame callback to execute after the current frame
      WidgetsBinding.instance?.addPostFrameCallback((_) {
        // Check if the previous route was not the meeting screen
        if (ModalRoute.of(context)?.settings.name != '/meeting_screen') {
          // User navigated back to the meeting screen
          print("Welcome");
          fetchMeetingData();
        }
      });
    }
  }

  @override
  bool get wantKeepAlive => true;

  fetchMeetingData() {
    _reloadMeetingDetails();
    // Fetch meeting data using the meetingId
    // Set the meeting variable to the fetched data
    setState(() {});
  }

  Future<void> savePdf() async {
    final folderName = 'Pratilekh_MOM_PDF_Files';
    final downloadsDirectory = await getDownloadsDirectory();
    final folderPath = '${downloadsDirectory?.path}\\Pratilekh\\$folderName';

    Directory directory = Directory(folderPath);

    // Check if the directory exists
    if (await directory.exists()) {
      print('Directory already exists: $folderPath');
    } else {
      // If directory doesn't exist, create it
      directory.create(recursive: true).then((Directory directory) {
        print('Directory created: $folderPath');
      });
    }
    print(allData.length);
    try {
      // Check if allData is null
      if (allData == null) {
        print('allData is null');
        return;
      }

      // Create a PDF document
      final pdf = pw.Document();

      // Add content to the PDF document
      pdf.addPage(
        pw.Page(
          build: (context) {
            return pw.Table.fromTextArray(
              context: context,
              data: [
                <String>['Sno', 'Agenda', 'desc','resp','info'],
                for (var i=1; i <= allData.length ; i++) // Start from 1 and use <=
                  [
                    i.toString(), // Use i for Sno
                    allData[i]?.containsKey('Agenda') == true ? allData[i]!['Agenda']!.join('\n') : '',
                    allData[i]?.containsKey('Discussion') == true ? allData[i]!['Discussion']!.join('\n') : '',
                    allData[i]?.containsKey('Response') == true ? allData[i]!['Response']!.join('\n') : '',
                    allData[i]?.containsKey('Info') == true ? allData[i]!['Info']!.join('\n') : '',

                  ],
              ],
            );
          },
        ),
      );



      print('Before saving PDF document');
      // Save the PDF document
      final bytes = await pdf.save(); // Error occurs here
      print('After saving PDF document');

      final file = File('${directory.path}\\meeting_mom.pdf');
      await file.writeAsBytes(bytes);
      print(file);
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
                child: Text('Open Folder'),
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
    } catch (e, stackTrace) {
      print('Error occurred: $e');
      print('Stack trace: $stackTrace');
    }
  }
  List<int> Sno = [];


  Map<int, Map<String, List<String>>> allData = {};

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
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 208.0, vertical: 50),
            child: FutureBuilder<Map<String, dynamic>>(
              future: _meetingDetailsFuture,
              //DatabaseHelper.getMeetingDetailsAndRecords(widget.meetingId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else {
                  final Map<String, dynamic> data = snapshot.data!;
                  final Map<String, dynamic>? meetingDetails =
                      data['meetingDetails'];

                  final List<Map<String, dynamic>> meetingRecords =
                      data['meetingRecords'];
                  if (meetingDetails == null) {
                    return const Center(
                        child: Text('Meeting details not found.'));
                  } else {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: RichText(
                            text: TextSpan(
                              style: DefaultTextStyle.of(context).style,
                              children: <TextSpan>[
                                 TextSpan(
                                  text: 'Meeting Title: ',
                                  style: myBoldBlueStyle,
                                ),
                                TextSpan(
                                  text: meetingDetails['title'],
                                  style: myBoldblackStyle
                                ),
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
                                  text: 'Meeting Held By : ',
                                  style:myBoldBlueStyle,
                                ),
                                TextSpan(
                                  text: meetingDetails['meeting_held'],
                                  style:myBoldblackStyle
                                ),
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
                                      text: 'Meeting Code No: ',
                                      style:myBoldBlueStyle,
                                    ),
                                    TextSpan(
                                      text: meetingDetails['codeNo'],
                                      style: myBoldblackStyle
                                    ),
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
                                      text: 'Meeting Date : ',
                                      style: myBoldBlueStyle,
                                    ),
                                    TextSpan(
                                      text: meetingDetails['meetingDate'],
                                      style: myBoldblackStyle
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
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
                                      text: 'Meeting Member List : ',
                                      style: myBoldBlueStyle,
                                    ),
                                    ..._buildMemberList(
                                        meetingDetails['memberList']),
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
                                      text: 'Invited Member List : ',
                                      style:myBoldBlueStyle,
                                    ),
                                    ..._buildMemberList(
                                        meetingDetails['inviteMemberList']),
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
                                      text: 'Copy to  : ',
                                      style: myBoldBlueStyle,
                                    ),
                                    ..._buildMemberList(meetingDetails['copyto']),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),



                        // Add more details here...
                        const SizedBox(height: 50),
                        Text(
                          'Meeting Records :',
                          style: TextStyleForTitle,
                        ),
                        const Divider(),
                        if (meetingRecords.isEmpty)
                          const Text('No records found.',style: TextStyle( fontWeight: FontWeight.bold,
                            letterSpacing: 1,),)
                        else
                          ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: meetingRecords.length,
                            itemBuilder: (context, index) {
                              final record = meetingRecords[index];
                              return Column(
                                children: [
                                  ListTile(
                                    leading: Text(
                                      '${index + 1}.',
                                      style: TextStyleForTitle,
                                    ),
                                    title: Text(path.basename(
                                        record['input_source'] ??
                                            'No input source')),
                                    subtitle: Text(record['processed_date'] ??
                                        'No process output'),
                                    // Add more details as needed...
                                    trailing: SizedBox(
                                      width: 500, // Adjust the width as needed
                                      child: Row(
                                        children: [
                                          // IconButton(onPressed: (){
                                          //   _reloadMeetingDetails();
                                          // }, icon: Icon(Icons.refresh)),
                                          Container(
                                            width: 170,
                                            height: 35,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              border: Border.all(
                                                  color: Colors
                                                      .grey), // Add border color
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      5.0), // Add border radius
                                            ),
                                            child: DropdownButton<String>(
                                              icon:
                                                  Container(), // Set the default icon
                                              hint: const Row(
                                                children: [
                                                  Text('   Download'),
                                                  SizedBox(
                                                    width: 30,
                                                  ),
                                                  Icon(Icons
                                                      .arrow_drop_down_outlined)
                                                ],
                                              ),
                                              underline: Container(),
                                              onChanged: (value) {
                                                // Implement the logic when dropdown value changes
                                              },
                                              items: [
                                                DropdownMenuItem(
                                                  onTap: () async {

                                                    if (record['o1'] != null) {
                                                      String filename =
                                                          'audio_${DateTime.now().millisecondsSinceEpoch.toString()}.txt';
                                                      final folderName =
                                                          'Pratilekh_TXT_Files\\$filename';
                                                      final downloadsDirectory =
                                                          await getDownloadsDirectory();
                                                      final folderPath =
                                                          '${downloadsDirectory?.path}\\Pratilekh\\$folderName';
                                                      Directory directory =
                                                          Directory(folderPath);

                                                      // Check if the directory exists
                                                      if (await directory
                                                          .exists()) {

                                                      } else {
                                                        // If directory doesn't exist, create it
                                                        directory
                                                            .create(
                                                                recursive: true)
                                                            .then((Directory
                                                                directory) {

                                                        });
                                                      }
                                                      if (directory != null) {
                                                        directory.createSync(
                                                            recursive: true);
                                                        String filePath =
                                                            '${directory.path}\\$filename';
                                                        File file =
                                                            File(filePath);
                                                        await file
                                                            .writeAsString(
                                                                record['o1']);
                                                        _showDialogforSinglespeaker(
                                                            context, filePath);
                                                      } else {

                                                      }
                                                    } else {

                                                      _datanotfound(
                                                          context,
                                                          record[
                                                              'input_source'],
                                                          record['meeting_id'],
                                                          true);
                                                      _datanotfound(
                                                          context,
                                                          record[
                                                              'input_source'],
                                                          record['meeting_id'],
                                                          true);
                                                    }
                                                  },
                                                  value: 'Option 1',
                                                  child: const Text(
                                                      'Single Speaker'),
                                                ),
                                                DropdownMenuItem(
                                                  onTap: () {

                                                  },
                                                  value: 'Option 2',
                                                  child: DropdownButton<String>(
                                                    hint: const Text(
                                                        'Multi Speaker'),
                                                    underline: Container(),
                                                    onChanged: (value) {
                                                      // Implement the logic when dropdown value changes
                                                    },
                                                    items: [
                                                      // DropdownMenuItem(
                                                      //   onTap: (){
                                                      //     Map<String, dynamic>? data;
                                                      //     try {
                                                      //       data = json.decode(record['o2']);
                                                      //       _handleResponseDataAndSaveAsPdf(data!,'1','0');
                                                      //     } catch (e) {
                                                      //       // Handle the FormatException here
                                                      //       print('Error decoding JSON: $e');
                                                      //       data = {}; // or null
                                                      //     }
                                                      //   },
                                                      //   value: 'Option 1',
                                                      //   child: Text('Single\n Speaker',style: TextStyleForDropdown,),
                                                      // ),
                                                      DropdownMenuItem(
                                                        onTap: () {
                                                          if (record['o2'] !=
                                                              null) {
                                                            Map<String,
                                                                dynamic>? data;
                                                            try {
                                                              data = json.decode(
                                                                  record['o2']);
                                                              _handleResponseDataAndSaveAsPdf(
                                                                  data!,
                                                                  '0',
                                                                  '1');
                                                            } catch (e) {
                                                              // Handle the FormatException here

                                                              data =
                                                                  {}; // or null
                                                            }
                                                          } else {

                                                            _datanotfound(
                                                                context,
                                                                record[
                                                                    'input_source'],
                                                                record[
                                                                    'meeting_id'],
                                                                false);
                                                            _datanotfound(
                                                                context,
                                                                record[
                                                                    'input_source'],
                                                                record[
                                                                    'meeting_id'],
                                                                false);
                                                          }
                                                        },
                                                        value: 'Option 2',
                                                        child: Text(
                                                          'PDF File',
                                                          style:
                                                              TextStyleForDropdown,
                                                        ),
                                                      ),
                                                      DropdownMenuItem(
                                                        onTap: () {
                                                          if (record['o2'] !=
                                                              null) {
                                                            Map<String,
                                                                dynamic>? data;
                                                            try {
                                                              data = json.decode(
                                                                  record['o2']);
                                                              sendDatatoSaveInWorldFile(
                                                                  data![
                                                                      'messages'],
                                                                  false);
                                                              // _handleResponseDataAndSaveAsPdf(data!,'0','1');
                                                            } catch (e) {
                                                              // Handle the FormatException here

                                                              data =
                                                                  {}; // or null
                                                            }
                                                          } else {

                                                            _datanotfound(
                                                                context,
                                                                record[
                                                                    'input_source'],
                                                                record[
                                                                    'meeting_id'],
                                                                false);
                                                            _datanotfound(
                                                                context,
                                                                record[
                                                                    'input_source'],
                                                                record[
                                                                    'meeting_id'],
                                                                false);
                                                          }
                                                        },
                                                        value: 'Option 3',
                                                        child: Text(
                                                          'WORD File',
                                                          style:
                                                              TextStyleForDropdown,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                DropdownMenuItem(
                                                  onTap: () {
                                                  },
                                                  value: 'Option 3',
                                                  child: DropdownButton<String>(
                                                    hint: const Text(
                                                        'Speaker wise '),
                                                    underline: Container(),
                                                    onChanged: (value) {
                                                      // Implement the logic when dropdown value changes
                                                    },
                                                    items: [
                                                      // DropdownMenuItem(
                                                      //   onTap: (){
                                                      //
                                                      //   },
                                                      //   value: 'Option 1',
                                                      //   child: Text('Single\n Speaker',style: TextStyleForDropdown,),
                                                      // ),
                                                      DropdownMenuItem(
                                                        onTap: () {
                                                          if (record['o2'] !=
                                                              null) {
                                                            Map<String,
                                                                dynamic>? data;
                                                            try {
                                                              data = json.decode(
                                                                  record['o2']);
                                                              _handleResponseDataAndSaveAsPdf(
                                                                  data!,
                                                                  '1',
                                                                  '0');
                                                            } catch (e) {
                                                              // Handle the FormatException here

                                                              data =
                                                                  {}; // or null
                                                            }
                                                          } else {

                                                            _datanotfound(
                                                                context,
                                                                record[
                                                                    'input_source'],
                                                                record[
                                                                    'meeting_id'],
                                                                false);
                                                            _datanotfound(
                                                                context,
                                                                record[
                                                                    'input_source'],
                                                                record[
                                                                    'meeting_id'],
                                                                false);
                                                          }
                                                        },
                                                        value: 'Option 2',
                                                        child: Text(
                                                          'PDF File',
                                                          style:
                                                              TextStyleForDropdown,
                                                        ),
                                                      ),
                                                      DropdownMenuItem(
                                                        onTap: () {
                                                          if (record['o2'] !=
                                                              null) {
                                                            Map<String,
                                                                dynamic>? data;
                                                            try {
                                                              data = json.decode(
                                                                  record['o2']);
                                                              sendDatatoSaveInWorldFile(
                                                                  data![
                                                                      'messages'],
                                                                  true);
                                                              // _handleResponseDataAndSaveAsPdf(data!,'0','1');
                                                            } catch (e) {
                                                              // Handle the FormatException here

                                                              data =
                                                                  {}; // or null
                                                            }
                                                          } else {

                                                            _datanotfound(
                                                                context,
                                                                record[
                                                                    'input_source'],
                                                                record[
                                                                    'meeting_id'],
                                                                false);
                                                            _datanotfound(
                                                                context,
                                                                record[
                                                                    'input_source'],
                                                                record[
                                                                    'meeting_id'],
                                                                false);
                                                          }
                                                        },
                                                        value: 'Option 3',
                                                        child: Text(
                                                          'WORD File',
                                                          style:
                                                              TextStyleForDropdown,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                DropdownMenuItem(
                                                  onTap: () {

                                                    if (record['m_o_m'] !=
                                                        null) {
                                                      DateFormat inputDateFormat = DateFormat('dd-MM-yyyy hh:mm:ss');

                                                      // Parse the date string
                                                      DateTime meetingDate = inputDateFormat.parse(meetingDetails['meetingDate']);

                                                      // Create a DateFormat object with the desired output format
                                                      DateFormat outputDateFormat = DateFormat('dd-MM-yyyy');

                                                      // Format the date
                                                      String formattedDate = outputDateFormat.format(meetingDate);

                                                      // Print the formatted date
                                                      print(formattedDate); /// Output: 2024-05-10

                                                      sendDataToApiFor_SaveMOM(
                                                        meetingDetails['codeNo'], formattedDate, meetingDetails['title'], meetingDetails['memberList'], meetingDetails['inviteMemberList'], record['m_o_m'], meetingDetails['copyto'], meetingDetails['meeting_held']);

                                                    } else {
                                                      showDialog(
                                                        context: context,
                                                        builder:
                                                            (BuildContext
                                                        context) {
                                                          return AlertDialog(
                                                            title: const Text(
                                                                'Data Not Available'),
                                                            content:
                                                            const Text(
                                                                'The requested data is not available. Generate first to download'),
                                                            actions: [
                                                              TextButton(
                                                                onPressed:
                                                                    () {
                                                                  Navigator.of(context)
                                                                      .pop();
                                                                },
                                                                child: const Text(
                                                                    'OK'),
                                                              ),
                                                            ],
                                                          );
                                                        },
                                                      );
                                                      showDialog(
                                                        context: context,
                                                        builder:
                                                            (BuildContext
                                                        context) {
                                                          return AlertDialog();
                                                        },
                                                      );
                                                    }
                                                  },
                                                  value: 'Option 3',
                                                  child: Text(
                                                    'Download M-O-M',
                                                    style:
                                                    TextStyleForDropdown,
                                                  ),
                                                ),
                                                // DropdownMenuItem(
                                                //   onTap: () {},
                                                //   value: 'Option 2',
                                                //   child: DropdownButton<String>(
                                                //     hint: const Text('M-O-M'),
                                                //     underline: Container(),
                                                //     onChanged: (value) {
                                                //       // Implement the logic when dropdown value changes
                                                //     },
                                                //     items: [
                                                //       // DropdownMenuItem(
                                                //       //   onTap: (){
                                                //       //
                                                //       //   },
                                                //       //   value: 'Option 1',
                                                //       //   child: Text('Single\n Speaker',style: TextStyleForDropdown,),
                                                //       // ),
                                                //       DropdownMenuItem(
                                                //         onTap: () {
                                                //           if (record['m_o_m'] !=
                                                //               null) {
                                                //
                                                //
                                                //             void convertdata(String momdata){
                                                //
                                                //               if (momdata != null) {
                                                //                 // Decode the retrieved JSON string
                                                //                 Map<String, dynamic> decodedData = jsonDecode(momdata);
                                                //
                                                //                 // Convert the keys to integers
                                                //                 Map<int, Map<String, List<String>>> allData = {};
                                                //                 decodedData.forEach((key, value) {
                                                //                   Map<String, List<String>> innerMap = {};
                                                //                   value.forEach((innerKey, innerValue) {
                                                //                     innerMap[innerKey] = List<String>.from(innerValue);
                                                //                   });
                                                //                   allData[int.parse(key)] = innerMap;
                                                //                 });
                                                //
                                                //                 // Set the state with the converted data
                                                //                 setState(() {
                                                //                   this.allData = allData;
                                                //                   Sno = List<int>.generate(allData.length, (index) => index + 1);
                                                //                 });
                                                //
                                                //               } else {
                                                //
                                                //               }
                                                //             }
                                                //              convertdata( record['m_o_m']);
                                                //             print(allData);
                                                //             //
                                                //             // generatePdf(record['m_o_m']);
                                                //             savePdf();
                                                //           }
                                                //           else {
                                                //             showDialog(
                                                //               context: context,
                                                //               builder:
                                                //                   (BuildContext
                                                //                       context) {
                                                //                 return AlertDialog(
                                                //                   title: const Text(
                                                //                       'Data Not Available'),
                                                //                   content:
                                                //                       const Text(
                                                //                           'The requested data is not available. Generate first to download'),
                                                //                   actions: [
                                                //                     TextButton(
                                                //                       onPressed:
                                                //                           () {
                                                //                         Navigator.of(context)
                                                //                             .pop();
                                                //                       },
                                                //                       child: const Text(
                                                //                           'OK'),
                                                //                     ),
                                                //                   ],
                                                //                 );
                                                //               },
                                                //             );
                                                //             showDialog(
                                                //               context: context,
                                                //               builder:
                                                //                   (BuildContext
                                                //                       context) {
                                                //                 return const AlertDialog();
                                                //               },
                                                //             );
                                                //           }
                                                //         },
                                                //         value: 'Option 2',
                                                //         child: Text(
                                                //           'PDF File          ',
                                                //           style:
                                                //               TextStyleForDropdown,
                                                //         ),
                                                //       ),
                                                //       DropdownMenuItem(
                                                //         onTap: () {
                                                //           if (record['m_o_m'] !=
                                                //               null) {
                                                //             String
                                                //                 m_o_m_without_brackets =
                                                //                 record['m_o_m']
                                                //                     .replaceAll(
                                                //                         '[', '')
                                                //                     .replaceAll(
                                                //                         ']',
                                                //                         '');
                                                //             List<String>
                                                //                 m_o_m_list =
                                                //                 m_o_m_without_brackets
                                                //                     .split('.')
                                                //                     .map((item) =>
                                                //                         item.trim())
                                                //                     .toList();
                                                //
                                                //             sendDataToApiFor_SaveMOM(
                                                //               meetingDetails[
                                                //                   'codeNo'],
                                                //               meetingDetails[
                                                //                   'meetingDate'],
                                                //               meetingDetails[
                                                //                   'title'],
                                                //               meetingDetails[
                                                //                   'memberList'],
                                                //               meetingDetails[
                                                //                   'inviteMemberList'],
                                                //               m_o_m_list,
                                                //               meetingDetails[
                                                //                   'copyto'],
                                                //             );
                                                //           } else {
                                                //             showDialog(
                                                //               context: context,
                                                //               builder:
                                                //                   (BuildContext
                                                //                       context) {
                                                //                 return AlertDialog(
                                                //                   title: const Text(
                                                //                       'Data Not Available'),
                                                //                   content:
                                                //                       const Text(
                                                //                           'The requested data is not available. Generate first to download'),
                                                //                   actions: [
                                                //                     TextButton(
                                                //                       onPressed:
                                                //                           () {
                                                //                         Navigator.of(context)
                                                //                             .pop();
                                                //                       },
                                                //                       child: const Text(
                                                //                           'OK'),
                                                //                     ),
                                                //                   ],
                                                //                 );
                                                //               },
                                                //             );
                                                //             showDialog(
                                                //               context: context,
                                                //               builder:
                                                //                   (BuildContext
                                                //                       context) {
                                                //                 return AlertDialog();
                                                //               },
                                                //             );
                                                //           }
                                                //         },
                                                //         value: 'Option 3',
                                                //         child: Text(
                                                //           'WORD File',
                                                //           style:
                                                //               TextStyleForDropdown,
                                                //         ),
                                                //       ),
                                                //     ],
                                                //   ),
                                                // ),
                                              ],
                                            ),
                                          ),
                                          const Spacer(),
                                          InkWell(
                                            onTap: (){
                                              DatabaseHelper.getMeetingDetailsAndRecords(widget.meetingId).then((result) {
                                                if (result != null) {
                                                  if (record['o2'] !=
                                                      null) {
                                                    DateFormat inputDateFormat = DateFormat('dd-MM-yyyy hh:mm:ss');

                                                    // Parse the date string
                                                    DateTime meetingDate = inputDateFormat.parse(meetingDetails['meetingDate']);

                                                    // Create a DateFormat object with the desired output format
                                                    DateFormat outputDateFormat = DateFormat('dd-MM-yyyy');

                                                    // Format the date
                                                    String formattedDate = outputDateFormat.format(meetingDate);

                                                    // Print the formatted date
                                                  //  print(formattedDate); /// Output: 2024-05-10

                                                    // print(record['o2']);
                                                    Map<String, dynamic>?
                                                    data=json.decode(
                                                        record['o2']);
                                                   Navigator.push(context, MaterialPageRoute(builder: (context)=>Create_MOM_Screen(copyto: meetingDetails['copyto'], invitedmember: meetingDetails['inviteMemberList'], meetingdate: formattedDate, meetingID: widget.meetingId, meetingmember: meetingDetails['memberList'], meetingtitle: meetingDetails['title'], meetingcode: meetingDetails['codeNo'],multispeakerdata: data, recordfilename: record['input_source'],momdata: record['m_o_m'],)));

                                                  }
                                                  else {
                                                    _datanotfound(
                                                        context,
                                                        record[
                                                        'input_source'],
                                                        record[
                                                        'meeting_id'],
                                                        false);
                                                    // SnackBarHelper
                                                    //     .showFailedInsertionSnackbar(
                                                    //         context,
                                                    //         'message');
                                                  }
                                                  // Perform your task here
                                                  print('Task performed');
                                                }
                                              });

                                            },
                                            child: Container(
                                                width: 120,
                                                height: 35,
                                                decoration: BoxDecoration(
                                                  color: Colors.white,
                                                  border: Border.all(
                                                      color: Colors
                                                          .grey), // Add border color
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          5.0), // Add border radius
                                                ),
                                              child: const Center(child:Text('Create M-O-M',style: TextStyle(fontSize: 13),) ,),
                                            ),
                                          ),
                                          // Container(
                                          //   width: 120,
                                          //   height: 35,
                                          //   decoration: BoxDecoration(
                                          //     color: Colors.white,
                                          //     border: Border.all(
                                          //         color: Colors
                                          //             .grey), // Add border color
                                          //     borderRadius:
                                          //         BorderRadius.circular(
                                          //             5.0), // Add border radius
                                          //   ),
                                          //   child: DropdownButton<String>(
                                          //     padding:
                                          //         EdgeInsets.only(left: 20),
                                          //     hint: Text('M-O-M'),
                                          //     underline: Container(),
                                          //     onChanged: (value) {
                                          //       // Implement the logic when dropdown value changes
                                          //     },
                                          //     items: [
                                          //       DropdownMenuItem(
                                          //         onTap: () {
                                          //           if (record['o1'] != null) {
                                          //             summerise(
                                          //               record['o1'].toString(),
                                          //               record['input_source'],
                                          //               record['meeting_id'],
                                          //             );
                                          //           } else if (record['p1'] ==
                                          //               0) {
                                          //             print('data not avilble');
                                          //           }
                                          //         },
                                          //         value: 'Option 1',
                                          //         child: const Text('Generate'),
                                          //       ),
                                          //       DropdownMenuItem(
                                          //         onTap: () {},
                                          //         value: 'Option 2',
                                          //         child: const Text('Print'),
                                          //       ),
                                          //     ],
                                          //   ),
                                          // ),
                                          const Spacer(),
                                          Container(
                                            height: 35,
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              border: Border.all(
                                                  color: Colors.grey),
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                            ),
                                            child: DropdownButton<String>(
                                              padding: const EdgeInsets.only(
                                                  left: 20),
                                              hint: const Text('View'),
                                              underline: Container(),
                                              onChanged: (value) {
                                                // Implement the logic when dropdown value changes
                                              },
                                              items: [
                                                DropdownMenuItem(
                                                  value: 'Option 1',
                                                  child: GestureDetector(
                                                    onTap: () async {
                                                      if (record['o1'] !=
                                                          null) {
                                                        _showDialogforSinglespeaker_for_show_message(
                                                            context,
                                                            record['o1']);
                                                      } else {
                                                        _datanotfound(
                                                            context,
                                                            record[
                                                                'input_source'],
                                                            record[
                                                                'meeting_id'],
                                                            true);
                                                        // SnackBarHelper
                                                        //     .showFailedInsertionSnackbar(
                                                        //         context,
                                                        //         'message');
                                                        // // showErrorandproccesto_adddata(context, 'message');
                                                      }
                                                    },
                                                    child: const Text(
                                                        'Single Speaker'),
                                                  ),
                                                ),
                                                DropdownMenuItem(
                                                  value: 'Option 2',
                                                  child: GestureDetector(
                                                    onTap: () async {
                                                      if (record['o2'] !=
                                                          null) {
                                                        Map<String, dynamic>?
                                                            data;
                                                        try {
                                                          data = json.decode(
                                                              record['o2']);
                                                          _showDialogforMultispeaker(
                                                              context, data!);
                                                        } catch (e) {
                                                          // Handle the FormatException here

                                                          data = {}; // or null
                                                        }
                                                      } else {
                                                        _datanotfound(
                                                            context,
                                                            record[
                                                                'input_source'],
                                                            record[
                                                                'meeting_id'],
                                                            false);
                                                        // SnackBarHelper
                                                        //     .showFailedInsertionSnackbar(
                                                        //         context,
                                                        //         'message');
                                                      }
                                                    },
                                                    child: const Text(
                                                        'Multi speaker'),
                                                  ),
                                                ),
                                                DropdownMenuItem(
                                                  value: 'Option 3',
                                                  child: GestureDetector(
                                                    onTap: () async {
                                                      if (record['o2'] !=
                                                          null) {
                                                        Map<String, dynamic>?
                                                            data;
                                                        try {
                                                          data = json.decode(
                                                              record['o2']);
                                                          _showDialogforMultispeakerpoitwise(
                                                              context, data!);
                                                        } catch (e) {
                                                          // Handle the FormatException here

                                                          data = {}; // or null
                                                        }
                                                      } else {
                                                        _datanotfound(
                                                            context,
                                                            record[
                                                                'input_source'],
                                                            record[
                                                                'meeting_id'],
                                                            false);
                                                        // SnackBarHelper
                                                        //     .showFailedInsertionSnackbar(
                                                        //         context,
                                                        //         'message');
                                                      }
                                                      //_showDialogforMultispeaker(context, record['o2']);
                                                    },
                                                    child: const Text(
                                                        'Multi speaker\n Point wise'),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                  const Divider()
                                ],
                              );
                            },
                          ),
                      ],
                    );
                  }
                }
              },
            ),
          ),
        ));
  }

  void _showDialogforMultispeaker(
      BuildContext context, Map<String, dynamic> data) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Message Details'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var message in data['messages'])
                  ListTile(
                    title: Text('${message['speaker']} (${message['start_time']})'),
                    subtitle: Text(message['text']),
                  ),
              ],
            ),
          ),
          actions: <Widget>[
            Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Close',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDialogforSinglespeaker(BuildContext context, String data) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Message Details'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(data),
              ],
            ),
          ),
          actions: <Widget>[
            ElevatedButton(
              onPressed: () async {
                // Open folder in file explorer
                await Process.run('explorer.exe', [data]);
              },
              child: Text('Open Folder'),
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

  void _showDialogforSinglespeaker_for_show_message(
      BuildContext context, String data) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Message Details'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(data.replaceAll('[', '').replaceAll(']', ''))
              ],
            ),
          ),
          actions: <Widget>[
            Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Close',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDialogforMultispeakerpoitwise(
      BuildContext context, Map<String, dynamic> data) {
    // Group messages by speaker
    Map<String, List<Map<String, dynamic>>> speakerMessages = {};
    for (var message in data['messages']) {
      String speaker = message['speaker'];
      if (!speakerMessages.containsKey(speaker)) {
        speakerMessages[speaker] = [];
      }
      speakerMessages[speaker]!.add(message);
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Message Details'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                for (var speaker in speakerMessages.keys)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          speaker,
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      for (var message in speakerMessages[speaker]!)
                        ListTile(
                          title: Text('${message['start_time']}'),
                          subtitle: Text(message['text']),
                        ),
                    ],
                  ),
              ],
            ),
          ),
          actions: <Widget>[
            Align(
              alignment: Alignment.center,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text(
                  'Close',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
          ],
        );
      },
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
            style:myBoldblackStyle
          ),
        );
      }
      return memberSpans;
    } catch (e) {

      return []; // Return empty list if there's an error decoding the JSON string
    }
  }

  void _datanotfound(BuildContext context, String filepath, String meeting_id,
      bool singlespeaker) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text(
            'Data not found !',
            style: TextStyle(color: Colors.red),
          ),
          content: const SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Data not found please process to show data'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
                onPressed: () {
                  // Check if the file exists
                  if (File(filepath).existsSync()) {
                    // File exists, so you can proceed with your logic

                    File file = File(filepath);
                    // Your code to handle the file...
                    Navigator.of(context).pop();
                    if (singlespeaker == true) {
                      sendAudioSingle(file, meeting_id);
                    } else {
                      SendAudioMultple(file, meeting_id);
                    }
                  } else {
                    SnackBarHelper.showFailedInsertionSnackbar(
                        context, 'File does not exist.');
                    // File does not exist, handle this case accordingly

                    // Your code to handle when the file doesn't exist...
                  }
                },
                child: const Text('Process')),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Close', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
