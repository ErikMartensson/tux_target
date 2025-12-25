# Runtime Fixes & File Modifications

This document describes all the fixes required after building the client and server to make the game actually playable.

**Last Updated:** December 25, 2024

---

## Overview

After successfully building both the client (tux-target.exe) and server (tux-target-srv.exe), several runtime issues were discovered that prevented gameplay. This document catalogues each issue, its root cause, and the fix applied.

---

## Critical Crash Fixes

### 1. Client Crash: Water Rendering

**Symptom:**
- Client crashes with access violation (0xc0000005) at offset 0x196e3c
- Occurs during level loading after connecting to server

**Root Cause:**
- Water rendering code ([water_task.cpp:146-154](../client/src/water_task.cpp#L146-L154)) creates textures with empty filenames
- Missing texture files: `water_env.tga`, `water_disp.tga`, `water_disp2.tga`
- Code attempts: `new CTextureFile(res)` where `res` is an empty string

**Fix:**
- Disabled water rendering in [mtp_target_default.cfg](../build/bin/Release/mtp_target_default.cfg)
- Changed `DisplayWater = 2` to `DisplayWater = 0` (line 49)

**Status:** ✅ Fixed - water doesn't render but game doesn't crash

**Future:** Need to either find original water textures or create compatible ones

---

### 2. Server Crash: Missing Level Files

**Symptom:**
- Server crashes immediately when client connects
- Failed assertion: `"levels.size() > 0"` at [level_manager.cpp:142](../server/src/level_manager.cpp#L142)

**Root Cause:**
- Server attempts to load a level when client connects
- No level files present in `build/bin/Release/data/level/`

**Fix:**
- Copied 69 level files from mtp-target-src (v1.5.19) to `data/level/`
- Level files are forward compatible (v1.5.19 levels work with v1.2.2a server)

**Command:**
```bash
mkdir -p build/bin/Release/data/level
cp mtp-target-src/data/level/*.lua build/bin/Release/data/level/
```

**Status:** ✅ Fixed - all 69 levels loaded successfully

---

### 3. Server Crash: Lua Script Path Errors

**Symptom:**
- Server crashes during level transitions
- Log shows: `Failed to load data/lua/level_darts_server.lua with error code 1`

**Root Cause:**
- All 69 level files referenced server Lua scripts with incorrect relative paths
- Level files contained: `ServerLua = "level_darts_server.lua"`
- Actual location: `data/lua/level_darts_server.lua`

**Fix:**
- Updated all 69 level files using sed:
```bash
cd build/bin/Release/data/level
sed -i 's/ServerLua = "\([^"]*\)"/ServerLua = "data\/lua\/\1"/' *.lua
```

**Example change:**
```diff
- ServerLua = "level_darts_server.lua"
+ ServerLua = "data/lua/level_darts_server.lua"
```

**Status:** ✅ Fixed - level transitions now work

---

## Visual/Content Fixes

### 4. Wrong Skybox Theme

**Symptom:**
- Skybox displays city buildings instead of snow/antarctica theme
- Game is supposed to feature penguins in antarctic setting

**Root Cause:**
- Generic `sky.shape` file was a copy of `sky_city.shape`
- Data directory contains multiple skybox variants: `sky_snow.shape`, `sky_city.shape`, etc.

**Fix:**
```bash
cd build/bin/Release/data/shape
rm sky.shape
cp sky_snow.shape sky.shape
```

**Status:** ✅ Fixed - correct snowy skybox now displays

---

### 5. Penguin Rendering Issues

**Symptom:**
- Penguins rendered too large and overlapping each other
- All penguins occupy the same visual space

**Root Cause:**
- Unknown - possibly scale settings in model files or rendering code

**Status:** ⚠️ Unfixed - visual issue but doesn't prevent gameplay

**Investigation Needed:**
- Check penguin model files (.shape files)
- Review entity rendering scale in client code
- Compare with screenshots from original game

---

## Gameplay Fixes

### 6. Keyboard Controls Not Working

**Symptom:**
- Arrow keys don't steer the penguin in ball or gliding mode
- WASD keys type characters into chat instead of controlling movement
- User reports: "I can't control my pingoo at all"

**Root Cause:**
- Chat system ([chat_task.cpp:88](../client/src/chat_task.cpp#L88)) captures ALL keyboard input via `kbGetString()`
- This happens every frame, before control code can read key states
- Arrow keys and letter keys are consumed by chat before reaching [controler.cpp](../client/src/controler.cpp)

**Fix:**
Modified chat system to only capture input when explicitly activated:

**File: [client/src/chat_task.h](../client/src/chat_task.h)**
- Added `bool chatActive;` member variable

**File: [client/src/chat_task.cpp](../client/src/chat_task.cpp)**
- Initialize `chatActive = false` in `init()`
- Only call `kbGetString()` when `chatActive == true`
- Toggle chat mode on/off when Return/Enter key is pressed
- Allow Escape key to cancel chat mode
- Show visual cursor (`_`) when chat is active

**New Controls:**
- **Return/Enter:** Activate chat (press again to send message)
- **Escape:** Cancel chat without sending
- **Arrow keys:** Now work for steering (previously captured by chat)
- **CTRL:** Toggle between ball and gliding modes (unchanged)

**Status:** ✅ Fixed - full keyboard control restored

**Files Modified:**
- [client/src/chat_task.h](../client/src/chat_task.h): Added chatActive flag
- [client/src/chat_task.cpp](../client/src/chat_task.cpp): Implemented chat toggle logic

---

## Missing Files & Dependencies

### 7. Missing Driver DLLs

**Symptom:**
- Client fails to start with error: `Load library 'nel_drv_opengl_win_r.dll' failed`

**Root Cause:**
- NeL drivers are separate DLLs built from Ryzom Core
- Not automatically copied to game directory

**Fix:**
Built and copied driver DLLs:
```bash
cd /c/ryzomcore/build
cmake --build . --config Release --target nel_drv_opengl_win -j 24
cmake --build . --config Release --target nel_drv_openal_win -j 24
cp bin/Release/nel_drv_opengl_win_r.dll /c/Users/User/Repos/tux_target/build/bin/Release/
cp bin/Release/nel_drv_openal_win_r.dll /c/Users/User/Repos/tux_target/build/bin/Release/
```

**Required Files:**
- `nel_drv_opengl_win_r.dll` (1.4 MB) - Graphics driver
- `nel_drv_openal_win_r.dll` (870 KB) - Sound driver

**Status:** ✅ Fixed - see post-build script below

---

### 8. Missing Font Files

**Symptom:**
- Client log shows: `PATH: File (n019003l.pfb) not found`

**Root Cause:**
- Font files not included in repository
- NeL requires specific PostScript and TrueType fonts

**Fix:**
Copied fonts from Ryzom Core samples:
```bash
mkdir -p build/bin/Release/data/font
cp /c/ryzomcore/nel/samples/3d/cegui/datafiles/n019003l.pfb \
   build/bin/Release/data/font/
cp /c/ryzomcore/nel/samples/3d/font/beteckna.ttf \
   build/bin/Release/data/font/bigfont.ttf
```

**Required Files:**
- `n019003l.pfb` (27 KB) - Century Schoolbook font
- `bigfont.ttf` (17 KB) - Display font (renamed from beteckna.ttf)

**Status:** ✅ Fixed - see post-build script below

---

### 9. Missing Configuration Variables

**Symptom:**
- Client crashes on startup: `Exception will be launched: variable "VSync" not found`

**Root Cause:**
- User config file missing required variables expected by client

**Fix:**
Added to `C:\Users\User\AppData\Roaming\tux-target.cfg`:
```cfg
VSync                = 0;
AntiAlias            = 0;
SoundDriver          = "OpenAL";
MusicVolume          = 0.8000000000;
SoundVolume          = 0.8000000000;
```

**Status:** ✅ Fixed

---

## Automated Post-Build Setup

To avoid repeating these manual steps, use the provided post-build script:

**File:** [scripts/post_build.sh](../scripts/post_build.sh)

```bash
# Run after building client/server
./scripts/post_build.sh
```

The script automatically:
1. Copies driver DLLs from Ryzom Core
2. Copies font files
3. Creates data directory structure
4. Copies default config files
5. Verifies all required files are present

---

## Summary Table

| Issue | Component | Severity | Status | Fix Location |
|-------|-----------|----------|--------|--------------|
| Water rendering crash | Client | Critical | ✅ Fixed | mtp_target_default.cfg |
| Missing level files | Server | Critical | ✅ Fixed | Copied from archive |
| Lua script paths | Server | Critical | ✅ Fixed | Level files updated |
| Wrong skybox | Client | Minor | ✅ Fixed | Replaced sky.shape |
| Penguin overlap | Client | Minor | ⚠️ Unfixed | TBD |
| Keyboard controls | Client | Critical | ✅ Fixed | chat_task.cpp/h |
| Missing drivers | Client | Critical | ✅ Fixed | Post-build script |
| Missing fonts | Client | Critical | ✅ Fixed | Post-build script |
| Missing config vars | Client | Minor | ✅ Fixed | User config |

---

## Configuration Files

### Client Configuration

**Primary Config:** `build/bin/Release/mtp_target_default.cfg`
- `DisplayWater = 0` - Disabled water rendering

**User Config:** `C:\Users\User\AppData\Roaming\tux-target.cfg`
- Contains login credentials and user preferences

### Server Configuration

**Server Config:** `build/bin/Release/mtp_target_service.cfg`
- Copied from `server/mtp_target_service_default.cfg`
- Configures bot behavior, network settings, physics parameters

---

## Known Issues (Remaining)

### Penguin Size/Overlap
- **Impact:** Visual only, doesn't prevent gameplay
- **Next Steps:**
  - Compare model files with working version
  - Review entity scale settings in code
  - Check camera distance settings

### Water Rendering Disabled
- **Impact:** Missing visual element
- **Next Steps:**
  - Search for original water texture files
  - Or create compatible replacement textures
  - Test with water rendering re-enabled

### Level Transition Stability
- **Impact:** Some level transitions may crash
- **Status:** Partially fixed, monitoring for issues
- **Next Steps:** Test all 69 levels

---

## Future Improvements

1. **Automated Testing**
   - Script to verify all required files present
   - Checksum validation for copied files
   - Automated startup test

2. **Better Error Messages**
   - Detect missing files before crash
   - Guide user to run post-build script
   - Validate config files on startup

3. **Packaging**
   - Create installer that includes all dependencies
   - Bundle required fonts and textures
   - Pre-configure for local play

---

## References

- [BUILDING.md](BUILDING.md) - How to build client and server
- [MODIFICATIONS.md](MODIFICATIONS.md) - Source code changes for modern compatibility
- Post-build script: [scripts/post_build.sh](../scripts/post_build.sh)
- Build dependencies: [CONTINUATION_PROMPT.md](../CONTINUATION_PROMPT.md) (gitignored)

---

**Last Updated:** December 25, 2024
**Tested With:** Version 1.2.2a (client and server)
**Platform:** Windows 11, Visual Studio 2022 Build Tools
