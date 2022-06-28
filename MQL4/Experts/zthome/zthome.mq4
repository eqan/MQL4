//+------------------------------------------------------------------+
//|                                                                  |
//|                                     Copyright © 2022, Eqan Ahmad |
//|                                     https://fiverr.com/eqanahmad |
//+------------------------------------------------------------------+
/*
   EA that:

   ✅-Opens 2 trades at once. (One with take profit other without, but
   moves stoploss to breakeven once the first takes profit.)

   ✅-Has dynamic stop loss and take profit based on ATR (take profit is 1x ATR, stoploss is 1.5x
   ATR, also if you can leave those numbers adjustible and not hard code them, that would
   be nice)

   ✅-Risks 1-2% of an account per trade (also not hard code it)

   ✅-Uses moving average, "Absolute Strengs HIstogram" and "Solar Wind" to determine a trade
   direction and exit. (indicators included, and their values not hard code)

   ✅*for short trades: if price is bellow moving average and both indicators are red, enter the trade.
   Exit when one of the indicators changes color, or hits stoploss.

   ✅*for long trades: if price is above moving average and both indicators are green, enter the
   trade. Exit when one of the indicators changes color, or hits stoploss.

   ✅*Reenters trade short: when short has been stopped out, looks at the candle where it exited
   and next two, if any of them is a bearish candle enters a short trade. In reenters baseline
   doesnt matter.

   ✅*Reenters trade long: when long has been stopped out, looks at the candle where it exited
   and next two, if any of them is a bullish candle enters a long trade. In reenters baseline
   doesnt matter.

   If anythings is unclear please contact me. I have also added the indicators once again in the files and some screenshots
   showing how trades work. I would like to use it to trade japanese yen pairs, and gold/silver and also S&P500 indicies so
   please make it work for those too!

   I have also added an indicator that calculates stoploss and takeprofit values, maybe it help
   you to understand what I meant. (its called No_Nonsense_ATR)

*/

#property copyright "Copyright © 2022, Eqan Ahmad"
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
input int magicNumber1 = 123;                                 // 1st Trade Magic Number
input int magicNumber2 = 1234;                                // 2nd Trade Magic Number
//input double takeProfit = 20;                               // Take Profit (Pips)
//input double stopLoss = 30;                                 // Stop Loss (Pips)
input double percentageRisk = 0.00002;                        // Percentage Risk

input settings atrs = 0;                                      // ===== ATR Setup =====
input int atrPeriod = 14;                                     // ATR Period
input double atrTP = 1;                                       // ATR TP Multiplier
input double atrSL = 1.5;                                     // ATR SL Multiplier

input settings mas = 0;                                       // ===== Moving Average Setup =====
input int ma_Period = 5;                                      // Period
input int ma_Shift = 0;                                       // Shift
input ENUM_MA_METHOD ma_Method = MODE_EMA;                    // Method
//input ENUM_APPLIED_PRICE ma_AppliedPrice = PRICE_CLOSE;       // Applied Price

input settings ashs = 0;                                      // ===== Absolute Strength History Setup =====
input int ash_Mode = 0;                                       // Mode
input int ash_Length = 9;                                     // Length
input int ash_Smooth = 1;                                     // Smooth
input int ash_Signal = 4;                                     // Signal
input int ash_Price = 0;                                      // Price
input int ash_ModeMA = 3;                                     // ModeMA
input int ash_Mode_Histo = 3;                                 // Mode_Histo

input settings sws = 0;                                       // ===== Solar Winds Setup =====
input int sws_Period = 10;                                    // Period

input settings bks = 0;                                       // ===== Break Even =====
input int distance = 10;                                      // Distance pips
input int lockInpips = 2;                                     // Lock Pips

input settings tss = 0;                                       // ===== Trailing Stop =====
input bool allowTrailingStop = true;                          // Allow Trailing Stop ?
input int trailingStart = 200;                                // Trailing Start
input int trailingStep = 150;                                 // Trailing Stop

input settings als = 0;                                       // ===== Alerts =====
input bool allowAlerts = false;                               // Desktop Alerts ?
input bool allowMobile = false;                               // Mobile Alerts ?
input bool allowEmail = false;                                // Email Alerts ?


datetime current;
double pip = Point,stopLevel,lotSize, stopLoss, takeProfit;
int totalBuy = 0,totalSell = 0,step, candleCountAfterChangeShort = 0, candleCountAfterChangeLong = 0;
bool triggerChangeShort = false, triggerChangeLong = false, afterTriggerChangeShort = false, afterTriggerChangeLong = false;
bool enableDoubleTradeCheck = false, allowBreakEven = true;
static int ClosedTrades;
string dir="zthome//";

