#if ((__RENDERER__ >= 0xB000 && __RENDERER__ < 0x10000) \
  || __RENDERER__ >= 0x20000)


// TODO:
// - add macros for the new text drawing


#include "lilium__include\hdr_analysis.fxh"
#include "lilium__include\draw_font.fxh"
#include "lilium__include\draw_text_fix.fxh"

#undef FONT_BRIGHTNESS

//#define _DEBUG
//#define _TESTY

#ifndef ENABLE_CLL_FEATURES
  #define ENABLE_CLL_FEATURES YES
#endif

#ifndef ENABLE_CIE_FEATURES
  #define ENABLE_CIE_FEATURES YES
#endif

#ifndef ENABLE_CSP_FEATURES
  #define ENABLE_CSP_FEATURES YES
#endif


#if (ENABLE_CLL_FEATURES == YES \
  || ENABLE_CSP_FEATURES == YES)
uniform float2 MOUSE_POSITION
<
  source = "mousepoint";
>;
#else
  static const float2 MOUSE_POSITION = float2(0.f, 0.f);
#endif

#if (ENABLE_CLL_FEATURES == YES)
uniform float2 NIT_PINGPONG0
<
  source    = "pingpong";
  min       = 0.f;
  max       = 1.75f;
  step      = 1.f;
  smoothing = 0.f;
>;

uniform float2 NIT_PINGPONG1
<
  source    = "pingpong";
  min       =  0.f;
  max       =  3.f;
  step      =  1.f;
  smoothing =  0.f;
>;

uniform float2 NIT_PINGPONG2
<
  source    = "pingpong";
  min       = 0.f;
  max       = 1.f;
  step      = 3.f;
  smoothing = 0.f;
>;
#else
  static const float2 NIT_PINGPONG0 = float2(0.f, 0.f);
  static const float2 NIT_PINGPONG1 = float2(0.f, 0.f);
  static const float2 NIT_PINGPONG2 = float2(0.f, 0.f);
#endif


#define CSP_SRGB_TEXT  "sRGB (sRGB transfer function / gamma 2.2 + BT.709 primaries)"
#define CSP_SCRGB_TEXT "scRGB (linear + BT.709 primaries)"
#define CSP_HDR10_TEXT "HDR10 (PQ + BT.2020 primaries)"
#define CSP_HLG_TEXT   "HLG (HLG + BT.2020 primaries)"

#if (BUFFER_COLOR_BIT_DEPTH == 8)
  #define BACK_BUFFER_FORMAT_TEXT "RGBA8_UNORM or BGRA8_UNORM"
#elif (BUFFER_COLOR_BIT_DEPTH == 10)
  // d3d11 and d3d12 only allow rgb10a2 to be used for HDR10
  #if (__RENDERER__ >= 0xB000 && __RENDERER__ < 0x10000)
    #define BACK_BUFFER_FORMAT_TEXT "RGB10A2_UNORM"
  #else
    #define BACK_BUFFER_FORMAT_TEXT "RGB10A2_UNORM or BGR10A2_UNORM"
  #endif
#elif (BUFFER_COLOR_BIT_DEPTH == 16)
  #define BACK_BUFFER_FORMAT_TEXT "RGBA16_FLOAT"
#else
  #define BACK_BUFFER_FORMAT_TEXT "unknown"
#endif


#define CSP_UNSET_TEXT "colour space unset! likely "

#if (BUFFER_COLOR_SPACE == CSP_SCRGB)
  #define BACK_BUFFER_COLOUR_SPACE_TEXT CSP_SCRGB_TEXT
#elif (BUFFER_COLOR_SPACE == CSP_HDR10)
  #define BACK_BUFFER_COLOUR_SPACE_TEXT CSP_HDR10_TEXT
#elif (BUFFER_COLOR_SPACE == CSP_HLG)
  #define BACK_BUFFER_COLOUR_SPACE_TEXT CSP_HLG_TEXT
#elif (BUFFER_COLOR_SPACE == CSP_SRGB \
    && defined(IS_POSSIBLE_SCRGB_BIT_DEPTH))
  #define BACK_BUFFER_COLOUR_SPACE_TEXT CSP_UNSET_TEXT CSP_SCRGB_TEXT
#elif (BUFFER_COLOR_SPACE == CSP_UNKNOWN \
    && defined(IS_POSSIBLE_SCRGB_BIT_DEPTH))
  #define BACK_BUFFER_COLOUR_SPACE_TEXT CSP_UNSET_TEXT CSP_SCRGB_TEXT
#elif (BUFFER_COLOR_SPACE == CSP_UNKNOWN \
    && defined(IS_POSSIBLE_HDR10_BIT_DEPTH))
  #define BACK_BUFFER_COLOUR_SPACE_TEXT CSP_UNSET_TEXT CSP_HDR10_TEXT
#elif (BUFFER_COLOR_SPACE == CSP_SRGB)
  #define BACK_BUFFER_COLOUR_SPACE_TEXT CSP_SRGB_TEXT
#else
  #define BACK_BUFFER_COLOUR_SPACE_TEXT "unknown"
#endif


#if (CSP_OVERRIDE == CSP_SRGB)
  #define CSP_OVERRIDE_TEXT CSP_SRGB_TEXT
#elif (CSP_OVERRIDE == CSP_SCRGB)
  #define CSP_OVERRIDE_TEXT CSP_SCRGB_TEXT
#elif (CSP_OVERRIDE == CSP_HDR10)
  #define CSP_OVERRIDE_TEXT CSP_HDR10_TEXT
#elif (CSP_OVERRIDE == CSP_HLG)
  #define CSP_OVERRIDE_TEXT CSP_HLG_TEXT
#else
  #define CSP_OVERRIDE_TEXT "unset"
#endif


#if (ACTUAL_COLOUR_SPACE == CSP_SRGB)
  #define ACTUAL_CSP_TEXT CSP_SRGB_TEXT
#elif (ACTUAL_COLOUR_SPACE == CSP_SCRGB)
  #define ACTUAL_CSP_TEXT CSP_SCRGB_TEXT
#elif (ACTUAL_COLOUR_SPACE == CSP_HDR10)
  #define ACTUAL_CSP_TEXT CSP_HDR10_TEXT
#elif (ACTUAL_COLOUR_SPACE == CSP_HLG)
  #define ACTUAL_CSP_TEXT CSP_HLG_TEXT
#else
  #define ACTUAL_CSP_TEXT "unknown"
#endif

#define INFO_TEXT \
       "detected back buffer format:       " BACK_BUFFER_FORMAT_TEXT           \
  "\n" "detected back buffer color space:  " BACK_BUFFER_COLOUR_SPACE_TEXT     \
  "\n" "colour space overwritten to:       " CSP_OVERRIDE_TEXT                 \
  "\n" "colour space in use by the shader: " ACTUAL_CSP_TEXT                   \
  "\n"                                                                         \
  "\n" "Use the \"Preprocessor definition\" 'CSP_OVERRIDE' below to override " \
  "\n" "the colour space in case the auto detection doesn't work."             \
  "\n" "Possible values are:"                                                  \
  "\n" "- 'CSP_HDR10'"                                                         \
  "\n" "- 'CSP_SCRGB'"                                                         \
  "\n" "Hit ENTER to apply."


uniform int GLOBAL_INFO
<
  ui_category = "info";
  ui_label    = " ";
  ui_type     = "radio";
  ui_text     = INFO_TEXT;
>;

//uniform float FONT_SIZE
//<
//  ui_category = "global";
//  ui_label    = "font size";
//  ui_type     = "slider";
//  ui_min      = 30.f;
//  ui_max      = 40.f;
//  ui_step     = 1.f;
//> = 30;

uniform uint FONT_SIZE
<
  ui_category = "global";
  ui_label    = "font size";
  ui_type     = "combo";
  ui_items    = "32\0"
                "34\0"
                "36\0"
                "38\0"
                "40\0"
                "42\0"
                "44\0"
                "46\0"
                "48\0";
> = 0;

uniform float FONT_BRIGHTNESS
<
  ui_category = "global";
  ui_label    = "font brightness";
  ui_type     = "slider";
  ui_units    = " nits";
  ui_min      = 10.f;
  ui_max      = 250.f;
  ui_step     = 0.5f;
> = 140.f;

#define TEXT_POSITION_TOP_LEFT  0
#define TEXT_POSITION_TOP_RIGHT 1

uniform uint TEXT_POSITION
<
  ui_category = "global";
  ui_label    = "text position";
  ui_type     = "combo";
  ui_items    = "top left\0"
                "top right\0";
> = 0;

// CLL
#if (ENABLE_CLL_FEATURES == YES)
uniform bool SHOW_CLL_VALUES
<
  ui_category = "Content Light Level analysis";
  ui_label    = "show CLL values";
  ui_tooltip  = "Shows max/avg/min Content Light Levels.";
> = true;

uniform bool SHOW_CLL_FROM_CURSOR
<
  ui_category = "Content Light Level analysis";
  ui_label    = "show CLL value from cursor position";
> = true;

uniform bool CLL_ROUNDING_WORKAROUND
<
  ui_category = "Content Light Level analysis";
  ui_label    = "work around rounding errors for displaying maxCLL";
  ui_tooltip  = "A value of 0.005 is added to the maxCLL value.";
> = false;
#else
  static const bool SHOW_CLL_VALUES         = false;
  static const bool SHOW_CLL_FROM_CURSOR    = false;
  static const bool CLL_ROUNDING_WORKAROUND = false;
#endif

// CIE
#if (ENABLE_CIE_FEATURES == YES)
uniform bool SHOW_CIE
<
  ui_category = "CIE diagram visualisation";
  ui_label    = "show CIE diagram";
  ui_tooltip  = "Change diagram type via the \"Preprocessor definition\" 'CIE_DIAGRAM' below."
           "\n" "Possible values are:"
           "\n" "- 'CIE_1931' for the CIE 1931 xy diagram"
           "\n" "- 'CIE_1976' for the CIE 1976 UCS u'v' diagram";
> = true;

#if (CIE_DIAGRAM == CIE_1931)
  static const uint CIE_BG_X = CIE_1931_BG_X;
  static const uint CIE_BG_Y = CIE_1931_BG_Y;
#else
  static const uint CIE_BG_X = CIE_1976_BG_X;
  static const uint CIE_BG_Y = CIE_1976_BG_Y;
#endif

uniform float CIE_DIAGRAM_BRIGHTNESS
<
  ui_category = "CIE diagram visualisation";
  ui_label    = "CIE diagram brightness";
  ui_type     = "slider";
  ui_units    = " nits";
  ui_min      = 10.f;
  ui_max      = 250.f;
  ui_step     = 0.5f;
> = 80.f;

uniform float CIE_DIAGRAM_SIZE
<
  ui_category = "CIE diagram visualisation";
  ui_label    = "CIE diagram size (in %)";
  ui_type     = "slider";
  ui_units    = "%%";
  ui_min      = 50.f;
  ui_max      = 100.f;
  ui_step     = 0.1f;
> = 100.f;
#else
  static const bool  SHOW_CIE               = false;
  static const float CIE_DIAGRAM_BRIGHTNESS = 0.f;
  static const float CIE_DIAGRAM_SIZE       = 0.f;
#endif

// Texture_CSPs
#if (ENABLE_CSP_FEATURES == YES)
uniform bool SHOW_CSPS
<
  ui_category = "Colour Space analysis";
  ui_label    = "show colour spaces used";
  ui_tooltip  = "in %";
> = true;

uniform bool SHOW_CSP_MAP
<
  ui_category = "Colour Space analysis";
  ui_label    = "show colour space map";
  ui_tooltip  = "        colours:"
           "\n" "black and white: BT.709"
           "\n" "           teal: DCI-P3"
           "\n" "         yellow: BT.2020"
           "\n" "           blue: AP1"
           "\n" "            red: AP0"
           "\n" "           pink: invalid";
> = false;

uniform bool SHOW_CSP_FROM_CURSOR
<
  ui_category = "Colour Space analysis";
  ui_label    = "show colour space from cursor position";
> = true;
#else
  static const bool SHOW_CSPS            = false;
  static const bool SHOW_CSP_MAP         = false;
  static const bool SHOW_CSP_FROM_CURSOR = false;
#endif

// heatmap
#if (ENABLE_CLL_FEATURES == YES)
uniform bool SHOW_HEATMAP
<
  ui_category = "Heatmap visualisation";
  ui_label    = "show heatmap";
  ui_tooltip  = "         colours:   10000 nits:   1000 nits:"
           "\n" " black and white:       0-  100       0- 100"
           "\n" "  teal to green:      100-  203     100- 203"
           "\n" " green to yellow:     203-  400     203- 400"
           "\n" "yellow to red:        400- 1000     400- 600"
           "\n" "   red to pink:      1000- 4000     600- 800"
           "\n" "  pink to blue:      4000-10000     800-1000";
> = false;

uniform uint HEATMAP_CUTOFF_POINT
<
  ui_category = "Heatmap visualisation";
  ui_label    = "heatmap cutoff point";
  ui_type     = "combo";
  ui_items    = "10000 nits\0"
                " 1000 nits\0";
> = 0;

uniform float HEATMAP_BRIGHTNESS
<
  ui_category = "Heatmap visualisation";
  ui_label    = "heatmap brightness (in nits)";
  ui_type     = "slider";
  ui_units    = " nits";
  ui_min      = 10.f;
  ui_max      = 250.f;
  ui_step     = 0.5f;
> = 80.f;

uniform bool SHOW_BRIGHTNESS_HISTOGRAM
<
  ui_category = "Brightness histogram";
  ui_label    = "show brightness histogram";
  ui_tooltip  = "Brightness histogram paid for by Aemony.";
> = true;

uniform float BRIGHTNESS_HISTOGRAM_BRIGHTNESS
<
  ui_category = "Brightness histogram";
  ui_label    = "brightness histogram brightness (in nits)";
  ui_type     = "slider";
  ui_units    = " nits";
  ui_min      = 10.f;
  ui_max      = 250.f;
  ui_step     = 0.5f;
> = 80.f;

uniform float BRIGHTNESS_HISTOGRAM_SIZE
<
  ui_category = "Brightness histogram";
  ui_label    = "brightness histogram size (in %)";
  ui_type     = "slider";
  ui_units    = "%%";
  ui_min      = 50.f;
  ui_max      = 100.f;
  ui_step     = 0.1f;
> = 70.f;

// highlight a certain nit range
uniform bool HIGHLIGHT_NIT_RANGE
<
  ui_category = "Highlight brightness range visualisation";
  ui_label    = "enable highlighting brightness levels in a certain range";
  ui_tooltip  = "in nits";
> = false;

uniform float HIGHLIGHT_NIT_RANGE_START_POINT
<
  ui_category = "Highlight brightness range visualisation";
  ui_label    = "range starting point (in nits)";
  ui_type     = "drag";
  ui_units    = " nits";
  ui_min      = 0.f;
  ui_max      = 10000.f;
  ui_step     = 0.0000001f;
> = 0.f;

uniform float HIGHLIGHT_NIT_RANGE_END_POINT
<
  ui_category = "Highlight brightness range visualisation";
  ui_label    = "range end point (in nits)";
  ui_type     = "drag";
  ui_units    = " nits";
  ui_min      = 0.f;
  ui_max      = 10000.f;
  ui_step     = 0.0000001f;
> = 0.f;

