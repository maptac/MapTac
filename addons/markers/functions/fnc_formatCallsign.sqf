#include "..\script_component.hpp"
/*
 * Author: Smith
 * Formats the group callsign by the callsign format setting.
 * Short formats reduce words without digits to their first letter, the numbers are kept
 * with the chosen separator ("Alpha 1-1" -> "A1-1", "A1/1", "A11"; "Альфа 1-1" -> "А1-1").
 *
 * Arguments:
 * 0: Group callsign <STRING>
 *
 * Return Value:
 * Formatted callsign <STRING>
 *
 * Example:
 * ["Alpha 1-1"] call maptac_markers_fnc_formatCallsign
 *
 * Public: No
 */

params ["_callsign"];

if (GVAR(callsignFormat) == CALLSIGN_FULL) exitWith {_callsign};

private _separator = ["", "-", "/", ""] select GVAR(callsignFormat);

private _parts = (_callsign splitString " ") apply {
    private _chars = toArray _x;
    if (_chars findIf {_x >= 48 && _x <= 57} != -1) then { // has a digit
        (_x splitString "-/") joinString _separator
    } else {
        toUpper toString [_chars select 0]
    };
};

_parts joinString ""
