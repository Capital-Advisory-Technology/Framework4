#property copyright "Copyright � 2012, Vladimirs Forex Signals and Mentoring"
#property link      "http://www.VladimirForexSignals.com"

#property indicator_separate_window
#property indicator_levelcolor Black
#property indicator_buffers 7
#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_color3 Green
#property indicator_color4 Red
#property indicator_color5 LimeGreen
#property indicator_color6 Maroon
#property indicator_color7 Black

string gs_76 = "Vladimir_Ribakov_Divergence_Recognition";
bool gi_84 = TRUE;
bool gi_88 = TRUE;
bool gi_92 = FALSE;
string gs_unused_96 = "";
int g_period_104 = 12;
int g_period_108 = 26;
int g_period_112 = 9;
extern int Line_Distance = 1;
extern int Max_Bars_Lookback = 250;
bool gi_124 = TRUE;
bool gi_128 = FALSE;
int gi_132 = 60;
double gd_136 = 0.0;
double gd_144 = 0.0;
bool gi_152 = FALSE;
double gd_156 = 7.0;
double gd_164 = 0.00007;
int gi_172 = 1;
int gi_176 = 6333684;
int gi_180 = 255;
int gi_184 = 64636;
int gi_188 = 32768;
int gi_192 = 2;
int gi_196 = 1;
int gi_200 = 2237106;
int gi_204 = 25600;
bool gi_208 = FALSE;
bool gi_unused_212 = FALSE;
bool gi_unused_216 = FALSE;
double gd_220 = 0.000015;
double gd_228 = 99.0;
double g_ibuf_236[];
double g_ibuf_240[];
double g_ibuf_244[];
double g_ibuf_248[];
double g_ibuf_252[];
double g_ibuf_256[];
double g_ibuf_260[];
string gs_264 = "";
double gd_unused_272 = 0.0004;
double gd_280 = 1.0;
int g_bars_288 = 0;
double gd_292 = 0.0;
double gd_300 = 0.0;
int gi_unused_308 = 0;
int gi_unused_312 = 0;
int gi_316 = 0;
int gi_320 = 0;
int gi_324 = 0;
int gi_328 = 0;
double g_low_332 = 0.0;
double gd_340 = 0.0;
double gd_348 = 0.0;
double gd_356 = 0.0;
int gi_364 = 0;
int gi_368 = 0;
int gi_372 = 0;
int gi_376 = 0;
double g_high_380 = 0.0;
double gd_388 = 0.0;
double gd_396 = 0.0;
double gd_404 = 0.0;
int gi_412 = 0;
int gi_416 = 0;
double gd_420 = 0.0;
double gd_428 = 0.0;
int g_bars_436 = -1;
double gda_440[1][11];
string gs_444 = "Vladimir_Ribakov_Divergence_";

int init() {
   IndicatorBuffers(9);
   SetIndexBuffer(0, g_ibuf_236);
   SetIndexBuffer(1, g_ibuf_240);
   SetIndexBuffer(2, g_ibuf_244);
   SetIndexBuffer(3, g_ibuf_248);
   SetIndexBuffer(4, g_ibuf_252);
   SetIndexBuffer(5, g_ibuf_256);
   SetIndexBuffer(6, g_ibuf_260);
   SetIndexStyle(0, DRAW_NONE, STYLE_SOLID);
   SetIndexStyle(1, DRAW_NONE, STYLE_SOLID);
   SetIndexStyle(2, DRAW_HISTOGRAM);
   SetIndexStyle(3, DRAW_HISTOGRAM);
   SetIndexStyle(4, DRAW_HISTOGRAM);
   SetIndexStyle(5, DRAW_HISTOGRAM);
   SetIndexStyle(6, DRAW_NONE);
   SetIndexArrow(0, 233);
   SetIndexArrow(1, 234);
   SetIndexLabel(0, "MACD");
   SetIndexLabel(1, "Signal");
   SetIndexLabel(2, "HistogramUP");
   SetIndexLabel(3, "HistogramDOWN");
   SetIndexLabel(4, "HistogramUP1");
   SetIndexLabel(5, "HistogramDOWN1");
   gs_264 = gs_76;
   IndicatorDigits(6);
   IndicatorShortName(gs_264);
   if (_Point == 0.00001) gd_280 = 10;
   if (gd_136 > 0.0 || gd_144 > 0.0) {
      gd_292 = gd_136;
      gd_300 = gd_144;
   } else {
      switch (Period()) {
      case PERIOD_M1:
         gd_292 = 1;
         gd_300 = 0.000003;
         gd_unused_272 = 0.00005;
         break;
      case PERIOD_M5:
         gd_292 = 1;
         gd_300 = 0.000003;
         gd_unused_272 = 0.0001;
         break;
      case PERIOD_M15:
         gd_292 = 1;
         gd_300 = 0.000003;
         gd_unused_272 = 0.0002;
         break;
      case PERIOD_M30:
         gd_292 = 1;
         gd_300 = 0.000003;
         gd_unused_272 = 0.0002;
         break;
      case PERIOD_H1:
         gd_292 = 1;
         gd_300 = 0.00005;
         gd_unused_272 = 0.0003;
         Line_Distance += 4;
         break;
      case PERIOD_H4:
         gd_292 = 1;
         gd_300 = 0.0001;
         gd_unused_272 = 0.0008;
         Line_Distance += 3;
         break;
      case PERIOD_D1:
         gd_292 = 1;
         gd_300 = 0.0001;
         gd_unused_272 = 0.003;
         Line_Distance += 4;
         break;
      case PERIOD_W1:
         gd_292 = 1;
         gd_300 = 0.0001;
         gd_unused_272 = 0.008;
         Line_Distance += 4;
         break;
      case PERIOD_MN1:
         gd_292 = 1;
         gd_300 = 0.0001;
         gd_unused_272 = 0.01;
         Line_Distance += 4;
      }
   }
   g_bars_436 = -1;
   g_bars_288 = FALSE;
   return (0);
}

