#include "..\script_component.hpp"
/*
 * Author: Smith
 * Returns the text shown next to the marker on the map: the label parts (author, squad, text) switched on
 * by the map buttons or held keys
 *
 * Arguments:
 * 0: Marker data <HASHMAP>
 *
 * Return Value:
 * Label <STRING>
 *
 * Example:
 * [_data] call maptac_markers_fnc_getMarkerLabel
 *
 * Public: No
 */

params ["_data"];

private _fnc_isShown = {
    (GVAR(labelShown) select _this) || {GVAR(labelHeld) select _this}
};

private _author = "";
if (LABEL_PART_AUTHOR call _fnc_isShown) then {
    _author = _data getOrDefault ["creatorName", ""];
};

private _group = "";
if (LABEL_PART_GROUP call _fnc_isShown) then {
    _group = [_data getOrDefault ["creatorGroup", ""]] call FUNC(formatCallsign);
};

private _text = "";
if (LABEL_PART_TEXT call _fnc_isShown) then {
    _text = _data getOrDefault ["text", ""];
};

// "A1-1 Smith: text"
private _who = ([_group, _author] select {_x != ""}) joinString " ";

([_who, _text] select {_x != ""}) joinString ": "
