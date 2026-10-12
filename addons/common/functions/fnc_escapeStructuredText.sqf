#include "..\script_component.hpp"
/*
 * Author: Smith
 * Escapes the text to be inserted into structured text or a diary record
 *
 * Arguments:
 * 0: Text <STRING>
 *
 * Return Value:
 * Escaped text <STRING>
 *
 * Example:
 * ["<b>&"] call maptac_common_fnc_escapeStructuredText
 *
 * Public: No
 */

params ["_text"];

[[[_text, "&", "&amp;"] call CBA_fnc_replace, "<", "&lt;"] call CBA_fnc_replace, ">", "&gt;"] call CBA_fnc_replace
