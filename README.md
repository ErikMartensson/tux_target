# MTP Target - Community Revival

<p align="center">
  <img src="assets/site_logo.png" alt="MTP Target Logo" width="170" height="94">
</p>

> A free multiplayer online action game where you roll down a giant ramp and delicately land on platforms to score points. Fight with and against players in this mix of action, dexterity, and strategy - inspired by Monkey Target from Super Monkey Ball.

**Status:** ✅ Playable - Version 1.2.2a client and server working in LAN mode with scoring and physics

---

## Table of Contents

- [About This Project](#about-this-project)
- [Current Status](#current-status)
- [Quick Start (Ubuntu/WSL)](#quick-start-ubuntuwsl)
- [Documentation](#documentation)
- [Architecture](#architecture)
- [What We've Fixed](#what-weve-fixed)
- [Contributing](#contributing)
- [Original Game Info](#original-game-info)
- [Project Goals](#project-goals)
- [Known Issues](#known-issues)
- [License](#license)
- [Credits](#credits)
- [Contact & Community](#contact--community)

---

## About This Project

**MTP Target** was created by Melting Pot in 2003-2004 and went offline around 2013. This is a community effort to bring it back to life by:

1. ✅ **Building a local server** - Run your own game server
2. ✅ **Creating a modern login service** - TypeScript/Deno replacement for authentication
3. ✅ **Compiling the client** - Build from source for debugging and modifications
4. ✅ **Windows support** - Full Windows build with Visual Studio 2022

### Version Strategy

We're currently running **version 1.2.2a** (from this repository's source code) for both client and server. This ensures full compatibility between all components.

**Future Plans:**
- Port features and improvements from version 1.5.19 where possible
- Add additional levels from 1.5.19 release
- Consider protocol upgrade to 1.5.19 if compatible with gameplay

The original v1.5.19 server source is unavailable, so we're starting with the v1.2.2a codebase we have and will enhance it over time.

---

## Current Status

### What Works ✅

- ✅ **Build System:** Full Windows build with Visual Studio 2022 working
- ✅ **Game Server:** Compiles and runs on Windows, 71 levels loaded
- ✅ **Game Client:** Compiles and runs on Windows with OpenGL/OpenAL drivers
- ✅ **Login Service:** Modern TypeScript implementation handles authentication
- ✅ **Database:** SQLite-based user and shard management
- ✅ **Physics:** ODE 0.16.5 engine with Lua 5.x scripting (mostly working)
- ✅ **Network:** Full protocol working (VLP login + game server connection)
- ✅ **Basic Controls:** Keyboard input (arrow keys, Ctrl, Enter for chat)

### Known Issues ⚠️

**Visual/Polish Issues:**
- ⚠️ **Water rendering disabled** - Missing texture files cause crash (DisplayWater = 0 workaround)
- ⚠️ **Limited to v1.2.2a features** - Some v1.5.19 improvements not yet ported
- ⚠️ **9 level scripts need conversion** - Some special game modes don't work yet

**The game is fully playable!** Scoring, friction, and bot AI all work correctly.

See [docs/RUNTIME_FIXES.md](docs/RUNTIME_FIXES.md) for detailed issue documentation.

---

## Quick Start (Windows)

**Prerequisites:**
- Windows 10/11
- Visual Studio 2022 Build Tools
- CMake 3.20+
- Deno 2.6.0+ (for login service)
- Git Bash (recommended for running scripts)

### 1. Build Dependencies

See **[docs/BUILDING.md](docs/BUILDING.md)** for complete instructions on building:
- NeL Framework (from Ryzom Core)
- ODE Physics Library (0.16.5)
- External dependencies (CURL, Lua, libxml2, etc.)

### 2. Build Game Client & Server

```bash
cd tux_target
mkdir build && cd build

# Configure
cmake .. -DBUILD_CLIENT=ON -DBUILD_SERVER=ON \
  -DWITH_STATIC=ON -DWITH_STATIC_LIBXML2=ON -DWITH_STATIC_CURL=ON

# Build
cmake --build . --config Release -j 24

# Run post-build setup
cd ..
./scripts/post_build.sh  # or scripts\post_build.bat on Windows
```

### 3. Start Services

```bash
# Terminal 1: Start login service
cd login-service-deno
deno task login

# Terminal 2: Start game server
cd build/bin/Release
./tux-target-srv.exe

# Terminal 3: Start game client
cd build/bin/Release
./tux-target.exe
```

**Controls:**
- **Arrow keys:** Steer penguin (requires speed in ball mode)
- **CTRL:** Toggle between ball/gliding modes
- **Enter:** Open chat (press again to send)
- **Escape:** Cancel chat

**Chat Commands:**

| Command | Description |
|---------|-------------|
| `/help` | Show available commands |
| `/v <name>` | Vote for a level (e.g., `/v arena`) |
| `/forcemap <name>` | Force next level (admin) |
| `/forceend` | End current session (admin) |

See **[docs/LEVELS.md](docs/LEVELS.md)** for the complete level list and map names.

For detailed build instructions and troubleshooting, see **[docs/BUILDING.md](docs/BUILDING.md)** and **[docs/RUNTIME_FIXES.md](docs/RUNTIME_FIXES.md)**.

---

## Documentation

| Document | Description |
|----------|-------------|
| [**BUILDING.md**](docs/BUILDING.md) | Complete build guide for Windows (NeL, ODE, client, server) |
| [**RUNTIME_FIXES.md**](docs/RUNTIME_FIXES.md) | Runtime crashes and fixes (water, levels, controls, files) |
| [**LEVELS.md**](docs/LEVELS.md) | Level list and chat commands for voting/forcing maps |
| [**MODIFICATIONS.md**](docs/MODIFICATIONS.md) | Source code changes for modern compatibility |
| [**PROTOCOL_NOTES.md**](docs/PROTOCOL_NOTES.md) | NeL network protocol technical reference |
| [**scripts/post_build.sh**](scripts/post_build.sh) | Automated post-build file copy script |
| [**docs/archive/**](docs/archive/) | Historical development notes (reference only) |

---

## Architecture

```
┌─────────────┐         ┌──────────────┐         ┌──────────────┐
│   Client    │────────>│Login Service │────────>│   Database   │
│ (Windows)   │  Auth   │  (Deno/TS)   │  Query  │  (SQLite)    │
│             │<────────│   Port 49997 │<────────│              │
└─────────────┘  Shards └──────────────┘         └──────────────┘
       │
       │ Connect with cookie
       v
┌─────────────┐
│Game Server  │
│  (C++/NeL)  │  Lua scripts, ODE physics, multiplayer logic
│ Port 51574  │
└─────────────┘
```

**Technology Stack:**
- **Game Server:** C++ with NeL framework, ODE physics, Lua 5.1
- **Login Service:** TypeScript/Deno with SQLite
- **Client:** C++ with NeL 3D engine (original Windows binary or from source)

---

## What We've Fixed

The original code was from 2003-2004 and needed updates for modern systems:

- ✅ **Lua 5.0 → 5.1** - Migrated to currently supported Lua version
- ✅ **64-bit compatibility** - Fixed pointer casts and size types
- ✅ **Modern NeL API** - Updated for RyzomCore (NeL's successor)
- ✅ **ODE 0.5 → 0.16** - Physics engine upgrade
- ✅ **Namespace fixes** - Resolved conflicts with modern C++ std library

See [docs/MODIFICATIONS.md](docs/MODIFICATIONS.md) for technical details.

---

## Contributing

We'd love your help! This is a community effort to preserve a fun open-source game.

### Areas Where We Need Help

- **Windows Build System:** CMake configuration for Visual Studio
- **Client Compilation:** Getting the client to build on Windows
- **Protocol Documentation:** Reverse engineering remaining message formats
- **Testing:** Trying the server on different platforms
- **macOS Support:** Build instructions and testing

### How to Contribute

1. Fork this repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Make your changes
4. Test thoroughly
5. Commit with clear messages
6. Push and create a Pull Request

**Not a coder?** You can still help with:
- Documentation improvements
- Testing and bug reports
- Sharing knowledge about the original game
- Spreading the word

---

## Original Game Info

**MTP Target** was created by Melting Pot (Ace, Muf, Skeet) in 2003-2004 and active until ~2009.

**Main Features (from original site):**
- Immediate fun - no need to play 10 hours
- Short games - 1 minute rounds
- Original gameplay
- Five minutes to learn, weeks to master
- Tons of easy and hard levels
- Team maps with specific gameplay
- Up to 16 players simultaneously per server
- Free software (GPL) and free to play
- Tournaments

**Technical Stack:**
- **Engine:** NeL 3D (Nevrax Engine Library) from Ryzom
- **Physics:** ODE (Open Dynamics Engine)
- **Scripting:** Lua for game modes and levels
- **Platforms:** Windows, Linux, and Mac (originally)

---

## Project Goals

### Short Term
- [x] Get server running on modern Linux
- [x] Build working login service
- [ ] Debug SCS message format (in progress)
- [ ] Compile client from source
- [ ] Test full connection flow

### Medium Term
- [ ] Windows build system
- [ ] Automated builds (GitHub Actions)
- [ ] Docker containers for easy deployment
- [ ] Modern authentication (optional)
- [ ] Web-based server browser

### Long Term
- [ ] Community servers
- [ ] Custom levels and mods
- [ ] Updated graphics (optional)
- [ ] Modern networking (optional)

---

## Known Issues

### Visual/Polish Issues
- **Water rendering disabled** - Missing texture files (water_env.tga, water_disp.tga) cause client crash
  - Workaround: `DisplayWater = 0` in config
- **Limited to v1.2.2a features** - Some improvements from v1.5.19 not yet ported
- **9 level scripts need API conversion** - Some special game modes (darts, gates, bowls) don't work yet

### Fixed Issues ✅
- ✅ Build system - Full Windows compilation working
- ✅ Client/server crashes - Major crashes resolved
- ✅ **Scoring system** - Players and bots score correctly on landing platforms
- ✅ **Friction system** - Penguins slow down properly on target platforms
- ✅ **Server level transition crashes** - Lua 5.x compatibility fixes applied
- ✅ **Chat commands** - Vote and admin commands work with feedback
- ✅ Keyboard controls - Arrow keys work for steering, chat toggle working
- ✅ Physics steering - Entity acceleration and module override fixed
- ✅ Penguin visual size - Mesh scaling applied (was too large)
- ✅ Camera controls - Zoom persists on mouse drag, defaults to good view
- ✅ FreezeCommand bug - Entities properly unfrozen on game start
- ✅ Level loading - All 71 levels load correctly
- ✅ Skybox rendering - Correct antarctic theme displays
- ✅ Network protocol - Full compatibility achieved

See [docs/RUNTIME_FIXES.md](docs/RUNTIME_FIXES.md) for complete issue history and [Issues](../../issues) for bug tracker.

---

## License

This game is free software released under the **GNU GPL v2+** license.

See [COPYING](COPYING) for full license text.

---

## Credits

### Original Developers (2003-2004)
- **Code:** Ace, Muf, Skeet (Melting Pot)
- **Sounds:** Garou
- **Music:** Hulud (Digital Murder)
- **Graphics:** 9dan, Paul, Kaiser Foufou, Hades
- **Testing:** Darky, Dyze, Felix, Grib, R!pper, Snagrot, Uzgrot, Lithrel

### Libraries & Engines
- **NeL Framework:** Nevrax / Ryzom Core team
- **ODE Physics:** Russell Smith and contributors
- **Lua:** PUC-Rio team

### Community Restoration (2025)
- Server compilation and modern compatibility fixes
- TypeScript login service implementation
- Documentation and build guides

---

## Contact & Community

- **Issues:** Use GitHub [Issues](../../issues) for bugs and questions
- **Discussions:** GitHub [Discussions](../../discussions) for ideas and help
- **Original Site:** www.mtp-target.org (offline, domain expired/repurposed)

---

## Star This Repository

If you're interested in this project or want to see it succeed, please give it a star! It helps others discover this game restoration effort.

---

**Let's bring this fun penguin game back to life! 🐧🎯**
