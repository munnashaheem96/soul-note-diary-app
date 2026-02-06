import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  // 🔥 ADD DIARY (USER-BASED & SECURE)
  static Future<void> addDiary({
    required String title,
    required String content,
    required DateTime date,
    String? location,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _db.collection('users').doc(user.uid).collection('diaries').add({
      'title': title,
      'content': content,
      'date': Timestamp.fromDate(date),
      'year': date.year,
      'month': date.month,
      'location': location,
      'createdAt': Timestamp.now(),
      'updatedAt': Timestamp.now(), // ✅ ADD THIS
    });
  }

  // 📄 LOAD DIARIES (YEAR + MONTH FILTER)
  static Stream<QuerySnapshot> getDiaries({
    required int year,
    required int month,
  }) {
    final user = _auth.currentUser;

    if (user == null) {
      return const Stream.empty();
    }

    return _db
        .collection('users')
        .doc(user.uid)
        .collection('diaries')
        .where('year', isEqualTo: year)
        .where('month', isEqualTo: month)
        .orderBy('date', descending: true)
        .snapshots();
  }

  static Future<void> deleteDiary(String diaryId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _db
        .collection('users')
        .doc(user.uid)
        .collection('diaries')
        .doc(diaryId)
        .delete();
  }

  static Future<void> updateDiary({
    required String diaryId,
    required String title,
    required String content,
    String? location,
  }) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _db
        .collection('users')
        .doc(user.uid)
        .collection('diaries')
        .doc(diaryId)
        .update({
          'title': title,
          'content': content,
          'location': location,
          'updatedAt': Timestamp.now(),
        });
  }
}