int deinit() {
   string name_4;
   for (int li_0 = ObjectsTotal() - 1; li_0 >= 0; li_0--) {
      name_4 = ObjectName(li_0);
      if (StringSubstr(name_4, 0, StringLen(gs_444)) == gs_444) ObjectDelete(name_4);
   }
   return (0);
}

int start() {
   double ld_4;
   double ld_12;
   int li_20;
   int bars_24;
   int li_unused_32;
   int li_40;
   double ld_unused_44;
   double ld_52;
   int ind_counted_0 = IndicatorCounted();
   if (Bars - ind_counted_0 >= 2 || g_bars_288 != Bars) {
      li_20 = 2;
      bars_24 = Bars;
      if (g_bars_436 == -1 || g_bars_288 != Bars) li_20 = bars_24;
      g_bars_288 = Bars;
      for (int li_28 = 1; li_28 < li_20; li_28++) g_ibuf_236[li_28] = iMA(Symbol(), Period(), g_period_104, 0, MODE_EMA, PRICE_CLOSE, li_28) - iMA(Symbol(), Period(), g_period_108, 0, MODE_EMA, PRICE_CLOSE, li_28);
      for (li_28 = li_20; li_28 >= 1; li_28--) {
         g_ibuf_240[li_28] = iMAOnArray(g_ibuf_236, bars_24, g_period_112, 0, MODE_EMA, li_28);
         g_ibuf_260[li_28] = g_ibuf_236[li_28] - g_ibuf_240[li_28];
         g_ibuf_240[li_28] = g_ibuf_240[li_28];
         g_ibuf_260[li_28] = g_ibuf_260[li_28];
         ld_12 = g_ibuf_260[li_28];
         ld_4 = g_ibuf_260[li_28 + 1];
         if (ld_12 >= ld_4) {
            if (g_ibuf_260[li_28] >= 0.0) {
               g_ibuf_244[li_28] = g_ibuf_260[li_28];
               continue;
            }
            g_ibuf_248[li_28] = g_ibuf_260[li_28];
         } else {
            if (g_ibuf_260[li_28] >= 0.0) g_ibuf_252[li_28] = g_ibuf_260[li_28];
            else g_ibuf_256[li_28] = g_ibuf_260[li_28];
         }
      }
      g_bars_436 = bars_24;
      if (li_20 > 2) li_20 = Max_Bars_Lookback;
      li_unused_32 = -1;
      for (int li_36 = li_20; li_36 >= 2; li_36--) {
         li_40 = f0_11(li_36);
         if (li_40 == 12 || li_40 == 16 || li_40 == 22 || li_40 == 26) {
            li_unused_32 = li_40;
            ld_unused_44 = f0_7(li_40, Time[li_36], 7);
         }
         if (li_40 == 11 || li_40 == 15) {
            ld_52 = -1.0 * Line_Distance;
            f0_6(11, "bull.regu", Time[li_36], ld_52, gi_184, gi_192);
         }
         if (li_40 == 12 || li_40 == 16) {
            ld_52 = -1.0 * Line_Distance;
            f0_6(12, "bull.cont", Time[li_36], ld_52, gi_188, gi_192);
         }
         if (li_40 == 14 || li_40 == 15 || li_40 == 16) {
            ld_52 = -1.0 * Line_Distance;
            f0_6(li_40, "bull.hidd", Time[li_36], ld_52, gi_204, gi_196);
         }
         if (li_40 == 21 || li_40 == 25) {
            ld_52 = Line_Distance;
            f0_6(21, "bear.regu", Time[li_36], ld_52, gi_176, gi_192);
         }
         if (li_40 == 22 || li_40 == 26) {
            ld_52 = Line_Distance;
            f0_6(22, "bear.cont", Time[li_36], ld_52, gi_180, gi_192);
         }
         if (li_40 == 24 || li_40 == 25 || li_40 == 26) {
            ld_52 = Line_Distance;
            f0_6(li_40, "bear.hidd", Time[li_36], ld_52, gi_200, gi_196);
         }
      }
   }
   return (0);
}

