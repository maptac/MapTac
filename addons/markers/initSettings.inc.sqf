private _category = [ELSTRING(main,Category), LSTRING(Category)];

[
    QGVAR(replaceVanillaDialog), "CHECKBOX",
    [LSTRING(ReplaceVanillaDialog), LSTRING(ReplaceVanillaDialog_Description)],
    _category,
    true,
    0
] call CBA_fnc_addSetting;

// The map buttons switch the label parts until the defaults are changed again
private _fnc_applyLabelDefaults = {
    GVAR(labelShown) = [];
    {
        GVAR(labelShown) pushBack (missionNamespace getVariable [
            format ["%1%2", QGVAR(showLabel), _x],
            LABEL_PART_DEFAULTS select _forEachIndex
        ]);
    } forEach LABEL_PART_NAMES;
    call FUNC(updateMarkerLabels);
};

{
    _x params ["_part", "_title"];
    [
        format ["%1%2", QGVAR(showLabel), LABEL_PART_NAMES select _part], "CHECKBOX",
        [_title, LSTRING(ShowLabel_Description)],
        _category,
        LABEL_PART_DEFAULTS select _part,
        0,
        _fnc_applyLabelDefaults
    ] call CBA_fnc_addSetting;
} forEach [
    [LABEL_PART_AUTHOR, LSTRING(ShowLabelAuthor)],
    [LABEL_PART_GROUP, LSTRING(ShowLabelGroup)],
    [LABEL_PART_TEXT, LSTRING(ShowLabelText)]
];

[
    QGVAR(callsignFormat), "LIST",
    [LSTRING(CallsignFormat), LSTRING(CallsignFormat_Description)],
    _category,
    [
        [CALLSIGN_FULL, CALLSIGN_DASH, CALLSIGN_SLASH, CALLSIGN_COMPACT],
        [LSTRING(CallsignFormat_Full), LSTRING(CallsignFormat_Dash), LSTRING(CallsignFormat_Slash), LSTRING(CallsignFormat_Compact)],
        1
    ],
    0,
    {call FUNC(updateMarkerLabels)}
] call CBA_fnc_addSetting;

[
    QGVAR(enableMeasure), "CHECKBOX",
    [LSTRING(EnableMeasure), LSTRING(EnableMeasure_Description)],
    _category,
    true,
    1
] call CBA_fnc_addSetting;

[
    QGVAR(measureShowDistance), "CHECKBOX",
    [LSTRING(MeasureShowDistance), LSTRING(MeasureShowDistance_Description)],
    _category,
    true,
    1
] call CBA_fnc_addSetting;

[
    QGVAR(measureShowAzimuth), "CHECKBOX",
    [LSTRING(MeasureShowAzimuth), LSTRING(MeasureShowAzimuth_Description)],
    _category,
    true,
    1
] call CBA_fnc_addSetting;

[
    QGVAR(measureDistanceUnit), "LIST",
    [LSTRING(MeasureDistanceUnit), LSTRING(MeasureDistanceUnit_Description)],
    _category,
    [
        [DISTANCE_UNIT_METERS, DISTANCE_UNIT_KILOMETERS, DISTANCE_UNIT_DYNAMIC],
        [LSTRING(DistanceUnit_Meters), LSTRING(DistanceUnit_Kilometers), LSTRING(DistanceUnit_Dynamic)],
        0
    ],
    0
] call CBA_fnc_addSetting;

[
    QGVAR(enableRoute), "CHECKBOX",
    [LSTRING(EnableRoute), LSTRING(EnableRoute_Description)],
    _category,
    true,
    1
] call CBA_fnc_addSetting;

private _channelCategory = [ELSTRING(main,Category), LSTRING(CategoryChannels)];

{
    private _channelName = ([_forEachIndex] call FUNC(getChannelInfo)) select 0;

    // Vehicle and direct channels need no devices, they are only switched on or off
    private _modes = [
        [
            CHANNEL_MODE_DISABLED, CHANNEL_MODE_ENABLED, CHANNEL_MODE_BRIEFING, CHANNEL_MODE_RADIO,
            CHANNEL_MODE_GPS, CHANNEL_MODE_LONG_RANGE, CHANNEL_MODE_GPS_OR_LONG_RANGE
        ],
        [
            LSTRING(ChannelMode_Disabled), LSTRING(ChannelMode_Enabled), LSTRING(ChannelMode_Briefing), LSTRING(ChannelMode_Radio),
            LSTRING(ChannelMode_GPS), LSTRING(ChannelMode_LongRange), LSTRING(ChannelMode_GPSOrLongRange)
        ],
        1
    ];
    if (_forEachIndex in [4, 5]) then {
        _modes = [[CHANNEL_MODE_DISABLED, CHANNEL_MODE_ENABLED], [LSTRING(ChannelMode_Disabled), LSTRING(ChannelMode_Enabled)], 1];
    };

    [
        format ["%1%2", QGVAR(channelMode), _x], "LIST",
        [format [LLSTRING(ChannelMode), _channelName], LLSTRING(ChannelMode_Description)],
        _channelCategory,
        _modes,
        1,
        {call FUNC(updateChannelAccess)}
    ] call CBA_fnc_addSetting;
} forEach CHANNEL_SETTING_NAMES;

[
    QGVAR(directChannelRange), "SLIDER",
    [LSTRING(DirectChannelRange), LSTRING(DirectChannelRange_Description)],
    _channelCategory,
    [1, 100, 10, 0],
    1
] call CBA_fnc_addSetting;

// Channels recorded by replay mods, read by their compat addons (e.g. compat_ocap)
private _replayCategory = [ELSTRING(main,Category), LSTRING(CategoryReplay)];

{
    private _channelName = ([_forEachIndex] call FUNC(getChannelInfo)) select 0;

    [
        format ["%1%2", QGVAR(recordChannel), _x], "CHECKBOX",
        [format [LLSTRING(RecordChannel), _channelName], LLSTRING(RecordChannel_Description)],
        _replayCategory,
        true,
        1
    ] call CBA_fnc_addSetting;
} forEach CHANNEL_SETTING_NAMES;

[
    QGVAR(recordExtraChannels), "CHECKBOX",
    [LSTRING(RecordExtraChannels), LSTRING(RecordChannel_Description)],
    _replayCategory,
    true,
    1
] call CBA_fnc_addSetting;
