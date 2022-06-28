//+------------------------------------------------------------------+
//|                                                                  |
//|                                     Copyright © 2022, Eqan Ahmad |
//|                                     https://fiverr.com/eqanahmad |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2022, Eqan Ahmad"
#property link      "https://fiverr.com/eqanahmad"
#property version   "1.00"
#property strict

enum settings
  {
   settings = 0,                                  //======= Settings =======
  };
input settings gs = 0;                                  // ===== General =====
input double LotSize = 0.10;                            // LotSize
input int slippage = 5;                                 // Slippage
input int magicNumber = 20220108;                       // Magic Number
input double TakeProfit = 35;                           // Take Profit (Pips)
input double StopLoss = 10;                             // Stop Loss (Pips)

input settings BuyStopSetup = 0;                        // ===== Buy_Stop Setup =====
input int BuyStopStopLoss = 15;                         // BuyStopStopLoss
input int BuyStopTakeProfit = 40;                       // BuyStopTakeProfit
input int BuyStopPip = 5;                               // BuyStopPip

input settings SellStopSetup = 0;                       // ===== Sell_Stop Setup =====
input int SellStopStopLoss = 15;                        // SellStopStopLoss
input int SellStopTakeProfit = 40;                      // SellStopTakeProfit
input int SellStopPip = 5;                              // SellStopPip

input settings BuyLimitSetup = 0;                       // ===== Buy_Limit Setup =====
input int BuyLimitStopLoss = 15;                        // BuyLimitStopLoss
input int BuyLimitTakeProfit = 40;                      // BuyLimitTakeProfit
input int BuyLimitPip = 5;                              // BuyLimitPip

input settings SellLimitSetup = 0;                      // ===== Sell_Limit Setup =====
input int SellLimitStopLoss = 15;                       // SellLimitStopLoss
input int SellLimitTakeProfit = 40;                     // SellLimitTakeProfit
input int SellLimitPip = 5;                             // SellLimitPip

input settings STS = 0;                                 // ===== Save Trade Setup =====
input int SaveTradeStopLoss = 15;                       // SaveTradeStopLoss
input int SaveTradeTakeProfit = 40;                     // SaveTradeTakeProfit
input double SaveTradeLotSize = 0.5;                    // SaveTradeLotSize
input int SaveTradePip = 5;                             // SaveTradePip
input int ExpirationCandles = 6;                        // Expiration Candles

input settings FMA1 = 0;                                // ===== EMA Cross Over Start =====
input int fma1_Period = 10;                             // FMA Period
input int sma1_Period = 20;                             // SMA Period

input settings FMA2 = 0;                                // ===== EMA Cross Over Stop =====
input int fma2_Period = 5;                              // FMA Period
input int sma2_Period = 10;                             // SMA Period

datetime current;
bool emaCrossStartToggle = False;
bool emaCrossEndToggle = False;
bool emaSaveBuyTradeToggle = False;
bool emaSaveSellTradeToggle = False;
bool emaStartBuyTradeExpireToggle = False;
bool emaStartSellTradeExpireToggle = False;
color emaStartButtonColor = clrGreen;
color emaEndButtonColor = clrRed;
double pip = Point,stopLevel,lotSize, takeProfit = TakeProfit, stopLoss = StopLoss, buyUserDefinedPip, sellUserDefinedPip;
int totalBuy = 0,totalSell = 0, candlesAfterBuyTrade = 0, candlesAfterSellTrade = 0;
string dir="";
int rightEdge, position;

