#include "..\script_component.hpp"
/*
 * Author: Smith
 * Opens the context menu of the map (right click) at the mouse position.
 * On an MapTac marker: forwarding to another available channel (a new marker of the local player, the original one
 * stays in its channel), sending own marker again in its available channel (to who joined it later), measuring the distance
 * from the marker and deleting.
 * On an empty place: marker placement, repeating the last placed marker, the map tools (measuring, route, direction),
 * copying and pasting the markers (extra items, with Shift only).
 *
 * Arguments:
 * 0: Map control <CONTROL>
 * 1: Marker name, "" for an empty place <STRING>
 * 2: Show the extra items <BOOL> (default: false)
 *
 * Return Value:
 * Menu display <DISPLAY>
 *
 * Example:
 * [_mapCtrl, "MapTac:..."] call maptac_markers_fnc_openMapMenu
 *
 * Public: No
 */

params ["_mapCtrl", "_name", ["_extra", false]];

private _screenPos = getMousePosition;
private _pos = _mapCtrl ctrlMapScreenToWorld _screenPos;
private _channels = call FUNC(getAvailableChannels);

// [text, color, tooltip, code called with [map control, marker name or position, argument], argument]
private _items = [];

if (_name == "") then {
    _items pushBack [LLSTRING(MenuCreateMarker), [1, 1, 1, 1], "", {
        params ["_mapCtrl", "_pos", "_screenPos"];
        [_mapCtrl, _pos, _screenPos] call FUNC(openInsertMarker);
    }, _screenPos];

    // The last placed marker, while its channel is available
    GVAR(lastMarker) params [["_channel", -1], ["_channelData", []], ["_type", ""]];
    private _channelIndex = _channels findIf {[_x select 0, _x select 3] isEqualTo [_channel, _channelData]};
    if (_channelIndex != -1) then {
        (_channels select _channelIndex) params ["", "_channelName"];
        _items pushBack [format [LLSTRING(MenuRepeatMarker), [_type] call FUNC(getMarkerName)], [1, 1, 1, 1], _channelName, {
            params ["", "_pos"];
            GVAR(lastMarker) params ["_channel", "_channelData", "_type", "_text", "_color"];
            [_channel, _pos, _type, _text, _color, _channelData] call FUNC(placeMarker);
        }, nil];
    };

    if (_channels isNotEqualTo []) then {
        if (GVAR(enableRoute)) then {
            _items pushBack [LLSTRING(MenuRoute), [1, 1, 1, 1], "", {
                params ["_mapCtrl", "_pos"];
                [_mapCtrl, "route", _pos] call FUNC(startMapTool);
            }, nil];
        };
        _items pushBack [LLSTRING(MenuDirection), [1, 1, 1, 1], "", {
            params ["_mapCtrl", "_pos"];
            [_mapCtrl, "direction", _pos] call FUNC(startMapTool);
        }, nil];
    };

    if (GVAR(enableMeasure)) then {
        _items pushBack [LLSTRING(MenuMeasure), [1, 1, 1, 1], "", {
            params ["_mapCtrl", "_pos"];
            [_mapCtrl, "measure", _pos] call FUNC(startMapTool);
        }, nil];
    };

    // Copying and pasting all the visible markers as text, extra items
    if (_extra && {count GVAR(localMarkers) > 0}) then {
        _items pushBack [LLSTRING(MenuCopyMarkers), [1, 1, 1, 1], "", {
            params ["_mapCtrl"];
            [_mapCtrl, false] call FUNC(openMarkersTransfer);
        }, nil];
    };
    if (_extra && {_channels isNotEqualTo []}) then {
        _items pushBack [LLSTRING(MenuPasteMarkers), [1, 1, 1, 1], "", {
            params ["_mapCtrl"];
            [_mapCtrl, true] call FUNC(openMarkersTransfer);
        }, nil];
    };
} else {
    private _data = GVAR(localMarkers) get _name;
    if (isNil "_data") exitWith {};

    // A new marker of the local player in the channel
    private _fnc_forward = {
        params ["", "_name", "_channel"];
        private _data = GVAR(localMarkers) get _name;
        [
            _channel select 0, _data get "pos", _data get "type", _data getOrDefault ["text", ""], _data get "color",
            _channel select 1, _data getOrDefault ["polyline", []]
        ] call FUNC(placeMarker);
    };

    private _currentChannel = [_data get "channel", _data getOrDefault ["channelData", []]];
    {
        _x params ["_channel", "_channelName", "_color", "_channelData"];
        if ([_channel, _channelData] isEqualTo _currentChannel) then {continue};

        _items pushBack [format [LLSTRING(MenuForward), _channelName], _color, "", _fnc_forward, [_channel, _channelData]];
    } forEach _channels;

    // Own marker, its channel still available (frequency listened)
    if (
        (_data getOrDefault ["creatorKey", ""]) == [call CBA_fnc_currentUnit] call FUNC(getUnitKey)
        && {_channels findIf {[_x select 0, _x select 3] isEqualTo _currentChannel} != -1}
    ) then {
        _items pushBack [LLSTRING(MenuUpdate), [1, 1, 1, 1], LLSTRING(MenuUpdate_Tooltip), {
            params ["", "_name"];
            [_name, (GVAR(localMarkers) get _name) get "pos"] call FUNC(moveMarker);
        }, nil];
    };

    // From the marker point, lines from the clicked point
    if (GVAR(enableMeasure)) then {
        _items pushBack [LLSTRING(MenuMeasure), [1, 1, 1, 1], "", {
            params ["_mapCtrl", "", "_start"];
            [_mapCtrl, "measure", _start] call FUNC(startMapTool);
        }, [_pos, _data get "pos"] select ((_data getOrDefault ["shape", "ICON"]) == "ICON")];
    };

    _items pushBack [LLSTRING(MenuDelete), MENU_DELETE_COLOR, "", {
        params ["", "_name"];
        [_name] call FUNC(deleteMarker);
    }, nil];
};

