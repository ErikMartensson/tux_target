# Runtime Data Files (Corrected Versions)

This directory contains corrected/fixed versions of runtime data files that are automatically copied to the build directory by the post-build script.

## Purpose

These files have been modified to fix runtime crashes and issues. They are kept here so that:
1. The post-build script can automatically apply fixes
2. We track what's been changed
3. Original source files remain unmodified until permanent fixes are made

## Files

### Level Files (`level/*.lua`)
- **Count:** 71 level files from v1.5.19 source
- **Fix Applied:** ServerLua paths corrected
  - Changed: `ServerLua = "level_name_server.lua"`
  - To: `ServerLua = "data/lua/level_name_server.lua"`
- **Issue:** Server crashes on level transitions without this fix
- **Status:** Temporary fix - should be permanently fixed in Lua loading code

### Config Files (`config/mtp_target_default.cfg`)
- **Fix Applied:** Water rendering disabled
  - Changed: `DisplayWater = 2`
  - To: `DisplayWater = 0`
- **Issue:** Client crashes on level load due to missing water textures
- **Status:** Temporary fix - need to find/create water texture files

### Shape Files (`shape/sky.shape`)
- **Fix Applied:** Replaced with snow variant
  - Original: Generic city skybox
  - Fixed: Antarctic snow skybox (`sky_snow.shape`)
- **Issue:** Wrong theme (city instead of snow/penguin setting)
- **Status:** Permanent fix - correct file for the game

## Usage

These files are automatically copied by the post-build script:
```bash
./scripts/post_build.sh      # Linux/Git Bash
scripts\post_build.bat        # Windows CMD
```

## Future Work

### Level Files
- [ ] Fix Lua loading code to handle both absolute and relative paths
- [ ] Update all level files in original source repository
- [ ] Test that fixed loader works with both old and new path formats

### Config Files
- [ ] Find or create missing water texture files:
  - `water_env.tga` (environment map)
  - `water_disp.tga` (displacement map)
  - `water_disp2.tga` (secondary displacement)
- [ ] Re-enable water rendering once textures are available
- [ ] Test water rendering performance

### Shape Files
- ✅ No further work needed - correct file already in place

## See Also

- [docs/RUNTIME_FIXES.md](../docs/RUNTIME_FIXES.md) - Complete documentation of all runtime fixes
- [scripts/post_build.sh](../scripts/post_build.sh) - Automated file copy script
