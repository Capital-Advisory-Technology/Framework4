//+------------------------------------------------------------------+
//|                                                   CCI simple.mq4 |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""

#property indicator_separate_window
#property indicator_buffers 6
//---
#property indicator_color1  clrLime  //Green
#property indicator_color2  clrRed
#property indicator_color3  clrSteelBlue  //LightSteelBlue  //LightCyan  //Goldenrod
#property indicator_color4  clrLightCyan  //Lime  //CornflowerBlue
#property indicator_color5  clrMediumOrchid //Red
#property indicator_color6  clrGold
//---
#property indicator_width1  1
#property indicator_width2  1
#property indicator_width3  2
#property indicator_width4  2
#property indicator_width5  2
#property indicator_width6  0
//---
#property indicator_style6  STYLE_DASH  //DOT
//---
#property indicator_level1  -100
#property indicator_level2  0
#property indicator_level3  100
#property indicator_levelcolor clrDarkSlateGray  //DimGray  //DarkOrchid  //SteelBlue //MediumOrchid
#property indicator_levelstyle STYLE_DOT  //DASH



//
//
enum ConDiv { CONVERGENCE, DIVERGENCE };
//
//
extern string separator1              = "***CCI T3 Settings ***";
extern int    CCIPeriod               = 15;  //14;
extern ENUM_APPLIED_PRICE CCIPrice    = PRICE_WEIGHTED;  //PRICE_TYPICAL;
extern int    T3Period                = 7;  //5;
extern double T3Hot                   = 0.5;  //0.786;  //0.382;   //0.236, 0.382, 0.5, 0.618, 0.786, 1.0, 1.272, 1.414, 1.618, 2.058, 2.618, 3.32, 4.236, 5.35....
extern bool   T3Original              = false;
extern double CCIHotLevel             = 100.0;

extern string separator2              = "*** Second CCI Settings ***";
extern int    CCIPeriod2              = 15;  //14;
extern ENUM_APPLIED_PRICE CCIPrice2   = PRICE_WEIGHTED;  //PRICE_TYPICAL;

extern string separator3              = "*** Divergence Settings ***";
extern bool   drawIndicatorTrendLines = true;
extern bool   drawPriceTrendLines     = true;
extern ConDiv ConvergenceDivergence   = CONVERGENCE;
extern string drawLinesIdentificator  = "for M15";

extern string    separator4  =  "*** Alerts Settings ***";
extern bool   AlertsMessage  =  true,   //false,    
                AlertsSound  =  true,   //false,
                AlertsEmail  =  false,
               AlertsMobile  =  false;
extern string     SoundFile  =  "alert.wav";   //"news.wav",   //"stops.wav"   //"alert2.wav"   //"expert.wav"





double bullishDivergence[];
double bearishDivergence[];
double CCI[], CCUP[], CCDN[], CCI2[];
double prices[];
double emas[][6];

double alpha;
double c1;
double c2;
double c3;
double c4;
//double pipMultiplier = 1;

static datetime lastAlertTime;    string ConOrDiv;
string indicatorName;
string labelNames;

//
//
//
//
//

