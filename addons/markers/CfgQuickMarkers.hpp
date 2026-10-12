// Quick marker selection in the marker placement dialog: inner ring - categories, outer rings - markers of the category.
// icon - the category's own marker, selected by clicking the category (not repeated in the outer rings),
// its name is the category name.
// "%1" is replaced with the side prefix of the selected color (b_, o_, n_). Max 10 categories and 10 markers per category.
class GVAR(QuickMarkerCategories) {
    class Infantry {
        icon = "%1inf";
        markers[] = {"%1motor_inf", "%1mech_inf", "%1recon", "%1hq", "%1mortar", "%1unknown"};
    };
    class Vehicles {
        icon = "%1armor";
        markers[] = {"%1mech_inf", "%1motor_inf", "%1art", "%1antiair", "%1naval", "%1maint", "%1support", "%1service"};
    };
    class Aviation {
        icon = "%1air";
        markers[] = {"%1plane", "%1uav"};
    };
    class Requests {
        icon = "%1med";
        markers[] = {"%1support", "%1maint", "hd_pickup", "hd_join", "hd_destroy", "hd_warning"};
    };
    class Other {
        icon = "hd_dot";
        markers[] = {"hd_objective", "hd_flag", "hd_ambush", "hd_destroy", "hd_start", "hd_end", "hd_warning", "hd_unknown"};
    };
};

// Colors of the marker placement dialog. Selecting a color with a side prefix switches the markers to that side.
class GVAR(QuickMarkerColors) {
    class Friendly {
        displayName = CSTRING(ColorFriendly);
        color = "ColorBlue";
        prefix = "b_";
    };
    class Enemy {
        displayName = CSTRING(ColorEnemy);
        color = "ColorRed";
        prefix = "o_";
    };
    class Independent {
        displayName = CSTRING(ColorIndependent);
        color = "ColorGreen";
        prefix = "n_";
    };
    class Yellow {
        displayName = CSTRING(ColorYellow);
        color = "ColorYellow";
        prefix = "";
    };
    class White {
        displayName = CSTRING(ColorWhite);
        color = "ColorWhite";
        prefix = "";
    };
    class Black {
        displayName = CSTRING(ColorBlack);
        color = "ColorBlack";
        prefix = "";
    };
};

// Full localized names of the markers, used instead of the short vanilla ones.
// Side markers are named without the side prefix (inf for b_inf, o_inf, n_inf).
class GVAR(MarkerNames) {
    // Lines drawn with the map tools
    GVAR(route) = CSTRING(Marker_route);
    GVAR(direction) = CSTRING(Marker_direction);
    inf = CSTRING(Marker_inf);
    motor_inf = CSTRING(Marker_motor_inf);
    mech_inf = CSTRING(Marker_mech_inf);
    recon = CSTRING(Marker_recon);
    hq = CSTRING(Marker_hq);
    mortar = CSTRING(Marker_mortar);
    unknown = CSTRING(Marker_unknown);
    armor = CSTRING(Marker_armor);
    art = CSTRING(Marker_art);
    antiair = CSTRING(Marker_antiair);
    naval = CSTRING(Marker_naval);
    maint = CSTRING(Marker_maint);
    support = CSTRING(Marker_support);
    service = CSTRING(Marker_service);
    air = CSTRING(Marker_air);
    plane = CSTRING(Marker_plane);
    uav = CSTRING(Marker_uav);
    med = CSTRING(Marker_med);
    hd_dot = CSTRING(Marker_hd_dot);
    hd_objective = CSTRING(Marker_hd_objective);
    hd_flag = CSTRING(Marker_hd_flag);
    hd_ambush = CSTRING(Marker_hd_ambush);
    hd_destroy = CSTRING(Marker_hd_destroy);
    hd_start = CSTRING(Marker_hd_start);
    hd_end = CSTRING(Marker_hd_end);
    hd_warning = CSTRING(Marker_hd_warning);
    hd_unknown = CSTRING(Marker_hd_unknown);
    hd_pickup = CSTRING(Marker_hd_pickup);
    hd_join = CSTRING(Marker_hd_join);
};
