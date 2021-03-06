//+------------------------------------------------------------------+
//|                                                     Ichimoku.mq4 |
//|                                       Copyright © 2021, Mananhfz |
//|                                      https://fiverr.com/mananhfz |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2021, Mananhfz"
#property link      "https://fiverr.com/mananhfz"
#property version   "1.00"
#property strict

//+------------------------------------------------------------------+
//| User Inputs                                                      |
//+------------------------------------------------------------------+
input int tenka_sen = 9;                // Tenka Sen
input int kiju_sen  = 26;                // Kiju Sen
input int senkou_span_b = 52;            // Senkou Sen
input double _TP = 100;                 // TP Points
input double _SL = 100;                 // SL Points
input double _lotSize = 0.01;           // Lot Size
input int _slippage = 5;                // Slippage
input int magicNumber = 123;            // Magic Number


datetime current;
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
//| Order                                                            |
//+------------------------------------------------------------------+
void order()
  {
   double _tenka_sen_1 = iIchimoku(Symbol(), 0, tenka_sen, kiju_sen, senkou_span_b, 1, 1);
   double _tenka_sen_2 = iIchimoku(Symbol(), 0, tenka_sen, kiju_sen, senkou_span_b, 1, 2);
   double _kiju_sen_1  = iIchimoku(Symbol(), 0, tenka_sen, kiju_sen, senkou_span_b, 2, 1);
   double _kiju_sen_2  = iIchimoku(Symbol(), 0, tenka_sen, kiju_sen, senkou_span_b, 2, 2);
   double _senkou_span_a = iIchimoku(Symbol(), 0, tenka_sen, kiju_sen, senkou_span_b, 3, 1);
   double _senkou_span_b = iIchimoku(Symbol(), 0, tenka_sen, kiju_sen, senkou_span_b, 4, 1);

   double upperCloud = _senkou_span_a > _senkou_span_b ? _senkou_span_a : _senkou_span_b;
   double lowerCloud = _senkou_span_a < _senkou_span_b ? _senkou_span_a : _senkou_span_b;

//BUY
   if(_kiju_sen_2 > _tenka_sen_2 && _kiju_sen_1 < _tenka_sen_1  && Close[1] < lowerCloud)
     {
      orderBuy("Buy trade and used 1st condition!");
     }
   if(Open[1] < upperCloud && Close[1] > upperCloud)
      orderBuy("Buy trade and used 2nd condition!");

//SELL
   if(_kiju_sen_2 < _tenka_sen_2 && _kiju_sen_1 > _tenka_sen_1  && Close[1] > upperCloud)
     {
      orderSell("Sell trade and used 1st condition!");
     }
   if(Open[1] > lowerCloud && Close[1] < lowerCloud)
      orderSell("Sell trade and used 2nd condition!");
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