uniform float HIGHLIGHT_NIT_RANGE_BRIGHTNESS
<
  ui_category = "Highlight brightness range visualisation";
  ui_label    = "range brightness (in nits)";
  ui_type     = "slider";
  ui_units    = " nits";
  ui_min      = 10.f;
  ui_max      = 250.f;
  ui_step     = 0.5f;
> = 80.f;

// draw pixels as black depending on their nits
uniform bool DRAW_ABOVE_NITS_AS_BLACK
<
  ui_category = "Draw certain brightness levels as black";
  ui_label    = "enable drawing above this brightness as black";
> = false;

uniform float ABOVE_NITS_AS_BLACK
<
  ui_category = "Draw certain brightness levels as black";
  ui_label    = "draw above this brightness as black (in nits)";
  ui_type     = "drag";
  ui_units    = " nits";
  ui_min      = 0.f;
  ui_max      = 10000.f;
  ui_step     = 0.0000001f;
> = 10000.f;

uniform bool DRAW_BELOW_NITS_AS_BLACK
<
  ui_category = "Draw certain brightness levels as black";
  ui_label    = "enable drawing below this brightness as black";
> = false;

uniform float BELOW_NITS_AS_BLACK
<
  ui_category = "Draw certain brightness levels as black";
  ui_label    = "draw below this brightness as black (in nits)";
  ui_type     = "drag";
  ui_units    = " nits";
  ui_min      = 0.f;
  ui_max      = 10000.f;
  ui_step     = 1.f;
> = 0.f;
#else
  static const bool  SHOW_HEATMAP                    = false;
  static const uint  HEATMAP_CUTOFF_POINT            = 0;
  static const float HEATMAP_BRIGHTNESS              = 0.f;
  static const bool  SHOW_BRIGHTNESS_HISTOGRAM       = false;
  static const float BRIGHTNESS_HISTOGRAM_BRIGHTNESS = 0.f;
  static const float BRIGHTNESS_HISTOGRAM_SIZE       = 0.f;
  static const bool  HIGHLIGHT_NIT_RANGE             = false;
  static const float HIGHLIGHT_NIT_RANGE_START_POINT = 0.f;
  static const float HIGHLIGHT_NIT_RANGE_END_POINT   = 0.f;
  static const float HIGHLIGHT_NIT_RANGE_BRIGHTNESS  = 0.f;
  static const bool  DRAW_ABOVE_NITS_AS_BLACK        = false;
  static const float ABOVE_NITS_AS_BLACK             = 0.f;
  static const bool  DRAW_BELOW_NITS_AS_BLACK        = false;
  static const float BELOW_NITS_AS_BLACK             = 0.f;
#endif

#ifdef _TESTY
uniform bool ENABLE_TEST_THINGY
<
  ui_category = "TESTY";
  ui_label    = "enable test thingy";
> = false;

uniform float TEST_THINGY
<
  ui_category = "TESTY";
  ui_label    = "test thingy";
  ui_type     = "drag";
  ui_min      = -125.f;
  ui_max      = 125.f;
  ui_step     = 0.000000001f;
> = 0.f;
#endif


//void draw_maxCLL(float4 position : POSITION, float2 txcoord : TEXCOORD) : COLOR
//void draw_maxCLL(float4 VPos : SV_Position, float2 TexCoord : TEXCOORD, out float4 fragment : SV_Target0)
//{
//  const uint int_maxCLL = int(round(maxCLL));
//  uint digit1;
//  uint digit2;
//  uint digit3;
//  uint digit4;
//  uint digit5;
//  
//  if (maxCLL < 10)
//  {
//    digit1 = 0;
//    digit2 = 0;
//    digit3 = 0;
//    digit4 = 0;
//    digit5 = int_maxCLL;
//  }
//  else if (maxCLL < 100)
//  {
//    digit1 = 0;
//    digit2 = 0;
//    digit3 = 0;
//    digit4 = int_maxCLL / 10;
//    digit5 = int_maxCLL % 10;
//  }
//  else if (maxCLL < 1000)
//  {
//    digit1 = 0;
//    digit2 = 0;
//    digit3 = int_maxCLL / 100;
//    digit4 = (int_maxCLL % 100) / 10;
//    digit5 = (int_maxCLL % 10);
//  }
//  else if (maxCLL < 10000)
//  {
//    digit1 = 0;
//    digit2 = int_maxCLL / 1000;
//    digit3 = (int_maxCLL % 1000) / 100;
//    digit4 = (int_maxCLL % 100) / 10;
//    digit5 = (int_maxCLL % 10);
//  }
//  else
//  {
//    digit1 = int_maxCLL / 10000;
//    digit2 = (int_maxCLL % 10000) / 1000;
//    digit3 = (int_maxCLL % 1000) / 100;
//    digit4 = (int_maxCLL % 100) / 10;
//    digit5 = (int_maxCLL % 10);
//  }

  //res += tex2D(samplerText, (frac(uv) + float2(index % 14.0, trunc(index / 14.0))) /
  //            float2(_DRAWTEXT_GRID_X, _DRAWTEXT_GRID_Y)).x;

//  float4 hud = tex2D(samplerNumbers, TexCoord);
//  fragment = lerp(tex2Dfetch(ReShade::BackBuffer, TexCoord), hud, 1.f);
//
//}

#ifdef _TESTY
void Testy(
      float4 VPos     : SV_Position,
      float2 TexCoord : TEXCOORD,
  out float4 Output   : SV_Target0)
{
  if(ENABLE_TEST_THINGY == true)
  {
    const float xTest = TEST_THINGY;
    const float xxx = BUFFER_WIDTH  / 2.f - 100.f;
    const float xxe = (BUFFER_WIDTH  - xxx);
    const float yyy = BUFFER_HEIGHT / 2.f - 100.f;
    const float yye = (BUFFER_HEIGHT - yyy);
    if (TexCoord.x > xxx / BUFFER_WIDTH
     && TexCoord.x < xxe / BUFFER_WIDTH
     && TexCoord.y > yyy / BUFFER_HEIGHT
     && TexCoord.y < yye / BUFFER_HEIGHT)
      Output = float4(xTest, xTest, xTest, 1.f);
    else
      Output = float4(0.f, 0.f, 0.f, 0.f);
  }
  else
    Output = float4(tex2D(ReShade::BackBuffer, TexCoord).rgb, 1.f);
}
#endif

///text stuff

// colour space not supported
static const uint text_Error[26] = { __C, __O, __L, __O, __U, __R, __Space, __S, __P, __A, __C, __E, __Space,
                                     __N, __O, __T, __Space,
                                     __S, __U, __P, __P, __O, __R, __T, __E, __D};


uint2 GetCharSize()
{
  switch(FONT_SIZE)
  {
    case 8:
    {
      return FONT_ATLAS_SIZE_48_CHAR_DIM;
    }
    case 7:
    {
      return FONT_ATLAS_SIZE_46_CHAR_DIM;
    }
    case 6:
    {
      return FONT_ATLAS_SIZE_44_CHAR_DIM;
    }
    case 5:
    {
      return FONT_ATLAS_SIZE_42_CHAR_DIM;
    }
    case 4:
    {
      return FONT_ATLAS_SIZE_40_CHAR_DIM;
    }
    case 3:
    {
      return FONT_ATLAS_SIZE_38_CHAR_DIM;
    }
    case 2:
    {
      return FONT_ATLAS_SIZE_36_CHAR_DIM;
    }
    case 1:
    {
      return FONT_ATLAS_SIZE_34_CHAR_DIM;
    }
    default:
    {
      return FONT_ATLAS_SIZE_32_CHAR_DIM;
    }
  }
}


static const int ShowCllValuesLineCount     = 3;
static const int ShowCllFromCursorLineCount = 6;

#if (ACTUAL_COLOUR_SPACE == CSP_HDR10 \
  || ACTUAL_COLOUR_SPACE == CSP_HLG)

  static const int ShowCspsLineCount = 3;

#else

  static const int ShowCspsLineCount = 6;

#endif


void PrepareOverlay(uint3 ID : SV_DispatchThreadID)
{
  float drawCllLast        = tex2Dfetch(Storage_Consolidated, COORDS_CHECK_OVERLAY_REDRAW0).r;
  float drawcursorCllLast  = tex2Dfetch(Storage_Consolidated, COORDS_CHECK_OVERLAY_REDRAW1).r;
  float drawCspsLast       = tex2Dfetch(Storage_Consolidated, COORDS_CHECK_OVERLAY_REDRAW2).r;
  float drawcursorCspLast  = tex2Dfetch(Storage_Consolidated, COORDS_CHECK_OVERLAY_REDRAW3).r;
  uint  fontSizeLast       = tex2Dfetch(Storage_Consolidated, COORDS_CHECK_OVERLAY_REDRAW4).r;

  float floatShowCllValues     = SHOW_CLL_VALUES;
  float floatShowCllFromCrusor = SHOW_CLL_FROM_CURSOR;
  float floatShowCsps          = SHOW_CSPS;
  float floatShowCspFromCursor = SHOW_CSP_FROM_CURSOR;

  if (floatShowCllValues     != drawCllLast
   || floatShowCllFromCrusor != drawcursorCllLast
   || floatShowCsps          != drawCspsLast
   || floatShowCspFromCursor != drawcursorCspLast
   || FONT_SIZE              != fontSizeLast)
  {
    tex2Dstore(Storage_Consolidated, COORDS_CHECK_OVERLAY_REDRAW,  1);
    tex2Dstore(Storage_Consolidated, COORDS_CHECK_OVERLAY_REDRAW0, floatShowCllValues);
    tex2Dstore(Storage_Consolidated, COORDS_CHECK_OVERLAY_REDRAW1, floatShowCllFromCrusor);
    tex2Dstore(Storage_Consolidated, COORDS_CHECK_OVERLAY_REDRAW2, floatShowCsps);
    tex2Dstore(Storage_Consolidated, COORDS_CHECK_OVERLAY_REDRAW3, floatShowCspFromCursor);
    tex2Dstore(Storage_Consolidated, COORDS_CHECK_OVERLAY_REDRAW4, FONT_SIZE);

    tex2Dstore(Storage_Consolidated,
               COORDS_OVERLAY_TEXT_Y_OFFSET_CURSOR_CLL,
               !SHOW_CLL_VALUES
             ? -ShowCllValuesLineCount
             : 0);

    tex2Dstore(Storage_Consolidated,
               COORDS_OVERLAY_TEXT_Y_OFFSET_CSPS,
               (!SHOW_CLL_VALUES && SHOW_CLL_FROM_CURSOR)
             ? -(ShowCllValuesLineCount)

             : (SHOW_CLL_VALUES  && !SHOW_CLL_FROM_CURSOR)
             ? -(ShowCllFromCursorLineCount)

             : (!SHOW_CLL_VALUES  && !SHOW_CLL_FROM_CURSOR)
             ? -(ShowCllValuesLineCount
               + ShowCllFromCursorLineCount)

             : 0);

    tex2Dstore(Storage_Consolidated,
               COORDS_OVERLAY_TEXT_Y_OFFSET_CURSOR_CSP,
               ((!SHOW_CLL_VALUES && SHOW_CLL_FROM_CURSOR  && SHOW_CSPS)
              ? -(ShowCllValuesLineCount)

              : (SHOW_CLL_VALUES  && !SHOW_CLL_FROM_CURSOR && SHOW_CSPS)
              ? -(ShowCllFromCursorLineCount)

              : (SHOW_CLL_VALUES  && SHOW_CLL_FROM_CURSOR  && !SHOW_CSPS)
              ? -(ShowCspsLineCount)

              : (!SHOW_CLL_VALUES && !SHOW_CLL_FROM_CURSOR && SHOW_CSPS)
              ? -(ShowCllValuesLineCount
                + ShowCllFromCursorLineCount)

              : (!SHOW_CLL_VALUES && SHOW_CLL_FROM_CURSOR  && !SHOW_CSPS)
              ? -(ShowCllValuesLineCount
                + ShowCspsLineCount)

              : (SHOW_CLL_VALUES  && !SHOW_CLL_FROM_CURSOR && !SHOW_CSPS)
              ? -(ShowCllFromCursorLineCount
                + ShowCspsLineCount)

              : (!SHOW_CLL_VALUES && !SHOW_CLL_FROM_CURSOR && !SHOW_CSPS)
              ? -(ShowCllValuesLineCount
                + ShowCllFromCursorLineCount
                + ShowCspsLineCount)

#if (ACTUAL_COLOUR_SPACE == CSP_HDR10 \
  || ACTUAL_COLOUR_SPACE == CSP_HLG)
              : 0) - 3);
#else
              : 0));
#endif

    for (int y = 0; y < BUFFER_HEIGHT; y++)
    {
      for (int x = 0; x < BUFFER_WIDTH; x++)
      {
        tex2Dstore(StorageTextOverlay, int2(x, y), float4(0.f, 0.f, 0.f, 0.f));
      }
    }
  }

#ifdef _DEBUG

  else
  {
    uint2 currentActiveOverlayArea = GetCharSize() * uint2(30, 16);
    for (uint x = currentActiveOverlayArea.x - 20; x < currentActiveOverlayArea.x; x++)
    {
      for (uint y = currentActiveOverlayArea.y - 20; y < currentActiveOverlayArea.y; y++)
      {
        tex2Dstore(StorageTextOverlay, int2(x, y), float4(0.f, 0.f, 0.f, 0.f));
      }
    }
  }

#endif
}


#define FetchAndStoreSinglePixelOfChar(CurrentOffset, DrawOffset)                           \
  float4 pixel = tex2Dfetch(SamplerFontAtlasConsolidated, charOffset + CurrentOffset).rgba; \
  tex2Dstore(StorageTextOverlay, (int2(ID.x, ID.y) + DrawOffset) * charSize + CurrentOffset, pixel)

#define DrawChar(Char, DrawOffset)                             \
  uint2 charSize   = GetCharSize();                            \
  uint2 charOffset = Char * charSize + atlasXY;                \
  for (int y = 0; y < charSize.y; y++)                         \
  {                                                            \
    for (int x = 0; x < charSize.x; x++)                       \
    {                                                          \
      FetchAndStoreSinglePixelOfChar(uint2(x, y), DrawOffset); \
    }                                                          \
  }                                                            \

