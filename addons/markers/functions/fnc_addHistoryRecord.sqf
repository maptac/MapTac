#include "..\script_component.hpp"
/*
 * Author: Smith
 * Writes the marker change seen by the local player into the marker history tab of the briefing
 *
 * Arguments:
 * 0: Action, one of HISTORY_* <NUMBER>
 * 1: Unique name <STRING>
 * 2: Marker data <HASHMAP>
 * 3: In-game date of deletion <ARRAY> (default: date)
 * 4: Name of the player who deleted the marker <STRING> (default: "")
 * 5: Group callsign of the player who deleted the marker <STRING> (default: "")
 *
 * Return Value:
 * None
 *
 * Example:
 * [0, "MapTac:...", _data] call maptac_markers_fnc_addHistoryRecord
 *
 * Public: No
 */

params ["_action", "_name", "_data", ["_date", date], ["_editorName", ""], ["_editorGroup", ""]];

if (!hasInterface) exitWith {};

private _fnc_escape = {
    [_this] call EFUNC(common,escapeStructuredText)
};
private _fnc_player = {
    params ["_playerName", "_groupCallsign"];
    private _group = [_groupCallsign] call FUNC(formatCallsign);
    ([_playerName, format ["%1 (%2)", _playerName, _group]] select (_group != "")) call _fnc_escape
};

private _creationDate = _data getOrDefault ["creationDate", date];
private _modificationDate = _data getOrDefault ["modificationDate", []];
private _actionDate = [_creationDate, _date] select _action;
private _actionName = localize ([LSTRING(HistoryCreated), LSTRING(HistoryDeleted)] select _action);

private _typeName = [_data get "type"] call FUNC(getMarkerName);
private _text = _data getOrDefault ["text", ""];

private _title = format ["%1 %2: %3", [_actionDate] call FUNC(formatMarkerDate), _actionName, _typeName];
if (_text != "") then {
    _title = format ["%1 - %2", _title, _text];
};

([_data get "channel", _data getOrDefault ["channelData", []]] call FUNC(getChannelInfo)) params ["_channelName", "_channelColor"];
private _pos = _data get "pos";
private _grid = mapGridPosition _pos;
// The link moves the map to the marker, the deleted marker has nowhere to move
if (_action != HISTORY_DELETED) then {
    _grid = format ["<marker name='%1'>%2</marker>", _name, _grid];
};

private _lines = [
    format ["<font face='RobotoCondensedBold'>%1</font>", _actionName],
    format ["%1: %2", LLSTRING(HistoryMarker), _typeName call _fnc_escape]
];
if (_text != "") then {
    _lines pushBack format ["%1: %2", LLSTRING(HistoryText), _text call _fnc_escape];
};
_lines append [
    format ["%1: %2", LLSTRING(HistoryColor), getText (configFile >> "CfgMarkerColors" >> _data getOrDefault ["color", "Default"] >> "name") call _fnc_escape],
    format ["%1: %2", LLSTRING(TooltipPlacedBy), [_data getOrDefault ["creatorName", ""], _data getOrDefault ["creatorGroup", ""]] call _fnc_player],
    format ["%1: <font color='%2'>%3</font>", LLSTRING(TooltipChannel), (_channelColor select [0, 3]) call BIS_fnc_colorRGBtoHTML, _channelName call _fnc_escape],
    format ["%1: %2", LLSTRING(HistoryPosition), _grid],
    format ["%1: %2", LLSTRING(TooltipCreated), [_creationDate] call FUNC(formatMarkerDate)]
];
if (_modificationDate isNotEqualTo []) then {
    _lines pushBack format ["%1: %2", LLSTRING(TooltipModified), [_modificationDate] call FUNC(formatMarkerDate)];
};
if (_action == HISTORY_DELETED) then {
    _lines pushBack format ["%1: %2", LLSTRING(HistoryDeletedAt), [_date] call FUNC(formatMarkerDate)];
    if (_editorName != "") then {
        _lines pushBack format ["%1: %2", LLSTRING(HistoryDeletedBy), [_editorName, _editorGroup] call _fnc_player];
    };
};

private _record = [_title, _lines joinString "<br/>"];
GVAR(history) pushBack _record;

// Creates the tab with all records including this one, if it doesn't exist yet
if (isNull player || {!(player diarySubjectExists QGVAR(history))}) exitWith {
    call FUNC(initHistory);
};

player createDiaryRecord [QGVAR(history), _record];

nil