int f0_11(int ai_0) {
   int li_20;
   int li_24;
   int li_4 = -1;
   int li_8 = -1;
   int li_ret_12 = -1;
   gi_316 = f0_1(ai_0, ai_0 + 1, gi_172, 1, 0);
   gi_320 = -1;
   if (gi_316 > -1) {
      if (gi_316 == ai_0) {
         if (gi_92 == TRUE)
            if (NormalizeDouble(Close[gi_316 - 1], Digits) < NormalizeDouble(Open[gi_316 - 1], Digits)) gi_320 = -2;
         if (gi_320 != -2) gi_320 = f0_12(gi_316, gi_316 + 1);
      } else {
         if (gi_316 == ai_0 + 1) {
            if (gi_92 == TRUE)
               if (NormalizeDouble(Close[gi_316 - 1], Digits) < NormalizeDouble(Open[gi_316 - 1], Digits)) gi_320 = -2;
            if (gi_320 != -2) {
               for (int li_16 = ArrayRange(gda_440, 0); li_16 >= 0; li_16--)
                  if (gda_440[li_16][10] == Time[ai_0 + 1]) gi_320 = -2;
            }
            if (NormalizeDouble(Close[gi_316 - 1], Digits) < NormalizeDouble(Open[gi_316 - 1], Digits) && NormalizeDouble(Close[gi_316 - 2], Digits) < NormalizeDouble(Open[gi_316 - 2],
               Digits)) gi_320 = -2;
            if (gi_320 != -2) gi_320 = gi_316;
         }
      }
      if (gi_320 > -1) {
         g_low_332 = Low[gi_316];
         gd_348 = g_ibuf_260[gi_320];
         gi_324 = -1;
         gd_340 = 0;
         if (gi_124 == TRUE) {
            if (NormalizeDouble(gd_348, 6) < NormalizeDouble(0.0, 6)) gi_416 = 5;
            else gi_416 = 2;
            gi_412 = 1;
            gd_420 = 0;
            for (li_16 = ai_0 + 4; li_16 <= Max_Bars_Lookback; li_16++) {
               if ((NormalizeDouble(gd_220, 6) < NormalizeDouble(g_ibuf_260[li_16], 6) && NormalizeDouble(g_ibuf_260[li_16 - 1], 6) <= NormalizeDouble(gd_220, 6)) || (NormalizeDouble(g_ibuf_260[li_16],
                  6) < NormalizeDouble(gd_220, 8) && NormalizeDouble(gd_220, 6) <= NormalizeDouble(g_ibuf_260[li_16 - 1], 6))) {
                  gi_412++;
                  if (gi_416 < gi_412) break;
               }
               if (NormalizeDouble(g_ibuf_260[li_16], 6) < NormalizeDouble(gd_420, 6)) {
                  gd_420 = g_ibuf_260[li_16];
                  gd_340 = 99999;
                  li_20 = f0_1(li_16 - 2, li_16 + 2, gi_172, 2, g_low_332);
                  if (li_20 > -1 && li_20 - gi_320 > 5) {
                     gi_328 = f0_12(li_20 - 2, li_20 + 2);
                     if (gi_328 > -1) {
                        gd_356 = g_ibuf_260[gi_328];
                        if (NormalizeDouble(gd_356, 6) < NormalizeDouble(0.0, 6) && NormalizeDouble(gd_300, 6) <= NormalizeDouble(gd_348 - gd_356, 6)) {
                           if (NormalizeDouble(gd_292 * gd_280 * _Point, Digits) <= NormalizeDouble(gd_340 - g_low_332, Digits))
                              if (f0_5(gd_340, g_low_332, li_20, gi_316) == 0) gi_324 = li_20;
                        }
                     }
                  }
               }
               if (gi_324 != -1) break;
            }
            if (gi_324 != -1) {
               li_4 = f0_0(gi_324, gi_316, gd_340, g_low_332, "Low", 11, ai_0, gi_328, gi_320);
               li_ret_12 = li_4;
            }
         }
         if (gi_128 == TRUE) {
            if (NormalizeDouble(gd_348, 6) < NormalizeDouble(0.0, 6)) {
               gi_416 = 3;
               gi_412 = 1;
               for (li_16 = ai_0 + 4; li_16 <= Max_Bars_Lookback; li_16++) {
                  if ((NormalizeDouble(gd_220, 6) < NormalizeDouble(g_ibuf_260[li_16], 6) && NormalizeDouble(g_ibuf_260[li_16 - 1], 6) <= NormalizeDouble(gd_220, 6)) || (NormalizeDouble(g_ibuf_260[li_16],
                     6) < NormalizeDouble(gd_220, 6) && NormalizeDouble(gd_220, 6) <= NormalizeDouble(g_ibuf_260[li_16 - 1], 6))) {
                     if (gi_416 < gi_412) break;
                     gi_412++;
                  }
                  if (NormalizeDouble(gd_348 * gd_228 / 100.0, 6) < NormalizeDouble(g_ibuf_260[li_16], 6)) {
                     li_20 = f0_1(li_16 - 2, li_16 + 2, gi_172, 2, gd_348);
                     if (li_20 > -1 && li_20 - gi_320 > 5) {
                        gi_328 = f0_12(li_20 - 2, li_20 + 2);
                        if (gi_328 > -1) {
                           gd_356 = g_ibuf_260[gi_328];
                           if (NormalizeDouble(gd_356, 6) < NormalizeDouble(0.0, 6) && (gi_152 == FALSE && NormalizeDouble(gd_348, 6) <= NormalizeDouble(gd_356, 6)) || (gi_152 == TRUE && NormalizeDouble(gd_164,
                              6) <= NormalizeDouble(gd_356 - gd_348, 6))) {
                              gd_340 = Low[li_20];
                              if ((gi_152 == FALSE && NormalizeDouble(gd_340, Digits) <= NormalizeDouble(g_low_332, Digits)) || (gi_152 == TRUE && NormalizeDouble(gd_156 * gd_280 * _Point, Digits) <= NormalizeDouble(g_low_332 - gd_340,
                                 Digits)))
                                 if (f0_5(gd_340, g_low_332, li_20, gi_316) == 0) gi_324 = li_20;
                           }
                        }
                     }
                     if (gi_324 != -1) break;
                  }
               }
               if (gi_324 != -1) {
                  li_8 = f0_0(gi_324, gi_316, gd_340, g_low_332, "Low", 14, ai_0, gi_328, gi_320);
                  li_ret_12 = li_8;
                  if (li_8 > -1) {
                     if (li_4 == 11 && li_8 == 14) li_ret_12 = 15;
                     else
                        if (li_4 == 12 && li_8 == 14) li_ret_12 = 16;
                  }
               }
            }
         }
         if (li_ret_12 > -1) return (li_ret_12);
      }
   }
   gi_364 = f0_10(ai_0, ai_0 + 1, gi_172, 1, 0);
   gi_368 = -1;
   if (gi_364 > -1) {
      if (gi_364 == ai_0) {
         if (gi_92 == TRUE)
            if (NormalizeDouble(Open[gi_364 - 1], Digits) < NormalizeDouble(Close[gi_364 - 1], Digits)) gi_368 = -2;
         if (gi_368 != -2) gi_368 = f0_4(gi_364, gi_364 + 1);
      } else {
         if (gi_364 == ai_0 + 1) {
            for (li_16 = ArrayRange(gda_440, 0); li_16 >= 0; li_16--)
               if (gda_440[li_16][10] == Time[ai_0 + 1]) gi_368 = -2;
            if (gi_368 != -2) {
               if (gi_92 == TRUE) {
                  if (NormalizeDouble(Open[gi_364 - 1], Digits) < NormalizeDouble(Close[gi_364 - 1], Digits) && NormalizeDouble(Open[gi_364 - 2], Digits) < NormalizeDouble(Close[gi_364 - 2],
                     Digits)) gi_368 = -2;
               }
               if (gi_368 != -2) gi_368 = gi_364;
            }
         }
      }
      if (gi_368 > -1) {
         g_high_380 = High[gi_364];
         gd_396 = g_ibuf_260[gi_368];
         gi_372 = -1;
         gd_388 = 0;
         if (gi_124 == TRUE) {
            if (NormalizeDouble(0.0, 6) < NormalizeDouble(gd_396, 6)) gi_416 = 5;
            else gi_416 = 2;
            gi_412 = 1;
            gd_428 = 0;
            for (li_16 = ai_0 + 3; li_16 <= Max_Bars_Lookback; li_16++) {
               if ((NormalizeDouble(-1.0 * gd_220, 6) < NormalizeDouble(g_ibuf_260[li_16], 6) && NormalizeDouble(g_ibuf_260[li_16 - 1], 6) <= NormalizeDouble(-1.0 * gd_220, 6)) ||
                  (NormalizeDouble(g_ibuf_260[li_16], 6) < NormalizeDouble(-1.0 * gd_220, 6) && NormalizeDouble(-1.0 * gd_220, 6) <= NormalizeDouble(g_ibuf_260[li_16 - 1], 6))) {
                  gi_412++;
                  if (gi_416 < gi_412) break;
               }
               if (NormalizeDouble(gd_428, 6) < NormalizeDouble(g_ibuf_260[li_16], 6)) {
                  gd_428 = g_ibuf_260[li_16];
                  gd_388 = 0;
                  li_24 = f0_10(li_16 - 2, li_16 + 2, gi_172, 2, g_high_380);
                  if (li_24 > -1 && li_24 - gi_364 > 5) {
                     gi_376 = f0_4(li_24 - 2, li_24 + 2);
                     if (gi_376 > -1) {
                        gd_404 = g_ibuf_260[gi_376];
                        if (NormalizeDouble(0.0, 6) < NormalizeDouble(gd_404, 6) && NormalizeDouble(gd_300, 6) <= NormalizeDouble(gd_404 - gd_396, 6)) {
                           if (NormalizeDouble(gd_292 * gd_280 * _Point, Digits) <= NormalizeDouble(g_high_380 - gd_388, Digits))
                              if (f0_3(gd_388, g_high_380, li_24, gi_364) == 0) gi_372 = li_24;
                        }
                     }
                  }
               }
               if (gi_372 != -1) break;
            }
            if (gi_372 != -1) {
               li_4 = f0_0(gi_372, gi_364, gd_388, g_high_380, "High", 21, ai_0, gi_376, gi_368);
               li_ret_12 = li_4;
            }
         }
         if (gi_128 == TRUE) {
            if (NormalizeDouble(0.0, 6) < NormalizeDouble(gd_396, 6)) {
               gi_416 = 3;
               gi_412 = 1;
               for (li_16 = ai_0 + 4; li_16 <= Max_Bars_Lookback; li_16++) {
                  if ((NormalizeDouble(-1.0 * gd_220, 6) < NormalizeDouble(g_ibuf_260[li_16], 6) && NormalizeDouble(g_ibuf_260[li_16 - 1], 6) <= NormalizeDouble(-1.0 * gd_220, 6)) ||
                     (NormalizeDouble(g_ibuf_260[li_16], 6) < NormalizeDouble(-1.0 * gd_220, 6) && NormalizeDouble(-1.0 * gd_220, 6) <= NormalizeDouble(g_ibuf_260[li_16 - 1], 6))) {
                     if (gi_416 < gi_412) break;
                     gi_412++;
                  }
                  if (NormalizeDouble(g_ibuf_260[li_16], 6) < NormalizeDouble(gd_396 * gd_228 / 100.0, 6)) {
                     li_24 = f0_10(li_16 - 2, li_16 + 2, gi_172, 2, g_high_380);
                     if (li_24 > -1 && li_24 - gi_364 > 5) {
                        gi_376 = f0_4(li_24 - 2, li_24 + 2);
                        if (gi_376 > -1) {
                           gd_404 = g_ibuf_260[gi_376];
                           if (NormalizeDouble(0.0, 6) < NormalizeDouble(gd_404, 6) && (gi_152 == FALSE && NormalizeDouble(gd_404, 6) <= NormalizeDouble(gd_396, 6)) || (gi_152 == TRUE && NormalizeDouble(gd_164,
                              6) <= NormalizeDouble(gd_396 - gd_404, 6))) {
                              gd_388 = High[li_24];
                              if ((gi_152 == FALSE && NormalizeDouble(g_high_380, Digits) <= NormalizeDouble(gd_388, Digits)) || (gi_152 == TRUE && NormalizeDouble(gd_156 * gd_280 * _Point, Digits) <= NormalizeDouble(gd_388 - g_high_380,
                                 Digits)))
                                 if (f0_3(gd_388, g_high_380, li_24, gi_364) == 0) gi_372 = li_24;
                           }
                        }
                     }
                     if (gi_372 != -1) break;
                  }
               }
               if (gi_372 != -1) {
                  li_8 = f0_0(gi_372, gi_364, gd_388, g_high_380, "High", 24, ai_0, gi_376, gi_368);
                  li_ret_12 = li_8;
                  if (li_8 > -1) {
                     if (li_4 == 21 && li_8 == 24) li_ret_12 = 25;
                     else
                        if (li_4 == 22 && li_8 == 24) li_ret_12 = 26;
                  }
               }
            }
         }
         if (li_ret_12 > -1) return (li_ret_12);
      }
   }
   return (li_ret_12);
}