void DrawOverlay(uint3 ID : SV_DispatchThreadID)
{

  if (tex2Dfetch(Storage_Consolidated, COORDS_CHECK_OVERLAY_REDRAW).r)
  {

#ifdef _DEBUG

    if(ID.x == 0 && ID.y == 0 && ID.z == 0)
    {
      uint2 currentActiveOverlayArea = GetCharSize() * uint2(30, 16);
      for (uint x = currentActiveOverlayArea.x - 20; x < currentActiveOverlayArea.x; x++)
      {
        for (uint y = currentActiveOverlayArea.y - 20; y < currentActiveOverlayArea.y; y++)
        {
          if ((x < (currentActiveOverlayArea.x - 15) || x > (currentActiveOverlayArea.x - 6))
           || (y < (currentActiveOverlayArea.y - 15) || y > (currentActiveOverlayArea.y - 6)))
          {
            tex2Dstore(StorageTextOverlay, int2(x, y), float4(0.f, 0.f, 0.f, 1.f));
          }
          else
          {
            tex2Dstore(StorageTextOverlay, int2(x, y), float4(1.f, 1.f, 1.f, 1.f));
          }
        }
      }
    }

#endif


#define cursorCllOffset int2(0, tex2Dfetch(Storage_Consolidated, COORDS_OVERLAY_TEXT_Y_OFFSET_CURSOR_CLL).r)
#define cspsOffset      int2(0, tex2Dfetch(Storage_Consolidated, COORDS_OVERLAY_TEXT_Y_OFFSET_CSPS).r)
#define cursorCspOffset int2(0, tex2Dfetch(Storage_Consolidated, COORDS_OVERLAY_TEXT_Y_OFFSET_CURSOR_CSP).r)


    const uint  fontSize = 8 - FONT_SIZE;
    const uint2 atlasXY  = uint2(fontSize % 3, fontSize / 3) * FONT_ATLAS_OFFSET;

    switch(ID.y)
    {
      // max/avg/min CLL
      // maxCLL:
      case 0:
      {
        if (SHOW_CLL_VALUES)
        {
          switch(ID.x)
          {
            case 0:
            {
              DrawChar(_m, uint2(0, 0))
              return;
            }
            case 1:
            {
              DrawChar(_a, uint2(0, 0))
              return;
            }
            case 2:
            {
              DrawChar(_x, uint2(0, 0))
              return;
            }
            case 3:
            {
              DrawChar(_C, uint2(0, 0))
              return;
            }
            case 4:
            {
              DrawChar(_L, uint2(0, 0))
              return;
            }
            case 5:
            {
              DrawChar(_L, uint2(0, 0))
              return;
            }
            case 6:
            {
              DrawChar(_colon, uint2(0, 0))
              return;
            }
            case 7:
            {
              DrawChar(_space, uint2(0, 0))
              return;
            }
            case 8:
            {
              DrawChar(_dot, uint2(6, 0)) // six figure number
              return;
            }
            case 9:
            {
              DrawChar(_space, uint2(6 + 2, 0)) // 2 decimal places
              return;
            }
            case 10:
            {
              DrawChar(_n, uint2(6 + 2, 0)) // 2 decimal places
              return;
            }
            case 11:
            {
              DrawChar(_i, uint2(6 + 2, 0)) // 2 decimal places
              return;
            }
            case 12:
            {
              DrawChar(_t, uint2(6 + 2, 0)) // 2 decimal places
              return;
            }
            case 13:
            {
              DrawChar(_s, uint2(6 + 2, 0)) // 2 decimal places
              return;
            }
            case 14:
            {
              break; // break here for the storage of the redraw
            }
            default:
            {
              return;
            }
          }
        }
        else
        {
          switch(ID.x)
          {
            case 14:
            {
              break; // break here for the storage of the redraw
            }
            default:
            {
              return;
            }
          }
        }
      } break;
      // avgCLL:
      case 1:
      {
        if (SHOW_CLL_VALUES)
        {
          switch(ID.x)
          {
            case 0:
            {
              DrawChar(_a, uint2(0, 0))
              return;
            }
            case 1:
            {
              DrawChar(_v, uint2(0, 0))
              return;
            }
            case 2:
            {
              DrawChar(_g, uint2(0, 0))
              return;
            }
            case 3:
            {
              DrawChar(_C, uint2(0, 0))
              return;
            }
            case 4:
            {
              DrawChar(_L, uint2(0, 0))
              return;
            }
            case 5:
            {
              DrawChar(_L, uint2(0, 0))
              return;
            }
            case 6:
            {
              DrawChar(_colon, uint2(0, 0))
              return;
            }
            case 7:
            {
              DrawChar(_space, uint2(0, 0))
              return;
            }
            case 8:
            {
              DrawChar(_dot, uint2(6, 0)) // six figure number
              return;
            }
            case 9:
            {
              DrawChar(_space, uint2(6 + 2, 0)) // 2 decimal places
              return;
            }
            case 10:
            {
              DrawChar(_n, uint2(6 + 2, 0)) // 2 decimal places
              return;
            }
            case 11:
            {
              DrawChar(_i, uint2(6 + 2, 0)) // 2 decimal places
              return;
            }
            case 12:
            {
              DrawChar(_t, uint2(6 + 2, 0)) // 2 decimal places
              return;
            }
            case 13:
            {
              DrawChar(_s, uint2(6 + 2, 0)) // 2 decimal places
              return;
            }
            default:
            {
              return;
            }
          }
        }
        return;
      }
      // minCLL:
      case 2:
      {
        if (SHOW_CLL_VALUES)
        {
          switch(ID.x)
          {
            case 0:
            {
              DrawChar(_m, uint2(0, 0))
              return;
            }
            case 1:
            {
              DrawChar(_i, uint2(0, 0))
              return;
            }
            case 2:
            {
              DrawChar(_n, uint2(0, 0))
              return;
            }
            case 3:
            {
              DrawChar(_C, uint2(0, 0))
              return;
            }
            case 4:
            {
              DrawChar(_L, uint2(0, 0))
              return;
            }
            case 5:
            {
              DrawChar(_L, uint2(0, 0))
              return;
            }
            case 6:
            {
              DrawChar(_colon, uint2(0, 0))
              return;
            }
            case 7:
            {
              DrawChar(_space, uint2(0, 0))
              return;
            }
            case 8:
            {
              DrawChar(_dot, uint2(6, 0)) // six figure number
              return;
            }
            case 9:
            {
              DrawChar(_space, uint2(6 + 7, 0)) // 7 decimal places
              return;
            }
            case 10:
            {
              DrawChar(_n, uint2(6 + 7, 0)) // 7 decimal places
              return;
            }
            case 11:
            {
              DrawChar(_i, uint2(6 + 7, 0)) // 7 decimal places
              return;
            }
            case 12:
            {
              DrawChar(_t, uint2(6 + 7, 0)) // 7 decimal places
              return;
            }
            case 13:
            {
              DrawChar(_s, uint2(6 + 7, 0)) // 7 decimal places
              return;
            }
            default:
            {
              return;
            }
          }
        }
        return;
      }

      // cursorCLL
      // x:
      case 3:
      {
        if (SHOW_CLL_FROM_CURSOR)
        {
          switch(ID.x)
          {
            case 0:
            {
              DrawChar(_x, cursorCllOffset)
              return;
            }
            case 1:
            {
              DrawChar(_colon, cursorCllOffset)
              return;
            }
            case 2:
            {
              DrawChar(_space, cursorCllOffset)
              return;
            }
            default:
            {
              return;
            }
          }
        }
        return;
      }
      // y:
      case 4:
      {
        if (SHOW_CLL_FROM_CURSOR)
        {
          switch(ID.x)
          {
            case 0:
            {
              DrawChar(_y, cursorCllOffset)
              return;
            }
            case 1:
            {
              DrawChar(_colon, cursorCllOffset)
              return;
            }
            case 2:
            {
              DrawChar(_space, cursorCllOffset)
              return;
            }
            default:
            {
              return;
            }
          }
        }
        return;
      }
      // cursorCLL:
      case 5:
      {
        if (SHOW_CLL_FROM_CURSOR)
        {
          switch(ID.x)
          {
            case 0:
            {
              DrawChar(_c, cursorCllOffset)
              return;
            }
            case 1:
            {
              DrawChar(_u, cursorCllOffset)
              return;
            }
            case 2:
            {
              DrawChar(_r, cursorCllOffset)
              return;
            }
            case 3:
            {
              DrawChar(_s, cursorCllOffset)
              return;
            }
            case 4:
            {
              DrawChar(_o, cursorCllOffset)
              return;
            }
            case 5:
            {
              DrawChar(_r, cursorCllOffset)
              return;
            }
            case 6:
            {
              DrawChar(_C, cursorCllOffset)
              return;
            }
            case 7:
            {
              DrawChar(_L, cursorCllOffset)
              return;
            }
            case 8:
            {
              DrawChar(_L, cursorCllOffset)
              return;
            }
            case 9:
            {
              DrawChar(_colon, cursorCllOffset)
              return;
            }
            case 10:
            {
              DrawChar(_space, cursorCllOffset)
              return;
            }
            case 11:
            {
              DrawChar(_dot, cursorCllOffset + uint2(6, 0)) // six figure number
              return;
            }
            case 12:
            {
              DrawChar(_space, cursorCllOffset + uint2(6 + 7, 0)) // 7 decimal places
              return;
            }
            case 13:
            {
              DrawChar(_n, cursorCllOffset + uint2(6 + 7, 0)) // 7 decimal places
              return;
            }
            case 14:
            {
              DrawChar(_i, cursorCllOffset + uint2(6 + 7, 0)) // 7 decimal places
              return;
            }
            case 15:
            {
              DrawChar(_t, cursorCllOffset + uint2(6 + 7, 0)) // 7 decimal places
              return;
            }
            case 16:
            {
              DrawChar(_s, cursorCllOffset + uint2(6 + 7, 0)) // 7 decimal places
              return;
            }
            default:
            {
              return;
            }
          }
        }
        return;
      }
      // R:
      case 6:
      {
        if (SHOW_CLL_FROM_CURSOR)
        {
          switch(ID.x)
          {
            case 0:
            {
              DrawChar(_R, cursorCllOffset)
              return;
            }
            case 1:
            {
              DrawChar(_colon, cursorCllOffset)
              return;
            }
            case 2:
            {
              DrawChar(_space, cursorCllOffset)
              return;
            }

#if (ACTUAL_COLOUR_SPACE == CSP_HDR10 \
  || ACTUAL_COLOUR_SPACE == CSP_HLG)

            case 3:
            {
              DrawChar(_dot, cursorCllOffset + uint2(1, 0))
              return;
            }

#else

            case 3:
            {
              DrawChar(_dot, cursorCllOffset + uint2(4, 0))
              return;
            }

#endif

            default:
            {
              return;
            }
          }
        }
        return;
      }
      // G:
      case 7:
      {
        if (SHOW_CLL_FROM_CURSOR)
        {
          switch(ID.x)
          {
            case 0:
            {
              DrawChar(_G, cursorCllOffset)
              return;
            }
            case 1:
            {
              DrawChar(_colon, cursorCllOffset)
              return;
            }
            case 2:
            {
              DrawChar(_space, cursorCllOffset)
              return;
            }

#if (ACTUAL_COLOUR_SPACE == CSP_HDR10 \
  || ACTUAL_COLOUR_SPACE == CSP_HLG)

            case 3:
            {
              DrawChar(_dot, cursorCllOffset + uint2(1, 0))
              return;
            }

#else

            case 3:
            {
              DrawChar(_dot, cursorCllOffset + uint2(4, 0))
              return;
            }

#endif

            default:
            {
              return;
            }
          }
        }
        return;
      }
      // B:
      case 8:
      {
        if (SHOW_CLL_FROM_CURSOR)
        {
          switch(ID.x)
          {
            case 0:
            {
              DrawChar(_B, cursorCllOffset)
              return;
            }
            case 1:
            {
              DrawChar(_colon, cursorCllOffset)
              return;
            }
            case 2:
            {
              DrawChar(_space, cursorCllOffset)
              return;
            }

#if (ACTUAL_COLOUR_SPACE == CSP_HDR10 \
  || ACTUAL_COLOUR_SPACE == CSP_HLG)

            case 3:
            {
              DrawChar(_dot, cursorCllOffset + uint2(1, 0))
              return;
            }

#else

            case 3:
            {
              DrawChar(_dot, cursorCllOffset + uint2(4, 0))
              return;
            }

#endif

            default:
            {
              return;
            }
          }
        }
        return;
      }

      // CSPs
      // BT.709:
      case 9:
      {
        if (SHOW_CSPS)
        {
          switch(ID.x)
          {
            case 0:
            {
              DrawChar(_B, cspsOffset)
            } break;
            case 1:
            {
              DrawChar(_T, cspsOffset)
            } break;
            case 2:
            {
              DrawChar(_dot, cspsOffset)
            } break;
            case 3:
            {
              DrawChar(_7, cspsOffset)
            } break;
            case 4:
            {
              DrawChar(_0, cspsOffset)
            } break;
            case 5:
            {
              DrawChar(_9, cspsOffset)
            } break;
            case 6:
            {
              DrawChar(_colon, cspsOffset)
            } break;
            case 7:
            {
              DrawChar(_space, cspsOffset)
            } break;
            case 8:
            {
              DrawChar(_space, cspsOffset)
            } break;
            case 9:
            {
              DrawChar(_dot, cspsOffset + uint2(3, 0))
            } break;
            case 10:
            {
              DrawChar(_percent, cspsOffset + uint2(5, 0))
            } break;
            default:
            {
              return;
            }
          }
        }
        return;
      }
      // DCI-P3:
      case 10:
      {
        if (SHOW_CSPS)
        {
          switch(ID.x)
          {
            case 0:
            {
              DrawChar(_D, cspsOffset)
            } break;
            case 1:
            {
              DrawChar(_C, cspsOffset)
            } break;
            case 2:
            {
              DrawChar(_I, cspsOffset)
            } break;
            case 3:
            {
              DrawChar(_minus, cspsOffset)
            } break;
            case 4:
            {
              DrawChar(_P, cspsOffset)
            } break;
            case 5:
            {
              DrawChar(_3, cspsOffset)
            } break;
            case 6:
            {
              DrawChar(_colon, cspsOffset)
            } break;
            case 7:
            {
              DrawChar(_space, cspsOffset)
            } break;
            case 8:
            {
              DrawChar(_space, cspsOffset)
            } break;
            case 9:
            {
              DrawChar(_dot, cspsOffset + uint2(3, 0))
            } break;
            case 10:
            {
              DrawChar(_percent, cspsOffset + uint2(5, 0))
            } break;
            default:
            {
              return;
            }
          }
        }
        return;
      }
      // BT.2020:
      case 11:
      {
        if (SHOW_CSPS)
        {
          switch(ID.x)
          {
            case 0:
            {
              DrawChar(_B, cspsOffset)
            } break;
            case 1:
            {
              DrawChar(_T, cspsOffset)
            } break;
            case 2:
            {
              DrawChar(_dot, cspsOffset)
            } break;
            case 3:
            {
              DrawChar(_2, cspsOffset)
            } break;
            case 4:
            {
              DrawChar(_0, cspsOffset)
            } break;
            case 5:
            {
              DrawChar(_2, cspsOffset)
            } break;
            case 6:
            {
              DrawChar(_0, cspsOffset)
            } break;
            case 7:
            {
              DrawChar(_colon, cspsOffset)
            } break;
            case 8:
            {
              DrawChar(_space, cspsOffset)
            } break;
            case 9:
            {
              DrawChar(_dot, cspsOffset + uint2(3, 0))
            } break;
            case 10:
            {
              DrawChar(_percent, cspsOffset + uint2(5, 0))
            } break;
            default:
            {
              return;
            }
          }
        }
        return;
      }

