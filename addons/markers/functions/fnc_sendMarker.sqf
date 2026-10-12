#include "..\script_component.hpp"
/*
 * Author: Smith
 * Sends the marker data to the players, they create or update the marker locally.
 * Must be executed on server-side only
 *
 * Arguments:
 * 0: Marker name <STRING>
 * 1: Marker data <HASHMAP>
 * 2: Players <ARRAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * ["marker_1", createHashMap, allPlayers] call maptac_markers_fnc_sendMarker
 *
 * Public: No
 */

params ["_name", "_data", "_players"];

// Every unit that has received the marker may delete it, by unit key to survive respawn
private _holders = GVAR(markerHolders) getOrDefault [_name, []];
{
    _holders pushBackUnique ([_x] call FUNC(getUnitKey));
} forEach _players;
GVAR(markerHolders) set [_name, _holders];

[QGVAR(markerUpdated), [_name, _data], _players] call CBA_fnc_targetEvent;
