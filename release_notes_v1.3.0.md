# Habit Tracker M3E v1.3.0

Welcome to **Habit Tracker M3E v1.3.0**! This release brings high refresh rate display support (120Hz & 144Hz), full Light Mode background fixes, Predictive Back animations, floating profile avatar Hero preview with pencil edit action, and complete brand polish.

## What's New in v1.3.0

### ☀️ Pure Light Mode Fix
- **Pristine Backgrounds:** Resolved an issue where background remained dark in light mode across Today, To-do, Plan, Stats, and Settings tabs. The splash transition scaffold now cleanly releases upon completion, allowing light theme surfaces and wallpapers to shine through with full clarity.
- **Accurate System Theme Tracking:** Theme brightness and status bar overlays dynamically synchronize with chosen appearance options.

### ⚡ 120Hz & 144Hz Native High Refresh Rate
- **Max Native Display Rates:** Unlocked full 120Hz and 144Hz refresh rates across phones and tablets (including Xiaomi Pad 7, 7 Pro, 8, 8 Pro, and flagship high-refresh Android devices).
- **Butter-Smooth Scrolling:** Automatically queries display supported modes to match device resolution with peak refresh rate (`preferredDisplayModeId`).

### 🔙 Predictive Back Gesture & Smooth Page Transitions
- **Predictive Back Navigation:** Enabled `android:enableOnBackInvokedCallback="true"` with interactive swipe-to-pop gestures and smooth deceleration transitions across all Settings sections and navigation routes.
- **Natural Tactile Feedback:** Fluid interactive drag gestures make navigating deep sub-menus effortless.

### 🖼️ Profile Avatar Hero Transition & Edit Action
- **Shared Element Floating Preview:** Tapping the profile picture in Settings now triggers a smooth Hero transition enlarging the avatar floating over a frosted blurred backdrop.
- **Quick Edit Pencil Action:** Includes a dedicated floating pencil icon button next to the enlarged avatar to quickly update or pick a new profile photo.

### 🏷️ Complete Brand Polish ('M3E')
- **Settings Footers & App Branding:** Updated Settings bottom version footer to `M3E v1.3.0` and refined app headers, notification channels, onboarding title, and share cards to `M3E` / `Habit Tracker M3E`.
- **Package Integrity:** Verified package identifier as `com.habittrackerm3e.app`.

### 📦 Multi-Architecture Downloads
- **Optimized Device Builds:**
  - `HabitTracker-v1.3.0-arm64-v8a.apk` (Modern 64-bit Android smartphones & tablets)
  - `HabitTracker-v1.3.0-armeabi-v7a.apk` (32-bit Android devices)
  - `HabitTracker-v1.3.0-x86_64.apk` (64-bit Emulators & Intel/AMD devices)
  - `HabitTracker-v1.3.0-universal.apk` (All-in-one universal installer)
  - `HabitTracker-v1.3.0-apks.tar.gz` (Complete release archive)
- **Automatic In-App Updates:** In-app updater detects your device ABI and automatically downloads the optimal APK for your device.
