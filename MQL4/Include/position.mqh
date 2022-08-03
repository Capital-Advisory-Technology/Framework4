
#include <enums.mqh>

class Position {

   private:
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
      
   public: 
      Position::Position(
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
         this.openTime = cOpenTime;
         this.positionType = cPositiontype;
         this.lotSize = cLotSize; 
         this.openPrice =  cOpenPrice;
         this.slPrice = cSlPrice;
         this.tpPrice = cTpPrice;
         this.SMA200 = cSMA200;
         this.EMA200 = cEMA200;
         this.SMA65 = cSMA65;
         this.EMA65 = cEMA65;
         this.RSI14 = cRSI14;
         this.ATR14 = cATR14;
         this.breakEvenFlag = 0;
      };
      
      ~Position() {} 
      
      void setPositionClosed(datetime endTime, double cClosePrice, double cProfit){
         this.balance = AccountBalance();
         this.closeTime = endTime;
         this.closePrice = cClosePrice;
         this.profit = cProfit;
      };
      
      void setBreakEvenFlag(bool positive) {
         if (positive) {
            breakEvenFlag = 1;
         } else {
            breakEvenFlag = 0;
         }; 
      };
      
      long getOpenTime() {
         return openTime;
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
};