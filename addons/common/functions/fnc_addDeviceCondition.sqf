#include "..\script_component.hpp"
/*
 * Author: Smith
 * Adds a check of the device, used by compat addons for devices of other mods.
 * The device counts when any of its conditions is true (the slot item is the first one).
 *
 * Arguments:
 * 0: Device type, "radio", "gps" or "lr" (long-range radio) <STRING>
 * 1: Condition, gets the unit as _this select 0, returns whether the unit has the device <CODE>
 *
 * Return Value:
 * Added <BOOL>
 *
 * Example:
 * ["gps", {params ["_unit"]; "MyMod_GPS" in items _unit}] call maptac_common_fnc_addDeviceCondition
 *
 * Public: Yes
 */

params [["_type", "", [""]], ["_condition", {}, [{}]]];

private _conditions = GVAR(deviceConditions) get toLowerANSI _type;
if (isNil "_conditions") exitWith {
    WARNING_1("Unknown device type %1",_type);
    false
};

_conditions pushBack _condition;

true
