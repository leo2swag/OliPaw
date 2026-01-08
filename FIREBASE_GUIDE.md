# Firebase Integration Guide - OlliePaw
**Version**: 2.6
**Status**: Ready for Migration
**Last Updated**: 2026-01-08

---

## 📋 Overview

This guide consolidates all Firebase-related documentation for the OlliePaw project. Firebase provides authentication, cloud database, and file storage for the application.

**Key Services Used**:
- **Firebase Authentication** - User login/signup
- **Cloud Firestore** - NoSQL database for posts, pets, users
- **Firebase Storage** - Image and media storage
- **Firebase Security Rules** - Data access control

---

## ✅ Pre-Migration Checklist

Complete these steps BEFORE starting Firebase integration:

### 1. Development Environment

- [ ] Flutter SDK ≥3.2.0 installed
- [ ] Firebase CLI installed (`npm install -g firebase-tools`)
- [ ] FlutterFire CLI installed (`dart pub global activate flutterfire_cli`)
- [ ] Git repository clean (no uncommitted changes)

### 2. Firebase Project Setup

- [ ] Create Firebase project at [Firebase Console](https://console.firebase.google.com/)
- [ ] Enable Authentication (Email/Password provider)
- [ ] Create Firestore database (start in test mode)
- [ ] Enable Storage bucket
- [ ] Add iOS app (Bundle ID: `com.example.olliepaw`)
- [ ] Add Android app (Package name: `com.example.ollie_paw`)

### 3. Local Configuration

- [ ] Run `flutterfire configure` in project root
- [ ] Verify `lib/firebase_options.dart` generated
- [ ] Add Firebase config files to `.gitignore` (already done)
- [ ] Test Firebase initialization: `await Firebase.initializeApp()`

### 4. Code Readiness

- [ ] All providers use PersistenceService
- [ ] AuthProvider implemented (v2.6 ✅)
- [ ] FirestoreService skeleton exists (✅)
- [ ] Zero Flutter analyzer issues (✅)
- [ ] Existing tests pass

---

## 🚀 Step-by-Step Migration

### Phase 1: Firebase Authentication (Week 1)

#### Step 1.1: Configure Firebase Auth

```bash
# Enable Email/Password authentication in Firebase Console
# Authentication > Sign-in method > Email/Password > Enable
```

#### Step 1.2: Update AuthService

**File**: `lib/services/auth_service.dart`

Replace mock implementation with Firebase:

```dart
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

class AuthService {
  final firebase_auth.FirebaseAuth _firebaseAuth = firebase_auth.FirebaseAuth.instance;

  // Convert Firebase User to our AuthUser model
  AuthUser? _userFromFirebase(firebase_auth.User? user) {
    if (user == null) return null;

    return AuthUser(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
      photoUrl: user.photoURL,
      userType: 'owner',  // Default, override from Firestore
    );
  }

  @override
  Stream<AuthUser?> get authStateChanges {
    return _firebaseAuth.authStateChanges()
        .map(_userFromFirebase);
  }

  @override
  AuthUser? get currentUser {
    return _userFromFirebase(_firebaseAuth.currentUser);
  }

  @override
  Future<AuthUser> signUpWithEmailAndPassword({
    required String email,
    required String password,
    String? displayName,
    String? userType,
  }) async {
    try {
      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      if (displayName != null) {
        await credential.user?.updateDisplayName(displayName);
      }

      return _userFromFirebase(credential.user)!;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw AuthException(e.code, e.message ?? 'Unknown error');
    }
  }

  @override
  Future<AuthUser> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      return _userFromFirebase(credential.user)!;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw AuthException(e.code, e.message ?? 'Unknown error');
    }
  }

  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  @override
  Future<void> deleteAccount() async {
    await _firebaseAuth.currentUser?.delete();
  }
}
```

#### Step 1.3: Test Authentication

```dart
// Test in login screen
final authProvider = context.read<AuthProvider>();
final success = await authProvider.signIn(
  email: 'test@example.com',
  password: 'password123',
);

if (success) {
  print('Logged in: ${authProvider.email}');
}
```

**Validation**:
- [ ] User can sign up with email/password
- [ ] User can sign in
- [ ] User can sign out
- [ ] Auth state persists across app restarts
- [ ] Error messages display correctly

---

### Phase 2: Firestore Integration (Week 2)

#### Step 2.1: Firestore Data Model

**Collections Structure**:

```
users/
  {userId}/
    name: string
    email: string
    avatarUrl: string
    type: string ('owner'|'guest'|'merchant')
    createdAt: timestamp

    pets/ (subcollection)
      {petId}/
        name: string
        breed: string
        birthDate: string
        type: string ('dog'|'cat'|'other')
        bio: string
        avatarUrl: string
        vaccines: array
        weights: array

posts/
  {postId}/
    userId: string
    petId: string
    petName: string
    category: string
    mood: string
    content: string
    mediaUrls: array
    likes: number
    commentCount: number
    createdAt: timestamp

    comments/ (subcollection)
      {commentId}/
        userId: string
        userName: string
        content: string
        createdAt: timestamp
```

#### Step 2.2: Update FirestoreService

**File**: `lib/services/firestore_service.dart`

Key operations to implement:

```dart
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // === User Operations ===

  Future<void> saveUser(UserProfile user) async {
    await _firestore.collection('users').doc(user.id).set({
      'name': user.name,
      'email': user.email,
      'avatarUrl': user.avatarUrl,
      'type': user.type.name,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  Future<UserProfile?> getUser(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (!doc.exists) return null;

    final data = doc.data()!;
    return UserProfile(
      id: doc.id,
      name: data['name'],
      email: data['email'],
      avatarUrl: data['avatarUrl'],
      type: UserType.values.byName(data['type'] ?? 'owner'),
    );
  }

  // === Pet Operations ===

  Future<void> savePet(Pet pet, String userId) async {
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('pets')
        .doc(pet.id)
        .set(pet.toJson());
  }

  Stream<List<Pet>> getPetsStream(String userId) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('pets')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Pet.fromJson(doc.data()))
            .toList());
  }

  // === Post Operations ===

  Future<void> createPost(Post post) async {
    await _firestore.collection('posts').doc(post.id).set(post.toJson());
  }

  Stream<List<Post>> getPostsStream({int limit = 20}) {
    return _firestore
        .collection('posts')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Post.fromJson(doc.data()))
            .toList());
  }
}
```

#### Step 2.3: Hybrid Persistence Strategy

**Goal**: Maintain local-first architecture with cloud sync

```dart
class PersistenceService {
  final FirestoreService? _firestore;
  bool _cloudSyncEnabled = false;

  // Enable cloud sync
  Future<void> enableCloudSync() async {
    _cloudSyncEnabled = true;
  }

  // Save with dual write
  Future<void> savePet(Pet pet) async {
    // 1. Save to local Hive (fast, works offline)
    await _petBox.put(pet.id, pet);

    // 2. Background sync to Firestore (if enabled)
    if (_cloudSyncEnabled && _firestore != null) {
      final userId = getCurrentUserId();
      if (userId != null) {
        unawaited(_firestore.savePet(pet, userId));
      }
    }
  }

  // Load with fallback
  Future<Pet?> getPet(String id) async {
    // 1. Try local cache first
    final local = _petBox.get(id);
    if (local != null) return local;

    // 2. Fallback to Firestore
    if (_cloudSyncEnabled && _firestore != null) {
      final userId = getCurrentUserId();
      if (userId != null) {
        final pets = await _firestore.getUserPets(userId);
        return pets.firstWhere((p) => p.id == id, orElse: () => null);
      }
    }

    return null;
  }
}
```

**Benefits**:
- ✅ Works offline (local-first)
- ✅ Automatic cloud backup
- ✅ Multi-device sync
- ✅ Gradual migration (can enable per-user)

---

### Phase 3: Storage Integration (Week 3)

#### Step 3.1: Image Upload Service

```dart
class StorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadPetAvatar({
    required File imageFile,
    required String petId,
  }) async {
    try {
      final ref = _storage.ref().child('pets/$petId/avatar.jpg');

      await ref.putFile(
        imageFile,
        SettableMetadata(contentType: 'image/jpeg'),
      );

      return await ref.getDownloadURL();
    } catch (e) {
      debugPrint('[Storage] Upload error: $e');
      rethrow;
    }
  }

  Future<String> uploadPostMedia({
    required File mediaFile,
    required String postId,
    required MediaType mediaType,
  }) async {
    final ext = mediaType == MediaType.image ? 'jpg' : 'mp4';
    final ref = _storage.ref().child('posts/$postId/media.$ext');

    await ref.putFile(mediaFile);
    return await ref.getDownloadURL();
  }
}
```

#### Step 3.2: Update Image Picker Flow

```dart
Future<void> _pickAndUploadAvatar() async {
  // 1. Pick image
  final picker = ImagePicker();
  final image = await picker.pickImage(
    source: ImageSource.gallery,
    maxWidth: 800,
    maxHeight: 800,
    imageQuality: 85,
  );

  if (image == null) return;

  // 2. Show loading
  if (!mounted) return;
  final uploadUrl = await LoadingOverlay.show(
    context: context,
    message: 'Uploading image...',
    task: () => StorageService().uploadPetAvatar(
      imageFile: File(image.path),
      petId: pet.id,
    ),
  );

  // 3. Update pet with new URL
  final updatedPet = pet.copyWith(avatarUrl: uploadUrl);
  petProvider.updatePet(updatedPet);
}
```

---

## 🔒 Security Rules

### Firestore Security Rules

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

    // Users collection
    match /users/{userId} {
      // Anyone can read user profiles
      allow read: if isSignedIn();

      // Only owner can write their own profile
      allow write: if isOwner(userId);

      // Pets subcollection
      match /pets/{petId} {
        allow read: if isSignedIn();
        allow write: if isOwner(userId);
      }
    }

    // Posts collection
    match /posts/{postId} {
      // Anyone can read posts
      allow read: if isSignedIn();

      // Only post owner can update/delete
      allow create: if isSignedIn();
      allow update, delete: if isSignedIn()
        && request.auth.uid == resource.data.userId;

      // Comments subcollection
      match /comments/{commentId} {
        allow read: if isSignedIn();
        allow create: if isSignedIn();
        allow update, delete: if isSignedIn()
          && request.auth.uid == resource.data.userId;
      }
    }
  }
}
```

### Storage Security Rules

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {

    function isSignedIn() {
      return request.auth != null;
    }

    // Pet avatars
    match /pets/{petId}/{allPaths=**} {
      allow read: if isSignedIn();
      allow write: if isSignedIn();  // Can refine to owner check
    }

    // Post media
    match /posts/{postId}/{allPaths=**} {
      allow read: if isSignedIn();
      allow write: if isSignedIn();  // Can refine to post owner
    }
  }
}
```

