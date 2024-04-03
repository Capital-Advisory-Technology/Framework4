//+------------------------------------------------------------------+
//|                                        Trend Intensity Index.mq4 |
//|                                                           mladen |
//|                                                                  |
//| Trend Intensity Index originaly developed by M.H. Pee            |
//| TASC : 20:06 (Jun 2002) article                                  |
//| "Strong Trends = Strong Profits. Trend Intensity Index"          |
//+------------------------------------------------------------------+
#property copyright "mladen"
#property link      "mladenfx@gmail.com"

#property indicator_separate_window
#property indicator_buffers    6
#property indicator_color1     clrDarkGray
#property indicator_color2     clrDarkGray
#property indicator_color3     clrDeepSkyBlue
#property indicator_color4     clrDeepSkyBlue
#property indicator_color5     clrSandyBrown
#property indicator_color6     clrSandyBrown
#property indicator_style1     STYLE_DOT
#property indicator_width2     2
#property indicator_width3     2
#property indicator_width4     2
#property indicator_width5     2
#property indicator_width6     2
#property indicator_minimum  -1
#property indicator_maximum 101
#property strict


//
//
//
//
//

enum enPrices
{
   pr_close,      // Close
   pr_open,       // Open
   pr_high,       // High
   pr_low,        // Low
   pr_median,     // Median
   pr_typical,    // Typical
   pr_weighted,   // Weighted
   pr_average,    // Average (high+low+open+close)/4
   pr_medianb,    // Average median body (open+close)/2
   pr_tbiased,    // Trend biased price
   pr_tbiased2,   // Trend biased (extreme) price
   pr_haclose,    // Heiken ashi close
   pr_haopen ,    // Heiken ashi open
   pr_hahigh,     // Heiken ashi high
   pr_halow,      // Heiken ashi low
   pr_hamedian,   // Heiken ashi median
   pr_hatypical,  // Heiken ashi typical
   pr_haweighted, // Heiken ashi weighted
   pr_haaverage,  // Heiken ashi average
   pr_hamedianb,  // Heiken ashi median body
   pr_hatbiased,  // Heiken ashi trend biased price
   pr_hatbiased2, // Heiken ashi trend biased (extreme) price
   pr_habclose,   // Heiken ashi (better formula) close
   pr_habopen ,   // Heiken ashi (better formula) open
   pr_habhigh,    // Heiken ashi (better formula) high
   pr_hablow,     // Heiken ashi (better formula) low
   pr_habmedian,  // Heiken ashi (better formula) median
   pr_habtypical, // Heiken ashi (better formula) typical
   pr_habweighted,// Heiken ashi (better formula) weighted
   pr_habaverage, // Heiken ashi (better formula) average
   pr_habmedianb, // Heiken ashi (better formula) median body
   pr_habtbiased, // Heiken ashi (better formula) trend biased price
   pr_habtbiased2 // Heiken ashi (better formula) trend biased (extreme) price
};

extern int                Length    = 10;            // Calculation length
extern enPrices           Price     = pr_habmedianb;      // Price to use
extern ENUM_MA_METHOD     MaMethod  = MODE_LWMA;      // Average method to use
extern double             LevelHigh = 80;            // High level
extern double             LevelLow  = 20;            // Low level

//
//
//
//
//

double Tii[],Tiiua[],Tiiub[],Tiida[],Tiidb[];
double TiiPosition[];
double prices[],state[];

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

