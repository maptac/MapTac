#include "..\script_component.hpp"
/*
 * Author: Smith
 * Handles a marker delete request. The marker is deleted only for the players who currently are in its channel
 * (and the deleting player), like a radio transmission. The others keep their copy: the marker stays on the server
 * while somebody has it, so their copies still work and the creator can send it again.
 * Must be executed on server-side only
 *
 * Arguments:
 * 0: Marker name <STRING>
 * 1: Player who deletes the marker <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * ["MapTac:...", player] call maptac_markers_fnc_markerDeletingEH
 *
 * Public: No
 */

params ["_name", "_editor"];

private _data = GVAR(markers) get _name;
if (isNil "_data") exitWith {
    // Marker was already deleted, remove the outdated copy of the editor
    [QGVAR(markerDeleted), [_name], [_editor] select {!isNull _x}] call CBA_fnc_targetEvent;
};

if !(([_editor] call FUNC(getUnitKey)) in (GVAR(markerHolders) getOrDefault [_name, []])) exitWith {
    WARNING_2("%1 tried to delete marker %2 they do not have",_editor,_name);
};

private _receivers = [_data, _editor] call FUNC(resolveMarkerReceivers);
private _holders = (GVAR(markerHolders) getOrDefault [_name, []]) - (_receivers apply {[_x] call FUNC(getUnitKey)});
TRACE_3("Marker deleted",_name,_receivers,_holders);

[QGVAR(markerDeleted), [_name, date, name _editor, groupId group _editor], _receivers] call CBA_fnc_targetEvent;

// Kept while somebody has it
if (_holders isNotEqualTo []) exitWith {
    GVAR(markerHolders) set [_name, _holders];
};

GVAR(markers) deleteAt _name;
GVAR(markerHolders) deleteAt _name;

[QGVAR(markerDeletedServer), [_name, _data, _editor]] call CBA_fnc_localEvent;

nil
