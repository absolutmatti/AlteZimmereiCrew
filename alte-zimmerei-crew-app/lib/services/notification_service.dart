import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:flutter/material.dart';
import '../models/post_model.dart';
import '../models/shift_model.dart';
import '../models/event_model.dart';
import '../models/meeting_model.dart';
import '../constants/app_constants.dart';
import 'package:flutter/foundation.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();

  factory NotificationService() {
    return _instance;
  }

  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();
  final Map<String, int> _channelIdMap = {};
  int _notificationIdCounter = 0;

  Future<void> initialize() async {
    // Initialize timezone
    tz_data.initializeTimeZones();

    // Initialize notification settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    // Request permissions
    await _requestPermissions();

    // Initialize channel ID map
    _channelIdMap[AppConstants.newsChannel] = 1;
    _channelIdMap[AppConstants.generalChannel] = 2;
    _channelIdMap[AppConstants.shiftsChannel] = 3;
    _channelIdMap[AppConstants.meetingsChannel] = 4;
    _channelIdMap[AppConstants.eventsChannel] = 5;
  }

  Future<void> _requestPermissions() async {
    await _notificationsPlugin
        .resolvePlatformSpecificImplementation
            AndroidFlutterLocalNotificationsPlugin>()
        ?.requestPermission();

    await _notificationsPlugin
        .resolvePlatformSpecificImplementation
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
  }

  void _onNotificationTap(NotificationResponse response) {
    // Handle notification tap based on payload
    debugPrint('Notification tapped: ${response.payload}');
    
    // The payload is expected to be in the format "type:id"
    if (response.payload != null && response.payload!.contains(':')) {
      final parts = response.payload!.split(':');
      final type = parts[0];
      final id = parts[1];
      
      // This information can be used to navigate to the appropriate screen
      // Will be implemented in a central notification handler
    }
  }

  // Generate a unique notification ID
  int _getUniqueNotificationId() {
    return _notificationIdCounter++;
  }

  // Show immediate notification
  Future<void> showNotification({
    required String title,
    required String body,
    String? payload,
    String channelId = 'default_channel',
    String channelName = 'Default Channel',
    String channelDescription = 'Default notification channel',
  }) async {
    int id = _getUniqueNotificationId();
    
    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    DarwinNotificationDetails iosDetails = const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  // Schedule notification
  Future<void> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
    String channelId = 'default_channel',
    String channelName = 'Default Channel',
    String channelDescription = 'Default notification channel',
  }) async {
    int id = _getUniqueNotificationId();
    
    AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDescription,
      importance: Importance.high,
      priority: Priority.high,
      showWhen: true,
    );

    DarwinNotificationDetails iosDetails = const DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _notificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );
  }

  // Specific notification methods for app features
  
  // 1. New Post Notification
  Future<void> notifyNewPost(PostModel post, List<String> userIds) async {
    final String channelId = post.feedType == 'news' 
        ? AppConstants.newsChannel 
        : AppConstants.generalChannel;
    
    final String channelName = post.feedType == 'news' 
        ? 'News Notifications' 
        : 'General Feed Notifications';
    
    final String channelDesc = post.feedType == 'news' 
        ? 'Notifications for important news'
        : 'Notifications for general posts';
    
    String title = '${post.authorName} posted ${post.feedType == 'news' ? 'news' : 'in general feed'}';
    String body = post.isImportant 
        ? '🔔 IMPORTANT: ${post.content.length > 50 ? '${post.content.substring(0, 47)}...' : post.content}'
        : post.content.length > 50 ? '${post.content.substring(0, 47)}...' : post.content;
    
    await showNotification(
      title: title,
      body: body,
      channelId: channelId,
      channelName: channelName,
      channelDescription: channelDesc,
      payload: 'post:${post.id}:${post.feedType}'
    );
  }
  
  // 2. Shift Change Notification
  Future<void> notifyShiftChange(ShiftModel shift, String notificationType) async {
    String title;
    String body;
    
    switch (notificationType) {
      case 'request':
        title = 'Shift Change Requested';
        body = '${shift.assignedToName} requested to change their shift for ${shift.eventName}';
        break;
      case 'offer':
        title = 'New Shift Change Offer';
        body = 'Someone offered to take your shift for ${shift.eventName}';
        break;
      case 'approved':
        title = 'Shift Change Approved';
        body = 'Your shift change for ${shift.eventName} has been approved';
        break;
      default:
        title = 'Shift Update';
        body = 'There is an update to your shift for ${shift.eventName}';
    }
    
    await showNotification(
      title: title,
      body: body,
      channelId: AppConstants.shiftsChannel,
      channelName: 'Shift Notifications',
      channelDescription: 'Notifications for shift changes and updates',
      payload: 'shift:${shift.id}'
    );
  }
  
  // 3. Event Notification
  Future<void> notifyEvent(EventModel event, String notificationType) async {
    String title;
    String body;
    
    switch (notificationType) {
      case 'new':
        title = 'New Event Created';
        body = 'New event: ${event.name} on ${event.date.day}/${event.date.month}/${event.date.year}';
        break;
      case 'update':
        title = 'Event Updated';
        body = 'Event updated: ${event.name}';
        break;
      case 'reminder':
        title = 'Upcoming Event';
        body = 'Reminder: ${event.name} is tomorrow';
        break;
      default:
        title = 'Event Update';
        body = 'There is an update to the event: ${event.name}';
    }
    
    await showNotification(
      title: title,
      body: body,
      channelId: AppConstants.eventsChannel,
      channelName: 'Event Notifications',
      channelDescription: 'Notifications for events',
      payload: 'event:${event.id}'
    );
  }
  
  // 4. Meeting Notification
  Future<void> notifyMeeting(MeetingModel meeting, String notificationType) async {
    String title;
    String body;
    
    switch (notificationType) {
      case 'new':
        title = 'New Team Meeting';
        body = 'New meeting: ${meeting.title} on ${meeting.date.day}/${meeting.date.month}/${meeting.date.year}';
        break;
      case 'reminder':
        title = 'Meeting Reminder';
        body = 'Reminder: Meeting "${meeting.title}" is tomorrow';
        break;
      case 'update':
        title = 'Meeting Updated';
        body = 'Meeting "${meeting.title}" has been updated';
        break;
      default:
        title = 'Meeting Update';
        body = 'There is an update to the meeting: ${meeting.title}';
    }
    
    await showNotification(
      title: title,
      body: body,
      channelId: AppConstants.meetingsChannel,
      channelName: 'Meeting Notifications',
      channelDescription: 'Notifications for team meetings',
      payload: 'meeting:${meeting.id}'
    );
  }
  
  // 5. Schedule notifications for upcoming events
  Future<void> scheduleEventReminder(EventModel event) async {
    // Schedule a notification for 1 day before the event
    final reminderDate = event.date.subtract(const Duration(days: 1));
    
    // Only schedule if the reminder date is in the future
    if (reminderDate.isAfter(DateTime.now())) {
      await scheduleNotification(
        title: 'Event Tomorrow',
        body: 'Don\'t forget: ${event.name} is tomorrow!',
        scheduledDate: reminderDate,
        channelId: AppConstants.eventsChannel,
        channelName: 'Event Reminders',
        channelDescription: 'Reminders for upcoming events',
        payload: 'event:${event.id}'
      );
    }
  }
  
  // 6. Schedule notifications for upcoming meetings
  Future<void> scheduleMeetingReminder(MeetingModel meeting) async {
    // Schedule a notification for 1 day before the meeting
    final reminderDate = meeting.date.subtract(const Duration(days: 1));
    
    // Only schedule if the reminder date is in the future
    if (reminderDate.isAfter(DateTime.now())) {
      await scheduleNotification(
        title: 'Meeting Tomorrow',
        body: 'Don\'t forget: Meeting "${meeting.title}" is tomorrow!',
        scheduledDate: reminderDate,
        channelId: AppConstants.meetingsChannel,
        channelName: 'Meeting Reminders',
        channelDescription: 'Reminders for upcoming meetings',
        payload: 'meeting:${meeting.id}'
      );
    }
  }

  // Cancel notification
  Future<void> cancelNotification(int id) async {
    await _notificationsPlugin.cancel(id);
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }
}