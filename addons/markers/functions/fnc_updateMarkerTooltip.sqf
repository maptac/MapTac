#include "..\script_component.hpp"
/*
 * Author: Smith
 * Shows the tooltip of the MapTac marker under the cursor: type, creator, creation and modification dates, channel
 *
 * Arguments:
 * 0: Map control <CONTROL>
 *
 * Return Value:
 * None
 *
 * Example:
 * [findDisplay 12 displayCtrl 51] call maptac_markers_fnc_updateMarkerTooltip
 *
 * Public: No
 */

params ["_mapCtrl"];

(ctrlParent _mapCtrl getVariable [QGVAR(tooltipCtrls), [controlNull, controlNull]]) params ["_ctrlBackground", "_ctrlTooltip"];
if (isNull _ctrlTooltip) exitWith {};

// No tooltip while dragging or while a dialog is open over the map (the map still gets the mouse events)
private _name = "";
if (isNull (uiNamespace getVariable [QGVAR(mapDialog), displayNull]) && {GVAR(dragState) isEqualTo [] || {!(GVAR(dragState) select 2)}}) then {
    _name = [_mapCtrl] call FUNC(getMarkerUnderCursor);
};

private _data = GVAR(localMarkers) get _name;
if (isNil "_data") exitWith {
    _ctrlBackground ctrlShow false;
    _ctrlTooltip ctrlShow false;
    // Built again when it appears: channel names of compat addons change (e.g. radios retuned)
    _ctrlTooltip setVariable [QGVAR(data), nil];
};

// MouseHolding fires every frame, the text is built only when the tooltip appears or another marker
// or its new version is shown
if (_data isNotEqualTo (_ctrlTooltip getVariable [QGVAR(data), []])) then {
    _ctrlTooltip setVariable [QGVAR(data), _data];

    // Names may contain structured text markup
    private _fnc_escape = {
        [_this] call EFUNC(common,escapeStructuredText)
    };

    private _typeName = [_data get "type"] call FUNC(getMarkerName);
    private _creator = (_data getOrDefault ["creatorName", ""]) call _fnc_escape;
    private _group = ([_data getOrDefault ["creatorGroup", ""]] call FUNC(formatCallsign)) call _fnc_escape;
    if (_group != "") then {
        _creator = format ["%1 (%2)", _creator, _group];
    };
    ([_data get "channel", _data getOrDefault ["channelData", []], true] call FUNC(getChannelInfo)) params ["_channelName", "_channelColor"];

    private _lines = [
        format ["<t font='RobotoCondensedBold'>%1</t>", _typeName call _fnc_escape],
        format ["%1: %2", LLSTRING(TooltipPlacedBy), _creator],
        format ["%1: %2", LLSTRING(TooltipCreated), [_data getOrDefault ["creationDate", date]] call FUNC(formatMarkerDate)]
    ];

    private _modificationDate = _data getOrDefault ["modificationDate", []];
    if (_modificationDate isNotEqualTo []) then {
        _lines pushBack format ["%1: %2", LLSTRING(TooltipModified), [_modificationDate] call FUNC(formatMarkerDate)];
    };

    _lines pushBack format [
        "%1: <t color='%2'>%3</t>",
        LLSTRING(TooltipChannel),
        _channelColor call BIS_fnc_colorRGBAtoHTML,
        _channelName call _fnc_escape
    ];

    _ctrlTooltip ctrlSetStructuredText parseText (_lines joinString "<br/>");
};

// Next to the cursor, inside the screen. The background is bigger than the text for the vertical padding.
getMousePosition params ["_mouseX", "_mouseY"];
(ctrlPosition _ctrlTooltip) params ["", "", "_tooltipW"];
private _textH = ctrlTextHeight _ctrlTooltip;
private _padding = TOOLTIP_PADDING * pixelH;
private _tooltipH = _textH + 2 * _padding;

private _tooltipX = _mouseX + 16 * pixelW;
if (_tooltipX + _tooltipW > safeZoneX + safeZoneW) then {
    _tooltipX = _mouseX - 16 * pixelW - _tooltipW;
};
private _tooltipY = _mouseY + 16 * pixelH;
if (_tooltipY + _tooltipH > safeZoneY + safeZoneH) then {
    _tooltipY = _mouseY - 4 * pixelH - _tooltipH;
};

_ctrlBackground ctrlSetPosition [_tooltipX, _tooltipY, _tooltipW, _tooltipH];
_ctrlBackground ctrlCommit 0;
_ctrlBackground ctrlShow true;

_ctrlTooltip ctrlSetPosition [_tooltipX, _tooltipY + _padding, _tooltipW, _textH];
_ctrlTooltip ctrlCommit 0;
_ctrlTooltip ctrlShow true;

nil