int init()
{
      IndicatorBuffers(7);
      SetIndexBuffer(0,bullishDivergence);   SetIndexStyle(0,DRAW_ARROW);   SetIndexArrow(0,233);
      SetIndexBuffer(1,bearishDivergence);   SetIndexStyle(1,DRAW_ARROW);   SetIndexArrow(1,234);
      SetIndexBuffer(2,CCI);                 SetIndexStyle(2,DRAW_LINE); 
      SetIndexBuffer(3,CCUP);                SetIndexStyle(3,DRAW_LINE); 
      SetIndexBuffer(4,CCDN);                SetIndexStyle(4,DRAW_LINE); 
      SetIndexBuffer(5,CCI2);                SetIndexStyle(5,DRAW_LINE); 
      SetIndexBuffer(6,prices);
      
      SetLevelValue(0,CCIHotLevel);
      SetLevelValue(1,-CCIHotLevel);         if (ConvergenceDivergence==1) ConOrDiv="divergence";   else ConOrDiv="convergence";
      SetLevelValue(2,0);

      IndicatorDigits(1);  //Digits + 2);
         
      
       double a = T3Hot;
             c1 = -a*a*a;
             c2 =  3*(a*a+a*a*a);
             c3 = -3*(2*a*a+a+a*a*a);
             c4 = 1+3*a+a*a*a+3*a*a;

      T3Period = MathMax(1,T3Period);
      if (T3Original)
           alpha = 2.0/(1.0 + T3Period);
      else alpha = 2.0/(2.0 + (T3Period-1.0)/2.0);
      
     labelNames = "CCI T3 DiverLine "+drawLinesIdentificator+": ";
             
   indicatorName = "CCI T3 Divergence";
   IndicatorShortName(indicatorName);
   
   return(0);
}

int deinit()
  {
   int length=StringLen(labelNames);
   for(int i=ObjectsTotal()-1; i>=0; i--)
   {
   string name = ObjectName(i);
   if(StringSubstr(name,0,length) == labelNames)  ObjectDelete(name);
   }
return(0);
  }
//
//
//
//

int start()
{
   ////if (Digits==3 || Digits==5) 
   ////      pipMultiplier = 10;
   ////else  pipMultiplier = 1; 
   
   int counted_bars=IndicatorCounted();
   int i,k,limit;

   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
         limit = MathMin(Bars-counted_bars,Bars-1);
         if (ArrayRange(emas,0) != Bars) ArrayResize(emas,Bars);

   //
   //
   //
   //
   //

   for(i=limit; i>=0; i--)
    {
     CCI2[i] = iCCI(NULL,0,CCIPeriod2,CCIPrice2,i);
     prices[i] = iMA(NULL,0,1,0,MODE_SMA,CCIPrice,i);
     
     double avg = 0;   for(k=0; k<CCIPeriod; k++) avg += prices[i+k];   avg /= CCIPeriod;
     double dev = 0;   for(k=0; k<CCIPeriod; k++) dev += MathAbs(prices[i+k]-avg);   dev /= CCIPeriod;
        
        if (dev!=0) CCI[i] = iT3((prices[i]-avg)/(0.015*dev),i);
        else        CCI[i] = iT3(0,i);  
     
     if (CCI[i] > CCI[i+1])  CCUP[i] = CCI[i];                 
     if (CCI[i] < CCI[i+1])  CCDN[i] = CCI[i]; 
        
     if (drawIndicatorTrendLines || drawPriceTrendLines)
      {
       CatchBullishDivergence(i);
       CatchBearishDivergence(i);
      }           
    }
return(0);
}



double iT3(double price,int shift)
{
   int i = Bars-shift-1;
   if (i < 1)
      {
         emas[i][0] = price;
         emas[i][1] = price;
         emas[i][2] = price;
         emas[i][3] = price;
         emas[i][4] = price;
         emas[i][5] = price;
      }
   else
      {
         emas[i][0] = emas[i-1][0]+alpha*(price     -emas[i-1][0]);
         emas[i][1] = emas[i-1][1]+alpha*(emas[i][0]-emas[i-1][1]);
         emas[i][2] = emas[i-1][2]+alpha*(emas[i][1]-emas[i-1][2]);
         emas[i][3] = emas[i-1][3]+alpha*(emas[i][2]-emas[i-1][3]);
         emas[i][4] = emas[i-1][4]+alpha*(emas[i][3]-emas[i-1][4]);
         emas[i][5] = emas[i-1][5]+alpha*(emas[i][4]-emas[i-1][5]);
      }
   return(c1*emas[i][5] + c2*emas[i][4] + c3*emas[i][3] + c4*emas[i][2]);
}