**Apply Rules**:
```bash
# Install Firebase CLI
npm install -g firebase-tools

# Login
firebase login

# Initialize (select Firestore and Storage)
firebase init

# Deploy rules
firebase deploy --only firestore:rules
firebase deploy --only storage:rules
```

---

## ⚡ Performance Optimization

### 1. Firestore Query Optimization

**❌ Bad**: Load all data
```dart
final posts = await _firestore.collection('posts').get();
```

**✅ Good**: Limit, paginate, index
```dart
// Limit results
final posts = await _firestore
    .collection('posts')
    .orderBy('createdAt', descending: true)
    .limit(20)
    .get();

// Pagination
QueryDocumentSnapshot? lastDoc;

Future<List<Post>> loadMore() async {
  var query = _firestore
      .collection('posts')
      .orderBy('createdAt', descending: true)
      .limit(20);

  if (lastDoc != null) {
    query = query.startAfterDocument(lastDoc!);
  }

  final snapshot = await query.get();
  if (snapshot.docs.isNotEmpty) {
    lastDoc = snapshot.docs.last;
  }

  return snapshot.docs.map((doc) => Post.fromJson(doc.data())).toList();
}
```

**Create Composite Index**:
```bash
# Firebase Console > Firestore > Indexes
# Create index for: posts (createdAt DESC, userId ASC)
```

