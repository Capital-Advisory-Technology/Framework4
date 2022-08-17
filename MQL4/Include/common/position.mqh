
#include <common/enums.mqh>

class Position {

   private:
      int number;
      long openTime;
      long closeTime;
      double profit;
      int positionType;
      double balance;
      double lotSize;
      double openPrice;
      double closePrice;
      double slPrice;
      double tpPrice;
      double SMA200;
      double EMA200;
      double SMA65;
      double EMA65;
      double RSI14;
      double ATR14;
      int breakEvenFlag;
      int closeType;
      
   public: 
      Position::Position(
         int cNumber,
         long cOpenTime,
         int cPositiontype,
         double cLotSize, 
         double cOpenPrice, 
         double cSlPrice, 
         double cTpPrice,
         double cSMA200,
         double cEMA200,
         double cSMA65,
         double cEMA65,
         double cRSI14,
         double cATR14
      ) {
         this.number = cNumber;
         this.openTime = cOpenTime;
         this.positionType = cPositiontype;
         this.lotSize = cLotSize; 
         this.openPrice =  cOpenPrice;
         this.slPrice = cSlPrice;
         this.tpPrice = cTpPrice;
         this.SMA200 = NormalizeDouble(cSMA200, Digits);
         this.EMA200 = NormalizeDouble(cEMA200, Digits);
         this.SMA65 = NormalizeDouble(cSMA65, Digits);
         this.EMA65 = NormalizeDouble(cEMA65, Digits);
         this.RSI14 = NormalizeDouble(cRSI14, Digits);
         this.ATR14 = NormalizeDouble(cATR14, Digits);
         this.breakEvenFlag = 0;
      };
      
      ~Position() {} 
      
      void setPositionClosed(datetime endTime, double cClosePrice, double cProfit, int closeType){
         this.balance = AccountBalance();
         this.closeTime = endTime;
         this.closePrice = cClosePrice;
         this.profit = cProfit;
         this.closeType = closeType;
         
         Print("----------------------------------------");
         Print("number: " + string(number));
         Print("openTime: " + string(openTime));
         Print("closeTime: " + string(closeTime));
         Print("Profit: " + string(profit));
         Print("positionType: " + string(positionType));
         Print("balance: " + string(balance));
         Print("lotSize: " + string(lotSize));
         Print("openPrice: " + string(openPrice));
         Print("closePrice: " + string(closePrice));
         Print("slPrice: " + string(slPrice));
         Print("tpPrice: " + string(tpPrice));
         Print("SMA200: " + string(SMA200));
         Print("EMA200: " + string(EMA200));
         Print("SMA65: " + string(SMA65));
         Print("EMA65: " + string(EMA65));
         Print("RSI14: " + string(RSI14));
         Print("ATR14: " + string(ATR14));
         Print("breakEvenFlag: " + string(breakEvenFlag));
         Print("----------------------------------------");
      };
      
      void setBreakEvenFlag(bool positive) {
         if (positive) {
            breakEvenFlag = 1;
         } else {
            breakEvenFlag = 0;
         }; 
      };
      
      void updateStopLoss() {
         slPrice = getOpenPrice();
      };
      
      long getOpenTime() {
         return openTime;
      };
      
      int getNumber() {
         return number;
      };
        
      long getCloseTime() {
         return closeTime;
      };
      
      int getPositionType() {
         return positionType;
      };
      
      double getBalance() {
         return balance;
      };
      
      double getLotSize() {
         return lotSize;
      };
      
      double getOpenPrice() {
         return openPrice;
      };
      
      double getClosePrice() {
         return closePrice;
      };
      
      double getSlPrice() {
         return slPrice;
      };
      
      double getTpPrice() {
         return tpPrice;
      };
      
      double getProfit() {
         return profit;
      };
      
      double getSMA200() {
         return SMA200;
      };
      
      double getEMA200() {
         return EMA200;
      };
      
      double getSMA65() {
         return SMA65;
      };
      
      double getEMA65() {
         return EMA65;
      };
      
      double getRSI14() {
         return RSI14;
      };
      
      double getATR14() {
         return ATR14;
      };
      
      int getBreakEvenFlag() {
         return breakEvenFlag;
      };
      
       int getCloseType() {
         return closeType;
      };
};