int f0_1(int ai_0, int ai_4, int ai_8, int ai_12, double ad_16) {
   int li_ret_24 = -1;
   for (int li_28 = ai_0; li_28 <= ai_4; li_28++) {
      if (NormalizeDouble(Low[li_28], Digits) <= NormalizeDouble(Low[li_28 + 1], Digits) && NormalizeDouble(Low[li_28], Digits) < NormalizeDouble(Low[li_28 - 1], Digits)) {
         if (ai_8 == 1 || (ai_8 == 2 && NormalizeDouble(Low[li_28], Digits) < NormalizeDouble(Low[li_28 + 2], Digits))) {
            if (ai_12 == 1) {
               li_ret_24 = li_28;
               break;
            }
            if (NormalizeDouble(ad_16, Digits) < NormalizeDouble(Low[li_28], Digits)) {
               li_ret_24 = li_28;
               gd_340 = Low[li_28];
               break;
            }
            gd_340 = 99999.9;
            if (NormalizeDouble(Open[li_28], Digits) < NormalizeDouble(Close[li_28], Digits) && NormalizeDouble(ad_16, Digits) < NormalizeDouble(Open[li_28], Digits)) {
               gd_340 = Open[li_28];
               li_ret_24 = li_28;
               break;
            }
            if (NormalizeDouble(Close[li_28], Digits) < NormalizeDouble(Open[li_28], Digits) && NormalizeDouble(ad_16, Digits) < NormalizeDouble(Close[li_28], Digits)) {
               gd_340 = Close[li_28];
               li_ret_24 = li_28;
               break;
            }
            if (NormalizeDouble(gd_340, Digits) < NormalizeDouble(ad_16, Digits)) li_ret_24 = -1;
         }
      }
   }
   return (li_ret_24);
}

