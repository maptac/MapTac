#define COMPONENT compat_tfar
#define COMPONENT_BEAUTIFIED TFAR Compatibility
#include "\z\maptac\addons\main\script_mod.hpp"

// #define DEBUG_MODE_FULL
// #define DISABLE_COMPILE_CACHE
// #define ENABLE_PERFORMANCE_COUNTERS

#ifdef DEBUG_ENABLED_COMPAT_TFAR
    #define DEBUG_MODE_FULL
#endif

#ifdef DEBUG_SETTINGS_COMPAT_TFAR
    #define DEBUG_SETTINGS DEBUG_SETTINGS_COMPAT_TFAR
#endif

#include "\z\maptac\addons\main\script_macros.hpp"

// Marker channel type of the radio frequencies, see maptac_markers_fnc_addChannelType
#define CHANNEL_TFAR 100
// Radios the frequency is listened on
#define RADIO_SW 0
#define RADIO_LR 1
#define RADIO_VEHICLE 2
// Colors of the radios, index is RADIO_SW/LR/VEHICLE. Warm hues not used by the vanilla channels:
// orange for SW, pink for LR, lilac for the vehicle radios
#define RADIO_COLORS [[1, 0.6, 0.2, 1], [1, 0.45, 0.7, 1], [0.7, 0.55, 1, 1]]
// Color of the frequency that is not listened anymore
#define FREQUENCY_COLOR [0.6, 0.6, 0.6, 1]
// Brightness of the additional channel colors
#define ADDITIONAL_CHANNEL_BRIGHTNESS 0.7
// Replay recording of the frequency markers, the setting
#define RECORD_ALL 0
#define RECORD_LONG_RANGE_PLACED 1
#define RECORD_LONG_RANGE_BAND 2
// Long-range radios band, MHz, same in 0.9.x and 1.x (ASIP)
#define LONG_RANGE_MIN_FREQUENCY 30
#define LONG_RANGE_MAX_FREQUENCY 87
// How often the listened frequencies are checked, in seconds
#define FREQUENCIES_CHECK_INTERVAL 1
