//+------------------------------------------------------------------+
//|                                                       %r nrp.mq4 |
//+------------------------------------------------------------------+
#property copyright "www,forex-station.com"
#property link      "www,forex-station.com"

#property indicator_separate_window
#property indicator_buffers    3
#property indicator_color1     clrRoyalBlue
#property indicator_color2     clrRed
#property indicator_color3     clrOrange
#property indicator_width1     1
#property indicator_width2     1
#property indicator_minimum    -105
#property indicator_maximum    5
#property indicator_levelcolor clrSteelBlue
#property indicator_levelstyle 2
#property strict

//
//
//
//
//

enum enMaTypes
{
   ma_sma,     // Simple moving average
   ma_ema,     // Exponential moving average
   ma_smma,    // Smoothed MA
   ma_lwma,    // Linear weighted MA
   ma_slwma,   // Smoothed LWMA
   ma_dsema,   // Double Smoothed Exponential average
   ma_tema,    // Triple exponential moving average - TEMA
   ma_lsma     // Linear regression value (lsma)
};

extern int            WprPeriod                    = 14;    // Wpr period
extern int            T3Period                     = 10;    // T3 period
extern double         T3Hot                        = 0.7;   // T3 hot
extern bool           T3Original                   = false; // T3 original?
extern int            MaPeriod                     = 4;     // Wpr ma period
extern enMaTypes      MaMode                       = ma_sma;// Wpr ma method 
extern double         levelOb                      = -25;   // Overbought level
extern double         levelOs                      = -75;   // Oversold level

double wpr[],wprma[],Up[],Dn[],trend[];

//
//
//
//
//

int init()
{
   IndicatorBuffers(5);
   SetIndexBuffer(0,Up);      SetIndexStyle(0,DRAW_ARROW);  SetIndexArrow(0,159); 
   SetIndexBuffer(1,Dn);      SetIndexStyle(1,DRAW_ARROW);  SetIndexArrow(1,159);
   SetIndexBuffer(2,wprma);   SetIndexStyle(2,DRAW_LINE); 
   SetIndexBuffer(3,wpr);
   SetIndexBuffer(4,trend); 
   SetLevelValue(0,levelOs);
   SetLevelValue(1,levelOb);
   IndicatorShortName(" WPR T3 ("+(string)WprPeriod+")");
return(0);
}
int deinit() {   return(0); }
  
//+------------------------------------------------------------------+
//| Williams? Percent Range                                          |
//+------------------------------------------------------------------+
//
//