//+------------------------------------------------------------------+
//| Create Button                                                    |
//+------------------------------------------------------------------+
void createButton(string buttonName, string name,
                  int xDis, int yDis,
                  int xWidth, int yHeight,
                  int fontSize, bool read_only,
                  color bgColor, color foreColor
                 )

  {
   long typeChart = 0;
   ObjectCreate
   (
      typeChart,       // Current Chart
      buttonName,    // Object Name
      OBJ_BUTTON,    // Object Type
      0,             // In main window
      0,             // No date time
      0              // No price
   );
// Set distance from border
   ObjectSetInteger(typeChart, buttonName, OBJPROP_XDISTANCE, xDis);
// Set distance from border
   ObjectSetInteger(typeChart, buttonName, OBJPROP_YDISTANCE, yDis);
// Set width
   ObjectSetInteger(typeChart, buttonName, OBJPROP_XSIZE, xWidth);
// Set height
   ObjectSetInteger(typeChart, buttonName, OBJPROP_YSIZE, yHeight);
// Font Size
   ObjectSetInteger(typeChart, buttonName, OBJPROP_FONTSIZE,fontSize);
// Set Text Color
   ObjectSetInteger(typeChart, buttonName, OBJPROP_COLOR, foreColor);
// Set Background Color
   ObjectSetInteger(typeChart, buttonName, OBJPROP_BGCOLOR, bgColor);
// Set Name
   ObjectSetString(typeChart,  buttonName, OBJPROP_TEXT, name);
// Set Name
   ObjectSetString(typeChart,  buttonName, OBJPROP_FONT, "Calibri Bold");
// Disable the "Chart on foreground" tickbox
   ChartSetInteger(typeChart, CHART_FOREGROUND,0,false);
//--- enable (true) or cancel (false) read-only mode
   ObjectSetInteger(typeChart, name,OBJPROP_READONLY,read_only);

  }
//+------------------------------------------------------------------+
//| Create Object Text Function                                      |
//+------------------------------------------------------------------+
void createTextBox(string buttonName, string name,
                   int xDis, int yDis,
                   int xWidth, int yHeight,
                   int fontSize,
                   color bgColor, color foreColor)
  {
   long typeChart = 0;
   ObjectCreate
   (
      typeChart,       // Current Chart
      buttonName,    // Object Name
      OBJ_EDIT,    // Object Type
      0,             // In main window
      0,             // No date time
      0              // No price
   );
// Set distance from border
   ObjectSetInteger(typeChart, buttonName, OBJPROP_XDISTANCE, xDis);
// Set distance from border
   ObjectSetInteger(typeChart, buttonName, OBJPROP_YDISTANCE, yDis);
// Set text alignment
   ObjectSetInteger(typeChart, buttonName, OBJPROP_ALIGN, ALIGN_CENTER);
// Set width
   ObjectSetInteger(typeChart, buttonName, OBJPROP_XSIZE, xWidth);
// Set height
   ObjectSetInteger(typeChart, buttonName, OBJPROP_YSIZE, yHeight);
// Font Size
   ObjectSetInteger(typeChart, buttonName, OBJPROP_FONTSIZE,fontSize);
// Set Text Color
   ObjectSetInteger(typeChart, buttonName, OBJPROP_COLOR, foreColor);
// Set Background Color
   ObjectSetInteger(typeChart, buttonName, OBJPROP_BGCOLOR, bgColor);
// Set Name
   ObjectSetString(typeChart,  buttonName, OBJPROP_TEXT, name);
// Set Name
   ObjectSetString(typeChart,  buttonName, OBJPROP_FONT, "Calibri Bold");
// Disable the "Chart on foreground" tickbox
   ChartSetInteger(typeChart, CHART_FOREGROUND,0,false);
// Press State
   ObjectSetInteger(typeChart, buttonName,OBJPROP_STATE,true);
  }

//+------------------------------------------------------------------+
//| Reset Position Values                                            |
//+------------------------------------------------------------------+
void resetPositionValues()
  {
   position = (int)ChartGetInteger(0,CHART_HEIGHT_IN_PIXELS);
   rightEdge = (int)ChartGetInteger(0,CHART_WIDTH_IN_PIXELS);
   position = position/2 - 60;
  }
