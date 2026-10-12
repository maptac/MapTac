#include "..\script_component.hpp"
/*
 * Author: Smith
 * Returns RGBA of the marker color
 *
 * Arguments:
 * 0: Marker color (CfgMarkerColors class) <STRING>
 *
 * Return Value:
 * Color (RGBA) <ARRAY>
 *
 * Example:
 * ["ColorWEST"] call maptac_markers_fnc_getMarkerColor
 *
 * Public: No
 */

params ["_colorClass"];

// Colors may contain expressions (e.g. side colors from the profile)
private _color = getArray (configFile >> "CfgMarkerColors" >> _colorClass >> "color") apply {
    if (_x isEqualType "") then {call compile _x} else {_x}
};

if (count _color != 4) exitWith {[1, 1, 1, 1]};

_color
