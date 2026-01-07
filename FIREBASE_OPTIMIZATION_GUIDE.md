# Firebase Sync Optimization Guide

## Current Implementation Status

✅ **Working:**
- Hive local storage (fast, offline-first)
- Firestore cloud sync (dual-write pattern)
- User data syncing to cloud
- Cloud sync toggle (enable/disable)

⚠️ **Not Yet Implemented:**
- Firebase Storage for images
- Incremental sync (only changed data)
- Conflict resolution (multi-device edits)
- Background sync

---

## Optimization Opportunities

### 1. Batch Writes (Save Firebase Costs)

**Current:** Each save = 1 Firestore write
**Problem:** If user creates 5 pets quickly = 5 writes
**Solution:** Batch multiple writes together

```dart
// Instead of:
await _firestore.savePet(pet1);
await _firestore.savePet(pet2);
await _firestore.savePet(pet3);

// Use batch:
final batch = FirebaseFirestore.instance.batch();
batch.set(_firestore.collection('pets').doc(pet1.id), pet1.toJson());
batch.set(_firestore.collection('pets').doc(pet2.id), pet2.toJson());
batch.set(_firestore.collection('pets').doc(pet3.id), pet3.toJson());
await batch.commit(); // Only 1 network call
```

**Savings:** 3 writes → 1 batched operation
**When to use:** Profile editing, bulk imports

---

### 2. Selective Sync (Don't Sync Everything)

**Current:** All data syncs immediately
**Problem:** Wastes bandwidth and writes
**Solution:** Only sync important data

```dart
// Add syncPriority to models
class Pet {
  final SyncPriority priority;
  // HIGH = immediate sync (profile changes)
  // MEDIUM = sync on wifi (gallery)
  // LOW = sync when idle (analytics)
}

// In PersistenceService
if (pet.priority == SyncPriority.HIGH || isWifiConnected) {
  await _firestore.savePet(pet);
}
```

---

### 3. Incremental Sync (Only Changed Fields)

**Current:** Saves entire object every time
**Problem:** Changing pet name uploads ALL pet data
**Solution:** Track dirty fields

```dart
// Before
await _firestore.savePet(entirePet); // 5KB upload

// After (only changed fields)
await _firestore.collection('pets').doc(id).update({
  'name': newName,
  'updatedAt': DateTime.now()
}); // 100 bytes upload
```

**Savings:** 50x less data transfer
**Implementation:** Track which fields changed in copyWith

---

### 4. Debounced Sync (Reduce Rapid Writes)

**Current:** Every keystroke could trigger a save
**Problem:** User typing pet name = 10 saves
**Solution:** Debounce rapid changes

```dart
Timer? _syncTimer;

void savePetDebounced(Pet pet) {
  // Cancel previous timer
  _syncTimer?.cancel();

  // Save locally immediately (fast UX)
  _petBox.put(pet.id, PetHiveModel.fromPet(pet));

  // Delay cloud sync by 2 seconds
  _syncTimer = Timer(Duration(seconds: 2), () async {
    await _firestore.savePet(pet);
  });
}
```

**Savings:** 10 rapid edits → 1 cloud sync
**User experience:** No lag, syncs when user pauses

---

### 5. Offline Queue (Handle No Internet)

**Current:** Sync fails silently when offline
**Problem:** Data might not sync later
**Solution:** Queue failed syncs

```dart
class SyncQueue {
  final Queue<SyncTask> _queue = Queue();

  Future<void> savePet(Pet pet) async {
    // Always save locally
    await _hive.put(pet.id, pet);

    // Try cloud sync
    try {
      await _firestore.savePet(pet);
    } catch (e) {
      // If offline, add to queue
      _queue.add(SyncTask(type: 'pet', data: pet));
      _scheduleRetry();
    }
  }

  Future<void> _scheduleRetry() async {
    // Retry when back online
    await connectivity.onConnectivityChanged.listen((status) {
      if (status != ConnectivityResult.none) {
        _processQueue();
      }
    });
  }
}
```

---

### 6. Background Sync (iOS Background Modes)

**Current:** Only syncs when app is open
**Solution:** Sync in background periodically

```dart
// Using workmanager package
Workmanager().registerPeriodicTask(
  "sync-task",
  "firebaseSync",
  frequency: Duration(hours: 1),
);

// Syncs data even when app is closed
```

---

### 7. Compression (Large Objects)

**Current:** Pet with 100 weight records = large document
**Problem:** Firestore has 1MB document limit
**Solution:** Use subcollections or compress

