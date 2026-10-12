#include "..\script_component.hpp"
#include "\a3\ui_f\hpp\defineResincl.inc"
/*
 * Author: Smith
 * Opens the window for copying or pasting the markers.
 * Copying shows the text of all visible MapTac markers, selected for Ctrl+C: the scripted clipboard
 * is not available to the clients in multiplayer, the edit controls have it.
 * Pasting takes the pasted text (Ctrl+V) and places the markers at their positions in the chosen channel,
 * the local player is their author.
 *
 * Arguments:
 * 0: Map control <CONTROL>
 * 1: Pasting, otherwise copying <BOOL>
 *
 * Return Value:
 * Window <DISPLAY>
 *
 * Example:
 * [_mapCtrl, true] call maptac_markers_fnc_openMarkersTransfer
 *
 * Public: No
 */

params ["_mapCtrl", "_paste"];

private _display = ctrlParent _mapCtrl createDisplay QGVAR(RscMarkersTransfer);
if (isNull _display) exitWith {displayNull};

// Hides the marker tooltip while open
uiNamespace setVariable [QGVAR(mapDialog), _display];
[_mapCtrl] call FUNC(updateMarkerTooltip);

private _ctrlText = _display displayCtrl IDC_TRANSFER_TEXT;
private _ctrlStatus = _display displayCtrl IDC_TRANSFER_STATUS;
private _ctrlChannel = _display displayCtrl IDC_TRANSFER_CHANNEL;

if (!_paste) exitWith {
    (_display displayCtrl IDC_TRANSFER_TITLE) ctrlSetText LLSTRING(TransferCopyTitle);
    (_display displayCtrl IDC_TRANSFER_HINT) ctrlSetStructuredText parseText LLSTRING(TransferCopyHint);
    {
        _x ctrlShow false;
    } forEach [_ctrlStatus, _ctrlChannel, _display displayCtrl IDC_OK];
    (_display displayCtrl IDC_CANCEL) ctrlSetText LLSTRING(TransferClose);

    // Visible markers, rounded to meters
    private _markers = [];
    {
        if !(GVAR(channelAccess) getOrDefault [_y get "channel", true]) then {continue};
        (_y get "pos") params ["_posX", "_posY"];
        _markers pushBack [
            _y get "type",
            _y get "color",
            _y getOrDefault ["text", ""],
            [round _posX, round _posY],
            (_y getOrDefault ["polyline", []]) apply {round _x}
        ];
    } forEach GVAR(localMarkers);

    private _text = str _markers;
    _ctrlText ctrlSetText _text;
    ctrlSetFocus _ctrlText;
    _ctrlText ctrlSetTextSelection [0, count _text];

    _display
};

(_display displayCtrl IDC_TRANSFER_TITLE) ctrlSetText LLSTRING(TransferPasteTitle);
(_display displayCtrl IDC_TRANSFER_HINT) ctrlSetStructuredText parseText LLSTRING(TransferPasteHint);

// Channels, the channel of the last placed marker preselected
private _channels = call FUNC(getAvailableChannels);
_display setVariable [QGVAR(channels), _channels];
{
    _x params ["", "_name", "_color"];
    private _index = _ctrlChannel lbAdd _name;
    _ctrlChannel lbSetValue [_index, _forEachIndex];
    _ctrlChannel lbSetColor [_index, _color];
    _ctrlChannel lbSetSelectColor [_index, _color];
} forEach _channels;
private _channelIndex = _channels findIf {[_x select 0, _x select 3] isEqualTo (GVAR(lastMarker) select [0, 2])};
_ctrlChannel lbSetCurSel (_channelIndex max 0);

// The markers count or the error, the paste button only with the markers
private _fnc_update = {
    params ["_ctrlText"];
    private _display = ctrlParent _ctrlText;
    ([ctrlText _ctrlText] call FUNC(parseMarkers)) params ["_markers", "_error"];
    _display setVariable [QGVAR(markers), _markers];
    (_display displayCtrl IDC_TRANSFER_STATUS) ctrlSetText ([format [LLSTRING(TransferCount), count _markers], _error] select (_error != ""));
    (_display displayCtrl IDC_OK) ctrlEnable (_markers isNotEqualTo [] && {_display getVariable [QGVAR(channels), []] isNotEqualTo []});
};
_ctrlText ctrlAddEventHandler ["KeyUp", _fnc_update];
[_ctrlText] call _fnc_update;
ctrlSetFocus _ctrlText;

_display displayAddEventHandler ["Unload", {
    params ["_display", "_exitCode"];
    if (_exitCode != IDC_OK) exitWith {};

    private _ctrlChannel = _display displayCtrl IDC_TRANSFER_CHANNEL;
    private _channelIndex = lbCurSel _ctrlChannel;
    if (_channelIndex == -1) exitWith {};
    ((_display getVariable QGVAR(channels)) select (_ctrlChannel lbValue _channelIndex)) params ["_channel", "", "", "_channelData"];

    // One event for all the markers
    private _requests = (_display getVariable [QGVAR(markers), []]) apply {
        _x params ["_type", "_color", "_text", "_pos", "_polyline"];
        [_channel, _pos, _type, _text, _color, _channelData, _polyline, false] call FUNC(placeMarker)
    };
    [QGVAR(markersCreating), [_requests]] call CBA_fnc_serverEvent;
}];

_display
