import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart'; // Import audioplayers package
import 'package:google_fonts/google_fonts.dart';
import '../../../DataBase_Backend/Helpers/Helper.dart';
import '../../../Record_Directory/Costom_Recording.dart';
import '../../../Record_Directory/Costom_player.dart';
import '../../../Utils/Contants.dart';
import '../../../Utils/UI_HELPER.dart';

class Voice_Sample_EditScreen extends StatefulWidget {
  final int memberId; // Member ID passed from previous screen

  const Voice_Sample_EditScreen({Key? key, required this.memberId})
      : super(key: key);

  @override
  State<Voice_Sample_EditScreen> createState() =>
      _Voice_Sample_EditScreenState();
}

class _Voice_Sample_EditScreenState extends State<Voice_Sample_EditScreen> {
  TextEditingController memberNameController = TextEditingController();
  List<File?> audioFiles = [null, null, null, null, null];

  String pratlekhPath = "C:\\Pratilekh"; // Adjust this as necessary

  @override
  void initState() {
    super.initState();

    _loadMemberDetails();
  }
var folderpath;
  Future<void> _loadMemberDetails() async {
    // Fetch member details using the member ID received from previous screen
    Map<String, dynamic>? member =
        await DatabaseHelper.getMemberById(widget.memberId);
    if (member != null) {
      memberNameController.text = member['name'];
      memebersname=memberNameController.text;
      folderpath=member['folder_name'];
      // Decode JSON string to List<String>
      List<String> audioPaths =
          List<String>.from(jsonDecode(member['audio_paths']));

      setState(() {
        // Convert paths to File objects
        audioFiles = audioPaths.map((path) => File(path)).toList();
        print(audioPaths);
      });
    } else {
      _showDialog('Error', 'Member not found');
    }
  }

  // Future<void> _updateMember() async {
  //   String memberName = memberNameController.text;
  //   if (memberName.isNotEmpty && !audioFiles.contains(null)) {
  //     bool success = await DatabaseHelper.updateMember(
  //         widget.memberId, memberName, pratlekhPath, audioFiles);
  //     if (success) {
  //       _showDialog('Success', 'Member updated successfully');
  //       memberNameController.clear();
  //       setState(() {
  //         audioFiles = [null, null, null, null, null];
  //       });
  //     } else {
  //       print('Error Failed to update member');
  //       _showDialog('Error', 'Failed to update member');
  //     }
  //   } else {
  //     _showDialog('Error', 'Please provide all details');
  //   }
  // }

