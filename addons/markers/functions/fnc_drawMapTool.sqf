#include "..\script_component.hpp"
/*
 * Author: Smith
 * Draws the active map tool, called from the map Draw event:
 * the ruler from the start to the cursor with the 10 m, 100 m and 1 km ticks and the distance labels,
 * the route with the segment to the cursor (snapped to the nearest road while the key is held),
 * the direction arrow from the start to the cursor
 *
 * Arguments:
 * 0: Map control <CONTROL>
 *
 * Return Value:
 * None
 *
 * Example:
 * [_mapCtrl] call maptac_markers_fnc_drawMapTool
 *
 * Public: No
 */

params ["_mapCtrl"];

if !("tool" in GVAR(mapTool)) exitWith {};

private _tool = GVAR(mapTool) get "tool";
private _points = GVAR(mapTool) get "points";
private _start = _points select 0;
private _cursor = (_mapCtrl ctrlMapScreenToWorld getMousePosition) select [0, 2];

// Pixels per meter of the current map scale
private _fnc_pixelsPerMeter = {
    _cursor params ["_cursorX", "_cursorY"];
    (_mapCtrl ctrlMapWorldToScreen _cursor) params ["_x1", "_y1"];
    (_mapCtrl ctrlMapWorldToScreen [_cursorX + 100, _cursorY]) params ["_x2", "_y2"];
    sqrt (((_x2 - _x1) / pixelW) ^ 2 + ((_y2 - _y1) / pixelH) ^ 2) / 100
};

// [distance, unit (DISTANCE_UNIT_*)], dynamic: meters below 1 km
private _fnc_formatDistance = {
    params ["_distance", ["_unit", DISTANCE_UNIT_DYNAMIC]];
    if (_unit == DISTANCE_UNIT_METERS || {_unit == DISTANCE_UNIT_DYNAMIC && _distance < 1000}) exitWith {
        format [LLSTRING(DistanceMeters), round _distance]
    };
    format [LLSTRING(DistanceKilometers), round (_distance / 10) / 100]
};

// Labels [screen X, screen Y, text, color, align], drawn by the UI controls at the end:
// drawIcon text shrinks with the map zoom, the vanilla cursor info doesn't
private _labels = [];
private _textSize = MAP_TOOL_TEXT_SIZE;
private _fnc_label = {
    params ["_pos", "_text", "_color", ["_align", "center"]];
    (_mapCtrl ctrlMapWorldToScreen _pos) params ["_screenX", "_screenY"];
    _labels pushBack [_screenX, _screenY, _text, _color, _align];
};

// Lines one above another left of the cursor, mirroring the vanilla cursor info on the right
private _fnc_cursorLabel = {
    params ["_lines", "_color"];
    getMousePosition params ["_mouseX", "_mouseY"];
    private _firstY = _mouseY - _textSize * (count _lines - 1) / 2;
    {
        _labels pushBack [_mouseX - MAP_TOOL_CURSOR_LABEL_OFFSET * pixelW, _firstY + _textSize * _forEachIndex, _x, _color, "right"];
    } forEach _lines;
};

