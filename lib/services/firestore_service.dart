import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/firestore_models.dart';
import 'package:flutter/foundation.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Helper method to validate numeric ID
  bool _isValidNumericId(String id) {
    return RegExp(r'^\d+$').hasMatch(id);
  }

  // Helper method to validate and convert ID
  String _validateAndConvertId(dynamic id) {
    if (id is int) {
      return id.toString();
    }
    if (id is String) {
      return id;
    }
    throw FormatException('ID must be a numeric value or string');
  }

  // Admin Operations
  Future<void> createAdmin({
    required int id,
    required String name,
    required String email,
    required String password,
    required String phone,
    required String address,
  }) async {
    await _firestore.collection('admins').doc(id.toString()).set({
      'id': id,
      'name': name,
      'email': email,
      'password': password,
      'phone': phone,
      'address': address,
      'lastLogin': FieldValue.serverTimestamp(),
    });
  }

  Future<Admin?> getAdmin(int adminId) async {
    try {
      final docId = _validateAndConvertId(adminId);
      final doc = await _firestore.collection('admins').doc(docId).get();
      return doc.exists ? Admin.fromMap(doc.data()!) : null;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('Error getting admin: $e');
      }
      rethrow;
    }
  }

  // Student Operations
  Future<void> createStudent(Student student) async {
    try {
      final docId = _validateAndConvertId(student.id);
      await _firestore.collection('students').doc(docId).set(student.toMap());
    } catch (e) {
      print('Error creating student: $e');
      rethrow;
    }
  }

  Future<Student?> getStudent(int studentId) async {
    try {
      final docId = _validateAndConvertId(studentId);
      final doc = await _firestore.collection('students').doc(docId).get();
      return doc.exists ? Student.fromMap(doc.data()!) : null;
    } catch (e) {
      print('Error getting student: $e');
      rethrow;
    }
  }

  Future<List<Student>> getAllStudents() async {
    try {
      final snapshot = await _firestore.collection('students').get();
      return snapshot.docs.map((doc) => Student.fromMap(doc.data())).toList();
    } catch (e) {
      print('Error getting all students: $e');
      rethrow;
    }
  }

  // Add deleteStudent method
  Future<void> deleteStudent(dynamic studentId) async {
    try {
      final docId = _validateAndConvertId(studentId);

      // First, check if student exists
      final studentDoc =
          await _firestore.collection('students').doc(docId).get();
      if (!studentDoc.exists) {
        throw Exception('Student with ID $studentId does not exist');
      }

      // Delete student document
      await _firestore.collection('students').doc(docId).delete();

      // Also delete related records (courseRegistrations, attendance, submissions)
      final studentIdInt =
          studentId is int
              ? studentId
              : int.tryParse(studentId.toString()) ?? 0;

      // Delete course registrations
      final regQuery =
          await _firestore
              .collection('courseRegistrations')
              .where('studentId', isEqualTo: studentIdInt)
              .get();

      for (var doc in regQuery.docs) {
        await doc.reference.delete();
      }

      // Delete attendance records
      final attendanceQuery =
          await _firestore
              .collection('attendance')
              .where('studentId', isEqualTo: studentIdInt)
              .get();

      for (var doc in attendanceQuery.docs) {
        await doc.reference.delete();
      }

      // Delete submissions
      final submissionsQuery =
          await _firestore
              .collection('submissions')
              .where('studentId', isEqualTo: studentIdInt)
              .get();

      for (var doc in submissionsQuery.docs) {
        await doc.reference.delete();
      }

      print(
        'Student with ID $studentId and all related records deleted successfully',
      );
    } catch (e) {
      print('Error deleting student: $e');
      rethrow;
    }
  }

  // Add new student with all required fields
  Future<void> addNewStudent({
    required int id,
    required String name,
    required String email,
    required String password,
    required String phone,
    required String address,
    required int level,
    required int credits,
    required String collegeName,
    required String major,
    required double gpa,
  }) async {
    try {
      // Check if student with this ID already exists
      final existingStudent = await getStudent(id);
      if (existingStudent != null) {
        throw Exception('Student with ID $id already exists');
      }

      // Create new student object
      final newStudent = Student(
        id: id,
        name: name,
        email: email,
        password: password,
        phone: phone,
        address: address,
        level: level,
        credits: credits,
        collegeName: collegeName,
        major: major,
        gpa: gpa,
        lastLogin: DateTime.now(),
      );

      // Save to Firestore
      await createStudent(newStudent);
      print('New student added successfully with ID: $id');
    } catch (e) {
      print('Error adding new student: $e');
      rethrow;
    }
  }

  // Add new admin with all required fields
  Future<void> addNewAdmin({
    required int id,
    required String name,
    required String email,
    required String password,
    required String phone,
    required String address,
  }) async {
    try {
      // Check if admin with this ID already exists
      final existingAdmin = await getAdmin(id);
      if (existingAdmin != null) {
        throw Exception('Admin with ID $id already exists');
      }

      // Create new admin object
      final newAdmin = Admin(
        id: id,
        name: name,
        email: email,
        password: password,
        phone: phone,
        address: address,
        lastLogin: DateTime.now(),
      );

      // Save to Firestore
      await createAdmin(
        id: id,
        name: name,
        email: email,
        password: password,
        phone: phone,
        address: address,
      );
      print('New admin added successfully with ID: $id');
    } catch (e) {
      print('Error adding new admin: $e');
      rethrow;
    }
  }

  // Course Operations
  Future<void> createCourse(Course course) async {
    try {
      final docId = _validateAndConvertId(course.id);
      await _firestore.collection('courses').doc(docId).set(course.toMap());
    } catch (e) {
      print('Error creating course: $e');
      rethrow;
    }
  }

  Future<void> updateCourse(Course course) async {
    try {
      final docId = _validateAndConvertId(course.id);
      await _firestore.collection('courses').doc(docId).update(course.toMap());
    } catch (e) {
      print('Error updating course: $e');
      rethrow;
    }
  }

  Future<void> deleteCourse(int courseId) async {
    try {
      final docId = _validateAndConvertId(courseId);
      await _firestore.collection('courses').doc(docId).delete();
    } catch (e) {
      print('Error deleting course: $e');
      rethrow;
    }
  }

  Future<List<Course>> getAllCourses() async {
    try {
      final snapshot = await _firestore.collection('courses').get();
      return snapshot.docs.map((doc) => Course.fromMap(doc.data())).toList();
    } catch (e) {
      print('Error getting all courses: $e');
      rethrow;
    }
  }

  // Course Registration Operations
  Future<void> registerStudentForCourse(CourseRegistration registration) async {
    try {
      final docId = _validateAndConvertId(registration.id);
      await _firestore
          .collection('courseRegistrations')
          .doc(docId)
          .set(registration.toMap());
    } catch (e) {
      print('Error registering student for course: $e');
      rethrow;
    }
  }

  Future<List<CourseRegistration>> getStudentRegistrations(
    int studentId,
  ) async {
    try {
      final docId = _validateAndConvertId(studentId);
      final snapshot =
          await _firestore
              .collection('courseRegistrations')
              .where('studentId', isEqualTo: studentId)
              .get();
      return snapshot.docs
          .map((doc) => CourseRegistration.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting student registrations: $e');
      rethrow;
    }
  }

  // Attendance Operations
  Future<void> recordAttendance({
    required int studentId,
    required int courseId,
    required DateTime date,
    required bool isPresent,
    String notes = '',
  }) async {
    try {
      // Create a unique ID based on student, course, and date
      final dateStr = '${date.year}-${date.month}-${date.day}';
      final docId = '${studentId}_${courseId}_$dateStr';

      await _firestore.collection('attendance').doc(docId).set({
        'studentId': studentId,
        'courseId': courseId,
        'date': date,
        'isPresent': isPresent,
        'notes': notes,
      });

      print('Attendance recorded for student $studentId in course $courseId');
    } catch (e) {
      print('Error recording attendance: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getAttendanceForCourse(
    int courseId, {
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      Query query = _firestore
          .collection('attendance')
          .where('courseId', isEqualTo: courseId);

      if (startDate != null) {
        query = query.where('date', isGreaterThanOrEqualTo: startDate);
      }

      if (endDate != null) {
        query = query.where('date', isLessThanOrEqualTo: endDate);
      }

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print('Error getting attendance for course: $e');
      rethrow;
    }
  }

  Future<List<Map<String, dynamic>>> getAttendanceForStudent(
    int studentId,
    int courseId,
  ) async {
    try {
      final snapshot =
          await _firestore
              .collection('attendance')
              .where('studentId', isEqualTo: studentId)
              .where('courseId', isEqualTo: courseId)
              .orderBy('date', descending: true)
              .get();

      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print('Error getting attendance for student: $e');
      rethrow;
    }
  }

  // Get real-time stream of attendance for a student
  Stream<List<Map<String, dynamic>>> getAttendanceStreamForStudent(
    int studentId,
    int courseId,
  ) {
    try {
      return _firestore
          .collection('attendance')
          .where('studentId', isEqualTo: studentId)
          .where('courseId', isEqualTo: courseId)
          .orderBy('date', descending: true)
          .snapshots()
          .map(
            (snapshot) =>
                snapshot.docs
                    .map((doc) => doc.data() as Map<String, dynamic>)
                    .toList(),
          );
    } catch (e) {
      print('Error getting attendance stream for student: $e');
      rethrow;
    }
  }

  // Get real-time stream of all attendance for a student
  Stream<List<Map<String, dynamic>>> getAllAttendanceStreamForStudent(
    int studentId,
  ) {
    try {
      return _firestore
          .collection('attendance')
          .where('studentId', isEqualTo: studentId)
          .orderBy('date', descending: true)
          .snapshots()
          .map(
            (snapshot) =>
                snapshot.docs
                    .map((doc) => doc.data() as Map<String, dynamic>)
                    .toList(),
          );
    } catch (e) {
      print('Error getting all attendance stream for student: $e');
      rethrow;
    }
  }

  // Student Results Operations
  Future<void> recordStudentResult({
    required int studentId,
    required int courseId,
    double midtermGrade = 0.0,
    double finalGrade = 0.0,
    double assignmentsGrade = 0.0,
    double participationGrade = 0.0,
    String notes = '',
    bool updateStudentRecord =
        true, // Whether to update student total points and credits
    String instructorId = '',
    String instructorName = '',
    String semester = '',
    int academicYear = 0,
  }) async {
    try {
      // Get course information first
      final courseDoc =
          await _firestore.collection('courses').doc(courseId.toString()).get();
      if (!courseDoc.exists) {
        throw Exception('Course with ID $courseId not found');
      }

      final courseData = courseDoc.data() ?? {};
      final String courseName = courseData['name'] ?? 'Unknown Course';
      final String courseCode = courseData['code'] ?? '';
      final int courseCredits =
          int.tryParse(courseData['credits']?.toString() ?? '0') ?? 0;

      // Calculate total grade (can be customized based on weight of each component)
      final double totalGrade =
          midtermGrade * 0.3 +
          finalGrade * 0.4 +
          assignmentsGrade * 0.2 +
          participationGrade * 0.1;

      // Determine letter grade based on total
      String letterGrade = '';
      if (totalGrade >= 90)
        letterGrade = 'A';
      else if (totalGrade >= 80)
        letterGrade = 'B';
      else if (totalGrade >= 70)
        letterGrade = 'C';
      else if (totalGrade >= 60)
        letterGrade = 'D';
      else
        letterGrade = 'F';

      // Create a unique ID for the result
      final docId = '${studentId}_${courseId}';

      // Create result document
      final resultData = {
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
        'updatedAt': FieldValue.serverTimestamp(),
        'notes': notes,
        'instructorId': instructorId,
        'instructorName': instructorName,
        'semester': semester,
        'academicYear': academicYear,
        'isPublished':
            false, // Default to unpublished until instructor confirms
      };

      // Save the result in Firestore
      await _firestore.collection('studentResults').doc(docId).set(resultData);

      // If requested, update the student's record with new grade information
      if (updateStudentRecord) {
        await _updateStudentAcademicInfo(studentId, courseId, resultData);
      }

      print('Results recorded for student $studentId in course $courseId');
    } catch (e) {
      print('Error recording student results: $e');
      rethrow;
    }
  }

  // Updates student record with new academic information
  Future<void> _updateStudentAcademicInfo(
    int studentId,
    int courseId,
    Map<String, dynamic> resultData,
  ) async {
    try {
      // Get the student's current record
      final studentDoc =
          await _firestore
              .collection('students')
              .doc(studentId.toString())
              .get();
      if (!studentDoc.exists) {
        throw Exception('Student with ID $studentId not found');
      }

      final studentData = studentDoc.data() ?? {};

      // Extract current values
      int currentCredits = studentData['credits'] ?? 0;
      int currentTotalPoints = studentData['totalPoints'] ?? 0;
      List<Map<String, dynamic>> academicResults = [];

      // Try to convert existing academic results
      if (studentData['academicResults'] != null) {
        try {
          academicResults = List<Map<String, dynamic>>.from(
            studentData['academicResults'],
          );
        } catch (e) {
          print('Error converting academicResults: $e');
          // If conversion fails, start with empty list
        }
      }

      // Check if this course result already exists in the student's record
      int existingIndex = academicResults.indexWhere(
        (result) =>
            result['courseId'] == courseId.toString() ||
            result['courseId'] == courseId,
      );

      // Prepare the summary result to store in student document
      Map<String, dynamic> resultSummary = {
        'courseId': courseId.toString(),
        'courseName': resultData['courseName'],
        'courseCode': resultData['courseCode'],
        'credits': resultData['courseCredits'],
        'grade': resultData['letterGrade'],
        'semester': resultData['semester'],
        'academicYear': resultData['academicYear'],
        'totalGrade': resultData['totalGrade'],
        'updatedAt': FieldValue.serverTimestamp(),
      };

      // Calculate points earned for this course (only if passed)
      final int courseCredits = resultData['courseCredits'] ?? 0;
      int pointsEarned = 0;

      // Only count passed courses (grades A, B, C, D)
      if (resultData['letterGrade'] != 'F') {
        switch (resultData['letterGrade']) {
          case 'A':
            pointsEarned = courseCredits * 4;
            break;
          case 'B':
            pointsEarned = courseCredits * 3;
            break;
          case 'C':
            pointsEarned = courseCredits * 2;
            break;
          case 'D':
            pointsEarned = courseCredits * 1;
            break;
          default:
            pointsEarned = 0;
        }
      }

      // If updating an existing result, remove the old data first
      if (existingIndex >= 0) {
        // Get the old result to potentially subtract from totals
        Map<String, dynamic> oldResult = academicResults[existingIndex];
        int oldCredits = oldResult['credits'] ?? 0;

        // Calculate old points
        int oldPoints = 0;
        switch (oldResult['grade']) {
          case 'A':
            oldPoints = oldCredits * 4;
            break;
          case 'B':
            oldPoints = oldCredits * 3;
            break;
          case 'C':
            oldPoints = oldCredits * 2;
            break;
          case 'D':
            oldPoints = oldCredits * 1;
            break;
        }

        // Update with new values
        academicResults[existingIndex] = resultSummary;

        // Adjust total points and credits if they changed
        if (oldPoints != pointsEarned || oldCredits != courseCredits) {
          // Remove old values
          currentTotalPoints -= oldPoints;
          // Add new values
          currentTotalPoints += pointsEarned;
        }
      } else {
        // Add new result
        academicResults.add(resultSummary);

        // Only increase credits for new courses with passing grades
        if (resultData['letterGrade'] != 'F') {
          currentCredits += courseCredits;
        }

        // Add new points
        currentTotalPoints += pointsEarned;
      }

      // Calculate new GPA
      double newGPA = 0.0;
      int totalCreditsForGPA = 0;
      int totalPointsForGPA = 0;

      for (var result in academicResults) {
        final int credits = result['credits'] ?? 0;
        final String grade = result['grade'] ?? '';

        int gradePoints = 0;
        switch (grade) {
          case 'A':
            gradePoints = 4;
            break;
          case 'B':
            gradePoints = 3;
            break;
          case 'C':
            gradePoints = 2;
            break;
          case 'D':
            gradePoints = 1;
            break;
          case 'F':
            gradePoints = 0;
            break;
        }

        totalCreditsForGPA += credits;
        totalPointsForGPA += (credits * gradePoints);
      }

      if (totalCreditsForGPA > 0) {
        newGPA = totalPointsForGPA / totalCreditsForGPA;
      }

      // Update the student record with new academic information
      await _firestore.collection('students').doc(studentId.toString()).update({
        'credits': currentCredits,
        'totalPoints': currentTotalPoints,
        'gpa': newGPA,
        'academicResults': academicResults,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      print('Updated academic info for student $studentId');
    } catch (e) {
      print('Error updating student academic info: $e');
      // Don't rethrow since this is an auxiliary operation
      // The main grade recording was already completed
    }
  }

  // Publish student results (make them visible to students)
  Future<void> publishStudentResults(
    int courseId, {
    bool publishAll = false,
  }) async {
    try {
      // Get all results for this course
      final resultsQuery = _firestore
          .collection('studentResults')
          .where('courseId', isEqualTo: courseId.toString());

      final snapshot = await resultsQuery.get();

      // Update each result to published state
      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.update(doc.reference, {
          'isPublished': true,
          'publishedAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }

      await batch.commit();

      // Also get the course details to include in the logs
      final courseDoc =
          await _firestore.collection('courses').doc(courseId.toString()).get();
      String courseName = "Unknown Course";
      if (courseDoc.exists) {
        final courseData = courseDoc.data() as Map<String, dynamic>;
        courseName = courseData['name'] ?? "Course $courseId";
      }

      print(
        'Published ${snapshot.docs.length} results for course $courseName (ID: $courseId)',
      );
    } catch (e) {
      print('Error publishing results: $e');
      rethrow;
    }
  }

  // Get all academic results for a student
  Future<List<Map<String, dynamic>>> getStudentAcademicResults(
    int studentId,
  ) async {
    try {
      final resultsQuery =
          await _firestore
              .collection('studentResults')
              .where('studentId', isEqualTo: studentId.toString())
              .where(
                'isPublished',
                isEqualTo: true,
              ) // Only get published results for students
              .orderBy('updatedAt', descending: true)
              .get();

      return resultsQuery.docs
          .map((doc) => doc.data() as Map<String, dynamic>)
          .toList();
    } catch (e) {
      print('Error getting student academic results: $e');
      rethrow;
    }
  }

  // Get all course results including unpublished ones (for instructors)
  Future<List<Map<String, dynamic>>> getAllCourseResults(int courseId) async {
    try {
      // Primero obtenemos los resultados sin ordenar
      final resultsQuery =
          await _firestore
              .collection('studentResults')
              .where('courseId', isEqualTo: courseId.toString())
              .get();

      // Convertimos los documentos a una lista de mapas
      final results =
          resultsQuery.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();

      // Ordenamos la lista manualmente por totalGrade en orden descendente
      results.sort((a, b) {
        final totalGradeA = (a['totalGrade'] ?? 0.0) as num;
        final totalGradeB = (b['totalGrade'] ?? 0.0) as num;
        return totalGradeB.compareTo(totalGradeA); // Orden descendente
      });

      return results;
    } catch (e) {
      print('Error getting course results: $e');
      rethrow;
    }
  }

  // Get a specific student result for a course
  Future<Map<String, dynamic>?> getStudentResult(
    int studentId,
    int courseId,
  ) async {
    try {
      final docId = '${studentId}_${courseId}';
      final doc =
          await _firestore.collection('studentResults').doc(docId).get();

      return doc.exists ? doc.data() : null;
    } catch (e) {
      print('Error getting student result: $e');
      rethrow;
    }
  }

  // Get approved grades for a student
  Future<List<Map<String, dynamic>>> getApprovedGrades(int studentId) async {
    try {
      final snapshot =
          await _firestore
              .collection('grades')
              .where('studentId', isEqualTo: studentId.toString())
              .where('status', isEqualTo: 'approved')
              .get();

      List<Map<String, dynamic>> approvedGrades = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        approvedGrades.add({'id': doc.id, ...data});
      }

      return approvedGrades;
    } catch (e) {
      print('Error getting approved grades: $e');
      rethrow;
    }
  }

  // Get students enrolled in a course
  Future<List<Map<String, dynamic>>> getStudentsInCourse(int courseId) async {
    try {
      // First get all registrations for this course
      final registrationsSnapshot =
          await _firestore
              .collection('courseRegistrations')
              .where('courseId', isEqualTo: courseId.toString())
              .where('status', isEqualTo: 'active')
              .get();

      List<Map<String, dynamic>> students = [];

      // For each registration, get the student details
      for (var doc in registrationsSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final studentIdStr = data['studentId'];
        final studentId = int.tryParse(studentIdStr.toString()) ?? 0;

        if (studentId > 0) {
          final studentDoc =
              await _firestore
                  .collection('students')
                  .doc(studentId.toString())
                  .get();

          if (studentDoc.exists) {
            final studentData = studentDoc.data() as Map<String, dynamic>;
            students.add({
              'id': studentId,
              'name': studentData['name'] ?? 'Unknown',
              'email': studentData['email'] ?? '',
              'level': studentData['level'] ?? 0,
              'major': studentData['major'] ?? '',
            });
          }
        }
      }

      return students;
    } catch (e) {
      print('Error getting students in course: $e');
      rethrow;
    }
  }

  // Assignment Operations
  Future<void> createAssignment(Assignment assignment) async {
    try {
      final docId = _validateAndConvertId(assignment.id);
      await _firestore
          .collection('assignments')
          .doc(docId)
          .set(assignment.toMap());
    } catch (e) {
      print('Error creating assignment: $e');
      rethrow;
    }
  }

  Future<List<Assignment>> getCourseAssignments(int courseId) async {
    try {
      final docId = _validateAndConvertId(courseId);
      final snapshot =
          await _firestore
              .collection('assignments')
              .where('courseId', isEqualTo: courseId)
              .get();
      return snapshot.docs
          .map((doc) => Assignment.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting course assignments: $e');
      rethrow;
    }
  }

  // Submission Operations
  Future<void> submitAssignment(Submission submission) async {
    try {
      final docId = _validateAndConvertId(submission.id);
      await _firestore
          .collection('submissions')
          .doc(docId)
          .set(submission.toMap());
    } catch (e) {
      print('Error submitting assignment: $e');
      rethrow;
    }
  }

  Future<List<Submission>> getStudentSubmissions(int studentId) async {
    try {
      final docId = _validateAndConvertId(studentId);
      final snapshot =
          await _firestore
              .collection('submissions')
              .where('studentId', isEqualTo: studentId)
              .get();
      return snapshot.docs
          .map((doc) => Submission.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting student submissions: $e');
      rethrow;
    }
  }

  // Update last login
  Future<void> updateLastLogin(int userId, String userType) async {
    try {
      final docId = _validateAndConvertId(userId);
      final collection = userType == 'admin' ? 'admins' : 'students';
      await _firestore.collection(collection).doc(docId).update({
        'lastLogin': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error updating last login: $e');
      rethrow;
    }
  }

  // Add specific student with string ID
  Future<void> addSpecificStudent({
    required String id,
    required String name,
    required String email,
    required String password,
    required String phone,
    required String address,
    required int level,
    required int credits,
    required String collegeName,
    required String major,
    required double gpa,
  }) async {
    try {
      // Check if student with this ID already exists
      final existingStudent =
          await _firestore.collection('students').doc(id).get();
      if (existingStudent.exists) {
        throw Exception('Student with ID $id already exists');
      }

      // Create new student object
      final newStudent = {
        'id': id,
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
        'lastLogin': FieldValue.serverTimestamp(),
      };

      // Save to Firestore
      await _firestore.collection('students').doc(id).set(newStudent);
      print('New student added successfully with ID: $id');
    } catch (e) {
      print('Error adding new student: $e');
      rethrow;
    }
  }

  // Update student phone and password
  Future<void> updateStudentPhoneAndPassword({
    required dynamic studentId,
    required String phone,
    required String password,
  }) async {
    try {
      final docId = _validateAndConvertId(studentId);

      // Check if student exists
      final studentDoc =
          await _firestore.collection('students').doc(docId).get();
      if (!studentDoc.exists) {
        throw Exception('Student with ID $studentId does not exist');
      }

      // Update only phone and password fields
      await _firestore.collection('students').doc(docId).update({
        'phone': phone,
        'password': password,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      print('Phone and password updated for student $studentId');
    } catch (e) {
      print('Error updating student phone and password: $e');
      rethrow;
    }
  }

  // Instructor Operations
  Future<void> createInstructor(Instructor instructor) async {
    try {
      final docId = _validateAndConvertId(instructor.id);
      await _firestore
          .collection('instructors')
          .doc(docId)
          .set(instructor.toMap());
    } catch (e) {
      print('Error creating instructor: $e');
      rethrow;
    }
  }

  Future<Instructor?> getInstructor(int instructorId) async {
    try {
      final docId = _validateAndConvertId(instructorId);
      final doc = await _firestore.collection('instructors').doc(docId).get();
      return doc.exists ? Instructor.fromMap(doc.data()!) : null;
    } catch (e) {
      print('Error getting instructor: $e');
      rethrow;
    }
  }

  Future<Instructor?> getInstructorByEmail(String email) async {
    try {
      final querySnapshot =
          await _firestore
              .collection('instructors')
              .where('email', isEqualTo: email)
              .limit(1)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        return Instructor.fromMap(querySnapshot.docs.first.data());
      }
      return null;
    } catch (e) {
      print('Error getting instructor by email: $e');
      rethrow;
    }
  }

  Future<List<Instructor>> getAllInstructors() async {
    try {
      final snapshot = await _firestore.collection('instructors').get();
      return snapshot.docs
          .map((doc) => Instructor.fromMap(doc.data()))
          .toList();
    } catch (e) {
      print('Error getting all instructors: $e');
      rethrow;
    }
  }

  Future<void> updateInstructor(Instructor instructor) async {
    try {
      final docId = _validateAndConvertId(instructor.id);
      await _firestore
          .collection('instructors')
          .doc(docId)
          .update(instructor.toMap());
    } catch (e) {
      print('Error updating instructor: $e');
      rethrow;
    }
  }

  Future<void> deleteInstructor(int instructorId) async {
    try {
      final docId = _validateAndConvertId(instructorId);
      await _firestore.collection('instructors').doc(docId).delete();
    } catch (e) {
      print('Error deleting instructor: $e');
      rethrow;
    }
  }

  Future<void> assignCourseToInstructor(
    int instructorId,
    String courseId,
  ) async {
    try {
      final docId = _validateAndConvertId(instructorId);
      await _firestore.collection('instructors').doc(docId).update({
        'assignedCourses': FieldValue.arrayUnion([courseId]),
      });
    } catch (e) {
      print('Error assigning course to instructor: $e');
      rethrow;
    }
  }

  Future<void> removeCourseFromInstructor(
    int instructorId,
    String courseId,
  ) async {
    try {
      final docId = _validateAndConvertId(instructorId);
      await _firestore.collection('instructors').doc(docId).update({
        'assignedCourses': FieldValue.arrayRemove([courseId]),
      });
    } catch (e) {
      print('Error removing course from instructor: $e');
      rethrow;
    }
  }

  Future<void> addNewInstructor({
    required int id,
    required String name,
    required String email,
    required String password,
    required String phone,
    required String address,
    required String academicDegree,
    List<String>? assignedCourses,
  }) async {
    try {
      // Check if instructor with this ID already exists
      final existingInstructor = await getInstructor(id);
      if (existingInstructor != null) {
        throw Exception('Instructor with ID $id already exists');
      }

      // Check if email is already in use
      final emailExists = await getInstructorByEmail(email);
      if (emailExists != null) {
        throw Exception('Email $email is already in use');
      }

      // Create new instructor object
      final newInstructor = Instructor(
        id: id,
        name: name,
        email: email,
        password: password,
        phone: phone,
        address: address,
        academicDegree: academicDegree,
        assignedCourses: assignedCourses ?? [],
        lastLogin: DateTime.now(),
      );

      // Save to Firestore
      await createInstructor(newInstructor);
      print('New instructor added successfully with ID: $id');
    } catch (e) {
      print('Error adding new instructor: $e');
      rethrow;
    }
  }

  // Payment Operations
  Future<void> createPayment(Payment payment) async {
    try {
      // Use studentId as the document ID for easy lookup
      final docId = _validateAndConvertId(payment.studentId);
      await _firestore.collection('payments').doc(docId).set(payment.toMap());
    } catch (e) {
      print('Error creating payment record: $e');
      rethrow;
    }
  }

  Future<Payment?> getPayment(int studentId) async {
    try {
      final docId = _validateAndConvertId(studentId);
      final doc = await _firestore.collection('payments').doc(docId).get();
      return doc.exists ? Payment.fromMap(doc.data()!) : null;
    } catch (e) {
      print('Error getting payment: $e');
      rethrow;
    }
  }

  Future<List<Payment>> getAllPayments() async {
    try {
      final snapshot = await _firestore.collection('payments').get();
      return snapshot.docs.map((doc) => Payment.fromMap(doc.data())).toList();
    } catch (e) {
      print('Error getting all payments: $e');
      rethrow;
    }
  }

  Future<void> updatePaymentStatus(
    int studentId,
    String status, {
    double? amountPaid,
  }) async {
    try {
      final docId = _validateAndConvertId(studentId);
      final updateData = {
        'status': status,
        'lastUpdated': FieldValue.serverTimestamp(),
      };

      if (amountPaid != null) {
        updateData['amountPaid'] = amountPaid;
      }

      await _firestore.collection('payments').doc(docId).update(updateData);
    } catch (e) {
      print('Error updating payment status: $e');
      rethrow;
    }
  }

  // Initialize payment record for a student
  Future<void> initializeStudentPayment(
    int studentId,
    String studentName,
    double amountDue,
  ) async {
    try {
      final docId = _validateAndConvertId(studentId);

      // Check if payment record already exists
      final doc = await _firestore.collection('payments').doc(docId).get();
      if (doc.exists) {
        return; // Record already exists, no need to initialize
      }

      // Create new payment record
      final payment = Payment(
        studentId: studentId,
        studentName: studentName,
        amountDue: amountDue,
        amountPaid: 0.0,
        status: 'unpaid',
        lastUpdated: DateTime.now(),
      );

      await createPayment(payment);
    } catch (e) {
      print('Error initializing student payment: $e');
      rethrow;
    }
  }
}