//+------------------------------------------------------------------+
//| Truncate Numbers                                                 |
//+------------------------------------------------------------------+
string TruncateNumber(string number, int decimalPoints=3)
  {
//   int start_index = StringFind(number, ".");
//   if(start_index == -1)
//      return number;
//
//   string vals[2] = {"", ""};
//   StringSplit(number, '.', vals);
//
//   if(StringLen(vals[1]) <= decimalPoints)
      return number;

   //return StringConcatenate(vals[0], ".", StringSubstr(vals[1], 0, 2));
  }

//+------------------------------------------------------------------+
//| Set Buttons                                                      |
//+------------------------------------------------------------------+
void setButtons()
  {
   createButton("EMACrossStart", "EMA Cross Start",rightEdge - 120, position, 100, 30, 9, false, emaStartButtonColor, clrWhite);
   createButton("EMACrossEnd", "EMA Cross End",rightEdge - 120, position + 35, 100, 30, 9, false, emaEndButtonColor, clrWhite);
   createTextBox("LotSize", TruncateNumber(DoubleToString(lotSize)),rightEdge - 120, position + 68, 100, 30, 12, clrWhite, clrBlack);
   createButton("CloseAllTrades", "Close All Trades",rightEdge - 120, position + 103,100, 30, 9, false, clrWhite, clrBlack);
   createButton("Buy", "Buy",rightEdge - 120, position + 138, 40, 30, 9, false, clrGreen, clrWhite);
   createButton("Sell", "Sell",rightEdge - 60, position + 138, 40, 30, 9, false, clrRed, clrWhite);
   createButton("BuyS", "Buy S",rightEdge - 120, position + 174, 40, 30, 9, false, clrGreen, clrWhite);
   createButton("SellS", "Sell S",rightEdge - 60, position + 174, 40, 30, 9, false, clrRed, clrWhite);
   createButton("BuyL", "Buy L",rightEdge - 120, position + 210, 40, 30, 9, false, clrGreen, clrWhite);
   createButton("SellL", "Sell L",rightEdge - 60, position + 210, 40, 30, 9, false, clrRed, clrWhite);
  }

//+------------------------------------------------------------------+
//| Set TextBox LotSize                                              |
//+------------------------------------------------------------------+
void setTextBoxLotSize()
  {
      lotSize = (double)ObjectGetString(0, "LotSize", OBJPROP_TEXT);
  }

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
// Lot AutoLot
   lotSize = LotSize;
// Buttons Menu
   resetPositionValues();
   setButtons();

   return 0;
  }

//+------------------------------------------------------------------+
//| Reset Settings To Original                                       |
//+------------------------------------------------------------------+
void resetSettings()
  {
   buyUserDefinedPip = 0;
   sellUserDefinedPip = 0;
   takeProfit = TakeProfit;
   stopLoss = StopLoss;
  }

//+------------------------------------------------------------------+
//| Setup For Buy Stop                                               |
//+------------------------------------------------------------------+
void setBuyStopSettings()
  {
   buyUserDefinedPip = BuyStopPip;
   takeProfit = BuyStopTakeProfit;
   stopLoss = BuyStopStopLoss;
  }

//+------------------------------------------------------------------+
//| Setup For Sell Stop                                              |
//+------------------------------------------------------------------+
void setSellStopSettings()
  {
   sellUserDefinedPip = -SellStopPip;
   takeProfit = SellStopTakeProfit;
   stopLoss = SellStopStopLoss;
  }
//+------------------------------------------------------------------+
//| Setup For Buy Limit                                              |
//+------------------------------------------------------------------+
void setBuyLimitSettings()
  {
   buyUserDefinedPip = -BuyLimitPip;
   takeProfit = BuyLimitTakeProfit;
   stopLoss = BuyLimitStopLoss;
  }

//+------------------------------------------------------------------+
//| Setup For Sell Limit                                             |
//+------------------------------------------------------------------+
void setSellLimitSettings()
  {
   sellUserDefinedPip = SellLimitPip;
   takeProfit = SellLimitTakeProfit;
   stopLoss = SellLimitStopLoss;
  }
