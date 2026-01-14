# OlliePaw Warm UI Design Guide (v3.0)

Complete guide for OlliePaw's warm, friendly, family-oriented design system inspired by Moodiary.

---

## 📖 Table of Contents

1. [Design Philosophy](#design-philosophy)
2. [Quick Start](#quick-start)
3. [Color System](#color-system)
4. [Border Radius](#border-radius)
5. [Components](#components)
6. [Emoji Library](#emoji-library)
7. [Usage Examples](#usage-examples)
8. [Migration Guide](#migration-guide)

---

## Design Philosophy

### Core Principles
- **Organic shapes** - Soft blobs and curved forms, not rigid rectangles
- **Playful colors** - Warm pastels with emotional connections
- **Friendly typography** - Rounded fonts with personality
- **Emotional connection** - Emoji-rich, illustration-forward design
- **Smooth interactions** - Gentle animations and transitions

### Visual Language
- **Pill-shaped buttons** - Full rounded corners (999px) for warmth
- **24-48px radius** - Generous rounding for organic feel
- **Asymmetric blobs** - Hand-drawn aesthetic with 7 variants
- **Generous spacing** - Breathing room for comfort
- **Soft shadows** - Elevated depth without harshness

---

## Quick Start

### Using Emojis
```dart
import 'package:ollie_paw/core/constants/app_emojis.dart';

Text('${AppEmojis.paw} My Pets')
```

### Using Organic Blobs
```dart
import 'package:ollie_paw/widgets/common/organic_blob.dart';

OrganicBlob.mood(
  size: 65,
  color: AppColors.moodHappy,
  variant: 2,
  child: Text('😊', style: TextStyle(fontSize: 32)),
)
```

### Using Playful Empty States
```dart
import 'package:ollie_paw/widgets/common/playful_empty_state.dart';

PlayfulEmptyStates.noPosts(
  onCreatePost: () => _navigateToCreate(),
)
```

---

## Color System

### Primary Colors (Warmer & Softer)
```dart
AppColors.primaryOrange   // #FFB366 (was #FB923C)
AppColors.darkOrange      // #FFB88C (was #EA580C)
AppColors.lightOrangeBg   // #FFE5CC (was #FED7AA)
```

### Background Colors
```dart
AppColors.screenBg        // #FFF8F0 (warm cream)
AppColors.cardBg          // #F5E6D3 (soft beige)
AppColors.darkBg          // #1E2139 (navy blue for contrast)
```

### Mood Colors (8 Emotional States)
```dart
AppColors.moodHappy       // #FFD88C (warm yellow) 😊
AppColors.moodExcited     // #FFB3D9 (bright pink) 🤩
AppColors.moodCalm        // #B8E6D5 (mint green) 😌
AppColors.moodPlayful     // #A3D5E8 (sky blue) 😄
AppColors.moodSleepy      // #C5B3E6 (lavender) 😴
AppColors.moodEnergetic   // #FFB88C (peachy) 🤗
AppColors.moodLove        // #FFB3C1 (soft pink) 🥰
AppColors.moodNature      // #A8D5BA (soft green) 🌿
```

Each mood has a light background variant:
```dart
AppColors.moodHappyBg     // #FFF4E0
AppColors.moodExcitedBg   // #FFE5F3
// ... etc
```

### Category Colors (Pastel Updates)
```dart
AppColors.categorySnapshot  // #FFD88C (warm yellow)
AppColors.categorySleepy    // #C5B3E6 (lavender)
AppColors.categoryWalk      // #A8D5BA (soft green)
AppColors.categoryPlay      // #A3D5E8 (sky blue)
AppColors.categoryHealth    // #B8E6D5 (mint green)
```

### Shadow System
```dart
AppColors.cardShadow        // Soft card elevation
AppColors.floatingShadow    // Floating elements
AppColors.softShadow        // Subtle depth
```

---

## Border Radius

### All Values Doubled (v3.0)
```dart
AppRadius.xs      // 8px (was 4px)
AppRadius.sm      // 16px (was 8px)
AppRadius.md      // 24px (was 12px) ← NEW STANDARD
AppRadius.lg      // 32px (was 16px)
AppRadius.xl      // 40px (was 20px)
AppRadius.xxl     // 48px (was 24px)
AppRadius.xxxl    // 56px (was 30px)
AppRadius.xxxxl   // 64px (was 32px)
AppRadius.full    // 999px (pill shape)
```

### Purpose-Specific Radius
```dart
AppRadius.button        // full (999px) - Pill-shaped
AppRadius.input         // md (24px) - Soft inputs
AppRadius.card          // md (24px) - Warm cards
AppRadius.dialog        // lg (32px) - Dialogs
AppRadius.bottomSheet   // xxl (48px) - Bottom sheets
AppRadius.badge         // xl (40px) - Badges
AppRadius.avatar        // full (999px) - Avatars
```

### Quick Usage
```dart
// Direct value
BorderRadius.circular(AppRadius.md)

// Helper getters
AppRadius.allMD      // BorderRadius.circular(24)
AppRadius.topMD      // Top corners only
AppRadius.bottomMD   // Bottom corners only
```

---

## Components

### 1. OrganicBlob
**File:** `lib/widgets/common/organic_blob.dart`

Organic shape component with 7 unique variants.

**Basic Usage:**
```dart
OrganicBlob(
  size: 120,
  color: AppColors.moodHappy,
  variant: 0,
  child: Text('😊', style: TextStyle(fontSize: 48)),
)
```

**Irregular Shape:**
```dart
OrganicBlob.irregular(
  width: 150,
  height: 120,
  color: AppColors.moodPlayful.withValues(alpha: 0.3),
  variant: 2,
)
```

**Mood Selector:**
```dart
OrganicBlob.mood(
  size: 65,
  color: AppColors.moodHappy,
  variant: 0,
  child: Text('😊', style: TextStyle(fontSize: 32)),
)
```

**Shape Variants (0-6):**
- 0: Gentle irregular circle
- 1: Water drop
- 2: Cloud shape
- 3: Soft ellipse
- 4: Organic bean
- 5: Asymmetric circle
- 6: Wave circle

**Decorative Background:**
```dart
Stack(
  children: [
    DecorativeBlobs(), // 4 corner blobs
    YourContent(),
  ],
)
```

**Blob Card:**
```dart
BlobCard(
  padding: EdgeInsets.all(24),
  backgroundColor: AppColors.cardBg,
  blobColor: AppColors.moodHappy,
  blobAlignment: Alignment.topRight,
  child: YourContent(),
)
```

### 2. PlayfulEmptyState
**File:** `lib/widgets/common/playful_empty_state.dart`

Warm, friendly empty states with blob backgrounds.

**Basic Usage:**
```dart
PlayfulEmptyState(
  emoji: AppEmojis.emptyBox,
  title: 'No posts yet',
  message: 'Share your first moment!',
  actionLabel: 'Create Post',
  onAction: () => _navigateToCreate(),
)
```

**Pre-built Variants:**
```dart
PlayfulEmptyStates.noPosts(onCreatePost: ...)
PlayfulEmptyStates.noPets(onAddPet: ...)
PlayfulEmptyStates.noActivities(onAddActivity: ...)
PlayfulEmptyStates.noHealthRecords(onAddRecord: ...)
PlayfulEmptyStates.noMilestones(onAddMilestone: ...)
PlayfulEmptyStates.noSearchResults(query: 'fluffy')
```

**Compact Version:**
```dart
CompactEmptyState(
  emoji: AppEmojis.emptyBox,
  message: 'No data available',
  blobColor: AppColors.moodCalm,
)
```

### 3. AppButton (Updated)
**File:** `lib/widgets/common/app_button.dart`

All buttons now pill-shaped by default.

**Primary Button:**
```dart
AppButton.primary(
  label: 'Submit',
  onPressed: _handleSubmit,
  icon: Icons.check, // Optional
)
```

**With Emoji:**
```dart
AppButton.primary(
  label: '${AppEmojis.add} Add Pet',
  onPressed: _handleAdd,
)
```

### 4. MoodSelector (Redesigned)
**File:** `lib/widgets/create_post/mood_selector.dart`

Organic blob-based mood selection.

**Features:**
- 65px organic blobs (7 shape variants)
- Mood-specific colors
- 30% → 100% opacity on selection
- 32px emoji size

**Automatic Usage:**
```dart
MoodSelector(
  moods: [
    {'emoji': '😊', 'name': 'Happy'},
    {'emoji': '🤩', 'name': 'Excited'},
  ],
  selectedMood: _currentMood,
  onMoodSelected: (mood) => setState(() => _currentMood = mood),
)
```

### 5. AppInputDecoration
**File:** `lib/core/theme/app_input_decoration.dart`

Warm, soft input fields.

**Standard Input:**
```dart
TextFormField(
  decoration: AppInputDecoration.standard(
    labelText: 'Email',
    hintText: 'Enter your email',
    prefixIcon: Icons.email_outlined,
  ),
)
```

**Updates:**
- Border radius: 12px → 24px
- Fill color: grey → warm beige
- Focus color: warm orange

---

## Emoji Library

**File:** `lib/core/constants/app_emojis.dart`

80+ organized emoji constants across 10 categories.

### Categories

**Pets:**
```dart
AppEmojis.paw       // 🐾
AppEmojis.dog       // 🐕
AppEmojis.cat       // 🐱
AppEmojis.rabbit    // 🐰
```

**Moods:**
```dart
AppEmojis.happy     // 😊
AppEmojis.excited   // 🤩
AppEmojis.calm      // 😌
AppEmojis.sleepy    // 😴
```

**Activities:**
```dart
AppEmojis.camera    // 📸
AppEmojis.walk      // 🚶
AppEmojis.play      // 🎾
AppEmojis.meal      // 🍖
```

**Health:**
```dart
AppEmojis.health    // ❤️
AppEmojis.weight    // ⚖️
AppEmojis.vaccine   // 💉
AppEmojis.doctor    // 👨‍⚕️
```

**Milestones:**
```dart
AppEmojis.birthday  // 🎂
AppEmojis.trophy    // 🏆
AppEmojis.star      // ⭐
AppEmojis.party     // 🎉
```

**Status:**
```dart
AppEmojis.add       // ➕
AppEmojis.success   // ✅
AppEmojis.error     // ❌
AppEmojis.warning   // ⚠️
```

### Helper Functions
```dart
EmojiHelper.prefix(AppEmojis.add, 'Add Pet')  // "➕ Add Pet"
EmojiHelper.suffix('Health', AppEmojis.health) // "Health ❤️"
```

---

## Usage Examples

### Example 1: Warm Card
```dart
Container(
  padding: EdgeInsets.all(24),
  decoration: BoxDecoration(
    color: AppColors.cardBg,
    borderRadius: AppRadius.allMD,
    boxShadow: AppColors.cardShadow,
  ),
  child: Column(
    children: [
      Text('${AppEmojis.paw} Pet Profile'),
      // ... content
    ],
  ),
)
```

### Example 2: Mood Selection Screen
```dart
Column(
  children: [
    Text('How is ${petName} feeling?'),
    MoodSelector(
      moods: [
        {'emoji': '😊', 'name': 'Happy'},
        {'emoji': '🤩', 'name': 'Excited'},
        {'emoji': '😴', 'name': 'Sleepy'},
      ],
      selectedMood: _mood,
      onMoodSelected: (mood) => setState(() => _mood = mood),
    ),
  ],
)
```

### Example 3: Empty State
```dart
if (posts.isEmpty) {
  return PlayfulEmptyStates.noPosts(
    onCreatePost: () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => CreatePostScreen()),
      );
    },
  );
}
```

### Example 4: Decorated Screen
```dart
Stack(
  children: [
    DecorativeBlobs(),
    Positioned.fill(
      child: SafeArea(
        child: Column(
          children: [
            Text('${AppEmojis.paw} Welcome'),
            // ... content
          ],
        ),
      ),
    ),
  ],
)
```

---

## Migration Guide

### Replacing Old Empty States
**Before:**
```dart
if (list.isEmpty) {
  return Center(child: Text('No items'));
}
```

**After:**
```dart
if (list.isEmpty) {
  return PlayfulEmptyStates.generic(
    emoji: AppEmojis.emptyBox,
    title: 'No items yet',
    message: 'Add your first item to get started',
    actionLabel: '${AppEmojis.add} Add Item',
    onAction: _handleAdd,
  );
}
```

### Adding Emojis to Existing UI
**Before:**
```dart
AppButton.primary(
  label: 'Add Pet',
  onPressed: _handleAdd,
)
```

**After:**
```dart
AppButton.primary(
  label: '${AppEmojis.add} Add Pet',
  onPressed: _handleAdd,
)
```

### Using Blob Backgrounds
```dart
// Wrap existing content
Stack(
  children: [
    DecorativeBlobs(),
    Positioned.fill(child: YourExistingContent()),
  ],
)
```

---

## Design Checklist

When creating new UI, ensure:

- [ ] Uses `AppRadius` constants (not hardcoded values)
- [ ] Buttons are pill-shaped or use soft rounded corners
- [ ] Empty states use `PlayfulEmptyState`
- [ ] Emojis used appropriately (not too many)
- [ ] Uses warm background colors (`screenBg`/`cardBg`)
- [ ] Spacing is generous (`AppSpacing.lg` minimum)
- [ ] Copy feels friendly and helpful
- [ ] Shadows are soft (`cardShadow`, not harsh)
- [ ] Colors match emotional context
- [ ] Feels welcoming to families

---

## Files Reference

### Created (v3.0)
- `lib/core/constants/app_emojis.dart` - 80+ emoji constants
- `lib/widgets/common/organic_blob.dart` - Organic shapes
- `lib/widgets/common/playful_empty_state.dart` - Friendly empty states

### Modified (v3.0)
- `lib/core/constants/app_colors.dart` - Warm color palette
- `lib/core/theme/app_dimensions.dart` - Doubled radius values
- `lib/widgets/common/app_button.dart` - Pill-shaped design
- `lib/core/theme/app_input_decoration.dart` - Soft inputs
- `lib/widgets/create_post/mood_selector.dart` - Blob-based

---

## Visual Comparison

### Before v3.0
- Sharp 12-16px corners
- White/grey backgrounds
- Square mood cards
- Plain "No data" messages
- Standard buttons

### After v3.0
- Soft 24-48px corners + pill buttons
- Warm cream/beige backgrounds
- Organic blob mood selectors
- Friendly emoji-rich empty states
- Playful, approachable design

---

## Resources

- **Moodiary** - Design inspiration source
- **Color Psychology** - Warm colors for emotional connection
- **Google Fonts** - Consider Nunito/Poppins for rounded typography (future phase)

---

**Version:** v3.0
**Last Updated:** 2026-01-08
**Status:** ✅ Complete & Production Ready
