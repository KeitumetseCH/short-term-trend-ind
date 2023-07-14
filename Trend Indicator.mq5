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

input bool activateHTT = false; //Activate Higher Timeframe Monitoring
input ENUM_TIMEFRAMES Timeframe = PERIOD_H4; //Higher Timeframe Trend

input color longColour = C'0,170,0'; //Long Colour
input color shortColour = C'255,0,0'; //Short Colour

color undecided = C'245,90,16'; //EMA crossover colour

//VOID INITIALISATION
int OnInit(){
   PrintIndictor("IndicatorPanel", 30, 30, 27, 26, 3); // initialise indicator graphic
   PrintIndictor("Arrow", 21, 21, 9, 9, 1);
   
   if(activateHTT){
      PrintIndictor("IndicatorPanelHT", 69, 30, 27, 26, 3); // initialise indicator graphic
      PrintIndictor("ArrowHT", 60, 21, 9, 9, 1);
      PrintIndictor("CandleLower", 40, 17, 8, 13, 1);
      PrintIndictor("CandleUpper", 40, 30, 8, 13, 1);
   }else{
      ObjectDelete(0, "IndicatorPanelHT"); // delete indicator graphic from chart
      ObjectDelete(0, "ArrowHT"); // delete indicator graphic from chart
      ObjectDelete(0, "CandleLower"); // delete indicator graphic from chart
      ObjectDelete(0, "CandleUpper"); // delete indicator graphic from chart
   }
   return(INIT_SUCCEEDED);
}
//VOID START
int OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],const double &open[],const double &high[],const double &low[],const double &close[],const long &tick_volume[],const long &volume[],const int &spread[]){
   calculateTrend(PERIOD_CURRENT, "IndicatorPanel", "Arrow"); // calculate trend for current timeframe
   if(activateHTT){
      calculateTrend(Timeframe, "IndicatorPanelHT", "ArrowHT"); // calculate trend for higher timeframe
      calculateCandle(); // calculate direction of the current higher timeframe candle
   }
   
   return(rates_total);
}
//-----------------------------------------------------------------------------
void deinit(){
   ObjectDelete(0, "IndicatorPanel"); // delete indicator graphic from chart
   ObjectDelete(0, "Arrow"); // delete indicator graphic from chart
   ObjectDelete(0, "IndicatorPanelHT"); // delete indicator graphic from chart
   ObjectDelete(0, "ArrowHT"); // delete indicator graphic from chart
   ObjectDelete(0, "CandleLower"); // delete indicator graphic from chart
   ObjectDelete(0, "CandleUpper"); // delete indicator graphic from chart
}
//-----------------------------------------------------------------------------
void calculateTrend(ENUM_TIMEFRAMES timeF, string rsiEma, string emaBid){
   double ema10 = MovingAverageValue(timeF, 10);
   double ema20 = MovingAverageValue(timeF, 20);
   double ema50 = MovingAverageValue(timeF, 50);
   double rsi = RsiValue(timeF, 14);
   double Bid = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits); // declaring variable to store the Bid price
   
   if(rsi > 50){
      //Buy
      ChangeColour(longColour, 1, rsiEma);
   }else{
      //Sell
      ChangeColour(shortColour, 1, rsiEma);
   }
   
   if(Bid > ema50){
      //Buy
      ChangeColour(longColour, 3, emaBid);
   }else{
      //Sell
      ChangeColour(shortColour, 3, emaBid);
   }
   
   if(ema10 > ema20 && ema20 > ema50){
      //Buy
      ChangeColour(longColour, 2, rsiEma);
   }else if(ema10 < ema20 && ema20 < ema50){
      //Sell
      ChangeColour(shortColour, 2, rsiEma);
   }else{
      //10 EMA and 20 EMA crossover
      ChangeColour(undecided, 2, rsiEma);
   }
}
void calculateCandle(){
   double bid = NormalizeDouble(SymbolInfoDouble(_Symbol,SYMBOL_BID),_Digits); // declaring a variable to store the Bid price
   double openPrice = iOpen(_Symbol,Timeframe,0); // declaring a variable to store the candle open price
   double priceHigh = iHigh(_Symbol,Timeframe,0); // declaring a variable to store the candle high price
   double priceLow = iLow(_Symbol,Timeframe,0); // declaring a variable to store the candle low price
   bool bullBear; // declaring a variable to store the bull/bear flag
   double topWick, bottomWick, candleSize; // declaring variables to store the sizes of the top wick, bottom wick and the candle size
   
   // determine higher timeframe candle direction and show it
   if(bid > openPrice){
      ChangeColour(longColour, 3, "CandleUpper"); // change indicator colour to the long colour
      bullBear = true;
   }else{
      ChangeColour(shortColour, 3, "CandleUpper"); // change indicator colour to the short colour
      bullBear = false;
   }
   
   topWick = priceHigh - openPrice; // determine size of the top wick
   bottomWick =  openPrice - priceLow; // determine size of the bottom wick
   candleSize = openPrice - bid; // determine size of the candle
   candleSize = fabs(candleSize); // turning candle size into a positive number
   
   if(bullBear){
      topWick = priceHigh - bid; // determine the current size of the top wick
      if(candleSize < topWick){ // change colour of the indicator if the body of the candle is smaller than the top wick
         ChangeColour(undecided, 3, "CandleLower");
      }else{
         ChangeColour(longColour, 3, "CandleLower");
      }
   }else{
      bottomWick =  bid - priceLow; // determine the current size of the bottom wick
      if(candleSize < bottomWick){ // change colour of the indicator if the body of the candle is smaller than the bottom wick
         ChangeColour(undecided, 3, "CandleLower");
      }else{
         ChangeColour(shortColour, 3, "CandleLower");
      }
   }
}
double MovingAverageValue(ENUM_TIMEFRAMES timeF, int period){
   double myMovingAverageArray[]; // declaring MA array
   
   int ema = iMA(NULL, timeF, period, 0, MODE_EMA, PRICE_CLOSE); // declaring MA variable for settings
   ArraySetAsSeries(myMovingAverageArray,true);
   CopyBuffer(ema,0,0,3,myMovingAverageArray); // setting the MA value calculator
   
   return myMovingAverageArray[0];
}
double RsiValue(ENUM_TIMEFRAMES timeF, int period){
   double myRsiArray[]; // declaring RSI array
   
   int rsiValue = iRSI(NULL, timeF, period, PRICE_CLOSE); // declaring RSI variable for settings
   ArraySetAsSeries(myRsiArray,true);
   CopyBuffer(rsiValue,0,0,1,myRsiArray); // setting the RSI value calculator
   double rsi = NormalizeDouble(myRsiArray[0],2); // simplying the current RSI value to two decimal places
   
   return rsi;
}
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

void ChangeColour(color tempColour, int sectionChoice, string objName){
   switch(sectionChoice){
      case 1: // change RSI section colour
         ObjectSetInteger(0,objName,OBJPROP_COLOR,tempColour);
      break;
      
      case 2: // change EMA crossover section colour
         ObjectSetInteger(0,objName,OBJPROP_BGCOLOR,tempColour); 
      break;
      
      case 3: // change 50 EMA and Bid crossover section colour
         ObjectSetInteger(0,objName,OBJPROP_COLOR,tempColour);
         ObjectSetInteger(0,objName,OBJPROP_BGCOLOR,tempColour);
      break;
   }
}
