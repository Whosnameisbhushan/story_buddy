# Peblo AI Story Buddy & Quiz Component

A beautiful, kid-friendly, and lightweight Flutter application designed for early and middle-grade education. This mobile app narrate stories to children using a sweet, native TTS voice and provides an interactive, data-driven quiz.

## 🚀 Key Features
- **Kid-Friendly Aesthetics**: Warm pastel color scheme, gentle shadows, and large button layouts optimized for children's hands.
- **Dynamic AI Buddy Character**: Floating neutral/talking state robot character that transitions into a happy jumping robot celebrating correct answers.
- **Data-Driven Quiz Engine**: Dynamically renders questions and varying option counts (3, 4, 5+) directly parsed from a backend JSON format.
- **Micro-Animations & Feedback**: Horizontal shake animation and haptic vibration feedback on incorrect answers, combined with physical-based confetti shower on success.
- **Native TTS Engine Integration**: Fully configured to leverage high-quality native female speech synthesis.

---

## 📝 Challenge Submission Write-up

### 1. Framework Selection
**We chose Flutter** for this project because:
- **Cross-Platform Consistency**: Single codebase rendering perfectly at 60fps on Android (with 3GB RAM constraint) and iOS.
- **Rich Animation Engine**: Flutter's declarative layout coupled with `AnimationController` and physics-based rendering (using `confetti`) delivers premium, smooth animations without loading heavy layout elements.
- **State Management**: Built-in reactive architecture allowing efficient view rebuilds through the `Provider` library.

### 2. Transition State Management
- When the user clicks **"Read Me a Story"**, the app enters a `loading` state, followed by `playing` once the audio is ready.
- The quiz card begins in a `hidden` state (`QuizStatus.hidden`).
- Once the TTS engine fires the completion handler, the ViewModel updates the state to `QuizStatus.visible`.
- The screen UI wraps the quiz card inside an `AnimatedSize` and `AnimatedOpacity` widget. As soon as the state changes, the layout transitions smoothly by expanding the space and fading in the quiz card without any abrupt layout shifts.

### 3. Data-Driven Quiz Renderer
- Rather than hardcoding widgets, the app parses a standard backend JSON structure into a `Quiz` model.
- We utilize Dart's `List.generate` combined with dynamic theme styling mapping inside a scrollable vertical column:
  - Supports 3, 4, 5, or more options out-of-the-box.
  - Automatically indexes option labels (A, B, C, D...) using character offsets `String.fromCharCode(65 + index)`.
  - All styling details (selection color, success outline, disabled state) are derived dynamically from the `selectedOption` and `quizStatus` state.

### 4. Caching Approach (Remote Audio)
- For native TTS, the voice synthesis happens on-device, meaning local caching is managed natively by the operating system.
- **If integrating a remote TTS API (such as ElevenLabs)**:
  - We would use the `path_provider` package to access the local application support directory.
  - Prior to making a request, we would generate a MD5 hash of the requested text string (e.g. `md5(storyText)`).
  - Check if `app_directory/audio_cache/[hash].mp3` exists.
  - If it exists, play the local audio file using `just_audio` or `audioplayers` immediately, saving bandwidth and offering instantaneous playback.
  - If it doesn't, request the audio from ElevenLabs API, save the response byte stream to the file, and then play it.

### 5. Audio Loading and Failure Handling
- **Loading State**: When TTS begins preparing, the button switches to an indigo color, showing a circular loader and text "Preparing Story...".
- **Error State**: If speech synthesis fails (e.g. missing speech engines, audio driver issues), the state updates to `TtsStatus.error`.
- **User Feedback**: A soft-red warning banner appears below the main button explaining the error in friendly, child-appropriate language ("Oops! I couldn't read the story...").
- **Retry Mechanism**: A refresh/retry button is embedded inside the banner allowing the child to trigger synthesis again without resetting their progress.

### 6. Performance Optimization for Mid-Range Android Devices (≈3GB RAM)
- **Targeted Rebuilds**: Decoupled the UI widgets (`BuddyWidget`, `StoryCard`, `QuizCard`, `CelebrationOverlay`) and wrapped them with scoped `Consumer` widgets. This ensures that when the TTS state changes, the options card does not rebuild, and vice-versa.
- **Garbage Collection (GC) Mitigation**: Avoided allocating multiple controllers inside builders. `AnimationController` and `ConfettiController` are stored as widget state and disposed of in `dispose()` to prevent memory leaks.
- **Lightweight Asset Size**: The custom-designed buddy images are compressed and scale-optimized, taking less than 200KB of memory footprints.
- **Zero Heavy Renderers**: The horizontal shake animation is implemented using a lightweight, pure mathematical translation: `math.sin(value * 4 * math.pi) * 12.0` instead of a heavy external animation package.

### 7. AI Usage & Judgment
- **AI Assistance**: AI was utilized to draft initial layout suggestions, write basic test structures, and generate custom cartoon assets (`buddy_neutral.png`, `buddy_happy.png`).
- **Rejected Suggestions**:
  - The AI initially suggested using third-party package for the shake animation (e.g., `flutter_animator` or `animate_do`). We rejected this suggestion to minimize package overhead and keep the binary lightweight for 3GB RAM devices. We chose to write a custom, mathematically driven `AnimatedBuilder` instead.
  - It suggested rebuilding the whole screen on every tick of the floating animation. We modified this to use `AnimatedBuilder` targeting only the specific image translation to prevent 60fps performance drops.
- **Resolved Issues**:
  - Tapping options during the success screen caused unexpected state resets. Resolved by disabling button interactions once `QuizStatus.correctAnswer` is active.

---

## 🛠️ Getting Started

### Prerequisites
- Flutter SDK (stable channel)
- Android SDK / Android Studio configured

### Running the App
1. Clone or copy this repository:
   ```bash
   cd story_buddy
   ```
2. Fetch dependencies:
   ```bash
   flutter pub get
   ```
3. Run the application:
   ```bash
   flutter run
   ```

### Running Tests
Verify the widget structure and state flow by running tests:
```bash
flutter test
```
