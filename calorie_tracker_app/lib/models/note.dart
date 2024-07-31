import 'package:cloud_firestore/cloud_firestore.dart';

/// This is a Note class which contains a Title, Description/Content, and a 
/// Unique ID to differentiate between different Notes.
/// It also provides a factory constructor to create a Note instance from a Firestore document
/// and a method to convert a Note instance to a map suitable for Firestore.
/// 
/// Properties:
/// - description: A String that represents the note's description/contents.
/// - title: A String that represents the title of the note.
/// - id: A String that represents the note's unique ID.
/// 
/// Methods:
/// - Note.fromFirestore: Creates a Note instance from a Firestore DocumentSnapshot.
/// - toMap: Converts the Note into a Map suitable for storing in Firestore.
class Note {
  Note({required this.description, required this.title, this.id});

  String description;
  String title;
  String? id;

  //Note.fromFirestore: Creates a Note instance from a Firestore DocumentSnapshot.
  factory Note.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
  ) {
    final data = snapshot.data();

    return Note(
      title: data?['title'],
      description: data?['description'],
      id: snapshot.id,
    );
  }

  //toMap: Converts the Note into a Map suitable for storing in Firestore.
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'description': description,
    };
  }
}