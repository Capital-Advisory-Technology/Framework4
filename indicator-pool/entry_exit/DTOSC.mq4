
#property copyright ""
#property link      ""

#property indicator_separate_window
#property indicator_minimum 0.0
#property indicator_maximum 100.0
#property indicator_buffers 2
#property indicator_color1 Red
#property indicator_color2 Blue
#property indicator_width1 2
#property indicator_level1 30.0
#property indicator_width2 2
#property indicator_level2 70.0

extern string TimeFrame = "Current time frame";
extern int PeriodRSI = 13;
extern int PeriodStoch = 8;
extern int PeriodSK = 5;
extern int PeriodSD = 3;
extern int MAMode = 0;
double G_ibuf_104[];
double G_ibuf_108[];
double G_ibuf_112[];
double G_ibuf_116[];
string Gs_120;
int G_timeframe_128;
bool Gi_132 = FALSE;

// E37F0136AA3FFAF149B351F6A4C948E9
int init() {
   IndicatorBuffers(4);
   SetIndexBuffer(0, G_ibuf_104);
   SetIndexBuffer(1, G_ibuf_108);
   SetIndexBuffer(2, G_ibuf_112);
   SetIndexBuffer(3, G_ibuf_116);
   if (TimeFrame == "getBarsCount") {
      Gi_132 = TRUE;
      return (0);
   }
   G_timeframe_128 = f0_0(TimeFrame);
   IndicatorShortName("DTOSC (" + PeriodRSI + "," + PeriodStoch + "," + PeriodSK + "," + PeriodSD + ")");
   Gs_120 = WindowExpertName();
   return (0);
}

// 52D46093050F38C27267BCE42543EF60
int deinit() {
   return (0);
}

// EA2B2676C28C0DB26D39331A336C6B92
int start() {
   int shift_12;
   double Ld_16;
   double Ld_24;
   int Li_8 = IndicatorCounted();
   if (Li_8 < 0) return (-1);
   if (Li_8 > 0) Li_8--;
   int Li_4 = Bars - Li_8;
   if (Gi_132) {
      G_ibuf_104[0] = Li_4;
      return (0);
   }
   if (G_timeframe_128 != Period()) {
      Li_4 = MathMax(Li_4, MathMin(Bars, iCustom(NULL, G_timeframe_128, Gs_120, "getBarsCount", 0, 0) * G_timeframe_128 / Period()));
      for (int Li_0 = 0; Li_0 < Li_4; Li_0++) {
         shift_12 = iBarShift(NULL, G_timeframe_128, Time[Li_0]);
         G_ibuf_104[Li_0] = iCustom(NULL, G_timeframe_128, Gs_120, "", PeriodRSI, PeriodStoch, PeriodSK, PeriodSD, MAMode, 0, shift_12);
         G_ibuf_108[Li_0] = iCustom(NULL, G_timeframe_128, Gs_120, "", PeriodRSI, PeriodStoch, PeriodSK, PeriodSD, MAMode, 1, shift_12);
      }
      return (0);
   }
   for (Li_0 = Li_4; Li_0 >= 0; Li_0--) {
      G_ibuf_116[Li_0] = iRSI(NULL, 0, PeriodRSI, PRICE_CLOSE, Li_0);
      Ld_16 = G_ibuf_116[ArrayMinimum(G_ibuf_116, PeriodStoch, Li_0)];
      Ld_24 = G_ibuf_116[ArrayMaximum(G_ibuf_116, PeriodStoch, Li_0)];
      if (Ld_24 - Ld_16 != 0.0) G_ibuf_112[Li_0] = 100.0 * ((G_ibuf_116[Li_0] - Ld_16) / (Ld_24 - Ld_16));
      else G_ibuf_112[Li_0] = 0;
   }
   for (Li_0 = Li_4; Li_0 >= 0; Li_0--) G_ibuf_104[Li_0] = iMAOnArray(G_ibuf_112, 0, PeriodSK, 0, MAMode, Li_0);
   for (Li_0 = Li_4; Li_0 >= 0; Li_0--) G_ibuf_108[Li_0] = iMAOnArray(G_ibuf_104, 0, PeriodSD, 0, MAMode, Li_0);
   return (0);
}

// B9EDCDEA151586E355292E7EA9BE516E
int f0_0(string As_0) {
   int Li_12;
   for (int Li_8 = StringLen(As_0) - 1; Li_8 >= 0; Li_8--) {
      Li_12 = StringGetChar(As_0, Li_8);
      if ((Li_12 > '`' && Li_12 < '{') || (Li_12 > 'ß' && Li_12 < 256)) As_0 = StringSetChar(As_0, Li_8, Li_12 - 32);
      else
         if (Li_12 > -33 && Li_12 < 0) As_0 = StringSetChar(As_0, Li_8, Li_12 + 224);
   }
   int timeframe_16 = 0;
   if (As_0 == "M1" || As_0 == "1") timeframe_16 = 1;
   if (As_0 == "M5" || As_0 == "5") timeframe_16 = 5;
   if (As_0 == "M15" || As_0 == "15") timeframe_16 = 15;
   if (As_0 == "M30" || As_0 == "30") timeframe_16 = 30;
   if (As_0 == "H1" || As_0 == "60") timeframe_16 = 60;
   if (As_0 == "H4" || As_0 == "240") timeframe_16 = 240;
   if (As_0 == "D1" || As_0 == "1440") timeframe_16 = 1440;
   if (As_0 == "W1" || As_0 == "10080") timeframe_16 = 10080;
   if (As_0 == "MN" || As_0 == "43200") timeframe_16 = 43200;
   if (timeframe_16 < Period()) timeframe_16 = Period();
   return (timeframe_16);
}
