//------------------------------------------------------------------
#property copyright "www.forex-tsd.com"
#property link      "www.forex-tsd.com"
//------------------------------------------------------------------
#property indicator_separate_window
#property indicator_buffers 4
#property indicator_color1  LimeGreen
#property indicator_color2  PaleVioletRed
#property indicator_color3  Silver
#property indicator_color4  LimeGreen
#property indicator_style1  STYLE_DOT
#property indicator_style2  STYLE_DOT
#property indicator_width3  2
#property indicator_width4  2

//
//
//
//
//

extern ENUM_TIMEFRAMES    TimeFrame          = PERIOD_CURRENT;
extern int                SZOPeriod          = 14;
extern int                SZOLongPeriod      = 30;
extern ENUM_APPLIED_PRICE SZOPrice           = PRICE_CLOSE;
extern int                PriceFiltering     = 14;
extern ENUM_MA_METHOD     PriceFilteringMode = MODE_SMA;
extern double             SZOPercent         = 95;
extern int                AveragePeriod      = 14;
extern ENUM_MA_METHOD     AverageType        = MODE_EMA;

//
//
//
//
//

double upz[];
double dnz[];
double szo[];
double avg[];
double prices[];

string indicatorFileName;
bool   returnBars;

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
   IndicatorBuffers(5);
   SetIndexBuffer(0,upz);
   SetIndexBuffer(1,dnz);
   SetIndexBuffer(2,szo);
   SetIndexBuffer(3,avg);
   SetIndexBuffer(4,prices);

      //
      //
      //
      //
      //
      
         indicatorFileName = WindowExpertName();
         returnBars        = TimeFrame==-99;
         TimeFrame         = MathMax(TimeFrame,_Period);
      
      //
      //
      //
      //
      //
               
      IndicatorShortName(timeFrameToString(TimeFrame)+" Sentiment zone oscillator ("+SZOPeriod+","+SZOLongPeriod+")");
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
           if (returnBars) { upz[0] = MathMin(limit+1,Bars-1); return(0); }

   //
   //
   //
   //
   //

   if (TimeFrame == Period())
   {
      for(int i=limit; i>=0; i--)
      {
         prices[i] = iMA(NULL,0,PriceFiltering,0,PriceFilteringMode,SZOPrice,i);
         double useValue = 0;
            if (prices[i]>prices[i+1]) useValue =  1;
            if (prices[i]<prices[i+1]) useValue = -1;
         double result = 100.0*iTema(useValue,SZOPeriod,i);
      
         //
         //
         //
         //
         //
         
         szo[i] =  result/SZOPeriod;
            double hi = szo[ArrayMaximum(szo,SZOLongPeriod,i)];
            double lo = szo[ArrayMinimum(szo,SZOLongPeriod,i)];
            double rn = hi-lo;
         upz[i] = lo+rn*SZOPercent/100.0;
         dnz[i] = hi-rn*SZOPercent/100.0;
      }       
      for(i=limit; i>=0; i--) avg[i] = iMAOnArray(szo,0,AveragePeriod,0,AverageType,i);
      return(0);
   }
   
   //
   //
   //
   //
   //
   
   limit = MathMax(limit,MathMin(Bars-1,iCustom(NULL,TimeFrame,indicatorFileName,-99,0,0)*TimeFrame/Period()));
   for(i=limit; i>=0; i--)
   {
      int y = iBarShift(NULL,TimeFrame,Time[i]);
         upz[i] = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,SZOPeriod,SZOLongPeriod,SZOPrice,PriceFiltering,PriceFilteringMode,SZOPercent,AveragePeriod,AverageType,0,y);
         dnz[i] = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,SZOPeriod,SZOLongPeriod,SZOPrice,PriceFiltering,PriceFilteringMode,SZOPercent,AveragePeriod,AverageType,1,y);
         szo[i] = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,SZOPeriod,SZOLongPeriod,SZOPrice,PriceFiltering,PriceFilteringMode,SZOPercent,AveragePeriod,AverageType,2,y);
         avg[i] = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,SZOPeriod,SZOLongPeriod,SZOPrice,PriceFiltering,PriceFilteringMode,SZOPercent,AveragePeriod,AverageType,3,y);
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

double workTema[][3];
#define _ema1 0
#define _ema2 1
#define _ema3 2

double iTema(double price, double period, int r, int instanceNo=0)
{
   if (ArrayRange(workTema,0)!= Bars) ArrayResize(workTema,Bars); instanceNo*=3; r = Bars-r-1;

   //
   //
   //
   //
   //
      
   double alpha = 2.0 / (1.0+period);
          workTema[r][_ema1+instanceNo] = workTema[r-1][_ema1+instanceNo]+alpha*(price                        -workTema[r-1][_ema1+instanceNo]);
          workTema[r][_ema2+instanceNo] = workTema[r-1][_ema2+instanceNo]+alpha*(workTema[r][_ema1+instanceNo]-workTema[r-1][_ema2+instanceNo]);
          workTema[r][_ema3+instanceNo] = workTema[r-1][_ema3+instanceNo]+alpha*(workTema[r][_ema2+instanceNo]-workTema[r-1][_ema3+instanceNo]);
   return(workTema[r][_ema3+instanceNo]+3.0*(workTema[r][_ema1+instanceNo]-workTema[r][_ema2+instanceNo]));
}

//-------------------------------------------------------------------
//
//-------------------------------------------------------------------
//
//
//
//
//

string sTfTable[] = {"M1","M5","M15","M30","H1","H4","D1","W1","MN"};
int    iTfTable[] = {1,5,15,30,60,240,1440,10080,43200};

string timeFrameToString(int tf)
{
   for (int i=ArraySize(iTfTable)-1; i>=0; i--) 
         if (tf==iTfTable[i]) return(sTfTable[i]);
                              return("");
}