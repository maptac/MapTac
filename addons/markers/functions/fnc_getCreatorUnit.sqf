#include "..\script_component.hpp"
/*
 * Author: Smith
 * Returns the current unit of the marker creator: the creator unit while it lives, the respawned unit with the same
 * unit key, otherwise the stored creator unit (dead or null). The channels are resolved from it (side, group).
 *
 * Arguments:
 * 0: Marker data <HASHMAP>
 *
 * Return Value:
 * Creator unit <OBJECT>
 *
 * Example:
 * [_data] call maptac_markers_fnc_getCreatorUnit
 *
 * Public: Yes
 */

params [["_data", createHashMap, [createHashMap]]];

private _creator = _data getOrDefault ["creator", objNull];
private _key = _data getOrDefault ["creatorKey", ""];

if (alive _creator) exitWith {_creator};

private _units = call FUNC(getActingUnits);
private _index = _units findIf {alive _x && {([_x] call FUNC(getUnitKey)) == _key}};
if (_index != -1) exitWith {_units select _index};

_creator
