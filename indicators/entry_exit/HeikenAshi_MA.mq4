//+------------------------------------------------------------------+
//|                                            Heiken Ashi Ma T3.mq4 |
//+------------------------------------------------------------------+
//|                                                      mod by Raff |
//|                                               2009 mod by mladen |
//|  tools copied and pasted alerts from another HA indy so blame me |
//+------------------------------------------------------------------+
//------------------------------------------------------------------
#property copyright "www.forex-tsd.com"
#property link      "www.forex-tsd.com"
//------------------------------------------------------------------

#property indicator_chart_window
#property indicator_buffers 6
#property indicator_color1  clrSandyBrown
#property indicator_color2  clrDodgerBlue
#property indicator_color3  clrSandyBrown
#property indicator_color4  clrDodgerBlue
#property indicator_color5  clrSandyBrown
#property indicator_color6  clrDodgerBlue
#property indicator_width3  2
#property indicator_width4  2
#property indicator_width5  1
#property indicator_width6  1

//
//
//
//
//

enum maType   
{
   ma_sma,  // Simple moving average
   ma_ema,  // Exponential moving average
   ma_smma, // Smoothed moving average
   ma_lwma, // Linear weighted moving average
   ma_t3    // T3
};
extern int    MaPeriod        = 5;
extern maType MaMetod         = ma_t3;
extern int    Step            = 0;
extern bool   BetterFormula   = true;
extern double T3Hot           = 1.00;
extern bool   T3Original      = false;
extern bool   SortedValues    = true;

extern bool   ShowArrows      = false;
extern bool   alertsOn        = false;
extern bool   alertsOnCurrent = false;
extern bool   alertsMessage   = true;
extern bool   alertsSound     = false;
extern bool   alertsEmail     = false;

//
//
//
//
//

double Buffer1[];
double Buffer2[];
double Buffer3[];
double Buffer4[];
double UpArrow[];
double DnArrow[];
double trend[];

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