### 2. Offline Persistence

```dart
// Enable offline persistence (main.dart)
await Firebase.initializeApp();
FirebaseFirestore.instance.settings = const Settings(
  persistenceEnabled: true,
  cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
);
```

**Benefits**:
- Instant UI updates (writes to cache first)
- Works offline
- Automatic sync when online

### 3. Batch Writes

```dart
Future<void> saveBulkData(List<Pet> pets) async {
  final batch = _firestore.batch();

  for (final pet in pets) {
    final ref = _firestore
        .collection('users')
        .doc(userId)
        .collection('pets')
        .doc(pet.id);
    batch.set(ref, pet.toJson());
  }

  await batch.commit();  // Single network call
}
```

---

## 🧪 Testing Firebase Integration

### 1. Local Emulator Setup

```bash
# Install emulators
firebase init emulators  # Select Auth, Firestore, Storage

# Start emulators
firebase emulators:start
```

**Configure App**:
```dart
// lib/main.dart (debug mode only)
if (kDebugMode) {
  await Firebase.initializeApp();

  // Connect to emulators
  FirebaseAuth.instance.useAuthEmulator('localhost', 9099);
  FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
  FirebaseStorage.instance.useStorageEmulator('localhost', 9199);
}
```

### 2. Integration Tests

```dart
void main() {
  setUpAll(() async {
    await Firebase.initializeApp();
    // Configure emulators
  });

  testWidgets('User can sign up and create pet', (tester) async {
    final authService = AuthService();

    // Sign up
    final user = await authService.signUpWithEmailAndPassword(
      email: 'test@example.com',
      password: 'password123',
      displayName: 'Test User',
    );

    expect(user.email, 'test@example.com');

    // Create pet
    final firestoreService = FirestoreService();
    final pet = Pet(
      id: 'test_pet',
      name: 'Buddy',
      type: PetType.dog,
      breed: 'Golden Retriever',
    );

    await firestoreService.savePet(pet, user.uid);

    // Verify
    final savedPet = await firestoreService.getPet(pet.id, user.uid);
    expect(savedPet?.name, 'Buddy');
  });
}
```

