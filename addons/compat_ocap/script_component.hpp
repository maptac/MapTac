#define COMPONENT compat_ocap
#define COMPONENT_BEAUTIFIED OCAP Compatibility
#include "\z\maptac\addons\main\script_mod.hpp"

// #define DEBUG_MODE_FULL
// #define DISABLE_COMPILE_CACHE
// #define ENABLE_PERFORMANCE_COUNTERS

#ifdef DEBUG_ENABLED_COMPAT_OCAP
    #define DEBUG_MODE_FULL
#endif

#ifdef DEBUG_SETTINGS_COMPAT_OCAP
    #define DEBUG_SETTINGS DEBUG_SETTINGS_COMPAT_OCAP
#endif

#include "\z\maptac\addons\main\script_macros.hpp"

// Local marker names excluded from the OCAP client recording, see maptac_markers MARKER_NAME_PREFIX
#define LOCAL_MARKER_NAMES ["MapTac:", QEGVAR(markers,preview)]
// OCAP marker API: CBA server event, recorded markers are sent to it
#define OCAP_MARKER_EVENT "ocap_handleMarker"
// How often the OCAP recording state is checked, in seconds
#define RECORDING_CHECK_INTERVAL 2
