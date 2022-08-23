//+------------------------------------------------------------------+
//|                                                     COGMACD.mq4 |
//| Original Code from NG3110@latchess.com                           |                                    
//| Linuxser 2007 for TSD    http://www.forex-tsd.com/               |
//| Mod by Brooky @           Brooky-Indicators.com                  |
//+------------------------------------------------------------------+
#property  copyright ""
#property link       ""
//---------ang_pr (Din)--------------------
#property indicator_separate_window
#property indicator_buffers 9
//---
#property indicator_color1 clrDarkGray  //Olive
#property indicator_color2 clrSteelBlue  //Olive
#property indicator_color3 clrIndianRed  //Tomato
#property indicator_color4 clrGreenYellow //DarkBlue
//---
#property indicator_color5 clrOrange  //RoyalBlue
#property indicator_color6 clrDeepPink  //Red
#property indicator_color7 clrLimeGreen
#property indicator_color8 clrHotPink  //Orange
#property indicator_color9 clrSpringGreen  //LimeGreen
//---
#property indicator_width1 2
#property indicator_width2 2
#property indicator_width3 2
#property indicator_width4 0
//---
#property indicator_width5 2
#property indicator_width6 0
#property indicator_width7 0
#property indicator_width8 2
#property indicator_width9 2
//---
#property indicator_style1 0
#property indicator_style2 0
#property indicator_style3 0
#property indicator_style4 2
//---
#property indicator_style5 0
#property indicator_style6 1
#property indicator_style7 1
#property indicator_style8 0
#property indicator_style9 0
//---
#property indicator_level1 0
#property indicator_level2 30
#property indicator_level3 70
#property indicator_levelstyle 2
#property indicator_levelcolor clrDimGray
//-----------------------------------
//-----------------------------------

extern int               RSIPeriod = 15;   
extern ENUM_APPLIED_PRICE RSIPrice = PRICE_CLOSE;
extern int               SigPeriod = 21;  //42;  //32;  
extern ENUM_MA_METHOD      SigMode = MODE_LWMA;  

extern int                BarsBack = 240;
extern double             FiboBand = 0.786;
extern double              StdKoef = 3.32;     // 0.1454, 0.236, 0.382, 0.5, 0.618, 0.786, 1.0, 1.272, 1.414, 1.618, 2.058, 2.618, 3.32, 4.236, 5.35, 6.853....
extern int                    mPer = 3;
extern int                    iPer = 0;

//extern int fma = 12;
//extern int sma = 26;
//extern int sigma = 9;

