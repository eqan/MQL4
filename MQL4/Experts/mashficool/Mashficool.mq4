//+------------------------------------------------------------------+
//|                                                       Mashficool |
//|                                       Copyright © 2021, Mananhfz |
//|                                      https://fiverr.com/mananhfz |
//+------------------------------------------------------------------+
/*
// Algorithm
-> An arrow and a dot will confirm a signal
-> Feature to turn on and off the arrows or dots and so they can work independtly on their own
-> • buy • buy in this scenario only 1 buy would be place as there was no sell in between

// Trade management features
-> Limit order option on then it will not place an immediate market order, it will only place a limit order
-> Let's say there a point where sell signal came, so instead of putting the limit order at the same price, we will put the pending orer 30 pips above in case of sell !Only applicable with limit orders not market orders
-> StopLoss
-> TakeProfit
-> Telegram Signals Broad Caster
*/

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

input settings sbs = 0;                                       // ===== SBNR Arrows =====
input int sbnr_maxHistoryBars = 5;                            // Max History Bars
input string sbnr_timeFrame = "M1";
input int sbnr_rsiPerid1 = 2;                                 // RSI Period 1
input int sbnr_rsiPerid2 = 3;                                 // RSI Period 2
input int sbnr_rsiPerid3 = 4;                                 // RSI Period 3
input int sbnr_rsiPerid4 = 5;                                 // RSI Period 4
input int sbnr_maType = 1;                                    // MA Type
input int sbnr_maPeriod = 2;                                  // MA Period
input bool sbnr_Interpolate = true;                           // Interpolate
input string sbnr_arrowsIdentifier = "SNL arrows";            // Arrows Identifier
bool alertsOn = false;                                        // Alerts On? ?
bool alertsSound = false;                                     // Alerts Message ?
bool alertsEmail = false;                                     // Alerts Email ?
bool isOrderClosed = true;

int orderHistoryTotal();
datetime current;
double pip = Point,stopLevel,lotSize, PV=0, TV=0;
int totalBuy = 0,totalSell = 0,step, tradeNumber = 0,history = orderHistoryTotal();
string dir="";

//mashficool\\
//+------------------------------------------------------------------+
//| Expert initialization function                                   |
//+------------------------------------------------------------------+
int OnInit()
  {
//---
   TV = MarketInfo(Symbol(),MODE_TICKVALUE);
   pip = pip * 10.0;
   stopLevel = MarketInfo(Symbol(),MODE_STOPLEVEL) * pip;
   step = (MarketInfo(Symbol(),MODE_LOTSTEP) == 0.1) + 2 * (MarketInfo(Symbol(),MODE_LOTSTEP) == 0.01);
   lotSize = NormalizeDouble(LotSize,step);
   if(MarketInfo(Symbol(),MODE_LOTSTEP) == 0.1)
      PV = 1;
   else
      if(MarketInfo(Symbol(),MODE_LOTSTEP) == 0.01)
         PV = 10;
      else
         PV = 0.1;
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
   int h = orderHistoryTotal();
   ordersTotal();
   if(history != h)
     {
      onTradeClose(h - history);
      history = h;
     }
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
   double sbnrUp = iCustom(Symbol(), 0, dir + "SBNR arrows (NRP) 4 Periods",sbnr_maxHistoryBars, sbnr_timeFrame, sbnr_rsiPerid1, sbnr_rsiPerid2, sbnr_rsiPerid3, sbnr_rsiPerid4, sbnr_maType, sbnr_maPeriod, sbnr_Interpolate, sbnr_arrowsIdentifier, alertsOn, alertsSound, alertsEmail, 0, 1);
   double sbnrDown = iCustom(Symbol(), 0, dir + "SBNR arrows (NRP) 4 Periods",sbnr_maxHistoryBars,sbnr_timeFrame, sbnr_rsiPerid1, sbnr_rsiPerid2, sbnr_rsiPerid3, sbnr_rsiPerid4, sbnr_maType, sbnr_maPeriod, sbnr_Interpolate, sbnr_arrowsIdentifier, alertsOn, alertsSound, alertsEmail, 1, 1);
   if(hasValue(sbnrUp))
     {
      orderCloseSell("Order Sell Closed!");
      orderBuy();
     }
   if(hasValue(sbnrDown))
     {
      orderCloseBuy("Order Buy Closed!");
      orderSell();
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
         tradeNumber++;
         generateMessageForTelegram(OP_BUY, !isOrderClosed);
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
         tradeNumber++;
         generateMessageForTelegram(OP_SELL, !isOrderClosed);
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
              {
               Print("Buy Order closed on " + com);
               generateMessageForTelegram(OP_BUY, isOrderClosed);
              }
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
              {
               Print("Sell Order closed on " + com);
               generateMessageForTelegram(OP_SELL, isOrderClosed);
              }
           }
        }
     }
  }

