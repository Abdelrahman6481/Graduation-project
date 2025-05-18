import 'package:cloud_firestore/cloud_firestore.dart';

class Admin {
  final int id;
  final String name;
  final String email;
  final String password;
  final String phone;
  final String address;
  final DateTime lastLogin;

  Admin({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
    required this.address,
    required this.lastLogin,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id.toString(),
      'name': name,
      'email': email,
      'password': password,
      'phone': phone,
      'address': address,
      'lastLogin': lastLogin,
    };
  }

  factory Admin.fromMap(Map<String, dynamic> map) {
    return Admin(
      id: int.tryParse(map['id']?.toString() ?? '0') ?? 0,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      lastLogin:
          map['lastLogin'] != null
              ? (map['lastLogin'] as Timestamp).toDate()
              : DateTime.now(),
    );
  }
}

class Student {
  final int id;
  final String name;
  final String email;
  final String password;
  final String phone;
  final String address;
  final int level;
  final int credits;
  final String collegeName;
  final String major;
  final double gpa;
  final DateTime lastLogin;
  final int totalPoints;
  final List<Map<String, dynamic>>? academicResults;

  Student({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
    required this.address,
    required this.level,
    required this.credits,
    required this.collegeName,
    required this.major,
    required this.gpa,
    required this.lastLogin,
    this.totalPoints = 0,
    this.academicResults,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id.toString(),
      'name': name,
      'email': email,
      'password': password,
      'phone': phone,
      'address': address,
      'level': level,
      'credits': credits,
      'collegeName': collegeName,
      'major': major,
      'gpa': gpa,
      'lastLogin': lastLogin,
      'totalPoints': totalPoints,
      'academicResults': academicResults,
    };
  }

  factory Student.fromMap(Map<String, dynamic> map) {
    List<Map<String, dynamic>>? academicResultsList;
    if (map['academicResults'] != null) {
      academicResultsList = List<Map<String, dynamic>>.from(
        (map['academicResults'] as List).map(
          (item) => item is Map<String, dynamic> ? item : {},
        ),
      );
    }

    return Student(
      id: int.tryParse(map['id']?.toString() ?? '0') ?? 0,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      level: map['level'] ?? 0,
      credits: map['credits'] ?? 0,
      collegeName: map['collegeName'] ?? '',
      major: map['major'] ?? '',
      gpa: (map['gpa'] as num?)?.toDouble() ?? 0.0,
      lastLogin:
          map['lastLogin'] != null
              ? (map['lastLogin'] as Timestamp).toDate()
              : DateTime.now(),
      totalPoints: map['totalPoints'] ?? 0,
      academicResults: academicResultsList,
    );
  }

  Student copyWith({
    int? id,
    String? name,
    String? email,
    String? password,
    String? phone,
    String? address,
    int? level,
    int? credits,
    String? collegeName,
    String? major,
    double? gpa,
    DateTime? lastLogin,
    int? totalPoints,
    List<Map<String, dynamic>>? academicResults,
  }) {
    return Student(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      password: password ?? this.password,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      level: level ?? this.level,
      credits: credits ?? this.credits,
      collegeName: collegeName ?? this.collegeName,
      major: major ?? this.major,
      gpa: gpa ?? this.gpa,
      lastLogin: lastLogin ?? this.lastLogin,
      totalPoints: totalPoints ?? this.totalPoints,
      academicResults: academicResults ?? this.academicResults,
    );
  }
}

class Course {
  final int id;
  final String name;
  final String code;
  final int credits;
  final String instructor;
  final String description;
  final bool isActive;
  final List<Lecture>? lectures;
  final List<String>? prerequisites; // List of prerequisite course codes

  Course({
    required this.id,
    required this.name,
    required this.code,
    required this.credits,
    required this.instructor,
    required this.description,
    required this.isActive,
    this.lectures,
    this.prerequisites,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id.toString(),
      'name': name,
      'code': code,
      'credits': credits,
      'instructor': instructor,
      'description': description,
      'isActive': isActive,
      'lectures': lectures?.map((lecture) => lecture.toMap()).toList(),
      'prerequisites': prerequisites,
    };
  }

