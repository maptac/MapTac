#define COMPONENT common
#define COMPONENT_BEAUTIFIED Common
#include "\z\maptac\addons\main\script_mod.hpp"

// #define DEBUG_MODE_FULL
// #define DISABLE_COMPILE_CACHE
// #define ENABLE_PERFORMANCE_COUNTERS

#ifdef DEBUG_ENABLED_COMMON
    #define DEBUG_MODE_FULL
#endif

#ifdef DEBUG_SETTINGS_COMMON
    #define DEBUG_SETTINGS DEBUG_SETTINGS_COMMON
#endif

#include "\z\maptac\addons\main\script_macros.hpp"

// getSlotItemName slots
#define SLOT_RADIO 611
#define SLOT_GPS 612
