import 'package:flutter/material.dart';
import 'dart:io';
import '../models/event_model.dart';
import '../services/event_service.dart';

class EventProvider extends ChangeNotifier {
  final EventService _eventService = EventService();
  List<EventModel> _events = [];
  List<EventModel> _upcomingEvents = [];
  List<EventModel> _publishedEvents = [];
  bool _isLoading = false;
  String? _error;

  List<EventModel> get events => _events;
  List<EventModel> get upcomingEvents => _upcomingEvents;
  List<EventModel> get publishedEvents => _publishedEvents;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Initialize events
  void initializeEvents() {
    // Listen to all events stream
    _eventService.getAllEventsStream().listen((events) {
      _events = events;
      notifyListeners();
    });

    // Listen to upcoming events stream
    _eventService.getUpcomingEventsStream().listen((events) {
      _upcomingEvents = events;
      notifyListeners();
    });

    // Listen to published events stream
    _eventService.getPublishedEventsStream().listen((events) {
      _publishedEvents = events;
      notifyListeners();
    });
  }

  // Create event
  Future<void> createEvent({
    required String name,
    required DateTime date,
    required String description,
    File? flyerFile,
    required Map<String, String> staff,
    required Map<String, String> djs,
    required bool isPublished,
    required String createdById,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _eventService.createEvent(
        name: name,
        date: date,
        description: description,
        flyerFile: flyerFile,
        staff: staff,
        djs: djs,
        isPublished: isPublished,
        createdById: createdById,
      );
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update event
  Future<void> updateEvent(EventModel event) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _eventService.updateEvent(event);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Delete event
  Future<void> deleteEvent(String eventId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _eventService.deleteEvent(eventId);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Update flyer
  Future<String> updateFlyer(String eventId, File flyerFile) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      String flyerUrl = await _eventService.updateFlyer(eventId, flyerFile);
      _isLoading = false;
      notifyListeners();
      return flyerUrl;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return '';
    }
  }

  // Toggle publish status
  Future<void> togglePublishStatus(String eventId, bool isPublished) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _eventService.togglePublishStatus(eventId, isPublished);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}