  void _showDialog(String title, String content) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(content),
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
  }

  @override
  void dispose() {
    super.dispose();
  }

  String? memebersname;
  List<String> sampletext = [
    'The quick brown fox jumps over the lazy dog, capturing everyone attention with its swift and graceful movements.',
    'She sells seashells by the seashore, collecting beautiful treasures from the sandy beach as the waves crash gently.',
    'Bright stars twinkled in the clear night sky, casting a serene glow over the tranquil countryside and its sleeping inhabitants.',
    'A curious cat climbed the tall tree, navigating the branches skillfully, while birds chirped melodiously from their nests.',
    'In the middle of the bustling city, a quiet park offered a peaceful escape, where people could relax and enjoy nature.',
  ];
  List<bool> showPlayer = [true, true, true, true, true];

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
              padding: EdgeInsets.only(top: 50, right: 16, left: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(left: 20.0, bottom: 10),
                            child: Text(
                              'Member Name',
                              style: myBoldBlueStyle,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 20),
                            child: SizedBox(
                              height: 40,
                              width: 500,
                              child: Container(
                                decoration: containerDecorationgrayoutline,
                                child: TextFormField(
                                  cursorHeight: 20,
                                  controller: memberNameController,
                                  decoration: const InputDecoration(
                                    contentPadding:
                                        EdgeInsets.only(bottom: 5, left: 5),
                                    border: InputBorder.none,
                                  ),
                                  onChanged: (value) {
                                    memebersname = memberNameController.text;
                                  },
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Row(
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * .65,
                        width: MediaQuery.of(context).size.width * .88,
                        child: ListView.builder(
                          itemCount: sampletext.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(15)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey
                                          .withOpacity(0.5), // Shadow color
                                      spreadRadius: 5, // Spread radius
                                      blurRadius: 10, // Blur radius
                                      offset: const Offset(
                                          0, 2), // Offset in the y-axis
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
                                                    style: TextStyle(
                                                        color: Colors.red),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                Text(
                                                  '${sampletext[index] ?? 'Title not available'}',
                                                  style:
                                                      TextStyleForVoiceSample,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                        trailing: SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              0.1,
                                          // Wrap the Row with a SizedBox
                                          width: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              0.26,
                                          child: Row(
                                            children: [
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.2,
                                                child: Center(
                                                  child: showPlayer[index]
                                                      ? Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      25),
                                                          child: Costom_Player(
                                                            source: audioFiles[
                                                                    index]!
                                                                .path ?? '',
                                                            onDelete: () {
                                                              setState(() =>
                                                                  showPlayer[
                                                                          index] =
                                                                      false);
                                                              audioFiles[index] = null;  // Set the audioPath to null on delete
                                                            },
                                                          ),
                                                        )
                                                      : Costom_Recording(
                                                          onStop: (path) {
                                                            setState(() {
                                                              audioFiles[
                                                                      index] =
                                                                  File(path);
                                                              showPlayer[
                                                                  index] = true;
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
                ],
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                if (memebersname != null) {
                  bool anyPathIsNull =
                      audioFiles.any((element) => element == null);

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
                    // String pratlekhPath = 'your_pratlekh_path_here';
                    // String membersName = 'new_folder_name';
                    // String folderPath = '${pratlekhPath}\\Voice_Sample\\${member['folder_name']}';
                    String newFolderPath = '${pratlekhPath}\\Voice_Sample\\$memebersname';
                    // All paths are not null, proceed to save files
                    final oldDirectory = Directory(folderpath);
                    final newDirectory = Directory(newFolderPath);

                    if (await oldDirectory.exists()) {
                      await oldDirectory.rename(newFolderPath);
                      print('Folder renamed to $newFolderPath');
                    } else {
                      print('The folder $folderpath does not exist');
                    }
                    try {

                        for (var element in audioFiles) {
                          if (element != null && await element.exists()) {
                            final success =
                                _deleteFilesInDirectory(newDirectory.path);
                            if (await success) {

                              for (var element in audioFiles) {
                                if (element != null && await element.exists()) {
                                  final newFilePath =
                                      '${newDirectory.path}\\${element.uri.pathSegments.last}';
                                  if (File(newFilePath).existsSync()) {
                                    // File already exists in destination folder, skip it
                                    continue;
                                  }
                                  await element.copy(newFilePath);
                                  // Assuming `audioPath` and `newDirectory` are already defined
                                 // await copyAndSaveNewPaths(audioPath, newDirectory);

// Now `audioPath` contains the new paths

                                }
                              }
                              //await element.copy(newFilePath.path);
                              bool success = await DatabaseHelper.updateMember(
                                  widget.memberId,
                                  memebersname!,
                                  newDirectory.path,
                                  audioFiles);
                              if (await success) {
                                // audioFiles = [null, null, null, null, null];
                                // showPlayer = [
                                //   false,
                                //   false,
                                //   false,
                                //   false,
                                //   false
                                // ];
                                // memberNameController.clear();

                                setState(() {});
                              }
                            }
                          } else {
                            _showDialog('File !', "File not Found");
                          }
                        }
                        _showDialog('Success !', "File Updated Successfully");
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
              child: Text('Update Member'),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _deleteFilesInDirectory(String directoryPath) async {
    Directory directory = Directory(directoryPath);
    if (await directory.exists()) {
      try {
        await for (FileSystemEntity entity in directory.list()) {
          if (entity is File) {
            print(entity);
            await entity.delete();
          }
        }
        return true; // Return true if all files were successfully deleted
      } catch (e) {
        print('Error deleting files: $e');
        return false; // Return false if there was an error deleting files
      }
    } else {
      return true; // Return true if directory doesn't exist (considered success)
    }
  }
}