//+------------------------------------------------------------------+
//| Setup For Save A Buy Trade                                       |
//+------------------------------------------------------------------+
void setSaveBuySettings()
  {
   stopLoss = SaveTradeStopLoss;
   takeProfit = SaveTradeTakeProfit;
   lotSize = SaveTradeLotSize;
   buyUserDefinedPip = SaveTradePip;
  }
//+------------------------------------------------------------------+
//| Setup For Save A Sell Trade                                      |
//+------------------------------------------------------------------+
void setSaveSellSettings()
  {
   sellUserDefinedPip = -SaveTradePip;
   stopLoss = SaveTradeStopLoss;
   takeProfit = SaveTradeTakeProfit;
   lotSize = SaveTradeLotSize;
  }

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
   ObjectsDeleteAll();
  }


//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
   ordersTotal();
   if(current != Time[0])
     {
      current = Time[0];
      order();
     }
  }

//+------------------------------------------------------------------+
//| Return whether a stop loss occurred or take profit               |
//+------------------------------------------------------------------+
string fnHistoryCheck()
  {
   string sResult = "EMPTY";
   int iOrders = OrdersHistoryTotal()-1;
   for(int iO = iOrders; iO>=0; iO--)
     {
      bool value = OrderSelect(iO,SELECT_BY_POS,MODE_HISTORY);

      if(OrderSymbol() == Symbol() && OrderMagicNumber()== magicNumber)
        {
         if((TimeDayOfYear(OrderOpenTime()) == DayOfYear()) && (TimeYear(OrderOpenTime()) == Year()))
           {
            if(OrderProfit() >= 0)
               sResult = "PROFIT";
            else
               sResult = "LOSS";

           }
        }
     }
   return(sResult);
  }

//+------------------------------------------------------------------+
//| Order                                                            |
//+------------------------------------------------------------------+
void order()
  {
   if(emaSaveBuyTradeToggle)
     {
      if(fnHistoryCheck() == "LOSS")
        {
         setSaveBuySettings();
         orderCloseSell("Buy Stop Placed!");
         orderBuy();
         resetSettings();
         setTextBoxLotSize();
         setButtons();
         emaSaveBuyTradeToggle = False;
         emaStartBuyTradeExpireToggle = True;
        }
     }
   else
      if(emaStartBuyTradeExpireToggle)
        {
         candlesAfterBuyTrade++;
         if(candlesAfterBuyTrade > ExpirationCandles)
           {
            orderCloseBuy("Buy Stop Closed!");
            emaStartBuyTradeExpireToggle = False;
            candlesAfterBuyTrade = 0;
           }
        }
   if(emaSaveSellTradeToggle)
     {
      if(fnHistoryCheck() == "LOSS")
        {
         setSaveSellSettings();
         orderCloseBuy("Sell Stop Placed!");
         orderSell();
         resetSettings();
         setTextBoxLotSize();
         setButtons();
         emaSaveSellTradeToggle = False;
         emaStartSellTradeExpireToggle = True;
        }
     }
   else
      if(emaStartSellTradeExpireToggle)
        {
         candlesAfterSellTrade++;
         if(candlesAfterSellTrade > ExpirationCandles)
           {
            orderCloseSell("Sell Stop Closed!");
            emaStartSellTradeExpireToggle = False;
            candlesAfterSellTrade = 0;
           }
        }

   if(emaCrossStartToggle)
     {
      // For Cross Over Start
      double fma1_1 = iMA(NULL, 0, fma1_Period,0, MODE_EMA, PRICE_OPEN, 1);
      double fma1_2 = iMA(NULL, 0, fma1_Period,0, MODE_EMA, PRICE_OPEN, 2);
      double sma1_1 = iMA(NULL, 0, sma1_Period, 0, MODE_EMA, PRICE_OPEN, 1);
      double sma1_2 = iMA(NULL, 0, sma1_Period, 0, MODE_EMA, PRICE_OPEN, 2);

      if(fma1_2 > sma1_2 && fma1_1 < sma1_1)
        {
         Print("Cross Match EMA");
         orderCloseSell("");
         orderBuy();
         emaCrossStartToggle = False;
         emaStartButtonColor = clrGreen;
         setButtons();
        }
      if(fma1_2 < sma1_2 && fma1_1 > sma1_1)
        {
         Print("Cross Match EMA");
         orderCloseBuy("");
         orderSell();
         emaCrossStartToggle = False;
         emaStartButtonColor = clrGreen;
         setButtons();
        }
     }
   if(emaCrossEndToggle)
     {
      // For Cross Over End
      double fma2_1 = iMA(NULL, 0, fma2_Period,0, MODE_EMA, PRICE_OPEN, 1);
      double fma2_2 = iMA(NULL, 0, fma2_Period,0, MODE_EMA, PRICE_OPEN, 2);
      double sma2_1 = iMA(NULL, 0, sma2_Period, 0, MODE_EMA, PRICE_OPEN, 1);
      double sma2_2 = iMA(NULL, 0, sma2_Period, 0, MODE_EMA, PRICE_OPEN, 2);

      if(fma2_2 > sma2_2 && fma2_1 < sma2_1)
        {
         orderCloseBuy("Buy Closed On EMAEndToggle");
         emaCrossEndToggle = False;
         emaEndButtonColor = clrRed;
         setButtons();
        }
      else
         if(fma2_2 < sma2_2 && fma2_1 > sma2_1)
           {
            orderCloseSell("Sell Closed On EMAEndToggle");
            emaCrossEndToggle = False;
            emaEndButtonColor = clrRed;
            setButtons();
           }
     }
  }

