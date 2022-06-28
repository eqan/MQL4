//+------------------------------------------------------------------+
//|                                                     KARAR3 Trade |
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
input int trailingStart = 200;                                // Trailing Start
input int trailingStep = 150;                                 // Trailing Stop

input settings bks = 0;                                       // ===== Break Even =====
input bool allowBreakEven = true;                             // Allow Break Even ?
input int distance = 10;                                      // Distance pips
input int lockInPoints = 2;                                   // Lock Pips

input settings mkas = 0;                                       // ===== ML 400 karar 3 Indicator =====
input int mk_fastMovingAverage = 5;                               // Fast Moving Average
input int mk_slowMovingAverage = 12;                              // Slow Moving Average
input int mk_rsiPeriod = 12;                                      // RSI Period
input int mk_magicFilterPeriod = 1;                               // Magic Filter Period
input int mk_bollingerBandsPeriod = 10;                           // Bollinger Bands Period
input int mk_bollingerBandsShift = 0;                             // Bollinger Bands Shift
input double mk_bollingerBandsDeviation = 0.5;                    // Bollinger Bands Deviation
input int mk_bullPowerPeriod = 50;                                // Bull Power Period
input int mk_bearPowerPeriod = 50;                                // Bear Power Period
input int mk_utStup = 10;                                         // Utstup

input settings has = 0;                                         // ===== Heiken Ashi Indicator =====
input color bearShadow = clrRed;                                // Bear Shadow
input color bullShadow = clrWhite;                              // Bull Shadow
input color bearBody = clrRed;                                  // Bear Body
input color bullBody = clrWhite;                                // Bull Body
input int fluctionUpper = 80;                                   // Fluction Upper
input int fluctionLower = -80;                                  // Fluction Lower

input settings fls = 0;                                       // ===== Fluction Indicator ====
input int fl_ValueBuy =  -25;                                 // FL Buy Value
input int fl_ValueSell =   25;                                // FL Sell Value
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
input bool pb_Interpolate = true;                               // Interpolat

input settings als = 0;                                       // ===== Alerts =====
input bool allertOn = false;                                    // Allert ?
input bool allertOnCurrent = false;                             // Current Alert ?
input bool allertMessage = false;                               // Mobile Alerts ?
input bool allertSound = false;                                 // Sound Alert ?
input bool allertEmail = false;                                 // Email Alerts ?
input bool allertNotify = false;                                // Notification Alert ?
input string fl_Sound = "alert2.wav";                           // Alert Sound
input bool allertOnHighLow = false;                             // Alert On High Low


datetime current,prevBuy, prevSell;
double pip = Point,stopLevel,lotSize;
int totalBuy = 0,totalSell = 0,step;
string dir="Karar3\\";
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
///   if(current != Time[0])
     {
      current = Time[0];
      order();
     }

   if(allowBreakEven)
      breakEven();
   trailingStop();
  }
