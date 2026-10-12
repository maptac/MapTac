#include "..\script_component.hpp"
/*
 * Author: Smith
 * Checks whether the unit has the device: an item in the device slot or a device added by compat addons
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Device type, "radio", "gps" (GPS and UAV terminals) or "lr" (long-range radio) <STRING>
 *
 * Return Value:
 * Has the device <BOOL>
 *
 * Example:
 * [player, "radio"] call maptac_common_fnc_hasDevice
 *
 * Public: Yes
 */

params [["_unit", objNull, [objNull]], ["_type", "", [""]]];

if (isNull _unit) exitWith {false};

(GVAR(deviceConditions) getOrDefault [toLowerANSI _type, []]) findIf {[_unit] call _x} != -1
