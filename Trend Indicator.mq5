//+------------------------------------------------------------------+
//|                                              Trend Indicator.mq5 |
//|                                                     KeitumetseCH |
//|                          https://keitumetse.ternitidigital.co.za |
//+------------------------------------------------------------------+
#property copyright ""
#property link      ""
#property version   ""
#property strict
#property indicator_chart_window

input color longColour = C'0,170,0'; //Long Colour
input color shortColour = C'255,0,0'; //Short Colour

color undecided = C'245,90,16'; //EMA crossover colour

//VOID INITIALISATION
int OnInit(){
   PrintIndictor("IndicatorPanel", 30, 30, 27, 26, 3); // initialise indicator graphic
   PrintIndictor("Arrow", 21, 21, 9, 9, 1);
   
   return(INIT_SUCCEEDED);
}
//VOID START
int OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],const double &open[],const double &high[],const double &low[],const double &close[],const long &tick_volume[],const long &volume[],const int &spread[]){

   double myRsiArray[], myMovingAverageArray10[], myMovingAverageArray20[], myMovingAverageArray50[];
   
   int rsiValue = iRSI(NULL, 0, 14, PRICE_CLOSE); // declaring RSI variable for settings
   int ema10 = iMA(NULL, 0, 10, 0, MODE_EMA, PRICE_CLOSE); // declaring MA variable for settings
   int ema20 = iMA(NULL, 0, 20, 0, MODE_EMA, PRICE_CLOSE); // declaring MA variable for settings
   int ema50 = iMA(NULL, 0, 50, 0, MODE_EMA, PRICE_CLOSE); // declaring MA variable for settings
   double Bid = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits); // declaring variable to store the Bid price
   
   ArraySetAsSeries(myRsiArray,true);
   ArraySetAsSeries(myMovingAverageArray10,true);
   ArraySetAsSeries(myMovingAverageArray20,true);
   ArraySetAsSeries(myMovingAverageArray50,true);
   
   CopyBuffer(rsiValue,0,0,1,myRsiArray); // setting the RSI value calculator
   CopyBuffer(ema10,0,0,3,myMovingAverageArray10); // setting the MA value calculator
   CopyBuffer(ema20,0,0,3,myMovingAverageArray20); // setting the MA value calculator
   CopyBuffer(ema50,0,0,3,myMovingAverageArray50); // setting the MA value calculator
   
   double rsi = NormalizeDouble(myRsiArray[0],2); // simplying the current RSI value to two decimal places
   
   if(rsi > 50){
      //Buy
      ChangeColour(longColour, 1);
   }else{
      //Sell
      ChangeColour(shortColour, 1);
   }
   
   if(Bid > myMovingAverageArray50[0]){
      //Buy
      ChangeColour(longColour, 3);
   }else{
      //Sell
      ChangeColour(shortColour, 3);
   }
   
   if(myMovingAverageArray10[0] > myMovingAverageArray20[0] && myMovingAverageArray20[0] > myMovingAverageArray50[0]){
      //Buy
      ChangeColour(longColour, 2);
   }else if(myMovingAverageArray10[0] < myMovingAverageArray20[0] && myMovingAverageArray20[0] < myMovingAverageArray50[0]){
      //Sell
      ChangeColour(shortColour, 2);
   }else{
      //10 EMA and 20 EMA crossover
      ChangeColour(undecided, 2);
   }
   
   return(rates_total);
}
//-----------------------------------------------------------------------------
void deinit(){
   ObjectDelete(0, "IndicatorPanel"); // delete indicator graphic from chart
   ObjectDelete(0, "Arrow"); // delete indicator graphic from chart
}
//-----------------------------------------------------------------------------
void PrintIndictor(string objName, int objXDis, int objYDis, int objXSiz, int objYSiz, int objBorderWidth){

   ObjectCreate(0,objName,OBJ_RECTANGLE_LABEL,0,0,0);
   ObjectSetInteger(0,objName,OBJPROP_XDISTANCE,objXDis);
   ObjectSetInteger(0,objName,OBJPROP_YDISTANCE,objYDis);
   ObjectSetInteger(0,objName,OBJPROP_XSIZE,objXSiz);
   ObjectSetInteger(0,objName,OBJPROP_YSIZE,objYSiz);
   ObjectSetInteger(0,objName,OBJPROP_BGCOLOR,longColour);
   ObjectSetInteger(0,objName,OBJPROP_BORDER_TYPE,BORDER_FLAT);
   ObjectSetInteger(0,objName,OBJPROP_CORNER,CORNER_RIGHT_LOWER);
   ObjectSetInteger(0,objName,OBJPROP_COLOR,longColour);
   ObjectSetInteger(0,objName,OBJPROP_STYLE,STYLE_SOLID);
   ObjectSetInteger(0,objName,OBJPROP_WIDTH,objBorderWidth);
   ObjectSetInteger(0,objName,OBJPROP_BACK,false); 
   ObjectSetInteger(0,objName,OBJPROP_SELECTABLE,false); 
   ObjectSetInteger(0,objName,OBJPROP_SELECTED,false); 
   ObjectSetInteger(0,objName,OBJPROP_HIDDEN,true); 
   ObjectSetInteger(0,objName,OBJPROP_ZORDER,0);
}

void ChangeColour(color tempColour, int sectionChoice){
   switch(sectionChoice){
      case 1: // change RSI section colour
         ObjectSetInteger(0,"IndicatorPanel",OBJPROP_COLOR,tempColour);
      break;
      
      case 2: // change EMA crossover section colour
         ObjectSetInteger(0,"IndicatorPanel",OBJPROP_BGCOLOR,tempColour); 
      break;
      
      case 3: // change 50 EMA and Bid crossover section colour
         ObjectSetInteger(0,"Arrow",OBJPROP_BGCOLOR,tempColour);
         ObjectSetInteger(0,"Arrow",OBJPROP_COLOR,tempColour);
      break;
   }
}
