// Lua 5.0 to 5.x compatibility layer
#ifndef LUA_COMPAT_H
#define LUA_COMPAT_H

// LUA_GLOBALSINDEX was removed in Lua 5.2, use LUA_RIDX_GLOBALS
#ifndef LUA_GLOBALSINDEX
#define LUA_GLOBALSINDEX LUA_RIDX_GLOBALS
#endif

// lua_dostring was replaced with luaL_dostring
#ifndef lua_dostring
#define lua_dostring(L, s) luaL_dostring(L, s)
#endif

// lua_ref/lua_unref were removed - use luaL_ref/luaL_unref with LUA_REGISTRYINDEX
#ifndef lua_ref
#define lua_ref(L, lock) luaL_ref(L, LUA_REGISTRYINDEX)
#endif

#ifndef lua_unref
#define lua_unref(L, ref) luaL_unref(L, LUA_REGISTRYINDEX, ref)
#endif

#ifndef lua_getref
#define lua_getref(L, ref) lua_rawgeti(L, LUA_REGISTRYINDEX, ref)
#endif

// luaL_typerror was removed in Lua 5.2
#ifndef luaL_typerror
#define luaL_typerror(L, narg, tname) \
	luaL_error(L, "bad argument #%d (%s expected, got %s)", \
	           narg, tname, luaL_typename(L, narg))
#endif

#endif // LUA_COMPAT_H
