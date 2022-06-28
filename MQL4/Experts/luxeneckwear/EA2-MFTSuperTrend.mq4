//+------------------------------------------------------------------+
//|                                                                  |
//|                                     Copyright © 2021, Eqan Ahmad |
//|                                     https://fiverr.com/eqanahmad |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2021, Eqan Ahmad"
#property link      "https://fiverr.com/eqanahmad"
#property version   "1.00"
#property strict
enum settings
  {
   settings = 0,                                  //======= Settings =======
  };

input settings gs = 0;                                        // ===== General =====
input double LotSize = 0.01;                                  // LotSize
input int slippage = 5;                                       // Slippage
input int magicNumber = 123;                                  // Magic Number
input double takeProfit = 20;                                 // Take Profit (Pips)
input double stopLoss = 30;                                   // Stop Loss (Pips)
input double riskSL = 25;                                     // Risk% for Autolot

input settings st = 0;                                        // ===== Super Trend =====
string st_objPrefix = "SPRTRND";                              // Object Prefix
input double st_atrMultiplier = 2.0;                          // ATR Multiplier
input int st_atrPeriod = 100;                                 // ATR Period
input int st_atrMaxBars = 1000;                               // ATR Max Bars(Max 10.000)

input settings mst = 0;                                       // ===== MTF Super Trend =====
string mst_indicatorSettings = "====================";        // Indicator Settings
input double mst_atrMultiplier = 2.0;                         // ATR Multiplier
input int mst_atrPeriod = 100;                                // ATR Period
input int mst_atrMaxBars = 1000;                              // ATR Max Bars(Max 10.000)
input int mst_candleShiftToCalculateSuperTrend = 0;           // Candle shift to Calculate the Supertrend
string mst_enabledTimeFrames = "====================";        // Enabled Timeframes
bool mst_enableTimeFrameM1 = false;                           // Enable Timeframe M1
bool mst_enableTimeFrameM5 = false;                           // Enable Timeframe M5
bool mst_enableTimeFrameM15 = false;                          // Enable Timeframe M15
bool mst_enableTimeFrameM30 = false;                          // Enable Timeframe M30
bool mst_enableTimeFrameH1 = false;                           // Enable Timeframe H1
bool mst_enableTimeFrameH4 = false;                           // Enable Timeframe H4
bool mst_enableTimeFrameD1 = false;                           // Enable Timeframe D1
bool mst_enableTimeFrameW1 = false;                           // Enable Timeframe W1
bool mst_enableTimeFrameMN1 = false;                          // Enable Timeframe MN1
string mst_notificationOptions = "====================";      // Notification Options
bool mst_enableNotificationsFeature = false;                  // Enable Notifications Feature
bool mst_sendAlertNotification = false;                       // Send Alert Notification
bool mst_sendNotificationsToMobile = false;                   // Send Notification To Mobile
bool mst_sendNotificationsViaEmail = false;                   // Send Notification via Email
string mst_grpahicalObjects = "====================";         // Graphical Objects
bool mst_drawLines = false;                                   // Draw Lines
bool mst_drawWindow = false;                                  // Draw Window
bool mst_drawArrowSignal = false;                             // Draw Arrow Signal
int mst_arrowCodeBuy = 241;                                   // Arrow Code Buy
int mst_arrowCodeSell = 242;                                  // Arrow Code Sell
int mst_horizontalSpacing = 20;                               // Horizontal spacing for the control panel
int mst_verticalSpacing = 20;                                 // Vertical spacing for the control panel
string mst_indicatorName = "MQLTA-SMTF";                      // Indicator Name(to Name the objects)

datetime current;
double pip = Point,stopLevel,lotSize;
int totalBuy = 0,totalSell = 0,step;
string dir="";
//luxeneckwear//
double PV=1;


//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   if(MarketInfo(Symbol(),MODE_LOTSTEP) == 0.1)
     {
      step = 1;
      PV = 1;
     }
   else
      if(MarketInfo(Symbol(),MODE_LOTSTEP) == 0.01)
        {
         step = 2;
         PV = 10;
        }
      else
        {
         step = 0;
         PV = 0.1;
        }
   pip = pip * 10.0;
   stopLevel = MarketInfo(Symbol(),MODE_STOPLEVEL) * pip;
   step = (MarketInfo(Symbol(),MODE_LOTSTEP) == 0.1) + 2 * (MarketInfo(Symbol(),MODE_LOTSTEP) == 0.01);
   lotSize = NormalizeDouble(LotSize,step);
   if(lotSize != LotSize)
     {
      lotSize = lotSize == 0 ? MarketInfo(Symbol(),MODE_MINLOT) : lotSize;
      Print("Wrong Volume " + DoubleToString(LotSize,2) + " for Pair " + Symbol() + ".It should be round off to " + (string)step + " decimal places like " + DoubleToString(lotSize,step));
      Alert("Wrong Volume " + DoubleToString(LotSize,2) + " for Pair " + Symbol() + ".It should be round off to " + (string)step + " decimal places like " + DoubleToString(lotSize,step));
     }
//---
   return(INIT_SUCCEEDED);
  }
