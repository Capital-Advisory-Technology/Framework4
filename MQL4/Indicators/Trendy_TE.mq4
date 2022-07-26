//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "www,forex-station.com"
#property link      "www,forex-station.com"

#property indicator_chart_window
#property indicator_buffers 7
#property indicator_width3  3
#property indicator_width4  3
#property indicator_width5  3
#property strict

//
//
//
//
//

#define _disBar 1
#define _disLin 2
#define _disZer 4
enum enDisplayType
{
   dis_01=_disLin,                // Display trend envelopes line
   dis_02=_disBar,                // Display trend envelopes bars
   dis_03=_disZer,                // Display trend envelopes "zero" line
   dis_04=_disLin+_disBar,        // Display trend envelopes line and bars
   dis_05=_disLin+_disZer,        // Display trend envelopes line and "zero" line
   dis_06=_disBar+_disZer,        // Display trend envelopes bars and "zero" line
   dis_07=_disLin+_disBar+_disZer // Display all
};
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



extern ENUM_TIMEFRAMES TimeFrame       = PERIOD_D1;  // Time frame
extern int             MaPeriod        = 300;               // Ma period
extern int             MaFilterPass    = 1;               // M filter pass
extern int             MaShift         = 0;               // Shift
extern double          Deviation       = 0.2;             // Envelopes deviation
extern enPrices        Price           = pr_habmedianb;        // Price
extern bool            alertsOn        = false;           // Turn alerts on?
extern bool            alertsOnCurrent = false;           // Alerts on still opened bar?
extern bool            alertsMessage   = false;            // Alerts should display message?
extern bool            alertsSound     = false;           // Alerts should play a sound?
extern bool            alertsNotify    = false;           // Alerts should send a notification?
extern bool            alertsEmail     = false;           // Alerts should send an email?
extern string          soundFile       = "alert2.wav";    // Sound file
extern enDisplayType   DisplayWhat     = _disLin; // Display type
extern color           ColorUp         = clrDarkGreen;    // Color for up
extern color           ColorDn         = clrBrown;    // Color for down
extern color           ColorNe         = clrDarkGray;     // Color for neutral and "zero" line
extern bool            Interpolate     = true;            // Interpolate in multi time frame mode?

