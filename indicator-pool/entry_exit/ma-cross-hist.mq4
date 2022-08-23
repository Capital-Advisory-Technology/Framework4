//+-------------------------------------------------------------------+
//|	MA_Crossover_Histogram.mq4
//|	Simple indicator based on 2 EMA spread and shifted
//| !!! this file is created with Tab size 4 and no space indentation
//+-------------------------------------------------------------------+
#property copyright "Comer"
#property link		" "

#property indicator_separate_window

#property indicator_buffers	4

#property indicator_color1	DodgerBlue
#property indicator_style1	STYLE_SOLID
#property indicator_width1	4

#property indicator_color2	Red
#property indicator_style2	STYLE_SOLID
#property indicator_width2	4

#property indicator_color3	Navy
#property indicator_style3	STYLE_SOLID
#property indicator_width3	4

#property indicator_color4	Maroon
#property indicator_style4	STYLE_SOLID
#property indicator_width4	4

extern int		period		= 7;
extern int		Right_Shift	= 4;

double ExtMapBuffer1[];
double ExtMapBuffer2[];
double ExtMapBuffer3[];
double ExtMapBuffer4[];

int BarNumber;
int BarIndex;

int init() {
	int line = 0;

	SetIndexStyle ( line, DRAW_HISTOGRAM );
	SetIndexBuffer( line, ExtMapBuffer1 );
	line++;

	SetIndexStyle ( line, DRAW_HISTOGRAM );
	SetIndexBuffer( line, ExtMapBuffer2 );
	line++;

	SetIndexStyle ( line, DRAW_HISTOGRAM );
	SetIndexBuffer( line, ExtMapBuffer3 );
	line++;

	SetIndexStyle ( line, DRAW_HISTOGRAM );
	SetIndexBuffer( line, ExtMapBuffer4 );
	line++;

	// EMA has inherent lag - adjust the shift by lag amount
	int lag = (period - 1) / 3;
	Right_Shift -= lag;

	return(0);
}

int deinit() {
	return(0);
}

int start() {
	BarNumber = IndicatorCounted();	// [0 .. Bars]

	/*	'BarNumber' is the number of the LAST fake bar - the one that last time had index 0
		MT4 documentation states that the last bar is always considered NOT updated.
		So the 'BarNumber' may point to NEXT to LAST bar. However, there are different
		confusing scenarios around that, so it is safer to recalculate 1 more bar, potentially.
	*/

	// number of bars are faked at the end of the graph - always recalculate those
	// if not - the graph will be always filled as if period is 1.
	int fakeBars		= period - Right_Shift;
	int firstFakeNumber	= BarNumber - fakeBars - 1;

	// now add those bars to the list of bars to recalculate
	BarNumber = firstFakeNumber;
	
	for( BarIndex = Bars - BarNumber; BarIndex > 0; ) {
		BarIndex--;		// [Bars-1 .. 0]
		processBar();
		BarNumber++;
	}
   
	return(0);
}


void processBar() {
	int		frontLineDataIdx	= BarIndex + Right_Shift;
	
	if( frontLineDataIdx >= Bars )	// 'backLineDataIdx' being negative is fine - it will be processed correctly
		return;
	
	// 'backLineDataIdx' WILL become negative - these bars ARE FAKE and WILL BE recalculated (repainted)
	int		backLineDataIdx		= frontLineDataIdx - period;
	double	front				= getC( frontLineDataIdx );
	double	back				= getC( backLineDataIdx );

	draw( back, front, (backLineDataIdx <= 0) );
	
	return(0);
}

double getC( int index ) {
	int	p = period;
	
	if( index < 0 ) {
		p += index; // reduce period for bars that are right of "real" current. those bars ARE FAKE and will be recalculated on the next bar.
		index = 0;
		if(p <= 0)
			p = 1;
	}
	double c = iMA( NULL, 0, p, 0, MODE_LWMA, PRICE_TYPICAL, index );
	
	return (c);
}

void draw( double back, double front, bool isFake ) {
	bool up;
	
	if( back > front )
		up = true;
	else 
	if( back < front )
		up = false;
	else {	// exactly equal - copy the last values
		if( (BarNumber > 0) && (ExtMapBuffer1[ BarIndex+1 ] == 1) )
			up = true;
		else
			up = false;
	}
	
	double backValue;
	double frontValue;
	
	if( up ) {
		backValue	= 1;
		frontValue	= 0;
	}
	else {
		backValue	= 0;
		frontValue	= 1;
	}
	
	if( !isFake ) {
		ExtMapBuffer1[ BarIndex ] = backValue;
		ExtMapBuffer2[ BarIndex ] = frontValue;
		ExtMapBuffer3[ BarIndex ] = EMPTY_VALUE;
		ExtMapBuffer4[ BarIndex ] = EMPTY_VALUE;
	}
	else {
		ExtMapBuffer1[ BarIndex ] = EMPTY_VALUE;
		ExtMapBuffer2[ BarIndex ] = EMPTY_VALUE;
		ExtMapBuffer3[ BarIndex ] = backValue;
		ExtMapBuffer4[ BarIndex ] = frontValue;
	}
}

