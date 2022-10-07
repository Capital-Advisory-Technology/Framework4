#include <Tykee/common/enums.mqh>
#include <Tykee/common/logger.mqh>
#include <Tykee/database/DB.mqh>
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
      
      void setPositionClosed(datetime endTime, double cClosePrice, double cGrossProfit, double cNetProfit, double cCommission, double cSwap, int ccloseType){
         this.balance = AccountBalance();
         this.closeTime = endTime;
         this.closePrice = cClosePrice;
         this.grossProfit = cGrossProfit;
         this.netProfit = cNetProfit;
         this.commission = cCommission;
         this.swap = cSwap;
         this.closeType = ccloseType;
         
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
         Logger::log("SMA200: " + string(SMA200));
         Logger::log("EMA200: " + string(EMA200));
         Logger::log("SMA65: " + string(SMA65));
         Logger::log("EMA65: " + string(EMA65));
         Logger::log("RSI14: " + string(RSI14));
         Logger::log("ATR14: " + string(ATR14));
         Logger::log("breakEvenFlag: " + string(breakEvenFlag));
         Logger::log("closeType: " + string(closeType));
         Logger::log("----------------------------------------");
      };
      
      
      string getSql(int backtestId) {
         return setPositionQuery(
                 backtestId, number,
                 openTime, closeTime,
                 grossProfit, netProfit,
                 positionType,balance,
                 lotSize,openPrice,
                 closePrice,slPrice,
                 tpPrice,commission,
                 swap,SMA200,
                 EMA200,SMA65,
                 EMA65,RSI14, 
                 ATR14,breakEvenFlag,
                 closeType
              );
      }
      
      CJAVal toJson() {
         CJAVal json;
         
         json["number"] = number;
         json["open_time"] = openTime;
         json["close_time"] = closeTime;
         json["gross_profit"] = grossProfit;
         json["net_profit"] = netProfit;
         json["position_type"] = positionType;
         json["balance"] = balance;
         json["lot_size"] = lotSize;
         json["open_price"] = openPrice;
         json["close_price"] = closePrice;
         json["sl_price"] = slPrice;
         json["tp_price"] = tpPrice;
         json["commission"] = commission;
         json["swap"] = swap;
         json["sma_200"] = SMA200;
         json["ema_200"] = EMA200;
         json["sma_65"] = SMA65;
         json["ema_65"] = EMA65;
         json["rsi_14"] = RSI14;
         json["atr_14"] = ATR14;
         json["break_even_flag"] = breakEvenFlag;
         json["close_type"] = closeType;
         return json;
      }
      
      void setBreakEvenFlag(bool positive) {
         if (positive) {
            breakEvenFlag = 1;
         } else {
            breakEvenFlag = 0;
         }; 
      };
      
      double getNetProfit() {
         return netProfit;
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