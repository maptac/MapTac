#include "..\script_component.hpp"
/*
 * Author: Smith
 * Places a marker (an icon or a line) on the given channel on behalf of the unit the local player acts as
 * (own or remote controlled by Zeus).
 * The server resolves the channel receivers and sends the marker to them.
 *
 * Arguments:
 * 0: Channel ID <NUMBER>
 * 1: Position <ARRAY>
 * 2: Type (CfgMarkers class) <STRING> (default: "hd_dot")
 * 3: Text <STRING> (default: "")
 * 4: Color (CfgMarkerColors class) <STRING> (default: "Default")
 * 5: Channel data, for the channel types added by compat addons <ARRAY> (default: [])
 * 6: Line points [x1, y1, x2, y2, ...], places a line marker (route, direction) instead of the icon <ARRAY> (default: [])
 * 7: Send the request now, otherwise it is returned for a batch (markersCreating event) <BOOL> (default: true)
 *
 * Return Value:
 * Marker name, or [marker name, request] when not sent <STRING or ARRAY>
 *
 * Example:
 * [3, getPosATL player, "b_inf", "Squad 1", "ColorWEST"] call maptac_markers_fnc_placeMarker
 *
 * Public: Yes
 */

params [
    ["_channel", 0, [0]],
    ["_pos", [0, 0], [[]], [2, 3]],
    ["_type", "hd_dot", [""]],
    ["_text", "", [""]],
    ["_color", "Default", [""]],
    ["_channelData", [], [[]]],
    ["_polyline", [], [[]]],
    ["_send", true, [true]]
];

private _name = MARKER_NAME_PREFIX + (call CBA_fnc_createUUID);
// The server validates the request and builds the marker data, see fnc_markerCreatingEH
private _request = createHashMapFromArray [
    // Own unit or remote controlled by Zeus
    ["creator", call CBA_fnc_currentUnit],
    ["channel", _channel],
    ["channelData", _channelData],
    ["pos", _pos select [0, 2]],
    ["type", _type],
    ["text", _text],
    ["color", _color],
    ["polyline", _polyline]
];
TRACE_2("Placing marker",_name,_request);

if (!_send) exitWith {[_name, _request]};

[QGVAR(markerCreating), [_name, _request]] call CBA_fnc_serverEvent;

_name
