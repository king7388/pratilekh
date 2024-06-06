class MeetingRecord {
  final int? id;
  final String meetingId;
  final String inputSource;
  final String processOption;
  final String processOutput;

  MeetingRecord({
    this.id,
    required this.meetingId,
    required this.inputSource,
    required this.processOption,
    required this.processOutput,
  });

  // Convert a MeetingRecord object into a Map for database operations
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'meeting_id': meetingId,
      'input_source': inputSource,
      'process_option': processOption,
      'process_output': processOutput,
    };
  }

  // Convert a Map object from the database into a MeetingRecord object
  factory MeetingRecord.fromMap(Map<String, dynamic> map) {
    return MeetingRecord(
      id: map['id'],
      meetingId: map['meeting_id'],
      inputSource: map['input_source'],
      processOption: map['process_option'],
      processOutput: map['process_output'],
    );
  }
}
