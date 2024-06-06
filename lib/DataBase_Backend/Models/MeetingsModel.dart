import 'dart:convert';

class Meeting {
  int? id;
  String? meetingID;
  String title;
  String codeNo;
  List<String>? memberList;
  List<String>? inviteMemberList;
  DateTime? meetingDate;
  List<String>? copyto;

  Meeting({
    this.id,
    this.meetingID,
    required this.title,
    required this.codeNo,
    this.memberList,
    this.inviteMemberList,
    this.meetingDate,
    this.copyto,
  });

  factory Meeting.fromJson(Map<String, dynamic> json) {
    DateTime parsedMeetingDate = _parseMeetingDate(json['meetingDate']);

    return Meeting(
      id: json['id'],
      meetingID: json['meeting_id'],
      title: json['title'],
      codeNo: json['codeNo'],
      memberList: json['memberList'] != null ? (json['memberList'] as String).split(',') : null,
      inviteMemberList: json['inviteMemberList'] != null ? (json['inviteMemberList'] as String).split(',') : null,
      meetingDate: json['meetingDate'] != null ? parsedMeetingDate : null,
      copyto: json['copyto'] != null ? (json['copyto'] as String).split(',') : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'meeting_id': meetingID,
    'title': title,
    'codeNo': codeNo,
    'memberList':
    memberList != null ? jsonEncode(memberList) : jsonEncode([]),
    'inviteMemberList': inviteMemberList != null
        ? jsonEncode(inviteMemberList)
        : jsonEncode([]),
    'meetingDate': meetingDate?.toIso8601String(),
    'copyto': copyto != null ? jsonEncode(copyto) : jsonEncode([]),
  };
  static DateTime _parseMeetingDate(String dateString) {
    // Custom date parsing logic
    List<String> parts = dateString.split(' ');
    List<String> dateParts = parts[0].split('-');
    List<String> timeParts = parts[1].split(':');
    int year = int.parse(dateParts[2]);
    int month = int.parse(dateParts[1]);
    int day = int.parse(dateParts[0]);
    int hour = int.parse(timeParts[0]);
    int minute = int.parse(timeParts[1]);
    int second = int.parse(timeParts[2]);
    return DateTime(year, month, day, hour, minute, second);
  }
}