double upb[],dnb[],upa[],dna[],histou[],histod[],zero[],smax[],smin[],trend[],count[];
string indicatorFileName;
#define _mtfCall(_buff,_y) iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,MaPeriod,MaFilterPass,0,Deviation,Price,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsNotify,alertsEmail,soundFile,_buff,_y)

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
      int czer = ((DisplayWhat&_disZer)==0) ? clrNONE : ColorNe;
      int chup = ((DisplayWhat&_disBar)==0) ? clrNONE : ColorUp;
      int chdn = ((DisplayWhat&_disBar)==0) ? clrNONE : ColorDn;
      int clup = ((DisplayWhat&_disLin)==0) ? clrNONE : ColorUp;
      int cldn = ((DisplayWhat&_disLin)==0) ? clrNONE : ColorDn;
      int arst = ((DisplayWhat&_disLin)==0) ? DRAW_LINE : DRAW_ARROW;
      IndicatorBuffers(11);
      SetIndexBuffer(0, histou);   SetIndexStyle(0,DRAW_HISTOGRAM,EMPTY,EMPTY,chup);
      SetIndexBuffer(1, histod);   SetIndexStyle(1,DRAW_HISTOGRAM,EMPTY,EMPTY,chdn);
      SetIndexBuffer(2, zero);     SetIndexStyle(2,EMPTY,STYLE_DOT,0,czer);
      SetIndexBuffer(3, upb);      SetIndexStyle(3,EMPTY,EMPTY,EMPTY,clup);
      SetIndexBuffer(4, dnb);      SetIndexStyle(4,EMPTY,EMPTY,EMPTY,cldn);
      SetIndexBuffer(5, upa);      SetIndexStyle(5,arst,EMPTY,EMPTY,clup); SetIndexArrow(5,108);
      SetIndexBuffer(6, dna);      SetIndexStyle(6,arst,EMPTY,EMPTY,cldn); SetIndexArrow(6,108);
      SetIndexBuffer(7, smax);
      SetIndexBuffer(8, smin);
      SetIndexBuffer(9, trend);
      SetIndexBuffer(10,count);
   
      //
      //
      // 
      //
      //
   
         MaFilterPass      = fmax(MathMin(MaFilterPass,48),1);
         MaPeriod          = fmax(MaPeriod,2);
         Deviation         = fmax(fmin(Deviation,100),0.0);
         indicatorFileName = WindowExpertName();
         TimeFrame         = fmax(TimeFrame,_Period);  
         
         for (int i=0;i<4;i++) SetIndexShift(i,MaShift*TimeFrame/_Period);
   IndicatorShortName(timeFrameToString(TimeFrame)+" trend envelopes("+(string)MaPeriod+")");
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
   int i,counted_bars=IndicatorCounted();
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
         int limit = fmin(Bars-counted_bars,Bars-1); count[0]=limit;
            if (TimeFrame!=_Period)
            {
               limit = (int)fmax(limit,fmin(Bars-1,_mtfCall(10,0)*TimeFrame/_Period));
               for (i=limit;i>=0 && !_StopFlag; i--)
               {
                  int y = iBarShift(NULL,TimeFrame,Time[i]);
                     zero[i]  = _mtfCall(2,y);
                     smax[i]  = _mtfCall(7,y);
                     smin[i]  = _mtfCall(8,y);
                     trend[i] = _mtfCall(9,y);
                  
                     //
                     //
                     //
                     //
                     //
                  
                     if (!Interpolate || (i>0 && y==iBarShift(NULL,TimeFrame,Time[i-1]))) continue;
                        #define _interpolate(buff) buff[i+k] = buff[i]+(buff[i+n]-buff[i])*k/n
                        int n,k; datetime time = iTime(NULL,TimeFrame,y);
                           for(n = 1; (i+n)<Bars && Time[i+n] >= time; n++) continue;	
                           for(k = 1; k<n && (i+n)<Bars && (i+k)<Bars; k++) 
                           {
                              _interpolate(zero);
                              _interpolate(smax);
                              _interpolate(smin);
                           }                           
              }
              for (i=limit; i >= 0; i--)
              {
                  upb[i] = EMPTY_VALUE; dnb[i] = EMPTY_VALUE;
                  if (trend[i] ==  1) { upb[i] = smin[i]; histou[i] = High[i]; histod[i] = Low[i]; }
                  if (trend[i] == -1) { dnb[i] = smax[i]; histod[i] = High[i]; histou[i] = Low[i]; }
                  upa[i] = (i<Bars-1) ? (trend[i]!=trend[i+1] && trend[i]== 1) ? upb[i] : EMPTY_VALUE :  EMPTY_VALUE;
                  dna[i] = (i<Bars-1) ? (trend[i]!=trend[i+1] && trend[i]==-1) ? dnb[i] : EMPTY_VALUE :  EMPTY_VALUE;
	           }  
      return(0);
      }
      
      //
      //
      //
      //
      //

      for(i=limit; i>=0; i--)
      { 
         double price = getPrice(Price,Open,Close,High,Low,i);
         zero[i]  = iMultiPassMa(price,MaPeriod,MaFilterPass,i);
         smax[i]  = (1+Deviation/100)*zero[i];
         smin[i]  = (1-Deviation/100)*zero[i];
         trend[i] = (i<Bars-1) ? (price>smax[i+1]) ? 1 : (price<smin[i+1]) ? -1 : trend[i+1] : 0;
                 if (i<Bars-1)
                 {
                    if (trend[i]==-1 && smax[i]>smax[i+1]) smax[i] = smax[i+1];
                    if (trend[i]== 1 && smin[i]<smin[i+1]) smin[i] = smin[i+1];
                 }                  
         upb[i] = EMPTY_VALUE; dnb[i] = EMPTY_VALUE;
         if (trend[i] ==  1) { upb[i] = smin[i]; histou[i] = High[i]; histod[i] = Low[i]; }
         if (trend[i] == -1) { dnb[i] = smax[i]; histod[i] = High[i]; histou[i] = Low[i]; }
         upa[i] = (i<Bars-1) ? (trend[i]!=trend[i+1] && trend[i]== 1) ? upb[i] : EMPTY_VALUE :  EMPTY_VALUE;
         dna[i] = (i<Bars-1) ? (trend[i]!=trend[i+1] && trend[i]==-1) ? dnb[i] : EMPTY_VALUE :  EMPTY_VALUE;
      }
      if (alertsOn)
      {
         int whichBar = 1; if (alertsOnCurrent) whichBar = 0; 
         if (trend[whichBar] != trend[whichBar+1])
         {
            if (trend[whichBar] == 1) doAlert(" up");
            if (trend[whichBar] ==-1) doAlert(" down");       
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

double workMpFilter[][50][1];
double iMultiPassMa(double price, int period, int filterPass, int i, int instanceNo=0)
{ 
   if (ArrayRange(workMpFilter,0) != Bars) ArrayResize(workMpFilter,Bars); i = Bars-i-1; 

   double ma = 0;
   for (int p=0; p<filterPass; p++)
   {
      if (p==0) workMpFilter[i][0][instanceNo] = price;
      int k = 0;
      if (i>=period)
               ma = workMpFilter[i-1][p+1][instanceNo]+(workMpFilter[i][p][instanceNo]-workMpFilter[i-period][p][instanceNo])/period;
      else {   ma = workMpFilter[i][p][instanceNo]; for (k=1; k<period && (i-k)>=0; k++) ma += workMpFilter[i-k][p][instanceNo];
                                                                                         ma /= k; }
      workMpFilter[i][p+1][instanceNo] = ma;
   }               
   return(ma);
} 

 //------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//
//

#define priceInstances     1
#define priceInstancesSize 4
double workHa[][priceInstances*priceInstancesSize];
double getPrice(int tprice, const double& open[], const double& close[], const double& high[], const double& low[], int i, int instanceNo=0)
{
  if (tprice>=pr_haclose)
   {
      if (ArrayRange(workHa,0)!= Bars) ArrayResize(workHa,Bars); instanceNo*=priceInstancesSize; int r = Bars-i-1;
         
         //
         //
         //
         //
         //
         
         double haOpen  = (r>0) ? (workHa[r-1][instanceNo+2] + workHa[r-1][instanceNo+3])/2.0 : (open[i]+close[i])/2;;
         double haClose = (open[i]+high[i]+low[i]+close[i]) / 4.0;
         if (tprice>=pr_habclose)
               if (high[i]!=low[i])
                     haClose = (open[i]+close[i])/2.0+(((close[i]-open[i])/(high[i]-low[i]))*fabs((close[i]-open[i])/2.0));
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

//------------------------------------------------------------------
//
//------------------------------------------------------------------
//
//
//
//
//

void doAlert(string doWhat)
{
   static string   previousAlert="nothing";
   static datetime previousTime;
   string message;
   
      if (previousAlert != doWhat || previousTime != Time[0]) {
          previousAlert  = doWhat;
          previousTime   = Time[0];

          //
          //
          //
          //
          //

          message = timeFrameToString(_Period)+" "+_Symbol+" at "+TimeToStr(TimeLocal(),TIME_SECONDS)+" Trend envelopes state changed to "+doWhat;
             if (alertsMessage) Alert(message);
             if (alertsNotify)  SendNotification(message);
             if (alertsEmail)   SendMail(_Symbol+" Trend envelopes ",message);
             if (alertsSound)   PlaySound(soundFile);
      }
}

