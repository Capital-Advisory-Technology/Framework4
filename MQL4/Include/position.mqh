
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
      long openTime,
      int positiontype,
      double lotSize, 
      double openPrice, 
      double slPrice, 
      double tpPrice,
      double SMA200,
      double EMA200,
      double SMA65,
      double EMA65,
      double RSI14,
      double ATR14
      ) {
         this.positionType = positionType;
         this.lotSize = lotSize; 
         this.openPrice =  openPrice;
         this.slPrice = slPrice;
         this.tpPrice = tpPrice;
         this.SMA200 = SMA200;
         this.EMA200 = EMA200;
         this.SMA65 = SMA65;
         this.EMA65 = EMA65;
         this.RSI14 = RSI14;
         this.ATR14 = ATR14;
         this.breakEvenFlag = 0;
      };
      
      ~Position() { } 
      
      
      void setPositionClosed(datetime endTime, double closePrice, double profit){
         this.balance = AccountBalance();
         this.closeTime = endTime;
         this.closePrice = closePrice;
         this.profit = profit;
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