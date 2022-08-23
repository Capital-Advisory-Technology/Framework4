//+------------------------------------------------------------------+
//|                                                      Wildhog.mq4 |
//|                               Copyright © 2014, Gehtsoft USA LLC |
//|                                            http://fxcodebase.com |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""

#property indicator_separate_window
#property indicator_buffers 5
#property indicator_color1  LimeGreen
#property indicator_color2  Orange
#property indicator_color3  Orange
#property indicator_color4  LimeGreen
#property indicator_color5  Magenta
#property indicator_width1  2
#property indicator_width2  2
#property indicator_width3  2

//
//
//
//
//

extern int    Length                    = 8;
extern double Overbought_Level          = 60.0;
extern double Oversold_Level            = 40.0;
extern int    DivergearrowSize          = 1; 
extern double DivergencearrowsUpperGap  = 4;
extern double DivergencearrowsLowerGap  = 4;
extern bool   drawDivergences           = true;
extern bool   ShowClassicalDivergence   = true;
extern bool   ShowHiddenDivergence      = true;
extern bool   drawIndicatorTrendLines   = true;
extern bool   drawPriceTrendLines       = true;
extern color  divergenceBullishColor    = DeepSkyBlue;
extern color  divergenceBearishColor    = DeepPink;
extern string drawLinesIdentificator    = "whdiverge1";
extern bool   divergenceAlert           = true;
extern bool   divergenceAlertsMessage   = true;
extern bool   divergenceAlertsSound     = true;
extern bool   divergenceAlertsEmail     = false;
extern bool   divergenceAlertsNotify    = false;
extern string divergenceAlertsSoundName = "alert1.wav";


double Wildhog[];
double whda[];
double whdb[];
double bullishDivergence[];
double bearishDivergence[];
double slope[];

string indicatorName;
string labelNames;

//
//
//
//
//

