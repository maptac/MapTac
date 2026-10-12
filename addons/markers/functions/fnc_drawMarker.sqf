#include "..\script_component.hpp"
/*
 * Author: Smith
 * Draws the known MapTac marker on the map, recreates it if it already exists.
 * The text shown on the map depends on the label mode.
 *
 * Arguments:
 * 0: Unique name <STRING>
 * 1: Marker data <HASHMAP>
 *
 * Return Value:
 * None
 *
 * Example:
 * ["marker_1", createHashMap] call maptac_markers_fnc_drawMarker
 *
 * Public: No
 */

params ["_name", "_data"];

private _creator = _data get "creator";
private _pos = _data get "pos";
private _type = _data get "type";
private _brush = _data get "brush";
private _dir = _data get "dir";
private _color = _data get "color";
private _alpha = _data get "alpha";
private _shape = _data get "shape";
private _size = _data get "size";
private _polyline = _data get "polyline";

// Channel and creator can be set only on creation
deleteMarkerLocal _name;
// No engine channel: visibility handled by MapTac, engine removes e.g. direct channel markers in briefing
createMarkerLocal [_name, _pos, -1, _creator];
_name setMarkerTextLocal ([_data] call FUNC(getMarkerLabel));
// Lines (routes, directions) have MapTac types, not CfgMarkers classes
if (_shape == "ICON") then {
    _name setMarkerTypeLocal _type;
};
_name setMarkerBrushLocal _brush;
_name setMarkerDirLocal _dir;
_name setMarkerColorLocal _color;
_name setMarkerAlphaLocal _alpha;
_name setMarkerShapeLocal _shape;
_name setMarkerSizeLocal _size;

if (_polyline isNotEqualTo []) then {
    _name setMarkerPolylineLocal _polyline;
};

nil