#if (ACTUAL_COLOUR_SPACE != CSP_HDR10 \
  && ACTUAL_COLOUR_SPACE != CSP_HLG)

      // AP1:
      case 12:
      {
        if (SHOW_CSPS)
        {
          switch(ID.x)
          {
            case 0:
            {
              DrawChar(_A, cspsOffset)
            } break;
            case 1:
            {
              DrawChar(_P, cspsOffset)
            } break;
            case 2:
            {
              DrawChar(_1, cspsOffset)
            } break;
            case 3:
            {
              DrawChar(_colon, cspsOffset)
            } break;
            case 4:
            {
              DrawChar(_space, cspsOffset)
            } break;
            case 5:
            {
              DrawChar(_space, cspsOffset)
            } break;
            case 6:
            {
              DrawChar(_space, cspsOffset)
            } break;
            case 7:
            {
              DrawChar(_space, cspsOffset)
            } break;
            case 8:
            {
              DrawChar(_space, cspsOffset)
            } break;
            case 9:
            {
              DrawChar(_dot, cspsOffset + uint2(3, 0))
            } break;
            case 10:
            {
              DrawChar(_percent, cspsOffset + uint2(5, 0))
            } break;
            default:
            {
              return;
            }
          }
        }
        return;
      }
      // AP0:
      case 13:
      {
        if (SHOW_CSPS)
        {
          switch(ID.x)
          {
            case 0:
            {
              DrawChar(_A, cspsOffset)
            } break;
            case 1:
            {
              DrawChar(_P, cspsOffset)
            } break;
            case 2:
            {
              DrawChar(_0, cspsOffset)
            } break;
            case 3:
            {
              DrawChar(_colon, cspsOffset)
            } break;
            case 4:
            {
              DrawChar(_space, cspsOffset)
            } break;
            case 5:
            {
              DrawChar(_space, cspsOffset)
            } break;
            case 6:
            {
              DrawChar(_space, cspsOffset)
            } break;
            case 7:
            {
              DrawChar(_space, cspsOffset)
            } break;
            case 8:
            {
              DrawChar(_space, cspsOffset)
            } break;
            case 9:
            {
              DrawChar(_dot, cspsOffset + uint2(3, 0))
            } break;
            case 10:
            {
              DrawChar(_percent, cspsOffset + uint2(5, 0))
            } break;
            default:
            {
              return;
            }
          }
        }
        return;
      }
      // invalid:
      case 14:
      {
        if (SHOW_CSPS)
        {
          switch(ID.x)
          {
            case 0:
            {
              DrawChar(_i, cspsOffset)
            } break;
            case 1:
            {
              DrawChar(_n, cspsOffset)
            } break;
            case 2:
            {
              DrawChar(_v, cspsOffset)
            } break;
            case 3:
            {
              DrawChar(_a, cspsOffset)
            } break;
            case 4:
            {
              DrawChar(_l, cspsOffset)
            } break;
            case 5:
            {
              DrawChar(_i, cspsOffset)
            } break;
            case 6:
            {
              DrawChar(_d, cspsOffset)
            } break;
            case 7:
            {
              DrawChar(_colon, cspsOffset)
            } break;
            case 8:
            {
              DrawChar(_space, cspsOffset)
            } break;
            case 9:
            {
              DrawChar(_dot, cspsOffset + uint2(3, 0))
            } break;
            case 10:
            {
              DrawChar(_percent, cspsOffset + uint2(5, 0))
            } break;
            default:
            {
              return;
            }
          }
        }
        return;
      }

#endif

      // cursorCSP
      case 15:
      {
        if (SHOW_CSP_FROM_CURSOR)
        {
          switch(ID.x)
          {
            case 0:
            {
              DrawChar(_c, cursorCspOffset)
            } break;
            case 1:
            {
              DrawChar(_u, cursorCspOffset)
            } break;
            case 2:
            {
              DrawChar(_r, cursorCspOffset)
            } break;
            case 3:
            {
              DrawChar(_s, cursorCspOffset)
            } break;
            case 4:
            {
              DrawChar(_o, cursorCspOffset)
            } break;
            case 5:
            {
              DrawChar(_r, cursorCspOffset)
            } break;
            case 6:
            {
              DrawChar(_C, cursorCspOffset)
            } break;
            case 7:
            {
              DrawChar(_S, cursorCspOffset)
            } break;
            case 8:
            {
              DrawChar(_P, cursorCspOffset)
            } break;
            case 9:
            {
              DrawChar(_colon, cursorCspOffset)
            } break;
            case 10:
            {
              DrawChar(_space, cursorCspOffset)
            } break;
            default:
            {
              return;
            }
          }
        }
        return;
      }

      default:
      {
        return;
      }
    }

    if (ID.x == 14 && ID.y == 0 && ID.z == 0)
    {
      tex2Dstore(Storage_Consolidated, COORDS_CHECK_OVERLAY_REDRAW, 0);
      return;
    }
  }

  return;
}


#define _6th(Val) Val / 100000.f
#define _5th(Val) Val / 10000.f
#define _4th(Val) Val / 1000.f
#define _3rd(Val) Val / 100.f
#define _2nd(Val) Val / 10.f
#define _1st(Val) Val % 10.f
#define d1st(Val) Val % 1.f *     10.f
#define d2nd(Val) Val % 1.f *    100.f % 10.f
#define d3rd(Val) Val % 1.f *   1000.f % 10.f
#define d4th(Val) Val % 1.f *  10000.f % 10.f
#define d5th(Val) Val % 1.f * 100000.f % 10.f
#define d6th(Val) Val % 1.f * 100000.f % 1.f  * 10.f
#define d7th(Val) Val % 1.f * 100000.f % 0.1f * 100.f

#define DrawNumberAboveZero(Offset)            \
  if (curNumber > 0)                           \
  {                                            \
    DrawChar(uint2(curNumber % 10, 0), Offset) \
  }                                            \
  else                                         \
  {                                            \
    DrawChar(_space, Offset)                   \
  }


