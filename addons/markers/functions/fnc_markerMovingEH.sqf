#include "..\script_component.hpp"
/*
 * Author: Smith
 * Handles a marker move request, sends the updated marker to the players who currently are in its channel
 * (including those who did not have the marker yet). Only the creator can move the marker.
 * The same position sends the marker again (see fnc_moveMarker).
 * Must be executed on server-side only
 *
 * Arguments:
 * 0: Marker name <STRING>
 * 1: New position 2D <ARRAY>
 * 2: Player who moves the marker <OBJECT>
 *
 * Return Value:
 * None
 *
 * Example:
 * ["MapTac:...", [1000, 1000], player] call maptac_markers_fnc_markerMovingEH
 *
 * Public: No
 */

params [["_name", "", [""]], ["_pos", [], [[]]], ["_editor", objNull, [objNull]]];

if !(_pos isEqualTypeParams [0, 0]) exitWith {
    WARNING_2("Marker %1: invalid position from %2",_name,_editor);
};

private _data = GVAR(markers) get _name;
if (isNil "_data") exitWith {
    // Marker was already deleted, remove the outdated copy of the editor
    [QGVAR(markerDeleted), [_name], [_editor] select {!isNull _x}] call CBA_fnc_targetEvent;
};

if (([_editor] call FUNC(getUnitKey)) != _data getOrDefault ["creatorKey", ""]) exitWith {
    WARNING_2("%1 tried to move marker %2 they did not create",_editor,_name);
    // Revert the position moved locally by the editor
    [QGVAR(markerUpdated), [_name, _data], [_editor] select {!isNull _x}] call CBA_fnc_targetEvent;
};

// The same position only sends the marker again (e.g. to who joined the channel later), it is not a modification
if (_pos isNotEqualTo ((_data get "pos") select [0, 2])) then {
    _data set ["pos", _pos];
    _data set ["modificationDate", date];
};

private _receivers = [_data, _editor] call FUNC(resolveMarkerReceivers);
TRACE_3("Marker moved",_name,_pos,_receivers);

[_name, _data, _receivers] call FUNC(sendMarker);

[QGVAR(markerMovedServer), [_name, _data, _editor]] call CBA_fnc_localEvent;

nil
