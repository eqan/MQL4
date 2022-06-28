//+------------------------------------------------------------------+
//|                                                           Jm1894 |
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
input double takeProfit = 200;                                // Take Profit
input double stopLoss = 300;                                  // Stop Loss
input int maxOrders = 2;                                      // Simultaneous orders at a time

input settings mars = 0;                                      // ===== MartinGale =====
input bool turnOnMartinGale = true;                           // Turn On Martin Gale
input int totalTurns = 4;                                     // Total Martin Gale Turns
input int StopLossBoundary = 10;                              // Stop Loss Boundary

input settings tss = 0;                                       // ===== Trailing Stop =====
input bool allowTrailingStop = true;                          // Allow Trailing Stop ?
input int trailingStart = 200;                                // Trailing Start
input int trailingStep = 150;                                 // Trailing Stop

input settings bks = 0;                                       // ===== Break Even =====
input bool allowBreakEven = true;                             // Allow Break Even ?
input int distance = 10;                                      // Distance Points
input int lockInPoints = 2;                                   // Lock Points

input settings macs = 0;                                      // ===== MACD =====
input int macd_FastEma = 12;                                  // Fast EMA
input int macd_SlowEma = 26;                                  // Slow EMA
input int macd_SignalPeriod = 9;                              // Signal Period
input ENUM_APPLIED_PRICE macd_AppliedPrice = PRICE_CLOSE;     // Applied Price
input int macd_Mode = MODE_MAIN;                              // Mode
input int macd_Boundary = 0;                                  // Boundary


input settings alls = 0;                                      // ===== Alligator =====
input int all_JawPeriod = 13;                                 // Jaw Period
input int all_JawShift = 8;                                   // Jaw Shift
input int all_TeethPeriod = 8;                                // Teeth Period
input int all_TeethShift = 5;                                 // Teeth Shift
input int all_LipsPeriod = 5;                                 // Lips Period
input int all_LipsShift = 3;                                  // Lips Shift
input ENUM_MA_METHOD all_MaMethod = MODE_SMMA;                // MA Method
input ENUM_APPLIED_PRICE all_AppliedPrice = PRICE_MEDIAN;     // Applied Price

input settings rsis = 0;                                      // ===== RSI =====
input int rsi_Period = 5;                                     // Period
input ENUM_APPLIED_PRICE rsi_AppliedPrice = PRICE_CLOSE;      // Applied Price
input int rsi_BuyBoundary = 50;                               // Buy Boundary
input int rsi_SellBoundary = 50;                              // Sell Boundary

input settings tims = 0;                                      // ===== Time =====
input bool useTime = true;                                    // Use Time limitation?
input string openTime = "00:00";                              // From (HH:MM)
input string closeTime = "23:59";                             // Till (HH:MM)
input bool tradeMonday = true;                                // Trade on Monday ?
input bool tradeTuesday = true;                               // Trade on Tuesday ?
input bool tradeWednesday = true;                             // Trade on wednesday ?
input bool tradeThursday = true;                              // Trade on Thursday ?
input bool tradeFriday = true;                                // Trade on Friday ?

input settings eads = 0;                                      // ===== EA Activation Days =====
input bool Sunday = true;                                     // Sunday
input bool Monday = true;                                     // Monday
input bool Tuesday = true;                                    // Tuesday
input bool Wednesday = true;                                  // Wednesday
input bool Thursday = true;                                   // Thursday
input bool Friday = true;                                     // Friday
input bool Saturday = true;                                   // Saturday

input settings als = 0;                                       // ===== Alerts =====
input bool allowAlerts = false;                               // Desktop Alerts ?
input bool allowMobile = false;                               // Mobile Alerts ?
input bool allowEmail = false;                                // Email Alerts ?


datetime current;
double stopLevel,lotSize, stopLossBoundary;
int totalBuy = 0,totalSell = 0,step, currentTurn = 1;
string dir = "", starterType;
bool functionCall = false;
//
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   stopLossBoundary = StopLossBoundary * Point;
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
   if(current != Time[0])
     {
      current = Time[0];

      order();

      if(allowBreakEven)
         breakEven();
      if(allowTrailingStop)
         trailingStop();
     }
  }

