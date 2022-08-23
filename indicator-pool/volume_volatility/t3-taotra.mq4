//+------------------------------------------------------------------+ 
//|                                                    T3.Taotra.mq4 | 
//+------------------------------------------------------------------+ 
#property copyright ""
#property link      "" 

#property indicator_separate_window
#property indicator_buffers 6
#property indicator_color1 Yellow
#property indicator_color2 Red
#property indicator_color3 Magenta
#property indicator_color4 Aqua
#property indicator_color5 LimeGreen
#property indicator_color6 Blue

//
//
//
//
//

extern string TimeFrame   = "Current time frame";
extern int    T3Period_1  = 3;
extern int    T3Period_2  = 5;
extern int    T3Period_3  = 8;
extern int    T3Period_4  = 12;
extern int    T3Period_5  = 21;
extern int    T3Period_6  = 34;
extern double T3Hot       = 1;
extern int    T3Price     = PRICE_CLOSE; 
extern bool   T3Original  = false;
extern bool   Interpolate = true;

//
//
//
//
//

double Ind_Buffer1[];
double Ind_Buffer2[];
double Ind_Buffer3[];
double Ind_Buffer4[];
double Ind_Buffer5[];
double Ind_Buffer6[];

//
//
//
//
//

int    timeFrame;
string indicatorFileName;
bool   returnBars;
bool   calculateValue;
double c1;
double c2;
double c3;
double c4;

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
   SetIndexBuffer(0, Ind_Buffer1);
   SetIndexBuffer(1, Ind_Buffer2);
   SetIndexBuffer(2, Ind_Buffer3);
   SetIndexBuffer(3, Ind_Buffer4);
   SetIndexBuffer(4, Ind_Buffer5);
   SetIndexBuffer(5, Ind_Buffer6);

      T3Hot = MathMax(MathMin(T3Hot,1),0.0001);
      double a  = T3Hot;
             c1 = -a*a*a;
             c2 =  3*(a*a+a*a*a);
             c3 = -3*(2*a*a+a+a*a*a);
             c4 = 1+3*a+a*a*a+3*a*a;

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
      
   IndicatorShortName(timeFrameToString(timeFrame)+" T3 Taotra ("+T3Period_1+","+T3Period_2+","+T3Period_3+","+T3Period_4+","+T3Period_5+","+T3Period_6+")");
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
   int i,limit;

   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
         limit = MathMin(Bars-counted_bars,Bars-1);
         if (returnBars) { Ind_Buffer1[0] = limit+1; return(0); }

   //
   //
   //
   //
   //

   if (calculateValue || timeFrame==Period())
   {
      for(i=limit; i>=0; i--)
      {
         double price = iMA(NULL,0,1,0,MODE_SMA,T3Price,i);
         Ind_Buffer1[i]  = iT3(price,T3Period_1,i, 0);
         Ind_Buffer2[i]  = iT3(price,T3Period_2,i, 6);
         Ind_Buffer3[i]  = iT3(price,T3Period_3,i,12);
         Ind_Buffer4[i]  = iT3(price,T3Period_4,i,18);
         Ind_Buffer5[i]  = iT3(price,T3Period_5,i,24);
         Ind_Buffer6[i]  = iT3(price,T3Period_6,i,30);
      }
      return(0);
   }

   
   //
   //
   //
   //
   //
   
   limit = MathMax(limit,MathMin(Bars-1,iCustom(NULL,timeFrame,indicatorFileName,"returnBars",0,0)*timeFrame/Period()));
   for(i=limit; i>=0; i--)
   {
      int y = iBarShift(NULL,timeFrame,Time[i]);
         Ind_Buffer1[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",T3Period_1,T3Period_2,T3Period_3,T3Period_4,T3Period_5,T3Period_6,T3Hot,T3Price,T3Original,0,y);
         Ind_Buffer2[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",T3Period_1,T3Period_2,T3Period_3,T3Period_4,T3Period_5,T3Period_6,T3Hot,T3Price,T3Original,1,y);
         Ind_Buffer3[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",T3Period_1,T3Period_2,T3Period_3,T3Period_4,T3Period_5,T3Period_6,T3Hot,T3Price,T3Original,2,y);
         Ind_Buffer4[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",T3Period_1,T3Period_2,T3Period_3,T3Period_4,T3Period_5,T3Period_6,T3Hot,T3Price,T3Original,3,y);
         Ind_Buffer5[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",T3Period_1,T3Period_2,T3Period_3,T3Period_4,T3Period_5,T3Period_6,T3Hot,T3Price,T3Original,4,y);
         Ind_Buffer6[i] = iCustom(NULL,timeFrame,indicatorFileName,"calculateValue",T3Period_1,T3Period_2,T3Period_3,T3Period_4,T3Period_5,T3Period_6,T3Hot,T3Price,T3Original,5,y);

         //
         //
         //
         //
         //
      
         if (timeFrame <= Period() || y==iBarShift(NULL,timeFrame,Time[i-1])) continue;
         if (!Interpolate) continue;

         //
         //
         //
         //
         //

         datetime time = iTime(NULL,timeFrame,y);
            for(int n = 1; i+n < Bars && Time[i+n] >= time; n++) continue;	
            double factor = 1.0 / n;
            for(int k = 1; k < n; k++)
            {
               Ind_Buffer1[i+k] = k*factor*Ind_Buffer1[i+n] + (1.0-k*factor)*Ind_Buffer1[i];
               Ind_Buffer2[i+k] = k*factor*Ind_Buffer2[i+n] + (1.0-k*factor)*Ind_Buffer2[i];
               Ind_Buffer3[i+k] = k*factor*Ind_Buffer3[i+n] + (1.0-k*factor)*Ind_Buffer3[i];
               Ind_Buffer4[i+k] = k*factor*Ind_Buffer4[i+n] + (1.0-k*factor)*Ind_Buffer4[i];
               Ind_Buffer5[i+k] = k*factor*Ind_Buffer5[i+n] + (1.0-k*factor)*Ind_Buffer5[i];
               Ind_Buffer6[i+k] = k*factor*Ind_Buffer6[i+n] + (1.0-k*factor)*Ind_Buffer6[i];
            }               
   }

   //
   //
   //
   //
   //
   
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

double t3Values[][36];
double iT3(double price,int period, int i,int s)
{
   if (ArrayRange(t3Values,0) != Bars) ArrayResize(t3Values,Bars);

   int    r = Bars-i-1;
   double alpha = 2.0/(2.0 + (period-1.0)/2.0);
            if (T3Original) alpha = 2.0/(1.0 + period);

   if (r < 2)
      {
         t3Values[r][s+0] = price;
         t3Values[r][s+1] = price;
         t3Values[r][s+2] = price;
         t3Values[r][s+3] = price;
         t3Values[r][s+4] = price;
         t3Values[r][s+5] = price;
      }
   else
      {
         t3Values[r][s+0] = t3Values[r-1][s+0]+alpha*(price           -t3Values[r-1][s+0]);
         t3Values[r][s+1] = t3Values[r-1][s+1]+alpha*(t3Values[r][s+0]-t3Values[r-1][s+1]);
         t3Values[r][s+2] = t3Values[r-1][s+2]+alpha*(t3Values[r][s+1]-t3Values[r-1][s+2]);
         t3Values[r][s+3] = t3Values[r-1][s+3]+alpha*(t3Values[r][s+2]-t3Values[r-1][s+3]);
         t3Values[r][s+4] = t3Values[r-1][s+4]+alpha*(t3Values[r][s+3]-t3Values[r-1][s+4]);
         t3Values[r][s+5] = t3Values[r-1][s+5]+alpha*(t3Values[r][s+4]-t3Values[r-1][s+5]);
      }
   return(c1*t3Values[r][s+5] + c2*t3Values[r][s+4] + c3*t3Values[r][s+3] + c4*t3Values[r][s+2]);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
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
   tfs = StringUpperCase(tfs);
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

string StringUpperCase(string str)
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