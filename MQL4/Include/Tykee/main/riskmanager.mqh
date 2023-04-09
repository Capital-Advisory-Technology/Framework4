//###<Experts/Models/DEWA.mq4>
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
        int positionType;
        double openPrice;
        int stopLossPoints;
        int takeProfitPoints;
        double lotSize;
        double stopLossPrice;
        double takeProfitPrice;

        bool isBreakeven;
        bool isProfitZone;
        double breakevenPrice;
        double profitZonePrice;
        double profitZoneSLPrice;

        void setPositionType(int cPositionType)
        {
            positionType = cPositionType;
        }

        void setSLpoints() {
            double atr = NormalizeDouble(iATR(Symbol(), Period(), ATRPeriod, 1), Digits);
            int points = (int)(atr / Point * SLRatio);
            stopLossPoints = points;
        }

        void setTPpoints() {
            int points = (int)(stopLossPoints * TPRatio);
            takeProfitPoints = points;
        }

        void setOpenPrice() {
            double price;
            if (positionType == OP_BUY) price = Ask; else price = Bid;
            openPrice = price;
        }
        
        void setSLprice() {
            setSLpoints();
            double price = 0;
            double stopLoss = stopLossPoints * Point;
            if (positionType == OP_BUY) price = NormalizeDouble(openPrice - stopLoss, Digits); else price = NormalizeDouble(openPrice + stopLoss, Digits);
            stopLossPrice = price;
        }

        void setTPprice() {
            setTPpoints();
            double price = 0;
            double takeProfit = takeProfitPoints * Point;
            if (positionType == OP_BUY) price = NormalizeDouble(openPrice + takeProfit, Digits); else price = NormalizeDouble(openPrice - takeProfit, Digits);
            takeProfitPrice = price;
        }

        void setLotSize() {
            double lotStep = MarketInfo(Symbol(), MODE_LOTSTEP);
            double minLot = MarketInfo(Symbol(), MODE_MINLOT);
            double maxLot = MarketInfo(Symbol(), MODE_MAXLOT);
            double tickVal = MarketInfo(Symbol(), MODE_TICKVALUE);
            double lots = AccountBalance() * riskPerTrade / 100 / (stopLossPoints * tickVal);

            lotSize = MathMin(
                maxLot,
                MathMax(
                    minLot,
                    NormalizeDouble(lots / lotStep, 0) * lotStep
                )
            );
        }
        
        void setBreakevenPrice() {
            double price = 0;
            double breakevenDelta = takeProfitPoints * Point * breakeven;
            if (positionType == OP_BUY) price = NormalizeDouble(breakevenDelta + openPrice, Digits); else price = NormalizeDouble(openPrice - breakevenDelta, Digits);
            breakevenPrice = price;
        }

        void setProfitZonePrice() {
            double price = 0;
            double profitZoneDelta = takeProfitPoints * Point * profitZone;
            if (positionType == OP_BUY) {
                price = NormalizeDouble(openPrice + profitZoneDelta, Digits);
            } else {
                price = NormalizeDouble(openPrice - profitZoneDelta, Digits);
            }
            profitZonePrice = price;
            Print("ProfitZonePrice: ", profitZonePrice);
        }

        void setProfitZoneSLPrice() {
            double price = 0;
            double profitDelta;
            if (positionType == OP_BUY) {
                profitDelta = takeProfitPrice - openPrice;
                price = NormalizeDouble(openPrice + profitDelta * profitRatio, Digits);
            } else {
                profitDelta = openPrice - takeProfitPrice;
                price = NormalizeDouble(openPrice - profitDelta * profitRatio, Digits);
            }
            profitZoneSLPrice = price;
            Print("ProfitZoneSLPrice: ", profitZoneSLPrice);
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

            this.isBreakeven = false;
            this.isProfitZone = false;
        }

        ~RiskManager() {
        }

        void newTrade(int cPositionType) {
            setPositionType(cPositionType);
            setOpenPrice();
            setSLprice();
            setTPprice();
            setLotSize();
            setBreakevenPrice();
            setProfitZonePrice();
            setProfitZoneSLPrice();
        }

        void onPositionClosed() {
            openPrice = 0;
            stopLossPoints = 0;
            takeProfitPoints = 0;
            lotSize = 0;
            stopLossPrice = 0;
            takeProfitPrice = 0;

            isBreakeven = false;
            isProfitZone = false;
            breakevenPrice = 0;
            profitZonePrice = 0;
            profitZoneSLPrice = 0;
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

        void setProfitZone() {
            isProfitZone = true;
        }

        bool getProfitZone() {
            return isProfitZone;
        }

        double getProfitZonePrice() {
            return profitZonePrice;
        }

        double getProfitZoneSLPrice() {
            return profitZoneSLPrice;
        }
};