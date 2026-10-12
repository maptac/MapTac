private _category = [ELSTRING(main,Category), LSTRING(Category)];

[
    QGVAR(limitRange), "CHECKBOX",
    [LSTRING(LimitRange), LSTRING(LimitRange_Description)],
    _category,
    false,
    1
] call CBA_fnc_addSetting;

[
    QGVAR(recordFrequencies), "LIST",
    [LSTRING(RecordFrequencies), LSTRING(RecordFrequencies_Description)],
    _category,
    [
        [RECORD_ALL, RECORD_LONG_RANGE_PLACED, RECORD_LONG_RANGE_BAND],
        [LSTRING(RecordFrequencies_All), LSTRING(RecordFrequencies_LongRangePlaced), LSTRING(RecordFrequencies_LongRangeBand)],
        0
    ],
    1
] call CBA_fnc_addSetting;
