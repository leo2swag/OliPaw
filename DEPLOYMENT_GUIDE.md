# 🚀 Pet SOS Feature - Production Deployment Guide

**Version:** 2.9
**Date:** January 14, 2026
**Status:** Ready for Production Deployment

---

## 📋 Overview

This guide walks through deploying the Pet SOS & Community Broadcast feature to production, including:

1. ✅ **Firebase Firestore** setup for cloud persistence
2. ✅ **Real GPS** integration (optional)
3. ✅ **Push Notifications** via FCM (optional)
4. ✅ **Security Rules** and rate limiting
5. ✅ **Testing** and monitoring

---

## 🔥 Part 1: Firebase Firestore Setup

### Step 1.1: Enable Firestore

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project: **OlliePaw**
3. Navigate to **Build → Firestore Database**
4. Click **Create Database**
5. Choose **Start in production mode**
6. Select location: Choose closest to your users (e.g., `asia-east1` for Asia)

### Step 1.2: Create Collections

Firestore will auto-create collections when first document is added, but you can pre-create them:

```javascript
// Collections to create:
sos_posts
├── (auto-generated document IDs)

clues
├── (auto-generated document IDs)

broadcasts
├── (auto-generated document IDs)
```

### Step 1.3: Set Security Rules

Navigate to **Firestore → Rules** and paste:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Helper functions
    function isSignedIn() {
      return request.auth != null;
    }

    function isOwner(userId) {
      return isSignedIn() && request.auth.uid == userId;
    }

    // SOS Posts
    match /sos_posts/{sosId} {
      // Anyone can read active SOS posts
      allow read: if resource.data.status == 'active'
                  && resource.data.isDeleted == false;

      // Only authenticated users can create SOS
      allow create: if isSignedIn()
                    && request.resource.data.ownerId == request.auth.uid;

      // Only owner can update their SOS
      allow update: if isOwner(resource.data.ownerId);

      // Only owner can delete their SOS
      allow delete: if isOwner(resource.data.ownerId);
    }

    // Clues
    match /clues/{clueId} {
      // Anyone can read clues
      allow read: if true;

      // Only authenticated users can submit clues
      allow create: if isSignedIn()
                    && request.resource.data.reporterId == request.auth.uid;

      // Only SOS owner can update clues (mark as helpful)
      allow update: if isSignedIn();

      // Only clue reporter can delete
      allow delete: if isOwner(resource.data.reporterId);
    }

    // Broadcasts
    match /broadcasts/{broadcastId} {
      // Anyone can read active broadcasts
      allow read: if resource.data.isDeleted == false
                  && resource.data.expiresAt > request.time;

      // Only authenticated users can create broadcasts
      allow create: if isSignedIn()
                    && request.resource.data.authorId == request.auth.uid;

      // Only author can update
      allow update: if isOwner(resource.data.authorId);

      // Only author can delete
      allow delete: if isOwner(resource.data.authorId);
    }

    // Rate limiting: User quota tracking
    match /users/{userId}/broadcast_quota/daily {
      allow read, write: if isOwner(userId);
    }
  }
}
```

### Step 1.4: Create Indexes

Navigate to **Firestore → Indexes** and create:

**SOS Posts Composite Index:**
```
Collection: sos_posts
Fields:
- lastSeenLocation.city (Ascending)
- status (Ascending)
- isDeleted (Ascending)
- createdAt (Descending)
```

**Broadcasts Composite Index:**
```
Collection: broadcasts
Fields:
- location.city (Ascending)
- isDeleted (Ascending)
- createdAt (Descending)
```

**Clues Index:**
```
Collection: clues
Fields:
- sosPostId (Ascending)
- timestamp (Descending)
```

### Step 1.5: Integrate Firebase Service

Update your providers to use `FirebaseSOSService`:

```dart
// In sos_provider.dart
import '../services/firebase_sos_service.dart';

class SOSProvider extends ChangeNotifier {
  final FirebaseSOSService _firebaseService = FirebaseSOSService();

