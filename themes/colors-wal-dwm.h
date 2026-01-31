static const char norm_fg[] = "#c0d2e2";
static const char norm_bg[] = "#11130f";
static const char norm_border[] = "#86939e";

static const char sel_fg[] = "#c0d2e2";
static const char sel_bg[] = "#528BA3";
static const char sel_border[] = "#c0d2e2";

static const char urg_fg[] = "#c0d2e2";
static const char urg_bg[] = "#0974B2";
static const char urg_border[] = "#0974B2";

static const char *colors[][3]      = {
    /*               fg           bg         border                         */
    [SchemeNorm] = { norm_fg,     norm_bg,   norm_border }, // unfocused wins
    [SchemeSel]  = { sel_fg,      sel_bg,    sel_border },  // the focused win
    [SchemeUrg] =  { urg_fg,      urg_bg,    urg_border },
};
