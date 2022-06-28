//+------------------------------------------------------------------+
//|                                                                  |
//|                                       Copyright © 2021, Mananhfz |
//|                                      https://fiverr.com/mananhfz |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2021, Mananhfz"
#property link      "https://fiverr.com/mananhfz"
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

input settings bks = 0;                                       // ===== Break Even =====
input bool allowBreakEven = true;                             // Allow Break Even ?
input int distance = 10;                                      // Distance pips
input int lockInPoints = 2;                                   // Lock Pips

input settings fls = 0;                                       // ===== Fluction Indicator ====
input int fl_Value_1 =  -25;                                  // FL Buy Value
input int fl_Value_2 =   25;                                  // FL Sell Value
input ENUM_TIMEFRAMES  fl_TimeFrame = PERIOD_CURRENT;         // Time Frame
input int fl_period = 14;                                     // Period
input int fl_Level = 25;                                      // Level
input double fl_Smooth = 15.0;                                // Smooth
input int fl_AdaptPeriod = 14;                                // Adapt Period

input settings pbs = 0;                                       // ===== Price Border Indicator =====
input string pb_TimeFrame = "All tf";                           // Time Frame
input int pb_HalfLength = 61;                                   // Half Length
input int pb_Price = 0;                                         // Price
input double pb_AtrMultiplier = 2.6;                            // ATR Multiplier
input int pb_AtrPeriod = 110;                                   // ATR Period
input bool pb_Interpolate = true;                               // Interpolate

input settings has = 0;                                       // ===== Heiken Ashi Indicator =====
input color bearShadow = clrRed;                                // Bear Shadow
input color bullShadow = clrWhite;                              // Bull Shadow
input color bearBody = clrRed;                                  // Bear Body
input color bullBody = clrWhite;                                // Bull Body

input settings als = 0;                                       // ===== Alerts =====
input bool allertOn = false;                                    // Allert ?
input bool allertOnCurrent = false;                             // Current Alert ?
input bool allertMessage = false;                               // Mobile Alerts ?
input bool allertSound = false;                                 // Sound Alert ?
input bool allertEmail = false;                                 // Email Alerts ?
input bool allertNotify = false;                                // Notification Alert ?
input bool allertOnHighLow = false;                             // Alert On High Low
input string fl_Sound = "alert2.wav";                           // Alert Sound

datetime current;
double pip = Point,stopLevel,lotSize;
int totalBuy = 0,totalSell = 0,step;
string dir="Task6\\";
//
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   pip = Point * 10.0;
   stopLevel = MarketInfo(Symbol(),MODE_STOPLEVEL) * Point;
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

   if(allowBreakEven)
      breakEven();
  }
//+------------------------------------------------------------------+
//| Function to Check if the Conditions for the Order has met        |
//+------------------------------------------------------------------+
void order()
  {
   double m1Kiju = iCustom(Symbol(), 0, dir + "Fluction indicator", fl_TimeFrame, fl_period, fl_Level, fl_Smooth, fl_AdaptPeriod, allertOn, allertOnCurrent, allertMessage, allertSound, allertNotify, allertNotify,fl_Sound, 0, 1);
   double value3 = iCustom(Symbol(), 0, dir + "Fluction indicator", fl_TimeFrame, fl_period, fl_Level, fl_Smooth, fl_AdaptPeriod, allertOn, allertOnCurrent, allertMessage, allertSound, allertNotify, allertNotify,fl_Sound, 2, 1);
   double heikenOpen = iCustom(Symbol(), 0, dir + "Heiken Ashi",  bearShadow, bullShadow, bearBody, bullBody, 2, 1);
   double heikenClose= iCustom(Symbol(), 0, dir + "Heiken Ashi",  bearShadow, bullShadow, bearBody, bullBody, 3, 1);
   double priceBorderLine = iCustom(Symbol(), 0, dir + "PriceBorder", pb_TimeFrame, pb_HalfLength, pb_Price, pb_AtrMultiplier, pb_AtrPeriod, pb_Interpolate, allertOn, allertOnCurrent, allertOnHighLow, allertMessage, allertSound, allertEmail, 0, 1);
   double priceTop = iCustom(Symbol(), 0, dir + "PriceBorder", pb_TimeFrame, pb_HalfLength, pb_Price, pb_AtrMultiplier, pb_AtrPeriod, pb_Interpolate, allertOn, allertOnCurrent, allertOnHighLow, allertMessage, allertSound, allertEmail, 1, 1);
   double priceBottom = iCustom(Symbol(), 0, dir + "PriceBorder", pb_TimeFrame, pb_HalfLength, pb_Price, pb_AtrMultiplier, pb_AtrPeriod, pb_Interpolate, allertOn, allertOnCurrent, allertOnHighLow, allertMessage, allertSound, allertEmail, 2, 1);
   double priceTouch = 0;
   ordersTotal();
   if(m1Kiju < fl_Value_1 && !hasValue(value3) && heikenClose > heikenOpen && totalBuy == 0)
     {
      orderBuy();
      if(High[1] >= priceTop && priceTop <= Low[1])
        {
            orderCloseSell("Order Sold!");
        }
      else
         if(takeProfit > 100)
            orderCloseSell("Order Sold!");
     }
   else
      if(m1Kiju > fl_Value_2 && hasValue(value3) && heikenClose < heikenOpen && totalSell == 0)
        {
         orderSell();
         if(High[1] >= priceBottom && priceBottom <= Low[1])
           {
               orderCloseBuy("Order Bought!");
           }
         else
            if(takeProfit > 100)
               orderCloseBuy("Order Bought!");
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

   int retries = 3;
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
//|Function to apply breakEven                                       |
//+------------------------------------------------------------------+
void breakEven()
  {
   for(int i = OrdersTotal() - 1; i >= 0; --i) // Cycle searching in orders
     {
      if(OrderSelect(i,SELECT_BY_POS) == true)
        {
         if(OrderMagicNumber() == magicNumber && OrderSymbol() == Symbol())
           {
            if(OrderType() == OP_BUY && (Bid - OrderOpenPrice()) > lockInPoints * pip)
              {
               if((Bid - OrderOpenPrice()) >= distance * pip && OrderStopLoss() < OrderOpenPrice())
                 {
                  double sl = NormalizeDouble(OrderOpenPrice() + lockInPoints * pip,Digits);

                  if(OrderModify(OrderTicket(),OrderOpenPrice(),sl,OrderTakeProfit(),0,clrRed) > 0)
                     Print("Break even: Buy Order# " + IntegerToString(OrderTicket()) + " modified successfully.");
                  else
                     Print("Break even: Error in Buy# " + IntegerToString(OrderTicket()) + " OrderModify. Error code=",GetLastError());
                 }
              }
            else
               if(OrderType() == OP_SELL && (OrderOpenPrice() - Ask) > lockInPoints * pip)
                 {
                  if((OrderOpenPrice() - Ask) >= distance * pip && (OrderStopLoss() > OrderOpenPrice() || OrderStopLoss() == 0))
                    {
                     double sl = NormalizeDouble(OrderOpenPrice() - lockInPoints * pip,Digits);

                     if(OrderModify(OrderTicket(),OrderOpenPrice(),sl,OrderTakeProfit(),0,clrRed) > 0)
                        Print("Break even: Sell Order# " + IntegerToString(OrderTicket()) + " modified successfully.");
                     else
                        Print("Break even: Error in Sell# " + IntegerToString(OrderTicket()) + " OrderModify. Error code=",GetLastError());
                    }

                 }
           }
        }
     }
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
//+------------------------------------------------------------------+