void DrawNumbersToOverlay(uint3 ID : SV_DispatchThreadID)
{

  const uint  fontSize = 8 - FONT_SIZE;
  const uint2 atlasXY  = uint2(fontSize % 3, fontSize / 3) * FONT_ATLAS_OFFSET;

  switch(ID.y)
  {
    // max/avg/min CLL
    // maxCLL:
    case 0:
    {
      if (SHOW_CLL_VALUES)
      {
        switch(ID.x)
        {
          case 0:
          {
#if (ACTUAL_COLOUR_SPACE != CSP_HDR10 \
  && ACTUAL_COLOUR_SPACE != CSP_HLG)

            precise float maxCllShow = tex2Dfetch(Storage_Consolidated, COORDS_SHOW_MAXCLL).r;
            precise uint  curNumber  = _6th(maxCllShow);
            DrawNumberAboveZero(uint2(8, 0))
#else
            DrawChar(_space, uint2(8, 0))
#endif
            return;
          }
          case 1:
          {
            precise float maxCllShow = tex2Dfetch(Storage_Consolidated, COORDS_SHOW_MAXCLL).r;
            precise uint  curNumber  = _5th(maxCllShow);
            DrawNumberAboveZero(uint2(8, 0))
            return;
          }
          case 2:
          {
            precise float maxCllShow = tex2Dfetch(Storage_Consolidated, COORDS_SHOW_MAXCLL).r;
            precise uint  curNumber  = _4th(maxCllShow);
            DrawNumberAboveZero(uint2(8, 0))
            return;
          }
          case 3:
          {
            precise float maxCllShow = tex2Dfetch(Storage_Consolidated, COORDS_SHOW_MAXCLL).r;
            precise uint  curNumber  = _3rd(maxCllShow);
            DrawNumberAboveZero(uint2(8, 0))
            return;
          }
          case 4:
          {
            precise float maxCllShow = tex2Dfetch(Storage_Consolidated, COORDS_SHOW_MAXCLL).r;
            precise uint  curNumber  = _2nd(maxCllShow);
            DrawNumberAboveZero(uint2(8, 0))
            return;
          }
          case 5:
          {
            precise float maxCllShow = tex2Dfetch(Storage_Consolidated, COORDS_SHOW_MAXCLL).r;
            precise uint  curNumber  = _1st(maxCllShow);
            DrawChar(uint2(curNumber, 0), uint2(8, 0))
            return;
          }
          case 6:
          {
            precise float maxCllShow = tex2Dfetch(Storage_Consolidated, COORDS_SHOW_MAXCLL).r;
            precise uint  curNumber  = d1st(maxCllShow);
            DrawChar(uint2(curNumber, 0), uint2(9, 0))
            return;
          }
          case 7:
          {
            precise float maxCllShow = tex2Dfetch(Storage_Consolidated, COORDS_SHOW_MAXCLL).r;
            precise uint  curNumber  = d2nd(maxCllShow);
            DrawChar(uint2(curNumber, 0), uint2(9, 0))
            return;
          }
//          case 8:
//          {
//            precise float maxCllShow = tex2Dfetch(Storage_Consolidated, COORDS_SHOW_MAXCLL).r;
//            precise uint  curNumber  = d3rd(maxCllShow);
//            DrawChar(uint2(curNumber, 0), uint2(9, 0))
//            return;
//          }
//          case 9:
//          {
//            precise float maxCllShow = tex2Dfetch(Storage_Consolidated, COORDS_SHOW_MAXCLL).r;
//            precise uint  curNumber  = d4th(maxCllShow);
//            DrawChar(uint2(curNumber, 0), uint2(9, 0))
//            return;
//          }
//          case 10:
//          {
//            precise float maxCllShow = tex2Dfetch(Storage_Consolidated, COORDS_SHOW_MAXCLL).r;
//            precise uint  curNumber  = d5th(maxCllShow);
//            DrawChar(uint2(curNumber, 0), uint2(9, 0))
//            return;
//          }
//          case 11:
//          {
//            precise float maxCllShow = tex2Dfetch(Storage_Consolidated, COORDS_SHOW_MAXCLL).r;
//            precise uint  curNumber  = d6th(maxCllShow);
//            DrawChar(uint2(curNumber, 0), uint2(9, 0))
//            return;
//          }
//          case 12:
//          {
//            precise float maxCllShow = tex2Dfetch(Storage_Consolidated, COORDS_SHOW_MAXCLL).r;
//            precise uint  curNumber  = d7th(maxCllShow);
//            DrawChar(uint2(curNumber, 0), uint2(9, 0))
//            return;
//          }
          default:
          {
            return;
          }
        }
      }
      return;
    }
    // avgCLL:
    case 1:
    {
      if (SHOW_CLL_VALUES)
      {
        switch(ID.x)
        {
          case 0:
          {
#if (ACTUAL_COLOUR_SPACE != CSP_HDR10 \
  && ACTUAL_COLOUR_SPACE != CSP_HLG)

            precise float avgCllShow = tex2Dfetch(Storage_Consolidated, COORDS_SHOW_AVGCLL).r;
            precise uint  curNumber  = _6th(avgCllShow);
            DrawNumberAboveZero(uint2(8, 0))
#else
            DrawChar(_space, uint2(8, 0))
#endif
            return;
          }
          case 1:
          {
            precise float avgCllShow = tex2Dfetch(Storage_Consolidated, COORDS_SHOW_AVGCLL).r;
            precise uint  curNumber  = _5th(avgCllShow);
            DrawNumberAboveZero(uint2(8, 0))
            return;
          }
          case 2:
          {
            precise float avgCllShow = tex2Dfetch(Storage_Consolidated, COORDS_SHOW_AVGCLL).r;
            precise uint  curNumber  = _4th(avgCllShow);
            DrawNumberAboveZero(uint2(8, 0))
            return;
          }
          case 3:
          {
            precise float avgCllShow = tex2Dfetch(Storage_Consolidated, COORDS_SHOW_AVGCLL).r;
            precise uint  curNumber  = _3rd(avgCllShow);
            DrawNumberAboveZero(uint2(8, 0))
            return;
          }
          case 4:
          {
            precise float avgCllShow = tex2Dfetch(Storage_Consolidated, COORDS_SHOW_AVGCLL).r;
            precise uint  curNumber  = _2nd(avgCllShow);
            DrawNumberAboveZero(uint2(8, 0))
            return;
          }
          case 5:
          {
            precise float avgCllShow = tex2Dfetch(Storage_Consolidated, COORDS_SHOW_AVGCLL).r;
            precise uint  curNumber  = _1st(avgCllShow);
            DrawChar(uint2(curNumber, 0), uint2(8, 0))
            return;
          }
          case 6:
          {
            precise float avgCllShow = tex2Dfetch(Storage_Consolidated, COORDS_SHOW_AVGCLL).r;
            precise uint  curNumber  = d1st(avgCllShow);
            DrawChar(uint2(curNumber, 0), uint2(9, 0))
            return;
          }
          case 7:
          {
            precise float avgCllShow = tex2Dfetch(Storage_Consolidated, COORDS_SHOW_AVGCLL).r;
            precise uint  curNumber  = d2nd(avgCllShow);
            DrawChar(uint2(curNumber, 0), uint2(9, 0))
            return;
          }
//          case 8:
//          {
//            precise float avgCllShow = tex2Dfetch(Storage_Consolidated, COORDS_SHOW_AVGCLL).r;
//            precise uint  curNumber  = d3rd(avgCllShow);
//            DrawChar(uint2(curNumber, 0), uint2(9, 0))
//            return;
//          }
//          case 9:
//          {
//            precise float avgCllShow = tex2Dfetch(Storage_Consolidated, COORDS_SHOW_AVGCLL).r;
//            precise uint  curNumber  = d4th(avgCllShow);
//            DrawChar(uint2(curNumber, 0), uint2(9, 0))
//            return;
//          }
//          case 10:
//          {
//            precise float avgCllShow = tex2Dfetch(Storage_Consolidated, COORDS_SHOW_AVGCLL).r;
//            precise uint  curNumber  = d5th(avgCllShow);
//            DrawChar(uint2(curNumber, 0), uint2(9, 0))
//            return;
//          }
//          case 11:
//          {
//            precise float avgCllShow = tex2Dfetch(Storage_Consolidated, COORDS_SHOW_AVGCLL).r;
//            precise uint  curNumber  = d6th(avgCllShow);
//            DrawChar(uint2(curNumber, 0), uint2(9, 0))
//            return;
//          }
//          case 12:
//          {
//            precise float avgCllShow = tex2Dfetch(Storage_Consolidated, COORDS_SHOW_AVGCLL).r;
//            precise uint  curNumber  = d7th(avgCllShow);
//            DrawChar(uint2(curNumber, 0), uint2(9, 0))
//            return;
//          }
          default:
          {
            return;
          }
        }
      }
      return;
    }
    // minCLL:
    case 2:
    {
      if (SHOW_CLL_VALUES)
      {
        switch(ID.x)
        {
          case 0:
          {
#if (ACTUAL_COLOUR_SPACE != CSP_HDR10 \
  && ACTUAL_COLOUR_SPACE != CSP_HLG)

            precise float minCllShow = tex2Dfetch(Storage_Consolidated, COORDS_SHOW_MINCLL).r;
            precise uint  curNumber  = _6th(minCllShow);
            DrawNumberAboveZero(uint2(8, 0))
#else
            DrawChar(_space, uint2(8, 0))
#endif
            return;
          }
          case 1:
          {
            precise float minCllShow = tex2Dfetch(Storage_Consolidated, COORDS_SHOW_MINCLL).r;
            precise uint  curNumber  = _5th(minCllShow);
            DrawNumberAboveZero(uint2(8, 0))
            return;
          }
          case 2:
          {
            precise float minCllShow = tex2Dfetch(Storage_Consolidated, COORDS_SHOW_MINCLL).r;
            precise uint  curNumber  = _4th(minCllShow);
            DrawNumberAboveZero(uint2(8, 0))
            return;
          }
          case 3:
          {
            precise float minCllShow = tex2Dfetch(Storage_Consolidated, COORDS_SHOW_MINCLL).r;
            precise uint  curNumber  = _3rd(minCllShow);
            DrawNumberAboveZero(uint2(8, 0))
            return;
          }
          case 4:
          {
            precise float minCllShow = tex2Dfetch(Storage_Consolidated, COORDS_SHOW_MINCLL).r;
            precise uint  curNumber  = _2nd(minCllShow);
            DrawNumberAboveZero(uint2(8, 0))
            return;
          }
          case 5:
          {
            precise float minCllShow = tex2Dfetch(Storage_Consolidated, COORDS_SHOW_MINCLL).r;
            precise uint  curNumber  = _1st(minCllShow);
            DrawChar(uint2(curNumber, 0), uint2(8, 0))
            return;
          }
          case 6:
          {
            precise float minCllShow = tex2Dfetch(Storage_Consolidated, COORDS_SHOW_MINCLL).r;
            precise uint  curNumber  = d1st(minCllShow);
            DrawChar(uint2(curNumber, 0), uint2(9, 0))
            return;
          }
          case 7:
          {
            precise float minCllShow = tex2Dfetch(Storage_Consolidated, COORDS_SHOW_MINCLL).r;
            precise uint  curNumber  = d2nd(minCllShow);
            DrawChar(uint2(curNumber, 0), uint2(9, 0))
            return;
          }
          case 8:
          {
            precise float minCllShow = tex2Dfetch(Storage_Consolidated, COORDS_SHOW_MINCLL).r;
            precise uint  curNumber  = d3rd(minCllShow);
            DrawChar(uint2(curNumber, 0), uint2(9, 0))
            return;
          }
          case 9:
          {
            precise float minCllShow = tex2Dfetch(Storage_Consolidated, COORDS_SHOW_MINCLL).r;
            precise uint  curNumber  = d4th(minCllShow);
            DrawChar(uint2(curNumber, 0), uint2(9, 0))
            return;
          }
          case 10:
          {
            precise float minCllShow = tex2Dfetch(Storage_Consolidated, COORDS_SHOW_MINCLL).r;
            precise uint  curNumber  = d5th(minCllShow);
            DrawChar(uint2(curNumber, 0), uint2(9, 0))
            return;
          }
          case 11:
          {
            precise float minCllShow = tex2Dfetch(Storage_Consolidated, COORDS_SHOW_MINCLL).r;
            precise uint  curNumber  = d6th(minCllShow);
            DrawChar(uint2(curNumber, 0), uint2(9, 0))
            return;
          }
          case 12:
          {
            precise float minCllShow = tex2Dfetch(Storage_Consolidated, COORDS_SHOW_MINCLL).r;
            precise uint  curNumber  = d7th(minCllShow);
            DrawChar(uint2(curNumber, 0), uint2(9, 0))
            return;
          }
          default:
          {
            return;
          }
        }
      }
      return;
    }

    // cursorCLL
    // x:
    case 3:
    {
      if (SHOW_CLL_FROM_CURSOR)
      {
        switch(ID.x)
        {

#define mPosX clamp(MOUSE_POSITION.x, 0.f, BUFFER_WIDTH - 1)

          case 0:
          {
            precise uint curNumber = _4th(mPosX);
            DrawNumberAboveZero(cursorCllOffset + uint2(3, 0))
            return;
          }
          case 1:
          {
            precise uint curNumber = _3rd(mPosX);
            DrawNumberAboveZero(cursorCllOffset + uint2(3, 0))
            return;
          }
          case 2:
          {
            precise uint curNumber = _2nd(mPosX);
            DrawNumberAboveZero(cursorCllOffset + uint2(3, 0))
            return;
          }
          case 3:
          {
            precise uint curNumber = _1st(mPosX);
            DrawChar(uint2(curNumber, 0), cursorCllOffset + uint2(3, 0))
            return;
          }
          default:
          {
            return;
          }
        }
      }
      return;
    }
    // y:
    case 4:
    {
      if (SHOW_CLL_FROM_CURSOR)
      {

#define mPosY clamp(MOUSE_POSITION.y, 0.f, BUFFER_HEIGHT - 1)

        switch(ID.x)
        {
          case 0:
          {
            precise uint curNumber = _4th(mPosY);
            DrawNumberAboveZero(cursorCllOffset + uint2(3, 0))
            return;
          }
          case 1:
          {
            precise uint curNumber = _3rd(mPosY);
            DrawNumberAboveZero(cursorCllOffset + uint2(3, 0))
            return;
          }
          case 2:
          {
            precise uint curNumber = _2nd(mPosY);
            DrawNumberAboveZero(cursorCllOffset + uint2(3, 0))
            return;
          }
          case 3:
          {
            precise uint curNumber = _1st(mPosY);
            DrawChar(uint2(curNumber, 0), cursorCllOffset + uint2(3, 0))
            return;
          }
          default:
          {
            return;
          }
        }
      }
      return;
    }
    // cursorCLL:
    case 5:
    {
      if (SHOW_CLL_FROM_CURSOR)
      {

#define mPos int2(clamp(MOUSE_POSITION.x, 0.f, BUFFER_WIDTH  - 1), \
                  clamp(MOUSE_POSITION.y, 0.f, BUFFER_HEIGHT - 1))

        switch(ID.x)
        {
          case 0:
          {
#if (ACTUAL_COLOUR_SPACE != CSP_HDR10 \
  && ACTUAL_COLOUR_SPACE != CSP_HLG)

            precise float cursorCll = tex2Dfetch(Sampler_CLL_Values, mPos).r;
            precise uint  curNumber = _6th(cursorCll);
            DrawNumberAboveZero(cursorCllOffset + uint2(11, 0))
#else
            DrawChar(_space, cursorCllOffset + uint2(11, 0))
#endif
            return;
          }
          case 1:
          {
            precise float cursorCll = tex2Dfetch(Sampler_CLL_Values, mPos).r;
            precise uint  curNumber = _5th(cursorCll);
            DrawNumberAboveZero(cursorCllOffset + uint2(11, 0))
            return;
          }
          case 2:
          {
            precise float cursorCll = tex2Dfetch(Sampler_CLL_Values, mPos).r;
            precise uint  curNumber = _4th(cursorCll);
            DrawNumberAboveZero(cursorCllOffset + uint2(11, 0))
            return;
          }
          case 3:
          {
            precise float cursorCll = tex2Dfetch(Sampler_CLL_Values, mPos).r;
            precise uint  curNumber = _3rd(cursorCll);
            DrawNumberAboveZero(cursorCllOffset + uint2(11, 0))
            return;
          }
          case 4:
          {
            precise float cursorCll = tex2Dfetch(Sampler_CLL_Values, mPos).r;
            precise uint  curNumber = _2nd(cursorCll);
            DrawNumberAboveZero(cursorCllOffset + uint2(11, 0))
            return;
          }
          case 5:
          {
            precise float cursorCll = tex2Dfetch(Sampler_CLL_Values, mPos).r;
            precise uint  curNumber = _1st(cursorCll);
            DrawChar(uint2(curNumber, 0), cursorCllOffset + uint2(11, 0))
            return;
          }
          case 6:
          {
            precise float cursorCll = tex2Dfetch(Sampler_CLL_Values, mPos).r;
            precise uint  curNumber = d1st(cursorCll);
            DrawChar(uint2(curNumber, 0), cursorCllOffset + uint2(12, 0))
            return;
          }
          case 7:
          {
            precise float cursorCll = tex2Dfetch(Sampler_CLL_Values, mPos).r;
            precise uint  curNumber = d2nd(cursorCll);
            DrawChar(uint2(curNumber, 0), cursorCllOffset + uint2(12, 0))
            return;
          }
          case 8:
          {
            precise float cursorCll = tex2Dfetch(Sampler_CLL_Values, mPos).r;
            precise uint  curNumber = d3rd(cursorCll);
            DrawChar(uint2(curNumber, 0), cursorCllOffset + uint2(12, 0))
            return;
          }
          case 9:
          {
            precise float cursorCll = tex2Dfetch(Sampler_CLL_Values, mPos).r;
            precise uint  curNumber = d4th(cursorCll);
            DrawChar(uint2(curNumber, 0), cursorCllOffset + uint2(12, 0))
            return;
          }
          case 10:
          {
            precise float cursorCll = tex2Dfetch(Sampler_CLL_Values, mPos).r;
            precise uint  curNumber = d5th(cursorCll);
            DrawChar(uint2(curNumber, 0), cursorCllOffset + uint2(12, 0))
            return;
          }
          case 11:
          {
            precise float cursorCll = tex2Dfetch(Sampler_CLL_Values, mPos).r;
            precise uint  curNumber = d6th(cursorCll);
            DrawChar(uint2(curNumber, 0), cursorCllOffset + uint2(12, 0))
            return;
          }
          case 12:
          {
            precise float cursorCll = tex2Dfetch(Sampler_CLL_Values, mPos).r;
            precise uint  curNumber = d7th(cursorCll);
            DrawChar(uint2(curNumber, 0), cursorCllOffset + uint2(12, 0))
            return;
          }
          default:
          {
            return;
          }
        }
      }
      return;
    }
    // R:
    case 6:
    {
      if (SHOW_CLL_FROM_CURSOR)
      {
        switch(ID.x)
        {

#if (ACTUAL_COLOUR_SPACE == CSP_HDR10 \
  || ACTUAL_COLOUR_SPACE == CSP_HLG)

          case 0:
          {
            precise float cursorR   = tex2Dfetch(ReShade::BackBuffer, mPos).r;
            precise uint  curNumber = _1st(cursorR);
            DrawChar(uint2(curNumber, 0), cursorCllOffset + uint2(3, 0))
            return;
          }
          case 1:
          {
            precise float cursorR   = tex2Dfetch(ReShade::BackBuffer, mPos).r;
            precise uint  curNumber = d1st(cursorR);
            DrawChar(uint2(curNumber, 0), cursorCllOffset + uint2(4, 0))
            return;
          }
          case 2:
          {
            precise float cursorR   = tex2Dfetch(ReShade::BackBuffer, mPos).r;
            precise uint  curNumber = d2nd(cursorR);
            DrawChar(uint2(curNumber, 0), cursorCllOffset + uint2(4, 0))
            return;
          }
          case 3:
          {
            precise float cursorR   = tex2Dfetch(ReShade::BackBuffer, mPos).r;
            precise uint  curNumber = d3rd(cursorR);
            DrawChar(uint2(curNumber, 0), cursorCllOffset + uint2(4, 0))
            return;
          }
          case 4:
          {
            precise float cursorR   = tex2Dfetch(ReShade::BackBuffer, mPos).r;
            precise uint  curNumber = d4th(cursorR);
            DrawChar(uint2(curNumber, 0), cursorCllOffset + uint2(4, 0))
            return;
          }

#else

          case 0:
          {
            precise float cursorR   = tex2Dfetch(ReShade::BackBuffer, mPos).r;
            precise uint  curNumber = _4th(cursorR);
            DrawNumberAboveZero(cursorCllOffset + uint2(3, 0))
            return;
          }
          case 1:
          {
            precise float cursorR   = tex2Dfetch(ReShade::BackBuffer, mPos).r;
            precise uint  curNumber = _3rd(cursorR);
            DrawNumberAboveZero(cursorCllOffset + uint2(3, 0))
            return;
          }
          case 2:
          {
            precise float cursorR   = tex2Dfetch(ReShade::BackBuffer, mPos).r;
            precise uint  curNumber = _2nd(cursorR);
            DrawNumberAboveZero(cursorCllOffset + uint2(3, 0))
            return;
          }
          case 3:
          {
            precise float cursorR   = tex2Dfetch(ReShade::BackBuffer, mPos).r;
            precise uint  curNumber = _1st(cursorR);
            DrawChar(uint2(curNumber, 0), cursorCllOffset + uint2(3, 0))
            return;
          }
          case 4:
          {
            precise float cursorR   = tex2Dfetch(ReShade::BackBuffer, mPos).r;
            precise uint  curNumber = d1st(cursorR);
            DrawChar(uint2(curNumber, 0), cursorCllOffset + uint2(4, 0))
            return;
          }
          case 5:
          {
            precise float cursorR   = tex2Dfetch(ReShade::BackBuffer, mPos).r;
            precise uint  curNumber = d2nd(cursorR);
            DrawChar(uint2(curNumber, 0), cursorCllOffset + uint2(4, 0))
            return;
          }
          case 6:
          {
            precise float cursorR   = tex2Dfetch(ReShade::BackBuffer, mPos).r;
            precise uint  curNumber = d3rd(cursorR);
            DrawChar(uint2(curNumber, 0), cursorCllOffset + uint2(4, 0))
            return;
          }
          case 7:
          {
            precise float cursorR   = tex2Dfetch(ReShade::BackBuffer, mPos).r;
            precise uint  curNumber = d4th(cursorR);
            DrawChar(uint2(curNumber, 0), cursorCllOffset + uint2(4, 0))
            return;
          }
          case 8:
          {
            precise float cursorR   = tex2Dfetch(ReShade::BackBuffer, mPos).r;
            precise uint  curNumber = d5th(cursorR);
            DrawChar(uint2(curNumber, 0), cursorCllOffset + uint2(4, 0))
            return;
          }
          case 9:
          {
            precise float cursorR   = tex2Dfetch(ReShade::BackBuffer, mPos).r;
            precise uint  curNumber = d6th(cursorR);
            DrawChar(uint2(curNumber, 0), cursorCllOffset + uint2(4, 0))
            return;
          }
          case 10:
          {
            precise float cursorR   = tex2Dfetch(ReShade::BackBuffer, mPos).r;
            precise uint  curNumber = d7th(cursorR);
            DrawChar(uint2(curNumber, 0), cursorCllOffset + uint2(4, 0))
            return;
          }

#endif

          default:
          {
            return;
          }
        }
      }
      return;
    }
    // G:
    case 7:
    {
      if (SHOW_CLL_FROM_CURSOR)
      {
        switch(ID.x)
        {

#if (ACTUAL_COLOUR_SPACE == CSP_HDR10 \
  || ACTUAL_COLOUR_SPACE == CSP_HLG)

          case 0:
          {
            precise float cursorG   = tex2Dfetch(ReShade::BackBuffer, mPos).r;
            precise uint  curNumber = _1st(cursorG);
            DrawChar(uint2(curNumber, 0), cursorCllOffset + uint2(3, 0))
            return;
          }
          case 1:
          {
            precise float cursorG   = tex2Dfetch(ReShade::BackBuffer, mPos).r;
            precise uint  curNumber = d1st(cursorG);
            DrawChar(uint2(curNumber, 0), cursorCllOffset + uint2(4, 0))
            return;
          }
          case 2:
          {
            precise float cursorG   = tex2Dfetch(ReShade::BackBuffer, mPos).r;
            precise uint  curNumber = d2nd(cursorG);
            DrawChar(uint2(curNumber, 0), cursorCllOffset + uint2(4, 0))
            return;
          }
          case 3:
          {
            precise float cursorG   = tex2Dfetch(ReShade::BackBuffer, mPos).r;
            precise uint  curNumber = d3rd(cursorG);
            DrawChar(uint2(curNumber, 0), cursorCllOffset + uint2(4, 0))
            return;
          }
          case 4:
          {
            precise float cursorG   = tex2Dfetch(ReShade::BackBuffer, mPos).r;
            precise uint  curNumber = d4th(cursorG);
            DrawChar(uint2(curNumber, 0), cursorCllOffset + uint2(4, 0))
            return;
          }

#else

          case 0:
          {
            precise float cursorG   = tex2Dfetch(ReShade::BackBuffer, mPos).r;
            precise uint  curNumber = _4th(cursorG);
            DrawNumberAboveZero(cursorCllOffset + uint2(3, 0))
            return;
          }
          case 1:
          {
            precise float cursorG   = tex2Dfetch(ReShade::BackBuffer, mPos).r;
            precise uint  curNumber = _3rd(cursorG);
            DrawNumberAboveZero(cursorCllOffset + uint2(3, 0))
            return;
          }
          case 2:
          {
            precise float cursorG   = tex2Dfetch(ReShade::BackBuffer, mPos).r;
            precise uint  curNumber = _2nd(cursorG);
            DrawNumberAboveZero(cursorCllOffset + uint2(3, 0))
            return;
          }
          case 3:
          {
            precise float cursorG   = tex2Dfetch(ReShade::BackBuffer, mPos).r;
            precise uint  curNumber = _1st(cursorG);
            DrawChar(uint2(curNumber, 0), cursorCllOffset + uint2(3, 0))
            return;
          }
          case 4:
          {
            precise float cursorG   = tex2Dfetch(ReShade::BackBuffer, mPos).r;
            precise uint  curNumber = d1st(cursorG);
            DrawChar(uint2(curNumber, 0), cursorCllOffset + uint2(4, 0))
            return;
          }
          case 5:
          {
            precise float cursorG   = tex2Dfetch(ReShade::BackBuffer, mPos).r;
            precise uint  curNumber = d2nd(cursorG);
            DrawChar(uint2(curNumber, 0), cursorCllOffset + uint2(4, 0))
            return;
          }
          case 6:
          {
            precise float cursorG   = tex2Dfetch(ReShade::BackBuffer, mPos).r;
            precise uint  curNumber = d3rd(cursorG);
            DrawChar(uint2(curNumber, 0), cursorCllOffset + uint2(4, 0))
            return;
          }
          case 7:
          {
            precise float cursorG   = tex2Dfetch(ReShade::BackBuffer, mPos).r;
            precise uint  curNumber = d4th(cursorG);
            DrawChar(uint2(curNumber, 0), cursorCllOffset + uint2(4, 0))
            return;
          }
          case 8:
          {
            precise float cursorG   = tex2Dfetch(ReShade::BackBuffer, mPos).r;
            precise uint  curNumber = d5th(cursorG);
            DrawChar(uint2(curNumber, 0), cursorCllOffset + uint2(4, 0))
            return;
          }
          case 9:
          {
            precise float cursorG   = tex2Dfetch(ReShade::BackBuffer, mPos).r;
            precise uint  curNumber = d6th(cursorG);
            DrawChar(uint2(curNumber, 0), cursorCllOffset + uint2(4, 0))
            return;
          }
          case 10:
          {
            precise float cursorG   = tex2Dfetch(ReShade::BackBuffer, mPos).r;
            precise uint  curNumber = d7th(cursorG);
            DrawChar(uint2(curNumber, 0), cursorCllOffset + uint2(4, 0))
            return;
          }

#endif

          default:
          {
            return;
          }
        }
      }
      return;
    }
    // B:
    case 8:
    {
      if (SHOW_CLL_FROM_CURSOR)
      {
        switch(ID.x)
        {

#if (ACTUAL_COLOUR_SPACE == CSP_HDR10 \
  || ACTUAL_COLOUR_SPACE == CSP_HLG)

          case 0:
          {
            precise float cursorB   = tex2Dfetch(ReShade::BackBuffer, mPos).r;
            precise uint  curNumber = _1st(cursorB);
            DrawChar(uint2(curNumber, 0), cursorCllOffset + uint2(3, 0))
            return;
          }
          case 1:
          {
            precise float cursorB   = tex2Dfetch(ReShade::BackBuffer, mPos).r;
            precise uint  curNumber = d1st(cursorB);
            DrawChar(uint2(curNumber, 0), cursorCllOffset + uint2(4, 0))
            return;
          }
          case 2:
          {
            precise float cursorB   = tex2Dfetch(ReShade::BackBuffer, mPos).r;
            precise uint  curNumber = d2nd(cursorB);
            DrawChar(uint2(curNumber, 0), cursorCllOffset + uint2(4, 0))
            return;
          }
          case 3:
          {
            precise float cursorB   = tex2Dfetch(ReShade::BackBuffer, mPos).r;
            precise uint  curNumber = d3rd(cursorB);
            DrawChar(uint2(curNumber, 0), cursorCllOffset + uint2(4, 0))
            return;
          }
          case 4:
          {
            precise float cursorB   = tex2Dfetch(ReShade::BackBuffer, mPos).r;
            precise uint  curNumber = d4th(cursorB);
            DrawChar(uint2(curNumber, 0), cursorCllOffset + uint2(4, 0))
            return;
          }

#else

          case 0:
          {
            precise float cursorB   = tex2Dfetch(ReShade::BackBuffer, mPos).r;
            precise uint  curNumber = _4th(cursorB);
            DrawNumberAboveZero(cursorCllOffset + uint2(3, 0))
            return;
          }
          case 1:
          {
            precise float cursorB   = tex2Dfetch(ReShade::BackBuffer, mPos).r;
            precise uint  curNumber = _3rd(cursorB);
            DrawNumberAboveZero(cursorCllOffset + uint2(3, 0))
            return;
          }
          case 2:
          {
            precise float cursorB   = tex2Dfetch(ReShade::BackBuffer, mPos).r;
            precise uint  curNumber = _2nd(cursorB);
            DrawNumberAboveZero(cursorCllOffset + uint2(3, 0))
            return;
          }
          case 3:
          {
            precise float cursorB   = tex2Dfetch(ReShade::BackBuffer, mPos).r;
            precise uint  curNumber = _1st(cursorB);
            DrawChar(uint2(curNumber, 0), cursorCllOffset + uint2(3, 0))
            return;
          }
          case 4:
          {
            precise float cursorB   = tex2Dfetch(ReShade::BackBuffer, mPos).r;
            precise uint  curNumber = d1st(cursorB);
            DrawChar(uint2(curNumber, 0), cursorCllOffset + uint2(4, 0))
            return;
          }
          case 5:
          {
            precise float cursorB   = tex2Dfetch(ReShade::BackBuffer, mPos).r;
            precise uint  curNumber = d2nd(cursorB);
            DrawChar(uint2(curNumber, 0), cursorCllOffset + uint2(4, 0))
            return;
          }
          case 6:
          {
            precise float cursorB   = tex2Dfetch(ReShade::BackBuffer, mPos).r;
            precise uint  curNumber = d3rd(cursorB);
            DrawChar(uint2(curNumber, 0), cursorCllOffset + uint2(4, 0))
            return;
          }
          case 7:
          {
            precise float cursorB   = tex2Dfetch(ReShade::BackBuffer, mPos).r;
            precise uint  curNumber = d4th(cursorB);
            DrawChar(uint2(curNumber, 0), cursorCllOffset + uint2(4, 0))
            return;
          }
          case 8:
          {
            precise float cursorB   = tex2Dfetch(ReShade::BackBuffer, mPos).r;
            precise uint  curNumber = d5th(cursorB);
            DrawChar(uint2(curNumber, 0), cursorCllOffset + uint2(4, 0))
            return;
          }
          case 9:
          {
            precise float cursorB   = tex2Dfetch(ReShade::BackBuffer, mPos).r;
            precise uint  curNumber = d6th(cursorB);
            DrawChar(uint2(curNumber, 0), cursorCllOffset + uint2(4, 0))
            return;
          }
          case 10:
          {
            precise float cursorB   = tex2Dfetch(ReShade::BackBuffer, mPos).r;
            precise uint  curNumber = d7th(cursorB);
            DrawChar(uint2(curNumber, 0), cursorCllOffset + uint2(4, 0))
            return;
          }

#endif

          default:
          {
            return;
          }
        }
      }
      return;
    }

    // show CSPs
    // BT.709:
    case 9:
    {
      if (SHOW_CSPS)
      {
        switch(ID.x)
        {
          case 0:
          {
            precise float precentageBt709 = tex2Dfetch(Storage_Consolidated, COORDS_SHOW_PERCENTAGE_BT709).r;
            precise uint  curNumber       = _3rd(precentageBt709);
            DrawNumberAboveZero(cspsOffset + uint2(9, 0))
            return;
          }
          case 1:
          {
            precise float precentageBt709 = tex2Dfetch(Storage_Consolidated, COORDS_SHOW_PERCENTAGE_BT709).r;
            precise uint  curNumber       = _2nd(precentageBt709);
            DrawNumberAboveZero(cspsOffset + uint2(9, 0))
            return;
          }
          case 2:
          {
            precise float precentageBt709 = tex2Dfetch(Storage_Consolidated, COORDS_SHOW_PERCENTAGE_BT709).r;
            precise uint  curNumber       = _1st(precentageBt709);
            DrawChar(uint2(curNumber, 0), cspsOffset + uint2(9, 0))
            return;
          }
          case 3:
          {
            precise float precentageBt709 = tex2Dfetch(Storage_Consolidated, COORDS_SHOW_PERCENTAGE_BT709).r;
            precise uint  curNumber       = d1st(precentageBt709);
            DrawChar(uint2(curNumber, 0), cspsOffset + uint2(10, 0))
            return;
          }
          case 4:
          {
            precise float precentageBt709 = tex2Dfetch(Storage_Consolidated, COORDS_SHOW_PERCENTAGE_BT709).r;
            precise uint  curNumber       = d2nd(precentageBt709);
            DrawChar(uint2(curNumber, 0), cspsOffset + uint2(10, 0))
            return;
          }
//          case 5:
//          {
//            precise float precentageBt709 = tex2Dfetch(Storage_Consolidated, COORDS_SHOW_PERCENTAGE_BT709).r;
//            precise uint  curNumber       = d3rd(precentageBt709);
//            DrawChar(uint2(curNumber, 0), cspsOffset + uint2(10, 0))
//            return;
//          }
//          case 6:
//          {
//            precise float precentageBt709 = tex2Dfetch(Storage_Consolidated, COORDS_SHOW_PERCENTAGE_BT709).r;
//            precise uint  curNumber       = d4th(precentageBt709);
//            DrawChar(uint2(curNumber, 0), cspsOffset + uint2(10, 0))
//            return;
//          }
          default:
          {
            return;
          }
        }
      }
      return;
    }
    // DCI-P3:
    case 10:
    {
      if (SHOW_CSPS)
      {
        switch(ID.x)
        {
          case 0:
          {
            precise float precentageDciP3 = tex2Dfetch(Storage_Consolidated, COORDS_SHOW_PERCENTAGE_DCI_P3).r;
            precise uint  curNumber       = _3rd(precentageDciP3);
            DrawNumberAboveZero(cspsOffset + uint2(9, 0))
            return;
          }
          case 1:
          {
            precise float precentageDciP3 = tex2Dfetch(Storage_Consolidated, COORDS_SHOW_PERCENTAGE_DCI_P3).r;
            precise uint  curNumber       = _2nd(precentageDciP3);
            DrawNumberAboveZero(cspsOffset + uint2(9, 0))
            return;
          }
          case 2:
          {
            precise float precentageDciP3 = tex2Dfetch(Storage_Consolidated, COORDS_SHOW_PERCENTAGE_DCI_P3).r;
            precise uint  curNumber       = _1st(precentageDciP3);
            DrawChar(uint2(curNumber, 0), cspsOffset + uint2(9, 0))
            return;
          }
          case 3:
          {
            precise float precentageDciP3 = tex2Dfetch(Storage_Consolidated, COORDS_SHOW_PERCENTAGE_DCI_P3).r;
            precise uint  curNumber       = d1st(precentageDciP3);
            DrawChar(uint2(curNumber, 0), cspsOffset + uint2(10, 0))
            return;
          }
          case 4:
          {
            precise float precentageDciP3 = tex2Dfetch(Storage_Consolidated, COORDS_SHOW_PERCENTAGE_DCI_P3).r;
            precise uint  curNumber       = d2nd(precentageDciP3);
            DrawChar(uint2(curNumber, 0), cspsOffset + uint2(10, 0))
            return;
          }
//          case 5:
//          {
//            precise float precentageDciP3 = tex2Dfetch(Storage_Consolidated, COORDS_SHOW_PERCENTAGE_DCI_P3).r;
//            precise uint  curNumber       = d3rd(precentageDciP3);
//            DrawChar(uint2(curNumber, 0), cspsOffset + uint2(10, 0))
//            return;
//          }
//          case 6:
//          {
//            precise float precentageDciP3 = tex2Dfetch(Storage_Consolidated, COORDS_SHOW_PERCENTAGE_DCI_P3).r;
//            precise uint  curNumber       = d4th(precentageDciP3);
//            DrawChar(uint2(curNumber, 0), cspsOffset + uint2(10, 0))
//            return;
//          }
          default:
          {
            return;
          }
        }
      }
      return;
    }
    // BT.2020:
    case 11:
    {
      if (SHOW_CSPS)
      {
        switch(ID.x)
        {
          case 0:
          {
            precise float precentageBt2020 = tex2Dfetch(Storage_Consolidated, COORDS_SHOW_PERCENTAGE_BT2020).r;
            precise uint  curNumber        = _3rd(precentageBt2020);
            DrawNumberAboveZero(cspsOffset + uint2(9, 0))
            return;
          }
          case 1:
          {
            precise float precentageBt2020 = tex2Dfetch(Storage_Consolidated, COORDS_SHOW_PERCENTAGE_BT2020).r;
            precise uint  curNumber        = _2nd(precentageBt2020);
            DrawNumberAboveZero(cspsOffset + uint2(9, 0))
            return;
          }
          case 2:
          {
            precise float precentageBt2020 = tex2Dfetch(Storage_Consolidated, COORDS_SHOW_PERCENTAGE_BT2020).r;
            precise uint  curNumber        = _1st(precentageBt2020);
            DrawChar(uint2(curNumber, 0), cspsOffset + uint2(9, 0))
            return;
          }
          case 3:
          {
            precise float precentageBt2020 = tex2Dfetch(Storage_Consolidated, COORDS_SHOW_PERCENTAGE_BT2020).r;
            precise uint  curNumber        = d1st(precentageBt2020);
            DrawChar(uint2(curNumber, 0), cspsOffset + uint2(10, 0))
            return;
          }
          case 4:
          {
            precise float precentageBt2020 = tex2Dfetch(Storage_Consolidated, COORDS_SHOW_PERCENTAGE_BT2020).r;
            precise uint  curNumber        = d2nd(precentageBt2020);
            DrawChar(uint2(curNumber, 0), cspsOffset + uint2(10, 0))
            return;
          }
//          case 5:
//          {
//            precise float precentageBt2020 = tex2Dfetch(Storage_Consolidated, COORDS_SHOW_PERCENTAGE_BT2020).r;
//            precise uint  curNumber        = d3rd(precentageBt2020);
//            DrawChar(uint2(curNumber, 0), cspsOffset + uint2(10, 0))
//            return;
//          }
//          case 6:
//          {
//            precise float precentageBt2020 = tex2Dfetch(Storage_Consolidated, COORDS_SHOW_PERCENTAGE_BT2020).r;
//            precise uint  curNumber        = d4th(precentageBt2020);
//            DrawChar(uint2(curNumber, 0), cspsOffset + uint2(10, 0))
//            return;
//          }
          default:
          {
            return;
          }
        }
      }
      return;
    }