  factory Course.fromMap(Map<String, dynamic> map) {
    List<Lecture>? lecturesList;
    if (map['lectures'] != null) {
      lecturesList =
          (map['lectures'] as List)
              .map((lectureMap) => Lecture.fromMap(lectureMap))
              .toList();
    }

    List<String>? prerequisitesList;
    if (map['prerequisites'] != null) {
      prerequisitesList = List<String>.from(map['prerequisites']);
    }

    return Course(
      id: int.tryParse(map['id']?.toString() ?? '0') ?? 0,
      name: map['name'] ?? '',
      code: map['code'] ?? '',
      credits: map['credits'] ?? 0,
      instructor: map['instructor'] ?? '',
      description: map['description'] ?? '',
      isActive: map['isActive'] ?? false,
      lectures: lecturesList,
      prerequisites: prerequisitesList,
    );
  }
}

class Lecture {
  final String day;
  final String time;
  final String room;

  Lecture({required this.day, required this.time, required this.room});

  Map<String, dynamic> toMap() {
    return {'day': day, 'time': time, 'room': room};
  }

  factory Lecture.fromMap(Map<String, dynamic> map) {
    return Lecture(
      day: map['day'] ?? '',
      time: map['time'] ?? '',
      room: map['room'] ?? '',
    );
  }
}

class CourseRegistration {
  final int id;
  final int studentId;
  final int courseId;
  final DateTime registrationDate;
  final String status; // 'active', 'completed', 'dropped'

  CourseRegistration({
    required this.id,
    required this.studentId,
    required this.courseId,
    required this.registrationDate,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id.toString(),
      'studentId': studentId.toString(),
      'courseId': courseId.toString(),
      'registrationDate': registrationDate,
      'status': status,
    };
  }

  factory CourseRegistration.fromMap(Map<String, dynamic> map) {
    return CourseRegistration(
      id: int.tryParse(map['id']?.toString() ?? '0') ?? 0,
      studentId: int.tryParse(map['studentId']?.toString() ?? '0') ?? 0,
      courseId: int.tryParse(map['courseId']?.toString() ?? '0') ?? 0,
      registrationDate:
          map['registrationDate'] != null
              ? (map['registrationDate'] as Timestamp).toDate()
              : DateTime.now(),
      status: map['status'] ?? '',
    );
  }
}

class Attendance {
  final int id;
  final int studentId;
  final int courseId;
  final DateTime date;
  final bool isPresent;
  final String notes;

  Attendance({
    required this.id,
    required this.studentId,
    required this.courseId,
    required this.date,
    required this.isPresent,
    this.notes = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id.toString(),
      'studentId': studentId.toString(),
      'courseId': courseId.toString(),
      'date': date,
      'isPresent': isPresent,
      'notes': notes,
    };
  }

  factory Attendance.fromMap(Map<String, dynamic> map) {
    return Attendance(
      id: int.tryParse(map['id']?.toString() ?? '0') ?? 0,
      studentId: int.tryParse(map['studentId']?.toString() ?? '0') ?? 0,
      courseId: int.tryParse(map['courseId']?.toString() ?? '0') ?? 0,
      date:
          map['date'] != null
              ? (map['date'] as Timestamp).toDate()
              : DateTime.now(),
      isPresent: map['isPresent'] ?? false,
      notes: map['notes'] ?? '',
    );
  }
}

class Assignment {
  final int id;
  final int courseId;
  final String title;
  final String description;
  final DateTime dueDate;
  final int maxScore;

  Assignment({
    required this.id,
    required this.courseId,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.maxScore,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id.toString(),
      'courseId': courseId.toString(),
      'title': title,
      'description': description,
      'dueDate': dueDate,
      'maxScore': maxScore,
    };
  }

  factory Assignment.fromMap(Map<String, dynamic> map) {
    return Assignment(
      id: int.tryParse(map['id']?.toString() ?? '0') ?? 0,
      courseId: int.tryParse(map['courseId']?.toString() ?? '0') ?? 0,
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      dueDate:
          map['dueDate'] != null
              ? (map['dueDate'] as Timestamp).toDate()
              : DateTime.now(),
      maxScore: map['maxScore'] ?? 0,
    );
  }
}