int f0_10(int ai_0, int ai_4, int ai_8, int ai_12, double ad_16) {
   int li_ret_24 = -1;
   for (int li_28 = ai_0; li_28 <= ai_4; li_28++) {
      if (NormalizeDouble(High[li_28 + 1], Digits) <= NormalizeDouble(High[li_28], Digits) && NormalizeDouble(High[li_28 - 1], Digits) <= NormalizeDouble(High[li_28], Digits)) {
         if (ai_8 == 1 || (ai_8 == 2 && NormalizeDouble(High[li_28 + 2], Digits) <= NormalizeDouble(High[li_28], Digits))) {
            if (ai_12 == 1) {
               li_ret_24 = li_28;
               break;
            }
            if (NormalizeDouble(High[li_28], Digits) < NormalizeDouble(ad_16, Digits)) {
               li_ret_24 = li_28;
               gd_388 = High[li_28];
               break;
            }
            gd_388 = 0;
            if (NormalizeDouble(Open[li_28], Digits) < NormalizeDouble(Close[li_28], Digits) && NormalizeDouble(Close[li_28], Digits) < NormalizeDouble(ad_16, Digits)) {
               gd_388 = Close[li_28];
               li_ret_24 = li_28;
               break;
            }
            if (NormalizeDouble(Close[li_28], Digits) < NormalizeDouble(Open[li_28], Digits) && NormalizeDouble(Open[li_28], Digits) < NormalizeDouble(ad_16, Digits)) {
               gd_388 = Open[li_28];
               li_ret_24 = li_28;
               break;
            }
            li_ret_24 = -1;
         }
      }
   }
   return (li_ret_24);
}

