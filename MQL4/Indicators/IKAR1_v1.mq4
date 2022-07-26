//+------------------------------------------------------------------+
//|                                                        IKAR1.mq4 |
//|                                                            IKAR  |
//|                                                       pagrabs.eu |
//+------------------------------------------------------------------+
#property copyright "IKAR "
#property link      "pagrabs.eu"
#property version   "1.00"
#property strict
#property indicator_chart_window

#define SHOW 0
#define HIDE 1
enum SH {Show, Hide};

// 
extern SH ShowMenu = SHOW;

extern color MenuColor = clrWhiteSmoke;
extern int MenuFont = 8;

// RSI  
extern int RSIPeriod = 14;
extern double OverBought         =  70.0;
extern double VeryOverBought     =  75.0;
extern double ExtremeOverBought  =  80.0;
extern double OverSold           =  30.0;
extern double VeryOverSold       =  25.0;
extern double ExtremeOverSold    =  20.0;

// EMA, SMA
extern int EMAPeriod = 65;
extern int SMAPeriod = 200;

// global var
int medzera; 


int OnInit()
  {

   DrawMenu();
   
   return(INIT_SUCCEEDED);
  }



void OnDeinit(const int reason)
  {

   
  }


void OnTick() {
   ReDrawMenu();
}


bool DrawMenu() {
   medzera = 8;
   //---Create and Modify Label Cells
   //--- RSI Label
   ObjectCreate("RSILabel",OBJ_LABEL,0,0,0,0,0);
   ObjectSetText("RSILabel", "RSI_"+IntegerToString(RSIPeriod)+" : " , MenuFont, "TimesNewRoman", MenuColor);
   ObjectSet("RSILabel",OBJPROP_XDISTANCE,medzera * MenuFont + 90);     
   ObjectSet("RSILabel",OBJPROP_YDISTANCE,10+1*(MenuFont+2));
   ObjectSet("RSILabel",OBJPROP_CORNER,1);
   //--- EMA Label
   ObjectCreate("EMALabel",OBJ_LABEL,0,0,0,0,0);
   ObjectSetText("EMALabel", "EMA_"+IntegerToString(EMAPeriod)+" : "  , MenuFont, "TimesNewRoman", MenuColor);
   ObjectSet("EMALabel",OBJPROP_XDISTANCE,medzera * MenuFont + 90);     
   ObjectSet("EMALabel",OBJPROP_YDISTANCE,20+2*(MenuFont+2));
   ObjectSet("EMALabel",OBJPROP_CORNER,1);
   //--- SMA Label
   ObjectCreate("SMALabel",OBJ_LABEL,0,0,0,0,0);
   ObjectSetText("SMALabel", "SMA_"+IntegerToString(SMAPeriod)+" : "  , MenuFont, "TimesNewRoman", MenuColor);
   ObjectSet("SMALabel",OBJPROP_XDISTANCE,medzera * MenuFont + 90);     
   ObjectSet("SMALabel",OBJPROP_YDISTANCE,30+3*(MenuFont+2));
   ObjectSet("SMALabel",OBJPROP_CORNER,1);
   //--- Disclaimer Label
   ObjectCreate("Disclaimer",OBJ_LABEL,0,0,0,0,0);
   ObjectSetText("Disclaimer", "THIS IS NOT FINANCIAL ADVICE. TRADE AT YOUR OWN RISK.", 7, "TimesNewRoman", clrYellow);
   ObjectSet("Disclaimer",OBJPROP_XDISTANCE,10);     
   ObjectSet("Disclaimer",OBJPROP_YDISTANCE,10+1*(MenuFont+2));
   ObjectSet("Disclaimer",OBJPROP_CORNER,3);
   
   //--- Create and Modify Value Cells      
   //--- RSI value
   ObjectCreate("RSIValue",OBJ_LABEL,0,0,0,0,0);
   ObjectSetText("RSIValue", " - ", MenuFont, "TimesNewRoman",MenuColor);
   ObjectSet("RSIValue",OBJPROP_XDISTANCE, 3 * MenuFont);     
   ObjectSet("RSIValue",OBJPROP_YDISTANCE,10+1*(MenuFont+2));
   ObjectSet("RSIValue",OBJPROP_CORNER,1);
   //--- EMA value
   ObjectCreate("EMAValue",OBJ_LABEL,0,0,0,0,0);  
   ObjectSetText("EMAValue", " - ", MenuFont, "TimesNewRoman",MenuColor);
   ObjectSet("EMAValue",OBJPROP_XDISTANCE, 3 * MenuFont);     
   ObjectSet("EMAValue",OBJPROP_YDISTANCE,20+2*(MenuFont+2));
   ObjectSet("EMAValue",OBJPROP_CORNER,1);
   //--- SMA value
   ObjectCreate("SMAValue",OBJ_LABEL,0,0,0,0,0);  
   ObjectSetText("SMAValue", " - ", MenuFont, "TimesNewRoman",MenuColor);
   ObjectSet("SMAValue",OBJPROP_XDISTANCE, 3 * MenuFont);     
   ObjectSet("SMAValue",OBJPROP_YDISTANCE,30+3*(MenuFont+2));
   ObjectSet("SMAValue",OBJPROP_CORNER,1);
   
   
   //--- Create and Modify Monthly High and Low HLine
   double months_high = MonthsHigh();
   ObjectCreate("MonthlyHigh", OBJ_HLINE, 0, Time[0], months_high,0,0);
   ObjectSet("MonthlyHigh", OBJPROP_COLOR, clrDeepPink);
   ObjectSet("MonthlyHigh", OBJPROP_STYLE, STYLE_SOLID);
   ObjectSet("MonthlyHigh", OBJPROP_BACK, false);
   
   double months_low = MonthsLow();
   ObjectCreate("MonthlyLow", OBJ_HLINE, 0, Time[0], months_low,0,0);
   ObjectSet("MonthlyLow", OBJPROP_COLOR, clrAqua);
   ObjectSet("MonthlyLow", OBJPROP_STYLE, STYLE_SOLID);
   ObjectSet("MonthlyLow", OBJPROP_BACK, false);
   
   return(true);
}

