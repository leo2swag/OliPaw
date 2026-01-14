# OlliePaw 🐾

A warm, friendly pet-centric social network built with Flutter - featuring organic UI design inspired by Moodiary.

---

## 🚀 Quick Start

### Prerequisites
- Flutter SDK 3.38.5 or higher
- Dart 3.10.4 or higher
- Xcode (for iOS development)
- Android Studio (for Android development)

### Setup

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd OlliePaw
   ```

2. **Configure API Keys**
   ```bash
   cp .env.example .env
   ```

   Get your Gemini API Key from [Google AI Studio](https://makersuite.google.com/app/apikey) and update `.env`:
   ```env
   GEMINI_API_KEY=your_actual_api_key_here
   ```

3. **Install dependencies**
   ```bash
   flutter pub get
   cd ios && pod install && cd ..
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

---

## ✨ Key Features

- 🐾 **Pet Profile Management** - Track multiple pets with detailed profiles
- 🎨 **Warm UI Design** - Organic shapes, soft colors, playful aesthetics (v3.0)
- 📸 **Social Feed** - Share moments with your pet community
- ❤️ **Health Tracking** - Monitor weight, vaccines, and milestones
- 🤖 **AI Integration** - Gemini-powered content generation
- 💰 **Treats System** - In-app currency and rewards
- ✅ **Daily Check-ins** - Engage with your pet community

---

## 🎨 Design System (v3.0)

### Warm UI Transformation
Inspired by Moodiary's friendly aesthetic, OlliePaw features:

- **Organic Blobs** - Hand-drawn style shapes with 7 variants
- **Soft Colors** - Warm pastels with emotional mood colors
- **Pill-Shaped Buttons** - Full rounded corners (999px)
- **24px Border Radius** - New standard for cards and inputs
- **80+ Emoji Constants** - Playful visual language
- **Friendly Empty States** - Large emoji + blob backgrounds

See [WARM_UI_GUIDE.md](WARM_UI_GUIDE.md) for complete design documentation.

---

## 🏗️ Architecture

### State Management (Provider)
- `AuthProvider` - Authentication and user sessions
- `PetProvider` - Pet profile management
- `CurrencyProvider` - Treats currency system
- `CheckInProvider` - Daily check-in rewards

### Key Components
- **OrganicBlob** - Warm, organic shape widgets
- **PlayfulEmptyState** - Friendly empty state UI
- **AppButton** - Unified pill-shaped buttons
- **MoodSelector** - Blob-based mood selection

### Code Organization
```
lib/
├── core/               # Core functionality
│   ├── constants/      # Colors, emojis, constants
│   ├── extensions/     # Dart extensions
│   └── theme/          # Design system (dimensions, input styles)
├── models/             # Data models
├── providers/          # State management
├── screens/            # App screens
├── services/           # Business logic
├── utils/              # Utilities
└── widgets/            # Reusable widgets
    ├── common/         # Shared widgets (blobs, buttons, empty states)
    └── [feature]/      # Feature-specific widgets
```

---

## 📚 Documentation

### Essential Guides
- **[WARM_UI_GUIDE.md](WARM_UI_GUIDE.md)** - Complete warm UI design system (v3.0)
- **[DEVELOPER_GUIDE.md](../DEVELOPER_GUIDE.md)** - Development setup and practices
- **[FIREBASE_GUIDE.md](../FIREBASE_GUIDE.md)** - Firebase integration guide

### Code Standards
- **[CHINESE_COMMENTS_GUIDE.md](CHINESE_COMMENTS_GUIDE.md)** - Code documentation standards

### Additional Resources
- **[CODE_STRUCTURE_GUIDE.md](../CODE_STRUCTURE_GUIDE.md)** - Detailed architecture guide
- **[TESTING_GUIDE.md](../TESTING_GUIDE.md)** - Testing framework and examples

---

## 🎨 Using the Warm UI System

### Emojis
```dart
import 'package:ollie_paw/core/constants/app_emojis.dart';

// In buttons
AppButton.primary(
  label: '${AppEmojis.add} Add Pet',
  onPressed: _handleAdd,
)

// In text
Text('${AppEmojis.paw} My Pets')
```

### Organic Blobs
```dart
import 'package:ollie_paw/widgets/common/organic_blob.dart';

// Mood selector
OrganicBlob.mood(
  size: 65,
  color: AppColors.moodHappy,
  variant: 2,
  child: Text('😊', style: TextStyle(fontSize: 32)),
)

// Background decoration
Stack(
  children: [
    DecorativeBlobs(),
    YourContent(),
  ],
)
```

### Playful Empty States
```dart
import 'package:ollie_paw/widgets/common/playful_empty_state.dart';

// Pre-built empty states
if (posts.isEmpty) {
  return PlayfulEmptyStates.noPosts(
    onCreatePost: () => _navigateToCreate(),
  );
}
```

---

## 🔧 Development

### Code Quality
- ✅ Zero compilation errors
- ✅ Zero warnings
- ✅ 9 info suggestions (prefer_const - non-critical)
- ✅ Comprehensive documentation
- ✅ Consistent design system

### Running Tests
```bash
flutter test
```

### Code Analysis
```bash
flutter analyze --no-fatal-infos
```

### Building
```bash
# iOS
flutter build ios

# Android
flutter build apk
```

---

## 📦 Dependencies

### Core
- `flutter` - UI framework
- `provider` - State management
- `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage` - Backend
- `sqflite` - Local database
- `shared_preferences` - Key-value storage

### UI/UX
- `fl_chart` - Charts and graphs
- `image_picker` - Photo selection
- `cached_network_image` - Image caching

### AI
- `google_generative_ai` - Gemini AI integration

See `pubspec.yaml` for complete dependency list.

---

## 🔒 Security

- ⚠️ **Never commit `.env` files**
- ⚠️ **Never hardcode API keys**
- ⚠️ **Each developer uses their own keys**
- ⚠️ **Don't share credentials**

---

## 📈 Version History

### v3.0 - Warm UI Transformation (Current)
- 🎨 Complete UI redesign with organic shapes
- 🌈 Warm color palette with mood colors
- 💊 Pill-shaped buttons and soft corners
- 😊 80+ emoji constants
- 🎭 Playful empty states
- 📖 Comprehensive design documentation

### v2.6 - Code Consolidation
- ✅ Unified authentication system
- 📚 Documentation consolidation
- 🔧 Code duplication elimination
- 🎯 Zero analyzer issues

### Earlier Versions
See git history for detailed changelog.

---

## 🤝 Contributing

1. Follow the [CHINESE_COMMENTS_GUIDE.md](CHINESE_COMMENTS_GUIDE.md) for code documentation
2. Use the design system defined in `lib/core/theme/`
3. Utilize `AppEmojis` for consistent emoji usage
4. Apply `PlayfulEmptyStates` for empty UI states
5. Run `flutter analyze` before committing

---

## 📝 License

This project is a Flutter application template.

---

## 🆘 Troubleshooting

### Xcode Build Errors
```bash
# Clean and rebuild
flutter clean
rm -rf ios/Pods ios/Podfile.lock
flutter pub get
cd ios && pod install && cd ..
```

### Dependency Issues
```bash
flutter pub get
flutter pub upgrade
```

### Firebase Issues
See [FIREBASE_GUIDE.md](../FIREBASE_GUIDE.md) for detailed troubleshooting.

---

**Built with ❤️ using Flutter**
