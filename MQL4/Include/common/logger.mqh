
class Logger {
   public:
      static bool isDebug;
      
      Logger(void){};
     ~Logger(void){};
   
   
   static void log(string msg) {
      if (isDebug) Print(msg);
   }

};

bool Logger::isDebug = false;