import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart' as sqflite_ffi;
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:uuid/uuid.dart';
import '../Models/MeetingsModel.dart';
import 'dart:io';

class DatabaseHelper {
  static late Database _database;

  static Future<Database> get database async {
    return _database;
  }

  static Future<void> initDatabase() async {
    // Initialize sqflite_ffi and set the database factory
    sqfliteFfiInit();
    sqflite_ffi.databaseFactory = databaseFactoryFfi;

    // Get the path for storing the database file
    var databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'meeting_database.db');

    try {
      // Open the database
      _database = await openDatabase(
        path,
        onCreate: (db, version) async {
          // Create the meetings table
          await db.execute('''
            CREATE TABLE meetings (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              meeting_id TEXT,
              title TEXT,
              codeNo TEXT,
              meeting_held TEXT,
              memberList TEXT,
              inviteMemberList TEXT,
              meetingDate TEXT,
              copyto TEXT
            )
          ''');

          // Create the meeting_records table
          await db.execute('''
            CREATE TABLE meeting_records (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              meeting_id TEXT,
              input_source TEXT,
              processed_date TEXT, 
              p1 INTEGER DEFAULT 0,
              p2 INTEGER DEFAULT 0,
              p3 INTEGER DEFAULT 0,
              o1 TEXT,
              o2 TEXT,
              o3 TEXT,
              m_o_m TEXT
            )
          ''');

          // Create the members table with unique name constraint
          await db.execute('''
            CREATE TABLE members (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              name TEXT UNIQUE,
              folder_name TEXT
            )
          ''');
        },
        version: 1,
        onOpen: (db) async {
          // Check if the audio_paths column exists, and add it if it doesn't
          var result = await db.rawQuery("PRAGMA table_info(members)");
          bool columnExists = result.any((column) => column['name'] == 'audio_paths');
          if (!columnExists) {
            await db.execute('''
              ALTER TABLE members ADD COLUMN audio_paths TEXT
            ''');
          }
        },
      );
      print('Database initialized');
    } catch (e) {
      print('Error initializing database: $e');
      // Handle initialization error, e.g., log it or throw an exception
      throw Exception('Failed to initialize database: $e');
    }
  }
  static Future<List<Map<String, dynamic>>> getAllMembers() async {
    try {
      if (_database == null) {
        await initDatabase();
      }
      return await _database.query('members');
    } catch (e) {
      print('Error fetching members: $e');
      return [];
    }
  }
  static Future<bool> deleteMember(int id) async {
    try {
      if (_database == null) {
        await initDatabase();
      }
      int result = await _database.delete(
        'members',
        where: 'id = ?',
        whereArgs: [id],
      );
      if (result > 0) {
        print('Member with id $id deleted successfully');
        return true;
      } else {
        print('No member found with id $id');
        return false;
      }
    } catch (e) {
      print('Error deleting member: $e');
      return false;
    }
  }


  static Future<bool> CheckinsertMember(String name, String folderName) async {
    try{
      // Ensure the database is initialized
      if (_database == null) {
        await initDatabase();
      }

      // Check if the record already exists
      final existingRecords = await _database.query(
        'members',
        where: 'name = ? AND folder_name = ?',
        whereArgs: [name, folderName],
      );
      if (existingRecords.isNotEmpty) {
        // Record already exists
        print('Record with name $name and folderName $folderName already exists.');
        return false; // Return false indicating insertion failed
      }else{
        return true;
      }
    }catch(e){
      return false;
    }
  }
  static Future<bool> insertMember(String name, String folderName, List<File?> audioFiles) async {
    try {
      // Convert the list of File? objects to a list of paths
      List<String> audioPaths = audioFiles.map((file) => file?.path ?? '').toList();

      // Convert the list of paths to a JSON string
      String audioPathsJson = jsonEncode(audioPaths);

      // Insert the member
      await _database.insert(
        'members',
        {
          'name': name,
          'folder_name': folderName,
          'audio_paths': audioPathsJson,
        },
        conflictAlgorithm: ConflictAlgorithm.fail,
      );

      print('Insert successful');
      return true;

    } catch (e) {
      print('Insert failed: $e');
      return false;
    }
  }
  static Future<Map<String, dynamic>?> getMemberById(int id) async {
    List<Map<String, dynamic>> result = await _database.query(
      'members',
      where: 'id = ?',
      whereArgs: [id],
    );
    return result.isNotEmpty ? result.first : null;
  }
  static Future<bool> updateMember(int id, String name, String folderName, List<File?> audioFiles) async {
    try {
      List<String> audioPaths = audioFiles.map((file) => file?.path ?? '').toList();
      String audioPathsJson = jsonEncode(audioPaths);

      await _database.update(
        'members',
        {
          'name': name,
          'folder_name': folderName,
          'audio_paths': audioPathsJson,
        },
        where: 'id = ?',
        whereArgs: [id],
      );

      return true;
    } catch (e) {
      return false;
    }
  }


