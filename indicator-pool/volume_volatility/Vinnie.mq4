//+------------------------------------------------------------------+
//|                                             VininI_Trend_WPR.mq4 |
//|                                  Ñopyright 2008. Victor Nicolaev |
//|                                                    vinin@mail.ru |
//+------------------------------------------------------------------+
#property copyright "Ñopyright 2008. Victor Nicolaev"
#property link      "vinin@mail.ru"


#property indicator_separate_window
#property indicator_buffers 2
#property indicator_color1 Yellow
#property indicator_color2 Red
#property indicator_level2  0


extern int MA_Trend=3;
extern int WPR_Start=10;
extern int WPR_Step=10;
extern int WPR_Count=50;
extern int Limit=1440;
//---- buffers
double WPR[];
double Signal[];
double tmp[];
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init() 
  {
//---- drawing settings
   SetIndexStyle(0,DRAW_HISTOGRAM);
   SetIndexStyle(1,DRAW_LINE);

   SetIndexBuffer(0,WPR);
   SetIndexBuffer(1,Signal);
//   SetIndexBuffer(2,TrendUP);
//   SetIndexBuffer(3,TrendDN);

   ArrayResize(tmp,WPR_Count);
   return(0); 
  }//int init() 
//+------------------------------------------------------------------+
int start() 
  {
   int limit1,limit2;
   int i,j;
   double sum=0;

   int counted_bars=IndicatorCounted();
   if(counted_bars<0) return(-1);
   if(counted_bars>0) counted_bars--;
   limit1=Bars-counted_bars;
   if(counted_bars==0) limit1-=1+WPR_Count;

   limit2=limit1;
   if(IndicatorCounted()==0) limit2=limit1-MA_Trend;

   for(i=limit1;i>=0;i--)
     {
      sum=0;
      for(j=0;j<WPR_Count;j++) 
        {
         tmp[j]=(iWPR(NULL,0,WPR_Start+j*WPR_Step,i)+50.0)*2.0;
         sum=tmp[j];
        }
      WPR[i]=sum/WPR_Count;
      sum=0;
      for(j=0;j<WPR_Count;j++) 
        {
         sum+=MathPow(WPR[i]-tmp[j],2);
        }
      sum=MathSqrt(sum/WPR_Count);
     }

   for(i=limit2;i>=0;i--) Signal[i]=iMAOnArray(WPR,0,MA_Trend,0,MODE_SMA,i);

   return(0);
  }
//+------------------------------------------------------------------+
