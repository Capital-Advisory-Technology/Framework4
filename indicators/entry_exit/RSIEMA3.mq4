//+------------------------------------------------------------------+ 
//| ARSI.mq4 
//+------------------------------------------------------------------+ 
#property copyright "Alexander Kirilyuk M." 
#property link "" 

#property indicator_separate_window
//#property indicator_chart_window
#property indicator_buffers 3
#property indicator_color1 DodgerBlue
#property indicator_color2 Yellow
#property indicator_color3 Red
#property indicator_width1 2
#property indicator_width2 2
#property indicator_width3 2
extern int ARSI1Period = 14;
extern int ARSI2Period =  3;
extern int ARSI3Period =  50;

//---- buffers 
double ARSI1[]; 
double ARSI2[]; 
double ARSI3[]; 

int init()
{ 
	string short_name = "2+1 RSI adaptive EMAs (" + ARSI1Period + "," + ARSI2Period+")";

	SetIndexBuffer(0,ARSI1); 
	SetIndexBuffer(1,ARSI2);
   SetIndexBuffer(2,ARSI3); 
 
	//SetIndexDrawBegin(0,ARSIPeriod);

	return(0); 
} 

int start() 
{ 
	int i, counted_bars = IndicatorCounted(); 
	int limit;

	if(Bars <= ARSI1Period) 
		return(0);

	if(counted_bars < 0)
	{
		return;
	}
	
	if(counted_bars == 0)
	{
		limit = Bars;
	}
	if(counted_bars > 0)
	{
		limit = Bars - counted_bars;
	}
	
	double sc;
	for(i = limit; i >= 0; i--)
	{
		sc = MathAbs(iRSI(NULL, 0, ARSI1Period, PRICE_CLOSE, i)/100.0 - 0.5) * 2.0;
		if( Bars - i <= ARSI1Period)
   			ARSI1[i] = Close[i];
		else	ARSI1[i] = ARSI1[i+1] + sc * (Close[i] - ARSI1[i+1]);
		sc = MathAbs(iRSI(NULL, 0, ARSI2Period, PRICE_CLOSE, i)/100.0 - 0.5) * 2.0;
		if( Bars - i <= ARSI2Period)
   			ARSI2[i] = Close[i];
		else	ARSI2[i] = ARSI2[i+1] + sc * (Close[i] - ARSI2[i+1]);
		sc = MathAbs(iRSI(NULL, 0, ARSI3Period, PRICE_CLOSE, i)/100.0 - 0.5) * 2.0;
		if( Bars - i <= ARSI3Period)
   			ARSI3[i] = Close[i];
		else	ARSI3[i] = ARSI3[i+1] + sc * (Close[i] - ARSI3[i+1]);
	}
	return(0); 
} 