//+------------------------------------------------------------------+
//| Function to Check if the Conditions for the Order has met        |
//+------------------------------------------------------------------+
void order()
  {
   double fluctionValue  = iCustom(Symbol(), 0, dir + "Fluction indicator", fl_TimeFrame, fl_period, fl_Level, fl_Smooth, fl_AdaptPeriod, allertOn, allertOnCurrent, allertMessage, allertSound, allertNotify, allertNotify,fl_Sound, 1, 1);
   double fluctionValue3 = iCustom(Symbol(), 0, dir + "Fluction indicator", fl_TimeFrame, fl_period, fl_Level, fl_Smooth, fl_AdaptPeriod, allertOn, allertOnCurrent, allertMessage, allertSound, allertNotify, allertNotify,fl_Sound, 2, 1);
   double heikenOpen = iCustom(Symbol(), 0, dir + "Heiken Ashi",  bearShadow, bullShadow, bearBody, bullBody, 2, 1);
   double heikenClose= iCustom(Symbol(), 0, dir + "Heiken Ashi",  bearShadow, bullShadow, bearBody, bullBody, 3, 1);
   double mlKararBuy  = iCustom(Symbol(), 0, dir + "ML 400 Karar 3", mk_fastMovingAverage, mk_slowMovingAverage, mk_rsiPeriod, mk_magicFilterPeriod, mk_bollingerBandsPeriod, mk_bollingerBandsShift, mk_bollingerBandsDeviation, mk_bullPowerPeriod, mk_bearPowerPeriod, allertOn, mk_utStup, 0, 1);
   double mlKararSell = iCustom(Symbol(), 0, dir + "ML 400 Karar 3", mk_fastMovingAverage, mk_slowMovingAverage, mk_rsiPeriod, mk_magicFilterPeriod, mk_bollingerBandsPeriod, mk_bollingerBandsShift, mk_bollingerBandsDeviation, mk_bullPowerPeriod, mk_bearPowerPeriod, allertOn, mk_utStup, 1, 1);
   double priceMiddle = iCustom(Symbol(), 0, dir + "PriceBorder", pb_TimeFrame, pb_HalfLength, pb_Price, pb_AtrMultiplier, pb_AtrPeriod, pb_Interpolate, allertOn, allertOnCurrent, allertOnHighLow, allertMessage, allertSound, allertEmail, 0, 1);

   if(fluctionValue > fluctionUpper  && heikenClose < heikenOpen)
      orderCloseBuy("Buy order closed on condtion 1!");
   else
      if(hasValue(fluctionValue3) && heikenClose < heikenOpen)
         orderCloseBuy("Buy order closed on condtion 2!");
   if(fluctionValue < fluctionLower  && heikenClose > heikenOpen)
      orderCloseSell("Sell order closed on condtion 1!");
   else
      if(!hasValue(fluctionValue3) && heikenClose > heikenOpen)
         orderCloseSell("Sell order closed on condtion 2!");

   if(prevBuy != Time[0] && fluctionValue < fl_ValueBuy && hasValue(mlKararBuy) && !hasValue(fluctionValue3) && heikenClose > heikenOpen && Close[1] < priceMiddle)
      orderBuy();
   else
      if(prevSell != Time[0] && fluctionValue > fl_ValueSell && hasValue(mlKararSell) && hasValue(fluctionValue3) && heikenClose < heikenOpen && Close[1] > priceMiddle)
         orderSell();
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
         prevBuy=Time[0];
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
         prevSell=Time[0];
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
//| Trailing Stop Function                                           |
//+------------------------------------------------------------------+
void trailingStop()
  {
   for(int i = OrdersTotal() -1; i >= 0; i--)
     {
      if(OrderSelect(i, SELECT_BY_POS) && OrderSymbol() == Symbol())
        {
         if(OrderType() == OP_BUY &&  Bid - OrderOpenPrice() >= trailingStart * Point && OrderStopLoss() < Bid - trailingStep* Point)
           {
            printf("%f < %f", OrderStopLoss(), Bid - trailingStart * Point);
            OrderModify(OrderTicket(), OrderOpenPrice(), NormalizeDouble(Bid - trailingStep * Point, Digits), OrderTakeProfit(), 0);
            Print("Modified buy by trailing stop");
           }
         else
            if(OrderType() == OP_SELL &&  OrderOpenPrice() - Ask >= trailingStart * Point  && (OrderStopLoss() > Ask + trailingStep * Point || OrderStopLoss() == 0))
              {
               printf("%f > %f", OrderStopLoss(), Ask + trailingStart * Point);
               OrderModify(OrderTicket(), OrderOpenPrice(), NormalizeDouble(Ask + trailingStep * Point, Digits), OrderTakeProfit(), 0);
               Print("Modified buy by trailing stop");
              }
            else
               printf("%f == %f", OrderStopLoss(), Ask + trailingStart * Point);
        }
     }
  }
//+------------------------------------------------------------------+