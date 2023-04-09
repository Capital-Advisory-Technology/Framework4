#include <Tykee/common/enums.mqh>
#include <Tykee/common/logger.mqh>
#include <libs/JAson.mqh>

/*
   Position "Data class". Just to hold state of position.
*/
class Position {

   private:
      int number;
      long openTime;
      long closeTime;
      double grossProfit;
      double netProfit;
      int positionType;
      double balance;
      double lotSize;
      double openPrice;
      double closePrice;
      double slPrice;
      double tpPrice;
      double commission;
      double swap;
      int breakEvenFlag;
      int closeType;
      
   public: 
      Position::Position(
         int cNumber,
         long cOpenTime,
         int cPositionType,
         double cLotSize, 
         double cOpenPrice, 
         double cSlPrice, 
         double cTpPrice
      ) {
         this.number = cNumber;
         this.openTime = cOpenTime;
         this.positionType = cPositionType;
         this.lotSize = cLotSize; 
         this.openPrice =  cOpenPrice;
         this.slPrice = cSlPrice;
         this.tpPrice = cTpPrice;
         this.breakEvenFlag = 0;
      };
      
      ~Position() {} 
      
      void setPositionClosed(datetime endTime, double cClosePrice, double cGrossProfit, double cNetProfit, double cCommission, double cSwap, int cCloseType){
         this.balance = NormalizeDouble(AccountBalance(), 2);
         this.closeTime = endTime;
         this.closePrice = NormalizeDouble(cClosePrice, Digits);
         this.grossProfit = NormalizeDouble(cGrossProfit, 2);
         this.netProfit = NormalizeDouble(cNetProfit, 2);
         this.commission = NormalizeDouble(cCommission, 2);
         this.swap = NormalizeDouble(cSwap, 2);
         this.closeType = cCloseType;
         
         Logger::log("----------------------------------------");
         Logger::log("number: " + string(number));
         Logger::log("openTime: " + string(openTime));
         Logger::log("closeTime: " + string(closeTime));
         Logger::log("grossProfit: " + string(grossProfit));
         Logger::log("netProfit: " + string(netProfit));
         Logger::log("positionType: " + string(positionType));
         Logger::log("balance: " + string(balance));
         Logger::log("lotSize: " + string(lotSize));
         Logger::log("openPrice: " + string(openPrice));
         Logger::log("closePrice: " + string(closePrice));
         Logger::log("slPrice: " + string(slPrice));
         Logger::log("tpPrice: " + string(tpPrice));
         Logger::log("Commission: " + string(commission));
         Logger::log("Swap: " + string(swap));
         Logger::log("breakEvenFlag: " + string(breakEvenFlag));
         Logger::log("closeType: " + string(closeType));
         Logger::log("----------------------------------------");
      };
            
      void setBreakEvenFlag(bool positive) {
         if (positive) {
            breakEvenFlag = 1;
         } else {
            breakEvenFlag = 0;
         }; 
      };
      
      int getPositionType() {
         return positionType;    
      }
      
      int getBreakEvenFlag() {
         return breakEvenFlag;    
      }
      
      void updateStopLoss(double price) {
         slPrice = price;
      };

      CJAVal toJson() {
         CJAVal json;
         json["order_nr"] = number;
         json["date_from"] = openTime;
         json["date_to"] = closeTime;
         json["lot_size"] = lotSize;
         json["open_price"] = openPrice;
         json["close_price"] = closePrice;
         json["sl_price"] = slPrice;
         json["tp_price"] = tpPrice;
         json["gross_profit"] = grossProfit;
         json["net_profit"] = netProfit;
         json["commission"] = commission;
         json["swap"] = swap;
         json["balance"] = balance;
         json["position_type"] = positionType;
         json["breakeven_flag"] = breakEvenFlag;
         json["close_type"] = closeType;
         return json;
      }
};