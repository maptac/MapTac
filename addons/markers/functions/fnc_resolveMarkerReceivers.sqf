#include "..\script_component.hpp"
/*
 * Author: Smith
 * Resolves the players who currently are in the marker channel, relative to the player who changes the marker
 * (creates, moves or deletes it): like a radio transmission, the change reaches who hears that player.
 * The editor receives the marker even outside of the channel, so their local copy is synchronized.
 * Players who cannot use the channel (disabled channel, no required devices) don't receive it,
 * except the editor.
 * Must be executed on server-side only
 *
 * Arguments:
 * 0: Marker data <HASHMAP>
 * 1: Player who creates/moves/deletes the marker <OBJECT>
 *
 * Return Value:
 * Players <ARRAY>
 *
 * Example:
 * [_data, player] call maptac_markers_fnc_resolveMarkerReceivers
 *
 * Public: No
 */

params ["_data", "_editor"];

private _channel = _data get "channel";
private _receivers = [_editor, _data get "channelData"] call (GVAR(channelResolvers) getOrDefault [_channel, {[]}]);

// Own copy, e.g. command channel when not a group leader. The editor may be a remote controlled unit.
if (alive _editor) then {
    _receivers pushBackUnique _editor;
};

// Null targets would make CBA_fnc_targetEvent broadcast to everyone
_receivers select {!isNull _x && {_x == _editor || {[_x, _channel] call FUNC(canUseChannel)}}}
