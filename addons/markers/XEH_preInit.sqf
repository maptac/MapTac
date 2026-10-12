#include "script_component.hpp"

ADDON = false;

PREP_RECOMPILE_START;
#include "XEH_PREP.hpp"
PREP_RECOMPILE_END;

// Channel ID -> receivers resolver, gets [_sender, _channelData], used on the server.
// Receivers are the acting units of the players (own or remote controlled by Zeus).
// Compat addons add theirs with fnc_addChannelType.
GVAR(channelResolvers) = createHashMapFromArray [
    [0, {call FUNC(getActingUnits)}],
    [1, {units side group (_this select 0) arrayIntersect (call FUNC(getActingUnits))}],
    // Command: leaders of the side groups
    [2, {(units side group (_this select 0) arrayIntersect (call FUNC(getActingUnits))) select {_x == leader _x}}],
    [3, {units group (_this select 0) arrayIntersect (call FUNC(getActingUnits))}],
    [4, {crew objectParent (_this select 0) arrayIntersect (call FUNC(getActingUnits))}],
    // Direct: by distance, nearEntities misses the units inside vehicles
    [5, {
        params ["_sender"];
        // Briefing: everybody stands at the slots, the author only
        if (time == 0) exitWith {[]};
        (call FUNC(getActingUnits)) select {_x distance _sender <= GVAR(directChannelRange)}
    }]
];
// Channel types added by compat addons: channel ID -> [available channels function, channel info function,
// replay recording filter]
GVAR(channelTypes) = createHashMap;

// Data of the MapTac markers known to this client: name -> data
GVAR(localMarkers) = createHashMap;
// Whether the local player can see the channel markers: channel -> bool
GVAR(channelAccess) = createHashMap;
// Label parts shown by the map buttons, the defaults are set by the settings
GVAR(labelShown) = +LABEL_PART_DEFAULTS;
// Label parts shown while their keys are held
GVAR(labelHeld) = [false, false, false];
// Marker history records of the local player: [title, text]
GVAR(history) = [];
// Markers written into the history as created
GVAR(historyMarkers) = createHashMap;
// [channel ID, channel data, type, text, color] of the last marker placed with the dialog:
// its channel is preselected in the dialog, the map menu repeats it
GVAR(lastMarker) = [];

#include "initSettings.inc.sqf"

// [marker name, start mouse position, is moving]
GVAR(dragState) = [];
// Mouse position of the last right button press on the map
GVAR(rightClickPos) = [0, 0];
// UI objects (the dialog over the map, the label buttons, the map tool controls) are kept in uiNamespace,
// missionNamespace variables must be serializable.
// Active map tool (measuring, route, direction), empty when none, see fnc_startMapTool
GVAR(mapTool) = createHashMap;
GVAR(mapToolEndTime) = -1;
GVAR(snapToRoadHeld) = false;

ADDON = true;