//+------------------------------------------------------------------+
//| Onclick Chart Event Handler                                      |
//+------------------------------------------------------------------+
void OnChartEvent(const int id, const long &lparam,const double &dparam,const string &sparam)
  {
   resetPositionValues();
   Print("LotSize: ", lotSize);
   if(id == CHARTEVENT_CHART_CHANGE)
     {
      setTextBoxLotSize();
      createTextBox("LotSize", TruncateNumber(DoubleToString(lotSize)),rightEdge - 120, position + 68, 100, 30, 12, clrWhite, clrBlack);
      setButtons();
      if(sparam == "LotSize")
        {
         setTextBoxLotSize();
         createTextBox("LotSize", TruncateNumber(DoubleToString(lotSize)),rightEdge - 120, position + 68, 100, 30, 12, clrWhite, clrBlack);
         Print("LotSize: ", lotSize);
        }
     }
   if(id == CHARTEVENT_OBJECT_CLICK)
     {
      if(sparam == "EMACrossStart")
        {
         if(!emaCrossStartToggle)
           {
            Print("EMA Cross Start Enabled");
            emaCrossStartToggle = True;
            emaCrossEndToggle = False;
            emaStartButtonColor = clrBlue;
            emaEndButtonColor = clrRed;
           }
         else
           {

            Print("EMA Cross Start Disabled");
            emaCrossStartToggle = False;
            emaCrossEndToggle = False;
            emaStartButtonColor = clrGreen;
            emaEndButtonColor = clrRed;
           }
         createButton("EMACrossStart", "EMA Cross Start",rightEdge - 120, position, 100, 30, 9, false, emaStartButtonColor, clrWhite);
         createButton("EMACrossEnd", "EMA Cross End",rightEdge - 120, position + 35, 100, 30, 9, false, emaEndButtonColor, clrWhite);
        }
      else
         if(sparam == "EMACrossEnd")
           {
            if(!emaCrossEndToggle)
              {
               Print("EMA Cross End Enabled");
               emaCrossStartToggle = False;
               emaCrossEndToggle = True;
               emaStartButtonColor = clrGreen;
               emaEndButtonColor = clrBlue;
               orderCloseBuy("Cross Match EMA");
               orderCloseSell("Cross Match EMA");
              }
            else
              {
               Print("EMA Cross End Disabled");
               emaCrossStartToggle = False;
               emaCrossEndToggle = False;
               emaStartButtonColor = clrGreen;
               emaEndButtonColor = clrRed;
              }
            createButton("EMACrossStart", "EMA Cross Start",rightEdge - 120, position, 100, 30, 9, false, emaStartButtonColor, clrWhite);
            createButton("EMACrossEnd", "EMA Cross End",rightEdge - 120, position + 35, 100, 30, 9, false, emaEndButtonColor, clrWhite);
           }

         else
            if(sparam == "CloseAllTrades")
              {
               emaCrossStartToggle = False;
               emaCrossEndToggle = False;
               emaStartButtonColor = clrGreen;
               emaEndButtonColor = clrRed;
               orderCloseBuy("Buy Closed On EMAEndToggle");
               orderCloseSell("Sell Closed On EMAEndToggle");
               createButton("EMACrossStart", "EMA Cross Start",rightEdge - 120, position, 100, 30, 9, false, emaStartButtonColor, clrWhite);
               createButton("EMACrossEnd", "EMA Cross End",rightEdge - 120, position + 35, 100, 30, 9, false, emaEndButtonColor, clrWhite);
              }
            else
               if(sparam == "Buy")
                 {
                  resetSettings();
                  orderCloseSell("Closed on Buy Signal");
                  orderBuy();
                  emaSaveBuyTradeToggle = True;
                  //setSaveBuySettings();
                  //orderBuy();
                 }
               else
                  if(sparam == "Sell")
                    {
                     resetSettings();
                     orderCloseBuy("Closed on Sell Signal");
                     orderSell();
                     emaSaveSellTradeToggle = True;
                     //setSaveSellSettings();
                     //orderSell();
                    }
                  else
                     if(sparam == "BuyS")
                       {
                        setBuyStopSettings();
                        orderCloseSell("Closed on Buy S Signal");
                        orderBuy();
                        emaSaveBuyTradeToggle = True;
                       }
                     else
                        if(sparam == "SellS")
                          {
                           setSellStopSettings();
                           orderCloseBuy("Closed on Sell S Signal");
                           orderSell();
                           emaSaveSellTradeToggle = True;
                          }
                        else
                           if(sparam == "BuyL")
                             {
                              setBuyLimitSettings();
                              orderCloseSell("Closed on Buy L Signal");
                              orderBuy();
                              emaSaveBuyTradeToggle = True;
                              //setSaveBuySettings();
                              //orderBuy();
                             }
                           else
                              if(sparam == "SellL")
                                {
                                 setSellLimitSettings();
                                 orderCloseBuy("Closed on Sell L Signal");
                                 orderSell();
                                 emaSaveSellTradeToggle = True;
                                 //setSaveSellSettings();
                                 //orderSell();
                                }
      resetSettings();
      ObjectSetInteger(0,sparam,OBJPROP_STATE,false);
     }

  }