int init()
{
   IndicatorBuffers(7);
   int style = DRAW_NONE; if (ShowArrows) style = DRAW_ARROW;
   SetIndexBuffer(0, Buffer1); SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexBuffer(1, Buffer2); SetIndexStyle(1,DRAW_HISTOGRAM);
   SetIndexBuffer(2, Buffer3); SetIndexStyle(2,DRAW_HISTOGRAM);
   SetIndexBuffer(3, Buffer4); SetIndexStyle(3,DRAW_HISTOGRAM);
   SetIndexBuffer(4, UpArrow); SetIndexStyle(4,style); SetIndexArrow(4,233);
   SetIndexBuffer(5, DnArrow); SetIndexStyle(5,style); SetIndexArrow(5,234);
   SetIndexBuffer(6, trend);
      MaPeriod = MathMax(1,MaPeriod);
   return(0);
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

int start()
{
   int counted_bars=IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
           int limit=MathMin(Bars-counted_bars,Bars-1);
           int pointModifier = 1;if (Digits==3 || Digits==5) pointModifier = 10;

   //
   //
   //
   //
   //
   
   for(int pos=limit; pos >= 0; pos--)
   {
      if (MaMetod==ma_t3)
         {
            double maOpen  = iT3(Open[pos] ,MaPeriod,T3Hot,T3Original,pos,0);
            double maClose = iT3(Close[pos],MaPeriod,T3Hot,T3Original,pos,1);
            double maLow   = iT3(Low[pos]  ,MaPeriod,T3Hot,T3Original,pos,2);
            double maHigh  = iT3(High[pos] ,MaPeriod,T3Hot,T3Original,pos,3);
         }
      else
         {
            maOpen  = iMA(NULL,0,MaPeriod,0,(int)MaMetod,PRICE_OPEN ,pos);
            maClose = iMA(NULL,0,MaPeriod,0,(int)MaMetod,PRICE_CLOSE,pos);
            maLow   = iMA(NULL,0,MaPeriod,0,(int)MaMetod,PRICE_LOW  ,pos);
            maHigh  = iMA(NULL,0,MaPeriod,0,(int)MaMetod,PRICE_HIGH ,pos);
         }
      if (SortedValues)
         {
            double sort[4];
                   sort[0] = maOpen;
                   sort[1] = maClose;
                   sort[2] = maLow;
                   sort[3] = maHigh;
                     ArraySort(sort);
                        maLow  = sort[0];
                        maHigh = sort[3];
                        if (Open[pos]>Close[pos])
                              { maOpen = sort[2]; maClose = sort[1]; }
                        else  { maOpen = sort[1]; maClose = sort[2]; }
         }                        
   
      //
      //
      //
      //
      //
        
         if (BetterFormula) {
               if (maHigh!=maLow)
                     double haClose  = (maOpen+maClose)/2+(((maClose-maOpen)/(maHigh-maLow))*MathAbs((maClose-maOpen)/2));
                     else  haClose   = (maOpen+maClose)/2; }
               else        haClose   = (maOpen+maHigh+maLow+maClose)/4;
                     double haOpen   = (Buffer3[pos+1]+Buffer4[pos+1])/2;
                     double haHigh   = MathMax(maHigh, MathMax(haOpen,haClose));
                     double haLow    = MathMin(maLow,  MathMin(haOpen,haClose));

         if (haOpen<haClose) { Buffer1[pos]=haLow;  Buffer2[pos]=haHigh; } 
         else                { Buffer1[pos]=haHigh; Buffer2[pos]=haLow;  } 
                               Buffer3[pos]=haOpen;
                               Buffer4[pos]=haClose;
         
         //
         //
         //
         //
         //
            
         if (Step>0)
         {
            if( MathAbs(Buffer1[pos]-Buffer1[pos+1]) < Step*pointModifier*_Point ) Buffer1[pos]=Buffer1[pos+1];
            if( MathAbs(Buffer2[pos]-Buffer2[pos+1]) < Step*pointModifier*_Point ) Buffer2[pos]=Buffer2[pos+1];
            if( MathAbs(Buffer3[pos]-Buffer3[pos+1]) < Step*pointModifier*_Point ) Buffer3[pos]=Buffer3[pos+1];
            if( MathAbs(Buffer4[pos]-Buffer4[pos+1]) < Step*pointModifier*_Point ) Buffer4[pos]=Buffer4[pos+1];
         }         
         trend[pos] = trend[pos+1];
         if (Buffer3[pos] < Buffer4[pos]) trend[pos] =  1;
         if (Buffer3[pos] > Buffer4[pos]) trend[pos] = -1;
         if (ShowArrows)
         {
               UpArrow[pos] = EMPTY_VALUE; 
               DnArrow[pos] = EMPTY_VALUE;
               if (trend[pos]!=trend[pos+1])
               {
                  if (trend[pos]== 1) UpArrow[pos] = Low[pos]  - iATR(NULL,0,20,pos)/2.0;
                  if (trend[pos]==-1) DnArrow[pos] = High[pos] + iATR(NULL,0,20,pos)/2.0;
               }                  
         }
      }
      manageAlerts();
    return(0);
   }
      

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

void manageAlerts()
{
   if (alertsOn)
   {
      if (alertsOnCurrent)
           int whichBar = 0;
      else     whichBar = 1; whichBar = iBarShift(NULL,0,iTime(NULL,0,whichBar));
      if (trend[whichBar] != trend[whichBar+1])
      {
         if (trend[whichBar] == 1) doAlert(whichBar,"up");
         if (trend[whichBar] ==-1) doAlert(whichBar,"down");
      }         
   }
}   

//
//
//
//
//

void doAlert(int forBar, string doWhat)
{
   static string   previousAlert="nothing";
   static datetime previousTime;
   string message;
   
      if (previousAlert != doWhat || previousTime != Time[forBar]) {
          previousAlert  = doWhat;
          previousTime   = Time[forBar];

          //
          //
          //
          //
          //

          message =  StringConcatenate(Symbol()," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," HAMA trend changed to ",doWhat);
             if (alertsMessage) Alert(message);
             if (alertsEmail)   SendMail(StringConcatenate(Symbol(),"HAMA "),message);
             if (alertsSound)   PlaySound("alert2.wav");
      }
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

double workT3[][24];
double workT3Coeffs[][6];
#define _period 0
#define _c1     1
#define _c2     2
#define _c3     3
#define _c4     4
#define _alpha  5

//
//
//
//
//

double iT3(double price, double period, double hot, bool original, int i, int instanceNo=0)
{
   if (ArrayRange(workT3,0) !=Bars)                 ArrayResize(workT3,Bars);
   if (ArrayRange(workT3Coeffs,0) < (instanceNo+1)) ArrayResize(workT3Coeffs,instanceNo+1);

   if (workT3Coeffs[instanceNo][_period] != period)
   {
     workT3Coeffs[instanceNo][_period] = period;
        double a = hot;
            workT3Coeffs[instanceNo][_c1] = -a*a*a;
            workT3Coeffs[instanceNo][_c2] = 3*a*a+3*a*a*a;
            workT3Coeffs[instanceNo][_c3] = -6*a*a-3*a-3*a*a*a;
            workT3Coeffs[instanceNo][_c4] = 1+3*a+a*a*a+3*a*a;
            if (original)
                 workT3Coeffs[instanceNo][_alpha] = 2.0/(1.0 + period);
            else workT3Coeffs[instanceNo][_alpha] = 2.0/(2.0 + (period-1.0)/2.0);
   }
   
   //
   //
   //
   //
   //
   
   int buffer = instanceNo*6;
   int r = Bars-i-1;
   if (r == 0)
      {
         workT3[r][0+buffer] = price;
         workT3[r][1+buffer] = price;
         workT3[r][2+buffer] = price;
         workT3[r][3+buffer] = price;
         workT3[r][4+buffer] = price;
         workT3[r][5+buffer] = price;
      }
   else
      {
         workT3[r][0+buffer] = workT3[r-1][0+buffer]+workT3Coeffs[instanceNo][_alpha]*(price              -workT3[r-1][0+buffer]);
         workT3[r][1+buffer] = workT3[r-1][1+buffer]+workT3Coeffs[instanceNo][_alpha]*(workT3[r][0+buffer]-workT3[r-1][1+buffer]);
         workT3[r][2+buffer] = workT3[r-1][2+buffer]+workT3Coeffs[instanceNo][_alpha]*(workT3[r][1+buffer]-workT3[r-1][2+buffer]);
         workT3[r][3+buffer] = workT3[r-1][3+buffer]+workT3Coeffs[instanceNo][_alpha]*(workT3[r][2+buffer]-workT3[r-1][3+buffer]);
         workT3[r][4+buffer] = workT3[r-1][4+buffer]+workT3Coeffs[instanceNo][_alpha]*(workT3[r][3+buffer]-workT3[r-1][4+buffer]);
         workT3[r][5+buffer] = workT3[r-1][5+buffer]+workT3Coeffs[instanceNo][_alpha]*(workT3[r][4+buffer]-workT3[r-1][5+buffer]);
      }

   //
   //
   //
   //
   //
   
   return(workT3Coeffs[instanceNo][_c1]*workT3[r][5+buffer] + 
          workT3Coeffs[instanceNo][_c2]*workT3[r][4+buffer] + 
          workT3Coeffs[instanceNo][_c3]*workT3[r][3+buffer] + 
          workT3Coeffs[instanceNo][_c4]*workT3[r][2+buffer]);
}