//+------------------------------------------------------------------+
//| Dynamic Take Profit & Stop Loss                                  |
//+------------------------------------------------------------------+
void updateTPAndSL()
  {
   double atrValue = iCustom(Symbol(), 0,dir + "ATR", atrPeriod,0, 1);
   Print("ATR" + DoubleToStr(atrValue));
   stopLoss = atrSL * atrValue;
   takeProfit = atrTP * atrValue;
  }
  
//+------------------------------------------------------------------+
//| Percentage Risk Close                                            |
//+------------------------------------------------------------------+
void riskAccountPerTrade()
  {
    lotSize=NormalizeDouble((AccountEquity()*percentageRisk),2);
    if(lotSize<0.1) lotSize=0.1;
  }

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   pip = pip * 10.0;
   stopLevel = MarketInfo(Symbol(),MODE_STOPLEVEL) * pip;
   step = (MarketInfo(Symbol(),MODE_LOTSTEP) == 0.1) + 2 * (MarketInfo(Symbol(),MODE_LOTSTEP) == 0.01);
   lotSize = NormalizeDouble(LotSize,step);
   updateTPAndSL();
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
//| Open 2 Buy Trades at once 1st TP 2nd Without TP                  |
//+------------------------------------------------------------------+
void orderTwoBuyTrades()
  {
   updateTPAndSL();
   riskAccountPerTrade();
   orderBuy(magicNumber1);
   takeProfit = 0;
   riskAccountPerTrade();
   orderBuy(magicNumber2);
   enableDoubleTradeCheck = true;
  }
  
//+------------------------------------------------------------------+
//| Open 2 Sell Trades at once 1st TP 2nd Without TP                 |
//+------------------------------------------------------------------+
void orderTwoSellTrades()
  {
   updateTPAndSL();
   riskAccountPerTrade();
   orderSell(magicNumber1);
   takeProfit = 0;
   riskAccountPerTrade();
   orderSell(magicNumber2);
   enableDoubleTradeCheck = true;
  }

//+------------------------------------------------------------------+
//| Moves stoploss to breakeven once the first takes profit          |
//+------------------------------------------------------------------+
void moveStoplossToBreakEvenOnFirstTradeTP()
  {
   for(int i = OrdersTotal() -1; i >= 0; --i)
     {
      if(OrderSelect(i, SELECT_BY_POS) && OrderSymbol() == Symbol())
        {
         if( ((OrderType()==OP_BUY)||(OrderType()==OP_SELL)) && (OrderMagicNumber() == magicNumber1))
           {
            if(OrderClosePrice() == OrderTakeProfit())  // Order closed by TP
              {
               allowBreakEven = true;
               enableDoubleTradeCheck = false;
               return;
              }
            if(OrderClosePrice() == OrderStopLoss())  // Order closed by SL
              {
               allowBreakEven = false;
               enableDoubleTradeCheck = false;
               return;
              }
           }
        }
     }
  }

