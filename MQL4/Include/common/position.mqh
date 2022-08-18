
#include <common/enums.mqh>
#include <database/DB.mqh>

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
         
         Logger::log("----------------------------------------");
         Logger::log("number: " + string(number));
         Logger::log("openTime: " + string(openTime));
         Logger::log("closeTime: " + string(closeTime));
         Logger::log("Profit: " + string(profit));
         Logger::log("positionType: " + string(positionType));
         Logger::log("balance: " + string(balance));
         Logger::log("lotSize: " + string(lotSize));
         Logger::log("openPrice: " + string(openPrice));
         Logger::log("closePrice: " + string(closePrice));
         Logger::log("slPrice: " + string(slPrice));
         Logger::log("tpPrice: " + string(tpPrice));
         Logger::log("SMA200: " + string(SMA200));
         Logger::log("EMA200: " + string(EMA200));
         Logger::log("SMA65: " + string(SMA65));
         Logger::log("EMA65: " + string(EMA65));
         Logger::log("RSI14: " + string(RSI14));
         Logger::log("ATR14: " + string(ATR14));
         Logger::log("breakEvenFlag: " + string(breakEvenFlag));
         Logger::log("----------------------------------------");
      };
      
      
      void exportToDatabase(Database* db, int backtestId) {
         string positionSql = setPositionQuery(
                 backtestId, number,
                 openTime, closeTime,
                 profit, positionType,
                 balance,lotSize,
                 openPrice,closePrice,
                 slPrice,tpPrice,
                 SMA200,EMA200,
                 SMA65,EMA65,
                 RSI14, ATR14,
                 breakEvenFlag,closeType
              );
          db.insertData(positionSql);   
      }
      
      void setBreakEvenFlag(bool positive) {
         if (positive) {
            breakEvenFlag = 1;
         } else {
            breakEvenFlag = 0;
         }; 
      };
      
      double getProfit() {
         return profit;
      }
      
      int getPositionType() {
         return positionType;    
      }
      
       int getBreakEvenFlag() {
         return breakEvenFlag;    
      }
      
      void updateStopLoss() {
         slPrice = openPrice;
      };

};