int init()
{
   IndicatorBuffers(6);
   SetIndexBuffer(0,Wildhog);
   SetIndexBuffer(1,whda); 
   SetIndexBuffer(2,whdb); 
   SetIndexBuffer(3,bullishDivergence); SetIndexStyle(3,DRAW_ARROW,0,DivergearrowSize); SetIndexArrow(3,233);
   SetIndexBuffer(4,bearishDivergence); SetIndexStyle(4,DRAW_ARROW,0,DivergearrowSize); SetIndexArrow(4,234); 
   SetIndexBuffer(5,slope);
   SetLevelValue(0,Overbought_Level);
   SetLevelValue(1,Oversold_Level);
   
      //
      //
      //
      //
      //
       
      labelNames    = "Wildhog_DivergenceLine "+drawLinesIdentificator+":";
      indicatorName = "Wildhog";
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
//

int start()
{
   int counted_bars=IndicatorCounted();
   int i,limit;

   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
         limit = MathMin(Bars-counted_bars,Bars-1);
         if (slope[limit] == -1) CleanPoint(limit,whda,whdb);
    //
    //
    //
    //
    //
    
    for(i=limit; i>=0; i--) 
    {
       double Min =  Low[iLowest(NULL, 0,MODE_LOW, Length,i)];
       double Max = High[iHighest(NULL,0,MODE_HIGH,Length,i)];
  
       if (Max!=Min)
            Wildhog[i] = 100*(Close[i]-Min)/(3*(Max-Min))+Wildhog[i+1]/1.5;
       else Wildhog[i] = 0;
       
       //
       //
       //
       //
       //
       
       whda[i]  = EMPTY_VALUE;
       whdb[i]  = EMPTY_VALUE;  
       slope[i] = slope[i+1];
       if (Wildhog[i]>Wildhog[i+1]) slope[i] = 1;
       if (Wildhog[i]<Wildhog[i+1]) slope[i] =-1;
       if (slope[i] == -1) PlotPoint(i,whda,whdb,Wildhog); 
       if (drawDivergences)
       {
          CatchBullishDivergence(i);
          CatchBearishDivergence(i);
       }             
    } 
 return(0);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

void CleanPoint(int i,double& first[],double& second[])
{
   if ((second[i]  != EMPTY_VALUE) && (second[i+1] != EMPTY_VALUE))
        second[i+1] = EMPTY_VALUE;
   else
   if ((first[i] != EMPTY_VALUE) && (first[i+1] != EMPTY_VALUE) && (first[i+2] == EMPTY_VALUE))
        first[i+1] = EMPTY_VALUE;
}

//
//
//
//
//

void PlotPoint(int i,double& first[],double& second[],double& from[])
{
    if (first[i+1] == EMPTY_VALUE)
    {
      if (first[i+2] == EMPTY_VALUE) 
      {
          first[i]    = from[i];
          first[i+1]  = from[i+1];
          second[i]   = EMPTY_VALUE;
      }
      else 
      {
          second[i]   = from[i];
          second[i+1] = from[i+1];
          first[i]    = EMPTY_VALUE;
      }
   }
   else
   {
          first[i]   = from[i];
          second[i]  = EMPTY_VALUE;
   }
}

//
//
//
//
//

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
   int lastLow    = GetIndicatorLastLow(shift+1);
   if (Wildhog[currentLow] > Wildhog[lastLow] && Low[currentLow] < Low[lastLow])
   {
     if (ShowClassicalDivergence)
     {
        bullishDivergence[currentLow] = Wildhog[currentLow] - DivergencearrowsLowerGap;
        if (drawPriceTrendLines)    DrawPriceTrendLine("l",Time[currentLow],Time[lastLow],Low[currentLow],Low[lastLow],            divergenceBullishColor,STYLE_SOLID);
        if (drawIndicatorTrendLines)DrawIndicatorTrendLine("l",Time[currentLow],Time[lastLow],Wildhog[currentLow],Wildhog[lastLow],divergenceBullishColor,STYLE_SOLID);
        if (divergenceAlert)        DisplayAlert("Classical bullish divergence",currentLow);  
     }
                        
   }
     
   //
   //
   //
   //
   //
        
   if (Wildhog[currentLow] < Wildhog[lastLow] && Low[currentLow] > Low[lastLow])
   {
     if (ShowHiddenDivergence)
     {
        bullishDivergence[currentLow] = Wildhog[currentLow] - DivergencearrowsLowerGap;
        if (drawPriceTrendLines)     DrawPriceTrendLine("l",Time[currentLow],Time[lastLow],Low[currentLow],Low[lastLow],            divergenceBullishColor,STYLE_DOT);
        if (drawIndicatorTrendLines) DrawIndicatorTrendLine("l",Time[currentLow],Time[lastLow],Wildhog[currentLow],Wildhog[lastLow],divergenceBullishColor,STYLE_DOT);
        if (divergenceAlert)         DisplayAlert("Hidden bullish divergence",currentLow); 
     }
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
   //
   //
   //
      
   if (Wildhog[currentPeak] < Wildhog[lastPeak] && High[currentPeak]>High[lastPeak])
   {
     if (ShowClassicalDivergence)
     {
        bearishDivergence[currentPeak] = Wildhog[currentPeak] + DivergencearrowsUpperGap;
        if (drawPriceTrendLines)     DrawPriceTrendLine("h",Time[currentPeak],Time[lastPeak],High[currentPeak],High[lastPeak],          divergenceBearishColor,STYLE_SOLID);
        if (drawIndicatorTrendLines) DrawIndicatorTrendLine("h",Time[currentPeak],Time[lastPeak],Wildhog[currentPeak],Wildhog[lastPeak],divergenceBearishColor,STYLE_SOLID);
        if (divergenceAlert)         DisplayAlert("Classical bearish divergence",currentPeak);
     } 
                        
   }
   
   //
   //
   //
   //
   //

   if (Wildhog[currentPeak] > Wildhog[lastPeak] && High[currentPeak] < High[lastPeak])
   {
     if (ShowHiddenDivergence)
     {
        bearishDivergence[currentPeak] = Wildhog[currentPeak] + DivergencearrowsUpperGap;
        if (drawPriceTrendLines)     DrawPriceTrendLine("h",Time[currentPeak],Time[lastPeak],High[currentPeak],High[lastPeak],          divergenceBearishColor,STYLE_DOT);
        if (drawIndicatorTrendLines) DrawIndicatorTrendLine("h",Time[currentPeak],Time[lastPeak],Wildhog[currentPeak],Wildhog[lastPeak],divergenceBearishColor,STYLE_DOT);
        if (divergenceAlert)         DisplayAlert("Hidden bearish divergence",currentPeak);
     }
                         
   }   
}

//
//
//
//
//

bool IsIndicatorPeak(int shift)
{
   if(Wildhog[shift] >= Wildhog[shift+1] && Wildhog[shift] > Wildhog[shift+2] && Wildhog[shift] > Wildhog[shift-1])
       return(true);
   else 
       return(false);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//

bool IsIndicatorLow(int shift)
{
   if(Wildhog[shift] <= Wildhog[shift+1] && Wildhog[shift] < Wildhog[shift+2] && Wildhog[shift] < Wildhog[shift-1])
       return(true);
   else 
       return(false);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//

int GetIndicatorLastPeak(int shift)
{
    for(int i = shift+5; i < Bars; i++)
    {
       if(Wildhog[i] >= Wildhog[i+1] && Wildhog[i] > Wildhog[i+2] && Wildhog[i] >= Wildhog[i-1] && Wildhog[i] > Wildhog[i-2])
         return(i);
    }
return(-1);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//

int GetIndicatorLastLow(int shift)
{
    for (int i = shift+5; i < Bars; i++)
    {
       if (Wildhog[i] <= Wildhog[i+1] && Wildhog[i] < Wildhog[i+2] && Wildhog[i] <= Wildhog[i-1] && Wildhog[i] < Wildhog[i-2])
         return(i);
}
     
return(-1);
}

//
//
//
//
//

void DisplayAlert(string doWhat, int shift)
{
    string dmessage;
    static datetime lastAlertTime;
    if(shift <= 2 && Time[0] != lastAlertTime)
    {
      dmessage =  StringConcatenate(Symbol()," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," Wildhog ",doWhat);
          if (divergenceAlertsMessage) Alert(dmessage);
          if (divergenceAlertsNotify)  SendNotification(dmessage);
          if (divergenceAlertsEmail)   SendMail(StringConcatenate(Symbol()," Wildhog "),dmessage);
          if (divergenceAlertsSound)   PlaySound(divergenceAlertsSoundName); 
          lastAlertTime = Time[0];
    }
}

//
//
//
//
//

void DrawPriceTrendLine(string first,datetime t1, datetime t2, double p1, double p2, color lineColor, double style)
{
    string label = labelNames+first+"os"+DoubleToStr(t1,0);
      ObjectDelete(label);
      ObjectCreate(label, OBJ_TREND, 0, t1, p1, t2, p2, 0, 0);
         ObjectSet(label, OBJPROP_RAY, 0);
         ObjectSet(label, OBJPROP_COLOR, lineColor);
         ObjectSet(label, OBJPROP_STYLE, style);
}

//
//
//
//
//

void DrawIndicatorTrendLine(string first,datetime t1, datetime t2, double p1, double p2, color lineColor, double style)
{
    int indicatorWindow = WindowFind(indicatorName);
    if (indicatorWindow < 0) return;
    
    //
    //
    //
    //
    //
    
    string label = labelNames+first+DoubleToStr(t1,0);
      ObjectDelete(label);
      ObjectCreate(label, OBJ_TREND, indicatorWindow, t1, p1, t2, p2, 0, 0);
         ObjectSet(label, OBJPROP_RAY, 0);
         ObjectSet(label, OBJPROP_COLOR, lineColor);
         ObjectSet(label, OBJPROP_STYLE, style);
}