#if (ACTUAL_COLOUR_SPACE != CSP_HDR10 \
  && ACTUAL_COLOUR_SPACE != CSP_HLG)

    // AP1:
    case 12:
    {
      if (SHOW_CSPS)
      {
        switch(ID.x)
        {
          case 0:
          {
            precise float precentageAp1 = tex2Dfetch(Storage_Consolidated, COORDS_SHOW_PERCENTAGE_AP1).r;
            precise uint  curNumber     = _3rd(precentageAp1);
            DrawNumberAboveZero(cspsOffset + uint2(9, 0))
            return;
          }
          case 1:
          {
            precise float precentageAp1 = tex2Dfetch(Storage_Consolidated, COORDS_SHOW_PERCENTAGE_AP1).r;
            precise uint  curNumber     = _2nd(precentageAp1);
            DrawNumberAboveZero(cspsOffset + uint2(9, 0))
            return;
          }
          case 2:
          {
            precise float precentageAp1 = tex2Dfetch(Storage_Consolidated, COORDS_SHOW_PERCENTAGE_AP1).r;
            precise uint  curNumber     = _1st(precentageAp1);
            DrawChar(uint2(curNumber, 0), cspsOffset + uint2(9, 0))
            return;
          }
          case 3:
          {
            precise float precentageAp1 = tex2Dfetch(Storage_Consolidated, COORDS_SHOW_PERCENTAGE_AP1).r;
            precise uint  curNumber     = d1st(precentageAp1);
            DrawChar(uint2(curNumber, 0), cspsOffset + uint2(10, 0))
            return;
          }
          case 4:
          {
            precise float precentageAp1 = tex2Dfetch(Storage_Consolidated, COORDS_SHOW_PERCENTAGE_AP1).r;
            precise uint  curNumber     = d2nd(precentageAp1);
            DrawChar(uint2(curNumber, 0), cspsOffset + uint2(10, 0))
            return;
          }
//          case 5:
//          {
//            precise float precentageAp1 = tex2Dfetch(Storage_Consolidated, COORDS_SHOW_PERCENTAGE_AP1).r;
//            precise uint  curNumber     = d3rd(precentageAp1);
//            DrawChar(uint2(curNumber, 0), cspsOffset + uint2(10, 0))
//            return;
//          }
//          case 6:
//          {
//            precise float precentageAp1 = tex2Dfetch(Storage_Consolidated, COORDS_SHOW_PERCENTAGE_AP1).r;
//            precise uint  curNumber     = d4th(precentageAp1);
//            DrawChar(uint2(curNumber, 0), cspsOffset + uint2(10, 0))
//            return;
//          }
          default:
          {
            return;
          }
        }
      }
      return;
    }
    // AP0:
    case 13:
    {
      if (SHOW_CSPS)
      {
        switch(ID.x)
        {
          case 0:
          {
            precise float precentageAp0 = tex2Dfetch(Storage_Consolidated, COORDS_SHOW_PERCENTAGE_AP0).r;
            precise uint  curNumber     = _3rd(precentageAp0);
            DrawNumberAboveZero(cspsOffset + uint2(9, 0))
            return;
          }
          case 1:
          {
            precise float precentageAp0 = tex2Dfetch(Storage_Consolidated, COORDS_SHOW_PERCENTAGE_AP0).r;
            precise uint  curNumber     = _2nd(precentageAp0);
            DrawNumberAboveZero(cspsOffset + uint2(9, 0))
            return;
          }
          case 2:
          {
            precise float precentageAp0 = tex2Dfetch(Storage_Consolidated, COORDS_SHOW_PERCENTAGE_AP0).r;
            precise uint  curNumber     = _1st(precentageAp0);
            DrawChar(uint2(curNumber, 0), cspsOffset + uint2(9, 0))
            return;
          }
          case 3:
          {
            precise float precentageAp0 = tex2Dfetch(Storage_Consolidated, COORDS_SHOW_PERCENTAGE_AP0).r;
            precise uint  curNumber     = d1st(precentageAp0);
            DrawChar(uint2(curNumber, 0), cspsOffset + uint2(10, 0))
            return;
          }
          case 4:
          {
            precise float precentageAp0 = tex2Dfetch(Storage_Consolidated, COORDS_SHOW_PERCENTAGE_AP0).r;
            precise uint  curNumber     = d2nd(precentageAp0);
            DrawChar(uint2(curNumber, 0), cspsOffset + uint2(10, 0))
            return;
          }
//          case 5:
//          {
//            precise float precentageAp0 = tex2Dfetch(Storage_Consolidated, COORDS_SHOW_PERCENTAGE_AP0).r;
//            precise uint  curNumber     = d3rd(precentageAp0);
//            DrawChar(uint2(curNumber, 0), cspsOffset + uint2(10, 0))
//            return;
//          }
//          case 6:
//          {
//            precise float precentageAp0 = tex2Dfetch(Storage_Consolidated, COORDS_SHOW_PERCENTAGE_AP0).r;
//            precise uint  curNumber     = d4th(precentageAp0);
//            DrawChar(uint2(curNumber, 0), cspsOffset + uint2(10, 0))
//            return;
//          }
          default:
          {
            return;
          }
        }
      }
      return;
    }
    // invalid:
    case 14:
    {
      if (SHOW_CSPS)
      {
        switch(ID.x)
        {
          case 0:
          {
            precise float precentageInvalid = tex2Dfetch(Storage_Consolidated, COORDS_SHOW_PERCENTAGE_INVALID).r;
            precise uint  curNumber         = _3rd(precentageInvalid);
            DrawNumberAboveZero(cspsOffset + uint2(9, 0))
            return;
          }
          case 1:
          {
            precise float precentageInvalid = tex2Dfetch(Storage_Consolidated, COORDS_SHOW_PERCENTAGE_INVALID).r;
            precise uint  curNumber         = _2nd(precentageInvalid);
            DrawNumberAboveZero(cspsOffset + uint2(9, 0))
            return;
          }
          case 2:
          {
            precise float precentageInvalid = tex2Dfetch(Storage_Consolidated, COORDS_SHOW_PERCENTAGE_INVALID).r;
            precise uint  curNumber         = _1st(precentageInvalid);
            DrawChar(uint2(curNumber, 0), cspsOffset + uint2(9, 0))
            return;
          }
          case 3:
          {
            precise float precentageInvalid = tex2Dfetch(Storage_Consolidated, COORDS_SHOW_PERCENTAGE_INVALID).r;
            precise uint  curNumber         = d1st(precentageInvalid);
            DrawChar(uint2(curNumber, 0), cspsOffset + uint2(10, 0))
            return;
          }
          case 4:
          {
            precise float precentageInvalid = tex2Dfetch(Storage_Consolidated, COORDS_SHOW_PERCENTAGE_INVALID).r;
            precise uint  curNumber         = d2nd(precentageInvalid);
            DrawChar(uint2(curNumber, 0), cspsOffset + uint2(10, 0))
            return;
          }
//          case 5:
//          {
//            precise float precentageInvalid = tex2Dfetch(Storage_Consolidated, COORDS_SHOW_PERCENTAGE_INVALID).r;
//            precise uint  curNumber         = d3rd(precentageInvalid);
//            DrawChar(uint2(curNumber, 0), cspsOffset + uint2(10, 0))
//            return;
//          }
//          case 6:
//          {
//            precise float precentageInvalid = tex2Dfetch(Storage_Consolidated, COORDS_SHOW_PERCENTAGE_INVALID).r;
//            precise uint  curNumber         = d4th(precentageInvalid);
//            DrawChar(uint2(curNumber, 0), cspsOffset + uint2(10, 0))
//            return;
//          }
          default:
          {
            return;
          }
        }
      }
      return;
    }

