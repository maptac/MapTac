#include "..\script_component.hpp"
/*
 * Author: Smith
 * Adds a marker channel type, used by compat addons (e.g. radio frequencies).
 * One channel type may have many channels, the channel is identified by its channel data.
 * Must be called on every machine, before the markers are placed (preInit/postInit).
 *
 * Arguments:
 * 0: Channel ID, must be EXTRA_CHANNEL_MIN or more, so it doesn't collide with the engine channels <NUMBER>
 * 1: Channels of the type available to the local player, returns an array of channel data <CODE>
 * 2: Channel info, gets [_channelData, _detailed], returns [localized name, color (RGBA)] <CODE>
 *    _detailed is true for the marker tooltip, where the name may be longer (e.g. with units)
 * 3: Channel receivers on the server, gets [_sender, _channelData], returns players <CODE>
 * 4: Replay recording filter on the server, gets [_name, _data] of the marker, returns whether it is recorded
 *    (see fnc_isChannelRecorded) <CODE> (default: {true})
 *
 * Return Value:
 * Added <BOOL>
 *
 * Example:
 * [100, {[["100.0"]]}, {params ["_data"]; [_data select 0, [1, 1, 1, 1]]}, {allPlayers}] call maptac_markers_fnc_addChannelType
 *
 * Public: Yes
 */

params [
    ["_channel", -1, [0]],
    ["_availableFunc", {}, [{}]],
    ["_infoFunc", {}, [{}]],
    ["_resolverFunc", {}, [{}]],
    ["_recordFunc", {true}, [{}]]
];

if (_channel < EXTRA_CHANNEL_MIN) exitWith {
    WARNING_1("Channel type ID %1 collides with the engine channels",_channel);
    false
};

GVAR(channelTypes) set [_channel, [_availableFunc, _infoFunc, _recordFunc]];
GVAR(channelResolvers) set [_channel, _resolverFunc];

true
