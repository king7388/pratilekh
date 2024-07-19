import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:pratilekh/Screens/HomeDashbord/Voice_Sample/Voice_Sample.dart';

import '../../../DataBase_Backend/Helpers/Helper.dart';
import '../../../Utils/Contants.dart';
import 'Edit_Sample.dart';

class All_Sample extends StatefulWidget {
  const All_Sample({Key? key}) : super(key: key);

  @override
  State<All_Sample> createState() => _All_SampleState();
}

class _All_SampleState extends State<All_Sample> {
  List<Map<String, dynamic>> _members = [];

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    List<Map<String, dynamic>> members = await DatabaseHelper.getAllMembers();
    setState(() {
      _members = List<Map<String, dynamic>>.from(members);
    });
  }

  // Future<void> _loadMembers() async {
  //   List<Map<String, dynamic>> members = await DatabaseHelper.getAllMembers();
  //   setState(() {
  //     _members = members;
  //   });
  // }

  Future<void> _deleteFolder(String folderPath) async {
    try {
      final directory = Directory(folderPath);
      if (await directory.exists()) {
        await directory.delete(recursive: true);
        print('Folder $folderPath deleted successfully');
      } else {
        print('Folder $folderPath does not exist');
      }
    } catch (e) {
      print('Error deleting folder: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 100.0, left: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'All Sample',
                    style: TextStyleForTitle,
                  ),
                  //ElevatedButton(onPressed: (){
                  // Navigator.push(context, MaterialPageRoute(builder: (context)=>Voice_Sample()));
                  // }, child: Text('Add Sample'),),
                ],
              ),
            ),
            if (_members.isEmpty)
              const Padding(
                padding: EdgeInsets.only(left: 28.0, top: 20),
                child: Text('No Data Found'),
              ),
            // Expanded(
            //   child: ListView.builder(
            //     itemCount: _members.length,
            //     itemBuilder: (context, index) {
            //       return Padding(
            //         padding: const EdgeInsets.only(right: 808.0),
            //         child: ListTile(
            //           title: Text(_members[index]['name']),
            //           subtitle: Text(_members[index]['folder_name']),
            //           trailing: IconButton(
            //             onPressed: () async {
            //               bool isDeleted = await DatabaseHelper.deleteMember(
            //                   _members[index]['id']);
            //               if (isDeleted) {
            //                 String folderPath = _members[index]['folder_name'];
            //                 setState(() {
            //                   _members.removeAt(index);
            //                 });
            //                 await _deleteFolder(folderPath);
            //
            //               }
            //
            //               // DatabaseHelper.deleteMember(_members[index]['id']);
            //               // setState(() {
            //               //
            //               // });
            //             },
            //             icon: Icon(Icons.delete),
            //           ),
            //           // Implement onTap if needed
            //         ),
            //       );
            //     },
            //   ),
            // ),
            Expanded(
              child: ListView.builder(
                itemCount: _members.length,
                itemBuilder: (context, index) {
                  return Column(
                    children: [
                      ListTile(
                        leading: Text(
                          '${index + 1}.',
                          style: TextStyleForTitle,
                        ),
                        title: RichText(
                          text: TextSpan(
                            children: [
                              const TextSpan(
                                text: 'Person Name :- ',
                                style: TextStyle(color: Colors.blue), // You can add more styling here
                              ),
                              TextSpan(
                                text: '${_members[index]['name']}',
                                style: TextStyle(color: Colors.black), // You can add more styling here
                              ),
                            ],
                          ),
                        )
                        ,
                        //subtitle: Text(_members[index]['folder_name']),
                        trailing: SizedBox(
                          // Wrap the Row with a SizedBox
                          width:
                              200, // Set the width according to your requirement
                          child: Row(
                            children: [
                              ElevatedButton(
                                onPressed: () async {
                                  Navigator.push(context, MaterialPageRoute(builder: (context)=>Voice_Sample_EditScreen(memberId: _members[index]['id'],)));
                                  // await Process.run('explorer.exe',
                                  //     [_members[index]['folder_name']]);
                                },
                                child: Text('View'),
                              ),
                              Spacer(),
                              ElevatedButton(
                                  onPressed: () async {
                                    showDeleteConfirmationDialog(
                                        context,
                                        _members[index]['id'],
                                        _members[index]['folder_name'],
                                        index);

                                    // DatabaseHelper.deleteMember(_members[index]['id']);
                                    // setState(() {
                                    //
                                    // });
                                  },
                                  child: Icon(Icons.delete))
                            ],
                          ),
                        ),
                      ),
                      Divider()
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> showDeleteConfirmationDialog(
      BuildContext context, var id, String path, var i) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Confirmation'),
          content: const SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Are you sure you want to delete this item?'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // dismiss the dialog
              },
            ),
            TextButton(
              child: Text('Delete'),
              onPressed: () async {
                bool isDeleted = await DatabaseHelper.deleteMember(id);
                if (isDeleted) {
                  String folderPath = path;
                  setState(() {
                    _members.removeAt(i);
                  });
                  await _deleteFolder(folderPath);
                }
                // Perform delete operation here
                Navigator.of(context).pop(); // dismiss the dialog
              },
            ),
          ],
        );
      },
    );
  }
}