int f0_12(int ai_0, int ai_4) {
   for (int li_ret_8 = ai_0; li_ret_8 <= ai_4; li_ret_8++) {
      if (NormalizeDouble(g_ibuf_260[li_ret_8], 6) < NormalizeDouble(g_ibuf_260[li_ret_8 - 1], 6) && NormalizeDouble(g_ibuf_260[li_ret_8], 6) < NormalizeDouble(g_ibuf_260[li_ret_8 +
         1], 6)) return (li_ret_8);
   }
   return (-1);
}

int f0_4(int ai_0, int ai_4) {
   for (int li_ret_8 = ai_0; li_ret_8 <= ai_4; li_ret_8++) {
      if (NormalizeDouble(g_ibuf_260[li_ret_8 - 1], 6) < NormalizeDouble(g_ibuf_260[li_ret_8], 6) && NormalizeDouble(g_ibuf_260[li_ret_8 + 1], 6) < NormalizeDouble(g_ibuf_260[li_ret_8],
         6)) return (li_ret_8);
   }
   return (-1);
}

int f0_3(double ad_0, double ad_8, int ai_16, int ai_20) {
   double ld_28;
   double ld_40;
   double ld_48;
   int count_24 = 1;
   if (NormalizeDouble(0.0, 6) < NormalizeDouble(ai_16 - ai_20, 6)) {
      ld_28 = (ad_8 - ad_0) / _Point / (ai_16 - ai_20);
      for (int li_36 = ai_20 + 2; li_36 < ai_16 - 1; li_36++) {
         if (NormalizeDouble(Close[li_36], Digits) < NormalizeDouble(Open[li_36], Digits)) ld_40 = Open[li_36];
         else ld_40 = Close[li_36];
         if (ai_16 - li_36 > 0.0) {
            ld_48 = (ld_40 - ad_0) / _Point / (ai_16 - li_36);
            if (NormalizeDouble(ld_28, 6) < NormalizeDouble(ld_48, 6)) {
               count_24++;
               if (count_24 <= 2) continue;
               return (1);
            }
            count_24 = 0;
         }
      }
   }
   return (0);
}

int f0_5(double ad_0, double ad_8, int ai_16, int ai_20) {
   double ld_28;
   double ld_40;
   double ld_48;
   int count_24 = 1;
   if (NormalizeDouble(0.0, 6) < NormalizeDouble(ai_16 - ai_20, 6)) {
      ld_28 = (ad_0 - ad_8) / _Point / (ai_16 - ai_20);
      for (int li_36 = ai_20 + 2; li_36 < ai_16 - 1; li_36++) {
         if (NormalizeDouble(Close[li_36], Digits) < NormalizeDouble(Open[li_36], Digits)) ld_40 = Close[li_36];
         else ld_40 = Open[li_36];
         if (NormalizeDouble(0.0, 6) < NormalizeDouble(ai_16 - li_36, 6)) {
            ld_48 = (ad_0 - ld_40) / _Point / (ai_16 - li_36);
            if (NormalizeDouble(ld_28, 8) < NormalizeDouble(ld_48, 8)) {
               count_24++;
               if (count_24 <= 2) continue;
               return (1);
            }
            count_24 = 0;
         }
      }
   }
   return (0);
}

int f0_8(int ai_0, int ai_4) {
   double ld_12;
   double ld_24;
   double ld_32;
   int count_8 = 1;
   if (NormalizeDouble(0.0, 6) < NormalizeDouble(ai_0 - ai_4, 6)) {
      ld_12 = (g_ibuf_260[ai_4] - g_ibuf_260[ai_0]) / _Point / (ai_0 - ai_4);
      for (int li_20 = ai_4 + 2; li_20 < ai_0 - 1; li_20++) {
         ld_24 = g_ibuf_260[li_20];
         if (NormalizeDouble(0.0, 6) < NormalizeDouble(li_20 - ai_4, 6)) {
            ld_32 = (g_ibuf_260[ai_4] - ld_24) / _Point / (li_20 - ai_4);
            if (NormalizeDouble(ld_12, 8) < NormalizeDouble(ld_32, 8)) {
               count_8++;
               if (count_8 <= 2) continue;
               return (1);
            }
            count_8 = 0;
         }
      }
   }
   return (0);
}

int f0_2(int ai_0, int ai_4) {
   double ld_12;
   double ld_24;
   double ld_32;
   int count_8 = 1;
   if (NormalizeDouble(0.0, 6) < NormalizeDouble(ai_0 - ai_4, 6)) {
      ld_12 = (g_ibuf_260[ai_0] - g_ibuf_260[ai_4]) / _Point / (ai_0 - ai_4);
      for (int li_20 = ai_4 + 2; li_20 < ai_0 - 1; li_20++) {
         ld_24 = g_ibuf_260[li_20];
         if (NormalizeDouble(0.0, 6) < NormalizeDouble(li_20 - ai_4, 6)) {
            ld_32 = (ld_24 - g_ibuf_260[ai_4]) / _Point / (li_20 - ai_4);
            if (NormalizeDouble(ld_12, 8) < NormalizeDouble(ld_32, 8)) {
               count_8++;
               if (count_8 <= 2) continue;
               return (1);
            }
            count_8 = 0;
         }
      }
   }
   return (0);
}

