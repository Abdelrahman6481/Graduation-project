import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main(List<String> args) async {
  // Usage: dart run bin/add_admin.dart <id> <name> <email> <password> <phone> <address>
  if (args.length < 6) {
    print(
      'Usage: dart run bin/add_admin.dart <id> <name> <email> <password> <phone> <address>',
    );
    return;
  }

  final id = args[0];
  final name = args[1];
  final email = args[2];
  final password = args[3];
  final phone = args[4];
  final address = args[5];

  await Firebase.initializeApp();

  final firestore = FirebaseFirestore.instance;

  await firestore.collection('admins').doc(id).set({
    'id': id,
    'name': name,
    'email': email,
    'password': password,
    'phone': phone,
    'address': address,
    'lastLogin': FieldValue.serverTimestamp(),
  });

  print('Admin with ID $id added successfully!');
}
