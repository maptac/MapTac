#include "..\script_component.hpp"
/*
 * Author: Smith
 * Returns layouts of the quick selection rings: categories inside, markers of the category outside.
 * Icons fill half-circle rings (from the top through the left to the bottom), what doesn't fit goes to the next ring.
 * The end icons keep a distance from the ring ends, where the ring background ends.
 *
 * Arguments:
 * 0: Categories count <NUMBER>
 * 1: Markers count <NUMBER>
 * 2: Icon width in pixels <NUMBER>
 *
 * Return Value:
 * 0: Categories rings layout, [radius in pixels, angle step, icons count] for every ring <ARRAY>
 * 1: Markers rings layout <ARRAY>
 *
 * Example:
 * [5, 10, 50] call maptac_markers_fnc_getQuickRingLayouts
 *
 * Public: No
 */

params ["_categoriesCount", "_markersCount", "_iconWidth"];

// Icons count that fits into the ring and the angle step between them
private _fnc_capacity = {
    params ["_radius"];

    // Arc of the icons, without the distance from the ring ends
    private _arc = 180 - 2 * asin ((RING_END_MARGIN * _iconWidth / _radius) min 1);
    // Chord between neighbor icons must fit the icon with a gap
    private _minStep = 2 * asin ((RING_ICON_SPACING * _iconWidth / (2 * _radius)) min 1);
    private _capacity = 1 + floor (_arc / _minStep + 0.001); // tolerance for the exact fit
    private _step = 0;
    if (_capacity > 1) then {
        _step = _arc / (_capacity - 1);
    };

    [_capacity, _step]
};

private _fnc_layout = {
    params ["_count", "_radius"];

    private _layout = [];
    while {_count > 0} do {
        ([_radius] call _fnc_capacity) params ["_capacity", "_step"];
        private _ringCount = _count min _capacity;

        _layout pushBack [_radius, _step, _ringCount];
        _count = _count - _ringCount;
        _radius = _radius + RING_GAP * _iconWidth;
    };

    _layout
};

// All categories fit into one ring, limited for the case of too many categories
private _innerRadius = RING_INNER_RADIUS * _iconWidth;
private _maxInnerRadius = _innerRadius * 4;
while {(([_innerRadius] call _fnc_capacity) select 0) < _categoriesCount && _innerRadius < _maxInnerRadius} do {
    _innerRadius = _innerRadius + 0.05 * _iconWidth;
};

private _categoryLayout = [_categoriesCount, _innerRadius] call _fnc_layout;

private _lastRadius = (_categoryLayout select -1) select 0;
private _markerLayout = [_markersCount, _lastRadius + RING_GAP * _iconWidth] call _fnc_layout;

[_categoryLayout, _markerLayout]
