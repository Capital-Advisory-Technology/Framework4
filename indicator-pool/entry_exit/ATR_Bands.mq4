//+-----------------------------------------------------------------------+
//| ATR Bands.mq4                                                         |
//| modded by MaryJane from STARCBands code (scorpion@fxfisherman.com)    |
//| to allow any ATR period and all basic MA types                        |
//+-----------------------------------------------------------------------+

#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 Goldenrod
#property indicator_color2 Teal
#property indicator_color3 DarkViolet
#property indicator_style1 STYLE_DOT
#property indicator_style2 STYLE_SOLID
#property indicator_style3 STYLE_SOLID


//---- indicator parameters
extern int MA_Period=75;
extern int MA_Mode=0;
extern int MA_Price=0;
extern int ATR_Period=300;
extern double KATR=2.618;
extern int Shift=0;

//---- buffers
double MovingBuffer[];
double UpperBuffer[];
double LowerBuffer[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function |
//+------------------------------------------------------------------+
int init()
{
  //---- indicators
  SetIndexStyle(0,DRAW_LINE);
  SetIndexBuffer(0,MovingBuffer);
  SetIndexStyle(1,DRAW_LINE);
  SetIndexBuffer(1,UpperBuffer);
  SetIndexStyle(2,DRAW_LINE);
  SetIndexBuffer(2,LowerBuffer);
  //----
  SetIndexDrawBegin(0,MA_Period+Shift);
  SetIndexDrawBegin(1,ATR_Period+Shift);
  SetIndexDrawBegin(2,ATR_Period+Shift);
  //----
  return(0);
}

//+------------------------------------------------------------------+
//| Bollinger Bands |
//+------------------------------------------------------------------+
int start()
{
  int i,k,counted_bars=IndicatorCounted();
  
  //----
  if(Bars<=MA_Period) return(0);
  
  //---- initial zero
  if(counted_bars<1)
  for(i=1;i<=MA_Period;i++)
  {
    MovingBuffer[Bars-i]=EMPTY_VALUE;
    UpperBuffer[Bars-i]=EMPTY_VALUE;
    LowerBuffer[Bars-i]=EMPTY_VALUE;
  }
  
  //----
  int limit=Bars-counted_bars;
  if(counted_bars>0) limit++;
  for(i=0; i<limit; i++)
  {
    MovingBuffer[i] = iMA(NULL,0,MA_Period,Shift,MA_Mode,MA_Price,i);
    UpperBuffer[i] = MovingBuffer[i] + (KATR * iATR(NULL,0,ATR_Period,i+Shift));
    LowerBuffer[i] = MovingBuffer[i] - (KATR * iATR(NULL,0,ATR_Period,i+Shift));
  }
  
  //----
  return(0);
}

//+----------scorpion@fxfisherman.com--------------------------------+