#include "..\script_component.hpp"
/*
 * Author: Smith
 * Returns the full localized name of the marker type.
 * Uses the MapTac names (side markers without the side prefix), falls back to the vanilla name.
 *
 * Arguments:
 * 0: Marker type (CfgMarkers class) <STRING>
 *
 * Return Value:
 * Name <STRING>
 *
 * Example:
 * ["o_motor_inf"] call maptac_markers_fnc_getMarkerName
 *
 * Public: No
 */

params ["_type"];

private _names = configFile >> QGVAR(MarkerNames);

private _name = getText (_names >> _type);
if (_name == "" && {(_type select [0, 2]) in SIDE_PREFIXES}) then {
    _name = getText (_names >> (_type select [2]));
};
if (_name == "") then {
    _name = getText (configFile >> "CfgMarkers" >> _type >> "name");
};

_name
