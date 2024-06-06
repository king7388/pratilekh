import 'dart:async';
import 'dart:convert';
import 'dart:ui';
import 'package:flutter/services.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bootstrap5/flutter_bootstrap5.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:record_platform_interface/record_platform_interface.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../Record_Directory/audio_player.dart';
import '../../../Record_Directory/audio_recorder.dart';
import '../../../Utils/UI_HELPER.dart';
import '../../../Utils/Utils.dart';
import '../../../Utils/responsive.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/status.dart' as status;
import 'package:pdf/widgets.dart' as pw;


class Live_Transcripton_Screen extends StatefulWidget {
  @override
  State<Live_Transcripton_Screen> createState() => _Live_Transcripton_ScreenState();
}

class _Live_Transcripton_ScreenState extends State<Live_Transcripton_Screen> {

  bool isChecked1 = false;
  bool isChecked2 = false;
  bool isChecked3 = false;
  bool isChecked4 = false;
  bool isChecked5 = false;
  bool webshocket=false;
  Map<String, dynamic>? Data;
  String? data;
  bool showPlayer = false;
  File? audioPath;

  Map<String, dynamic> jsonData = {};

  ScrollController _controller = ScrollController();
  Future<void> pickAudio() async {
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
      });
    } else {
      // User canceled the picker
    }
  }

  void sendAudioSingle() async {
    webshocket=false;
    setState(() {

    });
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

        print('Response data type: ${response.runtimeType}');

        if (response.statusCode == 200) {
          print('Audio sent successfully');

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
          // Generate a unique filename
          String filename =
              'audio_${DateTime.now().millisecondsSinceEpoch.toString()}.txt';

          // Get the path for the desktop/documents directory
          String dir = '${Directory.systemTemp.path}/Documents/';

          // Create the directory if it doesn't exist
          Directory(dir).createSync(recursive: true);

          // Write the response body to a file
          File file = File('$dir$filename');
          await file.writeAsString(data.join('\n'));

          // Show a pop-up displaying the downloaded file's path
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
          print(
              'Failed to send audio. Status code: ${response.body.toString()}');
          return UI_Componenet.showError(
              context, '${response.body.toString()}');
        }
      } catch (e) {
        Utils.isloading = false;
        setState(() {});
        return UI_Componenet.showError(context, '${e.toString()}');
        print('Error sending audio: $e');
      }
    } else {
      return UI_Componenet.showAudio(
          context, 'Please select Audio File to proceed');
      print('Audio file is null. Please select an audio file first.');
    }
  }

  void SendAudioMultple() async {
    webshocket=false;
    setState(() {

    });
    // Get the path of the audio file if it is not null
    if (audioPath != null) {
      String audioFilePath = audioPath!.path;
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

      // Send the request
      try {
        Utils.isloading = true;
        UI_Componenet.scrollToBottom(_controller);
        setState(() {});
        var streamedResponse = await request.send();

        // Read response from stream
        var response = await http.Response.fromStream(streamedResponse);

        print('Response data type: ${response.runtimeType}');

        if (response.statusCode == 200) {
          Utils.isloading = false;
          print('Audio sent successfully');

          // Parse the JSON response
           jsonData = json.decode(response.body);

          setState(() {
            Data = jsonData;
          });

          setState(() {});
        } else {
          Utils.isloading = false;
          setState(() {});
          return UI_Componenet.showError(
              context, '${response.body.toString()}');
          print('Failed to send audio. Status code: ${response.statusCode}');
        }
      } catch (e) {
        Utils.isloading = false;
        setState(() {});
        return UI_Componenet.showError(context, "${e.toString()}");
        print('Error sending audio: $e');
      }
    } else {
      return UI_Componenet.showAudio(
          context, 'Please select Audio File to proceed');
      print('Audio file is null. Please select an audio file first.');
    }
  }

  final List<String> messages = [];
  late Uri wsUrl = Uri.parse('ws://localhost:8765');
   WebSocketChannel? channel;

  // void connectWeb() async {
  //   UI_Componenet.scrollToBottom(_controller);
  //   if (channel != null && channel!.sink != null && !channel!.sink!.close().) {
  //     // If channel is already connected, just add the message
  //     messages.add("Your message here");
  //     setState(() {
  //       isloading = false;
  //       webshocket = true;
  //       Navigator.pop(context);
  //     });
  //     print(messages);
  //   } else{
  //     channel = IOWebSocketChannel.connect(wsUrl);
  //     channel!.stream.listen((message) {
  //       if (!mounted) return; // Check if the widget is still mounted
  //       setState(() {
  //         messages.add(message);
  //         if(messages!=null){
  //           webshocket=true;
  //         }
  //       });
  //       print(messages);
  //     });
  //   }
  //
  // }
  bool isWebSocketConnected = false;

  void connectWeb() async {
    UI_Componenet.scrollToBottom(_controller);
    if (isWebSocketConnected) {
      Utils.isloading=true;
      setState(() {

      });
     channel!.stream.listen((message) {
       if (!mounted) return; // Check if the widget is still mounted
       setState(() {

         webshocket=true;

       });

     });
        webshocket = true;
      print(messages);
      Utils.isloading=false;
      setState(() {

      });
    } else {
      Utils.isloading=true;
      setState(() {

      });
      channel = IOWebSocketChannel.connect(wsUrl);
      channel!.stream.listen(
            (message) {
          if (!mounted) return; // Check if the widget is still mounted
            messages.add(message);
            webshocket=true;
          print(messages);
          Utils.isloading=false;
          setState(() {});
        },
        onError: (error) {
          // Handle errors
          print('WebSocket error: $error');
        },
        onDone: () {
          // Handle close event
          print('WebSocket closed');

          Utils.isloading=false;
          isWebSocketConnected = false; // Reset connection flag
          setState(() {

          });
        },
      );
      isWebSocketConnected = true; // Set connection flag
    }
  }



  void disconnectWeb() {
    if (channel != null && channel!.sink != null) {
      channel!.sink.close();
      messages.clear();
      webshocket = false;
      setState(() {
        Utils.isloading = false;
      });
      print("WebSocket disconnected successfully.");
    } else {
      print("WebSocket channel is not initialized.");
    }
  }


  // void disconnectWeb() {
  //   final wsUrl = Uri.parse('ws://localhost:8080');
  //   final channel = WebSocketChannel.connect(wsUrl);
  //   channel.sink.close(status.goingAway);
  // }



  List<dynamic>? worldfiledata;
  ///

  ///
  Future<void> _saveMessages(Map<String, dynamic> jsonData) async {
    // Create a directory to store files
    Directory? documentsDirectory = await getDownloadsDirectory();
    String? documentsPath = documentsDirectory?.path;
    String speakersFolderPath =
        '$documentsPath/speakers${DateTime.now().millisecondsSinceEpoch.toString()}';
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
          String speakerFolderPath = '$speakersFolderPath/$speaker';
          Directory(speakerFolderPath).createSync(recursive: true);

          // Create a file for speaker's messages
          File file = File('$speakerFolderPath/messages.txt');
          await file.writeAsString(speakerMessages[speaker]!.join('\n'));
        }
      }
      else if (isChecked3 == false) {
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
        File file = File('$speakerFolderPath$filename');
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

  Future<void> _handleResponseDataAndSaveAsPdf(Map<String, dynamic> jsonData) async {
    // Extract messages from JSON data
    List<dynamic> messages = jsonData['messages'];
    if(isChecked3==false){

      List<String> allMessages = [];

    // Combine all messages into a single list
    for (var message in messages) {
      if (message['speaker'] != null &&
          message['text'] != null &&
          message['time'] != null) {
        String messageText = '${message['speaker']} (${message['time']}): ${message['text']}';
        allMessages.add(messageText);
      }
    }

    // Generate a unique folder name based on the current timestamp
    final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
    final folderName = 'messages_$timestamp';

    // Get the directory for saving the PDF
    final Directory? documentsDirectory = await getDownloadsDirectory();
    final String? documentsPath = documentsDirectory?.path;
    final folderPath = '$documentsPath/$folderName';

    // Create a directory for saving the PDF files
    final folder = Directory(folderPath);
    await folder.create();

    // Save all messages in a single PDF file
    final pdf = pw.Document();

    // Add pages to the PDF for all messages
    for (int i = 0; i < allMessages.length; i += 40) {
      final pageMessages = allMessages.sublist(i, i + 40 < allMessages.length ? i + 40 : allMessages.length);
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
    final pdfFilename = 'all_messages.pdf';
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
    }
    else if(isChecked3==true){
      Map<String, List<String>> speakerMessages = {};

      // Generate a unique folder name based on the current timestamp
      final timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final folderName = 'messages_$timestamp';

      // Get the directory for saving the PDF
      final Directory? documentsDirectory = await getDownloadsDirectory();
      final String? documentsPath = documentsDirectory?.path;
      final folderPath = '$documentsPath/$folderName';

      // Create a directory for saving the PDF files
      final folder = Directory(folderPath);
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
          speakerMessages[speaker]!.add('${message['speaker']} (${message['time']}): ${message['text']}');
        }
      }

      // Save messages in PDF files
      for (var entry in speakerMessages.entries) {
        final speaker = entry.key;
        final messages = entry.value;

        final pdf = pw.Document();

        // Add pages to the PDF for each speaker's messages
        for (int i = 0; i < messages.length; i += 20) {
          final pageMessages = messages.sublist(i, i + 20 < messages.length ? i + 20 : messages.length);
          pdf.addPage(
            pw.Page(
              build: (pw.Context context) {
                return pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    pw.Text(speaker, style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                    pw.SizedBox(height: 5), // Add space between speaker name and messages
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
                  Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text(
                      'Speaker: $speaker',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Spacer(),
                  SizedBox(
                    width: MediaQuery.of(context).size.width * 0.3,
                    height: MediaQuery.of(context).size.height*0.06,
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
                // Save changes made to speaker names
                Data['messages'].forEach((message) {
                  String oldSpeaker = message['speaker'];
                  String newSpeaker =
                      textEditingControllers[oldSpeaker]?.text ?? oldSpeaker;
                  message['speaker'] = newSpeaker;
                });
                // Convert the modified Data to JSON
                worldfiledata = Data['messages'];

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
        print('Response from server: $responseBody');
        if(responseBody['message']==true){
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
                      await Process.run('explorer.exe', [responseBody['file_path']]);
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
        }else{
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

        print('Data sent successfully.');
      } else {
        print('Failed to send data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error sending data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 50.0, right: 50),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 28.0),
              child: Column(
                children: [
                  const Text(
                    "Live Transcription  ( Output : Immediate Output )",
                    style: TextStyle(
                        fontSize: 20,
                        color: Color(0xFF8591B0),
                        fontWeight: FontWeight.bold,
                        fontFamily: "Montserrat-Regular"),
                  ),
                  const SizedBox(
                    height: 32,
                  ),
                  Stack(
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            // You can add any necessary state changes here
                          });
                          if (isWebSocketConnected) {
                            disconnectWeb();
                          } else {
                            connectWeb();
                          }
                        },
                        style: ButtonStyle(
                          backgroundColor: MaterialStateProperty.resolveWith<Color>((states) {
                            if (states.contains(MaterialState.pressed)) {
                              // When button is pressed
                              return isWebSocketConnected ? Colors.red.shade700 : Colors.green.shade700;
                            }
                            // Default color
                            return isWebSocketConnected ? Colors.red : Colors.green;
                          }),
                        ),
                        child: Text(isWebSocketConnected ? 'Stop Record' : 'Start Record', style: TextStyle(color: Colors.white)),
                      ),
                      if (Utils.isloading)
                        Positioned.fill(
                          child: Container(
                            color: Colors.red,
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Please wait',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            if (isChecked3 == true || isChecked2==true) ..._buildSpeakerTextFields(Data),
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
            if(webshocket==false)
            UI_Componenet.Costom_Container_output(context, Data),
            if(webshocket==true)
              // StreamBuilder(
              //   stream: channel!.stream,
              //   builder: (context, snapshot) {
              //     if (snapshot.connectionState == ConnectionState.waiting) {
              //       return CircularProgressIndicator();
              //     } else if (snapshot.hasError) {
              //       return Text('Error: ${snapshot.error}');
              //     } else {
              //       if(snapshot.hasData) {
              //         // Add the new message to the list
              //         messages.add(snapshot.data.toString());
              //       }
              //
              //       // Build the chat UI
              //       return Column(
              //         children: [
              //           Expanded(
              //             child: SingleChildScrollView(
              //               child: Column(
              //                 crossAxisAlignment: CrossAxisAlignment.stretch,
              //                 children: messages.map((message) {
              //                   return Padding(
              //                     padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              //                     child: Container(
              //                       padding: EdgeInsets.all(12.0),
              //                       decoration: BoxDecoration(
              //                         color: Colors.grey[300],
              //                         borderRadius: BorderRadius.circular(8.0),
              //                       ),
              //                       child: Text(
              //                         message,
              //                         style: TextStyle(fontSize: 16.0),
              //                       ),
              //                     ),
              //                   );
              //                 }).toList(),
              //               ),
              //             ),
              //           ),
              //           // Additional UI components can go here
              //         ],
              //       );
              //     }
              //   },
              // ),
            UI_Componenet.Costom_Webshocekt_Ui(context, messages.toString()),
            if (isChecked3 == true || isChecked2==true)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 700.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(onPressed: () {
                    if (jsonData['messages'] != null) {
                      _handleResponseDataAndSaveAsPdf(jsonData);
                    }
                  }, child: Text('Save As PDF')),
                  ElevatedButton(onPressed: () {
                    sendDatatoSaveInWorldFile();
                  }, child: Text('Save As Word')),
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
            )
          ],
        ),
      ),
    );
  }
}





