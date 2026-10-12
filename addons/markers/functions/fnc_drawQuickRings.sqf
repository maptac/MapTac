#include "..\script_component.hpp"
/*
 * Author: Smith
 * Draws the background of the quick selection rings of the marker placement dialog on the map under it,
 * so the icons don't blend with the map and the markers. Called from the map Draw event.
 *
 * Arguments:
 * 0: Map control <CONTROL>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_mapCtrl] call maptac_markers_fnc_drawQuickRings
 *
 * Public: No
 */

params ["_mapCtrl"];

private _display = _mapCtrl getVariable [QGVAR(insertDisplay), displayNull];
if (isNull _display) exitWith {};

(_display getVariable [QGVAR(ringLayouts), []]) params [["_categoryLayout", []], ["_markerLayout", []]];
(_display getVariable QGVAR(origin)) params ["_originX", "_originY"];
(_display getVariable QGVAR(quickIconSize)) params ["_iconW", "_iconH"];

// Bands of the neighbor rings touch, the outlines separate them
private _halfBand = RING_GAP * _iconW / pixelW / 2;
// All the bands end on one vertical line right of the marker point, a bit further than the end icons.
// Inside the innermost band, otherwise the band would have no end.
private _innermostRadius = ((_categoryLayout select 0) select 0) - _halfBand;
private _edgeX = (0.6 * _iconH / pixelH) min (0.9 * _innermostRadius);

// From the top through the left to the bottom, as the icons go, between the angles where the circles
// cross the end line. Positions are 3D, drawPolygon doesn't take 2D ones.
private _fnc_arc = {
    params ["_arcRadius"];
    private _start = acos ((_edgeX / _arcRadius) min 1);
    private _step = (360 - 2 * _start) / RING_SEGMENTS;
    private _points = [];
    for "_i" from 0 to RING_SEGMENTS do {
        private _angle = _start + _step * _i;
        _points pushBack ((_mapCtrl ctrlMapScreenToWorld [
            _originX + _arcRadius * cos _angle * pixelW,
            _originY - _arcRadius * sin _angle * pixelH
        ]) + [0]);
    };
    _points
};

{
    _x params ["_layout", "_color"];

    {
        _x params ["_radius"];

        private _innerRadius = _radius - _halfBand;
        private _outerRadius = _radius + _halfBand;
        private _outerPoints = [_outerRadius] call _fnc_arc;
        private _innerPoints = [_innerRadius] call _fnc_arc;

        private _triangles = [];
        for "_i" from 0 to (RING_SEGMENTS - 1) do {
            _triangles append [
                _outerPoints select _i, _innerPoints select _i, _outerPoints select (_i + 1),
                _innerPoints select _i, _innerPoints select (_i + 1), _outerPoints select (_i + 1)
            ];
        };
        _mapCtrl drawTriangle [_triangles, _color, "#(rgb,1,1,1)color(1,1,1,1)"];

        reverse _innerPoints;
        _mapCtrl drawPolygon [_outerPoints + _innerPoints, RING_OUTLINE_COLOR];
    } forEach _layout;
} forEach [
    [_categoryLayout, RING_CATEGORY_BACKGROUND_COLOR],
    [_markerLayout, RING_BACKGROUND_COLOR]
];

nil
