#include "..\script_component.hpp"
/*
 * Author: Smith
 * Returns quick marker selection categories from the config with marker types of the given side prefix
 *
 * Arguments:
 * 0: Side prefix of the markers (b_, o_, n_) <STRING>
 *
 * Return Value:
 * Categories <ARRAY>
 * 0: Display name (name of the category marker) <STRING>
 * 1: Category marker type (CfgMarkers class) <STRING>
 * 2: Other marker types of the category (CfgMarkers classes) <ARRAY>
 *
 * Example:
 * _categories = ["b_"] call maptac_markers_fnc_getQuickMarkerCategories
 *
 * Public: No
 */

params ["_prefix"];

private _cfgMarkers = configFile >> "CfgMarkers";

private _categories = [];
{
    private _icon = format [getText (_x >> "icon"), _prefix];
    private _types = getArray (_x >> "markers") apply {format [_x, _prefix]};
    _types = _types select {isClass (_cfgMarkers >> _x)};

    if !(isClass (_cfgMarkers >> _icon)) then {
        if (_types isEqualTo []) then {continue};
        _icon = _types deleteAt 0;
    };

    // The category marker is selected by the category itself
    _types = _types - [_icon];

    _categories pushBack [[_icon] call FUNC(getMarkerName), _icon, _types select [0, MAX_QUICK_MARKERS]];
} forEach ("true" configClasses (configFile >> QGVAR(QuickMarkerCategories)));

if (_categories isEqualTo []) then {
    _categories = [[["hd_dot"] call FUNC(getMarkerName), "hd_dot", []]];
};

_categories select [0, MAX_QUICK_MARKERS]