void CatchBullishDivergence(int shift)
{
   shift++;
         bullishDivergence[shift] = EMPTY_VALUE;
            ObjectDelete(labelNames+"l"+DoubleToStr(Time[shift],0));
            ObjectDelete(labelNames+"l"+"os" + DoubleToStr(Time[shift],0));            
   if(!IsIndicatorLow(shift)) return;  

   //
   //
   //
   //
   //
      
   int currentLow = shift;
   int lastLow = GetIndicatorLastLow(shift+1);

   //
   //
   int cur = currentLow;    if (ConvergenceDivergence==0) cur = lastLow;
   int pre = lastLow;       if (ConvergenceDivergence==0) pre = currentLow;
   //
   //
    
   if(CCI[currentLow] > CCI[lastLow] && Low[cur] < Low[pre])
   {
      bullishDivergence[currentLow] = CCI[currentLow] - 35;  //_Point*pipMultiplier;
      if(drawPriceTrendLines == true)
                 DrawPriceTrendLine("l",Time[currentLow],Time[lastLow],Low[currentLow],Low[lastLow],clrLime,STYLE_SOLID);
      if(drawIndicatorTrendLines == true)
                 DrawIndicatorTrendLine("l",Time[currentLow],Time[lastLow],CCI[currentLow],CCI[lastLow],clrLime,STYLE_SOLID);
      if(AlertsMessage || AlertsEmail || AlertsMobile || AlertsSound)
                 SetupAlerts("Classical bullish "+ConOrDiv+" on: ",currentLow);  
                        
   }
     
   //
   //
   //
   //
   //
        
   if(CCI[currentLow] < CCI[lastLow] && Low[cur] > Low[pre])
   {
      bullishDivergence[currentLow] = CCI[currentLow] - 35;  //_Point*pipMultiplier;
      if(drawPriceTrendLines == true)
                 DrawPriceTrendLine("l",Time[currentLow],Time[lastLow],Low[currentLow],Low[lastLow], clrLime, STYLE_DOT);
      if(drawIndicatorTrendLines == true)                            
                 DrawIndicatorTrendLine("l",Time[currentLow],Time[lastLow],CCI[currentLow], CCI[lastLow], clrLime, STYLE_DOT);
      if(AlertsMessage || AlertsEmail || AlertsMobile || AlertsSound)
                 SetupAlerts("Hidden bullish "+ConOrDiv+" on: ",currentLow); 
   }
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

void CatchBearishDivergence(int shift)
{
   shift++; 
         bearishDivergence[shift] = EMPTY_VALUE;
            ObjectDelete(labelNames+"h"+DoubleToStr(Time[shift],0));
            ObjectDelete(labelNames+"h"+"os" + DoubleToStr(Time[shift],0));            
   if(IsIndicatorPeak(shift) == false) return;
   int currentPeak = shift;
   int lastPeak = GetIndicatorLastPeak(shift+1);

   //
   //
   int cur = currentPeak;    if (ConvergenceDivergence==0) cur = lastPeak;
   int pre = lastPeak;       if (ConvergenceDivergence==0) pre = currentPeak;
   //
   //
      
   if(CCI[currentPeak] < CCI[lastPeak] && High[cur] > High[pre])
   {
       bearishDivergence[currentPeak] = CCI[currentPeak] + 35;  //_Point*pipMultiplier;
       if(drawPriceTrendLines == true)
               DrawPriceTrendLine("h",Time[currentPeak],Time[lastPeak],High[currentPeak],High[lastPeak],clrRed,STYLE_SOLID);
       if(drawIndicatorTrendLines == true)
               DrawIndicatorTrendLine("h",Time[currentPeak],Time[lastPeak],CCI[currentPeak],CCI[lastPeak],clrRed,STYLE_SOLID);
       if(AlertsMessage || AlertsEmail || AlertsMobile || AlertsSound)
               SetupAlerts("Classical bearish "+ConOrDiv+" on: ",currentPeak); 
                        
   }
   
   //
   //
   //
   //
   //

   if(CCI[currentPeak] > CCI[lastPeak] && High[cur] < High[pre])
   {
      bearishDivergence[currentPeak] = CCI[currentPeak] + 35;  //_Point*pipMultiplier;
      if (drawPriceTrendLines == true)
               DrawPriceTrendLine("h",Time[currentPeak],Time[lastPeak],High[currentPeak],High[lastPeak], clrRed, STYLE_DOT);
      if (drawIndicatorTrendLines == true)
               DrawIndicatorTrendLine("h",Time[currentPeak],Time[lastPeak],CCI[currentPeak],CCI[lastPeak], clrRed, STYLE_DOT);
      if(AlertsMessage || AlertsEmail || AlertsMobile || AlertsSound)
               SetupAlerts("Hidden bearish "+ConOrDiv+" on: ",currentPeak);
                         
   }   
}
//+------------------------------------------------------------------+
bool IsIndicatorPeak(int shift)
  {
   if(CCI[shift] >= CCI[shift+1] && CCI[shift] > CCI[shift+2] && 
      CCI[shift] > CCI[shift-1])
       return(true);
   else 
       return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool IsIndicatorLow(int shift)
  {
   if(CCI[shift] <= CCI[shift+1] && CCI[shift] < CCI[shift+2] && 
      CCI[shift] < CCI[shift-1])
       return(true);
   else 
       return(false);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetIndicatorLastPeak(int shift)
  {
           for(int i = shift+5; i < Bars; i++)
             {
               if(CCI[i] >= CCI[i+1] && CCI[i] > CCI[i+2] &&
                  CCI[i] >= CCI[i-1] && CCI[i] > CCI[i-2])
                   return(i);
             }
   return(-1);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int GetIndicatorLastLow(int shift)
  {
            for(int i = shift+5; i < Bars; i++)
             {
                if(CCI[i] <= CCI[i+1] && CCI[i] < CCI[i+2] &&
                   CCI[i] <= CCI[i-1] && CCI[i] < CCI[i-2])
                    return(i);
              }
     
    return(-1);
  }

void SetupAlerts(string message, int shift)
  {
   if(shift <= 2 && Time[shift] != lastAlertTime)
     {
       string mess = message + _Symbol + " , " + _Period + " minutes chart";
       lastAlertTime = Time[shift];
       if (AlertsSound)   PlaySound(SoundFile);
       if (AlertsMessage) Alert(mess);
       if (AlertsEmail)   SendMail(_Symbol,mess);
       if (AlertsMobile)  SendNotification(mess);
     }
  }


void DrawPriceTrendLine(string first,datetime t1, datetime t2, double p1, double p2, color lineColor, double style)
{
   string label = labelNames+first+"os"+DoubleToStr(t1,0);
   ObjectDelete(label);
      ObjectCreate(label, OBJ_TREND, 0, t1, p1, t2, p2, 0, 0);
         ObjectSet(label, OBJPROP_RAY, 0);
         ObjectSet(label, OBJPROP_COLOR, lineColor);
         ObjectSet(label, OBJPROP_STYLE, style);
         ObjectSet(label, OBJPROP_SELECTABLE, false);
}
void DrawIndicatorTrendLine(string first,datetime t1, datetime t2, double p1, double p2, color lineColor, double style)
{
   int indicatorWindow = WindowFind(indicatorName);
   if (indicatorWindow < 0) return;
   
   string label = labelNames+first+DoubleToStr(t1,0);
   ObjectDelete(label);
      ObjectCreate(label, OBJ_TREND, indicatorWindow, t1, p1, t2, p2, 0, 0);
         ObjectSet(label, OBJPROP_RAY, 0);
         ObjectSet(label, OBJPROP_COLOR, lineColor);
         ObjectSet(label, OBJPROP_STYLE, style);
         ObjectSet(label, OBJPROP_SELECTABLE, false);
}