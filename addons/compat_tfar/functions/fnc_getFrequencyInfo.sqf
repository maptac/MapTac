#include "..\script_component.hpp"
/*
 * Author: Smith
 * Returns the name and the color of the frequency channel.
 * The name is the frequency with the local radios it is listened on (e.g. "100.4 - AN/PRC-152",
 * "45.3 - RT-1523G (ASIP) (add. channel)", the vehicle name for the vehicle radios). The frequency goes first,
 * so long radio names don't hide it. The encryption code is added to the frequency when it is not the code of
 * the player side (also no encryption), so the same frequencies with different codes can be told apart:
 * TFAR radios hear each other only with the same code.
 * The color depends on the radio (SW, LR, vehicle), darker for the additional channels,
 * gray when the frequency is not listened anymore.
 *
 * Arguments:
 * 0: Channel data <ARRAY>
 *   0: Frequency <STRING>
 *   1: Encryption code <STRING>
 * 1: Detailed, for the marker tooltip: the frequency with its unit <BOOL> (default: false)
 *
 * Return Value:
 * 0: Localized name <STRING>
 * 1: Color (RGBA) <ARRAY>
 *
 * Example:
 * [["100.0", "_bluefor"]] call maptac_compat_tfar_fnc_getFrequencyInfo
 *
 * Public: No
 */

params ["_channelData", ["_detailed", false]];
_channelData params [["_frequency", "", [""]], ["_code", "", [""]]];

// Not listened anymore (retuned) or not checked yet: the frequency only
private _radios = GVAR(frequencyRadios) getOrDefault [_channelData, []];

private _radioNames = [];
{
    _radioNames pushBackUnique (_x select 0);
} forEach _radios;

private _additional = false;
private _color = FREQUENCY_COLOR;
if (_radios isNotEqualTo []) then {
    // The radio where it is the active channel, SW radios first
    private _mainIndex = _radios findIf {!(_x select 2)};
    (_radios select (_mainIndex max 0)) params ["", "_radioType"];
    _color = +(RADIO_COLORS select _radioType);

    // Additional channel on all the radios
    if (_mainIndex == -1) then {
        _additional = true;
        for "_i" from 0 to 2 do {
            _color set [_i, (_color select _i) * ADDITIONAL_CHANNEL_BRIGHTNESS];
        };
    };
};

// Default codes of the sides, independent is tf_guer_radio_code in 0.9.x and tf_independent_radio_code in 1.x
private _sideCodes = [
    [west, missionNamespace getVariable ["tf_west_radio_code", ""], LLSTRING(CodeWest)],
    [east, missionNamespace getVariable ["tf_east_radio_code", ""], LLSTRING(CodeEast)],
    [resistance, missionNamespace getVariable ["tf_independent_radio_code", missionNamespace getVariable ["tf_guer_radio_code", ""]], LLSTRING(CodeIndependent)]
];

private _playerSide = side group (call CBA_fnc_currentUnit);
private _ownCode = ((_sideCodes select {(_x select 0) == _playerSide}) param [0, [sideUnknown, ""]]) select 1;

// TFAR frequencies are in MHz
private _frequencyText = [_frequency, format [LLSTRING(FrequencyMHz), _frequency]] select _detailed;

// Codes can be disabled in 1.x, then all the codes are empty
if (_code != _ownCode && {!(missionNamespace getVariable ["TFAR_radioCodesDisabled", false])}) then {
    private _codeName = ((_sideCodes select {(_x select 1) == _code}) param [0, []]) param [2, ""];
    if (_codeName == "") then {
        _codeName = if (_code == "") then {
            LLSTRING(CodeNone)
        } else {
            // Custom code of the mission
            [_code, "_"] call CBA_fnc_leftTrim
        };
    };
    _frequencyText = format [LLSTRING(ChannelNotes), _frequencyText, _codeName];
};

// "Frequency - radio (add. channel)", the frequency only when it is not listened anymore
private _name = _frequencyText;
if (_radioNames isNotEqualTo []) then {
    // Radio names may contain "/" (AN/PRC-152)
    _name = format [LLSTRING(RadioChannel), _frequencyText, _radioNames joinString " + "];
    if (_additional) then {
        _name = format [LLSTRING(ChannelNotes), _name, LLSTRING(AdditionalChannel)];
    };
};

[_name, _color]