class Submission {
  final String id;
  final String studentId;
  final String assignmentId;
  final String fileUrl;
  final DateTime submissionDate;
  final int? score;
  final String? feedback;

  Submission({
    required this.id,
    required this.studentId,
    required this.assignmentId,
    required this.fileUrl,
    required this.submissionDate,
    this.score,
    this.feedback,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId,
      'assignmentId': assignmentId,
      'fileUrl': fileUrl,
      'submissionDate': submissionDate,
      'score': score,
      'feedback': feedback,
    };
  }

  factory Submission.fromMap(Map<String, dynamic> map) {
    return Submission(
      id: map['id'],
      studentId: map['studentId'],
      assignmentId: map['assignmentId'],
      fileUrl: map['fileUrl'],
      submissionDate: (map['submissionDate'] as Timestamp).toDate(),
      score: map['score'],
      feedback: map['feedback'],
    );
  }
}

class Instructor {
  final int id;
  final String name;
  final String email;
  final String password;
  final String phone;
  final String address;
  final String academicDegree;
  final List<String>? assignedCourses; // Course IDs
  final DateTime lastLogin;

  Instructor({
    required this.id,
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
    required this.address,
    required this.academicDegree,
    this.assignedCourses,
    required this.lastLogin,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id.toString(),
      'name': name,
      'email': email,
      'password': password,
      'phone': phone,
      'address': address,
      'academicDegree': academicDegree,
      'assignedCourses': assignedCourses,
      'lastLogin': lastLogin,
    };
  }

  factory Instructor.fromMap(Map<String, dynamic> map) {
    List<String>? coursesList;
    if (map['assignedCourses'] != null) {
      coursesList = List<String>.from(map['assignedCourses']);
    }

    return Instructor(
      id: int.tryParse(map['id']?.toString() ?? '0') ?? 0,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      password: map['password'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      academicDegree: map['academicDegree'] ?? '',
      assignedCourses: coursesList,
      lastLogin:
          map['lastLogin'] != null
              ? (map['lastLogin'] as Timestamp).toDate()
              : DateTime.now(),
    );
  }
}

class StudentResult {
  final String id;
  final int studentId;
  final int courseId;
  final String courseName;
  final String courseCode;
  final int courseCredits;
  final double midtermGrade;
  final double finalGrade;
  final double assignmentsGrade;
  final double participationGrade;
  final double totalGrade;
  final String letterGrade;
  final DateTime updatedAt;
  final String notes;
  final String instructorId;
  final String instructorName;
  final String semester;
  final int academicYear;
  final bool isPublished;

  StudentResult({
    required this.id,
    required this.studentId,
    required this.courseId,
    this.courseName = '',
    this.courseCode = '',
    this.courseCredits = 0,
    this.midtermGrade = 0.0,
    this.finalGrade = 0.0,
    this.assignmentsGrade = 0.0,
    this.participationGrade = 0.0,
    this.totalGrade = 0.0,
    this.letterGrade = '',
    required this.updatedAt,
    this.notes = '',
    this.instructorId = '',
    this.instructorName = '',
    this.semester = '',
    this.academicYear = 0,
    this.isPublished = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'studentId': studentId.toString(),
      'courseId': courseId.toString(),
      'courseName': courseName,
      'courseCode': courseCode,
      'courseCredits': courseCredits,
      'midtermGrade': midtermGrade,
      'finalGrade': finalGrade,
      'assignmentsGrade': assignmentsGrade,
      'participationGrade': participationGrade,
      'totalGrade': totalGrade,
      'letterGrade': letterGrade,
      'updatedAt': updatedAt,
      'notes': notes,
      'instructorId': instructorId,
      'instructorName': instructorName,
      'semester': semester,
      'academicYear': academicYear,
      'isPublished': isPublished,
    };
  }