if (_items isEqualTo []) exitWith {displayNull};

private _display = ctrlParent _mapCtrl createDisplay QGVAR(RscMapMenu);
if (isNull _display) exitWith {displayNull};

_display setVariable [QGVAR(target), [_mapCtrl, [_name, _pos] select (_name == "")]];

// Hides the marker tooltip while open
uiNamespace setVariable [QGVAR(mapDialog), _display];
[_mapCtrl] call FUNC(updateMarkerTooltip);

private _ctrls = _items apply {
    _x params ["_text", "_color", "_tooltip", "_code", "_argument"];

    private _ctrl = _display ctrlCreate [QGVAR(RscMapMenuItem), -1];
    _ctrl ctrlSetText _text;
    _ctrl ctrlSetTextColor _color;
    _ctrl ctrlSetTooltip _tooltip;
    _ctrl setVariable [QGVAR(action), [_code, _argument]];
    _ctrl ctrlAddEventHandler ["ButtonClick", {
        params ["_ctrl"];
        private _display = ctrlParent _ctrl;
        (_ctrl getVariable QGVAR(action)) params ["_code", "_argument"];
        (_display getVariable QGVAR(target)) params ["_mapCtrl", "_target"];
        _display closeDisplay 1;
        // After the menu is closed, the action may open another dialog over the map
        [_code, [_mapCtrl, _target, _argument]] call CBA_fnc_execNextFrame;
    }];
    _ctrl
};

// Width of the longest item, kept on the screen. Rounded to whole pixels, so the items have no gaps between them.
(ctrlPosition (_ctrls select 0)) params ["", "", "_minW", "_itemH"];
_itemH = pixelH * round (_itemH / pixelH);
private _padding = 0.5 * _itemH;
private _menuW = (selectMax (_ctrls apply {ctrlTextWidth _x}) + 2 * _padding) max _minW min (safeZoneW / 2);
_menuW = pixelW * round (_menuW / pixelW);
private _menuH = _itemH * count _ctrls;

_screenPos params ["_mouseX", "_mouseY"];
private _menuX = pixelW * round ((_mouseX min (safeZoneX + safeZoneW - _menuW)) / pixelW);
private _menuY = pixelH * round ((_mouseY min (safeZoneY + safeZoneH - _menuH)) / pixelH);
_display setVariable [QGVAR(menuArea), [_menuX, _menuY, _menuW, _menuH]];

{
    _x ctrlSetPosition [_menuX, _menuY + _itemH * _forEachIndex, _menuW, _itemH];
    _x ctrlCommit 0;
} forEach _ctrls;

// A click outside closes the menu, as Escape does
_display displayAddEventHandler ["MouseButtonDown", {
    params ["_display"];
    (_display getVariable QGVAR(menuArea)) params ["_menuX", "_menuY", "_menuW", "_menuH"];
    getMousePosition params ["_mouseX", "_mouseY"];
    if (_mouseX < _menuX || _mouseX > _menuX + _menuW || _mouseY < _menuY || _mouseY > _menuY + _menuH) then {
        _display closeDisplay 2;
    };
}];

_display
