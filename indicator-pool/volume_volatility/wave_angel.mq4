//+------------------------------------------------------------------+
//| A WolfWave finder based on ZIGZAG.MQ4                            |
//| fukinagashi a t gmx p o i n t net                                              |
//+------------------------------------------------------------------+

#property indicator_chart_window
#property indicator_buffers 1
#property indicator_color1 Blue
#define MaxAnalyze 200
#define UpperDistance 15
#define LowerDistance 5
#define Title "WW"

//---- indicator parameters
extern int ExtDepth=12;
extern int ExtDeviation=5;
extern int ExtBackstep=3;

//---- indicator buffers
double ExtMapBuffer[];
double ExtMapBuffer2[];

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int init()
  {
   IndicatorBuffers(2);
//---- drawing settings

   SetIndexStyle(0,DRAW_SECTION);
//---- indicator buffers mapping
   SetIndexBuffer(0,ExtMapBuffer);
   SetIndexBuffer(1,ExtMapBuffer2);
     
   SetIndexEmptyValue(0,0.0);

   ArraySetAsSeries(ExtMapBuffer,true);
   ArraySetAsSeries(ExtMapBuffer2,true);
//---- indicator short name
   IndicatorShortName("WolfWave");
//---- initialization done

   return(0);
  }
  
int deinit()
{
      for (int i=1;i<=5;i++) {
         ObjectDelete(Title + ""+i);
      }
   
      ObjectDelete(Title + "Line-2-4");   
      ObjectDelete(Title + "Line-1-3");
      ObjectDelete(Title + "Line-1-4");
      }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int start()
  {
   int    shift, back,lasthighpos,lastlowpos;
   double val,res;
   double curlow,curhigh,lasthigh,lastlow;
   int num=0;

   int Peak[MaxAnalyze],h,i,j;
   int Wolf[6];
   string WolfWave="None";
   double Winkel1, Winkel2;
   bool found=false;
   
   for(shift=Bars-ExtDepth; shift>=0; shift--)
     {
      val=Low[Lowest(NULL,0,MODE_LOW,ExtDepth,shift)];
      if(val==lastlow) val=0.0;
      else 
        { 
         lastlow=val; 
         if((Low[shift]-val)>(ExtDeviation*_Point)) val=0.0;
         else
           {
            for(back=1; back<=ExtBackstep; back++)
              {
               res=ExtMapBuffer[shift+back];
               if((res!=0)&&(res>val)) ExtMapBuffer[shift+back]=0.0; 
              }
           }
        } 
      ExtMapBuffer[shift]=val;
      //--- high
      val=High[Highest(NULL,0,MODE_HIGH,ExtDepth,shift)];
      if(val==lasthigh) val=0.0;
      else 
        {
         lasthigh=val;
         if((val-High[shift])>(ExtDeviation*_Point)) val=0.0;
         else
           {
            for(back=1; back<=ExtBackstep; back++)
              {
               res=ExtMapBuffer2[shift+back];
               if((res!=0)&&(res<val)) ExtMapBuffer2[shift+back]=0.0; 
              } 
           }
        }
      ExtMapBuffer2[shift]=val;
     }

   // final cutting 
   lasthigh=-1; lasthighpos=-1;
   lastlow=-1;  lastlowpos=-1;

   for(shift=Bars-ExtDepth; shift>=0; shift--)
     {
      curlow=ExtMapBuffer[shift];
      curhigh=ExtMapBuffer2[shift];
      if((curlow==0)&&(curhigh==0)) continue;
      //---
      if(curhigh!=0)
        {
         if(lasthigh>0) 
           {
            if(lasthigh<curhigh) ExtMapBuffer2[lasthighpos]=0;
            else ExtMapBuffer2[shift]=0;
           }
         //---
         if(lasthigh<curhigh || lasthigh<0)
           {
            lasthigh=curhigh;
            lasthighpos=shift;
           }
         lastlow=-1;
        }
      //----
      if(curlow!=0)
        {
         if(lastlow>0)
           {
            if(lastlow>curlow) ExtMapBuffer[lastlowpos]=0;
            else ExtMapBuffer[shift]=0;
           }
         //---
         if((curlow<lastlow)||(lastlow<0))
           {
            lastlow=curlow;
            lastlowpos=shift;
           }
         lasthigh=-1;
        }
     }
  
   for(shift=Bars-1; shift>=0; shift--)
     {
      if(shift>=Bars-ExtDepth) ExtMapBuffer[shift]=0.0;
      else
        {
         res=ExtMapBuffer2[shift];
         //if(res!=0.0) ExtMapBuffer[shift]=res;
         if(res>0.0) ExtMapBuffer[shift]=res;         
        }
     }
     
// Basic Modification ==>

	i=0;
   for(h=0; h<Bars && i<MaxAnalyze; h++)
   {
      if ((ExtMapBuffer[h]!=0) || (ExtMapBuffer2[h]!=0)) {
         Peak[i]= h;
         i++;    
      }
   }
   
   for(j=0;j<i && j<MaxAnalyze && found==false;j++) {
      Wolf[1]=Peak[j+4]; // 1 High
      Wolf[2]=Peak[j+3]; // 2 Low
      Wolf[3]=Peak[j+2]; // 3 High 
      Wolf[4]=Peak[j+1]; // 4 Low 
      Wolf[5]=Peak[j+0]; // 5 High
      if (     // Buy Wolfwave
         Low[Wolf[1]]<High[Wolf[2]] &&  // 1. + 3.a.
         Low[Wolf[3]]<Low[Wolf[1]] &&   // 2. + 3.b. 
         Low[Wolf[3]]<High[Wolf[4]]  // 4
         ) {
            WolfWave="Buy";
      } else if 
         (     // Sell Wolfwave
         High[Wolf[1]]>Low[Wolf[2]] &&  // 1. + 3.a.
         High[Wolf[3]]>High[Wolf[1]] &&   // 2. + 3.b. 
         High[Wolf[3]]>Low[Wolf[4]]  // 4
         ) {
            WolfWave="Sell";
         } else {
            WolfWave="Not";
      }
      
      if(WolfWave=="Buy") {
        	ObjectCreate(Title + "Line-1-3", OBJ_TREND, 0, Time[Wolf[1]],Low[Wolf[1]], Time[Wolf[3]],Low[Wolf[3]] );
        	if (ObjectGetValueByShift(Title + "Line-1-3", Wolf[5]) >= Low[Wolf[5]]) {
           	ObjectCreate(Title + "1", OBJ_TEXT, 0, Time[Wolf[1]],Low[Wolf[1]]-LowerDistance*_Point );
           	ObjectSetText(Title + "1", ""+DoubleToStr(1,0), 10, "Arial", Blue);
           	ObjectCreate(Title + "2", OBJ_TEXT, 0, Time[Wolf[2]],High[Wolf[2]]+UpperDistance*_Point );
           	ObjectSetText(Title + "2", ""+DoubleToStr(2,0), 10, "Arial", Blue);
           	ObjectCreate(Title + "3", OBJ_TEXT, 0, Time[Wolf[3]],Low[Wolf[3]]-LowerDistance*_Point );
           	ObjectSetText(Title + "3", ""+DoubleToStr(3,0), 10, "Arial", Blue);
           	ObjectCreate(Title + "4", OBJ_TEXT, 0, Time[Wolf[4]],High[Wolf[4]]+UpperDistance*_Point );
           	ObjectSetText(Title + "4", ""+DoubleToStr(4,0), 10, "Arial", Blue);
           	ObjectCreate(Title + "5", OBJ_TEXT, 0, Time[Wolf[5]],Low[Wolf[5]]-LowerDistance*_Point );
           	ObjectSetText(Title + "5", ""+DoubleToStr(5,0), 10, "Arial", Blue);
           	ObjectCreate(Title + "Line-1-4", OBJ_TREND, 0, Time[Wolf[1]],Low[Wolf[1]], Time[Wolf[4]],High[Wolf[4]] );
           	ObjectSet(Title + "Line-1-4", OBJPROP_COLOR, Black);
          	ObjectSet(Title + "Line-1-4", OBJPROP_WIDTH, 2);
           	Comment("Buy Wolfwave (" + TimeToStr(Time[Wolf[5]],TIME_DATE|TIME_MINUTES) + ") at " + (ObjectGetValueByShift("Line-1-3", Wolf[5])-5*_Point) + " SL " + High[Wolf[5]]);
          	// found=true;
         } else {
            ObjectDelete(Title + "Line-1-3");
         }
      } else if (WolfWave=="Sell") {
         ObjectCreate(Title + "Line-1-3", OBJ_TREND, 0, Time[Wolf[1]],High[Wolf[1]], Time[Wolf[3]],High[Wolf[3]] );
         if ( ObjectGetValueByShift(Title + "Line-1-3", Wolf[5]) <= High[Wolf[5]] ) {
           	ObjectCreate(Title + "1", OBJ_TEXT, 0, Time[Wolf[1]],High[Wolf[1]]+UpperDistance*_Point );
            ObjectSetText(Title + "1", ""+DoubleToStr(1,0), 10, "Arial", Blue);
            ObjectCreate(Title + "2", OBJ_TEXT, 0, Time[Wolf[2]],Low[Wolf[2]]-LowerDistance*_Point );
            ObjectSetText(Title + "2", ""+DoubleToStr(2,0), 10, "Arial", Blue);
            ObjectCreate(Title + "3", OBJ_TEXT, 0, Time[Wolf[3]],High[Wolf[3]]+UpperDistance*_Point );
            ObjectSetText(Title + "3", ""+DoubleToStr(3,0), 10, "Arial", Blue);
            ObjectCreate(Title + "4", OBJ_TEXT, 0, Time[Wolf[4]],Low[Wolf[4]]-LowerDistance*_Point );
            ObjectSetText(Title + "4", ""+DoubleToStr(4,0), 10, "Arial", Blue);
            ObjectCreate(Title + "5", OBJ_TEXT, 0, Time[Wolf[5]],High[Wolf[5]]+UpperDistance*_Point );
            ObjectSetText(Title + "5", ""+DoubleToStr(5,0), 10, "Arial", Blue);
            ObjectCreate(Title + "Line-1-4", OBJ_TREND, 0, Time[Wolf[1]],High[Wolf[1]], Time[Wolf[4]],Low[Wolf[4]] );
            ObjectSet(Title + "Line-1-4", OBJPROP_COLOR, Black);
            ObjectSet(Title + "Line-1-4", OBJPROP_WIDTH, 2);
           	Comment("Sell Wolfwave (" + TimeToStr(Time[Wolf[5]],TIME_DATE|TIME_MINUTES) + ") at " + (ObjectGetValueByShift("Line-1-3", Wolf[5])-5*_Point) + " SL " + High[Wolf[5]]);
            // found=true;
         } else {
           	ObjectDelete(Title + "Line-1-3");
         }
      } 
   }
}