//+------------------------------------------------------------------+
//| Function to Check if the Conditions for the Order has met        |
//+------------------------------------------------------------------+
void order()
  {
   double ma = iMA(NULL, 0, ma_Period,ma_Shift, ma_Method, PRICE_CLOSE, 1);
   double ASH_Bull = iCustom(Symbol(), 0, dir + "AbsoluteSrenghtHisto-v1", ash_Mode, ash_Length, ash_Smooth, ash_Signal, ash_Price, ash_ModeMA, ash_Mode_Histo, 0, 1);
   double ASH_Bear = iCustom(Symbol(), 0, dir + "AbsoluteSrenghtHisto-v1", ash_Mode, ash_Length, ash_Smooth, ash_Signal, ash_Price, ash_ModeMA, ash_Mode_Histo, 1, 1);
   double solarWind = iCustom(Symbol(), 0, dir + "Solar_Winds", sws_Period, 0, 1);
   if(enableDoubleTradeCheck)
   {
      moveStoplossToBreakEvenOnFirstTradeTP();
   }
   if(afterTriggerChangeShort)
     {
      candleCountAfterChangeShort++;
     }
   if(afterTriggerChangeLong)
     {
      candleCountAfterChangeLong++;
     }

   if((Open[1] < ma && Open[1] > Close[1]) || (Close[1] < ma && Close[1] > Open[1]))
     {
      if(solarWind < 0 && ASH_Bear)
        {
         if(triggerChangeLong)
           {
            orderCloseSell("Buy Order Closed Of Long Trade");
            triggerChangeLong = false;
            afterTriggerChangeLong = true;
            candleCountAfterChangeLong = 0;
           }
         orderTwoBuyTrades();
         triggerChangeShort = true;
        }
     }
   else
      if((Open[1] > ma && Open[1] > Close[1]) || (Close[1] > ma && Close[1] > Open[1]))
        {
         if(solarWind > 0 && ASH_Bull)
           {
            if(triggerChangeShort)
              {
               orderCloseBuy("Buy Order Closed Of Short Trade");
               triggerChangeShort = false;
               afterTriggerChangeShort = true;
               candleCountAfterChangeShort = 0;
              }
            orderTwoSellTrades();
            triggerChangeLong = true;
           }
        }
//   *Reenters trade short: when short has been stopped out, looks at the candle where it exited
//   and next two, if any of them is a bearish candle enters a short trade. In reenters baseline
//   doesnt matter.
//
//   *Reenters trade long: when long has been stopped out, looks at the candle where it exited
//   and next two, if any of them is a bullish candle enters a long trade. In reenters baseline
//   doesnt matter.
///  Dont know  what baseline is or what type of bearish we are talking about
   if(afterTriggerChangeShort && ASH_Bear && candleCountAfterChangeShort < 3)
     {
      orderCloseSell("Order close on short trade");
      orderTwoBuyTrades();
      candleCountAfterChangeShort = 0;
      afterTriggerChangeShort = false;
     }
   if(afterTriggerChangeLong && ASH_Bull && candleCountAfterChangeLong < 3)
     {
      orderCloseBuy("Order close on long trade");
      orderTwoSellTrades();
      candleCountAfterChangeLong = 0;
      afterTriggerChangeLong = false;
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
void orderBuy(int magicNumber)
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
void orderSell(int magicNumber)
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
         if(OrderMagicNumber() == magicNumber2 && OrderSymbol() == Symbol())
           {
            if(OrderType() == OP_BUY && (Bid - OrderOpenPrice()) > lockInpips * pip)
              {
               if((Bid - OrderOpenPrice()) >= distance * pip && OrderStopLoss() < OrderOpenPrice())
                 {
                  double sl = NormalizeDouble(OrderOpenPrice() + lockInpips * pip,Digits);

                  if(OrderModify(OrderTicket(),OrderOpenPrice(),sl,OrderTakeProfit(),0,clrRed) > 0)
                     Print("Break even: Buy Order# " + IntegerToString(OrderTicket()) + " modified successfully.");
                  else
                     Print("Break even: Error in Buy# " + IntegerToString(OrderTicket()) + " OrderModify. Error code=",GetLastError());
                 }
              }
            else
               if(OrderType() == OP_SELL && (OrderOpenPrice() - Ask) > lockInpips * pip)
                 {
                  if((OrderOpenPrice() - Ask) >= distance * pip && (OrderStopLoss() > OrderOpenPrice() || OrderStopLoss() == 0))
                    {
                     double sl = NormalizeDouble(OrderOpenPrice() - lockInpips * pip,Digits);

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
         if(OrderSymbol() == Symbol() && (OrderMagicNumber() == magicNumber1 || OrderMagicNumber() == magicNumber2))
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
         if(OrderSymbol() == Symbol() && (OrderMagicNumber() == magicNumber1 || OrderMagicNumber() == magicNumber2) && OrderType() == OP_BUY)
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
         if(OrderSymbol() == Symbol() && (OrderMagicNumber() == magicNumber1 || OrderMagicNumber() == magicNumber2) && OrderType() == OP_SELL)
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
   for(int i = OrdersTotal() -1; i >= 0; --i)
     {
      if(OrderSelect(i, SELECT_BY_POS) && OrderSymbol() == Symbol())
        {
         if(OrderType() == OP_BUY &&  Bid - OrderOpenPrice() >= trailingStart * pip && OrderStopLoss() < Bid - trailingStep* pip)
           {
            if(OrderModify(OrderTicket(), OrderOpenPrice(), NormalizeDouble(Bid - trailingStep * pip, Digits), OrderTakeProfit(), 0))
               Print("Modified buy by trailing stop");
            else
               Print("Not Modified buy by trailing stop");
           }
         else
            if(OrderType() == OP_SELL && OrderOpenPrice() - Ask >= trailingStart * pip && (OrderStopLoss() > Ask + trailingStep * pip || OrderStopLoss() == 0))
              {
               if(OrderModify(OrderTicket(), OrderOpenPrice(), NormalizeDouble(Ask + trailingStep * pip, Digits), OrderTakeProfit(), 0))
                  Print("Modified sell by trailing stop");
               else
                  Print("Not Modified sell by trailing stop");
              }
        }
     }
  }
//+------------------------------------------------------------------+
//| Convert time to string type                                      |
//+------------------------------------------------------------------+
string timeFrame()
  {
   switch(Period())
     {
      case 1:
         return "M1";
      case 5:
         return "M5";
      case 15:
         return "M15";
      case 30:
         return "M30";
      case 60:
         return "H1";
      case 240:
         return "H4";
      case 1440:
         return "Daily";
     }
   return "";
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