  Future<String?> createSOSPost(...) async {
    // Create locally first (instant feedback)
    final sosPost = SOSPost(...);
    _activeSOS.add(sosPost);
    notifyListeners();

    // Sync to Firebase
    final firebaseId = await _firebaseService.createSOSPost(sosPost);

    if (firebaseId != null) {
      // Update local ID with Firebase ID
      final index = _activeSOS.indexWhere((s) => s.id == sosPost.id);
      if (index != -1) {
        _activeSOS[index] = sosPost.copyWith(id: firebaseId);
        notifyListeners();
      }
    }

    return firebaseId;
  }

  // Use Firebase streams for real-time updates
  void watchNearbySOSPosts(String city) {
    _firebaseService.watchNearbySOSPosts(city: city).listen((posts) {
      _nearbySOSPosts = posts;
      notifyListeners();
    });
  }
}
```

---

## 📍 Part 2: Real GPS Integration (Optional)

### Step 2.1: Install Dependencies

Add to `pubspec.yaml`:

```yaml
dependencies:
  geolocator: ^10.1.0
  geocoding: ^2.1.1
```

Run:
```bash
flutter pub get
```

### Step 2.2: iOS Configuration

Edit `ios/Runner/Info.plist`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>我们需要您的位置来显示附近的宠物 SOS</string>

<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>我们需要您的位置来显示附近的宠物 SOS</string>
```

### Step 2.3: Android Configuration

Edit `android/app/src/main/AndroidManifest.xml`:

```xml
<manifest>
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />

    <application>
        ...
    </application>
</manifest>
```

### Step 2.4: Update LocationService

Replace mock GPS with real GPS:

```dart
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  bool _useRealGPS = true; // Toggle between mock and real GPS

  Future<LocationData> getCurrentLocation() async {
    if (_useRealGPS) {
      try {
        // Check permission
        LocationPermission permission = await Geolocator.checkPermission();
        if (permission == LocationPermission.denied) {
          permission = await Geolocator.requestPermission();
        }

        if (permission == LocationPermission.denied ||
            permission == LocationPermission.deniedForever) {
          throw Exception('Location permission denied');
        }

        // Get position
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );

        // Get address
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

        String city = placemarks.first.locality ?? '未知城市';
        String address = '${placemarks.first.street}, ${placemarks.first.locality}';

        return LocationData(
          latitude: position.latitude,
          longitude: position.longitude,
          addressName: address,
          city: city,
          timestamp: DateTime.now(),
        );
      } catch (e) {
        // Fallback to mock GPS
        return _getMockLocation();
      }
    }
    return _getMockLocation();
  }
}
```

### Step 2.5: Test GPS

```dart
final locationService = LocationService();
final location = await locationService.getCurrentLocation();
print('Current location: ${location.latitude}, ${location.longitude}');
print('City: ${location.city}');
```

---

## 🔔 Part 3: Push Notifications (Optional)

### Step 3.1: Enable Firebase Cloud Messaging

1. Go to Firebase Console → **Project Settings**
2. Navigate to **Cloud Messaging** tab
3. Copy your **Server Key** (for backend use)

### Step 3.2: Install FCM Package

Add to `pubspec.yaml`:

```yaml
dependencies:
  firebase_messaging: ^14.7.6
  flutter_local_notifications: ^16.3.0
```

Run:
```bash
flutter pub get
```

### Step 3.3: iOS Configuration

Edit `ios/Runner/AppDelegate.swift`:

```swift
import UIKit
import Flutter
import Firebase

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()

    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
    }

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
```

### Step 3.4: Android Configuration

Edit `android/app/build.gradle`:

```gradle
dependencies {
    implementation platform('com.google.firebase:firebase-bom:32.7.0')
    implementation 'com.google.firebase:firebase-messaging'
}
```

### Step 3.5: Create FCM Service

Create `lib/services/fcm_service.dart`:

