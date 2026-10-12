#include "..\script_component.hpp"
/*
 * Author: Smith
 * Returns the players who listen to the frequency, by the frequencies reported by them.
 * The sender must listen to the frequency too, a radio transmits only on its own frequency.
 * With the range limit setting, only the players who would hear the sender over the radio:
 * the distance against the sender radio range with the TFAR distance multipliers, terrain is not taken into account.
 * Must be executed on server-side only
 *
 * Arguments:
 * 0: Sender <OBJECT>
 * 1: Channel data <ARRAY>
 *   0: Frequency <STRING>
 *   1: Encryption code <STRING>
 *
 * Return Value:
 * Players <ARRAY>
 *
 * Example:
 * [player, ["100.0", "_bluefor"]] call maptac_compat_tfar_fnc_getFrequencyPlayers
 *
 * Public: No
 */

params ["_sender", "_channelData"];

// The sender doesn't listen to the frequency (retuned), so cannot transmit on it
private _index = (_sender getVariable [QGVAR(frequencies), []]) find _channelData;
if (_index == -1) exitWith {[]};

private _players = (call EFUNC(markers,getActingUnits)) select {_channelData in (_x getVariable [QGVAR(frequencies), []])};
if (!GVAR(limitRange)) exitWith {_players};

private _range = (_sender getVariable [QGVAR(ranges), []]) param [_index, 0];

_players select {(_x distance _sender) * (_x getVariable [QGVAR(receivingFactor), 1]) <= _range}
