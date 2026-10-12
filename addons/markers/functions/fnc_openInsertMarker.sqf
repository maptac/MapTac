#include "..\script_component.hpp"
#include "\a3\ui_f\hpp\defineResincl.inc"
/*
 * Author: Smith
 * Opens the MapTac marker placement dialog at the marker position on the screen.
 * The marker is previewed with a local marker on the map, so it looks exactly like the placed one.
 *
 * Arguments:
 * 0: Map control <CONTROL>
 * 1: Marker position <ARRAY>
 * 2: Marker position on the screen <ARRAY> (default: getMousePosition)
 *
 * Return Value:
 * Marker placement dialog <DISPLAY>
 *
 * Example:
 * [findDisplay 12 displayCtrl 51, [1000, 1000]] call maptac_markers_fnc_openInsertMarker
 *
 * Public: No
 */

params ["_mapCtrl", "_pos", ["_screenPos", getMousePosition]];

private _display = ctrlParent _mapCtrl createDisplay QGVAR(RscInsertMarker);
if (isNull _display) exitWith {displayNull};

_display setVariable [QGVAR(position), _pos];

// Hides the marker tooltip while open
uiNamespace setVariable [QGVAR(mapDialog), _display];
[_mapCtrl] call FUNC(updateMarkerTooltip);

deleteMarkerLocal QGVAR(preview);
createMarkerLocal [QGVAR(preview), _pos];
QGVAR(preview) setMarkerShapeLocal "ICON";

// Quick selection icon size
private _probe = _display ctrlCreate [QGVAR(RscQuickMarker), -1];
(ctrlPosition _probe) params ["", "", "_iconW", "_iconH"];
ctrlDelete _probe;
_display setVariable [QGVAR(quickIconSize), [_iconW, _iconH]];

private _colors = (("true" configClasses (configFile >> QGVAR(QuickMarkerColors))) apply {
    [getText (_x >> "displayName"), getText (_x >> "color"), getText (_x >> "prefix")]
}) select {isClass (configFile >> "CfgMarkerColors" >> (_x select 1))};
if (_colors isEqualTo []) then {
    _colors = [["", "ColorBlack", ""]];
};
_display setVariable [QGVAR(colors), _colors];

// Preselect the last used color and marker type, the markers side follows the type
private _lastType = profileNamespace getVariable [QGVAR(lastMarkerType), ""];
private _lastColor = profileNamespace getVariable [QGVAR(lastMarkerColor), ""];
private _colorIndex = 0 max (_colors findIf {(_x select 1) == _lastColor});
private _prefix = _lastType select [0, 2];
if !(_prefix in SIDE_PREFIXES) then {
    _prefix = (_colors select _colorIndex) select 2;
    if (_prefix == "") then {
        _prefix = SIDE_PREFIXES select 0;
    };
};

private _categories = [_prefix] call FUNC(getQuickMarkerCategories);
_display setVariable [QGVAR(prefix), _prefix];
_display setVariable [QGVAR(selectedType), _lastType];
_display setVariable [QGVAR(categoryIndex), 0 max (_categories findIf {_lastType == _x select 1 || {_lastType in (_x select 2)}})];

// The biggest rings, for the category with the most markers
private _maxMarkers = selectMax (_categories apply {count (_x select 2)});
([count _categories, _maxMarkers, _iconW / pixelW] call FUNC(getQuickRingLayouts)) params ["_categoryLayout", "_markerLayout"];
private _maxRadius = (([_markerLayout, _categoryLayout] select (_markerLayout isEqualTo [])) select -1) select 0;

// Config controls are defined relative to the marker point, the rings extend to the left of it.
// Keep everything on the screen, the map is moved under the dialog when it is shifted.
private _left = -_maxRadius * pixelW - _iconW / 2;
private _top = -_maxRadius * pixelH - _iconH / 2;
private _right = 0;
private _bottom = -_top;
{
    (ctrlPosition _x) params ["_ctrlX", "_ctrlY", "_ctrlW", "_ctrlH"];
    _left = _left min _ctrlX;
    _top = _top min _ctrlY;
    _right = _right max (_ctrlX + _ctrlW);
    _bottom = _bottom max (_ctrlY + _ctrlH);
} forEach allControls _display;

_screenPos params ["_screenX", "_screenY"];
private _originX = (_screenX max (safeZoneX - _left)) min (safeZoneX + safeZoneW - _right);
private _originY = (_screenY max (safeZoneY - _top)) min (safeZoneY + safeZoneH - _bottom);
_display setVariable [QGVAR(origin), [_originX, _originY]];

{
    (ctrlPosition _x) params ["_ctrlX", "_ctrlY", "_ctrlW", "_ctrlH"];
    _x ctrlSetPosition [_ctrlX + _originX, _ctrlY + _originY, _ctrlW, _ctrlH];
    _x ctrlCommit 0;
} forEach allControls _display;

if (_originX != _screenX || _originY != _screenY) then {
    (ctrlPosition _mapCtrl) params ["_mapX", "_mapY", "_mapW", "_mapH"];
    (_mapCtrl ctrlMapScreenToWorld [_mapX + _mapW / 2, _mapY + _mapH / 2]) params ["_centerX", "_centerY"];
    (_mapCtrl ctrlMapScreenToWorld [_originX, _originY]) params ["_shiftedX", "_shiftedY"];
    _pos params ["_posX", "_posY"];

    _mapCtrl ctrlMapAnimAdd [0, ctrlMapScale _mapCtrl, [_centerX + _posX - _shiftedX, _centerY + _posY - _shiftedY]];
    ctrlMapAnimCommit _mapCtrl;
};

