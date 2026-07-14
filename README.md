# F1 Companion

F1 Companion is a highly polished, responsive Flutter application designed to give Formula 1 fans a premium companion screen experience. The app connects to the public **OpenF1 API** and **MultiViewer API** to deliver real-time data, session countdowns, and a full Race Replay telemetry map visualization.

---

## Key Features

### 1. 2026 F1 Countdown & Calendar
- **Live Countdown**: A precise ticker showing days, hours, minutes, and seconds until the next session (Practice, Qualifying, Sprint, or Grand Prix).
- **Weekend Session Timings**: Automatically fetches and lists local session schedules for the upcoming race weekend.
- **Scrollable Calendar**: View all Grand Prix meetings of the 2026 season. It automatically scrolls to focus on the next upcoming race (showing completed races above and upcoming ones below).
- **Track Outline Rendering**: Outlines for circuit maps are fetched and tinted to white using a custom **Luminance-to-Alpha matrix filter**, ensuring clean outlines (including the Hungarian GP) render perfectly on dark themes.

### 2. Interactive Race Replay & Telemetry
- **Leaderboard**: Real-time table displaying driver position, acronym, last lap/gap, tyre compound, and pit stop count.
- **Retirement Detection**: Automatically identifies retired/crashed drivers, tags them as `Out`, and sorts them to the bottom of the table.
- **Smooth Interpolation Map**: Smoothly animates the position of all 22 drivers around the track map at ~60 FPS.
- **Playback Controls**: Play, pause, seek, speed multiplier (up to 20x), and adjustable API refresh rates.
- **Track Status Flags**: Reflects real-time safety cars, virtual safety cars (VSC), and red flags directly via track line color indicators (Green, Yellow, Red).

---

## Technical Stack & Architecture

- **Framework**: Flutter (Dart)
- **State Management**: `Provider` for reactive state propagation (`CountdownProvider`, `RaceReplayProvider`, `NavigationProvider`).
- **Telemetry Math**: High-performance linear interpolation (LERP) algorithms in Dart that search coordinate caches and compute intermediate (x, y) driver positions relative to the playback clock.
- **Theme**: Premium dark mode theme with glassmorphic elements and high-contrast neon accents.

---

## Optimization & Security

### 1. Battery & Memory Management
- **Tab-Aware Lifecycle**: By observing tab switching, the app stops the 1-second countdown timer when the countdown is hidden.
- **Playback Auto-Pause**: If a race replay is running, it automatically pauses (canceling both the high-frequency 60 FPS animation timer and the API background fetch polling) as soon as the user navigates away from the Replay screen. This prevents battery drain and CPU overhead.
- **Idempotent Timers**: Prevents starting multiple periodic loops simultaneously.

### 2. Screen Scaling & Responsiveness (Tablets & Foldables)
- **Responsive Layout Engine**: Implements layout policies that scale from small phones to large tablets and unfolded foldables (supporting both portrait and landscape modes).
- **Tablet Portrait Optimizations**: Stacks elements vertically but keeps the countdown card and schedule side-by-side to prevent awkward horizontal stretching.
- **Auto-Collapsing Controls**: On narrow landscape screens or split-screen foldables, the media player bar shrinks margins and collapses label text strings (e.g. hiding "LAP" text but keeping the icon and value) to avoid clipping and horizontal scroll boundaries.

### 3. Secure Connection Handling
- **Secure Network Timeouts**: A 15-second timeout `.timeout(const Duration(seconds: 15))` is enforced on all API calls (OpenF1, MultiViewer, Jolpica) to prevent requests from hanging indefinitely under poor network conditions.

---

## Getting Started & Compilation

To build and run the application locally on a connected device:

1. **Pre-requisites**: Ensure Flutter SDK and Android SDK are installed and a device is connected.
2. **Build and Install Release APK**:
   ```bash
   # Build the APK in release mode
   flutter build apk --release
   
   # Install to connected device via adb
   adb install -r build/app/outputs/flutter-apk/app-release.apk
   ```
3. **Run Unit Tests**:
   ```bash
   flutter test
   ```
