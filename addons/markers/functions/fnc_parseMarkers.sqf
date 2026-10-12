#include "..\script_component.hpp"
/*
 * Author: Smith
 * Parses the copied markers text (see fnc_openMarkersTransfer). The text is parsed as a simple array,
 * no code is executed. Invalid markers are skipped.
 *
 * Arguments:
 * 0: Copied markers text <STRING>
 *
 * Return Value:
 * 0: Markers, [type, color, text, position, line points] <ARRAY>
 * 1: Localized error, "" when parsed <STRING>
 *
 * Example:
 * [_text] call maptac_markers_fnc_parseMarkers
 *
 * Public: No
 */

params [["_text", "", [""]]];

_text = [_text] call CBA_fnc_trim;
if (_text == "") exitWith {[[], ""]};
// parseSimpleArray logs errors on non-array strings
if (_text select [0, 1] != "[") exitWith {[[], LLSTRING(TransferInvalid)]};

private _markers = (parseSimpleArray _text) select {
    _x isEqualType []
    && {_x isEqualTypeParams ["", "", "", [], []]}
    && {(_x select 3) isEqualTypeParams [0, 0]}
    && {(_x select 4) isEqualTo [] || {(_x select 4) isEqualTypeAll 0}}
};

if (_markers isEqualTo []) exitWith {[[], LLSTRING(TransferInvalid)]};

[_markers select [0, MAX_TRANSFER_MARKERS], ""]
