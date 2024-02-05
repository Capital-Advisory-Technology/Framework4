//+------------------------------------------------------------------+
//|                                                          MPC.mq4 |
//|                                      Copyright � 2007, Alexandre |
//|                       http://www.kroufr.ru/content/view/885/124/ |
//+------------------------------------------------------------------+
#property copyright "Copyright � 2007, Alexandre"
#property link "http://www.kroufr.ru/content/view/885/124/"
//----
#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Magenta
#property indicator_color2 Red
#property indicator_color3 Aqua
//---- input parameters
extern int MPC_Range = 40;
extern bool LastBarOnly = true; 
//---- buffers
double UppValueBuffer[];
double MidPointBuffer[];
double LowValueBuffer[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function |
//+------------------------------------------------------------------+
int init()
  {
//----
   if (MPC_Range <= 1) { MPC_Range = 1; }
//---- indicators
   IndicatorShortName("Middle _Point Channel (" + MPC_Range + ")"); 
//----
   SetIndexStyle(0, DRAW_LINE); 
   SetIndexLabel(0, "Upper MPC Bound"); 
   SetIndexBuffer(0, UppValueBuffer); 
   SetIndexDrawBegin(0, MPC_Range); 
//----
   SetIndexStyle(1, DRAW_LINE);
   SetIndexLabel(1, "MPC Line"); 
   SetIndexBuffer(1, MidPointBuffer); 
   SetIndexDrawBegin(1, MPC_Range); 
//----
   SetIndexStyle(2, DRAW_LINE); 
   SetIndexLabel(2, "Lower MPC Bound"); 
   SetIndexBuffer(2, LowValueBuffer); 
   SetIndexDrawBegin(2, MPC_Range); 
//----
   return(0);
  }
//+------------------------------------------------------------------+
//| Custom indicator deinitialization function                       |
//+------------------------------------------------------------------+
int deinit()
{
//----
return(0);
}
//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int start()
  {
   int counted_bars = IndicatorCounted();
   int Limit;
   int i, cnt_bars;
   double hhv, llv, m_pr; 
   static bool   run_once; 
   static double m_pr_old; 
//----
   if(counted_bars < 0) 
       return(-1); 
   Limit = Bars - counted_bars;
// run once on start
   if(run_once == false) 
       cnt_bars = Limit - MPC_Range; 
   else
       if(LastBarOnly == false) 
           cnt_bars = Limit; 
       else
           cnt_bars = 0; 
   m_pr = (High[cnt_bars] + Low[cnt_bars]) / 2.0; 
//----
   if(MathAbs(m_pr - m_pr_old) < _Point) 
       return(0); 
   else 
       m_pr_old = m_pr; 
//----
   for(i = cnt_bars; i >= 0; i--) 
     {
       hhv = High[iHighest(NULL, 0, MODE_HIGH, MPC_Range, i)]; 
       llv =  Low[iLowest (NULL, 0,  MODE_LOW, MPC_Range, i)]; 
       UppValueBuffer[i] = hhv;
       MidPointBuffer[i] = (hhv + llv) / 2.0; 
       LowValueBuffer[i] = llv;
     } 
//----
   if(run_once == false) 
       run_once = true; 
//----
  return(0);
 }
//+------------------------------------------------------------------+