int init()
{
   IndicatorBuffers(8);
   SetIndexBuffer(0,TiiPosition);
   SetIndexBuffer(1,Tii);
   SetIndexBuffer(2,Tiiua);
   SetIndexBuffer(3,Tiiub);
   SetIndexBuffer(4,Tiida);
   SetIndexBuffer(5,Tiidb);
   SetIndexBuffer(6,prices);
   SetIndexBuffer(7,state);
   
      //
      //
      //
      //
      //
      
      LevelHigh = MathMin(MathMax(LevelHigh,0),100);
      LevelLow  = MathMin(MathMax(LevelLow,0) ,100);
      if (LevelHigh<LevelLow)
         {
            double temp = LevelHigh;
                   LevelHigh = LevelLow;
                   LevelLow  = temp;
         }
         
      //
      //
      //
      //
      //
               
   SetLevelValue(0,LevelHigh);
   SetLevelValue(1,LevelLow);
   return(0);
}
int deinit()
{
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

int start()
{
   int counted_bars=IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
         int limit = MathMin(Bars-counted_bars,Bars-1);

   //
   //
   //
   //
   //

   if (state[limit]== 1) CleanPoint(limit,Tiiua,Tiiub);
   if (state[limit]==-1) CleanPoint(limit,Tiida,Tiidb);
   for(int i=limit; i>=0; i--) prices[i] = getPrice(Price,Open,Close,High,Low,i);
   for(int i=limit; i>=0; i--)
   {
      double ma = iMAOnArray(prices,0,Length*2,0,MaMethod,i);

      //
      //
      //
      //
      //

         double sumUpDeviations = 0;
         double sumDnDeviations = 0;
               for(int j=0; j<Length && (i+j)<Bars; j++)
               {
                  double diff = prices[i+j]-ma;
                  if (diff>0)
                        sumUpDeviations += diff;
                  else  sumDnDeviations -= diff;
               }               
            
      //
      //
      //
      //
      //

      Tii[i]   = ((sumUpDeviations+sumDnDeviations)!=0) ? 100*sumUpDeviations/(sumUpDeviations+sumDnDeviations) : 0;
      Tiida[i] = EMPTY_VALUE;
      Tiidb[i] = EMPTY_VALUE;
      Tiiua[i] = EMPTY_VALUE;
      Tiiub[i] = EMPTY_VALUE;
      state[i] = 0;
      TiiPosition[i] = 50;
         if (Tii[i]>LevelHigh) { TiiPosition[i] = 101; state[i] =  1; }
         if (Tii[i]<LevelLow)  { TiiPosition[i] =  -1; state[i] = -1; }
         if (state[i] ==  1) PlotPoint(i,Tiiua,Tiiub,Tii);
         if (state[i] == -1) PlotPoint(i,Tiida,Tiidb,Tii);
   }
   return(0);
}

//-------------------------------------------------------------------
//                                                                  
//-------------------------------------------------------------------
//
//
//
//
//

void CleanPoint(int i,double& first[],double& second[])
{
   if (i>=Bars-3) return;
   if ((second[i]  != EMPTY_VALUE) && (second[i+1] != EMPTY_VALUE))
        second[i+1] = EMPTY_VALUE;
   else
      if ((first[i] != EMPTY_VALUE) && (first[i+1] != EMPTY_VALUE) && (first[i+2] == EMPTY_VALUE))
          first[i+1] = EMPTY_VALUE;
}

void PlotPoint(int i,double& first[],double& second[],double& from[])
{
   if (i>=Bars-2) return;
   if (first[i+1] == EMPTY_VALUE)
      if (first[i+2] == EMPTY_VALUE) 
            { first[i]  = from[i];  first[i+1]  = from[i+1]; second[i] = EMPTY_VALUE; }
      else  { second[i] =  from[i]; second[i+1] = from[i+1]; first[i]  = EMPTY_VALUE; }
   else     { first[i]  = from[i];                           second[i] = EMPTY_VALUE; }
}

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

#define _prHABF(_prtype) (_prtype>=pr_habclose && _prtype<=pr_habtbiased2)
#define _priceInstances     1
#define _priceInstancesSize 4
double workHa[][_priceInstances*_priceInstancesSize];
double getPrice(int tprice, const double& open[], const double& close[], const double& high[], const double& low[], int i, int instanceNo=0)
{
  if (tprice>=pr_haclose)
   {
      if (ArrayRange(workHa,0)!= Bars) ArrayResize(workHa,Bars); instanceNo*=_priceInstancesSize; int r = Bars-i-1;
         
         //
         //
         //
         //
         //
         
         double haOpen  = (r>0) ? (workHa[r-1][instanceNo+2] + workHa[r-1][instanceNo+3])/2.0 : (open[i]+close[i])/2;;
         double haClose = (open[i]+high[i]+low[i]+close[i]) / 4.0;
         if (_prHABF(tprice))
               if (high[i]!=low[i])
                     haClose = (open[i]+close[i])/2.0+(((close[i]-open[i])/(high[i]-low[i]))*MathAbs((close[i]-open[i])/2.0));
               else  haClose = (open[i]+close[i])/2.0; 
         double haHigh  = fmax(high[i], fmax(haOpen,haClose));
         double haLow   = fmin(low[i] , fmin(haOpen,haClose));

         //
         //
         //
         //
         //
         
         if(haOpen<haClose) { workHa[r][instanceNo+0] = haLow;  workHa[r][instanceNo+1] = haHigh; } 
         else               { workHa[r][instanceNo+0] = haHigh; workHa[r][instanceNo+1] = haLow;  } 
                              workHa[r][instanceNo+2] = haOpen;
                              workHa[r][instanceNo+3] = haClose;
         //
         //
         //
         //
         //
         
         switch (tprice)
         {
            case pr_haclose:
            case pr_habclose:    return(haClose);
            case pr_haopen:   
            case pr_habopen:     return(haOpen);
            case pr_hahigh: 
            case pr_habhigh:     return(haHigh);
            case pr_halow:    
            case pr_hablow:      return(haLow);
            case pr_hamedian:
            case pr_habmedian:   return((haHigh+haLow)/2.0);
            case pr_hamedianb:
            case pr_habmedianb:  return((haOpen+haClose)/2.0);
            case pr_hatypical:
            case pr_habtypical:  return((haHigh+haLow+haClose)/3.0);
            case pr_haweighted:
            case pr_habweighted: return((haHigh+haLow+haClose+haClose)/4.0);
            case pr_haaverage:  
            case pr_habaverage:  return((haHigh+haLow+haClose+haOpen)/4.0);
            case pr_hatbiased:
            case pr_habtbiased:
               if (haClose>haOpen)
                     return((haHigh+haClose)/2.0);
               else  return((haLow+haClose)/2.0);        
            case pr_hatbiased2:
            case pr_habtbiased2:
               if (haClose>haOpen)  return(haHigh);
               if (haClose<haOpen)  return(haLow);
                                    return(haClose);        
         }
   }
   
   //
   //
   //
   //
   //
   
   switch (tprice)
   {
      case pr_close:     return(close[i]);
      case pr_open:      return(open[i]);
      case pr_high:      return(high[i]);
      case pr_low:       return(low[i]);
      case pr_median:    return((high[i]+low[i])/2.0);
      case pr_medianb:   return((open[i]+close[i])/2.0);
      case pr_typical:   return((high[i]+low[i]+close[i])/3.0);
      case pr_weighted:  return((high[i]+low[i]+close[i]+close[i])/4.0);
      case pr_average:   return((high[i]+low[i]+close[i]+open[i])/4.0);
      case pr_tbiased:   
               if (close[i]>open[i])
                     return((high[i]+close[i])/2.0);
               else  return((low[i]+close[i])/2.0);        
      case pr_tbiased2:   
               if (close[i]>open[i]) return(high[i]);
               if (close[i]<open[i]) return(low[i]);
                                     return(close[i]);        
   }
   return(0);
}