int f0_0(int ai_0, int ai_4, double ad_8, double ad_16, string as_24, int ai_32, int ai_36, int ai_40, int ai_44) {
   string name_64;
   string ls_72;
   string name_84;
   int li_48 = -1;
   bool li_52 = FALSE;
   for (int li_56 = ArrayRange(gda_440, 0); li_56 >= 0; li_56--) {
      if (gda_440[li_56][5] == ai_32 || gda_440[li_56][5] == ai_32 + 1 && Time[ai_0] == gda_440[li_56][0]) {
         li_48 = li_56;
         break;
      }
   }
   if (gi_208 == TRUE) {
      if (li_48 == -1) {
         for (li_56 = ArrayRange(gda_440, 0); li_56 >= 0; li_56--) {
            if (gda_440[li_56][5] == ai_32 || gda_440[li_56][5] == ai_32 + 1 && Time[ai_0] == gda_440[li_56][2]) {
               if (!((as_24 == "Low" && NormalizeDouble(ad_16, Digits) < NormalizeDouble(gda_440[li_56][3], Digits) && NormalizeDouble(g_ibuf_260[iBarShift(Symbol(), gda_440[li_56][0],
                  1)], Digits) < NormalizeDouble(g_ibuf_260[ai_4], Digits)) || (as_24 == "High" && NormalizeDouble(gda_440[li_56][3], Digits) < NormalizeDouble(ad_16, Digits) && NormalizeDouble(g_ibuf_260[ai_4],
                  Digits) < NormalizeDouble(g_ibuf_260[iBarShift(Symbol(), gda_440[li_56][0], 1)], Digits)))) break;
               li_48 = li_56;
               break;
            }
         }
      }
      if (li_48 == -1) {
         for (li_56 = ArrayRange(gda_440, 0); li_56 >= 0; li_56--) {
            if (gda_440[li_56][5] == ai_32 || gda_440[li_56][5] == ai_32 + 1 && gda_440[li_56][0] <= Time[ai_0] && Time[ai_0] <= gda_440[li_56][2]) {
               li_48 = li_56;
               break;
            }
         }
      }
      if (li_48 == -1) {
         for (li_56 = ArrayRange(gda_440, 0); li_56 >= 0; li_56--) {
            if (gda_440[li_56][5] == ai_32 || gda_440[li_56][5] == ai_32 + 1 && Time[ai_0] <= gda_440[li_56][0] && gda_440[li_56][2] <= Time[ai_4]) {
               li_48 = li_56;
               li_52 = TRUE;
               break;
            }
         }
      }
      if (li_48 == -1) {
         for (li_56 = ArrayRange(gda_440, 0); li_56 >= 0; li_56--) {
            if (gda_440[li_56][5] == ai_32 || gda_440[li_56][5] == ai_32 + 1 && Time[ai_0] == gda_440[li_56][2]) {
               if (!((as_24 == "Low" && NormalizeDouble(ad_16, Digits) < NormalizeDouble(gda_440[li_56][3], Digits) && NormalizeDouble(g_ibuf_260[iBarShift(Symbol(), gda_440[li_56][0],
                  1)], Digits) < NormalizeDouble(g_ibuf_260[ai_4], Digits)) || (as_24 == "High" && NormalizeDouble(gda_440[li_56][3], Digits) < NormalizeDouble(ad_16, Digits) && NormalizeDouble(g_ibuf_260[ai_4],
                  Digits) < NormalizeDouble(g_ibuf_260[iBarShift(Symbol(), gda_440[li_56][0], 1)], Digits)))) break;
               li_48 = li_56;
               break;
            }
         }
      }
   }
   int count_60 = 0;
   for (li_56 = ai_4; li_56 <= ai_0 - 1; li_56++) {
      if ((NormalizeDouble(0.0, 6) < NormalizeDouble(g_ibuf_260[li_56], 6) && NormalizeDouble(g_ibuf_260[li_56 + 1], 6) < NormalizeDouble(0.0, 6)) || (NormalizeDouble(g_ibuf_260[li_56],
         6) < NormalizeDouble(0.0, 6) && NormalizeDouble(0.0, 6) < NormalizeDouble(g_ibuf_260[li_56 + 1], 6))) {
         count_60++;
         if (count_60 > 2) break;
      }
   }
   if (count_60 == 2)
      if (gi_132 < ai_0 - ai_4) return (-1);
   if (gi_84 == TRUE) {
      if (li_48 != -1) {
         if (ai_32 >= 10 && ai_32 < 20)
            if (NormalizeDouble(gda_440[li_48][3], Digits) < NormalizeDouble(ad_16, Digits)) return (-1);
         if (ai_32 >= 20 && ai_32 < 30)
            if (NormalizeDouble(ad_16, Digits) < NormalizeDouble(gda_440[li_48][3], Digits)) return (-1);
      }
   }
   if (gi_88 == TRUE) {
      if (count_60 > 1) {
         if (ai_32 >= 10 && ai_32 < 20)
            if (f0_8(ai_40, ai_44) == 1) return (-1);
         if (ai_32 >= 20 && ai_32 < 30)
            if (f0_2(ai_40, ai_44) == 1) return (-1);
      }
   }
   if (count_60 != 2) {
      if (ai_32 == 11) {
         ai_32 = 12;
         name_64 = gs_444 + f0_9(gda_440[li_48][0]) + "_(bull.regu)_c";
         if (ObjectFind(name_64) >= 0) ObjectDelete(name_64);
         name_64 = gs_444 + f0_9(gda_440[li_48][0]) + "_(bull.regu)_i";
         if (ObjectFind(name_64) >= 0) ObjectDelete(name_64);
      } else {
         if (ai_32 == 21) {
            ai_32 = 22;
            name_64 = gs_444 + f0_9(gda_440[li_48][0]) + "_(bear.regu)_c";
            if (ObjectFind(name_64) >= 0) ObjectDelete(name_64);
            name_64 = gs_444 + f0_9(gda_440[li_48][0]) + "_(bear.regu)_i";
            if (ObjectFind(name_64) >= 0) ObjectDelete(name_64);
         }
      }
   }
   if (li_48 == -1) {
      li_48 = ArrayRange(gda_440, 0);
      ArrayResize(gda_440, li_48 + 1);
      gda_440[li_48][0] = Time[ai_0];
      gda_440[li_48][6] = g_ibuf_260[ai_40];
      gda_440[li_48][8] = Time[ai_40];
      gda_440[li_48][1] = ad_8;
   }
   if (li_52 == TRUE) {
      ls_72 = gs_444 + f0_9(gda_440[li_48][0]);
      for (int li_80 = ObjectsTotal() - 1; li_80 >= 0; li_80--) {
         name_84 = ObjectName(li_80);
         if (StringSubstr(name_84, 0, 31) == ls_72) ObjectDelete(name_84);
      }
      gda_440[li_48][0] = Time[ai_0];
      gda_440[li_48][6] = g_ibuf_260[ai_40];
      gda_440[li_48][8] = Time[ai_40];
   }
   gda_440[li_48][5] = ai_32;
   gda_440[li_48][2] = Time[ai_4];
   gda_440[li_48][4] = Close[ai_4];
   gda_440[li_48][7] = g_ibuf_260[ai_44];
   gda_440[li_48][9] = Time[ai_44];
   gda_440[li_48][10] = Time[ai_36];
   gda_440[li_48][3] = ad_16;
   return (ai_32);
}

