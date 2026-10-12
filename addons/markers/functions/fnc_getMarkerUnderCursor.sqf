#include "..\script_component.hpp"
/*
 * Author: Smith
 * Returns the MapTac marker under the mouse cursor on the map
 *
 * Arguments:
 * 0: Map control <CONTROL>
 *
 * Return Value:
 * Marker name, empty if there is no MapTac marker under the cursor <STRING>
 *
 * Example:
 * _marker = [findDisplay 12 displayCtrl 51] call maptac_markers_fnc_getMarkerUnderCursor
 *
 * Public: No
 */

params ["_mapCtrl"];

(ctrlMapMouseOver _mapCtrl) params [["_type", ""], ["_name", ""]];

if (_type != "marker" || {_name select [0, count MARKER_NAME_PREFIX] != MARKER_NAME_PREFIX}) exitWith {""};

_name