---

## 📊 Migration Validation

### Checklist

**Authentication**:
- [ ] User signup works with Firebase
- [ ] User login works with Firebase
- [ ] Password reset implemented
- [ ] Auth state persists
- [ ] Error handling works

**Firestore**:
- [ ] User profiles sync to cloud
- [ ] Pet profiles sync to cloud
- [ ] Posts sync to cloud
- [ ] Offline mode works
- [ ] Multi-device sync verified

**Storage**:
- [ ] Pet avatars upload successfully
- [ ] Post images/videos upload
- [ ] URLs are accessible
- [ ] Storage rules enforced

**Performance**:
- [ ] App remains responsive during sync
- [ ] No blocking operations on UI thread
- [ ] Pagination works for large datasets
- [ ] Offline-first behavior maintained

---

## 🚨 Troubleshooting

### Common Issues

**Issue**: `MissingPluginException: No implementation found`
```bash
# Solution
flutter clean
flutter pub get
cd ios && pod install && cd ..
flutter run
```

**Issue**: Firestore permission denied
```
# Check security rules in Firebase Console
# Verify user is authenticated: FirebaseAuth.instance.currentUser
```

**Issue**: Storage upload fails
```dart
// Check file size (max 32MB per file)
// Verify storage rules allow writes
// Check internet connection
```

---

## 📚 Additional Resources

- [Firebase Flutter Documentation](https://firebase.flutter.dev/)
- [FlutterFire GitHub](https://github.com/firebase/flutterfire)
- [Firestore Data Modeling](https://firebase.google.com/docs/firestore/manage-data/structure-data)
- [Firebase Security Rules](https://firebase.google.com/docs/rules)

---

*For implementation assistance, see [DEVELOPER_GUIDE.md](DEVELOPER_GUIDE.md) or create an issue on GitHub.*
