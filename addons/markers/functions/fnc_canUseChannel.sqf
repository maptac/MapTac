#include "..\script_component.hpp"
/*
 * Author: Smith
 * Checks whether the unit can place and see markers in the channel by the channel mode setting:
 * disabled, enabled, enabled in the briefing only (the briefing markers stay visible in the mission),
 * the required devices. Command channel markers are placed by group leaders only.
 *
 * Arguments:
 * 0: Unit <OBJECT>
 * 1: Channel ID <NUMBER>
 * 2: Placing a marker, otherwise seeing <BOOL> (default: false)
 *
 * Return Value:
 * Can use the channel <BOOL>
 *
 * Example:
 * [player, 1, true] call maptac_markers_fnc_canUseChannel
 *
 * Public: Yes
 */

params [["_unit", objNull, [objNull]], ["_channel", 0, [0]], ["_placing", false, [false]]];

// Channel types of compat addons have no settings
if (_channel < 0 || {_channel >= count CHANNEL_SETTING_NAMES}) exitWith {true};

// Command: placed by group leaders only, as the vanilla channel
if (_placing && _channel == 2 && {leader group _unit != _unit}) exitWith {false};

private _fnc_has = {[_unit, _this] call EFUNC(common,hasDevice)};

switch (missionNamespace getVariable [format ["%1%2", QGVAR(channelMode), CHANNEL_SETTING_NAMES select _channel], CHANNEL_MODE_ENABLED]) do {
    case CHANNEL_MODE_DISABLED: {false};
    // The mission time starts after the briefing
    case CHANNEL_MODE_BRIEFING: {!_placing || {time == 0}};
    case CHANNEL_MODE_RADIO: {"radio" call _fnc_has};
    case CHANNEL_MODE_GPS: {"gps" call _fnc_has};
    case CHANNEL_MODE_LONG_RANGE: {"lr" call _fnc_has};
    case CHANNEL_MODE_GPS_OR_LONG_RANGE: {"gps" call _fnc_has || {"lr" call _fnc_has}};
    default {true};
}
