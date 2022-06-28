//+------------------------------------------------------------------+
//|                                                                  |
//|                                     Copyright © 2021, Eqan Ahmad |
//|                                     https://fiverr.com/eqanahmad |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2021, Eqan Ahmad"
#property link      "https://fiverr.com/eqanahmad"
#property version   "1.1"
#property description "Trade Entry when the SuperTrend Line changes on Current and Higher timeframe"
#property description "Trade Exit when the SuperTrend Line changes on Higher timeframe"
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

datetime current;
double pip = Point,stopLevel,lotSize;
int totalBuy = 0,totalSell = 0,step;
double PV = 1;
string dir = "";
//luxeneckwear//
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
   else if(MarketInfo(Symbol(),MODE_LOTSTEP) == 0.01)
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
   lotSize = autoLot();
   int higherPeriod = getHigherTimeframe();

   if(hasValue(superTrendDown(higherPeriod,2)) && hasValue(superTrendUp(higherPeriod,1)))
      {
      orderCloseSell("SuperTrend Line Changed on " + TFName(higherPeriod));
      }
   else if(hasValue(superTrendUp(higherPeriod,2)) && hasValue(superTrendDown(higherPeriod,1)))
      {
      orderCloseBuy("SuperTrend Line Changed on " + TFName(higherPeriod));
      }

   if(hasValue(superTrendUp(Period(),1)) && hasValue(superTrendUp(higherPeriod,1))
         && (hasValue(superTrendDown(Period(),2)) || hasValue(superTrendDown(higherPeriod,2))))
      {
      orderBuy();
      }
   else if(hasValue(superTrendDown(Period(),1)) && hasValue(superTrendDown(higherPeriod,1))
           && (hasValue(superTrendUp(Period(),2)) || hasValue(superTrendUp(higherPeriod,2))))
      {
      orderSell();
      }
   }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double superTrendUp(int period,int i)
   {
   return iCustom(Symbol(), period, dir + "MQLTA MT4 Supertrend Line", st_objPrefix, st_atrMultiplier, st_atrPeriod, st_atrMaxBars, 0, i);
   }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double superTrendDown(int period, int i)
   {
   return iCustom(Symbol(), period, dir + "MQLTA MT4 Supertrend Line", st_objPrefix, st_atrMultiplier, st_atrPeriod, st_atrMaxBars, 1, i);
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
//|                                                                  |
//+------------------------------------------------------------------+
int getHigherTimeframe()
   {
   switch(Period())
      {
      case PERIOD_M1:
         return PERIOD_M5;
      case PERIOD_M5:
         return PERIOD_M15;
      case PERIOD_M15:
         return PERIOD_M30;
      case PERIOD_M30:
         return PERIOD_H1;
      case PERIOD_H1:
         return PERIOD_H4;
      case PERIOD_H4:
         return PERIOD_D1;
      case PERIOD_D1:
         return PERIOD_W1;
      case PERIOD_W1:
         return PERIOD_MN1;
      case PERIOD_MN1:
         return PERIOD_MN1;
      default:
         return  Period();
      }
   }
//+------------------------------------------------------------------+
//| Period to String                                                 |
//+------------------------------------------------------------------+
string TFName(int period)
   {
   switch(period)
      {
      case PERIOD_M1:
         return("M1");
      case PERIOD_M5:
         return("M5");
      case PERIOD_M15:
         return("M15");
      case PERIOD_M30:
         return("M30");
      case PERIOD_H1:
         return("H1");
      case PERIOD_H4:
         return("H4");
      case PERIOD_D1:
         return("Daily");
      case PERIOD_W1:
         return("Weekly");
      case PERIOD_MN1:
         return("Monthly");
      default:
         return  "";
      }
   }
//+------------------------------------------------------------------+