//+------------------------------------------------------------------+
//| Function to Check if the Conditions for the Order has met        |
//+------------------------------------------------------------------+
void order()
  {
//--- Trading Days/Time Functionality
   if(!tradeMonday && DayOfWeek() == 1)
      return;
   if(!tradeTuesday && DayOfWeek() == 2)
      return;
   if(!tradeWednesday && DayOfWeek() == 3)
      return;
   if(!tradeThursday && DayOfWeek() == 4)
      return;
   if(!tradeFriday && DayOfWeek() == 5)
      return;
   if(useTime && !tradeTime())
      return;

   double macd_1 = iMACD(Symbol(), 0, macd_FastEma, macd_SlowEma, macd_SignalPeriod, macd_AppliedPrice, macd_Mode, 1);
   double alligator_Blue_1 = iAlligator(Symbol(), 0, all_JawPeriod, all_JawShift, all_TeethPeriod, all_TeethShift, all_LipsPeriod, all_LipsShift, all_MaMethod, all_AppliedPrice, MODE_GATORJAW, 1);
   double alligator_Red_1 = iAlligator(Symbol(), 0, all_JawPeriod, all_JawShift, all_TeethPeriod, all_TeethShift, all_LipsPeriod, all_LipsShift, all_MaMethod, all_AppliedPrice, MODE_GATORTEETH, 1);
   double alligator_Green_1 = iAlligator(Symbol(), 0, all_JawPeriod, all_JawShift, all_TeethPeriod, all_TeethShift, all_LipsPeriod, all_LipsShift, all_MaMethod, all_AppliedPrice, MODE_GATORLIPS, 1);
   double rsi_1 = iRSI(Symbol(), 0, rsi_Period, rsi_AppliedPrice, 1);
   double macd_2 = iMACD(Symbol(), 0, macd_FastEma, macd_SlowEma, macd_SignalPeriod, macd_AppliedPrice, macd_Mode, 2);
   double alligator_Blue_2 = iAlligator(Symbol(), 0, all_JawPeriod, all_JawShift, all_TeethPeriod, all_TeethShift, all_LipsPeriod, all_LipsShift, all_MaMethod, all_AppliedPrice, MODE_GATORJAW, 2);
   double alligator_Red_2 = iAlligator(Symbol(), 0, all_JawPeriod, all_JawShift, all_TeethPeriod, all_TeethShift, all_LipsPeriod, all_LipsShift, all_MaMethod, all_AppliedPrice, MODE_GATORTEETH, 2);
   double alligator_Green_2 = iAlligator(Symbol(), 0, all_JawPeriod, all_JawShift, all_TeethPeriod, all_TeethShift, all_LipsPeriod, all_LipsShift, all_MaMethod, all_AppliedPrice, MODE_GATORLIPS, 2);
   double rsi_2 = iRSI(Symbol(), 0, rsi_Period, rsi_AppliedPrice, 2);
   double maxValue = MathMax(alligator_Blue_1, alligator_Red_1);

   ordersTotal();

   if(totalBuy <= maxOrders// && alligator_Green_1 > maxValue && macd_1 > macd_Boundary
         && rsi_1 > rsi_BuyBoundary && rsi_2 < rsi_BuyBoundary
         /*     && (
                 checkCrossUp(alligator_Green_1, alligator_Blue_1, alligator_Green_2, alligator_Blue_2)
                 || checkCrossUp(alligator_Green_1, alligator_Red_1, alligator_Green_2, alligator_Red_2)
              )*/
     )
      orderBuy();
   else if(totalSell <= maxOrders
//            && alligator_Green_1 < maxValue && macd_1 < macd_Boundary /* && macd_2 > macd_Boundary*/
           && rsi_1 < rsi_SellBoundary && rsi_2 > rsi_SellBoundary
           /*          && ((
                            checkCrossDown(alligator_Green_1, alligator_Blue_1, alligator_Green_2, alligator_Blue_2)
                            || checkCrossDown(alligator_Green_1, alligator_Red_1, alligator_Green_2, alligator_Red_2)
                         )
                        ) */
          )
      orderSell();
  }
//+------------------------------------------------------------------+
//| Check Cross Up                                                   |
//+------------------------------------------------------------------+
bool checkCrossUp(double line1_1, double line2_1, double line1_2, double line2_2)
  {
   return (line1_2 < line2_2 && line1_1 > line2_1);
  }
