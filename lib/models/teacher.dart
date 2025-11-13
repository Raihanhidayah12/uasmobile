class Teacher {
  final int id;
  final String nip;
  final String name;
  final String subject;

  Teacher({required this.id, required this.nip, required this.name, required this.subject});

  factory Teacher.fromMap(Map<String, dynamic> map) => Teacher(
        id: map['id'],
        nip: map['nip'],
        name: map['name'],
        subject: map['subject'],
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'nip': nip,
        'name': name,
        'subject': subject,
      };
}
