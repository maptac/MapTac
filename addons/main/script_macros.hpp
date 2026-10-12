#include "\x\cba\addons\main\script_macros_common.hpp"

#define DFUNC(var1) TRIPLES(ADDON,fnc,var1)

#ifdef DISABLE_COMPILE_CACHE
    #undef PREP
    #define PREP(fncName) DFUNC(fncName) = compile preprocessFileLineNumbers QPATHTOF(functions\DOUBLES(fnc,fncName).sqf)
#else
    #undef PREP
    #define PREP(fncName) [QPATHTOF(functions\DOUBLES(fnc,fncName).sqf), QFUNC(fncName)] call CBA_fnc_compileFunction
#endif

// Allows recompiling all functions at runtime via `call MAPTAC_PREP_RECOMPILE` (only with DISABLE_COMPILE_CACHE)
#ifdef DISABLE_COMPILE_CACHE
    #define PREP_RECOMPILE_START if (isNil "MAPTAC_PREP_RECOMPILE") then {MAPTAC_RECOMPILES = []; MAPTAC_PREP_RECOMPILE = {{call _x} forEach MAPTAC_RECOMPILES}}; private _recomp = {
    #define PREP_RECOMPILE_END }; call _recomp; MAPTAC_RECOMPILES pushBack _recomp;
#else
    #define PREP_RECOMPILE_START ; /* disabled */
    #define PREP_RECOMPILE_END ; /* disabled */
#endif

// GUI positioning relative to the screen center (40x25 grid)
#define POS_X(N) QUOTE((N) * GUI_GRID_CENTER_W + GUI_GRID_CENTER_X)
#define POS_Y(N) QUOTE((N) * GUI_GRID_CENTER_H + GUI_GRID_CENTER_Y)
#define POS_W(N) QUOTE((N) * GUI_GRID_CENTER_W)
#define POS_H(N) QUOTE((N) * GUI_GRID_CENTER_H)

#define GUI_BCG_COLOR {"(profileNamespace getVariable ['GUI_BCG_RGB_R', 0.13])", "(profileNamespace getVariable ['GUI_BCG_RGB_G', 0.54])", "(profileNamespace getVariable ['GUI_BCG_RGB_B', 0.21])", "(profileNamespace getVariable ['GUI_BCG_RGB_A', 0.8])"}
