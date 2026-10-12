#include "..\script_component.hpp"
/*
 * Author: Smith
 * Returns the channels in which the local player can place markers:
 * the vanilla channels and the channels of the types added by compat addons
 *
 * Return Value:
 * Channels <ARRAY>
 * 0: Channel ID <NUMBER>
 * 1: Localized name <STRING>
 * 2: Color (RGBA) <ARRAY>
 * 3: Channel data <ARRAY>
 *
 * Example:
 * _channels = call maptac_markers_fnc_getAvailableChannels
 *
 * Public: No
 */

// Own unit or remote controlled by Zeus
private _unit = call CBA_fnc_currentUnit;
private _channels = [0, 1, 2, 3, 4, 5] select {
    (channelEnabled _x) select 0 // text chat enabled
    && {_x != 4 || {!isNull objectParent _unit}}
    && {[_unit, _x, true] call FUNC(canUseChannel)}
};

private _result = _channels apply {[_x] + ([_x] call FUNC(getChannelInfo)) + [[]]};

{
    private _channel = _x;
    _y params ["_availableFunc", "_infoFunc"];
    {
        _result pushBack ([_channel] + ([_x] call _infoFunc) + [_x]);
    } forEach (call _availableFunc);
} forEach GVAR(channelTypes);

_result