  factory StudentResult.fromMap(Map<String, dynamic> map) {
    return StudentResult(
      id: map['id'] ?? '',
      studentId: int.tryParse(map['studentId']?.toString() ?? '0') ?? 0,
      courseId: int.tryParse(map['courseId']?.toString() ?? '0') ?? 0,
      courseName: map['courseName'] ?? '',
      courseCode: map['courseCode'] ?? '',
      courseCredits: map['courseCredits'] ?? 0,
      midtermGrade: (map['midtermGrade'] as num?)?.toDouble() ?? 0.0,
      finalGrade: (map['finalGrade'] as num?)?.toDouble() ?? 0.0,
      assignmentsGrade: (map['assignmentsGrade'] as num?)?.toDouble() ?? 0.0,
      participationGrade:
          (map['participationGrade'] as num?)?.toDouble() ?? 0.0,
      totalGrade: (map['totalGrade'] as num?)?.toDouble() ?? 0.0,
      letterGrade: map['letterGrade'] ?? '',
      updatedAt:
          map['updatedAt'] != null
              ? (map['updatedAt'] as Timestamp).toDate()
              : DateTime.now(),
      notes: map['notes'] ?? '',
      instructorId: map['instructorId'] ?? '',
      instructorName: map['instructorName'] ?? '',
      semester: map['semester'] ?? '',
      academicYear: map['academicYear'] ?? 0,
      isPublished: map['isPublished'] ?? false,
    );
  }

  StudentResult copyWith({
    String? id,
    int? studentId,
    int? courseId,
    String? courseName,
    String? courseCode,
    int? courseCredits,
    double? midtermGrade,
    double? finalGrade,
    double? assignmentsGrade,
    double? participationGrade,
    double? totalGrade,
    String? letterGrade,
    DateTime? updatedAt,
    String? notes,
    String? instructorId,
    String? instructorName,
    String? semester,
    int? academicYear,
    bool? isPublished,
  }) {
    return StudentResult(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      courseId: courseId ?? this.courseId,
      courseName: courseName ?? this.courseName,
      courseCode: courseCode ?? this.courseCode,
      courseCredits: courseCredits ?? this.courseCredits,
      midtermGrade: midtermGrade ?? this.midtermGrade,
      finalGrade: finalGrade ?? this.finalGrade,
      assignmentsGrade: assignmentsGrade ?? this.assignmentsGrade,
      participationGrade: participationGrade ?? this.participationGrade,
      totalGrade: totalGrade ?? this.totalGrade,
      letterGrade: letterGrade ?? this.letterGrade,
      updatedAt: updatedAt ?? this.updatedAt,
      notes: notes ?? this.notes,
      instructorId: instructorId ?? this.instructorId,
      instructorName: instructorName ?? this.instructorName,
      semester: semester ?? this.semester,
      academicYear: academicYear ?? this.academicYear,
      isPublished: isPublished ?? this.isPublished,
    );
  }
}

class Payment {
  final int studentId;
  final String studentName;
  final double amountDue;
  final double amountPaid;
  final String status; // 'paid' or 'unpaid'
  final DateTime lastUpdated;

  Payment({
    required this.studentId,
    required this.studentName,
    required this.amountDue,
    required this.amountPaid,
    required this.status,
    required this.lastUpdated,
  });

  Map<String, dynamic> toMap() {
    return {
      'studentId': studentId.toString(),
      'studentName': studentName,
      'amountDue': amountDue,
      'amountPaid': amountPaid,
      'status': status,
      'lastUpdated': lastUpdated,
    };
  }

  factory Payment.fromMap(Map<String, dynamic> map) {
    return Payment(
      studentId: int.tryParse(map['studentId']?.toString() ?? '0') ?? 0,
      studentName: map['studentName'] ?? '',
      amountDue: (map['amountDue'] as num?)?.toDouble() ?? 0.0,
      amountPaid: (map['amountPaid'] as num?)?.toDouble() ?? 0.0,
      status: map['status'] ?? 'unpaid',
      lastUpdated:
          map['lastUpdated'] != null
              ? (map['lastUpdated'] as Timestamp).toDate()
              : DateTime.now(),
    );
  }
}
