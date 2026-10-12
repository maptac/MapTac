#include "..\script_component.hpp"
/*
 * Author: Smith
 * Returns the frequencies the local player listens to: the active and the additional channels
 * of all SW and LR radios (backpack, vehicle) that are turned on, with the radios they are listened on.
 * The frequency is identified together with the encryption code, as TFAR does it:
 * radios on the same frequency with different codes don't hear each other.
 * SW and LR radios on the same frequency and code hear each other, so they are one channel.
 * Works with TFAR 0.9.x and 1.x, uses only the API functions present in both.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * Frequencies, SW radios first <ARRAY>
 * 0: Channel data of the frequency channel <ARRAY>
 *   0: Frequency <STRING>
 *   1: Encryption code <STRING>
 * 1: Radios, [radio name (the vehicle name for the vehicle radios), RADIO_SW/LR/VEHICLE, is additional channel,
 *    transmitting range in meters] <ARRAY>
 *
 * Example:
 * call maptac_compat_tfar_fnc_getListenedFrequencies
 *
 * Public: No
 */

// TFAR client is not initialized yet (until the mission start, in both versions TFAR_currentUnit is set by it).
// Radio settings must not be read before: TFAR creates them on the first request with the side encryption codes,
// which may be not set yet, and the radio would keep the empty code.
if (isNil "TFAR_currentUnit" || {isNil "TFAR_fnc_radiosList"} || {isNil "TFAR_fnc_lrRadiosList"}) exitWith {[]};

// Remote controlled unit (Zeus) uses its radios
private _unit = TFAR_currentUnit;
if (isNull _unit) then {
    _unit = player;
};

// 1.x only, in 0.9.x radios are always on
private _fnc_isOn = {
    isNil "TFAR_fnc_radioOn" || {[_this] call TFAR_fnc_radioOn}
};

private _frequencies = [];

private _fnc_add = {
    params [["_frequency", ""], ["_code", ""], "_radioName", "_radioType", "_additional", "_range"];

    // Broken radio settings give nil or non-string values
    if !([_frequency, _code] isEqualTypeParams ["", ""]) exitWith {};
    if (_frequency == "") exitWith {};

    private _channelData = [_frequency, _code];
    private _index = _frequencies findIf {(_x select 0) isEqualTo _channelData};
    if (_index == -1) then {
        _index = _frequencies pushBack [_channelData, []];
    };
    ((_frequencies select _index) select 1) pushBackUnique [_radioName, _radioType, _additional, _range];
};

{
    if !(_x call _fnc_isOn) then {continue};

    // Radio instance class ("AN/PRC-152 1"), the name of its base radio class
    private _config = configFile >> "CfgWeapons" >> _x;
    private _range = getNumber (_config >> "tf_range");
    private _parent = getText (_config >> "tf_parent");
    if (_parent != "") then {
        _config = configFile >> "CfgWeapons" >> _parent;
    };
    private _radioName = getText (_config >> "displayName");
    private _code = _x call TFAR_fnc_getSwRadioCode;
    [_x call TFAR_fnc_getSwFrequency, _code, _radioName, RADIO_SW, false, _range] call _fnc_add;

    private _additional = _x call TFAR_fnc_getAdditionalSwChannel;
    if (!isNil "_additional" && {_additional > -1}) then {
        [[_x, _additional + 1] call TFAR_fnc_getChannelFrequency, _code, _radioName, RADIO_SW, true, _range] call _fnc_add;
    };
} forEach (_unit call TFAR_fnc_radiosList);

{
    // [radio object (backpack or vehicle), settings ID]
    if !(_x isEqualTypeParams [objNull, ""]) then {continue};
    if !(_x call _fnc_isOn) then {continue};

    // The backpack name or the vehicle name
    private _radioName = getText (configOf (_x select 0) >> "displayName");
    private _radioType = [RADIO_VEHICLE, RADIO_LR] select ((_x select 0) == backpackContainer _unit);
    private _range = [[_x select 0, "tf_range"] call TFAR_fnc_getLrRadioProperty] param [0, 0, [0]];
    private _code = _x call TFAR_fnc_getLrRadioCode;
    [_x call TFAR_fnc_getLrFrequency, _code, _radioName, _radioType, false, _range] call _fnc_add;

    private _additional = _x call TFAR_fnc_getAdditionalLrChannel;
    if (!isNil "_additional" && {_additional > -1}) then {
        [[_x, _additional + 1] call TFAR_fnc_getChannelFrequency, _code, _radioName, _radioType, true, _range] call _fnc_add;
    };
} forEach (_unit call TFAR_fnc_lrRadiosList);

_frequencies
