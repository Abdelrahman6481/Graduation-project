import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/firestore_models.dart';
import 'package:flutter/foundation.dart';

class AuthService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      if (kDebugMode) {
        debugPrint('Attempting login with email: $email');
        // Try admin login first
        debugPrint('Checking admin collection...');
      }
      final adminSnapshot =
          await _firestore
              .collection('admins')
              .where('email', isEqualTo: email)
              .limit(1)
              .get();

      if (kDebugMode) {
        debugPrint(
          'Admin query result: ${adminSnapshot.docs.length} documents found',
        );
      }
      if (adminSnapshot.docs.isNotEmpty) {
        final adminDoc = adminSnapshot.docs.first;
        final adminData = adminDoc.data();
        if (kDebugMode) {
          debugPrint('Admin document found: $adminData');
        }

        if (adminData['password'] == password) {
          if (kDebugMode) {
            debugPrint('Admin password matches');
          }
          // Admin.fromMap is not used, so we can remove it
          await adminDoc.reference.update({
            'lastLogin': FieldValue.serverTimestamp(),
          });
          return {'success': true, 'userType': 'admin', 'userData': adminData};
        } else {
          if (kDebugMode) {
            debugPrint('Admin password does not match');
          }
        }
      }

      // Try student login
      if (kDebugMode) {
        debugPrint('Checking student collection...');
      }
      final studentSnapshot =
          await _firestore
              .collection('students')
              .where('email', isEqualTo: email)
              .limit(1)
              .get();

      if (kDebugMode) {
        debugPrint(
          'Student query result: ${studentSnapshot.docs.length} documents found',
        );
      }
      if (studentSnapshot.docs.isNotEmpty) {
        final studentDoc = studentSnapshot.docs.first;
        final studentData = studentDoc.data();
        if (kDebugMode) {
          debugPrint('Student document found: $studentData');
        }

        if (studentData['password'] == password) {
          if (kDebugMode) {
            debugPrint('Student password matches');
          }
          // Student.fromMap is not used, so we can remove it
          await studentDoc.reference.update({
            'lastLogin': FieldValue.serverTimestamp(),
          });
          return {
            'success': true,
            'userType': 'student',
            'userData': studentData,
          };
        } else {
          if (kDebugMode) {
            debugPrint('Student password does not match');
          }
        }
      }

      if (kDebugMode) {
        debugPrint('Login failed - no matching user found');
      }
      return {'success': false, 'message': 'Invalid email or password'};
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('Error during login: $e');
        debugPrint('Stack trace: $stackTrace');
      }
      return {
        'success': false,
        'message': 'An error occurred during login: ${e.toString()}',
      };
    }
  }

  // Check if email exists in either collection
  Future<bool> emailExists(String email) async {
    try {
      if (kDebugMode) {
        debugPrint('Checking if email exists: $email');
      }

      final adminSnapshot =
          await _firestore
              .collection('admins')
              .where('email', isEqualTo: email)
              .limit(1)
              .get();

      if (adminSnapshot.docs.isNotEmpty) {
        if (kDebugMode) {
          debugPrint('Email found in admin collection');
        }
        return true;
      }

      final studentSnapshot =
          await _firestore
              .collection('students')
              .where('email', isEqualTo: email)
              .limit(1)
              .get();

      if (studentSnapshot.docs.isNotEmpty) {
        if (kDebugMode) {
          debugPrint('Email found in student collection');
        }
        return true;
      }

      if (kDebugMode) {
        debugPrint('Email not found in any collection');
      }
      return false;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('Error checking email existence: $e');
        debugPrint('Stack trace: $stackTrace');
      }
      return false;
    }
  }

  // Get user by email
  Future<Map<String, dynamic>?> getUserByEmail(String email) async {
    try {
      if (kDebugMode) {
        debugPrint('Getting user by email: $email');
      }

      // Check admin collection
      final adminSnapshot =
          await _firestore
              .collection('admins')
              .where('email', isEqualTo: email)
              .limit(1)
              .get();

      if (adminSnapshot.docs.isNotEmpty) {
        if (kDebugMode) {
          debugPrint('User found in admin collection');
        }
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
        if (kDebugMode) {
          debugPrint('User found in student collection');
        }
        return {'type': 'student', 'data': studentSnapshot.docs.first.data()};
      }

      if (kDebugMode) {
        debugPrint('User not found in any collection');
      }
      return null;
    } catch (e, stackTrace) {
      if (kDebugMode) {
        debugPrint('Error getting user by email: $e');
        debugPrint('Stack trace: $stackTrace');
      }
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