//+------------------------------------------------------------------------+
//| Function to return True if the double has some value, false otherwise  |
//+------------------------------------------------------------------------+
bool hasValue(double val)
  {
   return (val && val != EMPTY_VALUE);
  }
//+------------------------------------------------------------------+
//| Function to place Buy orders                                     |
//+------------------------------------------------------------------+
void orderBuy()
  {
   double sl = (stopLoss == 0) ? 0 : NormalizeDouble(Ask + buyUserDefinedPip*pip - stopLoss*pip, Digits);
   double tp = (takeProfit == 0) ? 0 : NormalizeDouble(Ask + buyUserDefinedPip*pip + takeProfit*pip, Digits);

   int retries = 10;
   while(retries >= 0)
     {
      if(OrderSend(Symbol(),OP_BUY,lotSize,Ask,slippage,sl,tp,"",magicNumber,0,clrBlue) < 0)
        {
         Print("Buy Order failed with error #",GetLastError());
         if(tp != 0 && tp - Bid < stopLevel)
            Print("Wrong Takeprofit " + DoubleToString(tp,Digits) + ", TP should be at " + DoubleToString(Ask + stopLevel,Digits) + " or above");
         if(sl != 0 && Bid - sl < stopLevel)
            Print("Wrong Stoploss " + DoubleToString(sl,Digits) + ", SL should be at " + DoubleToString(Bid - stopLevel,Digits) + " or below");
         if(retries - 1 >= 0)
            Sleep(1000);
        }
      else
        {
         Print("Buy Order placed successfully");
         break;
        }
      --retries;
     }//End While
  }
