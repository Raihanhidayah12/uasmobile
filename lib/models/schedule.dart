class Schedule {
  final int id;
  final String day;
  final String time;
  final String subject;
  final int teacherId;

  Schedule({required this.id, required this.day, required this.time, required this.subject, required this.teacherId});

  factory Schedule.fromMap(Map<String, dynamic> map) => Schedule(
        id: map['id'],
        day: map['day'],
        time: map['time'],
        subject: map['subject'],
        teacherId: map['teacher_id'],
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'day': day,
        'time': time,
        'subject': subject,
        'teacher_id': teacherId,
      };
}
