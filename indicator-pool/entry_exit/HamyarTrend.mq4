//+------------------------------------------------------------------+
//|                                            Hamyar.mq4            |
//|                                        Copyright © 2010, Farshad |
//|                                           http://www.vizhish.com |
//+------------------------------------------------------------------+

#property copyright "Copyright © 2010, Farshad Saremifar"
#property link      "farshad.saremifar@gmail.com"


#property indicator_separate_window
#property indicator_minimum 0.0
#property indicator_maximum 20.0
#property indicator_buffers 2
#property indicator_color1 Lime
#property indicator_color2 Red
#property indicator_width1 5
#property indicator_width2 5

extern int Lookback = 25;
 int BarLevel = 10;
int TimeFrame = 0;
double g_ibuf_96[];
double g_ibuf_100[];
double g_ibuf_104[];
string gs_108;

int init() {

   string ls_0;
   if (TimeFrame < Period()) TimeFrame = Period();
   switch (TimeFrame) {
   case 1:
      ls_0 = "M1";
      break;
   case 5:
      ls_0 = "M5";
      break;
   case 15:
      ls_0 = "M15";
      break;
   case 30:
      ls_0 = "M30";
      break;
   case 60:
      ls_0 = "H1";
      break;
   case 240:
      ls_0 = "H4";
      break;
   case 1440:
      ls_0 = "D1";
      break;
   case 10080:
      ls_0 = "W1";
      break;
   case 43200:
      ls_0 = "MN1";
      break;
   default:
      ls_0 = "TF0";
   }
   IndicatorBuffers(3);
   SetIndexBuffer(0, g_ibuf_96);
   SetIndexStyle(0, DRAW_ARROW);
   SetIndexArrow(0, 167);
   SetIndexLabel(0, "Bullish " + Lookback + " [" + TimeFrame + "]");
   SetIndexBuffer(1, g_ibuf_100);
   SetIndexStyle(1, DRAW_ARROW);
   SetIndexArrow(1, 167);
   SetIndexLabel(1, "Bearish " + Lookback + " [" + TimeFrame + "]");
   SetIndexBuffer(2, g_ibuf_104);

   IndicatorShortName("IntraDay Forecast:Copyright © 2010, Farshad Saremifar™  " );
   gs_108 = WindowExpertName();
   return (0);
}

int deinit() {
   return (0);
}

int start() {
   int l_index_4;
   int lia_12[];
   int l_index_16;
   int li_0 = IndicatorCounted();
   if (li_0 < 0) return (-1);
   if (li_0 > 0) li_0--;
   int li_8 = Bars - li_0;
   if (TimeFrame != Period()) {
      li_8 = MathMax(li_8, TimeFrame / Period());
      ArrayCopySeries(lia_12, 5, NULL, TimeFrame);
      l_index_4 = 0;
      l_index_16 = 0;
      while (l_index_4 < li_8) {
         if (Time[l_index_4] < lia_12[l_index_16]) l_index_16++;
         g_ibuf_96[l_index_4] = iCustom(NULL, TimeFrame, gs_108, Lookback, BarLevel, 0, l_index_16);
         g_ibuf_100[l_index_4] = iCustom(NULL, TimeFrame, gs_108, Lookback, BarLevel, 1, l_index_16);
         l_index_4++;
      }
      return (0);
   }
   for (l_index_4 = li_8; l_index_4 >= 0; l_index_4--) {
      g_ibuf_104[l_index_4] = g_ibuf_104[l_index_4 + 1];
      if (Close[l_index_4] > iMA(Symbol(), 0, Lookback, 0, MODE_SMA, PRICE_HIGH, l_index_4 + 1)) g_ibuf_104[l_index_4] = 1;
      if (Close[l_index_4] < iMA(Symbol(), 0, Lookback, 0, MODE_SMA, PRICE_LOW, l_index_4 + 1)) g_ibuf_104[l_index_4] = -1;
      if (g_ibuf_104[l_index_4] == -1.0) {
         g_ibuf_100[l_index_4] = BarLevel;
         g_ibuf_96[l_index_4] = EMPTY_VALUE;
      } else {
         g_ibuf_100[l_index_4] = EMPTY_VALUE;
         g_ibuf_96[l_index_4] = BarLevel;
      }
   }
   return (0);
}