static Future<List<String>> getColumns(String tableName) async {
    // Query the PRAGMA statement to get column information
    final List<Map<String, dynamic>> columns = await _database.rawQuery(
      "PRAGMA table_info($tableName);",
    );

    // Extract column names from the result
    List<String> columnNames = [];
    for (final column in columns) {
      columnNames.add(column['name'] as String);
    }

    return columnNames;
  }



  static Future<String?> insertOrUpdateMeeting({
    String? meetingID,
    required String title,
    required String codeNo,
    required String meeting_held,
    List<String>? memberList,
    List<String>? inviteMemberList,
    List<String>? copyto,
  }) async {
    try {
      String currentDate = DateFormat('dd-MM-yyyy HH:mm:ss').format(DateTime.now());

      if (meetingID != null) {
        // If meetingID is provided, check if a meeting with the given meetingID exists
        List<Map<String, dynamic>> existingMeetings = await _database.query(
          'meetings',
          where: 'meeting_id = ?',
          whereArgs: [meetingID],
        );

        if (existingMeetings.isNotEmpty) {
          // If the meeting already exists, update it
          return await updateMeeting(
            meetingID: meetingID,
            title: title,
            meeting_held: meeting_held,
            codeNo: codeNo,
            memberList: memberList,
            inviteMemberList: inviteMemberList,
            copyto: copyto,
          );
        }
      }

      // If meetingID is null or no matching meeting found, insert a new meeting
      meetingID ??= generateMeetingID(); // Generate a unique meeting ID if not provided

      // Convert lists to JSON strings
      String memberListJson = jsonEncode(memberList);
      String inviteMemberListJson = jsonEncode(inviteMemberList);
      String copytoJson = jsonEncode(copyto);

      // Insert data into the database
      await _database.insert('meetings', {
        'meeting_id': meetingID,
        'title': title,
        'meeting_held':meeting_held,
        'codeNo': codeNo,
        'memberList': memberListJson,
        'inviteMemberList': inviteMemberListJson,
        'meetingDate': currentDate,
        'copyto': copytoJson,
      });


      return meetingID; // Return the inserted or updated meeting ID
    } catch (e) {

      return null;
    }
  }
 static Future<List<Map<String, dynamic>>> getMeetingDataById(String meetingID) async {
    List<Map<String, dynamic>> results = await _database.query(
      'meetings',
      where: 'meeting_id = ?',
      whereArgs: [meetingID],
    );
    return results;
  }

  static Future<String?> updateMeeting({
    String? meetingID,
    required String title,
    required String codeNo,
    required String meeting_held,
    List<String>? memberList,
    List<String>? inviteMemberList,
    List<String>? copyto,
  }) async {
    try {
      // Convert lists to JSON strings
      String memberListJson = jsonEncode(memberList);
      String inviteMemberListJson = jsonEncode(inviteMemberList);
      String copytoJson = jsonEncode(copyto);

      // Update data in the database
      await _database.update('meetings', {
        'title': title,
        'meeting_held': meeting_held,
        'codeNo': codeNo,
        'memberList': memberListJson,
        'inviteMemberList': inviteMemberListJson,
        'copyto': copytoJson,
      }, where: 'meeting_id = ?', whereArgs: [meetingID]);


      return meetingID;
    } catch (e) {

      return null;
    }
  }



  // Function to generate a unique meeting ID
  static String generateMeetingID() {
    // Generate a random UUID (Universally Unique Identifier)
    // You can use any other unique ID generation method as well
    var uuid = Uuid();
    return uuid.v4();
  }

  static Future<List<Map<String, dynamic>>> getAllMeetings() async {
    // Retrieve all meeting data from the database
    return await _database.query('meetings');
  }


  static Future<bool> insertMeetingRecord(
      String meetingId,
      String inputSource,
      bool p1,
      bool p2,
      bool p3,
      String? o1,
      String? o2,
      String? o3,
      String? mom,
      String date,
      ) async {
    try {
      // Check if a record with the same meeting ID and input source exists
      final existingRecord = await _database.query(
        'meeting_records',
        where: 'meeting_id = ? AND input_source = ?',
        whereArgs: [meetingId, inputSource],
      );

      if (existingRecord.isNotEmpty) {
        // If a record exists, update it
        Map<String, dynamic> updateValues = {};
        if (date != null) updateValues['processed_date'] = date;
        if (p1 != null) updateValues['p1'] = p1 ? 1 : 0;
        if (p2 != null) updateValues['p2'] = p2 ? 1 : 0;
        if (p3 != null) updateValues['p3'] = p3 ? 1 : 0;
        if (o1 != null) updateValues['o1'] = o1;
        if (o2 != null) updateValues['o2'] = o2;
        if (o3 != null) updateValues['o3'] = o3;
        if (mom != null) updateValues['m_o_m'] = mom;

        if (updateValues.isNotEmpty) {
          await _database.update(
            'meeting_records',
            updateValues,
            where: 'meeting_id = ? AND input_source = ?',
            whereArgs: [meetingId, inputSource],
          );

        } else {

        }
      } else {
        // If no record exists, insert a new one
        await _database.insert(
          'meeting_records',
          {
            'meeting_id': meetingId,
            'input_source': inputSource,
            'processed_date': date,
            'p1': p1 ? 1 : 0,
            'p2': p2 ? 1 : 0,
            'p3': p3 ? 1 : 0,
            'o1': o1,
            'o2': o2,
            'o3': o3,
            'm_o_m': mom,
          },
        );

      }
      return true; // Return null if insertion or update is successful
    } catch (e) {

      return false; // Return the error message if insertion or update fails
    }
  }


  static Future<List<Map<String, dynamic>>> getAllMeetingRecords() async {
    List<Map<String, dynamic>> records =
        await _database.query('meeting_records');

    return records;
  }

  static Future<List<Map<String, dynamic>>?> getMeetingRecords(
      String meetingID) async {
    final Database db = await _database;
    try {
      List<Map<String, dynamic>> records = await db.query(
        'meeting_records',
        where: 'meeting_id = ?',
        whereArgs: [meetingID],
      );

      return records;
    } catch (e) {

      return null;
    }
  }

  static Future<Map<String, dynamic>> getMeetingDetailsAndRecords(
      String meetingID) async {
    final Database db = await _database;
    try {
      // Fetch meeting details
      List<Map<String, dynamic>> meetings = await db.query(
        'meetings',
        where: 'meeting_id = ?',
        whereArgs: [meetingID],
      );

      // Fetch meeting records
      List<Map<String, dynamic>> records = await db.query(
        'meeting_records',
        where: 'meeting_id = ?',
        whereArgs: [meetingID],
      );
      return {
        'meetingDetails': meetings.isNotEmpty ? meetings.first : null,
        'meetingRecords': records,
      };
    } catch (e) {
      return {
        'meetingDetails': null,
        'meetingRecords': [],
      };
    }
  }

}
