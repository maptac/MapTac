#include "..\script_component.hpp"
/*
 * Author: Smith
 * Handles a marker creation request, sends the marker to the players in its channel.
 * The marker data is built by the server from the validated request fields, the client cannot set
 * the other marker properties (size, alpha etc.) or the creator details.
 * Must be executed on server-side only
 *
 * Arguments:
 * 0: Marker name <STRING>
 * 1: Request, see fnc_placeMarker <HASHMAP>
 *
 * Return Value:
 * None
 *
 * Example:
 * ["MapTac:...", _request] call maptac_markers_fnc_markerCreatingEH
 *
 * Public: No
 */

params [["_name", "", [""]], ["_request", createHashMap, [createHashMap]]];

private _creator = _request getOrDefault ["creator", objNull];
private _channel = _request getOrDefault ["channel", -1];
private _channelData = _request getOrDefault ["channelData", []];
private _pos = _request getOrDefault ["pos", []];
private _type = _request getOrDefault ["type", ""];
private _text = _request getOrDefault ["text", ""];
private _color = _request getOrDefault ["color", ""];
private _polyline = _request getOrDefault ["polyline", []];

if (
    !([_creator, _channel, _channelData, _pos, _type, _text, _color, _polyline] isEqualTypeParams [objNull, 0, [], [], "", "", "", []])
    || {!(_pos isEqualTypeParams [0, 0])}
    || {_polyline isNotEqualTo [] && {!(_polyline isEqualTypeAll 0)}}
) exitWith {
    WARNING_1("Marker %1: invalid request",_name);
};

if (isNull _creator || {_name select [0, count MARKER_NAME_PREFIX] != MARKER_NAME_PREFIX} || {_name in GVAR(markers)}) exitWith {
    WARNING_2("Marker %1: exists, bad name or creator %2 gone",_name,_creator);
};

// Lines (routes, directions) have MapTac types, icons - CfgMarkers classes
private _shape = ["ICON", "POLYLINE"] select (_polyline isNotEqualTo []);
private _validType = if (_shape == "ICON") then {
    isClass (configFile >> "CfgMarkers" >> _type)
} else {
    _type in [QGVAR(route), QGVAR(direction)] && {count _polyline >= 4} && {count _polyline <= 2 * MAX_POLYLINE_POINTS}
        && {count _polyline % 2 == 0}
};
if (!_validType || {!isClass (configFile >> "CfgMarkerColors" >> _color)}) exitWith {
    WARNING_4("Marker %1 by %2: invalid type %3 or color %4",_name,_creator,_type,_color);
};

if !([_creator, _channel, true] call FUNC(canUseChannel)) exitWith {
    WARNING_3("Marker %1 by %2: channel %3 not available",_name,_creator,_channel);
};

private _data = createHashMapFromArray [
    ["channel", _channel],
    ["channelData", _channelData],
    ["pos", _pos],
    ["type", _type],
    ["text", _text select [0, MAX_MARKER_TEXT_LENGTH]],
    ["color", _color],
    ["brush", "Solid"],
    ["dir", 0],
    ["alpha", 1],
    ["shape", _shape],
    ["size", [1, 1]],
    ["polyline", _polyline],
    // Kept, known when the creator is dead or disconnected. Unit key survives respawn.
    ["creator", _creator],
    ["creatorName", name _creator],
    ["creatorGroup", groupId group _creator],
    ["creatorKey", [_creator] call FUNC(getUnitKey)],
    // Server in-game time, same for everyone. Empty modification date - not modified.
    ["creationDate", date],
    ["modificationDate", []]
];

GVAR(markers) set [_name, _data];

private _receivers = [_data, _creator] call FUNC(resolveMarkerReceivers);
TRACE_2("Marker created",_name,_receivers);

[_name, _data, _receivers] call FUNC(sendMarker);

[QGVAR(markerCreatedServer), [_name, _data]] call CBA_fnc_localEvent;

nil
