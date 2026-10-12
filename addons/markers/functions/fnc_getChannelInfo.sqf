#include "..\script_component.hpp"
/*
 * Author: Smith
 * Returns the localized name and the color of the marker channel
 *
 * Arguments:
 * 0: Channel ID <NUMBER>
 * 1: Channel data, for the channel types added by compat addons <ARRAY> (default: [])
 * 2: Detailed name, for the marker tooltip <BOOL> (default: false)
 *
 * Return Value:
 * 0: Localized name <STRING>
 * 1: Color (RGBA) <ARRAY>
 *
 * Example:
 * [1] call maptac_markers_fnc_getChannelInfo
 *
 * Public: No
 */

params ["_channel", ["_channelData", []], ["_detailed", false]];

private _channelType = GVAR(channelTypes) get _channel;
if (!isNil "_channelType") exitWith {
    [_channelData, _detailed] call (_channelType select 1)
};

switch (_channel) do {
    case 0: {[LELSTRING(common,ChannelGlobal), [0.85, 0.85, 0.85, 1]]};
    case 1: {[LELSTRING(common,ChannelSide), [0.27, 0.83, 0.99, 1]]};
    case 2: {[LELSTRING(common,ChannelCommand), [1, 1, 0.27, 1]]};
    case 3: {[LELSTRING(common,ChannelGroup), [0.71, 0.97, 0.38, 1]]};
    case 4: {[LELSTRING(common,ChannelVehicle), [1, 0.83, 0, 1]]};
    case 5: {[LELSTRING(common,ChannelDirect), [1, 1, 1, 1]]};
    default {["", [1, 1, 1, 1]]};
}
