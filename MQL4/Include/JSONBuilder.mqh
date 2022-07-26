
#property copyright "Copyright 2022, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property strict

class JSONBuilder {

   private:
      string json;
      int jsonParamCount;
      
   public: 
      JSONBuilder::JSONBuilder(void) {
       json = "{ ";
       jsonParamCount = 0;
       Print("Init first" + jsonParamCount);
      };
      
      JSONBuilder::JSONBuilder(string premade, int previousJsonParamCount) {
       json = premade;
       jsonParamCount = previousJsonParamCount;
      };
      
      JSONBuilder* addInput(string name, string value) {
         json = json + addComa() + name + ": \"" + value + "\"";
         Print(jsonParamCount + " HAHGAHAHA " + jsonParamCount++);
         JSONBuilder* pJson = new JSONBuilder(json, ++jsonParamCount);
         return pJson;
      };
      
      JSONBuilder* addInput(string name, int value) {
         json = json + addComa()+  name + ": " + (string)value ;
         JSONBuilder* pJson = new JSONBuilder(json, ++jsonParamCount);
         return pJson;
      };
      
      JSONBuilder* addInput(string name, float value) {
         json = json + addComa() + name + ": " + (string)value;
         JSONBuilder* pJson = new JSONBuilder(json, ++jsonParamCount);
         return pJson;
      };
      
      
      string addComa() {
         
         if(jsonParamCount > 1) {
            return ", ";
         } else { 
            return "";
         }
      }
      
      string build() {
           return json + " }";
      };
   
};
