//+------------------------------------------------------------------+
//|                                                Parabolic ADX.mq4 |
//|                        Copyright 2021, MetaQuotes Software Corp. |
//|                                             https://www.mql5.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2021, MetaQuotes Software Corp."
#property link      "https://www.mql5.com"
#property version   "1.00"
#property strict

datetime current;
double _lotSize;
//+------------------------------------------------------------------+
//| User Input                                                       |
//+------------------------------------------------------------------+
input int adx_period = 22;                            // Period ADX
input double step = 0.02;                             // Steps
input double max = 0.2;                               // Max
input ENUM_APPLIED_PRICE applied_price = PRICE_HIGH;  // Applied Price
input double _TP = 100;                               // TP Points
input double _SL = 100;                               // SL Points
input int _slippage = 5;                              // Slippage
input int magicNumber = 123;                          // Magic Number
input double MaxLot = 20;                             // Maximum lots to risk
input double LotsPer10K = 1;                          // Lots per $10K in account
input int breakEvenStart = 30;                        // Break Even Start Point
input int breakEvenLock = 14;                         // Break Even Lock Point             

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
   sellBreakEvenStop();
   buyBreakEvenStop();
  }
//+------------------------------------------------------------------+
//| Order                                                            |
//+------------------------------------------------------------------+
void order()
  {
   double postive_di_1  = iADX(Symbol(), 0, adx_period, applied_price, MODE_PLUSDI, 1);
   double postive_di_2  = iADX(Symbol(), 0, adx_period, applied_price, MODE_PLUSDI, 2);
   double negative_di_1 = iADX(Symbol(), 0, adx_period, applied_price, MODE_MINUSDI, 1);
   double negative_di_2 = iADX(Symbol(), 0, adx_period, applied_price, MODE_MINUSDI, 2);
   double parabolic_sar = iSAR(Symbol(), 0, step, max, 1);
   double lower_candle = MathMin(Close[1], Open[1]);
   double upper_candle = MathMax(Close[1], Open[1]);
   _lotSize = MM_Size();
   if(negative_di_2 > postive_di_2 &&  negative_di_1 < postive_di_1 && parabolic_sar < lower_candle)
     {
      sellOrdersClose();
      orderBuy("Buy Order Placed!");
     }
   else
      if(negative_di_2 < postive_di_2 &&  negative_di_1 > postive_di_1 && parabolic_sar > upper_candle)
        {
         orderSell("Sell Order Placed!");
         buyOrdersClose();
        }
  }
//+------------------------------------------------------------------+
//| Order Buy Function                                               |
//+------------------------------------------------------------------+
void orderBuy(string message)
  {
   double TP = 0;
   double SL = 0;
   if(_TP != 0)
      TP = NormalizeDouble(Ask + _TP * Point, Digits);
   if(_SL != 0)
      SL = NormalizeDouble(Ask - _SL * Point, Digits);
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
   double TP = 0;
   double SL = 0;
   if(_TP != 0)
      TP = NormalizeDouble(Bid - _TP * Point, Digits);
   if(_SL != 0)
      SL = NormalizeDouble(Bid + _SL * Point, Digits);
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
//| Lot size computation.                                            |
//+------------------------------------------------------------------+
double MM_Size() //Calculate position sizing
  {
   double lots = ((AccountBalance() / 10000)*LotsPer10K); //calculate the lot size according to how many lots input per 10K in "LotsPer10K"
   if(lots > MaxLot)
      lots = MaxLot;  //if greater than max set it to the maxlot size
   return(lots);
  }
//+------------------------------------------------------------------+
//| Buy Order Close                                                  |
//+------------------------------------------------------------------+
void buyOrdersClose()
  {
   for(int i = OrdersTotal() - 1; i >= 0; --i)
     {
      if(OrderSelect(i, SELECT_BY_POS) == true)
        {
         int Slippage = 0;
         if(OrderType() == OP_BUY && Symbol() == OrderSymbol() && OrderMagicNumber() == magicNumber)
           {
            if(OrderClose(OrderTicket(), OrderLots(), Bid, Slippage == true))
               Print("Buy Order Closed!");
            else
               Print("ERROR - Unable to close the order - ", OrderTicket(), " - ", GetLastError());
           }
        }
     }
  }
//+------------------------------------------------------------------+
//| Sell Order Close                                                 |
//+------------------------------------------------------------------+
void sellOrdersClose()
  {
   for(int i = OrdersTotal() - 1; i >= 0; --i)
     {
      if(OrderSelect(i, SELECT_BY_POS) == true)
        {
         int Slippage = 0;
         if(OrderType() == OP_SELL && Symbol() == OrderSymbol() && OrderMagicNumber() == magicNumber)
           {
            if(OrderClose(OrderTicket(), OrderLots(), Ask, Slippage == true))
               Print("Sell Order Closed!");
            else
               Print("ERROR - Unable to close the order - ", OrderTicket(), " - ", GetLastError());
           }
        }
     }
  }
//+------------------------------------------------------------------+
//| Buy Break Even Stop                                              |
//+------------------------------------------------------------------+
void buyBreakEvenStop()
  {
   for(int i= OrdersTotal() - 1; i >=0; i--)
     {
      if(OrderSelect(i, SELECT_BY_POS) && OrderType() == OP_BUY && OrderStopLoss() < OrderOpenPrice() && Bid > OrderOpenPrice() + breakEvenLock * Point() && Ask > OrderOpenPrice() + breakEvenStart * Point())
        {
         if(OrderModify(OrderTicket(), OrderOpenPrice(),NormalizeDouble(OrderOpenPrice() + breakEvenLock * Point(), Digits), OrderTakeProfit(), 0))
            Print("Buy Break Activated!");
         else
            Print("Buy Break Not Activated! Ask: ", Ask, " Bid: ", Bid, " Order Open Price: ", OrderOpenPrice() + 14 * Point());
        }
     }
  }
//+------------------------------------------------------------------+
//| Sell Break Even Stop                                             |
//+------------------------------------------------------------------+
void sellBreakEvenStop()
  {
   for(int i= OrdersTotal() - 1; i >=0; i--)
     {
      if(OrderSelect(i, SELECT_BY_POS) && OrderType() == OP_SELL && OrderStopLoss()> OrderOpenPrice() && Bid < OrderOpenPrice() - breakEvenStart * Point())
        {
         if(OrderModify(OrderTicket(), OrderOpenPrice(),NormalizeDouble(OrderOpenPrice() - breakEvenLock * Point(), Digits), OrderTakeProfit(), 0))
            Print("Sell Break Activated!");
         else
            Print("Sell Break Not Activated!: ", MarketInfo(Symbol(), MODE_STOPLEVEL));
        }
     }
  }
//+------------------------------------------------------------------+
