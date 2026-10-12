#include "..\script_component.hpp"
/*
 * Author: Smith
 * Returns the key of the unit that owns and holds the markers: the network ID of the unit.
 * Stored on the unit at the first call: the engine copies the unit variables to the respawned unit,
 * so the respawned unit keeps the key (see also XEH_postInit). Whoever plays the unit has its markers.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 *
 * Return Value:
 * Unit key, "" for null <STRING>
 *
 * Example:
 * [player] call maptac_markers_fnc_getUnitKey
 *
 * Public: No
 */

params [["_unit", objNull, [objNull]]];

if (isNull _unit) exitWith {""};

private _key = _unit getVariable QGVAR(unitKey);
if (isNil "_key") then {
    _key = _unit call BIS_fnc_netId;
    _unit setVariable [QGVAR(unitKey), _key, true];
};

_key