// Color buttons
private _ctrlColors = _display displayCtrl IDC_INSERTMARKER_COLORS;
(ctrlPosition _ctrlColors) params ["_areaX", "_areaY", "_areaW", "_areaH"];
private _gap = _areaW * 0.02;
private _buttonW = (_areaW - _gap * (count _colors - 1)) / count _colors;

private _colorCtrls = [];
{
    _x params ["_name", "_colorClass"];

    private _ctrl = _display ctrlCreate [QGVAR(RscQuickColor), -1];
    _ctrl ctrlSetPosition [_areaX + (_buttonW + _gap) * _forEachIndex, _areaY, _buttonW, _areaH];
    _ctrl ctrlCommit 0;
    _ctrl ctrlSetTooltip _name;
    _ctrl setVariable [QGVAR(value), _forEachIndex];
    [_ctrl, [_colorClass] call FUNC(getMarkerColor)] call FUNC(setQuickControlColor);
    _ctrl ctrlAddEventHandler ["ButtonClick", {
        params ["_ctrl"];
        [ctrlParent _ctrl, _ctrl getVariable QGVAR(value)] call FUNC(selectQuickColor);
    }];

    _colorCtrls pushBack _ctrl;
} forEach _colors;
_display setVariable [QGVAR(colorCtrls), _colorCtrls];

// Builds the rings
[_display, _colorIndex] call FUNC(selectQuickColor);

// Channels
private _ctrlChannel = _display displayCtrl IDC_INSERTMARKER_CHANNEL;
private _channels = call FUNC(getAvailableChannels);
_display setVariable [QGVAR(channels), _channels];
{
    _x params ["", "_name", "_color"];

    private _index = _ctrlChannel lbAdd _name;
    _ctrlChannel lbSetValue [_index, _forEachIndex];
    _ctrlChannel lbSetColor [_index, _color];
    _ctrlChannel lbSetSelectColor [_index, _color];
} forEach _channels;

// The channel of the last placed marker, otherwise the current one like the vanilla dialog does
private _channelIndex = _channels findIf {[_x select 0, _x select 3] isEqualTo (GVAR(lastMarker) select [0, 2])};
if (_channelIndex == -1) then {
    _channelIndex = _channels findIf {(_x select 0) == currentChannel};
};
_ctrlChannel lbSetCurSel (_channelIndex max 0);

// Nothing to send to: disabled channels or no devices
if (_channels isEqualTo []) then {
    _ctrlChannel lbSetValue [_ctrlChannel lbAdd LLSTRING(NoChannels), -1];
    _ctrlChannel lbSetCurSel 0;
    _ctrlChannel ctrlEnable false;
    (_display displayCtrl IDC_OK) ctrlEnable false;
};

// Placeholder is visible while the text is empty
private _ctrlText = _display displayCtrl IDC_INSERTMARKER_TEXT;
_ctrlText ctrlAddEventHandler ["KeyUp", {
    params ["_ctrlText"];
    (ctrlParent _ctrlText displayCtrl IDC_INSERTMARKER_TEXT_PLACEHOLDER) ctrlShow (ctrlText _ctrlText == "");
}];

// Vehicle name button, in a vehicle only
private _ctrlVehicle = _display displayCtrl IDC_INSERTMARKER_VEHICLE;
private _vehicle = objectParent (call CBA_fnc_currentUnit);
if (isNull _vehicle) then {
    _ctrlVehicle ctrlShow false;
} else {
    private _vehicleName = getText (configOf _vehicle >> "displayName");
    _ctrlVehicle ctrlSetTooltip format [LLSTRING(InsertVehicleName), _vehicleName];
    _ctrlVehicle setVariable [QGVAR(vehicleName), _vehicleName];
    _ctrlVehicle ctrlAddEventHandler ["ButtonClick", {
        params ["_ctrlVehicle"];
        private _display = ctrlParent _ctrlVehicle;
        private _ctrlText = _display displayCtrl IDC_INSERTMARKER_TEXT;
        private _vehicleName = _ctrlVehicle getVariable QGVAR(vehicleName);
        // Added to the text already written
        private _text = ctrlText _ctrlText;
        _ctrlText ctrlSetText ([_vehicleName, format ["%1 %2", _text, _vehicleName]] select (_text != ""));
        (_display displayCtrl IDC_INSERTMARKER_TEXT_PLACEHOLDER) ctrlShow false;
        ctrlSetFocus _ctrlText;
    }];
};

// Background of the rings is drawn on the map under the dialog
_mapCtrl setVariable [QGVAR(insertDisplay), _display];
_display setVariable [QGVAR(ringsDrawEH), [_mapCtrl, _mapCtrl ctrlAddEventHandler ["Draw", {call FUNC(drawQuickRings)}]]];

_display displayAddEventHandler ["Unload", {call FUNC(onInsertMarkerUnload)}];

ctrlSetFocus _ctrlText;

_display
