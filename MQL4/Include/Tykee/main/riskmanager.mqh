//+------------------------------------------------------------------+
//|                                                         risk.mqh |
//|                                            Copyright 2022, Tykee |
//|   risk.mqh provides functions that are used for risk management  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, Tykee"
#property link      ""
#property strict

#define ATRIndicator "Indicators\\Adaptive_ATR.ex4"
#resource "\\" + ATRIndicator


class RiskManager {
    private:
        // Init variables - ratios, percentages, etc.
        double riskPerTrade;
        double SLRatio;
        double TPRatio;
        double breakeven;
        double profitZone;
        double profitRatio;
        int ATRPeriod;
        
        // Calculated variables
        double openPrice;
        double lotSize;
        double stopLossPrice;
        double takeProfitPrice;

        bool isBreakeven;
        bool isProfitZone;
        double breakevenPrice;
        double profitZonePrice;
        double profitZoneSLPrice;

        int getSLpoints() {
            int stopLoss;
            double atr = NormalizeDouble(iATR(Symbol(), Period(), ATRPeriod, 1), Digits);
            stopLoss = (int)(atr / Point * SLRatio);
            return stopLoss;
        }

        int getTPpoints() {
            int takeProfit;
            takeProfit = (int)(getSLpoints() * TPRatio);
            return takeProfit;
        }

        void setOpenPrice(int positionType) {
            double price;
            if (positionType == OP_BUY) price = Ask; else price = Bid;
            openPrice = price;
        }
        
        void setSLprice(int positionType) {
            double price = 0;
            double stopLoss = getSLpoints() * Point;
            if (positionType == OP_BUY) price = NormalizeDouble(openPrice - stopLoss, Digits); else price = NormalizeDouble(openPrice + stopLoss, Digits);
            stopLossPrice = price;
        }

        void setTPprice(int positionType) {
            double price = 0;
            double takeProfit = getTPpoints() * Point;
            if (positionType == OP_BUY) price = NormalizeDouble(openPrice + takeProfit, Digits); else price = NormalizeDouble(openPrice - takeProfit, Digits);
            takeProfitPrice = price;
        }

        void setLotSize() {
            double lotStep = MarketInfo(Symbol(), MODE_LOTSTEP);
            double minLot = MarketInfo(Symbol(), MODE_MINLOT);
            double maxLot = MarketInfo(Symbol(), MODE_MAXLOT);
            double tickVal = MarketInfo(Symbol(), MODE_TICKVALUE);
            double lots = AccountBalance() * riskPerTrade / 100 / (getSLpoints() * tickVal);
            lotSize = MathMin(
                maxLot,
                MathMax(
                    minLot,
                    NormalizeDouble(lotSize / lotStep, 0) * lotStep
                )
            );
        }
        
        void setBreakevenPrice(int positionType) {
            double price = 0;
            double breakevenDelta = getTPpoints() * Point * breakeven;
            if (positionType == OP_BUY) price = NormalizeDouble(breakevenDelta + openPrice, Digits); else price = NormalizeDouble(breakevenDelta - openPrice, Digits);
            breakevenPrice = price;
        }


        // ADD PROFITZONES METHODS
        void setProfitZonePrice(int positionType) {
            double price = 0;
            double profitZoneDelta = getTPpoints() * Point * profitZone;
            if (positionType == OP_BUY) {
                price = NormalizeDouble(profitZoneDelta + openPrice, Digits);
            } else {
                price = NormalizeDouble(profitZoneDelta - openPrice, Digits);
            }
            return price;
        }

    public:
        RiskManager::RiskManager(double cRiskPerTrade, double cSLRatio, double cTPRatio, double cBreakeven, double cProfitZone, double cProfitRatio, int cATRPeriod) {
            this.riskPerTrade = cRiskPerTrade;
            this.SLRatio = cSLRatio;
            this.TPRatio = cTPRatio;
            this.breakeven = cBreakeven;
            this.profitZone = cProfitZone;
            this.profitRatio = cProfitRatio;
            this.ATRPeriod = cATRPeriod;
        }

        void newTrade(int positionType) {
            setOpenPrice(positionType);
            setSLprice(positionType);
            setTPprice(positionType);
            setLotSize();
            setBreakevenPrice(positionType);
        }

        double getLotSize() {
            return lotSize;
        }

        double getSLprice() {
            return stopLossPrice;
        }

        double getTPprice() {
            return takeProfitPrice;
        }

        void setBreakeven() {
            isBreakeven = true;
        }

        bool getBreakeven() {
            return isBreakeven;
        }

        double getBreakevenPrice() {
            return breakevenPrice;
        }

        // ADD PROFITZONES METHODS
 
};