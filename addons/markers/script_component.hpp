#define COMPONENT markers
#define COMPONENT_BEAUTIFIED Markers
#include "\z\maptac\addons\main\script_mod.hpp"

// #define DEBUG_MODE_FULL
// #define DISABLE_COMPILE_CACHE
// #define ENABLE_PERFORMANCE_COUNTERS

#ifdef DEBUG_ENABLED_MARKERS
    #define DEBUG_MODE_FULL
#endif

#ifdef DEBUG_SETTINGS_MARKERS
    #define DEBUG_SETTINGS DEBUG_SETTINGS_MARKERS
#endif

#include "\z\maptac\addons\main\script_macros.hpp"

#define IDC_INSERTMARKER_CHANNEL 1010
#define IDC_INSERTMARKER_TEXT 1011
#define IDC_INSERTMARKER_TEXT_PLACEHOLDER 1014
#define IDC_INSERTMARKER_COLORS 1015
#define IDC_INSERTMARKER_COLOR_FRAME 1016
#define IDC_INSERTMARKER_VEHICLE 1017

#define IDC_TRANSFER_TITLE 1101
#define IDC_TRANSFER_HINT 1102
#define IDC_TRANSFER_TEXT 1103
#define IDC_TRANSFER_STATUS 1104
#define IDC_TRANSFER_CHANNEL 1105
// Copied markers text: [[type, color, text, position, line points], ...]
#define MAX_TRANSFER_MARKERS 200
#define MAX_TRANSFER_TEXT_LENGTH 200000
// Distance from the marker point to the dialog controls, in GUI grid units
#define INSERTMARKER_LEFT 2.3

#define MARKER_NAME_PREFIX "MapTac:"
#define MAX_MARKER_TEXT_LENGTH 100
// Channels whose markers are sent to the joined players who did not receive them: global, side, command, group
#define RESTORED_CHANNELS [0, 1, 2, 3]
// Mouse movement (in screen units) after which pressed LMB on a marker starts dragging it
#define DRAG_THRESHOLD 0.005
// Area around the marker point where it can be grabbed, in marker icon sizes (CfgMarkers size)
#define MARKER_GRAB_RADIUS 0.6

#define MAX_QUICK_MARKERS 10

// Marker label parts, shown by the map buttons and while their keys are held
#define LABEL_PART_AUTHOR 0
#define LABEL_PART_GROUP 1
#define LABEL_PART_TEXT 2
// Suffixes of the label part settings, index is the part
#define LABEL_PART_NAMES ["Author", "Group", "Text"]
#define LABEL_PART_DEFAULTS [false, true, true]
// Text color of the map button of the hidden label part
#define LABEL_BUTTON_OFF_COLOR [1, 1, 1, 0.4]
// Distance between the label buttons, in button widths
#define LABEL_BUTTON_STEP 1.05
// Text color of the delete item of the marker menu
#define MENU_DELETE_COLOR [1, 0.45, 0.4, 1]

// Map tools: the click this close to the last route point (in screen units) finishes the route,
// the vanilla marker dialog opened by the finishing double click is closed this long after (in seconds)
#define MAP_TOOL_FINISH_DISTANCE 0.01
#define MAP_TOOL_DOUBLE_CLICK_TIME 0.5
// RscMapControl sizeExInfo, the vanilla cursor info text, see RscMapToolLabel
#define MAP_TOOL_TEXT_SIZE (((safeZoneW / safeZoneH) min 1.2) / 1.2 / 25 * 0.8)
// Right edge of the cursor labels left of the cursor, in pixels, mirrors the vanilla cursor info
#define MAP_TOOL_CURSOR_LABEL_OFFSET 17
// Points of the route marker
#define MAX_POLYLINE_POINTS 100
// The route point snaps to the roads this close to the cursor, in pixels
#define ROAD_SNAP_PIXELS 40
// Units of the ruler distances, the setting
#define DISTANCE_UNIT_DYNAMIC 0
#define DISTANCE_UNIT_METERS 1
#define DISTANCE_UNIT_KILOMETERS 2
// Ruler line from the start to the cursor
#define RULER_MAIN_LINE_COLOR [0, 0, 0, 1]
// Vanilla map cursor color (ticks and texts), measured from a screenshot: (178, 26, 0)
#define RULER_LINE_COLOR [0.7, 0.1, 0, 1]
#define RULER_TEXT_COLOR [0.7, 0.1, 0, 1]
// Ruler ticks from the largest: [step in meters, length in pixels]
#define RULER_TICKS [[1000, 16], [100, 10], [10, 5]]
// Minimal distance between the ticks and between the labels, in pixels
#define RULER_MIN_TICK_SPACING 6
#define RULER_MIN_LABEL_SPACING 60
// Distance of the labels from the ruler, in pixels
#define RULER_LABEL_OFFSET 18
// Arrow head of the direction: length in the arrow lengths, angle from the arrow line in degrees
#define ARROW_HEAD_SIZE 0.15
#define ARROW_HEAD_ANGLE 25

// Group callsign formats ("Alpha 1-1", "A1-1", "A1/1", "A11")
#define CALLSIGN_FULL 0
#define CALLSIGN_DASH 1
#define CALLSIGN_SLASH 2
#define CALLSIGN_COMPACT 3

// Vertical padding of the marker tooltip in pixels
#define TOOLTIP_PADDING 8
#define QUICK_MARKER_ALPHA 0.75
// Quick selection rings geometry, in icon widths
#define RING_INNER_RADIUS 0.8
#define RING_GAP 0.75
#define RING_ICON_SPACING 0.8
// Distance of the end icons from the ring ends
#define RING_END_MARGIN 0.25
// Background of the rings, drawn on the map: neutral, so all the marker colors (white and black too) are readable
#define RING_CATEGORY_BACKGROUND_COLOR [0.42, 0.44, 0.47, 0.85]
#define RING_BACKGROUND_COLOR [0.55, 0.57, 0.6, 0.8]
#define RING_OUTLINE_COLOR [0.1, 0.1, 0.1, 0.6]
// Segments of the ring background arc
#define RING_SEGMENTS 32
#define SIDE_PREFIXES ["b_", "o_", "n_"]

// Channel IDs of the channel types added by compat addons start here, lower ones are engine channels
#define EXTRA_CHANNEL_MIN 100

// Suffixes of the channel settings, index is the channel ID
#define CHANNEL_SETTING_NAMES ["Global", "Side", "Command", "Group", "Vehicle", "Direct"]
// Channel modes, the channel settings
#define CHANNEL_MODE_DISABLED 0
#define CHANNEL_MODE_ENABLED 1
#define CHANNEL_MODE_BRIEFING 2
#define CHANNEL_MODE_RADIO 3
#define CHANNEL_MODE_GPS 4
#define CHANNEL_MODE_LONG_RANGE 5
#define CHANNEL_MODE_GPS_OR_LONG_RANGE 6

#define HISTORY_CREATED 0
#define HISTORY_DELETED 1
