import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

import '../../../DataBase_Backend/Helpers/Helper.dart';
import '../../../Record_Directory/Costom_Recording.dart';
import '../../../Record_Directory/Costom_player.dart';
import '../../../Record_Directory/audio_player.dart';
import '../../../Record_Directory/audio_recorder.dart';
import '../../../Utils/Contants.dart';
import '../../../Utils/UI_HELPER.dart';

class Voice_Sample extends StatefulWidget {
  const Voice_Sample({super.key});

  @override
  State<Voice_Sample> createState() => _Voice_SampleState();
}

class _Voice_SampleState extends State<Voice_Sample> {
  //bool showPlayer = false;
  List<bool> showPlayer = [false, false, false, false, false];

  List<File?> audioPath = [
    null,
    null,
    null,
    null,
    null,
  ];
  List<File?> newPath=[];
  List<String> sampletext = [
    'The Indian Army is one of the largest and most powerful military forces in the world. It plays a vital role in protecting the country`s borders and sovereignty.',
    'The army uses advanced technology like drones and satellite imagery to keep an eye on border areas and detect any unauthorized movements or intruders.',
    'The army conducts regular patrols along the borders and maintains a network of outposts and bunkers to ensure constant vigilance against intruders.',
    'By employing a combination of technology, training, and teamwork, the Indian Army ensures the safety and security of the nation’s borders',
    'The army`s primary focus is on maintaining the country`s territorial integrity and preventing any unauthorized access, keeping the nation safe from external threats.',
  ];
  TextEditingController membername = TextEditingController();
  Future<void> copyAndSaveNewPaths(List<File?> audioPath, Directory newDirectory) async {
    List<File?> newAudioPath = [];

    for (var element in audioPath) {
      if (element != null && await element.exists()) {
        final newFilePath = '${newDirectory.path}\\${element.uri.pathSegments.last}';

        // If the file already exists in the destination folder, skip copying
        if (!File(newFilePath).existsSync()) {
          await element.copy(newFilePath);
        }

        // Add the new file to the list
        newAudioPath.add(File(newFilePath));
      } else {
        // If the element is null, add null to maintain the same structure
        newAudioPath.add(null);
      }
    }

    // Update the audioPath with new paths
    audioPath.clear();
    audioPath.addAll(newAudioPath);
  }


  // void _startRecording() {
  //
  //   // Add your recording start logic here
  //   // For example, you might use the Recorder's start method directly
  //   // Set the state to update the UI
  //   setState(() {
  //     showPlayer[index] = false;
  //   });
  // }
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
    // TODO: implement initState
    super.initState();
  }

  String? memebersname;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const SizedBox(
            height: 100,
          ),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 20.0),
                child: Text(
                  AppString.membername,
                  style: TextStyleForTitle,
                ),
              ),
            ],
          ),
          Row(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
                child: SizedBox(
                  height: 40,
                  width: 500,
                  child: Container(
                    decoration: containerDecorationgrayoutline,
                    child: TextFormField(
                      cursorHeight: 20,
                      controller: membername,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.only(bottom: 5, left: 5),
                        border: InputBorder.none,
                      ),
                      onChanged: (value) {
                      //  memebersname = membername.text;
                        memebersname = value.trim();
                      },
                    ),
                  ),
                ),
              ),
            ],
          ),
          Row(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * .7,
                width: MediaQuery.of(context).size.width * .88,
                child: ListView.builder(
                  itemCount: sampletext.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(15)),
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
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              ListTile(
                                leading: Text(
                                  '${index + 1}.',
                                  style: TextStyleForTitle,
                                  maxLines: 2,
                                ),
                                title: SizedBox(
                                  width:  MediaQuery.of(context).size.width * 0.7,
                                  child: Column(
                                    children: [
                                      const Row(
                                        children: [
                                          Padding(
                                            padding: EdgeInsets.all(8.0),
                                            child: Text(
                                              'Read this content when recording start.',
                                              style: TextStyle(color: Colors.red),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Text(
                                              '${sampletext[index] ?? 'Title not available'}',
                                              style: TextStyleForVoiceSample,
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),

                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                trailing: SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.1,
                                  // Wrap the Row with a SizedBox
                                  width:
                                      MediaQuery.of(context).size.width * 0.20,
                                  child: Row(
                                    children: [
                                      SizedBox(
                                        width:
                                            MediaQuery.of(context).size.width *
                                                0.2,
                                        child: Center(
                                          child: showPlayer[index]
                                              ? Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 25),
                                                  child: Costom_Player(
                                                    source:
                                                        audioPath[index]!.path,
                                                    onDelete: () {
                                                      setState(() =>
                                                          showPlayer[index] =
                                                              false);
                                                      audioPath[index] = null; // Set the audioPath to null on delete
                                                    },
                                                  ),
                                                )
                                              : Costom_Recording(
                                                  onStop: (path) {
                                                    setState(() {
                                                      audioPath[index] =
                                                          File(path);
                                                      showPlayer[index] = true;
                                                      print(File(path));
                                                    });
                                                  },
                                                ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
          ElevatedButton(
              onPressed: () async {
                if (memebersname != null) {
                  bool anyPathIsNull =
                      audioPath.any((element) => element == null);

                  if (anyPathIsNull) {
                    // Show error dialog if any path is null
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Error'),
                          content: const Text('Please provide all Samples.'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('OK'),
                            ),
                          ],
                        );
                      },
                    );
                  } else {
                    // All paths are not null, proceed to save files
                    final newDirectory = Directory(
                        '${pratlekhpath}\\Voice_Sample\\$memebersname');
                    if (!await newDirectory.exists()) {
                      await newDirectory.create(recursive: true);
                    }

                    try {
                      final checked = DatabaseHelper.CheckinsertMember(
                          memebersname!, newDirectory.path);
                      if (await checked) {
                        for (var element in audioPath) {
                          if (element != null && await element.exists()) {
                            final newFilePath =
                                '${newDirectory.path}\\${element.uri.pathSegments.last}';
                            if (File(newFilePath).existsSync()) {
                              // File already exists in destination folder, skip it
                              continue;
                            }
                            //await element.copy(newFilePath);
                            // Assuming `audioPath` and `newDirectory` are already defined
                            await copyAndSaveNewPaths(audioPath, newDirectory);

// Now `audioPath` contains the new paths

                          }
                        }
                      final success=  DatabaseHelper.insertMember(
                            memebersname!, newDirectory.path,audioPath);
                        if(await success){
                          audioPath = [null, null, null, null, null];
                          showPlayer = [false, false, false, false, false];
                          membername.clear();
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Success'),
                                content: const Text(
                                    'Member sample added successfully'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('OK'),
                                  ),
                                ],
                              );
                            },
                          );
                          setState(() {});
                        }


                      } else {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: const Text('Error'),
                              content: const Text(
                                  'Member Already Exist Please change name'),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('OK'),
                                ),
                              ],
                            );
                          },
                        );
                      }
                    } catch (e) {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            title: const Text('Error'),
                            content: Text(e.toString()),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('OK'),
                              ),
                            ],
                          );
                        },
                      );
                    }
                  }
                } else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Error'),
                        content: const Text('Please Enter Member Name..'),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: const Text('OK'),
                          ),
                        ],
                      );
                    },
                  );
                }
              },
              child: const Text('Submit'))
        ],
      ),
    );
  }
}
