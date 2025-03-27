import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/event_model.dart';
import '../constants/app_constants.dart';
import 'package:uuid/uuid.dart';

class EventService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final Uuid _uuid = Uuid();

  // Create a new event
  Future<EventModel> createEvent({
    required String name,
    required DateTime date,
    required String description,
    File? flyerFile,
    required Map<String, String> staff,
    required Map<String, String> djs,
    required bool isPublished,
    required String createdById,
  }) async {
    try {
      String eventId = _uuid.v4();
      
      // Upload flyer if provided
      String? flyerUrl;
      if (flyerFile != null) {
        flyerUrl = await _uploadFlyer(flyerFile, eventId);
      }
      
      EventModel event = EventModel(
        id: eventId,
        name: name,
        date: date,
        description: description,
        flyerUrl: flyerUrl,
        staff: staff,
        djs: djs,
        isPublished: isPublished,
        createdById: createdById,
      );

      await _firestore
          .collection(AppConstants.eventsCollection)
          .doc(eventId)
          .set(event.toMap());

      return event;
    } catch (e) {
      throw Exception('Failed to create event: ${e.toString()}');
    }
  }

  // Upload event flyer
  Future<String> _uploadFlyer(File flyerFile, String eventId) async {
    try {
      String fileName = 'flyer_${eventId}_${DateTime.now().millisecondsSinceEpoch}';
      String path = '${AppConstants.eventFlyersPath}/$fileName';
      
      UploadTask uploadTask = _storage.ref().child(path).putFile(flyerFile);
      TaskSnapshot snapshot = await uploadTask;
      String downloadUrl = await snapshot.ref.getDownloadURL();
      
      return downloadUrl;
    } catch (e) {
      throw Exception('Failed to upload flyer: ${e.toString()}');
    }
  }

  // Get all events stream
  Stream<List<EventModel>> getAllEventsStream() {
    return _firestore
        .collection(AppConstants.eventsCollection)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => EventModel.fromFirestore(doc))
            .toList());
  }

  // Get upcoming events stream
  Stream<List<EventModel>> getUpcomingEventsStream() {
    return _firestore
        .collection(AppConstants.eventsCollection)
        .where('date', isGreaterThanOrEqualTo: Timestamp.fromDate(DateTime.now()))
        .orderBy('date')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => EventModel.fromFirestore(doc))
            .toList());
  }

  // Get published events stream
  Stream<List<EventModel>> getPublishedEventsStream() {
    return _firestore
        .collection(AppConstants.eventsCollection)
        .where('isPublished', isEqualTo: true)
        .orderBy('date', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => EventModel.fromFirestore(doc))
            .toList());
  }

  // Get event by ID
  Future<EventModel> getEventById(String eventId) async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection(AppConstants.eventsCollection)
          .doc(eventId)
          .get();
      
      if (!doc.exists) {
        throw Exception('Event not found');
      }
      
      return EventModel.fromFirestore(doc);
    } catch (e) {
      throw Exception('Failed to get event: ${e.toString()}');
    }
  }

  // Update event
  Future<void> updateEvent(EventModel event) async {
    try {
      await _firestore
          .collection(AppConstants.eventsCollection)
          .doc(event.id)
          .update(event.toMap());
    } catch (e) {
      throw Exception('Failed to update event: ${e.toString()}');
    }
  }

  // Delete event
  Future<void> deleteEvent(String eventId) async {
    try {
      await _firestore
          .collection(AppConstants.eventsCollection)
          .doc(eventId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete event: ${e.toString()}');
    }
  }

  // Update flyer
  Future<String> updateFlyer(String eventId, File flyerFile) async {
    try {
      String flyerUrl = await _uploadFlyer(flyerFile, eventId);
      
      await _firestore
          .collection(AppConstants.eventsCollection)
          .doc(eventId)
          .update({'flyerUrl': flyerUrl});
      
      return flyerUrl;
    } catch (e) {
      throw Exception('Failed to update flyer: ${e.toString()}');
    }
  }

  // Toggle publish status
  Future<void> togglePublishStatus(String eventId, bool isPublished) async {
    try {
      await _firestore
          .collection(AppConstants.eventsCollection)
          .doc(eventId)
          .update({'isPublished': isPublished});
    } catch (e) {
      throw Exception('Failed to update publish status: ${e.toString()}');
    }
  }
}

