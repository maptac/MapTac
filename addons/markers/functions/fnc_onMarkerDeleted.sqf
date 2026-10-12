#include "..\script_component.hpp"
/*
 * Author: Smith
 * Handles the marker deletion received from the server: deletes it and writes the deletion into the history
 *
 * Arguments:
 * 0: Unique name <STRING>
 * 1: In-game date of deletion <ARRAY> (default: date)
 * 2: Name of the player who deleted the marker <STRING> (default: "")
 * 3: Group callsign of the player who deleted the marker <STRING> (default: "")
 *
 * Return Value:
 * None
 *
 * Example:
 * ["MapTac:...", date, "John", "Alpha 1-1"] call maptac_markers_fnc_onMarkerDeleted
 *
 * Public: No
 */

params ["_name", ["_date", date], ["_editorName", ""], ["_editorGroup", ""]];

private _data = GVAR(localMarkers) deleteAt _name;
deleteMarkerLocal _name;

if (!isNil "_data") then {
    [HISTORY_DELETED, _name, _data, _date, _editorName, _editorGroup] call FUNC(addHistoryRecord);
};

nil
