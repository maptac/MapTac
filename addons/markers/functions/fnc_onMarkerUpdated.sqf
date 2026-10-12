#include "..\script_component.hpp"
/*
 * Author: Smith
 * Handles the marker received from the server: stores it, draws it when its channel is available
 * and writes the new marker into the history (moves are not written)
 *
 * Arguments:
 * 0: Unique name <STRING>
 * 1: Marker data <HASHMAP>
 *
 * Return Value:
 * None
 *
 * Example:
 * ["MapTac:...", _data] call maptac_markers_fnc_onMarkerUpdated
 *
 * Public: No
 */

params ["_name", "_data"];

private _isNew = !(_name in GVAR(localMarkers));

// A copy, the server data is the same hashmap in singleplayer
_data = +_data;
GVAR(localMarkers) set [_name, _data];

// Hidden while the channel is not available
if (GVAR(channelAccess) getOrDefault [_data get "channel", true]) then {
    [_name, _data] call FUNC(drawMarker);
} else {
    deleteMarkerLocal _name;
};

// Once, also when the unit is switched back (Zeus)
if (_isNew && {!(_name in GVAR(historyMarkers))}) then {
    GVAR(historyMarkers) set [_name, true];
    [HISTORY_CREATED, _name, _data] call FUNC(addHistoryRecord);
};

nil