//+------------------------------------------------------------------+
//| Determines & Send's Appropriate Message To Telegram  `            |
//+------------------------------------------------------------------+
void generateMessageForTelegram(ENUM_ORDER_TYPE order, bool isOrderCloseTrade)
  {
   double profit = OrderProfit()+OrderSwap()+OrderCommission();
   double roi= profit*100.0/(AccountBalance()-profit);
   string message;
   if(order == 0 && !isOrderCloseTrade)
      message = "BUY Signal at "  + DoubleToStr(Ask);
   else
      if(order == 0 && isOrderCloseTrade)
         message =  "EXIT BUY Signal at "  + DoubleToStr(Ask);
      else
         if(!order == 0 && !isOrderCloseTrade)
            message = "SELL Signal at "  + DoubleToStr(Bid);
         else
            if(!order == 0 && isOrderCloseTrade)
               message =  "EXIT SELL Signal at "  + DoubleToStr(Bid);

   message += "\nDate: "  + returnCurrentDate() +
              "\nTime: " + returnCurrentTime() +
              "\nTrade number: " + IntegerToString(tradeNumber) + "\n";
   if(isOrderCloseTrade)
      message+="ROI: " + returnPositiveFormatString(roi) + "%\n";
   tms_send(message);
  }
//+------------------------------------------------------------------+
//| Check if values are positive then add a positive sig             |
//+------------------------------------------------------------------+
string returnPositiveFormatString(double value)
  {
   if(value >= 0)
      return ("+" + DoubleToString(value, 5));
   return (DoubleToString(value, 5));
  }

//+------------------------------------------------------------------+
//| Return Date                                                      |
//+------------------------------------------------------------------+
string returnCurrentDate()
  {
   MqlDateTime utcTime;
   TimeGMT(utcTime);
   return StringConcatenate(utcTime.mon, ".", utcTime.day, ".", utcTime.year, "\n");
  }
//+------------------------------------------------------------------+
//| Return Time                                                      |
//+------------------------------------------------------------------+
string returnCurrentTime()
  {
   MqlDateTime utcTime;
   TimeGMT(utcTime);
   return StringConcatenate(utcTime.hour, ":",utcTime.min, " hrs UTC\n");
  }
//+------------------------------------------------------------------+
//| Telegram Message Function                                        |
//+------------------------------------------------------------------+
void tms_send(string message)
  {
   Print(message);
  }
//+------------------------------------------------------------------+
//| Expert Trade Close function                                      |
//+------------------------------------------------------------------+
void onTradeClose(int count)
  {
   int j = 0;
   for(int i = OrdersHistoryTotal() - 1; i >= 0; --i) // Cycle searching in orders
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY) == true)
        {
         if(j < count && OrderSymbol() == Symbol() && OrderMagicNumber() == magicNumber)
           {
            if(OrderType() == OP_BUY)
               generateMessageForTelegram(OP_BUY, isOrderClosed);
            if(OrderType() == OP_SELL)
               generateMessageForTelegram(OP_SELL, isOrderClosed);
            ++j;
           }
        }
     }
  }
//+----------------------------------------------------------------------+
//| Function to return the number of History trades on the current Pair  |
//+----------------------------------------------------------------------+
int orderHistoryTotal()
  {
   int c = 0;
   for(int i = OrdersHistoryTotal() - 1; i >= 0; --i) // Cycle searching in orders
     {
      if(OrderSelect(i,SELECT_BY_POS,MODE_HISTORY) == true)
        {
         if(OrderSymbol() == Symbol() && OrderMagicNumber() == magicNumber)
            ++c;
        }
     }
   return c;
  }
//+------------------------------------------------------------------+
