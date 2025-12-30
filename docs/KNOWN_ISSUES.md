# Known Issues and Future Tasks

This document tracks known issues and planned improvements for the Tux Target game.

## High Priority

### 1. Missing Maps
**Status:** Not Started
**Description:** Not all maps are available anymore. Maps like Classic, Classic Fight, and others were removed due to v1.5.19 Lua API incompatibility.

**Affected Maps:**
- Classic, Classic Easy, Classic Fight, Classic Flat
- City Darts, City Destroy, City Easy, City Paint, City Precision
- Space Asteroids, Space Atomium, Space Fleet, etc.
- Sun Cross, Sun Extra Ball, Sun Paint, Sun Shrinker, Sun Target
- And many more (64 total removed)

**Solution:** Implement a Lua API compatibility layer that translates v1.5.19 `CLevel:method()` calls to v1.2.2a declarative table format, or port each level manually.

---

### 2. Bot AI Not Working on All Maps
**Status:** Not Started
**Description:** Bots aren't deploying (playing) correctly on all maps. This appears to be a per-map issue where bot behavior may depend on level-specific scripting.

**Symptoms:**
- Bots may not move properly
- Bots may not aim for targets correctly
- Some maps work better than others

**Solution:** Review and fix bot behavior on a per-map basis. May require updating Lua server scripts for each level.

---

## Medium Priority

### 3. High Ping on Local Server
**Status:** Not Started
**Description:** Playing on a locally-hosted server results in 15-17ms ping. Modern games typically have near-zero ping for local connections.

**Possible Causes:**
- Network tick rate too low
- Artificial delay in network code
- Inefficient packet handling
- Sleep/wait calls in network loop

**Investigation Areas:**
- `server/src/network.cpp` - Network tick rate and packet handling
- `server/src/physics.cpp` - Physics update rate
- Client-side prediction and interpolation settings

---

### 4. Input Delay / Steering Lag
**Status:** Not Started
**Description:** There's a noticeable delay between steering inputs and the penguin actually changing direction. This may be related to the high ping issue.

**Symptoms:**
- Delayed response to arrow key/WASD input
- Penguin takes time to turn
- Feels "laggy" even on local server

**Possible Causes:**
- Client-side input buffering
- Server-side input processing delay
- Interpolation smoothing too aggressive
- Network update rate too low

**Related Files:**
- `client/src/interpolator.cpp` - Client-side movement interpolation
- `client/src/mtp_target.cpp` - Input handling
- `server/src/entity.cpp` - Server-side entity updates

---

### 5. Momentum Loss on Ramp Transition
**Status:** Not Started
**Description:** Sometimes when hitting the bottom of the starting slope and transitioning into the launch ramp, all momentum is lost even when fully accelerating. This also affects bots occasionally.

**Symptoms:**
- Penguin suddenly stops at ramp transition
- Happens even with full acceleration
- Bots also affected

**Possible Causes:**
- Physics collision issue at geometry seams
- Velocity not being updated frequently enough (related to ping?)
- ODE physics contact handling
- Ground detection resetting velocity

**Investigation Areas:**
- `server/src/physics.cpp` - Collision handling
- Level geometry - Check for gaps/seams at ramp transitions
- Entity velocity update frequency

---

### 6. Darts Map Spawn Position
**Status:** Not Started
**Description:** On the "Darts" map, all penguins spawn too far back from the launch pad. This map has a long flat straight black surface that accelerates players toward a vertical dart board.

**Note:** This issue was observed before build process updates and needs re-testing.

**Details:**
- Map: `level_darts.lua` (currently removed)
- Start points may be incorrectly positioned
- Need to verify spawn positions match level design

---

## Low Priority / Nice to Have

### 7. Water Rendering Disabled
**Status:** Workaround Applied
**Description:** Water rendering is currently disabled because the required water textures or shaders are missing.

**Current Workaround:** Water task falls back gracefully when `water_light.shape` is missing.

---

### 8. Version Compatibility
**Status:** Ongoing
**Description:** The current build uses v1.2.2a source code. Some features from v1.5.19 are not available.

**Future Goal:** Port v1.5.19 features while maintaining stability, or create a compatibility layer.

---

## Completed

- [x] Fix client crash when connecting to server
- [x] Fix server crash on client connection
- [x] Fix ODE physics assertion crash
- [x] Fix missing textures (snow, water, etc.)
- [x] Fix penguin visual size matching collision sphere
- [x] Fix keyboard controls (chat no longer captures arrow keys)
- [x] Implement Lua include() function for level files
- [x] Add build automation scripts
- [x] Consolidate game assets in data/ directory

---

## Contributing

If you'd like to help fix any of these issues:
1. Fork the repository
2. Create a feature branch
3. Submit a pull request with your fix

Please include:
- Description of the fix
- Testing steps
- Any relevant screenshots or logs
