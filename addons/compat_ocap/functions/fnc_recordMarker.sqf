#include "..\script_component.hpp"
/*
 * Author: Smith
 * Sends the MapTac marker to the OCAP recording (ocap_handleMarker event), once from the server with the
 * full marker data: the local copies of the clients are excluded from the recording.
 * The text is the label of the marker: squad, author and text. Global channel markers are seen by all sides
 * in the replay, the others by the side of the creator (the respawned unit too).
 * Must be executed on server-side only
 *
 * Arguments:
 * 0: OCAP event, "CREATED", "UPDATED" or "DELETED" <STRING>
 * 1: Marker name <STRING>
 * 2: Marker data <HASHMAP>
 * 3: Player who changes the marker <OBJECT> (default: objNull)
 * 4: Creation time for CREATED, 0 when unknown (markers placed before the recording) <NUMBER> (default: time)
 *
 * Return Value:
 * None
 *
 * Example:
 * ["CREATED", "MapTac:...", _data] call maptac_compat_ocap_fnc_recordMarker
 *
 * Public: No
 */

params ["_event", "_name", "_data", ["_editor", objNull], ["_creationTime", time]];

if (_event == "DELETED") exitWith {
    [OCAP_MARKER_EVENT, ["DELETED", _name, _editor]] call CBA_fnc_localEvent;
};

// Lines: [x1, y1, x2, y2, ...], OCAP splits them into points
private _pos = _data getOrDefault ["polyline", []];
if (_pos isEqualTo []) then {
    _pos = ATLToASL ((_data get "pos") + [0]);
};
private _shape = _data get "shape";
// Lines have MapTac types, not CfgMarkers classes
private _type = ["", _data get "type"] select (_shape == "ICON");
private _color = _data get "color";

private _group = [_data getOrDefault ["creatorGroup", ""]] call EFUNC(markers,formatCallsign);
private _author = ([_group, _data getOrDefault ["creatorName", ""]] select {_x != ""}) joinString " ";
private _text = ([_author, _data getOrDefault ["text", ""]] select {_x != ""}) joinString ": ";

if (_event == "CREATED") exitWith {
    [OCAP_MARKER_EVENT, [
        "CREATED", _name, [_data] call EFUNC(markers,getCreatorUnit), _pos, _type, _shape, _data get "size", _data get "dir",
        _data get "brush", _color, _data get "alpha", _text, (_data get "channel") == 0, _creationTime
    ]] call CBA_fnc_localEvent;
};

// Lines don't move (not dragged), OCAP doesn't split their points on updates
if (_shape != "ICON") exitWith {};

// OCAP takes the HTML color on updates, as its own handlers send it
private _colorConfig = if (_color == "Default") then {
    configFile >> "CfgMarkers" >> _type >> "color"
} else {
    configFile >> "CfgMarkerColors" >> _color >> "color"
};
private _htmlColor = (_colorConfig call BIS_fnc_colorConfigToRGBA) call BIS_fnc_colorRGBtoHTML;

[OCAP_MARKER_EVENT, [
    "UPDATED", _name, _editor, _pos, _type, _shape, _data get "size", _data get "dir", _data get "brush",
    _htmlColor, _data get "alpha", _text
]] call CBA_fnc_localEvent;