//+------------------------------------------------------------------+
//| Function to place Sell Orders                                    |
//+------------------------------------------------------------------+
void orderSell()
  {
   double sl = (stopLoss == 0) ? 0 : NormalizeDouble(Bid + sellUserDefinedPip*pip + stopLoss * pip, Digits);
   double tp = (takeProfit == 0) ? 0 : NormalizeDouble(Bid + sellUserDefinedPip*pip - takeProfit * pip, Digits);

   int retries = 3;
   while(retries >= 0)
     {
      if(OrderSend(Symbol(),OP_SELL,lotSize,Bid,slippage,sl,tp,"",magicNumber,0,clrRed) < 0)
        {
         Print("Sell Order failed with error #",GetLastError());
         if(tp != 0 && Ask - tp < stopLevel)
            Print("Wrong Takeprofit " + DoubleToString(tp,Digits) + ", TP should be at " + DoubleToString(Bid - stopLevel,Digits) + " or below");
         if(sl != 0 && sl - Ask < stopLevel)
            Print("Wrong Stoploss " + DoubleToString(sl,Digits) + ", SL should be at " + DoubleToString(Ask + stopLevel,Digits) + " or above");
         if(retries - 1 >= 0)
            Sleep(1000);
        }
      else
        {
         Print("Sell Order placed successfully");
         break;
        }
      --retries;
     }//End While
  }
//+------------------------------------------------------------------+
//| Function to count total Buy, Sell Orders                         |
//+------------------------------------------------------------------+
void ordersTotal()
  {
   totalBuy = totalSell = 0;
   for(int i = OrdersTotal() - 1; i >= 0; --i) // Cycle searching in orders
     {
      if(OrderSelect(i,SELECT_BY_POS) == true)
        {
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == magicNumber)
           {
            if(OrderType() == OP_BUY)
               ++totalBuy;
            if(OrderType() == OP_SELL)
               ++totalSell;
           }
        }
     }
  }
//+------------------------------------------------------------------+
//| Function to close buy orders                                     |
//+------------------------------------------------------------------+
void orderCloseBuy(string com)
  {
   for(int i = OrdersTotal() - 1; i >= 0; --i) // Cycle searching in orders
     {
      if(OrderSelect(i,SELECT_BY_POS) == true)
        {
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == magicNumber && OrderType() == OP_BUY)
           {
            if(OrderClose(OrderTicket(),OrderLots(),Bid,slippage,clrCyan) == true)
               Print("Buy Order closed on " + com);
           }
        }
     }
  }
//+------------------------------------------------------------------+
//| Function to close sell orders                                    |
//+------------------------------------------------------------------+
void orderCloseSell(string com)
  {
   for(int i = OrdersTotal() - 1; i >= 0; --i) // Cycle searching in orders
     {
      if(OrderSelect(i,SELECT_BY_POS) == true)
        {
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == magicNumber && OrderType() == OP_SELL)
           {
            if(OrderClose(OrderTicket(),OrderLots(),Ask,slippage,clrCyan) == true)
               Print("Sell Order closed on " + com);
           }
        }
     }
  }
//+------------------------------------------------------------------+