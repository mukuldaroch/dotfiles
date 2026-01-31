const char *colorname[] = {

  /* 8 normal colors */
  [0] = "#11130f", /* black   */
  [1] = "#0974B2", /* red     */
  [2] = "#528BA3", /* green   */
  [3] = "#168FCF", /* yellow  */
  [4] = "#61A6D8", /* blue    */
  [5] = "#D1B099", /* magenta */
  [6] = "#CCC2B8", /* cyan    */
  [7] = "#c0d2e2", /* white   */

  /* 8 bright colors */
  [8]  = "#86939e",  /* black   */
  [9]  = "#0974B2",  /* red     */
  [10] = "#528BA3", /* green   */
  [11] = "#168FCF", /* yellow  */
  [12] = "#61A6D8", /* blue    */
  [13] = "#D1B099", /* magenta */
  [14] = "#CCC2B8", /* cyan    */
  [15] = "#c0d2e2", /* white   */

  /* special colors */
  [256] = "#11130f", /* background */
  [257] = "#c0d2e2", /* foreground */
  [258] = "#c0d2e2",     /* cursor */
};

/* Default colors (colorname index)
 * foreground, background, cursor */
 unsigned int defaultbg = 0;
 unsigned int defaultfg = 257;
 unsigned int defaultcs = 258;
 unsigned int defaultrcs= 258;
