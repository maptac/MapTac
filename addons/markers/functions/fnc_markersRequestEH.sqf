#include "..\script_component.hpp"
/*
 * Author: Smith
 * Handles the report of the unit a player acts as: their own unit (joined, also in progress or after reconnecting,
 * respawned) or the unit remote controlled as Zeus. The unit is remembered for the channels (fnc_getActingUnits).
 * When the player has switched to the unit (joined, Zeus), sends the current markers it should have, as when taking
 * another slot: the markers the unit has received before (any channel) and the markers of the lasting channels
 * (global, side, command, group) it is in now. Radio frequency, vehicle and direct channel markers are not sent
 * to the units which did not receive them: who was not listening when the marker was sent did not hear it.
 * Must be executed on server-side only
 *
 * Arguments:
 * 0: Unit the player acts as <OBJECT>
 * 1: Player <OBJECT>
 * 2: Switched to the unit, send its markers <BOOL> (default: true)
 *
 * Return Value:
 * None
 *
 * Example:
 * [player, player] call maptac_markers_fnc_markersRequestEH
 *
 * Public: No
 */

params [["_unit", objNull, [objNull]], ["_player", objNull, [objNull]], ["_switched", true, [true]]];

if (isNull _unit) exitWith {};

if (!isNull _player) then {
    _player setVariable [QGVAR(actingUnit), _unit];
};

if (!_switched) exitWith {};

private _key = [_unit] call FUNC(getUnitKey);
private _count = 0;

{
    private _channel = _y get "channel";
    private _send = _key in (GVAR(markerHolders) getOrDefault [_x, []]);

    if (!_send && {_channel in RESTORED_CHANNELS}) then {
        // Resolved from the creator (respawned too), the side or the group of a disconnected creator is unknown
        private _creator = [_y] call FUNC(getCreatorUnit);
        _send = alive _creator
            && {[_unit, _channel] call FUNC(canUseChannel)}
            && {_unit in ([_creator, _y get "channelData"] call (GVAR(channelResolvers) get _channel))};
    };

    if (_send) then {
        [_x, _y, [_unit]] call FUNC(sendMarker);
        _count = _count + 1;
    };
} forEach GVAR(markers);

TRACE_2("Markers restored",_unit,_count);

nil
