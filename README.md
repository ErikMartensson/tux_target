# MTP Target - Community Revival

<p align="center">
  <img src="assets/site_logo.png" alt="MTP Target Logo" width="170" height="94">
</p>

> A free multiplayer online action game where you roll down a giant ramp and delicately land on platforms to score points. Fight with and against players in this mix of action, dexterity, and strategy - inspired by Monkey Target from Super Monkey Ball.

**Status:** 🚧 Work in Progress - Version 1.2.2a client and server working with 7 of 71 maps

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

### Reference Source Code

The v1.5.19 client source code is preserved in [`reference/mtp-target-v1.5.19/`](reference/mtp-target-v1.5.19/) for comparison and asset extraction. This includes shapes and textures for space/sun/city themes that are missing from v1.2.2a.

**Original download:** [Internet Archive](https://web.archive.org/web/20130630212354/http://www.mtp-target.org/files/mtp-target-src.19.tar.bz2)

---

## Current Status

### What Works ✅

- ✅ **Build System:** Full Windows build with Visual Studio 2022 and automated scripts
- ✅ **Game Server:** Compiles and runs on Windows, 7 compatible levels working
- ✅ **Game Client:** Compiles and runs on Windows with OpenGL/OpenAL drivers
- ✅ **Login Service:** Modern TypeScript/Deno implementation handles authentication
- ✅ **Database:** SQLite-based user and shard management
- ✅ **Physics:** ODE 0.16.5 engine with Lua 5.x scripting
- ✅ **Network:** Full protocol working (VLP login + game server connection)
- ✅ **Controls:** Arrow keys for steering, Ctrl for ball/glide toggle, Enter for chat
- ✅ **Scoring:** Full scoring system with targets and friction
- ⚠️ **Bots:** AI bots present but not working correctly on all maps
- ✅ **Game Assets:** All textures, shapes, sounds included in repository

### Known Issues ⚠️

See [docs/KNOWN_ISSUES.md](docs/KNOWN_ISSUES.md) for the complete issue tracker.

**High Priority:**
- ⚠️ **64 maps unavailable** - Require v1.5.19 Lua API (compatibility layer needed)
- ⚠️ **Bot AI issues** - Not working correctly on all maps

**Medium Priority:**
- ⚠️ **High ping on localhost** - 17-19ms instead of near-zero
- ⚠️ **Input delay** - Noticeable lag between steering input and penguin response

**Low Priority:**
- ⚠️ **Water rendering disabled** - Falls back gracefully when textures missing

**The game is playable!** Core mechanics work, but many maps and features still need fixes.

See [docs/RUNTIME_FIXES.md](docs/RUNTIME_FIXES.md) for detailed fix documentation.

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

# Build client and server (includes post-build file copying)
./scripts/build-client.sh   # or scripts\build-client.bat on Windows
./scripts/build-server.sh   # or scripts\build-server.bat on Windows

# Or build both at once
./scripts/build-all.sh      # or scripts\build-all.bat on Windows
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
| [**KNOWN_ISSUES.md**](docs/KNOWN_ISSUES.md) | Issue tracker with planned fixes and priorities |
| [**LEVELS.md**](docs/LEVELS.md) | Level list and chat commands for voting/forcing maps |
| [**MODIFICATIONS.md**](docs/MODIFICATIONS.md) | Source code changes for modern compatibility |
| [**PROTOCOL_NOTES.md**](docs/PROTOCOL_NOTES.md) | NeL network protocol technical reference |
| [**scripts/post-build.sh**](scripts/post-build.sh) | Automated post-build file copy script |
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

See [docs/KNOWN_ISSUES.md](docs/KNOWN_ISSUES.md) for the complete issue tracker.

### Open Issues
- **64 maps unavailable** - Require v1.5.19 Lua API compatibility layer
- **Bot AI broken** - Not deploying correctly on all maps
- **High ping on localhost** - 17-19ms instead of near-zero
- **Input delay** - Noticeable lag between steering and response
- **Darts map spawn position** - Players spawn too far back (needs testing)
- **Water rendering disabled** - Falls back gracefully when textures missing

### Fixed Issues ✅
- ✅ Build system - Full Windows compilation with automated scripts
- ✅ Client/server crashes - Major crashes resolved
- ✅ Scoring system - Players score correctly on landing platforms
- ✅ Friction system - Penguins slow down properly on target platforms
- ✅ Server level transition crashes - Lua 5.x compatibility fixes applied
- ✅ Chat commands - Vote and admin commands work with feedback
- ✅ Keyboard controls - Arrow keys work for steering, chat toggle working
- ✅ Physics steering - Entity acceleration and module override fixed
- ✅ Penguin visual size - Mesh scaling matches collision sphere
- ✅ Camera controls - Zoom persists on mouse drag
- ✅ Level loading - 7 compatible levels load correctly
- ✅ Game assets - All textures, shapes, sounds consolidated in repo
- ✅ Network protocol - Full compatibility achieved
- ✅ **Momentum loss on ramp transitions** - Fixed ODE trimesh edge collision (dContactApprox1)

See [docs/RUNTIME_FIXES.md](docs/RUNTIME_FIXES.md) for fix documentation.

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
