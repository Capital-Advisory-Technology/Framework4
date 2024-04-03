//+------------------------------------------------------------------+
//|                                        Stochastic Divergence.mq4 |
//|                     edited from     FX5_MACD_Divergence_V1.1.mq4 |
//|                                                              FX5 |
//|Editor: byens (byens@web.de)                        hazem@uk2.net |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2007, FX5"
#property link      "hazem@uk2.net"
//----
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1 CornflowerBlue
#property indicator_color2 Red
#property indicator_color3 White
#property indicator_color4 White
#property indicator_style4 STYLE_DOT
#property indicator_level1 80
#property indicator_level2 50
#property indicator_level3 20
#property indicator_levelcolor DimGray
//----
#define arrowsDisplacement 0.0001
//---- input parameters
/*extern int    fastEMA = 12;
extern int    slowEMA = 26;
extern int    signalSMA = 9;*/

extern int    KPeriod                 = 5;
extern int    DPeriod                 = 3;
extern int    Slowing                 = 3;
extern bool   drawIndicatorTrendLines = true;
extern bool   drawPriceTrendLines     = true;
extern bool   displayAlert            = false;
extern bool   emailAlert              = false;
//extern bool   alert_ON=false;
extern color  ColorBearishTrendLines  = Gold;
extern color  ColorBullishTrendLines  = Gold;
extern int    TimeFrame               = 0;

//---- buffers
double bullishDivergence[];
double bearishDivergence[];
double macd[];
double signal[];
//----
static datetime lastAlertTime;
static string   indicatorName;


//+------------------------------------------------------------------+
//| Custom indicator timeframe function                              |
//+------------------------------------------------------------------+

string GetTimeFrameStr() {
   switch(TimeFrame)
   {
      case 1 : string TimeFrameStr2="M1"; break;
      case 5 : TimeFrameStr2="M5"; break;
      case 15 : TimeFrameStr2="M15"; break;
      case 30 : TimeFrameStr2="M30"; break;
      case 60 : TimeFrameStr2="H1"; break;
      case 240 : TimeFrameStr2="H4"; break;
      case 1440 : TimeFrameStr2="D1"; break;
      case 10080 : TimeFrameStr2="W1"; break;
      case 43200 : TimeFrameStr2="MN1"; break;
   } 
   return (TimeFrameStr2);
}
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
//---- indicators
   SetIndexStyle(0, DRAW_ARROW,0,2);
   SetIndexStyle(1, DRAW_ARROW,0,2);
   SetIndexStyle(2, DRAW_LINE);
   SetIndexStyle(3, DRAW_LINE);
//----   
   SetIndexBuffer(0, bullishDivergence);
   SetIndexBuffer(1, bearishDivergence);
   SetIndexBuffer(2, macd);
   SetIndexBuffer(3, signal);   
//----   
   SetIndexArrow(0, 233);
   SetIndexArrow(1, 234);
