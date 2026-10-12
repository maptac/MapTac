#include "script_component.hpp"

if (isServer) then {
    [QGVAR(frequenciesChanged), {
        params ["_unit", "_frequencies", "_ranges", "_receivingFactor", ["_longRange", []]];
        _unit setVariable [QGVAR(frequencies), _frequencies];
        _unit setVariable [QGVAR(ranges), _ranges];
        _unit setVariable [QGVAR(receivingFactor), _receivingFactor];
        _unit setVariable [QGVAR(longRange), _longRange];
    }] call CBA_fnc_addEventHandler;

    // Placed on a long-range radio: known at the creation only, the creator may retune later
    [QEGVAR(markers,markerCreatedServer), {
        params ["_name", "_data"];
        if ((_data get "channel") != CHANNEL_TFAR) exitWith {};
        [_name, _data] call FUNC(isLongRangeMarker);
    }] call CBA_fnc_addEventHandler;
    [QEGVAR(markers,markerDeletedServer), {
        params ["_name"];
        GVAR(longRangeMarkers) deleteAt _name;
    }] call CBA_fnc_addEventHandler;
};

if (!hasInterface) exitWith {};

// The server resolves the frequency channel receivers by the frequencies reported by the players.
// Distance multipliers are often set by missions locally, so they are taken here.
[{
    if (isNull player) exitWith {};

    private _listened = call FUNC(getListenedFrequencies);
    GVAR(frequencyRadios) = createHashMapFromArray _listened;

    private _unit = missionNamespace getVariable ["TFAR_currentUnit", player];
    if (isNull _unit) then {
        _unit = player;
    };
    // As TFAR does: the range of the transmitting radio and the multipliers of both units,
    // TFAR_globalRadioRangeCoef exists in 1.x only
    private _sendingFactor = _unit getVariable ["tf_sendingDistanceMultiplicator", 1];
    private _receivingFactor = (_unit getVariable ["tf_receivingDistanceMultiplicator", 1])
        / (missionNamespace getVariable ["TFAR_globalRadioRangeCoef", 1]);

    private _frequencies = _listened apply {_x select 0};
    // The longest range of the radios tuned to the frequency
    private _ranges = _listened apply {_sendingFactor * selectMax ((_x select 1) apply {_x select 3})};
    // Listened on a long-range radio (backpack, vehicle)
    private _longRange = _listened apply {(_x select 1) findIf {(_x select 1) != RADIO_SW} != -1};

    // Reported for the unit the player acts as (own or remote controlled by Zeus), its radios are listened
    private _report = [_unit, _frequencies, _ranges, _receivingFactor, _longRange];
    if (_report isEqualTo GVAR(lastReport)) exitWith {};
    GVAR(lastReport) = _report;

    TRACE_1("Listened frequencies changed",_frequencies);
    [QGVAR(frequenciesChanged), _report] call CBA_fnc_serverEvent;
}, FREQUENCIES_CHECK_INTERVAL] call CBA_fnc_addPerFrameHandler;