call {
    if (_tool == "measure") exitWith {
        private _distance = _start distance2D _cursor;
        _mapCtrl drawLine [_start, _cursor, RULER_MAIN_LINE_COLOR];
        if (_distance < 1) exitWith {};

        // Unit vector of the ruler, the ticks are perpendicular to it
        private _dirX = ((_cursor select 0) - (_start select 0)) / _distance;
        private _dirY = ((_cursor select 1) - (_start select 1)) / _distance;
        private _pixelsPerMeter = call _fnc_pixelsPerMeter;

        {
            _x params ["_step", "_tickPixels"];
            // Too dense at this map scale
            if (_step * _pixelsPerMeter < RULER_MIN_TICK_SPACING) then {continue};

            private _half = _tickPixels / 2 / _pixelsPerMeter;
            for "_along" from _step to _distance step _step do {
                private _tickX = (_start select 0) + _dirX * _along;
                private _tickY = (_start select 1) + _dirY * _along;
                _mapCtrl drawLine [
                    [_tickX - _dirY * _half, _tickY + _dirX * _half],
                    [_tickX + _dirY * _half, _tickY - _dirX * _half],
                    RULER_LINE_COLOR
                ];
            };
        } forEach RULER_TICKS;

        // Labels of the smallest ticks they fit to (the ticks go from the largest), beside the ruler
        private _labelStep = 0;
        {
            if ((_x select 0) * _pixelsPerMeter >= RULER_MIN_LABEL_SPACING) then {
                _labelStep = _x select 0;
            };
        } forEach RULER_TICKS;

        private _offset = RULER_LABEL_OFFSET / _pixelsPerMeter;
        if (_labelStep > 0) then {
            // Not at the end, the total distance is there
            for "_along" from _labelStep to (_distance - _labelStep / 2) step _labelStep do {
                [
                    [
                        (_start select 0) + _dirX * _along - _dirY * _offset,
                        (_start select 1) + _dirY * _along + _dirX * _offset
                    ],
                    [_along, GVAR(measureDistanceUnit)] call _fnc_formatDistance,
                    RULER_TEXT_COLOR
                ] call _fnc_label;
            };
        };

        // The exact distance and the azimuth at the cursor, by the settings
        private _parts = [];
        if (GVAR(measureShowDistance)) then {
            _parts pushBack ([_distance, GVAR(measureDistanceUnit)] call _fnc_formatDistance);
        };
        if (GVAR(measureShowAzimuth)) then {
            _parts pushBack format ["%1°", [round (_start getDir _cursor) % 360, 3] call CBA_fnc_formatNumber];
        };
        [_parts, RULER_TEXT_COLOR] call _fnc_cursorLabel;
    };

    private _colorClass = ((GVAR(mapTool) get "colors") select (GVAR(mapTool) get "colorIndex")) select 1;
    private _color = [_colorClass] call FUNC(getMarkerColor);

    if (_tool == "direction") exitWith {
        if (_start distance2D _cursor < 1) exitWith {
            GVAR(mapTool) set ["arrow", []];
        };

        // Arrow head lines from the end, in the world, so it scales with the map like the marker
        private _length = _start distance2D _cursor;
        private _dir = _start getDir _cursor;
        private _headLength = _length * ARROW_HEAD_SIZE;
        private _fnc_head = {
            _cursor params ["_cursorX", "_cursorY"];
            [_cursorX + _headLength * sin (_dir + 180 + _this), _cursorY + _headLength * cos (_dir + 180 + _this)]
        };
        private _arrow = [_start, _cursor, (-ARROW_HEAD_ANGLE) call _fnc_head, _cursor, ARROW_HEAD_ANGLE call _fnc_head];
        GVAR(mapTool) set ["arrow", _arrow];

        for "_i" from 0 to (count _arrow - 2) do {
            _mapCtrl drawLine [_arrow select _i, _arrow select (_i + 1), _color];
        };
        [[[_length] call _fnc_formatDistance], _color] call _fnc_cursorLabel;
    };

    // Route: the point under the cursor, snapped to the nearest road segment while the key is held
    if (GVAR(snapToRoadHeld)) then {
        private _radius = ROAD_SNAP_PIXELS / (call _fnc_pixelsPerMeter);
        private _closestDistance = _radius;
        private _snapped = _cursor;
        {
            (getRoadInfo _x) params ["", "", "", "", "", "", ["_begPos", []], ["_endPos", []]];
            if (_begPos isEqualTo [] || {_endPos isEqualTo []}) then {continue};

            // Projection of the cursor to the road segment
            _begPos params ["_begX", "_begY"];
            private _segmentX = (_endPos select 0) - _begX;
            private _segmentY = (_endPos select 1) - _begY;
            private _lengthSqr = _segmentX ^ 2 + _segmentY ^ 2;
            if (_lengthSqr == 0) then {continue};
            _cursor params ["_cursorX", "_cursorY"];
            private _ratio = 0 max ((((_cursorX - _begX) * _segmentX + (_cursorY - _begY) * _segmentY) / _lengthSqr) min 1);
            private _projection = [_begX + _segmentX * _ratio, _begY + _segmentY * _ratio];

            private _distance = _cursor distance2D _projection;
            if (_distance < _closestDistance) then {
                _closestDistance = _distance;
                _snapped = _projection;
            };
        } forEach (_cursor nearRoads _radius);
        _cursor = _snapped;
    };
    GVAR(mapTool) set ["cursor", _cursor];

    for "_i" from 0 to (count _points - 2) do {
        _mapCtrl drawLine [_points select _i, _points select (_i + 1), _color];
    };
    private _cursorColor = +_color;
    _cursorColor set [3, 0.5];
    _mapCtrl drawLine [_points select -1, _cursor, _cursorColor];

    // The route length to the cursor
    private _length = 0;
    for "_i" from 0 to (count _points - 2) do {
        _length = _length + ((_points select _i) distance2D (_points select (_i + 1)));
    };
    _length = _length + ((_points select -1) distance2D _cursor);
    [[[_length] call _fnc_formatDistance], _color] call _fnc_cursorLabel;
};

// Label controls, created when more are needed, hidden when unused
private _display = ctrlParent _mapCtrl;
private _pool = (uiNamespace getVariable [QGVAR(mapToolLabels), []]) select {!isNull _x};
while {count _pool < count _labels} do {
    _pool pushBack (_display ctrlCreate [QGVAR(RscMapToolLabel), -1]);
};
uiNamespace setVariable [QGVAR(mapToolLabels), _pool];

{
    if (_forEachIndex >= count _labels) then {
        _x ctrlShow false;
        continue;
    };

    (_labels select _forEachIndex) params ["_screenX", "_screenY", "_text", "_color", "_align"];
    _x ctrlSetText _text;
    _x ctrlSetTextColor _color;
    private _width = ctrlTextWidth _x + 4 * pixelW;
    private _ctrlX = [_screenX - _width / 2, _screenX - _width] select (_align == "right");
    _x ctrlSetPosition [_ctrlX, _screenY - _textSize / 2, _width, _textSize];
    _x ctrlCommit 0;
    _x ctrlShow true;
} forEach _pool;

nil