//----

   // Show regular timeframe string (HCY)
   if (TimeFrame == 0) {
      TimeFrame = Period();
      }
   indicatorName = Symbol()+" ("+GetTimeFrameStr()+"):  Stochastic_Divergence(" + KPeriod + ", " + 
                                 DPeriod + ", " + Slowing + ")";
   SetIndexDrawBegin(3, Slowing);//signalSMA);
   IndicatorDigits(Digits + 2);
   IndicatorShortName(indicatorName);

   return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
  {
   for(int i = ObjectsTotal() - 1; i >= 0; i--)
     {
       string label = ObjectName(i);
       if(StringSubstr(label, 0, 25) != "Stochastic_DivergenceLine")
           continue;
       ObjectDelete(label);   
     }
 //    ObjectsDeleteAll();
 //    ObjectDelete(label);
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int countedBars = IndicatorCounted();
   if(countedBars < 0)
       countedBars = 0;
   CalculateIndicator(countedBars);
//---- 
   return(0);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CalculateIndicator(int countedBars)
  {
   for(int i = Bars - countedBars; i >= 0; i--)
     {
       CalculateMACD(i);
       CatchBullishDivergence(i + 2);
       CatchBearishDivergence(i + 2);
     }              
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CalculateMACD(int i)
  {
   macd[i] = iStochastic(NULL, TimeFrame, KPeriod, DPeriod, Slowing, MODE_SMA, 0, MODE_MAIN, i);
               /*iMACD(NULL, 0, fastEMA, slowEMA, signalSMA, 
                   PRICE_CLOSE, MODE_MAIN, i);*/
   
   signal[i] = iStochastic(NULL, TimeFrame, KPeriod, DPeriod, Slowing, MODE_SMA, 0, MODE_SIGNAL, i);
               /*iMACD(NULL, 0, fastEMA, slowEMA, signalSMA, 
                     PRICE_CLOSE, MODE_SIGNAL, i);         */
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CatchBullishDivergence(int shift)
  {
   if(IsIndicatorTrough(shift) == false)
       return;  
   int currentTrough = shift;
   int lastTrough = GetIndicatorLastTrough(shift);
//   static bool turn_alarm = true;
//----   
   if(macd[currentTrough] >= macd[lastTrough] && 
      Low[currentTrough] <= Low[lastTrough])
     {
       bullishDivergence[currentTrough] = macd[currentTrough] - 
                                          arrowsDisplacement;
       //----
       if(drawPriceTrendLines == true)
           DrawPriceTrendLine(Time[currentTrough], Time[lastTrough], 
                              Low[currentTrough], 
                             Low[lastTrough], ColorBullishTrendLines, STYLE_SOLID);
       //----
       if(drawIndicatorTrendLines == true)
          DrawIndicatorTrendLine(Time[currentTrough], 
                                 Time[lastTrough], 
                                 macd[currentTrough],
                                 macd[lastTrough], 
                                 ColorBullishTrendLines, STYLE_SOLID);
       //----
       if(displayAlert == true || emailAlert == true)
          DisplayAlert("Classical bullish divergence on: ", 
                        currentTrough);  
                        
       //----
/*       if(alert_ON == true)
       {  
         Alert ("Classical bullish divergence on ",Symbol(),"-",TimeFrame);
         PlaySound("timeout.wav"); 
         turn_alarm=false;
       }*/
     }
//----   
   if(macd[currentTrough] <= macd[lastTrough] && 
      Low[currentTrough] >= Low[lastTrough])
     {
       bullishDivergence[currentTrough] = macd[currentTrough] - 
                                          arrowsDisplacement;
       //----
       if(drawPriceTrendLines == true)
           DrawPriceTrendLine(Time[currentTrough], Time[lastTrough], 
                              Low[currentTrough], 
                              Low[lastTrough], ColorBullishTrendLines, STYLE_DOT);
       //----
       if(drawIndicatorTrendLines == true)                            
           DrawIndicatorTrendLine(Time[currentTrough], 
                                  Time[lastTrough], 
                                  macd[currentTrough],
                                  macd[lastTrough], 
                                  ColorBullishTrendLines, STYLE_DOT);
       //----
       if(displayAlert == true || emailAlert == true)
           DisplayAlert("Hidden bullish divergence on: ", 
                        currentTrough);  
       
       //----
/*       if(alert_ON == true)
       {  
         Alert ("Hidden bullish divergence on ",Symbol(),"-",TimeFrame);
         PlaySound("timeout.wav"); 
         turn_alarm=false;
       }                 */
              
     }      
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CatchBearishDivergence(int shift)
  {
   if(IsIndicatorPeak(shift) == false)
       return;
   int currentPeak = shift;
   int lastPeak = GetIndicatorLastPeak(shift);
   static bool turn_alarm = true;
//----   
   if(macd[currentPeak] <= macd[lastPeak] && 
      High[currentPeak] >= High[lastPeak])
     {
       bearishDivergence[currentPeak] = macd[currentPeak] + 
                                        arrowsDisplacement;
      
       if(drawPriceTrendLines == true)
           DrawPriceTrendLine(Time[currentPeak], Time[lastPeak], 
                              High[currentPeak], 
                              High[lastPeak], ColorBearishTrendLines, STYLE_SOLID);
                            
       if(drawIndicatorTrendLines == true)
           DrawIndicatorTrendLine(Time[currentPeak], Time[lastPeak], 
                                  macd[currentPeak],
                                  macd[lastPeak], ColorBearishTrendLines, STYLE_SOLID);

       if(displayAlert == true || emailAlert == true)
           DisplayAlert("Classical bearish divergence on: ", 
                        currentPeak);  
       
/*       if(alert_ON == true)
       {  
         Alert ("Classical bearish divergence on ",Symbol(),"-",TimeFrame);
         PlaySound("timeout.wav"); 
         turn_alarm=false;
       }*/
     }
   if(macd[currentPeak] >= macd[lastPeak] && 
      High[currentPeak] <= High[lastPeak])
     {
       bearishDivergence[currentPeak] = macd[currentPeak] + 
                                        arrowsDisplacement;
       //----
       if(drawPriceTrendLines == true)
           DrawPriceTrendLine(Time[currentPeak], Time[lastPeak], 
                              High[currentPeak], 
                              High[lastPeak], ColorBearishTrendLines, STYLE_DOT);
       //----
       if(drawIndicatorTrendLines == true)
           DrawIndicatorTrendLine(Time[currentPeak], Time[lastPeak], 
                                  macd[currentPeak],
                                  macd[lastPeak], ColorBearishTrendLines, STYLE_DOT);
       //----
       if(displayAlert == true || emailAlert == true)
           DisplayAlert("Hidden bearish divergence on: ", 
                        currentPeak);  
                        
/*       if(alert_ON == true)
       {  
         Alert ("Hidden bearish divergence on ",Symbol(),"-",TimeFrame);
         PlaySound("timeout.wav"); 
         turn_alarm=false;
       } */
     }   
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsIndicatorPeak(int shift)
  {
   if(macd[shift] >= macd[shift+1] && macd[shift] > macd[shift+2] && 
      macd[shift] > macd[shift-1])
       return(true);
   else 
       return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsIndicatorTrough(int shift)
  {
   if(macd[shift] <= macd[shift+1] && macd[shift] < macd[shift+2] && 
      macd[shift] < macd[shift-1])
       return(true);
   else 
       return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetIndicatorLastPeak(int shift)
  {
   for(int i = shift + 5; i < Bars; i++)
     {
       if(signal[i] >= signal[i+1] && signal[i] >= signal[i+2] &&
          signal[i] >= signal[i-1] && signal[i] >= signal[i-2])
         {
           for(int j = i; j < Bars; j++)
             {
               if(macd[j] >= macd[j+1] && macd[j] > macd[j+2] &&
                  macd[j] >= macd[j-1] && macd[j] > macd[j-2])
                   return(j);
             }
         }
     }
   return(-1);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetIndicatorLastTrough(int shift)
  {
    for(int i = shift + 5; i < Bars; i++)
      {
        if(signal[i] <= signal[i+1] && signal[i] <= signal[i+2] &&
           signal[i] <= signal[i-1] && signal[i] <= signal[i-2])
          {
            for (int j = i; j < Bars; j++)
              {
                if(macd[j] <= macd[j+1] && macd[j] < macd[j+2] &&
                   macd[j] <= macd[j-1] && macd[j] < macd[j-2])
                    return(j);
              }
          }
      }
    return(-1);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DisplayAlert(string message, int shift)
  {
   if(shift <= 2 && Time[shift] != lastAlertTime)
     {
       lastAlertTime = Time[shift];
       if (displayAlert == true)
         Alert(message, Symbol(), " , ", /*Period()==*/TimeFrame, " minutes chart");
       if (emailAlert == true)  {
         SendMail("MT4 alert", message + Symbol() + " , " + TimeFrame + " minutes chart"); 
         int err = GetLastError ();
         Comment ("Error = " + err );
         }
     }
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawPriceTrendLine(datetime x1, datetime x2, double y1, 
                        double y2, color lineColor, double style)
  {
   string label = "Stochastic_DivergenceLine_v1.0# " + DoubleToStr(x1, 0) + TimeFrame;
   ObjectDelete(label);
   ObjectCreate(label, OBJ_TREND, 0, x1, y1, x2, y2, 0, 0);
   ObjectSet(label, OBJPROP_RAY, 0);
   ObjectSet(label, OBJPROP_COLOR, lineColor);
   ObjectSet(label, OBJPROP_STYLE, style);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawIndicatorTrendLine(datetime x1, datetime x2, double y1, 
                            double y2, color lineColor, double style)
  {
   int indicatorWindow = WindowFind(indicatorName);
   if(indicatorWindow < 0)
       return;
   string label = "Stochastic_DivergenceLine_v1.0$# " + DoubleToStr(x1, 0) + TimeFrame;
   ObjectDelete(label);
   ObjectCreate(label, OBJ_TREND, indicatorWindow, x1, y1, x2, y2, 
                0, 0);
   ObjectSet(label, OBJPROP_RAY, 0);
   ObjectSet(label, OBJPROP_COLOR, lineColor);
   ObjectSet(label, OBJPROP_STYLE, style);
  }
//+------------------------------------------------------------------+




