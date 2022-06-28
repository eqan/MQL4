//+------------------------------------------------------------------+
//|                                                        Stoch.mq4 |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

datetime current;
//+------------------------------------------------------------------+
//| User Inputs                                                      |
//+------------------------------------------------------------------+
input int k = 3;                                      // %K
input int d = 3;                                      // %D
input int slowing = 14;                                // Slowing

input int period_sma = 5;                             // Period SMA
input ENUM_MA_METHOD sma_enum_method = MODE_SMA;          // SMA ENUM Method
input ENUM_APPLIED_PRICE sma_applied_price = PRICE_CLOSE; // SMA Applied Price
input int period_ema = 20;                                // Period EMA
input ENUM_MA_METHOD ema_enum_method = MODE_EMA;          // EMA ENUM Method
input ENUM_APPLIED_PRICE ema_applied_price = PRICE_CLOSE; // EMA Applied Price
input ENUM_MA_METHOD enum_method = MODE_SMA;          // MA 1 ENUM Method


input ENUM_STO_PRICE applied_price = STO_LOWHIGH;     // MA 1 Applied Price
input double _TP = 100;                               // TP Points
input double _SL = 100;                               // SL Points
input double _lotSize = 0.01;                         // Lot Size
input int _slippage = 5;                              // Slippage
input int magicNumber = 123;                          // Magic Number



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
   if(current != Time[0])
     {
      current = Time[0];
      order();
     }

  }
//+------------------------------------------------------------------+
//| Order Function                                                   |
//+------------------------------------------------------------------+
void order()
  {
   double main_stoch_line = iStochastic(Symbol(), 0, k, d, slowing, enum_method, applied_price, MODE_MAIN, 1);
   double main_stoch_line_2 = iStochastic(Symbol(), 0, k, d, slowing, enum_method, applied_price, MODE_MAIN, 2);
   double sma = iMA(Symbol(), 0,period_sma, 0, sma_enum_method, sma_applied_price, 1);
   double ema = iMA(Symbol(), 0,period_ema, 0, ema_enum_method, ema_applied_price, 1);
   if(sma < ema && main_stoch_line_2 < 20 && main_stoch_line > 20)
      orderBuy("Buy order has been placed!");
   else
      if(sma > ema && main_stoch_line_2 > 80 && main_stoch_line < 80)
         orderSell("Sell order has been placed!");

  }
//+------------------------------------------------------------------+
//| Order Buy Function                                               |
//+------------------------------------------------------------------+
void orderBuy(string message)
  {
   double TP = NormalizeDouble(Ask + _TP * Point, Digits);
   double SL = NormalizeDouble(Ask - _SL * Point, Digits);
   int ticket = OrderSend(Symbol(), OP_BUY, _lotSize, Ask, _slippage, SL, TP, "Buy Order", magicNumber, 0, clrGreen);
   if(ticket < 0)
     {
      Print("BUY: ", SL, "TP: ", TP);
      Print("BUY: OrderSend failed with error #",GetLastError());
     }
   else
      Print(message);
  }
//+------------------------------------------------------------------+
//| Order Sell Function                                              |
//+------------------------------------------------------------------+
void orderSell(string message)
  {
   double TP = NormalizeDouble(Bid - _TP * Point, Digits);
   double SL = NormalizeDouble(Bid + _SL * Point, Digits);
   int ticket = OrderSend(Symbol(), OP_SELL, _lotSize, Bid, _slippage, SL, TP, "Sell Order", magicNumber, 0, clrRed);
   if(ticket < 0)
     {
      Print("SL: ", SL, "TP: ", TP);
      Print("SL: OrderSend failed with error #",GetLastError());
     }
   else
      Print(message);
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
