//+------------------------------------------------------------------+
//|                                          ANCHORED   Momentum.mq4 |
//|                      Copyright © 2004, MetaQuotes Software Corp. |
//|                                       http://www.metaquotes.net/ |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2010, Umnyashkin Victor"
#property link      "http://www.metaquotes.net/"

#property indicator_separate_window
#property indicator_buffers 1
#property indicator_color1 DodgerBlue
//---- input parameters
extern int MomPeriod=11;
extern int SmoothPeriod=6;
extern double Level=0;

//---- buffers
double MomBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   string short_name;
//---- indicator line
   SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(0,MomBuffer);
//---- name for DataWindow and indicator subwindow label
   short_name="AnchoredMom("+MomPeriod+","+SmoothPeriod+")";
   IndicatorShortName(short_name);
   SetIndexLabel(0,short_name);
//----
   SetIndexDrawBegin(0,MomPeriod);
//----
   SetLevelValue(0,Level);
   SetLevelValue(1,-Level); 
//----   
   return(0);
  }
//+------------------------------------------------------------------+
//| Momentum                                                         |
//+------------------------------------------------------------------+
int start()
  {
   int i,counted_bars=IndicatorCounted();
   int SMAPeriod=2*MomPeriod+1;
//----
   if(Bars<=SMAPeriod) return(0);
//---- initial zero
   if(counted_bars<1)
      for(i=1;i<=SMAPeriod;i++) MomBuffer[Bars-i]=0.0;
//----
   i=Bars-SMAPeriod-1;
   if(counted_bars>=SMAPeriod) i=Bars-counted_bars-1;
   while(i>=0)
     {
      double SMA=iMA(NULL,Period(),SMAPeriod,0,MODE_SMA,PRICE_CLOSE,i);
      double EMA=iMA(NULL,Period(),SmoothPeriod,0,MODE_EMA,PRICE_CLOSE,i);
      
      if( SMA == 0 ){i--;continue;}
    
      MomBuffer[i]=100*(EMA/SMA-1);
      
      //MomBuffer[i]=Close[i]*100/Close[i+MomPeriod];
      i--;
     }
   return(0);
  }
//+------------------------------------------------------------------+