#endif

    // cursorCSP:
    case 15:
    {
      if (SHOW_CSP_FROM_CURSOR)
      {
        const uint cursorCSP = tex2Dfetch(Sampler_CSPs, mPos).r * 255.f;

        if (cursorCSP == IS_CSP_BT709)
        {
          switch(ID.x)
          {
            case 0:
            {
              DrawChar(_B, cursorCspOffset + uint2(11, 0))
              return;
            }
            case 1:
            {
              DrawChar(_T, cursorCspOffset + uint2(11, 0))
              return;
            }
            case 2:
            {
              DrawChar(_dot, cursorCspOffset + uint2(11, 0))
              return;
            }
            case 3:
            {
              DrawChar(_7, cursorCspOffset + uint2(11, 0))
              return;
            }
            case 4:
            {
              DrawChar(_0, cursorCspOffset + uint2(11, 0))
              return;
            }
            case 5:
            {
              DrawChar(_9, cursorCspOffset + uint2(11, 0))
              return;
            }
            case 6:
            {
              DrawChar(_space, cursorCspOffset + uint2(11, 0))
              return;
            }
            default:
            {
              return;
            }
          }
          return;
        }
        else if (cursorCSP == IS_CSP_DCI_P3)
        {
          switch(ID.x)
          {
            case 0:
            {
              DrawChar(_D, cursorCspOffset + uint2(11, 0))
              return;
            }
            case 1:
            {
              DrawChar(_C, cursorCspOffset + uint2(11, 0))
              return;
            }
            case 2:
            {
              DrawChar(_I, cursorCspOffset + uint2(11, 0))
              return;
            }
            case 3:
            {
              DrawChar(_minus, cursorCspOffset + uint2(11, 0))
              return;
            }
            case 4:
            {
              DrawChar(_P, cursorCspOffset + uint2(11, 0))
              return;
            }
            case 5:
            {
              DrawChar(_3, cursorCspOffset + uint2(11, 0))
              return;
            }
            case 6:
            {
              DrawChar(_space, cursorCspOffset + uint2(11, 0))
              return;
            }
            default:
            {
              return;
            }
          }
          return;
        }
        else if (cursorCSP == IS_CSP_BT2020)
        {
          switch(ID.x)
          {
            case 0:
            {
              DrawChar(_B, cursorCspOffset + uint2(11, 0))
              return;
            }
            case 1:
            {
              DrawChar(_T, cursorCspOffset + uint2(11, 0))
              return;
            }
            case 2:
            {
              DrawChar(_dot, cursorCspOffset + uint2(11, 0))
              return;
            }
            case 3:
            {
              DrawChar(_2, cursorCspOffset + uint2(11, 0))
              return;
            }
            case 4:
            {
              DrawChar(_0, cursorCspOffset + uint2(11, 0))
              return;
            }
            case 5:
            {
              DrawChar(_2, cursorCspOffset + uint2(11, 0))
              return;
            }
            case 6:
            {
              DrawChar(_0, cursorCspOffset + uint2(11, 0))
              return;
            }
            default:
            {
              return;
            }
          }
          return;
        }

#if (ACTUAL_COLOUR_SPACE != CSP_HDR10 \
  && ACTUAL_COLOUR_SPACE != CSP_HLG)

        else if (cursorCSP == IS_CSP_AP1)
        {
          switch(ID.x)
          {
            case 0:
            {
              DrawChar(_A, cursorCspOffset + uint2(11, 0))
              return;
            }
            case 1:
            {
              DrawChar(_P, cursorCspOffset + uint2(11, 0))
              return;
            }
            case 2:
            {
              DrawChar(_1, cursorCspOffset + uint2(11, 0))
              return;
            }
            case 3:
            {
              DrawChar(_space, cursorCspOffset + uint2(11, 0))
              return;
            }
            case 4:
            {
              DrawChar(_space, cursorCspOffset + uint2(11, 0))
              return;
            }
            case 5:
            {
              DrawChar(_space, cursorCspOffset + uint2(11, 0))
              return;
            }
            case 6:
            {
              DrawChar(_space, cursorCspOffset + uint2(11, 0))
              return;
            }
            default:
            {
              return;
            }
          }
          return;
        }
        else if (cursorCSP == IS_CSP_AP0)
        {
          switch(ID.x)
          {
            case 0:
            {
              DrawChar(_A, cursorCspOffset + uint2(11, 0))
              return;
            }
            case 1:
            {
              DrawChar(_P, cursorCspOffset + uint2(11, 0))
              return;
            }
            case 2:
            {
              DrawChar(_0, cursorCspOffset + uint2(11, 0))
              return;
            }
            case 3:
            {
              DrawChar(_space, cursorCspOffset + uint2(11, 0))
              return;
            }
            case 4:
            {
              DrawChar(_space, cursorCspOffset + uint2(11, 0))
              return;
            }
            case 5:
            {
              DrawChar(_space, cursorCspOffset + uint2(11, 0))
              return;
            }
            case 6:
            {
              DrawChar(_space, cursorCspOffset + uint2(11, 0))
              return;
            }
            default:
            {
              return;
            }
          }
          return;
        }
        else
        {
          switch(ID.x)
          {
            case 0:
            {
              DrawChar(_i, cursorCspOffset + uint2(11, 0))
              return;
            }
            case 1:
            {
              DrawChar(_n, cursorCspOffset + uint2(11, 0))
              return;
            }
            case 2:
            {
              DrawChar(_v, cursorCspOffset + uint2(11, 0))
              return;
            }
            case 3:
            {
              DrawChar(_a, cursorCspOffset + uint2(11, 0))
              return;
            }
            case 4:
            {
              DrawChar(_l, cursorCspOffset + uint2(11, 0))
              return;
            }
            case 5:
            {
              DrawChar(_i, cursorCspOffset + uint2(11, 0))
              return;
            }
            case 6:
            {
              DrawChar(_d, cursorCspOffset + uint2(11, 0))
              return;
            }
            default:
            {
              return;
            }
          }
          return;
        }

#endif

      }
      return;
    }

    default:
    {
      return;
    }
  }
}


#if (ACTUAL_COLOUR_SPACE == CSP_SCRGB)

  #define MAP_INTO_CSP Scrgb

#elif (ACTUAL_COLOUR_SPACE == CSP_HDR10)

  #define MAP_INTO_CSP Hdr10

#elif (ACTUAL_COLOUR_SPACE == CSP_HLG)

  #define MAP_INTO_CSP Hlg

#elif (ACTUAL_COLOUR_SPACE == CSP_PS5)

  #define MAP_INTO_CSP Ps5

#endif