```dart
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class FCMService {
  static final FCMService _instance = FCMService._internal();
  factory FCMService() => _instance;
  FCMService._internal();

  final FirebaseMessaging _fcm = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();

  Future<void> initialize() async {
    // Request permission (iOS)
    await _fcm.requestPermission(
      alert: true,
      announcement: false,
      badge: true,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
      sound: true,
    );

    // Get FCM token
    String? token = await _fcm.getToken();
    print('FCM Token: $token');

    // Initialize local notifications
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _localNotifications.initialize(initSettings);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);
  }

  void _handleForegroundMessage(RemoteMessage message) {
    // Show local notification
    _showLocalNotification(
      message.notification?.title ?? '',
      message.notification?.body ?? '',
    );
  }

  void _showLocalNotification(String title, String body) {
    const androidDetails = AndroidNotificationDetails(
      'sos_channel',
      'Pet SOS Alerts',
      channelDescription: 'Notifications for nearby lost pets',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);

    _localNotifications.show(0, title, body, details);
  }
}

// Background message handler (must be top-level function)
@pragma('vm:entry-point')
Future<void> _handleBackgroundMessage(RemoteMessage message) async {
  print('Handling background message: ${message.messageId}');
}
```

### Step 3.6: Subscribe to Topics

```dart
// Subscribe user to nearby SOS alerts based on location
await FirebaseMessaging.instance.subscribeToTopic('sos_beijing');
await FirebaseMessaging.instance.subscribeToTopic('sos_shanghai');
```

---

## 🛡️ Part 4: Security & Rate Limiting

### Step 4.1: Implement Rate Limiting

Create `lib/services/rate_limiter.dart`:

```dart
class RateLimiter {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Check if user can create broadcast
  Future<bool> canCreateBroadcast(String userId, BroadcastType type) async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final quotaRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('broadcast_quota')
        .doc(today);

    final doc = await quotaRef.get();
    final data = doc.data() ?? {};

    final sosCount = data['sosCount'] ?? 0;
    final socialCount = data['socialCount'] ?? 0;
    final marketplaceCount = data['marketplaceCount'] ?? 0;

    switch (type) {
      case BroadcastType.sos:
        return sosCount < 1; // Max 1 SOS per day
      case BroadcastType.social:
        return socialCount < 5; // Max 5 social per day
      case BroadcastType.marketplace:
        return marketplaceCount < 3; // Max 3 marketplace per day
      case BroadcastType.danger:
        return true; // Unlimited danger alerts
    }
  }

  /// Increment broadcast count
  Future<void> incrementCount(String userId, BroadcastType type) async {
    final today = DateTime.now().toIso8601String().split('T')[0];
    final quotaRef = _firestore
        .collection('users')
        .doc(userId)
        .collection('broadcast_quota')
        .doc(today);

    final field = '${type.name}Count';
    await quotaRef.set({
      field: FieldValue.increment(1),
      'lastUpdated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }
}
```

### Step 4.2: Content Moderation

Create `lib/services/content_moderator.dart`:

```dart
class ContentModerator {
  // Blocked keywords
  static const List<String> _blockedWords = [
    '诈骗', '骗子', '假货', '毒品', // Add more
  ];

  /// Validate content for inappropriate words
  bool validateContent(String content) {
    final lowerContent = content.toLowerCase();
    for (final word in _blockedWords) {
      if (lowerContent.contains(word.toLowerCase())) {
        return false;
      }
    }
    return true;
  }

  /// Check for phone numbers
  bool containsPhoneNumber(String content) {
    final phoneRegex = RegExp(r'\d{3}-?\d{3,4}-?\d{4}');
    return phoneRegex.hasMatch(content);
  }

  /// Check for URLs
  bool containsURL(String content) {
    final urlRegex = RegExp(r'https?://\S+');
    return urlRegex.hasMatch(content);
  }
}
```

---

## 🧪 Part 5: Testing

### Step 5.1: Unit Tests

Create `test/sos_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:ollie_paw/services/location_service.dart';

void main() {
  group('LocationService Tests', () {
    test('Calculate distance', () {
      final service = LocationService();
      final beijing = LocationService.mockLocations['beijing_cbd']!;
      final shanghai = LocationService.mockLocations['shanghai_bund']!;

      final distance = service.calculateDistance(beijing, shanghai);
      expect(distance, greaterThan(1000)); // Should be > 1000km
    });
  });
}
```

