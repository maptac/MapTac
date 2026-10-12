#include "..\script_component.hpp"
/*
 * Author: Smith
 * Rebuilds the quick selection rings of the marker placement dialog for the selected color, side and category,
 * updates the preview marker
 *
 * Arguments:
 * 0: Marker placement dialog <DISPLAY>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_display] call maptac_markers_fnc_updateQuickRings
 *
 * Public: No
 */

params ["_display"];

private _colorClass = ((_display getVariable QGVAR(colors)) select (_display getVariable QGVAR(colorIndex))) select 1;
private _color = [_colorClass] call FUNC(getMarkerColor);

private _categories = [_display getVariable QGVAR(prefix)] call FUNC(getQuickMarkerCategories);
private _categoryIndex = (_display getVariable [QGVAR(categoryIndex), 0]) min (count _categories - 1);
_display setVariable [QGVAR(categoryIndex), _categoryIndex];
(_categories select _categoryIndex) params ["", "_categoryType", "_types"];

{
    ctrlDelete _x;
} forEach ((_display getVariable [QGVAR(categoryRingCtrls), []]) + (_display getVariable [QGVAR(markerRingCtrls), []]));

(_display getVariable QGVAR(quickIconSize)) params ["_iconW"];
([count _categories, count _types, _iconW / pixelW] call FUNC(getQuickRingLayouts)) params ["_categoryLayout", "_markerLayout"];
// For the background, see fnc_drawQuickRings
_display setVariable [QGVAR(ringLayouts), [_categoryLayout, _markerLayout]];

private _categoryItems = [];
{
    _x params ["_name", "_icon"];
    _categoryItems pushBack [_icon, _name, _forEachIndex];
} forEach _categories;

private _categoryCtrls = [_display, _categoryItems, _categoryLayout, _color, {
    params ["_display", "_index"];
    _display setVariable [QGVAR(categoryIndex), _index];
    _display setVariable [QGVAR(selectedType), ""]; // the category marker is selected below
    [_display] call FUNC(updateQuickRings);
}] call FUNC(createMarkerRing);
_display setVariable [QGVAR(categoryRingCtrls), _categoryCtrls];
[_categoryCtrls, _categoryIndex] call FUNC(highlightMarkerRing);

private _markerItems = _types apply {[_x, [_x] call FUNC(getMarkerName), _x]};
private _markerCtrls = [_display, _markerItems, _markerLayout, _color, FUNC(selectQuickMarker)] call FUNC(createMarkerRing);
_display setVariable [QGVAR(markerRingCtrls), _markerCtrls];

QGVAR(preview) setMarkerColorLocal _colorClass;

// Keep the selected marker when it belongs to the category, otherwise select the category marker
private _selectedType = _display getVariable [QGVAR(selectedType), ""];
if (_selectedType != _categoryType && {!(_selectedType in _types)}) then {
    _selectedType = _categoryType;
};
[_display, _selectedType] call FUNC(selectQuickMarker);

nil
