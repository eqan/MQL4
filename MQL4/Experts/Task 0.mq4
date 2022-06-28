//+------------------------------------------------------------------+
//|                                             Custom Indicator.mq4 |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

input double _TP = 100;                  // TP
input double _SL = 100;                  // SL
input double _lotSize = 0.01;            // Lot Size
input int _slippage = 5;                 // Slippage

//+------------------------------------------------------------------+
//| MA 1                                                             |
//+------------------------------------------------------------------+
input int _ma1_period = 50;              // MA 1 Period
input int _ma1_mashift = 0;              // MA 1 MA Shift
input ENUM_MA_METHOD _ma1_enum_method = MODE_SMA; // MA 1 ENUM Method
input ENUM_APPLIED_PRICE _ma1_applied_price = PRICE_CLOSE; // MA 1 Applied Price

//+------------------------------------------------------------------+
//| MA 2                                                             |
//+------------------------------------------------------------------+
input int _ma2_period = 200;             // MA 2 Period
input int _ma2_mashift = 0;              // MA 2 MA Shift
input ENUM_MA_METHOD _ma2_enum_method = MODE_SMA; // MA 2 ENUM Method
input ENUM_APPLIED_PRICE _ma2_applied_price = PRICE_CLOSE; // MA 2 Applied Price


datetime time;
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---

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

   if(time != Time[0])
     {
      time = Time[0];
      order();
     }
  }
//+------------------------------------------------------------------+
//| Order Function                                                   |
//+------------------------------------------------------------------+
void order()
  {
   double fast_1 = NormalizeDouble(iMA(Symbol(), 0,  _ma1_period, _ma1_mashift, _ma1_enum_method, _ma1_applied_price, 1), Digits);
   double slow_1 = NormalizeDouble(iMA(Symbol(), 0,  _ma2_period, _ma2_mashift, _ma2_enum_method, _ma2_applied_price, 1), Digits);
   double slow_2 = NormalizeDouble(iMA(Symbol(), 0,  _ma2_period, _ma2_mashift, _ma2_enum_method, _ma2_applied_price, 2), Digits);
   double fast_2 = NormalizeDouble(iMA(Symbol(), 0,  _ma1_period, _ma1_mashift, _ma1_enum_method, _ma1_applied_price, 2), Digits);
   double rsiResult = iRSI(Symbol(), 0, 5, PRICE_CLOSE, 1);
   if(fast_2 > slow_2 && slow_1 > fast_1 && rsiResult > 70)
     {
      orderSell();
     }
   else
      if(slow_2 > fast_2 && fast_1 > slow_1 && rsiResult < 30)
        {
         orderBuy();
        }
  }
//+------------------------------------------------------------------+
//| Order Buy Function                                               |
//+------------------------------------------------------------------+
void orderBuy()
  {
   double TP = NormalizeDouble(Ask + _TP * Point, Digits);
   double SL = NormalizeDouble(Ask - _SL * Point, Digits);
   int ticket=OrderSend(Symbol(), OP_BUY, _lotSize, Ask, _slippage, SL, TP, "Buy Order", 0, 0, clrGreen);
   if(ticket<0)
     {
      Print("BUY: ", SL, "TP: ", TP);
      Print("BUY: OrderSend failed with error #",GetLastError());
     }
   else
      Print("BUY: OrderSend placed successfully");
  }
//+------------------------------------------------------------------+
//| Order Sell Function                                              |
//+------------------------------------------------------------------+
void orderSell()
  {
   double TP = NormalizeDouble(Bid - _TP * Point, Digits);
   double SL = NormalizeDouble(Bid + _SL * Point, Digits);
   int ticket=OrderSend(Symbol(), OP_SELL, _lotSize, Bid, _slippage, SL, TP, "Sell Order", 0, 0, clrRed);
   if(ticket<0)
     {
      Print("SL: ", SL, "TP: ", TP);
      Print("SL: OrderSend failed with error #",GetLastError());
     }
   else
      Print("SL: OrderSend placed successfully");
  }