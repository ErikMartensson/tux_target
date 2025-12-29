# MTP Target - Level Reference

This document lists all available levels and how to select them using chat commands.

---

## Chat Commands

| Command | Description |
|---------|-------------|
| `/v <name>` | Vote for a level (shortcut) |
| `/votemap <name>` | Vote for a level |
| `/forcemap <name>` | Force next level (admin) |
| `/forceend` | End current session (admin) |
| `/help` | Show available commands |

**Notes:**
- Commands are case-insensitive
- Level matching uses **substring search** on the filename
- Use unique substrings to avoid matching multiple levels
- Vote requires enough players to agree (1/3 + 1 of human players)
- Admin commands work immediately (everyone is admin by default in local play)

---

## Level List

| Filename | Display Name | Suggested Command |
|----------|--------------|-------------------|
| level_arena | Arena | `/v arena` |
| level_classic | Snow classic | `/v level_classic` |
| level_classic_fight | Snow classic Fight | `/v fight` |
| level_classic_flat | Snow classic flat | `/v flat` |
| level_darts | Snow darts | `/v darts` |
| level_dont_go_too_far | Dont go too far | `/v too_far` |
| level_donuts | Give me the donuts | `/v donuts` |
| level_extra_ball | Extra ball | `/v extra` |
| level_hit_me | Hit me | `/v hit` |
| level_paint | Paint | `/v paint` |
| level_race | Race | `/v race` |
| level_run_away | Run Away | `/v run` |
| level_snow_dual_ramp | Snow funnel | `/v dual` |
| level_snow_fall | Snow fall | `/v fall` |
| level_snow_funnel | Snow funnel | `/v funnel` |
| level_snow_tube | Snow tube land | `/v tube` |
| level_stairs | Stairs | `/v level_stairs` |
| level_stairs2 | Stairs 2 | `/v stairs2` |
| level_team | Snow team | `/v level_team` |
| level_team_all_on_one | Team All on one | `/v all_on` |
| level_team_mirror | Snow team mirror | `/v mirror` |
| level_the_lane | The Lan | `/v lane` |
| level_the_wall | The Wall | `/v wall` |
| level_wood | Wood | `/v wood` |

---

## Ambiguous Names

Some short names match multiple levels. Use longer strings to be specific:

| Short Name | Matches |
|------------|---------|
| `classic` | level_classic, level_classic_fight, level_classic_flat |
| `team` | level_team, level_team_all_on_one, level_team_mirror |
| `stairs` | level_stairs, level_stairs2 |
| `funnel` | level_snow_funnel, level_snow_dual_ramp |

---

## Level Files

Levels are stored in `data/level/*.lua`. Each level file defines:
- `Name` - Display name shown in game
- `Author` - Level creator
- `Theme` - Visual theme (snow, city, sun, etc.)
- `ServerLua` - Server-side script for game logic
- `Modules` - 3D objects and platforms

Server scripts are in `data/lua/*_server.lua` and handle:
- Scoring logic
- Friction settings
- Special game modes

---

## Adding Custom Levels

To add a custom level:
1. Create a `.lua` file in `data/level/`
2. Define required fields (Name, Theme, Modules)
3. Optionally create a `*_server.lua` script for custom logic
4. Restart the server to load the new level
