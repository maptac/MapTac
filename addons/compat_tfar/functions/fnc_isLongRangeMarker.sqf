#include "..\script_component.hpp"
/*
 * Author: Smith
 * Checks whether the frequency marker was placed on a long-range radio (backpack or vehicle) of its creator.
 * Computed at the first call, by the frequencies the creator reported then, and kept: it is called
 * at the marker creation, the creator may retune later.
 * Must be executed on server-side only
 *
 * Arguments:
 * 0: Marker name <STRING>
 * 1: Marker data <HASHMAP>
 *
 * Return Value:
 * Placed on a long-range radio <BOOL>
 *
 * Example:
 * [_name, _data] call maptac_compat_tfar_fnc_isLongRangeMarker
 *
 * Public: No
 */

params ["_name", "_data"];

private _longRange = GVAR(longRangeMarkers) get _name;
if (!isNil "_longRange") exitWith {_longRange};

private _creator = _data getOrDefault ["creator", objNull];
private _index = (_creator getVariable [QGVAR(frequencies), []]) find (_data get "channelData");
_longRange = _index != -1 && {(_creator getVariable [QGVAR(longRange), []]) param [_index, false]};

GVAR(longRangeMarkers) set [_name, _longRange];
_longRange