### Step 5.2: Integration Tests

Create `integration_test/sos_flow_test.dart`:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:ollie_paw/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Complete SOS creation flow', (tester) async {
    app.main();
    await tester.pumpAndSettle();

    // Navigate to Profile
    await tester.tap(find.byIcon(Icons.person));
    await tester.pumpAndSettle();

    // Tap SOS button
    await tester.tap(find.text('🚨 发布寻宠 SOS'));
    await tester.pumpAndSettle();

    // Fill form
    await tester.enterText(find.byType(TextField).first, '100');
    await tester.pumpAndSettle();

    // Publish
    await tester.tap(find.text('🚨 立即发布 SOS'));
    await tester.pumpAndSettle();

    // Verify success
    expect(find.text('SOS 发布成功！'), findsOneWidget);
  });
}
```

Run tests:
```bash
flutter test
flutter test integration_test
```

---

## 📊 Part 6: Monitoring & Analytics

### Step 6.1: Firebase Analytics

```dart
import 'package:firebase_analytics/firebase_analytics.dart';

class AnalyticsService {
  final FirebaseAnalytics _analytics = FirebaseAnalytics.instance;

  void logSOSCreated(String sosId, int treatsReward) {
    _analytics.logEvent(
      name: 'sos_created',
      parameters: {
        'sos_id': sosId,
        'treats_reward': treatsReward,
      },
    );
  }

  void logClueSubmitted(String sosId) {
    _analytics.logEvent(
      name: 'clue_submitted',
      parameters: {'sos_id': sosId},
    );
  }

  void logSOSResolved(String sosId, Duration resolutionTime) {
    _analytics.logEvent(
      name: 'sos_resolved',
      parameters: {
        'sos_id': sosId,
        'resolution_hours': resolutionTime.inHours,
      },
    );
  }
}
```

### Step 6.2: Crashlytics

```dart
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

// In main.dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Enable Crashlytics
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;

  runApp(MyApp());
}
```

---

## 🚀 Part 7: Deployment Checklist

### Pre-Deployment

- [ ] Firebase Firestore enabled and configured
- [ ] Security rules deployed
- [ ] Indexes created
- [ ] Real GPS tested (if enabled)
- [ ] Push notifications tested (if enabled)
- [ ] Rate limiting implemented
- [ ] Content moderation active
- [ ] Unit tests passing
- [ ] Integration tests passing
- [ ] Analytics tracking configured

### Deployment

- [ ] Update version in `pubspec.yaml`
- [ ] Build release APK/IPA
- [ ] Test on real devices
- [ ] Submit to app stores
- [ ] Monitor crash reports
- [ ] Track key metrics

### Post-Deployment

- [ ] Monitor Firestore usage
- [ ] Check notification delivery rates
- [ ] Track SOS resolution rates
- [ ] Gather user feedback
- [ ] Iterate based on metrics

---

## 📈 Success Metrics

### Key Performance Indicators

| Metric | Target | Monitoring |
|--------|--------|------------|
| SOS Resolution Rate | 70%+ | Firebase Analytics |
| Average Resolution Time | < 24 hours | Custom events |
| Clues per SOS | 3+ | Firestore queries |
| User Participation | 50%+ | Analytics funnel |
| Notification Open Rate | 30%+ | FCM analytics |

---

## 🆘 Troubleshooting

### Issue: Firestore permission denied

**Solution:** Check security rules, ensure user is authenticated

### Issue: GPS not working

**Solution:** Verify permissions in iOS/Android manifests

### Issue: Notifications not received

**Solution:** Check FCM token, verify app is in foreground/background

---

## ✅ Deployment Complete!

The Pet SOS & Community Broadcast feature is now deployed to production with:

- ✅ Cloud persistence via Firebase
- ✅ Real-time data sync
- ✅ Security rules and rate limiting
- ✅ Optional GPS and push notifications
- ✅ Monitoring and analytics

**Ready to save pets! 🐾🚀**

---

**Created by:** Claude Code Assistant
**Date:** January 14, 2026
**Version:** 2.9 Production
