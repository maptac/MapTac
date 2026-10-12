#include "..\script_component.hpp"
/*
 * Author: Smith
 * Formats the in-game date of a marker change: time only for today, time and date otherwise
 *
 * Arguments:
 * 0: In-game date [year, month, day, hour, minute] <ARRAY>
 *
 * Return Value:
 * Formatted date <STRING>
 *
 * Example:
 * [date] call maptac_markers_fnc_formatMarkerDate
 *
 * Public: No
 */

params ["_date"];
_date params ["_year", "_month", "_day", "_hour", "_minute"];

private _time = format ["%1:%2", [_hour, 2] call CBA_fnc_formatNumber, [_minute, 2] call CBA_fnc_formatNumber];

if ((date select [0, 3]) isEqualTo [_year, _month, _day]) exitWith {_time};

format ["%1 %2.%3.%4", _time, [_day, 2] call CBA_fnc_formatNumber, [_month, 2] call CBA_fnc_formatNumber, _year]