//-----------------------------------
//-----------------------------------
double HISTOUP[],HISTODN[], SIGMA[], FINRSI[];
double CENTER[], StdHI[], StdLO[], FibHI[], FibLO[];
double ai[10,10], b[10], x[10], sx[20];
double sum;
int    ip, p, n, f;
double qq, mm, tt;
int    ii, jj, kk, ll, nn;
double sq, std;
//*******************************************
int init()
{
   IndicatorShortName("COG RSI ["+(string)RSIPeriod+">"+(string)SigPeriod+"]");   //"COGMACD: Mod by Brooky-Indicators.com");
   //---
   IndicatorBuffers(9);   IndicatorDigits(0);
   //---
   SetIndexBuffer(0,FINRSI);   SetIndexStyle(0,DRAW_LINE);    SetIndexDrawBegin(0,RSIPeriod+SigPeriod);
   SetIndexBuffer(1,HISTOUP);  SetIndexStyle(1,DRAW_LINE);    SetIndexDrawBegin(1,RSIPeriod+SigPeriod);
   SetIndexBuffer(2,HISTODN);  SetIndexStyle(2,DRAW_LINE);    SetIndexDrawBegin(2,RSIPeriod+SigPeriod);
   SetIndexBuffer(3,SIGMA);    SetIndexStyle(3,DRAW_LINE);    SetIndexDrawBegin(3,RSIPeriod+SigPeriod);   
   //---
   SetIndexBuffer(4,CENTER);   SetIndexStyle(4,DRAW_LINE);
   SetIndexBuffer(5,StdHI);    SetIndexStyle(5,DRAW_LINE);
   SetIndexBuffer(6,StdLO);    SetIndexStyle(5,DRAW_LINE);
   SetIndexBuffer(7,FibHI);    SetIndexStyle(7,DRAW_LINE);
   SetIndexBuffer(8,FibLO);    SetIndexStyle(8,DRAW_LINE);

   p = MathRound(BarsBack);
   
   nn = mPer + 1;
//------
return(0);
}
//----------------------------------------------------------
int deinit()
{
   Comment("");  return(0);
}
//**********************************************************************************************
int start()
{
   p = BarsBack; 
   sx[1] = p + 1;
   SetIndexDrawBegin(4,Bars - p - 1);
   SetIndexDrawBegin(5,Bars - p - 1);
   SetIndexDrawBegin(6,Bars - p - 1);
   SetIndexDrawBegin(7,Bars - p - 1);
   SetIndexDrawBegin(8,Bars - p - 1); 
//----------------------sx-------------------------------------------------------------------

     int i, limit;
     int CountedBars=IndicatorCounted();
  //---- check for possible errors
     if (CountedBars<0) return(-1);
  //---- the last counted bar will be recounted
     if (CountedBars>0) CountedBars--;
     limit=Bars-CountedBars;
  //---- main loop
     for (i=0; i<limit; i++)
      {
       FINRSI[i] = iRSI(NULL,0,RSIPeriod,RSIPrice,i);
       if (FINRSI[i] > 50)  HISTOUP[i] = FINRSI[i];
       if (FINRSI[i] < 50)  HISTODN[i] = FINRSI[i];
       //HISTOUP[ri]= iMACD(NULL,0,fma,sma,sigma,PRICE_CLOSE,MODE_MAIN,ri);//iStochastic(NULL,0,fma,sma,sigma,MODE_SMA,0,MODE_MAIN,ri);
       //SIGMA[ri]= iMACD(NULL,0,fma,sma,sigma,PRICE_CLOSE,MODE_SIGNAL,ri);//iStochastic(NULL,0,fma,sma,sigma,MODE_SMA,0,MODE_SIGNAL,ri);
      }
   
   for (i=0; i<limit; i++)  SIGMA[i] = iMAOnArray(FINRSI,Bars,SigPeriod,0,SigMode,i);

   for (int mi = 1; mi <= nn * 2 - 2; mi++)
   {
      sum = 0;
      for(n = iPer; n <= iPer + p; n++)
      {
         sum += MathPow(n, mi);
      }
      sx[mi + 1] = sum;
   }  
//----------------------syx-----------
   for(mi = 1; mi <= nn; mi++)
   {
   
      sum = 0.00000;
      for(n = iPer; n <= iPer + p; n++)
      {
         if(mi == 1)
            sum += (( FINRSI[n]+SIGMA[n] )+0.0000001)/2;//rsi_period  iRSI(NULL,0,rsi_period,prICE_CLOSE,n)
         else
            sum += (((FINRSI[n]+SIGMA[n])+0.0000001)/2) * MathPow(n, mi - 1);
      }
      b[mi] = sum;
   } 
//===============Matrix=======================================================================================================
   for(jj = 1; jj <= nn; jj++)
   {
      for(ii = 1; ii <= nn; ii++)
      {
         kk = ii + jj - 1;
         ai[ii, jj] = sx[kk];
      }
   }  
//===============Gauss========================================================================================================
   for(kk = 1; kk <= nn - 1; kk++)
   {
      ll = 0; mm = 0;
      for(ii = kk; ii <= nn; ii++)
      {
         if(MathAbs(ai[ii, kk]) > mm)
         {
            mm = MathAbs(ai[ii, kk]);
            ll = ii;
         }
      }
      if(ll == 0)
         return(0);   

      if(ll != kk)
      {
         for(jj = 1; jj <= nn; jj++)
         {
            tt = ai[kk, jj];
            ai[kk, jj] = ai[ll, jj];
            ai[ll, jj] = tt;
         }
         tt = b[kk]; b[kk] = b[ll]; b[ll] = tt;
      }  
      for(ii = kk + 1; ii <= nn; ii++)
      {
         qq = ai[ii, kk] / ai[kk, kk];
         for(jj = 1; jj <= nn; jj++)
         {
            if(jj == kk)
               ai[ii, jj] = 0;
            else
               ai[ii, jj] = ai[ii, jj] - qq * ai[kk, jj];
         }
         b[ii] = b[ii] - qq * b[kk];
      }
   }  
   x[nn] = b[nn] / ai[nn, nn];
   for(ii = nn - 1; ii >= 1; ii--)
   {
      tt = 0;
      for(jj = 1; jj <= nn - ii; jj++)
      {
         tt = tt + ai[ii, ii + jj] * x[ii + jj];
         x[ii] = (1 / ai[ii, ii]) * (b[ii] - tt);
      }
   } 
//===========================================================================================================================
   for(n = iPer; n <= iPer + p; n++)
   {
      sum = 0;
      for(kk = 1; kk <= mPer; kk++)
      {
         sum += x[kk + 1] * MathPow(n, kk);
      }
      CENTER[n] = x[1] + sum;
   } 
//-----------------------------------Std-----------------------------------------------------------------------------------
   sq = 0.0;
   for(n = iPer; n <= iPer + p; n++)
   {
      sq += MathPow((((FINRSI[n]+SIGMA[n])+0.0000001)/2) - CENTER[n], 2);
   }
   sq = MathSqrt(sq / (p + 1)) * StdKoef;
   std = iStdDevOnArray(FINRSI,0,p,0,MODE_SMA,iPer) * StdKoef;
   for(n = iPer; n <= iPer + p; n++)
   {
      StdHI[n] = CENTER[n] + sq;
      StdLO[n] = CENTER[n] - sq;
      FibHI[n] = CENTER[n] + (FiboBand*std);
      FibLO[n] = CENTER[n] - (FiboBand*std);
   } 
//-------------------------------------------------------------------------------
   //ObjectMove("sstart" + sName, 0, Time[p], CENTER[p]);
//----------------------------------------------------------------------------------------------------------------------------
return(0);
}
//==========================================================================================================================   