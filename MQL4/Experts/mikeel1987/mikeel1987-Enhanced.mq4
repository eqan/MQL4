//+------------------------------------------------------------------+
//|                                                      Mikeel 1987 |
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

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum en_lotSize
  {
   FIXED = 0, //FIXED
   AUTOMATIC = 1, //AUTOMATIC
  };

input settings gs = 0;                                        // ===== General =====
input en_lotSize lotType = 0;                                 // Lot type
input double LotSize = 0.01;                                  // Fixed Lot Size
input double riskSL = 1;                                      // Risk% for Autolot
input int slippage = 5;                                       // Slippage
input int magicNumber = 123;                                  // Magic Number
input double takeProfit = 20;                                 // Take Profit (Pips)
input double stopLoss = 30;                                   // Stop Loss (Pips)

input settings bbs = 0;                                       // ===== Bollinger Bands =====
input int bbPeriod = 20;                                      // Period
input int bbShift = 0;                                        // Shift
input double bbDeviation = 2;                                 // Deviation
input ENUM_APPLIED_PRICE bbAppliedPrice = PRICE_CLOSE;        // Applied Price

input settings tss = 0;                                       // ===== Trailing Stop =====
input bool allowTrailingStop = true;                          // Allow Trailing Stop ?

datetime current;
double pip = Point,stopLevel,lotSize,PV = 1;
int totalBuy = 0,totalSell = 0,step;

//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   pip = pip * 10.0;
   stopLevel = MarketInfo(Symbol(),MODE_STOPLEVEL) * pip;
   if(MarketInfo(Symbol(),MODE_LOTSTEP) == 0.1) // 0.1, 0.2, 0.5, Not 0.04
     {
      step = 1;
      PV = 1; //Pip value
     }
   else if(MarketInfo(Symbol(),MODE_LOTSTEP) == 0.01) //0.01, 0.02,0.2 Not 0.003
     {
      step = 2;
      PV = 10;
     }
   else //1,2,3,4,5 Not 0.1, 0.02
     {
      step = 0;
      PV = 0.1;
     }
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

   if(allowTrailingStop)
      trailingStop();
  }
//+------------------------------------------------------------------+
//| Function to Check if the Conditions for the Order has met        |
//+------------------------------------------------------------------+
void order()
  {
   double bbUpper_1 = iBands(Symbol(), 0, bbPeriod, bbDeviation, bbShift, bbAppliedPrice, MODE_UPPER, 1);
   double bbMiddle_1 = iBands(Symbol(), 0, bbPeriod, bbDeviation, bbShift, bbAppliedPrice, MODE_MAIN, 1);
   double bbMiddle_2 = iBands(Symbol(), 0, bbPeriod, bbDeviation, bbShift, bbAppliedPrice, MODE_MAIN, 2);
   double bbLower_1 = iBands(Symbol(), 0, bbPeriod, bbDeviation, bbShift, bbAppliedPrice, MODE_LOWER, 1);
   if(Close[1] > Open[1] && Close[1] >= bbUpper_1 && Open[1] <= bbUpper_1)
      orderBuy();
   if(Close[1] < Open[1] && bbLower_1 >= Close[1] && bbLower_1 <= Open[1])
      orderSell();
  }

//+------------------------------------------------------------------------+
//| Function to return True if the double has s  ome value, false otherwise|
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
      if(OrderSend(Symbol(),OP_BUY,autoLot(),Ask,slippage,sl,tp,"",magicNumber,0,clrBlue) < 0)
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
      if(OrderSend(Symbol(),OP_SELL,autoLot(),Bid,slippage,sl,tp,"",magicNumber,0,clrRed) < 0)
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
//| Function to return the AutoLot                                   |
//+------------------------------------------------------------------+
double autoLot()
  {
   if(lotType == 0 || stopLoss == 0)
      return lotSize;

   double l = NormalizeDouble((AccountEquity() * riskSL / 100.0) / (stopLoss * PV),step);
   l = MathMin(MarketInfo(Symbol(),MODE_MAXLOT),l);
   l = MathMax(MarketInfo(Symbol(),MODE_MINLOT),l);
   return l;
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
   double bbMiddle = NormalizeDouble(iBands(Symbol(), 0, bbPeriod, bbDeviation, bbShift, bbAppliedPrice, MODE_MAIN, 1), Digits);
   for(int i = OrdersTotal() - 1; i >= 0; --i)
     {
      if(OrderSelect(i, SELECT_BY_POS) && OrderSymbol() == Symbol())
        {
         if(OrderType() == OP_BUY && OrderStopLoss() != bbMiddle)
           {
            if(OrderModify(OrderTicket(), OrderOpenPrice(), bbMiddle, OrderTakeProfit(), 0))
               Print("Modified buy by trailing stop");
            else
               Print("Not Modified buy by trailing stop");
           }
         else if(OrderType() == OP_SELL && OrderStopLoss() != bbMiddle)
           {
            if(OrderModify(OrderTicket(), OrderOpenPrice(), bbMiddle, OrderTakeProfit(), 0))
               Print("Modified sell by trailing stop");
            else
               Print("Not Modified sell by trailing stop");
           }
        }
     }
  }
//+------------------------------------------------------------------+
