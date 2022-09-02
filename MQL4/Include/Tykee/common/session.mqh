#include <Tykee/common/logger.mqh>
#include <Tykee/common/JSONBuilder.mqh>
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

 public:
      Range::Range(int beginning, int end) {
         this.beginning = beginning;
         this.end = end;
      }
      
      int getBeginning() {
         return beginning;
      }
      
      int getEnd() {
         return end;
      }
};

class CustomSession {
      
   public:
      CustomSession::CustomSession() {
         positionsInPeriod = 0;
         limitPeriod = PERIOD_MN1;
         allowToOpen();
      }
        
      void addMinuteRange(int beginning, int end) {
         ArrayResize(minuteRanges, ArraySize(minuteRanges) + 1); 
         minuteRanges[ArraySize(minuteRanges) - 1] = new Range(beginning, end);
      }
      
      void addHourRange(int beginning, int end) {
         ArrayResize(hourRanges, ArraySize(hourRanges) + 1); 
         hourRanges[ArraySize(hourRanges) - 1] = new Range(beginning, end);
      }
      
      void addDayOfWeekRange(int beginning, int end) {
         ArrayResize(dayRanges, ArraySize(dayRanges) + 1); 
         dayRanges[ArraySize(dayRanges) - 1] = new Range(beginning, end);
      }
      
      void addMonthRange(int beginning, int end) {
         ArrayResize(monthRanges, ArraySize(monthRanges) + 1); 
         monthRanges[ArraySize(monthRanges) - 1] = new Range(beginning, end);
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
    
      bool allowToOpen() {
         bool hourExpression = isCustomSessionDayOfWeek() && isCustomSessionHour() && isCustomSessionMonth();
         bool minuteExpression = isCustomSessionDayOfWeek()
          && isCustomSessionHour()
          && isCustomSessionMinute()
          && isCustomSessionMonth();
         
         switch (Period()) {
            case PERIOD_M1:
               return minuteExpression && !isPositionLimitExceeded();
               
            case PERIOD_M5:
               return minuteExpression && !isPositionLimitExceeded();
            
            case PERIOD_M30:
               return minuteExpression && !isPositionLimitExceeded();
               
            case PERIOD_M15:
               return minuteExpression && !isPositionLimitExceeded();
            
            case PERIOD_H1:
               return hourExpression && !isPositionLimitExceeded();
            
            case PERIOD_H4:
               return hourExpression && !isPositionLimitExceeded();
               
            case PERIOD_D1:
               return isCustomSessionDayOfWeek() && isCustomSessionMonth() && !isPositionLimitExceeded();
            
            case PERIOD_MN1:
               return isCustomSessionMonth() && !isPositionLimitExceeded();
            
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
         CJAVal json;
           
         for (int i = 0;i < ArraySize(minuteRanges); i++) {
            CJAVal range;
            range["from"] = minuteRanges[i].getBeginning();
            range["to"] = minuteRanges[i].getEnd();
            json["minute_ranges"].Add(range);
        }
        
         for (int i = 0;i < ArraySize(hourRanges); i++) {
            CJAVal range;
            range["from"] = hourRanges[i].getBeginning();
            range["to"] = hourRanges[i].getEnd();
            json["hour_ranges"].Add(range);
        }
        
         for (int i = 0;i < ArraySize(dayRanges); i++) {
            CJAVal range;
            range["from"] = dayRanges[i].getBeginning();
            range["to"] = dayRanges[i].getEnd();
            json["day_ranges"].Add(range);
        }
        
         for (int i = 0;i < ArraySize(monthRanges); i++) {
            CJAVal range;
            range["from"] = monthRanges[i].getBeginning();
            range["to"] = monthRanges[i].getEnd();
            json["month_ranges"].Add(range);
        }
        
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
      
      
      bool isCustomSessionMinute() {
         int minute = Minute();
         for (int i = 0; i < ArraySize(minuteRanges); i++) {
            Range* range = minuteRanges[i];
            if (minute >= range.getBeginning() && minute < range.getEnd()) {
               return true;
            }
         }
         return false;
      }
      
      bool isPositionLimitExceeded() {
         return positionsInPeriod == positionLimit;
      }
      
       bool isCustomSessionHour() {
         int hour = Hour();
         for (int i = 0; i < ArraySize(hourRanges); i++) {
            Range* range = hourRanges[i];
            if (hour >= range.getBeginning() && hour <= range.getEnd()) {
               return true;
            }
         }
         return false;
      }
      
       bool isCustomSessionDayOfWeek() {
         int day = DayOfWeek();
         for (int i = 0; i < ArraySize(dayRanges); i++) {
            Range* range = dayRanges[i];
            if (day >= range.getBeginning() && day <= range.getEnd()) {
               return true;
            }
         }
         return false;
      }
      
      bool isCustomSessionMonth() {
         int month = Month();
         for (int i = 0; i < ArraySize(monthRanges); i++) {
            Range* range = monthRanges[i];
            if (month >= range.getBeginning() && month <= range.getEnd()) {
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
