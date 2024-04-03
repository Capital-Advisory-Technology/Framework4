//------------------------------------------------------------------
#property copyright "www.forex-station.com"
#property link      "www.forex-station.com"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1  clrLimeGreen
#property indicator_color2  clrOrange
#property indicator_color3  clrLimeGreen
#property indicator_color4  clrOrange
#property indicator_width3  3
#property indicator_width4  3
#property strict

//
//
//
//
//

extern ENUM_TIMEFRAMES    TimeFrame            = PERIOD_CURRENT;   // Time frame to use
extern double             AccStep              = 0.02;             // Accumulation step
extern double             AccLimit             = 0.2;              // Accumulation limit
extern ENUM_APPLIED_PRICE PriceHigh            = PRICE_CLOSE;      // Psar high price
extern ENUM_APPLIED_PRICE PriceLow             = PRICE_CLOSE;      // Psar low price
extern int                PriceSmoothing       = 0;                // Psar smoothing
extern ENUM_MA_METHOD     PriceSmoothingMethod = MODE_SMA;         // Psar ma smoothing method
extern bool               alertsOn             = true;             // Alerts on?
extern bool               alertsOnCurrent      = false;            // Alerts on current open bar?
extern bool               alertsMessage        = true;             // Alerts message?
extern bool               alertsSound          = false;            // Alerts sound?
extern bool               alertsEmail          = false;            // Alerts email?
extern bool               alertsNotify         = false;            // Alerts notification by phone?
extern bool               DrawAsDots           = true;             // Draw as dots or solid line
extern int                Shift                = 0;                // Shift

double sarUp[];
double sarDn[];
double saraUp[];
double saraDn[];
int    timeFrame;
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
   int type = DRAW_LINE; if (DrawAsDots) type = DRAW_ARROW;
      SetIndexBuffer(0,sarUp);  SetIndexStyle(0,type);       SetIndexArrow(0,159);
      SetIndexBuffer(1,sarDn);  SetIndexStyle(1,type);       SetIndexArrow(1,159);
      SetIndexBuffer(2,saraUp); SetIndexStyle(2,DRAW_ARROW); SetIndexArrow(2,159);
      SetIndexBuffer(3,saraDn); SetIndexStyle(3,DRAW_ARROW); SetIndexArrow(3,159);
   
      //
      //
      //
      //
      //
      
         indicatorFileName = WindowExpertName();
         returnBars        = (TimeFrame==-99);
         TimeFrame         = MathMax(TimeFrame,_Period);
         PriceSmoothing    = MathMax(PriceSmoothing,1);
         for (int i=0; i<4; i++) SetIndexShift(i,Shift*timeFrame/Period());
      
      //
      //
      //
      //
      //

   return(0);
}
int deinit() { return(0); }

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
   int i,counted_bars=IndicatorCounted();
      if(counted_bars < 0) return(-1);
      if(counted_bars>0) counted_bars--;
         int limit = MathMin(Bars-counted_bars,Bars-1);
         if (returnBars) { sarUp[0] = limit+1; return(0); }

   //
   //
   //
   //
   //
    
   if (TimeFrame == Period())
   {
      for(i = limit; i >= 0; i--)
      {
         double sarClose;
         double sarOpen;
         double sarPosition;
         double sarChange;
         double pHigh = iMA(NULL,0,PriceSmoothing,0,PriceSmoothingMethod,PriceHigh,i);
         double pLow  = iMA(NULL,0,PriceSmoothing,0,PriceSmoothingMethod,PriceLow ,i);
            iParabolic(fmax(pHigh,pLow),fmin(pHigh,pLow),AccStep,AccLimit,sarClose,sarOpen,sarPosition,sarChange,i);
            sarUp[i]  = EMPTY_VALUE;
            sarDn[i]  = EMPTY_VALUE;
            saraUp[i] = EMPTY_VALUE;
            saraDn[i] = EMPTY_VALUE;
            if (sarPosition==1)
                  sarUp[i] = sarClose;
            else  sarDn[i] = sarClose;
            if (sarChange!=0)
               if (sarChange==1)
                     saraUp[i] = sarClose;
               else  saraDn[i] = sarClose;
      }
      manageAlerts();
      return(0);
   }
   
   //
   //
   //
   //
   //

   limit = (int)fmax(limit,fmin(Bars-1,iCustom(NULL,TimeFrame,indicatorFileName,-99,0,0)*TimeFrame/Period()));
   for(i=limit; i>=0; i--)
   {
      int y = iBarShift(NULL,TimeFrame,Time[i]);
      int x = iBarShift(NULL,TimeFrame,Time[i+1]);
         sarUp[i]  = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,AccStep,AccLimit,PriceHigh,PriceLow,PriceSmoothing,PriceSmoothingMethod,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsEmail,0,0,y);
         sarDn[i]  = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,AccStep,AccLimit,PriceHigh,PriceLow,PriceSmoothing,PriceSmoothingMethod,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsEmail,0,1,y);
         saraUp[i] = EMPTY_VALUE;
         saraDn[i] = EMPTY_VALUE;
         if (x!=y)
         {
            saraUp[i]  = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,AccStep,AccLimit,PriceHigh,PriceLow,PriceSmoothing,PriceSmoothingMethod,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsEmail,0,2,y);
            saraDn[i]  = iCustom(NULL,TimeFrame,indicatorFileName,PERIOD_CURRENT,AccStep,AccLimit,PriceHigh,PriceLow,PriceSmoothing,PriceSmoothingMethod,alertsOn,alertsOnCurrent,alertsMessage,alertsSound,alertsEmail,0,3,y);
         }
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

