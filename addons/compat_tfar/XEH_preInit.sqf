#include "script_component.hpp"

ADDON = false;

PREP_RECOMPILE_START;
#include "XEH_PREP.hpp"
PREP_RECOMPILE_END;

// Long-range radios: backpacks and vehicle radios. They are radios too, TFAR handhelds are in the radio slot already.
private _fnc_hasLongRange = {
    params ["_unit"];
    private _vehicle = objectParent _unit;
    getNumber (configFile >> "CfgVehicles" >> backpack _unit >> "tf_hasLRradio") == 1
    || {!isNull _vehicle && {!isNil "TFAR_fnc_hasVehicleRadio"} && {_vehicle call TFAR_fnc_hasVehicleRadio}}
};
["lr", _fnc_hasLongRange] call EFUNC(common,addDeviceCondition);
["radio", _fnc_hasLongRange] call EFUNC(common,addDeviceCondition);

// Frequency channel data -> radios it is listened on, for the channel names
GVAR(frequencyRadios) = createHashMap;

// A marker channel for every listened frequency
[CHANNEL_TFAR, {
    private _frequencies = call FUNC(getListenedFrequencies);
    GVAR(frequencyRadios) = createHashMapFromArray _frequencies;
    _frequencies apply {_x select 0}
}, FUNC(getFrequencyInfo), FUNC(getFrequencyPlayers), {
    params ["_name", "_data"];
    switch (GVAR(recordFrequencies)) do {
        case RECORD_LONG_RANGE_PLACED: {[_name, _data] call FUNC(isLongRangeMarker)};
        case RECORD_LONG_RANGE_BAND: {
            private _frequency = parseNumber ((_data get "channelData") param [0, ""]);
            _frequency >= LONG_RANGE_MIN_FREQUENCY && _frequency <= LONG_RANGE_MAX_FREQUENCY
        };
        default {true};
    }
}] call EFUNC(markers,addChannelType);

// Server: marker name -> placed on a long-range radio, see fnc_isLongRangeMarker
GVAR(longRangeMarkers) = createHashMap;

// [unit, frequencies, ranges, receiving factor, long-range flags] last sent to the server
GVAR(lastReport) = [];

#include "initSettings.inc.sqf"

ADDON = true;
