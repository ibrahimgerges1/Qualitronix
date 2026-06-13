import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';


// Save history to Firestore under 'users/{userId}/history'
Future<void> saveHistoryToFirestore(Map<String, dynamic> historyItem) async {
  try {
    // Get the currently authenticated user's UID
    String userId = FirebaseAuth.instance.currentUser!.uid;

    // Reference to the user's history collection
    CollectionReference historyCollection = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('history');

    // Add the history item to the user's collection
    await historyCollection.add({
      'class_name': historyItem['class_name'],
      'confidence': historyItem['confidence'],
      'x_min': historyItem['x_min'],
      'y_min': historyItem['y_min'],
      'x_max': historyItem['x_max'],
      'y_max': historyItem['y_max'],
      'image_url': historyItem['image_url'],
      'timestamp': FieldValue.serverTimestamp(), // Use Firestore's server timestamp
    });
  } catch (e) {
    print("Error saving history: $e");
  }
}

// Stream history from Firestore under 'users/{userId}/history'
Stream<QuerySnapshot> getHistoryFromFirestore() {
  // Get the currently authenticated user's UID
  String userId = FirebaseAuth.instance.currentUser!.uid;

  // Return a stream of history items ordered by timestamp
  return FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .collection('history')
      .orderBy('timestamp', descending: true)
      .snapshots();
}
