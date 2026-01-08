# OlliePaw Developer Guide
**Version**: 2.6
**Last Updated**: 2026-01-08

---

## 📋 Table of Contents

1. [Quick Start](#quick-start)
2. [Project Architecture](#project-architecture)
3. [Provider Pattern & State Management](#provider-pattern--state-management)
4. [Data Persistence](#data-persistence)
5. [Performance Best Practices](#performance-best-practices)
6. [Testing Guide](#testing-guide)
7. [Code Style & Conventions](#code-style--conventions)
8. [Common Patterns](#common-patterns)

---

## 🚀 Quick Start

### Prerequisites
- Flutter SDK ≥3.2.0
- Dart ≥3.0.0
- Android Studio / VS Code
- Gemini API Key ([Get one here](https://makersuite.google.com/app/apikey))

### First Time Setup

```bash
# 1. Clone repository
git clone https://github.com/leo2swag/OliPaw.git
cd OliPaw/OlliePaw

# 2. Install dependencies
flutter pub get

# 3. Setup environment variables
cp .env.example .env
# Edit .env and add your GEMINI_API_KEY

# 4. Run the app
flutter run
```

### Project Structure

```
lib/
├── core/               # Core utilities, constants, theme
│   ├── constants/      # App-wide constants (colors, dimensions)
│   ├── theme/          # Theme configuration
│   ├── extensions/     # Dart extensions (date, string)
│   └── enums/          # Enum definitions
├── models/             # Data models
├── providers/          # State management (Provider pattern)
├── services/           # Business logic & external APIs
├── screens/            # UI screens
├── widgets/            # Reusable UI components
└── utils/              # Helper utilities
```

---

## 🏗️ Project Architecture

### State Management: Provider Pattern

**OlliePaw uses a modular Provider architecture** with clear separation of concerns:

```
UI (Screens/Widgets)
    ↓ (context.watch/read)
Provider (State Management)
    ↓ (business logic)
Service (API/External interactions)
    ↓ (data storage)
Persistence (Hive/SharedPreferences)
```

### Provider Hierarchy

```dart
MultiProvider(
  providers: [
    // Authentication & User Management
    ChangeNotifierProvider<AuthProvider>(...),

    // Pet Profile Management
    ChangeNotifierProvider<PetProvider>(...),

    // Virtual Currency System
    ChangeNotifierProvider<CurrencyProvider>(...),

    // Daily Check-in System
    ChangeNotifierProvider<CheckInProvider>(...),
  ],
)
```

### Key Architectural Principles

1. **Single Responsibility**: Each provider manages one domain
2. **Immutability**: Models are immutable, changes create new instances
3. **Persistence**: All providers auto-load/save state
4. **Type Safety**: Strong typing throughout, minimal dynamic types

---

## 📦 Provider Pattern & State Management

### Provider Lifecycle

```dart
class ExampleProvider extends ChangeNotifier {
  final PersistenceService _persistence;

  // 1. Constructor - Initialize dependencies
  ExampleProvider(this._persistence) {
    _loadFromStorage();
  }

  // 2. Load state from persistence
  Future<void> _loadFromStorage() async {
    _data = _persistence.getData();
    notifyListeners();  // Trigger UI rebuild
  }

  // 3. Update state
  void updateData(Data newData) {
    _data = newData;
    _persistence.saveData(_data);
    notifyListeners();  // Notify all listeners
  }

  // 4. Cleanup
  @override
  void dispose() {
    // Cancel subscriptions, close streams
    super.dispose();
  }
}
```

### Consumer Best Practices

**❌ Bad**: Rebuild entire widget on any change
```dart
Consumer<PetProvider>(
  builder: (context, provider, _) {
    return Column(
      children: [
        Text(provider.currentPet?.name ?? ''),  // Rebuilds for any pet change
        Text(provider.currentPet?.breed ?? ''),
        // ... 50 more widgets
      ],
    );
  },
)
```

**✅ Good**: Use Selector for targeted rebuilds
```dart
Selector<PetProvider, String?>(
  selector: (_, provider) => provider.currentPet?.name,
  builder: (context, name, _) {
    return Text(name ?? '');  // Only rebuilds when name changes
  },
)
```

### AuthProvider (v2.6 - Unified Authentication)

**Responsibilities**:
- User authentication (login/signup/logout)
- Session management
- Splash screen flow control
- Persistence integration

**Key Methods**:
```dart
// Firebase-ready methods
Future<bool> signIn({required String email, required String password})
Future<bool> signUp({required String email, required String password, ...})
Future<void> signOut()

// UserProvider compatibility (legacy API)
void login(UserProfile profile)
Future<void> logout()
void finishSplash()

// Getters
UserProfile? get currentUser           // App domain model
AuthUser? get authUser                 // Firebase user
bool get isLoggedIn
bool get splashFinished
```

---

## 💾 Data Persistence

### Two-Tier Storage Strategy

**Tier 1: SharedPreferences** (Simple key-value data)
- Treats balance
- Check-in dates
- Consecutive days
- User preferences

**Tier 2: Hive** (Complex objects)
- User profiles
- Pet profiles
- Posts
- Health records

### PersistenceService API

```dart
// Hive operations (async)
Future<void> savePet(Pet pet)
Pet? getPet(String id)
Future<void> saveUser(UserProfile user)
UserProfile? getUser(String userId)

// SharedPreferences operations (sync)
int getTreats()
bool saveTreats(int treats)
String? getLastCheckIn()
bool saveLastCheckIn(String date)

// User session
String? getCurrentUserId()
bool saveCurrentUserId(String id)
Future<void> logout()  // Clears all data
```

### Cloud Sync (Optional)

Enable cloud backup with Firestore:

```dart
final persistence = PersistenceService();
await persistence.enableCloudSync();  // Syncs to Firestore
```

**Sync Strategy**:
- **Write**: Local-first (Hive) → Background sync to Firestore
- **Read**: Local cache → Fallback to Firestore if missing
- **Conflict**: Last-write-wins (timestamp-based)

---

## ⚡ Performance Best Practices

### 1. Use `const` Constructors

```dart
// ❌ Bad
return Container(
  padding: EdgeInsets.all(16),
  child: Text('Hello'),
)

// ✅ Good
return Container(
  padding: const EdgeInsets.all(16),
  child: const Text('Hello'),
)
```

**Impact**: Reduces widget rebuilds, improves frame rate

### 2. Minimize notifyListeners() Calls

```dart
// ❌ Bad: 3 rebuilds
void updateMultipleFields() {
  _field1 = value1;
  notifyListeners();
  _field2 = value2;
  notifyListeners();
  _field3 = value3;
  notifyListeners();
}

// ✅ Good: 1 rebuild
void updateMultipleFields() {
  _field1 = value1;
  _field2 = value2;
  _field3 = value3;
  notifyListeners();  // Single notification
}
```

### 3. Use Selector Pattern

Only rebuild when specific data changes:

```dart
// Rebuilds only when pet name changes, not on any pet update
final name = context.select<PetProvider, String?>(
  (provider) => provider.currentPet?.name
);
```

### 4. ListView Best Practices

```dart
// ❌ Bad: Creates all items upfront
ListView(
  children: posts.map((post) => FeedCard(post)).toList(),
)

// ✅ Good: Lazy loading with builder
ListView.builder(
  itemCount: posts.length,
  itemBuilder: (context, index) => FeedCard(posts[index]),
)
```

### 5. Image Optimization

```dart
// Use cached_network_image for network images
CachedNetworkImage(
  imageUrl: pet.avatarUrl,
  placeholder: (context, url) => CircularProgressIndicator(),
  errorWidget: (context, url, error) => Icon(Icons.error),
  maxWidth: 400,  // Constrain size
  maxHeight: 400,
)
```

---

## 🧪 Testing Guide

### Test Coverage Goals

- **Providers**: 70% coverage minimum
- **Services**: 80% coverage (critical business logic)
- **Widgets**: 50% coverage (key user flows)
- **Overall**: 60% coverage

### Provider Testing Pattern

**Reference**: See `test/providers/currency_provider_test.dart` (100% coverage)

```dart
void main() {
  late MockPersistenceService mockPersistence;
  late CurrencyProvider provider;

  setUp(() {
    mockPersistence = MockPersistenceService();
    when(mockPersistence.getTreats()).thenReturn(100);
    provider = CurrencyProvider(mockPersistence);
  });

  test('earnTreats increases balance', () {
    provider.earnTreats(50, reason: 'Daily check-in');
    expect(provider.treats, 150);
    verify(mockPersistence.saveTreats(150)).called(1);
  });

  test('spendTreats returns false when insufficient balance', () {
    expect(provider.spendTreats(200), false);
    expect(provider.treats, 100);  // Balance unchanged
  });
}
```

### Widget Testing

```dart
testWidgets('Login button enabled with valid input', (tester) async {
  await tester.pumpWidget(
    MaterialApp(home: LoginScreen()),
  );

  // Find text fields
  final emailField = find.byKey(Key('email_field'));
  final passwordField = find.byKey(Key('password_field'));
  final loginButton = find.text('登录');

  // Enter valid credentials
  await tester.enterText(emailField, 'test@example.com');
  await tester.enterText(passwordField, 'password123');
  await tester.pump();

  // Verify button is enabled
  expect(
    tester.widget<ElevatedButton>(loginButton).enabled,
    true,
  );
});
```

### Running Tests

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/providers/currency_provider_test.dart

# View coverage report
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

---

## 📐 Code Style & Conventions

### Naming Conventions

- **Files**: `snake_case.dart`
- **Classes**: `PascalCase`
- **Variables/Methods**: `camelCase`
- **Constants**: `lowerCamelCase` (class constants) or `UPPER_SNAKE_CASE` (top-level)
- **Private**: `_leadingUnderscore`

### Enum Naming (Updated v2.6)

```dart
// ✅ Correct (lowerCamelCase)
enum UserType { owner, guest, merchant }
enum PetType { dog, cat, other }

// Usage
UserType.owner
PetType.dog
```

### Comments

**File Headers**:
```dart
/*
  文件：screens/home_screen.dart
  说明：
  - 主要功能描述
  - 架构变更历史
  - 使用方式
*/
```

**Class Documentation**:
```dart
/// Pet profile management provider
///
/// Responsibilities:
/// - Load/save pet profiles
/// - Switch between pets
/// - Update pet information
class PetProvider extends ChangeNotifier {
  // ...
}
```

### File Organization

```dart
// 1. File header comment
/* ... */

// 2. Imports (grouped)
import 'package:flutter/material.dart';  // Flutter packages
import 'package:provider/provider.dart'; // External packages

import '../models/types.dart';  // Relative imports
import '../services/persistence_service.dart';

// 3. Class definition
class MyClass {
  // 4. Fields (private then public)
  final String _privateField;
  String publicField;

  // 5. Constructor
  MyClass(this.publicField, this._privateField);

  // 6. Getters
  String get computed => '$_privateField-$publicField';

  // 7. Methods (public then private)
  void publicMethod() {}
  void _privateMethod() {}
}
```

---

## 🔧 Common Patterns

### 1. Loading Overlay Pattern

```dart
// lib/widgets/common/loading_overlay.dart
final result = await LoadingOverlay.show(
  context: context,
  message: 'Generating caption...',
  subtitle: 'Using AI magic ✨',
  task: () => geminiService.generateCaption(pet),
);
```

### 2. SnackBar Helper

```dart
// Success message
SnackBarHelper.showSuccess(context, 'Pet saved successfully!');

// Error message
SnackBarHelper.showError(context, 'Failed to save pet');

// Info message
SnackBarHelper.showInfo(context, 'Syncing to cloud...');
```

### 3. App Dialog Pattern

```dart
return AppDialog(
  icon: LucideIcons.alertCircle,
  iconColor: Colors.orange,
  title: 'Confirm Deletion',
  content: Text('Are you sure you want to delete this pet?'),
  actions: [
    AppDialog.cancelButton(context),
    AppDialog.confirmButton(
      context,
      onPressed: _deletePet,
      label: 'Delete',
      isDestructive: true,
    ),
  ],
);
```

### 4. Date Formatting (Use Extensions)

```dart
import '../core/extensions/date_extensions.dart';

// Format dates
DateTime.now().toShortDate()     // "2026-01-08"
DateTime.now().toLongDate()      // "January 8, 2026"

// Calculate age
DateTime.parse(pet.birthDate).calculateAge()  // "2 years 3 months"

// Check dates
DateTime.now().isToday
DateTime.now().isSameDay(otherDate)
```

### 5. Safe Async with mounted Check

```dart
Future<void> _loadData() async {
  final data = await fetchData();

  // Always check mounted before using BuildContext
  if (!mounted) return;

  setState(() {
    _data = data;
  });

  if (!mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(...);
}
```

---

## 📚 Additional Resources

### Internal Documentation
- [Firebase Integration Guide](FIREBASE_GUIDE.md)
- [Project Status & Roadmap](PROJECT_STATUS.md)
- [Optimization Summary](OPTIMIZATION_COMPLETE_SUMMARY.md)
- [Consolidation Plan](CONSOLIDATION_ACTION_PLAN.md)

### External Resources
- [Flutter Documentation](https://docs.flutter.dev/)
- [Provider Package](https://pub.dev/packages/provider)
- [Hive Database](https://docs.hivedb.dev/)
- [Firebase for Flutter](https://firebase.flutter.dev/)

### Code Style
- [Effective Dart](https://dart.dev/guides/language/effective-dart)
- [Flutter Style Guide](https://github.com/flutter/flutter/wiki/Style-guide-for-Flutter-repo)

---

## 🤝 Contributing

### Before Starting
1. Read this guide thoroughly
2. Check [PROJECT_STATUS.md](PROJECT_STATUS.md) for current priorities
3. Run `flutter analyze` - must have 0 issues
4. Write tests for new features

### Development Workflow

```bash
# 1. Create feature branch
git checkout -b feature/your-feature-name

# 2. Make changes
# ... code changes ...

# 3. Run tests
flutter test

# 4. Run analyzer
flutter analyze

# 5. Commit with descriptive message
git commit -m "feat: add user profile editing"

# 6. Push and create PR
git push origin feature/your-feature-name
```

### Commit Message Format

```
type: short description

Longer description if needed

Co-Authored-By: Your Name <email@example.com>
```

**Types**: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`

---

## ❓ Troubleshooting

### Common Issues

**Issue**: `MissingPluginException`
```bash
# Solution: Clean and rebuild
flutter clean
flutter pub get
flutter run
```

**Issue**: Hive type not registered
```bash
# Solution: Run code generation
flutter pub run build_runner build --delete-conflicting-outputs
```

**Issue**: Firebase not initializing
```bash
# Ensure firebase_options.dart exists
flutterfire configure
```

---

## 📊 Project Health Metrics

**Current Status** (as of v2.6):
- **Flutter Analyzer**: 0 issues ✅
- **Test Coverage**: 20% (Target: 70%)
- **Provider Count**: 4 (modular, single-responsibility)
- **Code Quality Score**: 8.5/10

**Recent Improvements**:
- Unified authentication (AuthProvider)
- Zero analyzer issues
- Comprehensive documentation
- Clear architectural patterns

---

*For questions or suggestions, create an issue on GitHub or contact the development team.*
