
#include <enums.mqh>

class Position {

   private:
   long openTime;
   long closeTime;
   int positionType;
   double lotSize;
   double openPrice;
   double closePrice;
   double slPrice;
   double tpPrice;
   double profit;
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
      
      
      void setPositionClosed(datetime endTime, double closePrice){
         closeTime = endTime;
         closePrice = closePrice;
         
      };
      
      void setBreakEvenFlag(bool positive) {
         if (positive) {
            breakEvenFlag = 1;
         } else {
            breakEvenFlag = 0;
         }; 
      };
};