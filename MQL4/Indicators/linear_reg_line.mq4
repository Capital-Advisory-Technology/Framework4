#property strict
#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 LightSeaGreen
#property indicator_type1 DRAW_LINE
#property indicator_width1  3
#property indicator_label1  "Regression Following Line"

#include <CAT/Math/Alglib/alglib.mqh>

/*
When using iCustom pay attention at the calculation because at every candle shift all the values will change
Buffer 0 = Regression Slope
*/

input int RegChannelInterval=20;             //Candles To Include In The Calculation
input int RegChannelShift=0;                 //Delay In The Channel
input int RegLimit=0;                     //Bars To Draw (0=No Limit)
bool iCustomMode=true;                      //Enable iCustom Mode

double ChannelLine[];
int Shift=0;

int OnInit(void) {

    IndicatorSetString(INDICATOR_SHORTNAME, "Linear Regression Line");

    if(!OnInitPreChecksPass()) {
        return(INIT_FAILED);
    }   

    InitialiseBuffers();

    return(INIT_SUCCEEDED);
}

int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[]) {

   int UpTo = 0;
    if (prev_calculated == 0) {
        ArrayFill(ChannelLine,0,ArraySize(ChannelLine),EMPTY_VALUE);
        
        if (RegLimit == 0) 
            UpTo = Bars(Symbol(),PERIOD_CURRENT);
        else 
            UpTo = RegLimit;
    }
    else UpTo = 1;
   
    for (int k = 0; k < UpTo; k++) {
        if (iClose(Symbol(),PERIOD_CURRENT,k)==NULL 
        || iClose(Symbol(),PERIOD_CURRENT,k)==0) continue;
        
        int Vars = 1;
        CMatrixDouble TimePrice(RegChannelInterval,Vars+1);
        
        for (int j = 0; j < RegChannelInterval; j ++) {
            int i = j + k;
            TimePrice[j].Set(0,i);
            TimePrice[j].Set(1,iClose(Symbol(),PERIOD_CURRENT,i+RegChannelShift));
        }

        int Info;
        CLinearModelShell LinearModel;
        CLRReportShell Ar;
        double LinearCoefficient[];
        CAlglib::LRBuild(TimePrice,RegChannelInterval,Vars,Info,LinearModel,Ar);
        CAlglib::LRUnpack(LinearModel,LinearCoefficient,Vars);
        double Slope = LinearCoefficient[0];
        double Intercept = LinearCoefficient[1];
        ChannelLine[k] = Slope * (k-RegChannelShift) + Intercept;      
    }

    CheckIfNewCandle();

    if(IsStopped()) return(0);

    return(rates_total);
}


bool OnInitPreChecksPass() {
    if (RegChannelInterval <= 0 || RegChannelShift < 0) {
        Print("Wrong input parameter, period and delay can't be less than zero");
        return false;
    }   
    if (Bars(Symbol(),PERIOD_CURRENT) < RegChannelInterval + RegChannelShift) {
        Print("Not Enough Historical Candles");
        return false;
    }   
    return true;
}


void InitialiseBuffers() {
    IndicatorSetInteger(INDICATOR_DIGITS,_Digits);
    ArraySetAsSeries(ChannelLine,true);
    SetIndexBuffer(0,ChannelLine,INDICATOR_DATA);
}

bool CheckIfNewCandle() {
    datetime NewCandleTime=TimeCurrent();

    if (NewCandleTime == iTime(Symbol(),0,0)) 
        return false;
    else {
        NewCandleTime=iTime(Symbol(),0,0);
        return true;
    }
}

