
// string baseUrl = "http://80.232.247.208";
string baseUrl = "http://localhost";
int timeout = 3000;
string secret = "ZhaoDingDang!1";

void SendRequest(string httpType, string methodName, string bodyData = "") {
      
      string cookies =  NULL;
      string headers = "Content-Type: application/json\r\n";
      // headers += "Secret: " + secret + "\r\n";
      
      char post[], result[];
    
      string  resultDecoded, resultHeaders;
      
      StringToCharArray(bodyData, post, 0, StringLen(bodyData));

      ResetLastError();

      int resultCode = WebRequest(httpType, baseUrl+methodName, headers, timeout, post, result, resultHeaders);
      if (resultCode == -1) {
         Print( "Error in WebRequest. Error code  =", GetLastError() );
      } else {
          for (int i = 0; i < ArraySize(result); i++ ) {
                 if (( result[i] == 10 ) || ( result[i] == 13)) continue;
                 else resultDecoded += CharToStr( result[i] );
          }
          Print( "DATA:: ", resultDecoded);
          Print( "HDRs:: ", resultHeaders );
       }
}