void HDR_analysis(
      float4 VPos     : SV_Position,
      float2 TexCoord : TEXCOORD,
  out float4 Output   : SV_Target0)
{
  const float3 input = tex2D(ReShade::BackBuffer, TexCoord).rgb;

  Output = float4(input, 1.f);


#if (ACTUAL_COLOUR_SPACE == CSP_SCRGB \
  || ACTUAL_COLOUR_SPACE == CSP_HDR10 \
  || ACTUAL_COLOUR_SPACE == CSP_HLG   \
  || ACTUAL_COLOUR_SPACE == CSP_PS5)

  //float maxCLL = float(uint(tex2Dfetch(Sampler_Max_Avg_Min_CLL_Values, int2(0, 0)).r*10000.f+0.5)/100)/100.f;
  //float avgCLL = float(uint(tex2Dfetch(Sampler_Max_Avg_Min_CLL_Values, int2(1, 0)).r*10000.f+0.5)/100)/100.f;
  //float minCLL = float(uint(tex2Dfetch(Sampler_Max_Avg_Min_CLL_Values, int2(2, 0)).r*10000.f+0.5)/100)/100.f;

  if (SHOW_CSP_MAP
   || SHOW_HEATMAP
   || HIGHLIGHT_NIT_RANGE)
  {
    float pixelCLL = tex2D(Sampler_CLL_Values, TexCoord).r;

#if (ENABLE_CSP_FEATURES == YES)

    if (SHOW_CSP_MAP)
    {
      Output = float4(Create_CSP_Map(tex2D(Sampler_CSPs, TexCoord).r * 255.f,
                                     pixelCLL), 1.f);
    }

#endif

#if (ENABLE_CLL_FEATURES == YES)

    if (SHOW_HEATMAP)
    {
      Output = float4(Heatmap_RGB_Values(pixelCLL,
                                         HEATMAP_CUTOFF_POINT,
                                         HEATMAP_BRIGHTNESS,
                                         false), 1.f);
    }

    if (HIGHLIGHT_NIT_RANGE)
    {
      float pingpong0 = NIT_PINGPONG0.x + 0.25f;
      float pingpong1 = NIT_PINGPONG1.y == 1 ? NIT_PINGPONG1.x
                                             : 6.f - NIT_PINGPONG1.x;

      if (pixelCLL >= HIGHLIGHT_NIT_RANGE_START_POINT
       && pixelCLL <= HIGHLIGHT_NIT_RANGE_END_POINT
       && pingpong0 >= 1.f)
      {
        float3 out3;
        float breathing = saturate(pingpong0 - 1.f);
        //float breathing = 1.f;

        if (pingpong1 >= 0.f
         && pingpong1 <= 1.f)
        {
          out3 = float3(1.f, NIT_PINGPONG2.x, 0.f);
        }
        else if (pingpong1 > 1.f
              && pingpong1 <= 2.f)
        {
          out3 = float3(NIT_PINGPONG2.x, 1.f, 0.f);
        }
        else if (pingpong1 > 2.f
              && pingpong1 <= 3.f)
        {
          out3 = float3(0.f, 1.f, NIT_PINGPONG2.x);
        }
        else if (pingpong1 > 3.f
              && pingpong1 <= 4.f)
        {
          out3 = float3(0.f, NIT_PINGPONG2.x, 1.f);
        }
        else if (pingpong1 > 4.f
              && pingpong1 <= 5.f)
        {
          out3 = float3(NIT_PINGPONG2.x, 0.f, 1.f);
        }
        else if (pingpong1 > 5.f
              && pingpong1 <= 6.f)
        {
          out3 = float3(1.f, 0.f, NIT_PINGPONG2.x);
        }

        out3 *= breathing * HIGHLIGHT_NIT_RANGE_BRIGHTNESS;

        out3 = Csp::Map::Bt709Into::MAP_INTO_CSP(out3);

        if (breathing > 0.f)
        {
          //Output = float4(out3, 1.f);
          Output = float4(lerp(Output.rgb, out3, breathing), 1.f);
        }
      }
    }

#endif
  }

#if (ENABLE_CLL_FEATURES == YES)

  if (DRAW_ABOVE_NITS_AS_BLACK)
  {
    float pixelCLL = tex2D(Sampler_CLL_Values, TexCoord).r;
    if (pixelCLL > ABOVE_NITS_AS_BLACK)
    {
      Output = (0.f, 0.f, 0.f, 0.f);
    }
  }
  if (DRAW_BELOW_NITS_AS_BLACK)
  {
    float pixelCLL = tex2D(Sampler_CLL_Values, TexCoord).r;
    if (pixelCLL < BELOW_NITS_AS_BLACK)
    {
      Output = (0.f, 0.f, 0.f, 0.f);
    }
  }

#endif

#if (ENABLE_CIE_FEATURES == YES)

  if (SHOW_CIE)
  {
    uint current_x_coord = TexCoord.x * BUFFER_WIDTH;  // expand to actual pixel values
    uint current_y_coord = TexCoord.y * BUFFER_HEIGHT; // ^

    const int2 textureDisplaySize =
      int2(round(float(CIE_BG_X) * CIE_DIAGRAM_SIZE / 100.f),
           round(float(CIE_BG_Y) * CIE_DIAGRAM_SIZE / 100.f));

    // draw the diagram in the bottom left corner
    if (current_x_coord <  textureDisplaySize.x
     && current_y_coord >= (BUFFER_HEIGHT - textureDisplaySize.y))
    {
      // get coords for the sampler
      float2 currentSamplerCoords = float2(
        (current_x_coord + 0.5f) / textureDisplaySize.x,
        (current_y_coord - (BUFFER_HEIGHT - textureDisplaySize.y) + 0.5f) / textureDisplaySize.y);

#if (CIE_DIAGRAM == CIE_1931)
  #define CIE_SAMPLER Sampler_CIE_1931_Current
#else
  #define CIE_SAMPLER Sampler_CIE_1976_Current
#endif

      float3 currentPixelToDisplay =
        pow(tex2D(CIE_SAMPLER, currentSamplerCoords).rgb, 2.2f) * CIE_DIAGRAM_BRIGHTNESS;

#undef CIE_SAMPLER

      Output = float4(Csp::Map::Bt709Into::MAP_INTO_CSP(currentPixelToDisplay), 1.f);

    }
  }

#endif

  if (SHOW_BRIGHTNESS_HISTOGRAM)
  {

    uint current_x_coord = TexCoord.x * BUFFER_WIDTH;  // expand to actual pixel values
    uint current_y_coord = TexCoord.y * BUFFER_HEIGHT; // ^

    const int2 textureDisplaySize =
      int2(round(float(TEXTURE_BRIGHTNESS_HISTOGRAM_SCALE_WIDTH)  * BRIGHTNESS_HISTOGRAM_SIZE / 100.f),
           round(float(TEXTURE_BRIGHTNESS_HISTOGRAM_SCALE_HEIGHT) * BRIGHTNESS_HISTOGRAM_SIZE / 100.f));

    // draw the histogram in the bottom right corner
    if (current_x_coord >= (BUFFER_WIDTH  - textureDisplaySize.x)
     && current_y_coord >= (BUFFER_HEIGHT - textureDisplaySize.y))
    {
      // get coords for the sampler
      float2 currentSamplerCoords = float2(
        (textureDisplaySize.x - (BUFFER_WIDTH - current_x_coord)  + 0.5f) / textureDisplaySize.x,
        (current_y_coord - (BUFFER_HEIGHT - textureDisplaySize.y) + 0.5f) / textureDisplaySize.y);

      float3 currentPixelToDisplay =
        tex2D(Sampler_Brightness_Histogram_Final, currentSamplerCoords).rgb;

      Output = float4(Csp::Map::Bt709Into::MAP_INTO_CSP(currentPixelToDisplay * BRIGHTNESS_HISTOGRAM_BRIGHTNESS), 1.f);

    }
  }

  uint2 currentActiveOverlayArea = GetCharSize() * uint2(30, 16);
  if ((TexCoord.x * BUFFER_WIDTH)  <= currentActiveOverlayArea.x
   && (TexCoord.x * BUFFER_HEIGHT) <= currentActiveOverlayArea.y)
  {

    float4 overlay = tex2D(SamplerTextOverlay, TexCoord).rgba;
    overlay = pow(overlay, 2.2f);

#if (ACTUAL_COLOUR_SPACE == CSP_SCRGB)

    overlay = float4(Csp::Map::Bt709Into::Scrgb(overlay.rgb * FONT_BRIGHTNESS), pow(overlay.a, 1.f / 2.6f));

#elif (ACTUAL_COLOUR_SPACE == CSP_HDR10)

    overlay = float4(Csp::Map::Bt709Into::Hdr10(overlay.rgb * FONT_BRIGHTNESS), overlay.a);

#elif (ACTUAL_COLOUR_SPACE == CSP_HLG)

    overlay = float4(Csp::Map::Bt709Into::Hlg(overlay.rgb * FONT_BRIGHTNESS), overlay.a);

#elif (ACTUAL_COLOUR_SPACE == CSP_PS5)

    overlay = float4(Csp::Map::Bt709Into::Ps5(overlay.rgb * FONT_BRIGHTNESS), pow(overlay.a, 1.f / 2.6f));

#endif

    Output = float4(lerp(Output.rgb, overlay.rgb, overlay.a), 1.f);

  }

}

#else

  Output = float4(input, 1.f);
  DrawTextString(float2(0.f, 0.f), 100.f, 1, TexCoord, text_Error, 26, Output, 1.f);
}

#endif

//technique lilium__HDR_analysis_CLL_OLD
//<
//  enabled = false;
//>
//{
//  pass CalcCLLvalues
//  {
//    VertexShader = PostProcessVS;
//     PixelShader = CalcCLL;
//    RenderTarget = Texture_CLL_Values;
//  }
//
//  pass GetMaxAvgMinCLLvalue0
//  {
//    ComputeShader = GetMaxAvgMinCLL0 <THREAD_SIZE1, 1>;
//    DispatchSizeX = DISPATCH_X1;
//    DispatchSizeY = 1;
//  }
//
//  pass GetMaxAvgMinCLLvalue1
//  {
//    ComputeShader = GetMaxAvgMinCLL1 <1, 1>;
//    DispatchSizeX = 1;
//    DispatchSizeY = 1;
//  }
//
//  pass GetMaxCLLvalue0
//  {
//    ComputeShader = getMaxCLL0 <THREAD_SIZE1, 1>;
//    DispatchSizeX = DISPATCH_X1;
//    DispatchSizeY = 1;
//  }
//
//  pass GetMaxCLLvalue1
//  {
//    ComputeShader = getMaxCLL1 <1, 1>;
//    DispatchSizeX = 1;
//    DispatchSizeY = 1;
//  }
//
//  pass GetAvgCLLvalue0
//  {
//    ComputeShader = getAvgCLL0 <THREAD_SIZE1, 1>;
//    DispatchSizeX = DISPATCH_X1;
//    DispatchSizeY = 1;
//  }
//
//  pass GetAvgCLLvalue1
//  {
//    ComputeShader = getAvgCLL1 <1, 1>;
//    DispatchSizeX = 1;
//    DispatchSizeY = 1;
//  }
//
//  pass GetMinCLLvalue0
//  {
//    ComputeShader = getMinCLL0 <THREAD_SIZE1, 1>;
//    DispatchSizeX = DISPATCH_X1;
//    DispatchSizeY = 1;
//  }
//
//  pass GetMinCLLvalue1
//  {
//    ComputeShader = getMinCLL1 <1, 1>;
//    DispatchSizeX = 1;
//    DispatchSizeY = 1;
//  }
//}


technique lilium__hdr_analysis
<
  ui_label = "Lilium's HDR analysis";
>
{

#ifdef _TESTY

  pass test_thing
  {
    VertexShader = PostProcessVS;
     PixelShader = Testy;
  }

#endif


//CLL
#if (ENABLE_CLL_FEATURES == YES)

  pass CalcCLLvalues
  {
    VertexShader = PostProcessVS;
     PixelShader = CalcCLL;
    RenderTarget = Texture_CLL_Values;
  }

  pass GetMaxAvgMinCLL0_NEW
  {
    ComputeShader = GetMaxAvgMinCLL0_NEW <THREAD_SIZE1, 1>;
    DispatchSizeX = DISPATCH_X1;
    DispatchSizeY = 2;
  }

  pass GetMaxAvgMinCLL1_NEW
  {
    ComputeShader = GetMaxAvgMinCLL1_NEW <1, 1>;
    DispatchSizeX = 2;
    DispatchSizeY = 2;
  }

  pass GetFinalMaxAvgMinCLL_NEW
  {
    ComputeShader = GetFinalMaxAvgMinCLL_NEW <1, 1>;
    DispatchSizeX = 1;
    DispatchSizeY = 1;
  }

  pass ClearBrightnessHistogramTexture
  {
    VertexShader       = PostProcessVS;
     PixelShader       = ClearBrightnessHistogramTexture;
    RenderTarget       = Texture_Brightness_Histogram;
    ClearRenderTargets = true;
  }

  pass ComputeBrightnessHistogram
  {
    ComputeShader = ComputeBrightnessHistogram <THREAD_SIZE0, 1>;
    DispatchSizeX = DISPATCH_X0;
    DispatchSizeY = 1;
  }

  pass RenderBrightnessHistogramToScale
  {
    VertexShader = PostProcessVS;
     PixelShader = RenderBrightnessHistogramToScale;
    RenderTarget = Texture_Brightness_Histogram_Final;
  }
#endif


//CIE
#if (ENABLE_CIE_FEATURES == YES)

#if (CIE_DIAGRAM == CIE_1931)
  pass Copy_CIE_1931_BG
  {
    VertexShader = PostProcessVS;
     PixelShader = Copy_CIE_1931_BG;
    RenderTarget = Texture_CIE_1931_Current;
  }
#endif

#if (CIE_DIAGRAM == CIE_1976)
  pass Copy_CIE_1976_BG
  {
    VertexShader = PostProcessVS;
     PixelShader = Copy_CIE_1976_BG;
    RenderTarget = Texture_CIE_1976_Current;
  }
#endif

  pass Generate_CIE_Diagram
  {
    ComputeShader = Generate_CIE_Diagram <THREAD_SIZE1, THREAD_SIZE1>;
    DispatchSizeX = DISPATCH_X1;
    DispatchSizeY = DISPATCH_Y1;
  }

#endif


//CSP
#if (ENABLE_CSP_FEATURES == YES \
  && ACTUAL_COLOUR_SPACE != CSP_SRGB)

  pass CalcCSPs
  {
    VertexShader = PostProcessVS;
     PixelShader = CalcCSPs;
    RenderTarget = Texture_CSPs;
  }

  pass CountCSPs_y
  {
    ComputeShader = CountCSPs_y <THREAD_SIZE0, 1>;
    DispatchSizeX = DISPATCH_X0;
    DispatchSizeY = 1;
  }

  pass CountCSPs_x
  {
    ComputeShader = CountCSPs_x <1, 1>;
    DispatchSizeX = 1;
    DispatchSizeY = 1;
  }

#endif

  pass CopyShowValues
  {
    ComputeShader = ShowValuesCopy <1, 1>;
    DispatchSizeX = 1;
    DispatchSizeY = 1;
  }


  pass PrepareOverlay
  {
    ComputeShader = PrepareOverlay <1, 1>;
    DispatchSizeX = 1;
    DispatchSizeY = 1;
  }

  pass DrawOverlay
  {
    ComputeShader = DrawOverlay <1, 1>;
    DispatchSizeX = 17;
    DispatchSizeY = 16;
  }

  pass DrawNumbersToOverlay
  {
    ComputeShader = DrawNumbersToOverlay <1, 1>;
    DispatchSizeX = 15;
    DispatchSizeY = 16;
  }

//  pass DrawToOverlay
//  {
//    VertexShader = VS_PrepareDrawToOverlay;
//     PixelShader = PS_DrawToOverlay;
//    RenderTarget = TextureTextOverlay;
//    ClearRenderTargets = false;
//  }


  pass HDR_analysis
  {
    VertexShader = PostProcessVS;
     PixelShader = HDR_analysis;
  }
}

#else

uniform int GLOBAL_INFO
<
  ui_category = "info";
  ui_label    = " ";
  ui_type     = "radio";
  ui_text     = "Only DirectX 11, 12 and Vulkan are supported!";
>;

#endif