void f0_6(int ai_0, string as_4, int ai_12, double ad_16, color a_color_24, int a_width_28) {
   string name_36;
   for (int li_32 = ArrayRange(gda_440, 0) - 1; li_32 >= 0; li_32--) {
      if (gda_440[li_32][5] == ai_0 && NormalizeDouble(gda_440[li_32][2], 0) == ai_12 || NormalizeDouble(gda_440[li_32][10], 0) == ai_12) {
         name_36 = gs_444 + f0_9(gda_440[li_32][0]) + "_(" + as_4 + ")_c";
         ObjectDelete(name_36);
         ObjectCreate(name_36, OBJ_TREND, 0, gda_440[li_32][0], gda_440[li_32][1] + ad_16 * gd_280 * _Point, gda_440[li_32][2], gda_440[li_32][3] + ad_16 * gd_280 * _Point,
            0, 0);
         ObjectSet(name_36, OBJPROP_RAY, FALSE);
         ObjectSet(name_36, OBJPROP_COLOR, a_color_24);
         ObjectSet(name_36, OBJPROP_STYLE, STYLE_SOLID);
         ObjectSet(name_36, OBJPROP_WIDTH, a_width_28);
         if (WindowFind(gs_264) > 0) {
            name_36 = gs_444 + f0_9(gda_440[li_32][0]) + "_(" + as_4 + ")_i";
            ObjectDelete(name_36);
            ObjectCreate(name_36, OBJ_TREND, WindowFind(gs_264), gda_440[li_32][8], gda_440[li_32][6] + ad_16 * gd_280 / 5.0 * _Point, gda_440[li_32][9], gda_440[li_32][7] + ad_16 * gd_280 / 5.0 * _Point,
               0, 0);
            ObjectSet(name_36, OBJPROP_RAY, FALSE);
            ObjectSet(name_36, OBJPROP_COLOR, a_color_24);
            ObjectSet(name_36, OBJPROP_STYLE, STYLE_SOLID);
            ObjectSet(name_36, OBJPROP_WIDTH, a_width_28);
         }
         GlobalVariableSet(StringConcatenate(Symbol(), "_", Period(), "_LastDivergence"), gda_440[li_32][2]);
         if (a_color_24 == gi_176 || a_color_24 == gi_180 || a_color_24 == gi_200) {
            GlobalVariableSet(StringConcatenate(Symbol(), "_", Period(), "_LastDivergenceDir"), 1);
            return;
         }
         GlobalVariableSet(StringConcatenate(Symbol(), "_", Period(), "_LastDivergenceDir"), 0);
         return;
      }
   }
}

string f0_9(int ai_0) {
   string ls_ret_4 = "";
   ls_ret_4 = ls_ret_4 + StringSubstr(DoubleToStr(TimeYear(ai_0), 0), 2, 2) + ".";
   ls_ret_4 = ls_ret_4 + StringSubstr(DoubleToStr(TimeMonth(ai_0) + 100, 0), 1, 2) + ".";
   ls_ret_4 = ls_ret_4 + StringSubstr(DoubleToStr(TimeDay(ai_0) + 100, 0), 1, 2) + " ";
   ls_ret_4 = ls_ret_4 + StringSubstr(DoubleToStr(TimeHour(ai_0) + 100, 0), 1, 2) + ":";
   ls_ret_4 = ls_ret_4 + StringSubstr(DoubleToStr(TimeMinute(ai_0) + 100, 0), 1, 2);
   return (ls_ret_4);
}

int f0_7(int ai_0, int ai_4, int ai_8) {
   for (int li_12 = ArrayRange(gda_440, 0); li_12 >= 0; li_12--)
      if (ai_0 == gda_440[li_12][5] && ai_4 == gda_440[li_12][2]) return (gda_440[li_12][ai_8]);
   return (-1);
}