double work[][7];
#define _high     0
#define _low      1
#define _ohigh    2
#define _olow     3
#define _open     4
#define _position 5
#define _af       6


void iParabolic(double high, double low, double step, double limit, double& pClose, double& pOpen, double& pPosition, double& pChange, int i)
{
   if (ArrayRange(work,0)!=Bars) ArrayResize(work,Bars); i = Bars-i-1;
   
   //
   //
   //
   //
   //
   
      pChange = 0;
         work[i][_ohigh]    = high;
         work[i][_olow]     = low;
            if (i<1)
               {
                  work[i][_high]     = high;
                  work[i][_low]      = low;
                  work[i][_open]     = high;
                  work[i][_position] = -1;
                  return;
               }
         work[i][_open]     = work[i-1][_open];
         work[i][_af]       = work[i-1][_af];
         work[i][_position] = work[i-1][_position];
         work[i][_high]     = fmax(work[i-1][_high],high);
         work[i][_low]      = fmin(work[i-1][_low] ,low );
      
   //
   //
   //
   //
   //
            
   if (work[i][_position] == 1)
      if (low<=work[i][_open])
         {
            work[i][_position] = -1;
               pChange = -1;
               pClose  = work[i][_high];
                         work[i][_high] = high;
                         work[i][_low]  = low;
                         work[i][_af]   = step;
                         work[i][_open] = pClose + work[i][_af]*(work[i][_low]-pClose);
                            if (work[i][_open]<work[i  ][_ohigh]) work[i][_open] = work[i  ][_ohigh];
                            if (work[i][_open]<work[i-1][_ohigh]) work[i][_open] = work[i-1][_ohigh];
         }
      else
         {
               pClose = work[i][_open];
                    if (work[i][_high]>work[i-1][_high] && work[i][_af]<limit) work[i][_af] = fmin(work[i][_af]+step,limit);
                        work[i][_open] = pClose + work[i][_af]*(work[i][_high]-pClose);
                            if (work[i][_open]>work[i  ][_olow]) work[i][_open] = work[i  ][_olow];
                            if (work[i][_open]>work[i-1][_olow]) work[i][_open] = work[i-1][_olow];
         }
   else
      if (high>=work[i][_open])
         {
            work[i][_position] = 1;
               pChange = 1;
               pClose  = work[i][_low];
                         work[i][_low]  = low;
                         work[i][_high] = high;
                         work[i][_af]   = step;
                         work[i][_open] = pClose + work[i][_af]*(work[i][_high]-pClose);
                            if (work[i][_open]>work[i  ][_olow]) work[i][_open] = work[i  ][_olow];
                            if (work[i][_open]>work[i-1][_olow]) work[i][_open] = work[i-1][_olow];
         }
      else
         {
               pClose = work[i][_open];
               if (work[i][_low]<work[i-1][_low] && work[i][_af]<limit) work[i][_af] = fmin(work[i][_af]+step,limit);
                   work[i][_open] = pClose + work[i][_af]*(work[i][_low]-pClose);
                            if (work[i][_open]<work[i  ][_ohigh]) work[i][_open] = work[i  ][_ohigh];
                            if (work[i][_open]<work[i-1][_ohigh]) work[i][_open] = work[i-1][_ohigh];
         }

   //
   //
   //
   //
   //
   
   pOpen     = work[i][_open];
   pPosition = work[i][_position];
}

//-------------------------------------------------------------------
//
//-------------------------------------------------------------------
//
//
//
//
//

void manageAlerts()
{
   if (alertsOn)
   {
      int whichBar = 1; if (alertsOnCurrent) whichBar = 0;
      if (saraUp[whichBar] != EMPTY_VALUE || saraDn[whichBar] != EMPTY_VALUE)
      {
         if (saraUp[whichBar] !=  EMPTY_VALUE) doAlert(whichBar,"up");
         if (saraDn[whichBar] !=  EMPTY_VALUE) doAlert(whichBar,"down");
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

       message =  StringConcatenate(Symbol()," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," ",timeFrameToString(_Period)+" Parabolic sar trend changed to ",doWhat);
          if (alertsMessage) Alert(message);
          if (alertsEmail)   SendMail(StringConcatenate(Symbol(),"parabolic sar"),message);
          if (alertsNotify)  SendNotification(message);
          if (alertsSound)   PlaySound("alert2.wav");
   }
}

//+-------------------------------------------------------------------
//|                                                                  
//+-------------------------------------------------------------------
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