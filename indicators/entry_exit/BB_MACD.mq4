//+------------------------------------------------------------------+
//|                                                  BB Macd nrp.mq4 |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""

#property indicator_separate_window
#property indicator_buffers 5
#property indicator_color1  DimGray
#property indicator_color2  DimGray
#property indicator_color3  DeepSkyBlue
#property indicator_color4  PaleVioletRed
#property indicator_color5  PaleVioletRed
#property indicator_width3  2
#property indicator_width4  2
#property indicator_width5  2

//
//
//
//
//

extern string TimeFrame        = "Current time frame";
extern int    FastLen          = 12;
extern int    SlowLen          = 26;
extern int    Length           = 10;
extern double StDv             = 1.0;
extern bool   drawDots         = False;
extern bool   arrowsVisible    = false;
extern string arrowsIdentifier = "bb macd arrows";
extern color  arrowsUpColor    = DeepSkyBlue;
extern color  arrowsDnColor    = Red;
extern bool   alertsOn         = false;
extern bool   alertsOnCurrent  = true;
extern bool   alertsMessage    = true;
extern bool   alertsSound      = false;
extern bool   alertsEmail      = false;
extern bool   Interpolate      = true;

//
//
//
//
//

double buffer1[];
double buffer2[];
double bbMacd[];
double buffer4[];
double buffer5[];
double buffer6[];
double trendSlope[];
double trendValue[];

//
//
//
//
//

int    timeFrame;
string indicatorFileName;
bool   returnBars;
bool   calculateValue;


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int init()
{
   IndicatorBuffers(8);
   SetIndexBuffer(0, buffer1);
   SetIndexBuffer(1, buffer2);
   SetIndexBuffer(2, bbMacd);
   SetIndexBuffer(3, buffer4);
   SetIndexBuffer(4, buffer5);
   SetIndexBuffer(5, buffer6);
   SetIndexBuffer(6, trendSlope);
   SetIndexBuffer(7, trendValue);
      if (drawDots) {
            SetIndexStyle(2, DRAW_ARROW); SetIndexArrow(2, 159);
            SetIndexStyle(3, DRAW_ARROW); SetIndexArrow(3, 159);
            SetIndexStyle(4, DRAW_NONE);
         }
      else
         {
            SetIndexStyle(2, DRAW_LINE);
            SetIndexStyle(3, DRAW_LINE);
            SetIndexStyle(4, DRAW_LINE);
         }

      //
      //
      //
      //
      //
      
         indicatorFileName = WindowExpertName();
         calculateValue    = (TimeFrame=="calculateValue"); if (calculateValue) return(0);
         returnBars        = (TimeFrame=="returnBars");     if (returnBars)     return(0);
         timeFrame         = stringToTimeFrame(TimeFrame);
      
      //
      //
      //
      //
      //
         
   IndicatorDigits(5);
   IndicatorShortName(timeFrameToString(timeFrame)+" BB Macd (" + FastLen + "," + SlowLen + "," + Length+")");
      SetIndexLabel(0, "Upperband");
      SetIndexLabel(1, "Lowerband");  
      SetIndexLabel(2, "BB Macd");
      SetIndexLabel(3, NULL);
      SetIndexLabel(4, NULL);
   return(0);
}

