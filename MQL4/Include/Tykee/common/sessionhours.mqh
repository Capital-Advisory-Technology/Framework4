
#include <Tykee/common/logger.mqh>

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

/*
  Use this if you want to define custom hours for backtest. 
  Usage is in template.
*/

class CustomSessionHours {
      
   public:
      CustomSessionHours::CustomSessionHours() {}  
      
      void addRange(int beginning, int end) {
         ArrayResize(ranges, ArraySize(ranges) + 1); 
         ranges[ArraySize(ranges) - 1] = new Range(beginning, end);
      }
      
      bool isCustomSessionHour() {
         int hour = Hour();
         for (int i = 0; i < ArraySize(ranges); i++) {
            Range* range = ranges[i];
            if (hour >= range.getBeginning() && hour <= range.getEnd()) {
               return true;
            }
         }
         return false;
      }
      
   private:
      Range* ranges[];
      
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