//+------------------------------------------------------------------+
//| Check Cross Down                                                 |
//+------------------------------------------------------------------+
bool checkCrossDown(double line1_1, double line2_1, double line1_2, double line2_2)
  {
   return (line1_2 > line2_2 && line1_1 < line2_1);
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
   double sl = (stopLoss == 0) ? 0 : NormalizeDouble(Ask - stopLoss * Point, Digits);
   double tp = (takeProfit == 0) ? 0 : NormalizeDouble(Ask + takeProfit * Point, Digits);

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
   double sl = (stopLoss == 0) ? 0 : NormalizeDouble(Bid + stopLoss * Point, Digits);
   double tp = (takeProfit == 0) ? 0 : NormalizeDouble(Bid - takeProfit * Point, Digits);

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
            if(OrderType() == OP_BUY && (Bid - OrderOpenPrice()) > lockInPoints * Point)
              {
               if((Bid - OrderOpenPrice()) >= distance * Point && OrderStopLoss() < OrderOpenPrice())
                 {
                  double sl = NormalizeDouble(OrderOpenPrice() + lockInPoints * Point,Digits);

                  if(OrderModify(OrderTicket(),OrderOpenPrice(),sl,OrderTakeProfit(),0,clrRed) > 0)
                     Print("Break even: Buy Order# " + IntegerToString(OrderTicket()) + " modified successfully.");
                  else
                     Print("Break even: Error in Buy# " + IntegerToString(OrderTicket()) + " OrderModify. Error code=",GetLastError());
                 }
              }
            else if(OrderType() == OP_SELL && (OrderOpenPrice() - Ask) > lockInPoints * Point)
              {
               if((OrderOpenPrice() - Ask) >= distance * Point && (OrderStopLoss() > OrderOpenPrice() || OrderStopLoss() == 0))
                 {
                  double sl = NormalizeDouble(OrderOpenPrice() - lockInPoints * Point,Digits);

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
//| Function to Show Alerts                                          |
//+------------------------------------------------------------------+
void doAlert(string title,string msg)
  {
   if(allowAlerts)
      Alert(msg);
   if(allowEmail)
      SendMail(title,msg);
   if(allowMobile)
      SendNotification(msg);
  }
//+------------------------------------------------------------------+
//| Trailing Stop Function                                           |
//+------------------------------------------------------------------+
void trailingStop()
  {
   for(int i = OrdersTotal() - 1; i >= 0; i--)
     {
      if(OrderSelect(i, SELECT_BY_POS) && OrderSymbol() == Symbol())
        {
         if(OrderType() == OP_BUY &&  Bid - OrderOpenPrice() >= trailingStart * Point && OrderStopLoss() < Bid - trailingStep * Point)
           {
            if(OrderModify(OrderTicket(), OrderOpenPrice(), NormalizeDouble(Bid - trailingStep * Point, Digits), OrderTakeProfit(), 0))
               Print("Modified buy by trailing stop");
            else
               Print("Couldn't modify buy by trailing stop");
           }
         else if(OrderType() == OP_SELL && OrderOpenPrice() - Ask >= trailingStart * Point && (OrderStopLoss() > Ask + trailingStep * Point || OrderStopLoss() == 0))
           {
            if(OrderModify(OrderTicket(), OrderOpenPrice(), NormalizeDouble(Ask + trailingStep * Point, Digits), OrderTakeProfit(), 0))
               Print("Modified sell by trailing stop");
            else
               Print("Couldn't modify sell by trailing stop");
           }
        }
     }
  }
//+------------------------------------------------------------------+
//| Martin Gale Function                                             |
//+------------------------------------------------------------------+
void martinGaleFunction()
  {
   double buyMarketPrice = OrderOpenPrice() * Point - Bid;
   double sellMarketPrice = Ask - OrderOpenPrice() * Point;

   if(currentTurn < totalTurns)
     {
      currentTurn++;
      lotSize *= 2;
      if(starterType == "buy" && buyMarketPrice <= -1 * stopLossBoundary)
        {
         //orderCloseSell("Sell Order Closed");
         orderBuy();
         Print("Buy on 2nd conditon");
        }
      if(starterType == "sell" && sellMarketPrice <= -1 * stopLossBoundary)
        {
         //orderCloseBuy("Buy Order Closed");
         orderSell();
         Print("Sell on 2nd conditon");
        }
     }
   else
      reset();
  }
//+------------------------------------------------------------------+
//| Reset Function                                                   |
//+------------------------------------------------------------------+
void reset()
  {
   currentTurn = 1;
   lotSize = LotSize;
   functionCall = 0;
  }
//+------------------------------------------------------------------+
//| Function to check TradeTime                                      |
//+------------------------------------------------------------------+
bool tradeTime()
  {
   int startHour,endHour,startMinute,endMinute;
   startHour = StrToInteger(StringSubstr(openTime,0,2));
   startMinute = StrToInteger(StringSubstr(openTime,3,2));

   endHour = StrToInteger(StringSubstr(closeTime,0,2));
   endMinute = StrToInteger(StringSubstr(closeTime,3,2));
   bool flag = false;

   if(Hour() >= startHour && Hour() <= endHour)
     {
      if(startHour == endHour)
        {
         if(Minute() >= startMinute && Minute() <= endMinute)
           {
            flag = true;
           }
         else
           {
            flag = false;
           }
        }
      else if(Hour() == startHour)
        {
         if(Minute() >= startMinute)
           {
            flag = true;
           }
         else
           {
            flag = false;
           }
        }
      else if(Hour() == endHour)
        {
         if(Minute() <= endMinute)
           {
            flag = true;
           }
         else
           {
            flag = false;
           }
        }
      else
        {
         flag = true;
        }
     }
   else
     {
      flag = false;
     }

   return flag;

  }

//+------------------------------------------------------------------+
