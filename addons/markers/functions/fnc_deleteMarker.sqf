#include "..\script_component.hpp"
/*
 * Author: Smith
 * Deletes the MapTac marker on behalf of the local player.
 * The marker is deleted for everyone who currently is in its channel.
 *
 * Arguments:
 * 0: Marker name <STRING>
 *
 * Return Value:
 * None
 *
 * Example:
 * ["MapTac:..."] call maptac_markers_fnc_deleteMarker
 *
 * Public: Yes
 */

params [["_name", "", [""]]];

[QGVAR(markerDeleting), [_name, call CBA_fnc_currentUnit]] call CBA_fnc_serverEvent;

nil
