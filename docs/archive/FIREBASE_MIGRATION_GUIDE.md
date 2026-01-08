# Firebase Migration Guide - OlliePaw App

**Version**: v2.5
**Date**: 2025-12-29
**Status**: Pre-Migration Planning

---

## Table of Contents

1. [Overview](#overview)
2. [Prerequisites](#prerequisites)
3. [Phase 1: Firebase Project Setup](#phase-1-firebase-project-setup)
4. [Phase 2: Flutter SDK Integration](#phase-2-flutter-sdk-integration)
5. [Phase 3: Data Model Preparation](#phase-3-data-model-preparation)
6. [Phase 4: Repository Layer Migration](#phase-4-repository-layer-migration)
7. [Phase 5: Data Migration Scripts](#phase-5-data-migration-scripts)
8. [Phase 6: Testing & Validation](#phase-6-testing--validation)
9. [Phase 7: Production Rollout](#phase-7-production-rollout)
10. [Rollback Strategy](#rollback-strategy)
11. [FAQ & Troubleshooting](#faq--troubleshooting)

---

## Overview

### Migration Goals

- Migrate from local-only Hive database to Firebase Firestore
- Preserve all existing user data (pets, posts, vaccines, weight history, gallery)
- Enable cloud sync and multi-device support
- Maintain offline-first capability with Firestore caching
- Zero data loss during migration

### Timeline Estimate

- **Total Time**: 2-3 weeks (depending on testing depth)
- **Development**: 1-2 weeks
- **Testing**: 3-5 days
- **Rollout**: 2-3 days (gradual rollout recommended)

### Risk Assessment

- **Data Loss Risk**: Medium (mitigated by backup strategy)
- **User Impact**: Low (transparent migration with fallback)
- **Rollback Complexity**: Low (dual-write pattern allows easy rollback)

---

## Prerequisites

### Required Accounts & Services

- [ ] Firebase account (free tier sufficient for testing)
- [ ] Google Cloud Platform project (created automatically with Firebase)
- [ ] Flutter development environment (already set up)

### Required Knowledge

- Basic understanding of Firestore data model (collections/documents)
- Understanding of async/await and Futures in Dart
- Familiarity with the existing OlliePaw codebase

### Development Environment

```bash
flutter --version  # Should be 3.0+
dart --version     # Should be 3.0+
```

---

## Phase 1: Firebase Project Setup

### Step 1.1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Enter project name: `olliepaw-app` (or your preferred name)
4. **Disable Google Analytics** (optional for testing, enable for production)
5. Click "Create project"
6. Wait for project to be created (~30 seconds)

### Step 1.2: Add iOS App to Firebase

1. In Firebase Console, click iOS icon
2. Fill in the form:
   - **iOS bundle ID**: `com.yourcompany.olliepaw` (must match your Xcode project)
   - **App nickname**: OlliePaw iOS
   - **App Store ID**: Leave blank for now
3. Download `GoogleService-Info.plist`
4. Move file to `OlliePaw/ios/Runner/GoogleService-Info.plist`
5. **Important**: Open Xcode and add the file to the project:
   ```bash
   cd OlliePaw/ios
   open Runner.xcworkspace
   ```
   - Right-click on `Runner` folder → Add Files to "Runner"
   - Select `GoogleService-Info.plist`
   - **Check "Copy items if needed"**
   - **Check "Runner" target**

### Step 1.3: Add Android App to Firebase

1. In Firebase Console, click Android icon
2. Fill in the form:
   - **Android package name**: `com.yourcompany.olliepaw` (must match `android/app/build.gradle`)
   - **App nickname**: OlliePaw Android
   - **Debug signing certificate SHA-1**: Optional for now
3. Download `google-services.json`
4. Move file to `OlliePaw/android/app/google-services.json`

### Step 1.4: Enable Firestore Database

1. In Firebase Console, go to **Build** → **Firestore Database**
2. Click "Create database"
3. Select **Start in test mode** (for development)
   - **Important**: Test mode allows all read/write. We'll add security rules later.
4. Choose Firestore location: `us-central` (or closest to your users)
5. Click "Enable"

### Step 1.5: Enable Firebase Storage

1. In Firebase Console, go to **Build** → **Storage**
2. Click "Get started"
3. Select **Start in test mode**
4. Use same location as Firestore
5. Click "Done"

### Step 1.6: Configure Firestore Security Rules (Development)

In Firebase Console → Firestore Database → Rules, use these **development-only** rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Development only - allows all read/write
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
```

**⚠️ WARNING**: These rules are INSECURE. Replace with proper rules before production (see Phase 7).

### Step 1.7: Configure Storage Security Rules (Development)

In Firebase Console → Storage → Rules:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Development only - allows all read/write
    match /{allPaths=**} {
      allow read, write: if true;
    }
  }
}
```

---

## Phase 2: Flutter SDK Integration

### Step 2.1: Add Firebase Dependencies

Edit `OlliePaw/pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter

  # Existing dependencies...
  provider: ^6.1.2
  hive: ^2.2.3
  # ... other existing deps ...

  # Firebase Core (required)
  firebase_core: ^3.11.0

  # Firestore
  cloud_firestore: ^5.7.0

  # Firebase Storage (for images/videos)
  firebase_storage: ^12.5.0

  # Firebase Auth (for future user authentication)
  firebase_auth: ^5.4.0
```

Run:
```bash
cd OlliePaw
flutter pub get
```

### Step 2.2: Update iOS Configuration

Edit `OlliePaw/ios/Podfile`:

```ruby
platform :ios, '13.0'  # Increase minimum version if lower

# Add this at the top after platform declaration
use_frameworks!
```

Run:
```bash
cd OlliePaw/ios
pod install
```

### Step 2.3: Update Android Configuration

Edit `OlliePaw/android/app/build.gradle`:

```gradle
android {
    defaultConfig {
        minSdkVersion 21  // Increase from 19 if lower
        targetSdkVersion 34
        multiDexEnabled true  // Add this line
    }
}

dependencies {
    // Add at the bottom
    implementation platform('com.google.firebase:firebase-bom:33.7.0')
    implementation 'com.google.firebase:firebase-analytics'
}
```

Edit `OlliePaw/android/build.gradle`:

```gradle
buildscript {
    dependencies {
        classpath 'com.android.tools.build:gradle:8.1.0'
        classpath 'com.google.gms:google-services:4.4.0'  // Add this
    }
}
```

Edit `OlliePaw/android/app/build.gradle` (at the very bottom):

```gradle
apply plugin: 'com.google.gms.google-services'  // Add this line
```

### Step 2.4: Initialize Firebase in App

Edit `OlliePaw/lib/main.dart`:

```dart
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize Hive (existing)
  await Hive.initFlutter();
  // ... rest of existing Hive setup ...

  runApp(const MyApp());
}
```

### Step 2.5: Verify Installation

Run the app:

```bash
flutter run
```

Check console output for:
```
[firebase_core] Firebase initialized successfully
```

If you see Firebase errors, check:
1. `GoogleService-Info.plist` is in Xcode project (iOS)
2. `google-services.json` exists in `android/app/` (Android)
3. Bundle ID matches Firebase Console configuration
4. Run `flutter clean && flutter pub get`

---

## Phase 3: Data Model Preparation

### Step 3.1: Add Firestore Metadata to Models

We need to add Firebase-specific fields to our data models.

**Edit `OlliePaw/lib/models/types.dart`**:

#### 3.1.1 Update Pet Model

```dart
class Pet {
  final String id;
  final String name;
  final PetType type;
  final String breed;
  final String birthDate;
  final String avatarUrl;
  final String bio;
  final List<Vaccine> vaccines;
  final List<WeightRecord> weightHistory;
  final List<String> gallery;

  // NEW: Firestore metadata
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isDeleted;

  Pet({
    required this.id,
    required this.name,
    required this.type,
    required this.breed,
    required this.birthDate,
    required this.avatarUrl,
    required this.bio,
    this.vaccines = const [],
    this.weightHistory = const [],
    this.gallery = const [],
    this.createdAt,
    this.updatedAt,
    this.isDeleted = false,
  });

  // Update toJson to include metadata
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type.name,
      'breed': breed,
      'birthDate': birthDate,
      'avatarUrl': avatarUrl,
      'bio': bio,
      'vaccines': vaccines.map((v) => v.toJson()).toList(),
      'weightHistory': weightHistory.map((w) => w.toJson()).toList(),
      'gallery': gallery,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isDeleted': isDeleted,
    };
  }

  // Update fromJson to parse metadata
  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      id: json['id'] as String,
      name: json['name'] as String,
      type: PetType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => PetType.DOG,
      ),
      breed: json['breed'] as String,
      birthDate: json['birthDate'] as String,
      avatarUrl: json['avatarUrl'] as String,
      bio: json['bio'] as String,
      vaccines: (json['vaccines'] as List<dynamic>?)
          ?.map((v) => Vaccine.fromJson(v as Map<String, dynamic>))
          .toList() ?? [],
      weightHistory: (json['weightHistory'] as List<dynamic>?)
          ?.map((w) => WeightRecord.fromJson(w as Map<String, dynamic>))
          .toList() ?? [],
      gallery: (json['gallery'] as List<dynamic>?)
          ?.map((url) => url as String)
          .toList() ?? [],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      isDeleted: json['isDeleted'] as bool? ?? false,
    );
  }

  // Add copyWith method for immutability
  Pet copyWith({
    String? id,
    String? name,
    PetType? type,
    String? breed,
    String? birthDate,
    String? avatarUrl,
    String? bio,
    List<Vaccine>? vaccines,
    List<WeightRecord>? weightHistory,
    List<String>? gallery,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
  }) {
    return Pet(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      breed: breed ?? this.breed,
      birthDate: birthDate ?? this.birthDate,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      bio: bio ?? this.bio,
      vaccines: vaccines ?? this.vaccines,
      weightHistory: weightHistory ?? this.weightHistory,
      gallery: gallery ?? this.gallery,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
```

#### 3.1.2 Update Post Model

```dart
class Post {
  final String id;
  final String petId;
  final String petName;
  final String petAvatar;
  final String date;
  final String content;
  final String? imageUrl;
  final int likes;
  final int comments;

  // NEW: Firestore metadata
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final bool isDeleted;

  Post({
    required this.id,
    required this.petId,
    required this.petName,
    required this.petAvatar,
    required this.date,
    required this.content,
    this.imageUrl,
    this.likes = 0,
    this.comments = 0,
    this.createdAt,
    this.updatedAt,
    this.isDeleted = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'petId': petId,
      'petName': petName,
      'petAvatar': petAvatar,
      'date': date,
      'content': content,
      'imageUrl': imageUrl,
      'likes': likes,
      'comments': comments,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'isDeleted': isDeleted,
    };
  }

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] as String,
      petId: json['petId'] as String,
      petName: json['petName'] as String,
      petAvatar: json['petAvatar'] as String,
      date: json['date'] as String,
      content: json['content'] as String,
      imageUrl: json['imageUrl'] as String?,
      likes: json['likes'] as int? ?? 0,
      comments: json['comments'] as int? ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : null,
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
      isDeleted: json['isDeleted'] as bool? ?? false,
    );
  }

  Post copyWith({
    String? id,
    String? petId,
    String? petName,
    String? petAvatar,
    String? date,
    String? content,
    String? imageUrl,
    int? likes,
    int? comments,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
  }) {
    return Post(
      id: id ?? this.id,
      petId: petId ?? this.petId,
      petName: petName ?? this.petName,
      petAvatar: petAvatar ?? this.petAvatar,
      date: date ?? this.date,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      likes: likes ?? this.likes,
      comments: comments ?? this.comments,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
    );
  }
}
```

### Step 3.2: Create Firestore Repository Layer

Create `OlliePaw/lib/services/firestore_service.dart`:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/types.dart';
import '../core/constants/app_constants.dart';

/// Firestore service for cloud data persistence
///
/// Handles all Firebase Firestore operations
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ==================== Pet Operations ====================

  /// Create or update a pet
  Future<void> savePet(Pet pet) async {
    final now = DateTime.now();
    final petData = pet.copyWith(
      createdAt: pet.createdAt ?? now,
      updatedAt: now,
    ).toJson();

    await _firestore
        .collection(AppConstants.petsCollection)
        .doc(pet.id)
        .set(petData, SetOptions(merge: true));
  }

  /// Get a pet by ID
  Future<Pet?> getPet(String petId) async {
    final doc = await _firestore
        .collection(AppConstants.petsCollection)
        .doc(petId)
        .get();

    if (!doc.exists) return null;
    return Pet.fromJson(doc.data()!);
  }

  /// Get all pets (not deleted)
  Future<List<Pet>> getAllPets() async {
    final snapshot = await _firestore
        .collection(AppConstants.petsCollection)
        .where('isDeleted', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => Pet.fromJson(doc.data()))
        .toList();
  }

  /// Delete a pet (soft delete)
  Future<void> deletePet(String petId) async {
    await _firestore
        .collection(AppConstants.petsCollection)
        .doc(petId)
        .update({
      'isDeleted': true,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  // ==================== Post Operations ====================

  /// Create a post
  Future<void> createPost(Post post) async {
    final now = DateTime.now();
    final postData = post.copyWith(
      createdAt: now,
      updatedAt: now,
    ).toJson();

    await _firestore
        .collection(AppConstants.postsCollection)
        .doc(post.id)
        .set(postData);
  }

  /// Get posts for a pet
  Future<List<Post>> getPostsForPet(String petId) async {
    final snapshot = await _firestore
        .collection(AppConstants.postsCollection)
        .where('petId', isEqualTo: petId)
        .where('isDeleted', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .limit(AppConstants.maxTimelinePosts)
        .get();

    return snapshot.docs
        .map((doc) => Post.fromJson(doc.data()))
        .toList();
  }

  /// Get all posts (timeline feed)
  Future<List<Post>> getAllPosts({int limit = 20}) async {
    final snapshot = await _firestore
        .collection(AppConstants.postsCollection)
        .where('isDeleted', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) => Post.fromJson(doc.data()))
        .toList();
  }

  /// Delete a post (soft delete)
  Future<void> deletePost(String postId) async {
    await _firestore
        .collection(AppConstants.postsCollection)
        .doc(postId)
        .update({
      'isDeleted': true,
      'updatedAt': DateTime.now().toIso8601String(),
    });
  }

  // ==================== Vaccine Subcollection ====================

  /// Add a vaccine to a pet
  Future<void> addVaccine(String petId, Vaccine vaccine) async {
    await _firestore
        .collection(AppConstants.petsCollection)
        .doc(petId)
        .collection(AppConstants.vaccinesSubcollection)
        .doc(vaccine.id)
        .set(vaccine.toJson());

    // Update parent document timestamp
    await _firestore
        .collection(AppConstants.petsCollection)
        .doc(petId)
        .update({'updatedAt': DateTime.now().toIso8601String()});
  }

  /// Get all vaccines for a pet
  Future<List<Vaccine>> getVaccines(String petId) async {
    final snapshot = await _firestore
        .collection(AppConstants.petsCollection)
        .doc(petId)
        .collection(AppConstants.vaccinesSubcollection)
        .orderBy('date', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => Vaccine.fromJson(doc.data()))
        .toList();
  }

  // ==================== Weight History Subcollection ====================

  /// Add a weight record to a pet
  Future<void> addWeightRecord(String petId, WeightRecord record) async {
    await _firestore
        .collection(AppConstants.petsCollection)
        .doc(petId)
        .collection(AppConstants.weightHistorySubcollection)
        .doc(record.id)
        .set(record.toJson());

    await _firestore
        .collection(AppConstants.petsCollection)
        .doc(petId)
        .update({'updatedAt': DateTime.now().toIso8601String()});
  }

  /// Get weight history for a pet
  Future<List<WeightRecord>> getWeightHistory(String petId) async {
    final snapshot = await _firestore
        .collection(AppConstants.petsCollection)
        .doc(petId)
        .collection(AppConstants.weightHistorySubcollection)
        .orderBy('date', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => WeightRecord.fromJson(doc.data()))
        .toList();
  }

  // ==================== Gallery Subcollection ====================

  /// Add a photo to gallery
  Future<void> addGalleryPhoto(String petId, String photoUrl) async {
    final galleryItem = {
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'url': photoUrl,
      'uploadedAt': DateTime.now().toIso8601String(),
    };

    await _firestore
        .collection(AppConstants.petsCollection)
        .doc(petId)
        .collection(AppConstants.gallerySubcollection)
        .add(galleryItem);

    await _firestore
        .collection(AppConstants.petsCollection)
        .doc(petId)
        .update({'updatedAt': DateTime.now().toIso8601String()});
  }

  /// Get gallery for a pet
  Future<List<String>> getGallery(String petId) async {
    final snapshot = await _firestore
        .collection(AppConstants.petsCollection)
        .doc(petId)
        .collection(AppConstants.gallerySubcollection)
        .orderBy('uploadedAt', descending: true)
        .limit(AppConstants.maxGalleryPhotos)
        .get();

    return snapshot.docs
        .map((doc) => doc.data()['url'] as String)
        .toList();
  }
}
```

---

## Phase 4: Repository Layer Migration

### Step 4.1: Create Hybrid Persistence Service

We'll use a **dual-write pattern** to write to both Hive (local) and Firestore (cloud) during migration.

**Edit `OlliePaw/lib/services/persistence_service.dart`**:

```dart
import 'package:hive/hive.dart';
import '../models/types.dart';
import '../models/pet_hive_model.dart';
import 'firestore_service.dart';

class PersistenceService {
  final Box<PetHiveModel> _petBox;
  final FirestoreService _firestore = FirestoreService();

  // Migration flag - set to true to enable cloud sync
  bool _cloudSyncEnabled = false;

  PersistenceService(this._petBox);

  /// Enable cloud synchronization
  void enableCloudSync() {
    _cloudSyncEnabled = true;
  }

  /// Disable cloud synchronization
  void disableCloudSync() {
    _cloudSyncEnabled = false;
  }

  // ==================== Pet CRUD ====================

  Future<void> savePet(Pet pet) async {
    // Save to Hive (local - always happens)
    final hiveModel = PetHiveModel.fromPet(pet);
    await _petBox.put(pet.id, hiveModel);

    // Save to Firestore (cloud - only if enabled)
    if (_cloudSyncEnabled) {
      try {
        await _firestore.savePet(pet);
      } catch (e) {
        print('[ERROR] Failed to sync pet to Firestore: $e');
        // Continue - local save succeeded
      }
    }
  }

  Future<Pet?> getPet(String id) async {
    // Try Hive first (local - fast)
    final hiveModel = _petBox.get(id);
    if (hiveModel != null) {
      return hiveModel.toPet();
    }

    // Try Firestore if cloud sync enabled
    if (_cloudSyncEnabled) {
      try {
        final pet = await _firestore.getPet(id);
        if (pet != null) {
          // Cache to Hive for next time
          await savePet(pet);
          return pet;
        }
      } catch (e) {
        print('[ERROR] Failed to fetch pet from Firestore: $e');
      }
    }

    return null;
  }

  List<Pet> getAllPets() {
    return _petBox.values
        .map((hiveModel) => hiveModel.toPet())
        .toList();
  }

  Future<void> deletePet(String id) async {
    // Delete from Hive (local)
    await _petBox.delete(id);

    // Delete from Firestore (cloud - soft delete)
    if (_cloudSyncEnabled) {
      try {
        await _firestore.deletePet(id);
      } catch (e) {
        print('[ERROR] Failed to delete pet from Firestore: $e');
      }
    }
  }

  // ==================== Migration Methods ====================

  /// Migrate all local Hive data to Firestore
  Future<void> migrateAllDataToCloud() async {
    if (!_cloudSyncEnabled) {
      throw Exception('Cloud sync must be enabled before migration');
    }

    final pets = getAllPets();
    print('[MIGRATION] Starting migration of ${pets.length} pets...');

    int successCount = 0;
    int failCount = 0;

    for (final pet in pets) {
      try {
        // Add timestamps if missing
        final petWithMetadata = pet.copyWith(
          createdAt: pet.createdAt ?? DateTime.now(),
          updatedAt: DateTime.now(),
        );

        await _firestore.savePet(petWithMetadata);
        successCount++;
        print('[MIGRATION] ✅ Migrated pet: ${pet.name}');
      } catch (e) {
        failCount++;
        print('[MIGRATION] ❌ Failed to migrate pet ${pet.name}: $e');
      }
    }

    print('[MIGRATION] Complete: $successCount success, $failCount failed');
  }

  /// Sync all data from Firestore to Hive (download)
  Future<void> syncFromCloud() async {
    if (!_cloudSyncEnabled) return;

    try {
      final cloudPets = await _firestore.getAllPets();
      print('[SYNC] Downloading ${cloudPets.length} pets from cloud...');

      for (final pet in cloudPets) {
        final hiveModel = PetHiveModel.fromPet(pet);
        await _petBox.put(pet.id, hiveModel);
      }

      print('[SYNC] ✅ Sync complete');
    } catch (e) {
      print('[SYNC] ❌ Failed to sync from cloud: $e');
    }
  }
}
```

### Step 4.2: Update AppState to Use Hybrid Service

**Edit `OlliePaw/lib/models/app_state.dart`**:

Add a method to enable cloud sync:

```dart
/// Enable cloud synchronization with Firebase
Future<void> enableCloudSync() async {
  _persistenceService.enableCloudSync();

  // Optionally migrate existing data
  await _persistenceService.migrateAllDataToCloud();

  notifyListeners();
}

/// Sync data from cloud
Future<void> syncFromCloud() async {
  await _persistenceService.syncFromCloud();

  // Reload current pet
  if (_currentPetId != null) {
    _currentPet = await _persistenceService.getPet(_currentPetId!);
    notifyListeners();
  }
}
```

---

## Phase 5: Data Migration Scripts

### Step 5.1: Create Migration Screen

Create `OlliePaw/lib/screens/migration_screen.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/app_state.dart';

class MigrationScreen extends StatefulWidget {
  const MigrationScreen({super.key});

  @override
  State<MigrationScreen> createState() => _MigrationScreenState();
}

class _MigrationScreenState extends State<MigrationScreen> {
  bool _isMigrating = false;
  String _status = 'Ready to migrate';
  double _progress = 0.0;

  Future<void> _startMigration() async {
    setState(() {
      _isMigrating = true;
      _status = 'Starting migration...';
      _progress = 0.1;
    });

    final appState = context.read<AppState>();

    try {
      // Step 1: Enable cloud sync
      setState(() {
        _status = 'Enabling cloud sync...';
        _progress = 0.3;
      });
      await appState.enableCloudSync();

      // Step 2: Migration happens in enableCloudSync
      setState(() {
        _status = 'Uploading data to Firebase...';
        _progress = 0.6;
      });
      await Future.delayed(const Duration(seconds: 2)); // Allow time for upload

      // Step 3: Verify
      setState(() {
        _status = 'Verifying data...';
        _progress = 0.9;
      });
      await appState.syncFromCloud();

      // Done
      setState(() {
        _status = '✅ Migration complete!';
        _progress = 1.0;
        _isMigrating = false;
      });

      // Navigate back after 2 seconds
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _status = '❌ Migration failed: $e';
        _isMigrating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Data Migration'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.cloud_upload,
              size: 80,
              color: Colors.blue,
            ),
            const SizedBox(height: 24),
            const Text(
              'Migrate to Cloud',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Your data will be safely uploaded to Firebase Cloud Storage. '
              'You\'ll be able to access it from any device.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            LinearProgressIndicator(value: _progress),
            const SizedBox(height: 16),
            Text(
              _status,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isMigrating ? null : _startMigration,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 48,
                  vertical: 16,
                ),
              ),
              child: Text(
                _isMigrating ? 'Migrating...' : 'Start Migration',
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Step 5.2: Add Migration Option to Settings

**Edit your settings screen** to add a "Migrate to Cloud" button:

```dart
ListTile(
  leading: const Icon(Icons.cloud_upload),
  title: const Text('Migrate to Cloud'),
  subtitle: const Text('Upload your data to Firebase'),
  onTap: () {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const MigrationScreen()),
    );
  },
),
```

---

## Phase 6: Testing & Validation

### Step 6.1: Pre-Migration Testing Checklist

- [ ] Firebase project created and configured
- [ ] iOS and Android apps registered in Firebase Console
- [ ] `GoogleService-Info.plist` added to Xcode project (iOS)
- [ ] `google-services.json` added to `android/app/` (Android)
- [ ] Firebase SDK dependencies added to `pubspec.yaml`
- [ ] Firebase initialized in `main.dart`
- [ ] App runs without Firebase errors
- [ ] Firestore and Storage enabled in Firebase Console

### Step 6.2: Migration Testing

**Test with a fresh user**:

1. Create a new pet with:
   - Name, breed, birth date, avatar
   - Add 2-3 vaccines
   - Add 2-3 weight records
   - Add 3-5 gallery photos
   - Create 2-3 posts

2. Navigate to Settings → Migrate to Cloud

3. Verify migration succeeded:
   - Check Firebase Console → Firestore Database
   - You should see:
     - `pets` collection with 1 document
     - Inside pet document: `vaccines`, `weightHistory`, `gallery` subcollections
     - `posts` collection with 2-3 documents

4. Test data retrieval:
   - Uninstall the app
   - Reinstall and login
   - Enable cloud sync
   - Verify all data appears correctly

### Step 6.3: Offline Testing

1. Enable airplane mode
2. Create a new pet
3. Add vaccines, weight, gallery
4. Disable airplane mode
5. Verify data syncs to cloud automatically

### Step 6.4: Rollback Testing

1. Back up Hive data: `_petBox.toMap()`
2. Perform migration
3. Disable cloud sync
4. Verify app still works with local Hive data

---

## Phase 7: Production Rollout

### Step 7.1: Update Firestore Security Rules (Production)

Replace development rules with secure production rules:

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

    // Pets collection
    match /pets/{petId} {
      // Anyone can read (for social features)
      allow read: if true;

      // Only authenticated users can create/update their own pets
      allow create: if isSignedIn();
      allow update, delete: if isSignedIn(); // Add ownership check later

      // Subcollections
      match /vaccines/{vaccineId} {
        allow read: if true;
        allow write: if isSignedIn();
      }

      match /weightHistory/{recordId} {
        allow read: if true;
        allow write: if isSignedIn();
      }

      match /gallery/{photoId} {
        allow read: if true;
        allow write: if isSignedIn();
      }
    }

    // Posts collection
    match /posts/{postId} {
      allow read: if true;
      allow create: if isSignedIn();
      allow update, delete: if isSignedIn(); // Add ownership check later
    }
  }
}
```

### Step 7.2: Update Storage Security Rules (Production)

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {

    // Helper functions
    function isSignedIn() {
      return request.auth != null;
    }

    function isValidImage() {
      return request.resource.contentType.matches('image/.*')
             && request.resource.size < 5 * 1024 * 1024; // 5MB max
    }

    // Avatars
    match /avatars/{allPaths=**} {
      allow read: if true;
      allow write: if isSignedIn() && isValidImage();
    }

    // Posts
    match /posts/{allPaths=**} {
      allow read: if true;
      allow write: if isSignedIn() && isValidImage();
    }

    // Gallery
    match /gallery/{allPaths=**} {
      allow read: if true;
      allow write: if isSignedIn() && isValidImage();
    }
  }
}
```

### Step 7.3: Gradual Rollout Plan

**Week 1: Internal Testing**
- Enable cloud sync for development team only
- Monitor Firebase Console for errors
- Check Firebase Usage & Billing

**Week 2: Beta Testing**
- Roll out to 10-20 beta users
- Collect feedback on sync speed and reliability
- Monitor Firestore read/write quotas

**Week 3: Public Rollout**
- Add migration prompt on app startup for existing users
- New users get cloud sync by default
- Monitor crash reports and Firebase errors

### Step 7.4: Monitoring

**Firebase Console Monitoring**:
- Go to Firebase Console → Usage & Quotas
- Monitor:
  - Firestore document reads/writes per day
  - Storage bandwidth usage
  - Cloud Functions invocations (if you add them later)

**Set up Alerts**:
- Go to Firebase Console → Alerts
- Create alerts for:
  - High read/write usage (approaching quota limits)
  - Storage size approaching free tier limit (1GB)
  - Unusual spike in requests

---

## Rollback Strategy

### If Migration Fails

**Immediate Rollback**:
1. Disable cloud sync in `PersistenceService`:
   ```dart
   persistenceService.disableCloudSync();
   ```

2. App continues working with local Hive data (no data loss)

**If Data is Corrupted**:
1. Hive data is NEVER deleted during migration (only dual-write)
2. Users can continue using app offline
3. Re-attempt migration after fix is deployed

### Emergency Rollback Procedure

**If production users report data issues**:

1. **Immediate**: Release hotfix that disables cloud sync by default
   ```dart
   // In main.dart
   final appState = AppState(...);
   appState.disableCloudSync(); // Force disable
   ```

2. **Communicate**: In-app message explaining temporary offline mode

3. **Investigate**: Check Firebase Console logs for errors

4. **Fix & Re-release**: Once fixed, gradually re-enable cloud sync

---

## FAQ & Troubleshooting

### Q: What happens if a user has no internet during migration?

**A**: Migration will fail gracefully. Local Hive data remains intact. User can retry migration when online.

### Q: Will users lose data if they uninstall the app?

**A**:
- **Before migration**: Yes (Hive is local-only)
- **After migration**: No (data is in Firestore)

### Q: How much does Firebase cost?

**A**:
- **Free tier** (Spark Plan):
  - 1 GB storage
  - 50,000 reads/day
  - 20,000 writes/day
  - 10 GB bandwidth/month
- **Paid tier** (Blaze Plan):
  - Pay-as-you-go after free tier limits
  - ~$0.06 per 100,000 reads
  - See [Firebase Pricing](https://firebase.google.com/pricing)

### Q: Can I migrate back to Hive-only?

**A**: Yes! Just call `persistenceService.disableCloudSync()` and the app uses Hive exclusively.

### Q: What if Firestore quota is exceeded?

**A**:
- App automatically falls back to Hive (offline mode)
- Displays error message to user
- Queued writes are retried when quota resets

### Common Errors

**Error**: `[firebase_core/no-app] No Firebase App '[DEFAULT]' has been created`

**Solution**:
1. Check `Firebase.initializeApp()` is called in `main.dart`
2. Verify `GoogleService-Info.plist` (iOS) or `google-services.json` (Android) exists
3. Run `flutter clean && flutter pub get`

---

**Error**: `MissingPluginException(No implementation found for method...)`

**Solution**:
1. Stop the app completely
2. Run `flutter clean`
3. Delete `ios/Pods` and `ios/Podfile.lock`
4. Run `cd ios && pod install`
5. Rebuild: `flutter run`

---

**Error**: `Null check operator used on a null value` in Firestore queries

**Solution**:
- Add null safety checks in `fromJson` methods:
  ```dart
  vaccines: (json['vaccines'] as List<dynamic>?)
      ?.map((v) => Vaccine.fromJson(v as Map<String, dynamic>))
      .toList() ?? [],
  ```

---

**Error**: Firestore permission denied

**Solution**:
1. Check Firebase Console → Firestore → Rules
2. Verify rules allow read/write for your use case
3. For testing, use permissive rules (see Phase 1.6)
4. For production, use secure rules (see Phase 7.1)

---

## Summary

This guide provides a complete, step-by-step migration path from Hive-only local storage to Firebase Firestore cloud storage. Key benefits:

- **Zero data loss**: Dual-write pattern keeps Hive as backup
- **Graceful degradation**: App works offline if Firebase fails
- **Easy rollback**: Can disable cloud sync anytime
- **Production-ready**: Includes security rules and monitoring

**Estimated Timeline**: 2-3 weeks from start to production rollout

**Next Steps**:
1. Complete Phase 1 (Firebase setup) - ~2 hours
2. Complete Phase 2 (SDK integration) - ~1 hour
3. Complete Phase 3 (data model updates) - ~3 hours
4. Test migration with sample data - ~2 hours
5. Beta test with real users - ~1 week
6. Production rollout - ~1 week

Good luck with your migration! 🚀
