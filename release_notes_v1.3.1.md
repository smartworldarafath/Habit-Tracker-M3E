# Habit Tracker M3E v1.3.1

Desktop rendering fix release (**Windows & Linux**).

## What's Fixed
- **Crisp text & icons on desktop:** Text and icons were being drawn as blocky, pixelated blobs in the Windows build. The desktop renderer is now forced to the stable Skia pipeline so every glyph renders sharp and clean.
- Applied the same fix to the **Linux** build.

## Downloads
- Streak-windows-x64.zip - Windows (x64)
- Streak-linux-x64.tar.gz / Streak-x86_64.AppImage - Linux (x64)
