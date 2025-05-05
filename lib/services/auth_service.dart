import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/firestore_models.dart';

class AuthService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      print('Attempting login with email: $email');

      // Try admin login first
      print('Checking admin collection...');
      final adminSnapshot =
          await _firestore
              .collection('admins')
              .where('email', isEqualTo: email)
              .limit(1)
              .get();

      print('Admin query result: ${adminSnapshot.docs.length} documents found');
      if (adminSnapshot.docs.isNotEmpty) {
        final adminDoc = adminSnapshot.docs.first;
        final adminData = adminDoc.data();
        print('Admin document found: $adminData');

        if (adminData['password'] == password) {
          print('Admin password matches');
          final admin = Admin.fromMap(adminData);
          await adminDoc.reference.update({
            'lastLogin': FieldValue.serverTimestamp(),
          });
          return {'success': true, 'userType': 'admin', 'userData': adminData};
        } else {
          print('Admin password does not match');
        }
      }

      // Try student login
      print('Checking student collection...');
      final studentSnapshot =
          await _firestore
              .collection('students')
              .where('email', isEqualTo: email)
              .limit(1)
              .get();

      print(
        'Student query result: ${studentSnapshot.docs.length} documents found',
      );
      if (studentSnapshot.docs.isNotEmpty) {
        final studentDoc = studentSnapshot.docs.first;
        final studentData = studentDoc.data();
        print('Student document found: $studentData');

        if (studentData['password'] == password) {
          print('Student password matches');
          final student = Student.fromMap(studentData);
          await studentDoc.reference.update({
            'lastLogin': FieldValue.serverTimestamp(),
          });
          return {
            'success': true,
            'userType': 'student',
            'userData': studentData,
          };
        } else {
          print('Student password does not match');
        }
      }

      print('Login failed - no matching user found');
      return {'success': false, 'message': 'Invalid email or password'};
    } catch (e, stackTrace) {
      print('Error during login: $e');
      print('Stack trace: $stackTrace');
      return {
        'success': false,
        'message': 'An error occurred during login: ${e.toString()}',
      };
    }
  }

  // Check if email exists in either collection
  Future<bool> emailExists(String email) async {
    try {
      print('Checking if email exists: $email');

      final adminSnapshot =
          await _firestore
              .collection('admins')
              .where('email', isEqualTo: email)
              .limit(1)
              .get();

      if (adminSnapshot.docs.isNotEmpty) {
        print('Email found in admin collection');
        return true;
      }

      final studentSnapshot =
          await _firestore
              .collection('students')
              .where('email', isEqualTo: email)
              .limit(1)
              .get();

      if (studentSnapshot.docs.isNotEmpty) {
        print('Email found in student collection');
        return true;
      }

      print('Email not found in any collection');
      return false;
    } catch (e, stackTrace) {
      print('Error checking email existence: $e');
      print('Stack trace: $stackTrace');
      return false;
    }
  }

  // Get user by email
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    try {
      print('Getting user by email: $email');

      // Check admin collection
      final adminSnapshot =
          await _firestore
              .collection('admins')
              .where('email', isEqualTo: email)
              .limit(1)
              .get();

      if (adminSnapshot.docs.isNotEmpty) {
        print('User found in admin collection');
        return {'type': 'admin', 'data': adminSnapshot.docs.first.data()};
      }

      // Check student collection
      final studentSnapshot =
          await _firestore
              .collection('students')
              .where('email', isEqualTo: email)
              .limit(1)
              .get();

      if (studentSnapshot.docs.isNotEmpty) {
        print('User found in student collection');
        return {'type': 'student', 'data': studentSnapshot.docs.first.data()};
      }

      print('User not found in any collection');
      return null;
    } catch (e, stackTrace) {
      print('Error getting user by email: $e');
      print('Stack trace: $stackTrace');
      return null;
    }
  }

  // Helper method to check if a document exists
  Future<bool> documentExists(String collection, String docId) async {
    if (!RegExp(r'^\d+$').hasMatch(docId)) {
      return false;
    }
    final doc = await _firestore.collection(collection).doc(docId).get();
    return doc.exists;
  }

  // Helper method to get document data
  Future<Map<String, dynamic>?> getDocumentData(
    String collection,
    String docId,
  ) async {
    if (!RegExp(r'^\d+$').hasMatch(docId)) {
      return null;
    }
    final doc = await _firestore.collection(collection).doc(docId).get();
    return doc.exists ? doc.data() : null;
  }
}