//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//---

  }
//+------------------------------------------------------------------+
//| Expert tick function                                             |
//+------------------------------------------------------------------+
void OnTick()
  {
//---
   ordersTotal();
   if(current != Time[0])
     {
      current = Time[0];
      order();
     }
  }
//+------------------------------------------------------------------+
//| Function to Check if the Conditions for the Order has met        |
//+------------------------------------------------------------------+
void order()
  {
   double superTrendUp_1 = iCustom(Symbol(), 0, dir + "MQLTA MT4 Supertrend Line", st_objPrefix, st_atrMultiplier, st_atrPeriod, st_atrMaxBars, 0, 1);
   double superTrendUp_2 = iCustom(Symbol(), 0, dir + "MQLTA MT4 Supertrend Line", st_objPrefix, st_atrMultiplier, st_atrPeriod, st_atrMaxBars, 0, 2);
   double superTrendDown_1 = iCustom(Symbol(), 0, dir + "MQLTA MT4 Supertrend Line", st_objPrefix, st_atrMultiplier, st_atrPeriod, st_atrMaxBars, 1, 1);
   double superTrendDown_2 = iCustom(Symbol(), 0, dir + "MQLTA MT4 Supertrend Line", st_objPrefix, st_atrMultiplier, st_atrPeriod, st_atrMaxBars, 1, 2);
   double mtfSuperTrendUp = iCustom(Symbol(), 0, dir + "MQLTA MT4 Supertrend Multi-Timeframe", mst_indicatorSettings, mst_atrMultiplier, mst_atrPeriod, mst_atrMaxBars, mst_candleShiftToCalculateSuperTrend,
                                    mst_enabledTimeFrames, mst_enableTimeFrameM1, mst_enableTimeFrameM5, mst_enableTimeFrameM15, mst_enableTimeFrameM30, mst_enableTimeFrameH1, mst_enableTimeFrameH4, mst_enableTimeFrameD1,
                                    mst_enableTimeFrameW1, mst_enableTimeFrameMN1, mst_notificationOptions, mst_enableNotificationsFeature, mst_sendAlertNotification, mst_sendNotificationsToMobile, mst_sendNotificationsViaEmail,
                                    mst_grpahicalObjects, mst_drawLines, mst_drawWindow, mst_drawArrowSignal, mst_arrowCodeBuy, mst_arrowCodeSell, mst_horizontalSpacing, mst_verticalSpacing, mst_indicatorName,0, 1);
   double mtfSuperTrendDown = iCustom(Symbol(), 0, dir + "MQLTA MT4 Supertrend Multi-Timeframe", mst_indicatorSettings, mst_atrMultiplier, mst_atrPeriod, mst_atrMaxBars, mst_candleShiftToCalculateSuperTrend,
                                      mst_enabledTimeFrames, mst_enableTimeFrameM1, mst_enableTimeFrameM5, mst_enableTimeFrameM15, mst_enableTimeFrameM30, mst_enableTimeFrameH1, mst_enableTimeFrameH4, mst_enableTimeFrameD1,
                                      mst_enableTimeFrameW1, mst_enableTimeFrameMN1, mst_notificationOptions, mst_enableNotificationsFeature, mst_sendAlertNotification, mst_sendNotificationsToMobile, mst_sendNotificationsViaEmail,
                                      mst_grpahicalObjects, mst_drawLines, mst_drawWindow, mst_drawArrowSignal, mst_arrowCodeBuy, mst_arrowCodeSell, mst_horizontalSpacing, mst_verticalSpacing, mst_indicatorName,1, 1);

   lotSize = autoLot();
   if(hasValue(mtfSuperTrendUp) && (hasValue(superTrendDown_2) && hasValue(superTrendUp_1)))/* && superTrendUp_1 < Close[1])*/
     {
      orderBuy();
      orderCloseSell("Order Sell has been closed!");
     }
   else
      if(hasValue(mtfSuperTrendDown) && (hasValue(superTrendUp_2) && hasValue(superTrendDown_1)))/* && superTrendDown_1 > Close[1])*/
        {
         orderSell();
         orderCloseBuy("Order Buy has been closed!");
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
   double sl = (stopLoss == 0) ? 0 : NormalizeDouble(Ask - stopLoss * pip, Digits);
   double tp = (takeProfit == 0) ? 0 : NormalizeDouble(Ask + takeProfit * pip, Digits);

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
   double sl = (stopLoss == 0) ? 0 : NormalizeDouble(Bid + stopLoss * pip, Digits);
   double tp = (takeProfit == 0) ? 0 : NormalizeDouble(Bid - takeProfit * pip, Digits);

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
//| Function to return the AutoLot                                   |
//+------------------------------------------------------------------+
double autoLot()
  {
   if(stopLoss == 0)
      return LotSize;

   double l = NormalizeDouble((AccountEquity() * riskSL / 100.0) / (stopLoss * PV),step);
   l = MathMin(MarketInfo(Symbol(),MODE_MAXLOT),l);
   l = MathMax(MarketInfo(Symbol(),MODE_MINLOT),l);
   return l;
  }
//+------------------------------------------------------------------+
