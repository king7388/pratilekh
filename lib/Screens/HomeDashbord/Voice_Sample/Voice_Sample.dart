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

  List<String> sampletext = [
    'The quick brown fox jumps over the lazy dog, capturing everyone attention with its swift and graceful movements.',
    'She sells seashells by the seashore, collecting beautiful treasures from the sandy beach as the waves crash gently.',
    'Bright stars twinkled in the clear night sky, casting a serene glow over the tranquil countryside and its sleeping inhabitants.',
    'A curious cat climbed the tall tree, navigating the branches skillfully, while birds chirped melodiously from their nests.',
    'In the middle of the bustling city, a quiet park offered a peaceful escape, where people could relax and enjoy nature.',
  ];
  TextEditingController membername = TextEditingController();

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
                        memebersname = membername.text;
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
                                title: Column(
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
                                        Text(
                                          '${sampletext[index] ?? 'Title not available'}',
                                          style: TextStyleForVoiceSample,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: SizedBox(
                                  height:
                                      MediaQuery.of(context).size.height * 0.1,
                                  // Wrap the Row with a SizedBox
                                  width:
                                      MediaQuery.of(context).size.width * 0.26,
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
                                                    },
                                                  ),
                                                )
                                              : Costom_Recording(
                                                  onStop: (path) {
                                                    setState(() {
                                                      audioPath[index] =
                                                          File(path);
                                                      showPlayer[index] = true;
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
                                '${newDirectory.path}/${element.uri.pathSegments.last}';
                            if (File(newFilePath).existsSync()) {
                              // File already exists in destination folder, skip it
                              continue;
                            }
                            await element.copy(newFilePath);
                          }
                        }
                        DatabaseHelper.insertMember(
                            memebersname!, newDirectory.path);
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
