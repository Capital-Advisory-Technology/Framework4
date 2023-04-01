//+------------------------------------------------------------------+
//|                                                         risk.mqh |
//|                                            Copyright 2022, Tykee |
//|   risk.mqh provides functions that are used for risk management  |
//+------------------------------------------------------------------+
#property copyright "Copyright 2022, Tykee"
#property link      ""
#property strict


class RiskManager {
    private:
        double breakeven;
        int zoneCount;

    public:
        RiskManager::RiskManager(double cBreakeven, int cZoneCount) {
            this.breakeven = cBreakeven;
            this.zoneCount = cZoneCount;
        }
            
};