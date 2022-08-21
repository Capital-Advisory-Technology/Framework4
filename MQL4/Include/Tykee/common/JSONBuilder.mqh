
class JSONBuilder {

   private:
      string json;
      int jsonParamCount;
      
   public: 
      JSONBuilder::JSONBuilder(void) {
       json = "{ ";
       jsonParamCount = 0;
      };
      
      JSONBuilder::JSONBuilder(string premade, int previousJsonParamCount) {
       json = premade;
       jsonParamCount = previousJsonParamCount;
      };
      
      JSONBuilder* addInput(string key, string value) {
         json = json + addComa() + key + ": \"" + value + "\"";
         JSONBuilder* pJson = new JSONBuilder(json, ++jsonParamCount);
         return pJson;
      };
      
      JSONBuilder* addInput(string key, int value) {
         json = json + addComa()+  key + ": " + (string)value ;
         JSONBuilder* pJson = new JSONBuilder(json, ++jsonParamCount);
         return pJson;
      };
      
      JSONBuilder* addInput(string key, float value) {
         json = json + addComa() + key + ": " + (string)value;
         JSONBuilder* pJson = new JSONBuilder(json, ++jsonParamCount);
         return pJson;
      };
      
       JSONBuilder* addInput(string key, double value) {
         json = json + addComa() + key + ": " + (string)value;
         JSONBuilder* pJson = new JSONBuilder(json, ++jsonParamCount);
         return pJson;
      };
      
      string addComa() {
         if(jsonParamCount > 0) {
            return ", ";
         } else { 
            return "";
         }
      };
      
      string build() {
           return json + " }";
      };
   
};