```dart
// Instead of embedding in Pet document:
class Pet {
  List<WeightRecord> weightHistory; // Could be 100+ items
}

// Use subcollection (already implemented!):
_firestore.collection('pets').doc(petId)
  .collection('weightHistory').add(record);
```

✅ **You already do this!** Good job!

---

### 8. Firebase Storage Integration (For Images)

**Current:** Using placeholder URLs
**Future:** Upload real images

```dart
import 'package:firebase_storage/firebase_storage.dart';

Future<String> uploadPetAvatar(File imageFile, String petId) async {
  // 1. Upload to Storage
  final ref = FirebaseStorage.instance
    .ref('pets/$petId/avatar.jpg');

  await ref.putFile(imageFile);

  // 2. Get download URL
  final url = await ref.getDownloadURL();

  // 3. Save URL to Firestore
  await _firestore.collection('pets').doc(petId).update({
    'avatarUrl': url
  });

  return url;
}
```

**Best practices:**
- Compress images before upload (use `image` package)
- Use WebP format (smaller size)
- Generate thumbnails (don't load full resolution)

---

### 9. Cost Optimization

**Firestore Pricing:**
- Document reads: 50,000/day free
- Document writes: 20,000/day free
- Storage: 1GB free

**How to stay in free tier:**

1. **Cache reads** - Read from Hive, not Firestore
   ```dart
   // ❌ Bad: Every app open = Firestore read
   final pet = await _firestore.getPet(id);

   // ✅ Good: Read from Hive
   final pet = _hive.get(id);
   ```

2. **Limit queries** - Don't load all posts at once
   ```dart
   // ❌ Bad: Load 1000 posts
   .get();

   // ✅ Good: Paginate
   .limit(20).get();
   ```

3. **Use listeners sparingly** - Real-time updates cost reads
   ```dart
   // Each update = 1 read per listener
   _firestore.collection('pets').snapshots();
   ```

---

## Recommended Implementation Priority

### Phase 1: Quick Wins (Do Now) ⚡
1. ✅ Enable cloud sync in debug mode (DONE)
2. Add Firebase Storage for image uploads
3. Implement debounced sync for edits

### Phase 2: Performance (Next Week) 🚀
4. Add offline queue for failed syncs
5. Implement batch writes for bulk operations
6. Add sync status indicator in UI

### Phase 3: Advanced (Later) 🔮
7. Incremental sync (only changed fields)
8. Background sync (when app closed)
9. Conflict resolution (multi-device)

---

## Code Example: Optimized PersistenceService

```dart
class OptimizedPersistenceService {
  Timer? _syncTimer;
  final Queue<SyncTask> _offlineQueue = Queue();

  Future<bool> savePet(Pet pet, {bool immediate = false}) async {
    // 1. Local save (always fast)
    final model = PetHiveModel.fromPet(pet);
    await _petBox.put(pet.id, model);
    debugPrint('[✅] Pet saved locally: ${pet.name}');

    // 2. Cloud sync (debounced unless immediate)
    if (_cloudSyncEnabled) {
      if (immediate) {
        await _syncToCloud(pet);
      } else {
        _debouncedSync(pet);
      }
    }

    return true;
  }

  void _debouncedSync(Pet pet) {
    _syncTimer?.cancel();
    _syncTimer = Timer(Duration(seconds: 2), () async {
      await _syncToCloud(pet);
    });
  }

  Future<void> _syncToCloud(Pet pet) async {
    try {
      await _firestore.savePet(pet);
      debugPrint('[☁️] Pet synced to cloud: ${pet.name}');
    } catch (e) {
      debugPrint('[⚠️] Sync failed, queuing for retry');
      _offlineQueue.add(SyncTask(type: 'pet', data: pet));
    }
  }

  Future<void> processOfflineQueue() async {
    while (_offlineQueue.isNotEmpty) {
      final task = _offlineQueue.removeFirst();
      try {
        if (task.type == 'pet') {
          await _firestore.savePet(task.data);
        }
      } catch (e) {
        // Re-add to queue if still failing
        _offlineQueue.addFirst(task);
        break;
      }
    }
  }
}
```

---

## Summary

**Your current implementation is EXCELLENT for v1:**
- ✅ Fast (local-first)
- ✅ Reliable (graceful fallback)
- ✅ Simple (easy to understand)

**When to add optimizations:**
- When you have 100+ users
- When Firebase bill > $0
- When users complain about slow syncs
- When adding image uploads

**Don't over-optimize prematurely!** Your current setup is great for MVP/testing.
