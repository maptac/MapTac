#include "..\script_component.hpp"
/*
 * Author: Smith
 * Moves the MapTac marker on behalf of the local player.
 * The marker is updated for everyone who currently is in its channel.
 *
 * Arguments:
 * 0: Marker name <STRING>
 * 1: New position, the same position sends the marker again to everyone in its channel <ARRAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * ["MapTac:...", getPosATL player] call maptac_markers_fnc_moveMarker
 *
 * Public: Yes
 */

params [
    ["_name", "", [""]],
    ["_pos", [0, 0], [[]], [2, 3]]
];

[QGVAR(markerMoving), [_name, _pos select [0, 2], call CBA_fnc_currentUnit]] call CBA_fnc_serverEvent;

nil