int start()
{
   int counted_bars=IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
           int limit=MathMin(Bars-counted_bars,Bars-1);

   //
   //
   //
   //
   //
    
   for (int i=limit; i>=0; i--)
   { 
       double hi   = High[iHighest(NULL,0,MODE_HIGH,WprPeriod,i)];
       double lo   =  Low[iLowest(NULL, 0,MODE_LOW, WprPeriod,i)];
       wpr[i] = (hi!=lo) ? iT3(-100*(hi - Close[i]) / (hi - lo),T3Period,T3Hot,T3Original,i) : 0;
       wprma[i] = iCustomMa(MaMode,wpr[i],MaPeriod,i,Bars);
       trend[i] = (i<Bars-1) ? (wpr[i]>wpr[i+1])  ? 1 : (wpr[i]<wpr[i+1])  ? -1 : trend[i+1] : 0;  
       Up[i] = (trend[i] ==  1) ? wpr[i] : EMPTY_VALUE;
       Dn[i] = (trend[i] == -1) ? wpr[i] : EMPTY_VALUE;      
    }
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

#define t3Instances 1
double workT3[][t3Instances*6];
double workT3Coeffs[][6];
#define _tperiod 0
#define _c1      1
#define _c2      2
#define _c3      3
#define _c4      4
#define _alpha   5

//
//
//
//
//

double iT3(double price, double period, double hot, bool original, int i, int tinstanceNo=0)
{
   if (ArrayRange(workT3,0) != Bars)                 ArrayResize(workT3,Bars);
   if (ArrayRange(workT3Coeffs,0) < (tinstanceNo+1)) ArrayResize(workT3Coeffs,tinstanceNo+1);

   if (workT3Coeffs[tinstanceNo][_tperiod] != period)
   {
     workT3Coeffs[tinstanceNo][_tperiod] = period;
        double a = hot;
            workT3Coeffs[tinstanceNo][_c1] = -a*a*a;
            workT3Coeffs[tinstanceNo][_c2] = 3*a*a+3*a*a*a;
            workT3Coeffs[tinstanceNo][_c3] = -6*a*a-3*a-3*a*a*a;
            workT3Coeffs[tinstanceNo][_c4] = 1+3*a+a*a*a+3*a*a;
            if (original)
                 workT3Coeffs[tinstanceNo][_alpha] = 2.0/(1.0 + period);
            else workT3Coeffs[tinstanceNo][_alpha] = 2.0/(2.0 + (period-1.0)/2.0);
   }
   
   //
   //
   //
   //
   //
   
   int instanceNo = tinstanceNo*6;
   int r = Bars-i-1;
   if (r == 0)
      {
         workT3[r][0+instanceNo] = price;
         workT3[r][1+instanceNo] = price;
         workT3[r][2+instanceNo] = price;
         workT3[r][3+instanceNo] = price;
         workT3[r][4+instanceNo] = price;
         workT3[r][5+instanceNo] = price;
      }
   else
      {
         workT3[r][0+instanceNo] = workT3[r-1][0+instanceNo]+workT3Coeffs[tinstanceNo][_alpha]*(price                  -workT3[r-1][0+instanceNo]);
         workT3[r][1+instanceNo] = workT3[r-1][1+instanceNo]+workT3Coeffs[tinstanceNo][_alpha]*(workT3[r][0+instanceNo]-workT3[r-1][1+instanceNo]);
         workT3[r][2+instanceNo] = workT3[r-1][2+instanceNo]+workT3Coeffs[tinstanceNo][_alpha]*(workT3[r][1+instanceNo]-workT3[r-1][2+instanceNo]);
         workT3[r][3+instanceNo] = workT3[r-1][3+instanceNo]+workT3Coeffs[tinstanceNo][_alpha]*(workT3[r][2+instanceNo]-workT3[r-1][3+instanceNo]);
         workT3[r][4+instanceNo] = workT3[r-1][4+instanceNo]+workT3Coeffs[tinstanceNo][_alpha]*(workT3[r][3+instanceNo]-workT3[r-1][4+instanceNo]);
         workT3[r][5+instanceNo] = workT3[r-1][5+instanceNo]+workT3Coeffs[tinstanceNo][_alpha]*(workT3[r][4+instanceNo]-workT3[r-1][5+instanceNo]);
      }

   //
   //
   //
   //
   //
   
   return(workT3Coeffs[tinstanceNo][_c1]*workT3[r][5+instanceNo] + 
          workT3Coeffs[tinstanceNo][_c2]*workT3[r][4+instanceNo] + 
          workT3Coeffs[tinstanceNo][_c3]*workT3[r][3+instanceNo] + 
          workT3Coeffs[tinstanceNo][_c4]*workT3[r][2+instanceNo]);
}

//------------------------------------------------------------------
//                                                                  
//------------------------------------------------------------------
//
//
//
//
//

#define _maInstances 1
#define _maWorkBufferx1 1*_maInstances
#define _maWorkBufferx2 2*_maInstances
#define _maWorkBufferx3 3*_maInstances

double iCustomMa(int mode, double price, double length, int r, int bars, int instanceNo=0)
{
   r = bars-r-1;
   switch (mode)
   {
      case ma_sma   : return(iSma(price,(int)ceil(length),r,bars,instanceNo));
      case ma_ema   : return(iEma(price,length,r,bars,instanceNo));
      case ma_smma  : return(iSmma(price,(int)ceil(length),r,bars,instanceNo));
      case ma_lwma  : return(iLwma(price,(int)ceil(length),r,bars,instanceNo));
      case ma_slwma : return(iSlwma(price,(int)ceil(length),r,bars,instanceNo));
      case ma_dsema : return(iDsema(price,length,r,bars,instanceNo));
      case ma_tema  : return(iTema(price,(int)ceil(length),r,bars,instanceNo));
      case ma_lsma  : return(iLinr(price,(int)ceil(length),r,bars,instanceNo));
      default       : return(price);
   }
}

//
//
//
//
//

double workSma[][_maWorkBufferx1];
double iSma(double price, int period, int r, int _bars, int instanceNo=0)
{
   if (ArrayRange(workSma,0)!= _bars) ArrayResize(workSma,_bars);

   workSma[r][instanceNo+0] = price;
   double avg = price; int k=1;  for(; k<period && (r-k)>=0; k++) avg += workSma[r-k][instanceNo+0];  
   return(avg/(double)k);
}

//
//
//
//
//

double workEma[][_maWorkBufferx1];
double iEma(double price, double period, int r, int _bars, int instanceNo=0)
{
   if (ArrayRange(workEma,0)!= _bars) ArrayResize(workEma,_bars);

   workEma[r][instanceNo] = price;
   if (r>0 && period>1)
          workEma[r][instanceNo] = workEma[r-1][instanceNo]+(2.0/(1.0+period))*(price-workEma[r-1][instanceNo]);
   return(workEma[r][instanceNo]);
}

//
//
//
//
//

double workSmma[][_maWorkBufferx1];
double iSmma(double price, double period, int r, int _bars, int instanceNo=0)
{
   if (ArrayRange(workSmma,0)!= _bars) ArrayResize(workSmma,_bars);

   workSmma[r][instanceNo] = price;
   if (r>1 && period>1)
          workSmma[r][instanceNo] = workSmma[r-1][instanceNo]+(price-workSmma[r-1][instanceNo])/period;
   return(workSmma[r][instanceNo]);
}

//
//
//
//
//

double workLwma[][_maWorkBufferx1];
double iLwma(double price, double period, int r, int _bars, int instanceNo=0)
{
   if (ArrayRange(workLwma,0)!= _bars) ArrayResize(workLwma,_bars);
   
   workLwma[r][instanceNo] = price; if (period<=1) return(price);
      double sumw = period;
      double sum  = period*price;

      for(int k=1; k<period && (r-k)>=0; k++)
      {
         double weight = period-k;
                sumw  += weight;
                sum   += weight*workLwma[r-k][instanceNo];  
      }             
      return(sum/sumw);
}

//
//
//
//
//


double workSlwma[][_maWorkBufferx2];
double iSlwma(double price, double period, int r, int _bars, int instanceNo=0)
{
   if (ArrayRange(workSlwma,0)!= _bars) ArrayResize(workSlwma,_bars); 

   //
   //
   //
   //
   //

      int SqrtPeriod = (int)MathFloor(MathSqrt(period)); instanceNo *= 2;
         workSlwma[r][instanceNo] = price;

         //
         //
         //
         //
         //
               
         double sumw = period;
         double sum  = period*price;
   
         for(int k=1; k<period && (r-k)>=0; k++)
         {
            double weight = period-k;
                   sumw  += weight;
                   sum   += weight*workSlwma[r-k][instanceNo];  
         }             
         workSlwma[r][instanceNo+1] = (sum/sumw);

         //
         //
         //
         //
         //
         
         sumw = SqrtPeriod;
         sum  = SqrtPeriod*workSlwma[r][instanceNo+1];
            for(int k=1; k<SqrtPeriod && (r-k)>=0; k++)
            {
               double weight = SqrtPeriod-k;
                      sumw  += weight;
                      sum   += weight*workSlwma[r-k][instanceNo+1];  
            }
   return(sum/sumw);
}

//
//
//
//
//

double workDsema[][_maWorkBufferx2];
#define _ema1 0
#define _ema2 1

double iDsema(double price, double period, int r, int _bars, int instanceNo=0)
{
   if (ArrayRange(workDsema,0)!= _bars) ArrayResize(workDsema,_bars); instanceNo*=2;

   //
   //
   //
   //
   //
   
   workDsema[r][_ema1+instanceNo] = price;
   workDsema[r][_ema2+instanceNo] = price;
   if (r>0 && period>1)
   {
      double alpha = 2.0 /(1.0+MathSqrt(period));
          workDsema[r][_ema1+instanceNo] = workDsema[r-1][_ema1+instanceNo]+alpha*(price                         -workDsema[r-1][_ema1+instanceNo]);
          workDsema[r][_ema2+instanceNo] = workDsema[r-1][_ema2+instanceNo]+alpha*(workDsema[r][_ema1+instanceNo]-workDsema[r-1][_ema2+instanceNo]); }
   return(workDsema[r][_ema2+instanceNo]);
}

//
//
//
//
//

double workTema[][_maWorkBufferx3];
#define _tema1 0
#define _tema2 1
#define _tema3 2

double iTema(double price, double period, int r, int bars, int instanceNo=0)
{
   if (ArrayRange(workTema,0)!= bars) ArrayResize(workTema,bars); instanceNo*=3;

   //
   //
   //
   //
   //
      
   workTema[r][_tema1+instanceNo] = price;
   workTema[r][_tema2+instanceNo] = price;
   workTema[r][_tema3+instanceNo] = price;
   if (r>0 && period>1)
   {
      double alpha = 2.0 / (1.0+period);
          workTema[r][_tema1+instanceNo] = workTema[r-1][_tema1+instanceNo]+alpha*(price                         -workTema[r-1][_tema1+instanceNo]);
          workTema[r][_tema2+instanceNo] = workTema[r-1][_tema2+instanceNo]+alpha*(workTema[r][_tema1+instanceNo]-workTema[r-1][_tema2+instanceNo]);
          workTema[r][_tema3+instanceNo] = workTema[r-1][_tema3+instanceNo]+alpha*(workTema[r][_tema2+instanceNo]-workTema[r-1][_tema3+instanceNo]); }
   return(workTema[r][_tema3+instanceNo]+3.0*(workTema[r][_tema1+instanceNo]-workTema[r][_tema2+instanceNo]));
}

//
//
//
//
//

double workLinr[][_maWorkBufferx1];
double iLinr(double price, int period, int r, int bars, int instanceNo=0)
{
   if (ArrayRange(workLinr,0)!= bars) ArrayResize(workLinr,bars);

   //
   //
   //
   //
   //
   
      period = MathMax(period,1);
      workLinr[r][instanceNo] = price;
      if (r<period) return(price);
         double lwmw = period; double lwma = lwmw*price;
         double sma  = price;
         for(int k=1; k<period && (r-k)>=0; k++)
         {
            double weight = period-k;
                   lwmw  += weight;
                   lwma  += weight*workLinr[r-k][instanceNo];  
                   sma   +=        workLinr[r-k][instanceNo];
         }             
   
   return(3.0*lwma/lwmw-2.0*sma/period);
}
