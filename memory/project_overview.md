---
name: project-overview
description: GNUstep Billiards app architecture, game types, build setup, and preferences system
metadata:
  type: project
---

GNUstep Billiards app — pure ObjC, no ARC, no NIB/xib (all UI built programmatically in code).

**Build:** GNUmakefile (primary on Linux), Billiards.xcodeproj uses PBXFileSystemSynchronizedRootGroup so new files in Billiards/ are auto-included in Xcode.

**Key files:**
- `AppDelegate.m` — creates window, sets up menu (both #ifdef GNUSTEP and macOS branches), launches NewGameController on startup
- `BilliardsView.m` — main game view; draws table image + balls + HUD; uses `_tableImage` (NSImage ivar)
- `NewGameController.m` — modal panel for game type selection
- `PreferencesController.m` — singleton; preferences panel with table colour NSPopUpButton + NSImageView preview; persists to NSUserDefaults key `BilliardsTableColour`; posts `BilliardsTableColourDidChangeNotification`

**Game types:** Billiards, Pool (8-ball), Pool (9-ball), Snooker — defined in GameType.h enum

**Table images (all in Billiards/ subdir, listed as resources in GNUmakefile):**
- billiard_table.png — Green (default)
- billiard_table_black.png
- billiard_table_blue.png
- billiard_table_red.png
- billiard_table_white.png

**Preferences:** Selected via `BilliardsTableColourDefaultsKey` in NSUserDefaults. BilliardsView observes `BilliardsTableColourDidChangeNotification` to hot-swap `_tableImage` at runtime. Default is Green (`billiard_table`).
