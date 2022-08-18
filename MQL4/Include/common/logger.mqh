
class Logger {
   public:
      static bool isDebug;
   
   static void log(string msg) {
      if (isDebug) Print(msg);
   }

};

bool Logger::isDebug = false;