int deinit()
{
   string lookFor       = arrowsIdentifier+":";
   int    lookForLength = StringLen(lookFor);
   for (int i=ObjectsTotal()-1; i>=0; i--)
   {
      string objectName = ObjectName(i);
         if (StringSubstr(objectName,0,lookForLength) == lookFor) ObjectDelete(objectName);
   }
   return(0);
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+

int start()
{
   int limit,i,counted_bars = IndicatorCounted();

   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
       limit = MathMin(Bars - counted_bars,Bars-1);
       if (returnBars) { buffer1[0] = limit+1; return(0); }


   //
   //
   //
   //
   //

   if (calculateValue || timeFrame == Period())
   {
      if (!drawDots) if (trendSlope[limit]==-1) CleanPoint(limit,buffer4,buffer5);
      double alpha = 2.0 / (Length + 1.0);
      for(i = limit; i >= 0 ; i--)
      {
         bbMacd[i]  = iMA(NULL,0,FastLen,0,MODE_EMA,PRICE_CLOSE,i) - iMA(NULL,0,SlowLen,0,MODE_EMA,PRICE_CLOSE,i);
         buffer6[i] = buffer6[i+1] + alpha*(bbMacd[i]-buffer6[i+1]);
               double sDev = iDeviation(bbMacd, buffer6[i], Length, i);
         buffer1[i] = buffer6[i] + (StDv * sDev);
         buffer2[i] = buffer6[i] - (StDv * sDev);
         buffer4[i] = EMPTY_VALUE;
         buffer5[i] = EMPTY_VALUE;
               
         //
         //
         //
         //
         //
               
         trendSlope[i] = trendSlope[i+1];
            if (bbMacd[i]>bbMacd[i+1]) trendSlope[i] =  1;
            if (bbMacd[i]<bbMacd[i+1]) trendSlope[i] = -1;
            if (trendSlope[i]==-1)
               if (drawDots)     buffer4[i] = bbMacd[i];
               else  PlotPoint(i,buffer4,buffer5,bbMacd);
         trendValue[i] = trendValue[i+1];
            if (bbMacd[i]>buffer1[i])                         trendValue[i] =  1;
            if (bbMacd[i]<buffer2[i])                         trendValue[i] = -1;
            if (bbMacd[i]<buffer1[i] && bbMacd[i]>buffer2[i]) trendValue[i] =  0;
         manageArrow(i);
      }
      manageAlerts();
      return(0);
   }      

   //
   //
   //
   //
   //

   limit = MathMax(limit,MathMin(Bars-1,iCustom(NULL,timeFrame,indicatorFileName,"returnBars",0,0)*timeFrame/Period()));
   if (!drawDots) if (trendSlope[limit]==-1) CleanPoint(limit,buffer4,buffer5);
   for(i=limit; i>=0; i--)
   {
      int y = iBarShift(NULL,timeFrame,Time[i]);
         buffer1[i]    = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",FastLen,SlowLen,Length,StDv,0,y);
         buffer2[i]    = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",FastLen,SlowLen,Length,StDv,1,y);
         bbMacd[i]     = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",FastLen,SlowLen,Length,StDv,2,y);
         trendSlope[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",FastLen,SlowLen,Length,StDv,6,y);
         trendValue[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",FastLen,SlowLen,Length,StDv,7,y);
         buffer4[i]    = EMPTY_VALUE;
         buffer5[i]    = EMPTY_VALUE;
            
               if (drawDots && trendSlope[i]==-1) buffer4[i] = bbMacd[i];
               manageArrow(i);
            
         //
         //
         //
         //
         //
      
         if (!Interpolate || y==iBarShift(NULL,timeFrame,Time[i-1])) continue;

         //
         //
         //
         //
         //

         datetime time = iTime(NULL,timeFrame,y);
            for(int n = 1; i+n < Bars && Time[i+n] >= time; n++) continue;	
            for(int k = 1; k < n; k++)
            {
               bbMacd[i+k]  = bbMacd[i]  + (bbMacd[i+n] -bbMacd[i])*k/n;
               buffer1[i+k] = buffer1[i] + (buffer1[i+n]-buffer1[i])*k/n;
               buffer2[i+k] = buffer2[i] + (buffer2[i+n]-buffer2[i])*k/n;
               if (buffer4[i+k] != EMPTY_VALUE) buffer4[i+k] = bbMacd[i+k];
            }               
   }
   if (!drawDots) for (i=limit;i>=0;i--) if (trendSlope[i]==-1) PlotPoint(i,buffer4,buffer5,bbMacd);
   manageAlerts();   
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

double iDeviation(double& array[],double dMA, int period,int shift)
{
   double dSum = 0.00;
   int    i;

   for(i=0; i<period; i++) dSum += (array[shift+i]-dMA)*(array[shift+i]-dMA);
   
   return(MathSqrt(dSum/period));
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

void manageArrow(int i)
{
   if (arrowsVisible)
   {
         deleteArrow(Time[i]);
         if (trendValue[i]!=trendValue[i+1])
         {
            if (trendValue[i] == 1)                        drawArrow(i,arrowsUpColor,241,false);
            if (trendValue[i] ==-1)                        drawArrow(i,arrowsDnColor,242,true);
            if (trendValue[i] == 0 && trendValue[i+1]== 1) drawArrow(i,arrowsDnColor,242,true);
            if (trendValue[i] == 0 && trendValue[i+1]==-1) drawArrow(i,arrowsUpColor,241,false);
         }
   }
}               

//
//
//
//
//

void drawArrow(int i,color theColor,int theCode,bool up)
{
   string name = arrowsIdentifier+":"+Time[i];
   double gap  = 3.0*iATR(NULL,0,20,i)/4.0;   
   
      //
      //
      //
      //
      //
      
      ObjectCreate(name,OBJ_ARROW,0,Time[i],0);
         ObjectSet(name,OBJPROP_ARROWCODE,theCode);
         ObjectSet(name,OBJPROP_COLOR,theColor);
         if (up)
               ObjectSet(name,OBJPROP_PRICE1,High[i]+gap);
         else  ObjectSet(name,OBJPROP_PRICE1,Low[i] -gap);
}

//
//
//
//
//

void deleteArrow(datetime time)
{
   string lookFor = arrowsIdentifier+":"+time; ObjectDelete(lookFor);
}


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//
//
//
//
//

void manageAlerts()
{
   if (!calculateValue && alertsOn)
   {
      if (alertsOnCurrent)
           int whichBar = 0;
      else     whichBar = 1; whichBar = iBarShift(NULL,0,iTime(NULL,timeFrame,whichBar));
      if (trendValue[whichBar] != trendValue[whichBar+1])
      {
         if (trendValue[whichBar] == 1)                               doAlert(whichBar,"up");
         if (trendValue[whichBar] ==-1)                               doAlert(whichBar,"down");
         if (trendValue[whichBar] == 0 && trendValue[whichBar+1]== 1) doAlert(whichBar,"back from up into zone");
         if (trendValue[whichBar] ==-0 && trendValue[whichBar+1]==-1) doAlert(whichBar,"back from down into zone");
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

          message =  StringConcatenate(Symbol()," ",timeFrameToString(timeFrame)," at ",TimeToStr(TimeLocal(),TIME_SECONDS)," BB macd broke bands ",doWhat);
             if (alertsMessage) Alert(message);
             if (alertsEmail)   SendMail(StringConcatenate(Symbol(),"BB macd "),message);
             if (alertsSound)   PlaySound("alert2.wav");
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

void CleanPoint(int i,double& first[],double& second[])
{
   if ((second[i]  != EMPTY_VALUE) && (second[i+1] != EMPTY_VALUE))
        second[i]   = EMPTY_VALUE;
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
         if (first[i+2] == EMPTY_VALUE) {
                first[i]   = from[i];
                first[i+1] = from[i+1];
                second[i]  = EMPTY_VALUE;
            }
         else {
                second[i]   =  from[i];
                second[i+1] =  from[i+1];
                first[i]    = EMPTY_VALUE;
            }
      }
   else
      {
         first[i]   = from[i];
         second[i]  = EMPTY_VALUE;
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

//
//
//
//
//

int stringToTimeFrame(string tfs)
{
   tfs = stringUpperCase(tfs);
   for (int i=ArraySize(iTfTable)-1; i>=0; i--)
         if (tfs==sTfTable[i] || tfs==""+iTfTable[i]) return(MathMax(iTfTable[i],Period()));
                                                      return(Period());
}
string timeFrameToString(int tf)
{
   for (int i=ArraySize(iTfTable)-1; i>=0; i--) 
         if (tf==iTfTable[i]) return(sTfTable[i]);
                              return("");
}

//
//
//
//
//

string stringUpperCase(string str)
{
   string   s = str;

   for (int length=StringLen(str)-1; length>=0; length--)
   {
      int tchar = StringGetChar(s, length);
         if((tchar > 96 && tchar < 123) || (tchar > 223 && tchar < 256))
                     s = StringSetChar(s, length, tchar - 32);
         else if(tchar > -33 && tchar < 0)
                     s = StringSetChar(s, length, tchar + 224);
   }
   return(s);
}