bool ReDrawMenu() {   
     
   double rsi_value = iRSI(NULL,0,RSIPeriod,PRICE_CLOSE,0);
   double ema_value = iMA(NULL, 0,EMAPeriod,0,MODE_EMA,PRICE_CLOSE,0);
   double sma_value = iMA(NULL, 0,SMAPeriod,0,MODE_SMA,PRICE_CLOSE,0);
  
   string rsi_status = RSIStatus(rsi_value);
   string ema_status = MAStatus(ema_value);
   string sma_status = MAStatus(sma_value);
   
   color rsi_color = RSIStatusColor(rsi_status);
   color ema_color = MAStatusColor(ema_status);
   color sma_color = MAStatusColor(sma_status);
  
   rsi_status = rsi_status + " - " + DoubleToString(rsi_value, 2);
   ema_status = ema_status + " - " + DoubleToString(ema_value, Digits);
   sma_status = sma_status + " - " + DoubleToString(sma_value, Digits);
   
   double monthly_high = MonthsHigh();
   double monthly_low = MonthsLow();
  
   ObjectSetText("RSIValue", rsi_status, MenuFont, "TImesNewRoman",rsi_color);
   ObjectSetText("EMAValue", ema_status, MenuFont, "TImesNewRoman",ema_color);
   ObjectSetText("SMAValue", sma_status, MenuFont, "TImesNewRoman",sma_color);
   ObjectMove("MonthlyHigh", 0,0,monthly_high);
   ObjectMove("MonthlyLow", 0,0,monthly_low);          
   return(true);
}

string RSIStatus(double rsi_value) {
  
  string rsi_status;
  
  if(rsi_value >= ExtremeOverBought) {
      rsi_status = "Extremly OverBought";
   } else if (rsi_value >= VeryOverBought) {
      rsi_status = "Very OverBought";
   } else if (rsi_value >= OverBought) {
      rsi_status = "OverBought";
   } else if (rsi_value > VeryOverBought && rsi_value <= OverSold) {
      rsi_status = "OverSold";
   } else if (rsi_value > ExtremeOverSold && rsi_value <= VeryOverSold) {
      rsi_status = "Very OverSold";
   } else if (rsi_value <= ExtremeOverSold) {
      rsi_status = "Extremly OverSold";
   } else {
       rsi_status = "Neutral";
   }
   
   return rsi_status;
}

color RSIStatusColor(string rsi_status) {
   color status_color;
   if(rsi_status == "Extremly OverBought") {
      status_color = clrLimeGreen;
   } else if (rsi_status == "Very OverBought") {
      status_color = clrLime;
   } else if (rsi_status == "OverBought") {
      status_color = clrChartreuse;
   } else if (rsi_status == "OverSold") {
      status_color = clrOrangeRed;
   } else if (rsi_status == "Very OverSold") {
      status_color = clrRed;
   } else if (rsi_status == "Extremly OverSold") {
      status_color = clrFireBrick;
   } else {
      status_color = clrWhite;
   }
   
   return status_color;
}
  
string MAStatus(double sma_value) {
   
   string sma_status;
   
   if (sma_value <= Ask) {
      sma_status = "Bullish";
   } else {
      sma_status = "Bearish";
   }
   
   return sma_status;
}


color MAStatusColor(string sma_status) {
   color status_color;
   if(sma_status == "Bullish") {
      status_color = clrLime;
   } else {
      status_color = clrRed;
   }
   
   return status_color;
}

double MonthsHigh() {
   double months_high;
   double last_month_high = iHigh(NULL, PERIOD_MN1, 0);
   double this_month_high = iHigh(NULL, PERIOD_MN1, 1);
   if (last_month_high > this_month_high) {
      months_high = last_month_high;
   } else {
      months_high = this_month_high;
   }
   return months_high;
}

double MonthsLow() {
   double months_low;
   double last_month_low = iLow(NULL, PERIOD_MN1, 0);
   double this_month_low = iLow(NULL, PERIOD_MN1, 1);
   if (last_month_low < this_month_low) {
      months_low = last_month_low;
   } else {
      months_low = this_month_low;
   }
   return months_low;
}