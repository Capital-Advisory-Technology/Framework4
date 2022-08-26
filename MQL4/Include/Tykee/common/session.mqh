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
      CustomSession::CustomSession() {}
        
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
      
      bool isTimeInCustomSession() {
         bool minuteExpression = isCustomSessionDayOfWeek() && isCustomSessionHour() && isCustomSessionMinute() && isCustomSessionMonth();
         switch (Period()) {
            case PERIOD_M1:
               return minuteExpression;
               
            case PERIOD_M5:
               return minuteExpression;
            
            case PERIOD_M30:
               return minuteExpression;
               
            case PERIOD_M15:
               return minuteExpression;
            
            case PERIOD_H4:
               return isCustomSessionDayOfWeek() && isCustomSessionHour() && isCustomSessionMonth();
               
            case PERIOD_D1:
               return isCustomSessionDayOfWeek() && isCustomSessionMonth();
            default:
               return false;
         }
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
        return json.Serialize();
      }
         
   private:
      Range* minuteRanges[];
      Range* hourRanges[];
      Range* dayRanges[];
      Range* monthRanges[];
      
       bool isCustomSessionMinute() {
         int minute = Minute();
         for (int i = 0; i < ArraySize(minuteRanges); i++) {
            Range* range = minuteRanges[i];
            if (minute >= range.getBeginning() && minute <= range.getEnd()) {
               return true;
            }
         }
         return false;
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
