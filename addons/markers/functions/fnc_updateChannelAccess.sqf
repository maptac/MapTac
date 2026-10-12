#include "..\script_component.hpp"
/*
 * Author: Smith
 * Updates which channels the local player can see, hides or shows markers of the changed channels.
 * Called when the player loadout or the channel settings change.
 *
 * Arguments:
 * None
 *
 * Return Value:
 * None
 *
 * Example:
 * call maptac_markers_fnc_updateChannelAccess
 *
 * Public: No
 */

// Own unit or remote controlled by Zeus
private _unit = call CBA_fnc_currentUnit;
if (!hasInterface || {isNull _unit}) exitWith {};

private _changed = [];
{
    private _access = [_unit, _forEachIndex] call FUNC(canUseChannel);
    if (GVAR(channelAccess) getOrDefault [_forEachIndex, true] isNotEqualTo _access) then {
        _changed pushBack _forEachIndex;
    };
    GVAR(channelAccess) set [_forEachIndex, _access];
} forEach CHANNEL_SETTING_NAMES;

if (_changed isEqualTo []) exitWith {};
TRACE_1("Channel access changed",_changed);

{
    if !((_y get "channel") in _changed) then {continue};

    if (GVAR(channelAccess) get (_y get "channel")) then {
        [_x, _y] call FUNC(drawMarker);
    } else {
        deleteMarkerLocal _x;
    };
} forEach GVAR(localMarkers);

nil
