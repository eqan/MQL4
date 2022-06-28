//+------------------------------------------------------------------+
//|                                                                  |
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
input int  maxBarsTill = 50;                                  // Max Bars Till Next Signal
input bool oco = true;                                        // Auto Order Close 

input settings bks = 0;                                       // ===== Break Even =====
input bool allowBreakEven = true;                             // Allow Break Even ?
input int distance = 10;                                      // Distance pips
input int lockInPoints = 2;                                   // Lock Pips

input settings mas1 = 0;                                      // ===== Moving Average 1 =====
input int ma_period1 = 50;                                    // MA Period
input int ma_shift1 = 0;                                      // MA Shift
input ENUM_MA_METHOD  ma_method1 = MODE_EMA;                  // MA Method
input ENUM_APPLIED_PRICE ma_price1 = PRICE_CLOSE;             // MA Price

input settings mas2 = 0;                                      // ===== Moving Average 2 =====
input int ma_period2 = 200;                                   // MA Period
input int ma_shift2 = 0;                                      // MA Shift
input ENUM_MA_METHOD  ma_method2 = MODE_EMA;                  // MA Method
input ENUM_APPLIED_PRICE ma_price2 = PRICE_CLOSE;             // MA Price

input settings als = 0;                                       // ===== Alerts =====
input bool allowAlerts = false;                                // Desktop Alerts ?
input bool allowMobile = false;                                // Mobile Alerts ?
input bool allowEmail = false;                                 // Email Alerts ?


datetime current;
double pip = Point,stopLevel,lotSize;
int totalBuy = 0,totalSell = 0,step;
string dir="Task7\\";
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
   if(current != Time[0])
     {
      current = Time[0];
      order();
     }

   if(allowBreakEven)
      breakEven();
  }
//+------------------------------------------------------------------+
//| Function to Check if the Conditions for the Order has met        |
//+------------------------------------------------------------------+
void order()
  {
   double fastEma_1 = iMA(Symbol(), 0, ma_period1, ma_shift1, ma_method1, ma_price1, 1);
   double fastEma_2 = iMA(Symbol(), 0, ma_period1, ma_shift1, ma_method1, ma_price1, 2);
   double slowEma_1 = iMA(Symbol(), 0, ma_period2, ma_shift2, ma_method2, ma_price2, 1);
   double slowEma_2 = iMA(Symbol(), 0, ma_period2, ma_shift2, ma_method2, ma_price2, 2);


   if(slowEma_2 > fastEma_2 && fastEma_1 > slowEma_1 && Check_Trend() == 'b')
   {
        if(oco)
           orderCloseSell("Order Closed!");
        orderBuy();
   }
    

   else
      if(slowEma_2 < fastEma_2 && fastEma_1 < slowEma_1 && Check_Trend() == 's')
      {
         if(oco)
            orderCloseBuy("Order Closed!");
         orderSell();
      }

   Print("OP BUY: ", OP_BUY, "OP SELL", OP_SELL);
  }
//+------------------------------------------------------------------+
//| Function check trend                                            |
//+------------------------------------------------------------------+
char Check_Trend()
  {
   double upTrend, downTrend;
   for(int i=0; i <=maxBarsTill; ++i)
     {
      upTrend = iCustom(Symbol(), 0, dir + "jayjohnson994", mas1, ma_period1, ma_method1, ma_price1, mas2, ma_period2, ma_method2, ma_price2, als,allowAlerts, allowMobile, allowEmail, 0, i);
      downTrend = iCustom(Symbol(), 0, dir + "jayjohnson994", mas1, ma_period1, ma_method1, ma_price1, mas2, ma_period2, ma_method2, ma_price2, als,allowAlerts, allowMobile, allowEmail, 1, i);

      if(hasValue(upTrend))
         return 'b';

      else
         if(hasValue(downTrend))
            return 's';
     }
   return '0';
  }

//+------------------------------------------------------------------------+
//| Function to return True if the double has some value, false otherwise  |
//+------------------------------------------------------------------------+
bool hasValue(double val)
  {
   return (val !=0 && val != EMPTY_VALUE);
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
