#include <Tykee/common/logger.mqh>
#include <Tykee/common/enums.mqh>
#include <libs/JAson.mqh>

int TokyoOpen = 2;
int TokyoClose = 10;

int LondonOpen = 10;
int LondonClose = 18;

int NewYorkOpen = 15;
int NewYorkClose = 23;

class Range {
 
 private:
   int beginning;
   int end;
   AllowedOrder allowedOrder;

 public:
      Range::Range(int beginning, int end, AllowedOrder allowedOrder) {
         this.beginning = beginning;
         this.end = end;
         this.allowedOrder = allowedOrder;
      }
      
      int getBeginning() {
         return beginning;
      }
      
      int getEnd() {
         return end;
      }
      
      AllowedOrder getAllowedOrder() {
         return allowedOrder;
      }
};

class CustomSession {
      
   public:
      CustomSession::CustomSession() {
         positionsInPeriod = 0;
         limitPeriod = PERIOD_MN1;
         allowToOpen(0);
      }
        
      void addMinuteRange(int beginning, int end, AllowedOrder allowedOrder) {
         ArrayResize(minuteRanges, ArraySize(minuteRanges) + 1); 
         minuteRanges[ArraySize(minuteRanges) - 1] = new Range(beginning, end, allowedOrder);
      }
      
      void addHourRange(int beginning, int end, AllowedOrder allowedOrder) {
         ArrayResize(hourRanges, ArraySize(hourRanges) + 1); 
         hourRanges[ArraySize(hourRanges) - 1] = new Range(beginning, end, allowedOrder);
      }
      
      void addDayOfWeekRange(int beginning, int end, AllowedOrder allowedOrder) {
         ArrayResize(dayRanges, ArraySize(dayRanges) + 1); 
         dayRanges[ArraySize(dayRanges) - 1] = new Range(beginning, end, allowedOrder);
      }
      
      void addMonthRange(int beginning, int end, AllowedOrder allowedOrder) {
         ArrayResize(monthRanges, ArraySize(monthRanges) + 1); 
         monthRanges[ArraySize(monthRanges) - 1] = new Range(beginning, end, allowedOrder);
      }
      
      void refresh() {   
          switch (limitPeriod) {   
            case PERIOD_H1:
               checkNewLimitPeriod(Hour());
               break;
           
            case PERIOD_D1:
               checkNewLimitPeriod(Day());
               break;
           
            case PERIOD_MN1:
               checkNewLimitPeriod(Month());
               
            default:
               Logger::log("Limit period is not supported");
               ExpertRemove();
         }
      }
    
      bool allowToOpen(int positionType) {
         bool isPositionLimitExceeded = isPositionLimitExceeded();
         bool isCustomSessionDayOfWeek = isInSession(dayRanges, DayOfWeek(), positionType);
         bool isCustomSessionHour = isInSession(hourRanges, Hour(), positionType);
         bool isCustomSessionMinute = isInSession(minuteRanges, Minute(), positionType);
         bool isCustomSessionMonth = isInSession(monthRanges, Month(), positionType);

         bool hourExpression = isCustomSessionDayOfWeek && isCustomSessionHour && isCustomSessionMonth;
         bool minuteExpression = isCustomSessionDayOfWeek
          && isCustomSessionHour
          && isCustomSessionMinute
          && isCustomSessionMonth;
         
         switch (Period()) {
            case PERIOD_M1:
               return minuteExpression && !isPositionLimitExceeded;
               
            case PERIOD_M5:
               return minuteExpression && !isPositionLimitExceeded;
            
            case PERIOD_M30:
               return minuteExpression && !isPositionLimitExceeded;
               
            case PERIOD_M15:
               return minuteExpression && !isPositionLimitExceeded;
            
            case PERIOD_H1:
               return hourExpression && !isPositionLimitExceeded;
            
            case PERIOD_H4:
               return hourExpression && !isPositionLimitExceeded;
               
            case PERIOD_D1:
               return isCustomSessionDayOfWeek && isCustomSessionMonth && !isPositionLimitExceeded;
            
            case PERIOD_MN1:
               return isCustomSessionMonth && !isPositionLimitExceeded;
            
            default:
               return false;
         }
      }
      
      void onPositionOpened() {
         positionsInPeriod++;
      }
      
      void setPositionLimit(int limit, int period) {
         if (period < Period()) {
            Logger::log("Position limit period is below current EA period. Please set it equal or larger");
            ExpertRemove();
            return;
         }
         limitPeriod = period;
         positionLimit = limit;
      }
      
      string toJson() {
         CJAVal* json;
         formatAndAddRangeObject(json, minuteRanges, "minute_ranges");
         formatAndAddRangeObject(json, hourRanges, "hour_ranges");
         formatAndAddRangeObject(json, dayRanges, "day_ranges");
         formatAndAddRangeObject(json, monthRanges, "month_ranges");

         CJAVal timeLimit;
         timeLimit["period"] = limitPeriod;
         timeLimit["limit"] = positionLimit;
         json["time_limit"] = timeLimit;
         return json.Serialize();
      }
         
   private:
      Range* minuteRanges[];
      Range* hourRanges[];
      Range* dayRanges[];
      Range* monthRanges[];
      int positionLimit;
      int positionsInPeriod;
      int limitPeriod;
      int lastTimeValue;
      
      bool isPositionLimitExceeded() {
         return positionsInPeriod == positionLimit;
      }

      void formatAndAddRangeObject(CJAVal* jsonToAdd, Range* &rangeList[], string rangePeriod) {
         for (int i = 0;i < ArraySize(minuteRanges); i++) {
            CJAVal range;
            range["from"] = minuteRanges[i].getBeginning();
            range["to"] = minuteRanges[i].getEnd();
            jsonToAdd[rangePeriod].Add(range);
         }
      }
      
      bool isInSession(Range* &rangeList[], int compareTo, int positionType) {
         for (int i = 0; i < ArraySize(rangeList); i++) {
            Range* range = rangeList[i];

            switch (range.getAllowedOrder()) {
               case OPEN_LONG:
                  if (positionType != OP_BUY) continue;
               case OPEN_SHORT:
                  if (positionType != OP_SELL) continue;                  
            }

            if (compareTo >= range.getBeginning() && compareTo < range.getEnd()) {
               return true;
            }
         }
         return false;
      }
      
      void checkNewLimitPeriod(int currentTime) {
         if (lastTimeValue != currentTime) {
            lastTimeValue = currentTime;
            positionsInPeriod = 0;
        }
      }  
};

bool isTokyoOpen()
  {
   return (Hour() >= TokyoOpen && Hour() < TokyoClose);
  }

bool isLondonOpen()
  {
   return (Hour() >= LondonOpen && Hour() < LondonClose);
  }

bool isNewYorkOpen()
  {
   return (Hour() >= NewYorkOpen && Hour() < NewYorkClose);
  }
