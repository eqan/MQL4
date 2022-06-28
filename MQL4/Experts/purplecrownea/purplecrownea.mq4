//+------------------------------------------------------------------+
//|                                                  Purple Crown EA |
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
enum en_lotSize
  {
   FIXED = 0, //FIXED
   AUTOMATIC = 1, //AUTOMATIC
  };

input settings gs = 0;                                        // ===== General =====
input int slippage = 5;                                       // Slippage
input int magicNumber = 123;                                  // Magic Number
input double takeProfit = 20;                                 // Take Profit (Pips)
input double stopLoss = 30;                                   // Stop Loss (Pips)

input settings ls = 0;                                        // ===== Lot Size Settings =====
input en_lotSize lotType = 0;                                 // Lot type
input double LotSize = 0.01;                                  // Fixed Lot Size
input double riskSL = 1;                                      // Risk% for Autolot

input settings hma1s = 0;                                     // ===== HMA 1 Settings =====
input string hma1_timeFrame = "240";                          // Time Frame
input int hma1_Period = 9;                                    // Period
input int hma1_PriceType = 0;                                 // Price Type
input int hma1_Method = 3;                                    // Method

input settings hma2s = 0;                                     // ===== HMA 2 Settings =====
input string hma2_timeFrame = "1440";                         // Time Frame
input int hma2_Period = 9;                                    // Period
input int hma2_PriceType = 0;                                 // Price Type
input int hma2_Method = 3;                                    // Method

input settings hma3s = 0;                                     // ===== HMA 3 Settings =====
input string hma3_timeFrame = "10080";                        // Time Frame
input int hma3_Period = 6;                                    // Period
input int hma3_PriceType = 0;                                 // Price Type
input int hma3_Method = 3;                                    // Method

bool hma_alertsOn = false;                                    // Alerts On ?
bool hma_alertsOnCurrent = false;                             // Alerts On Current ?
bool hma_alertsMessage = false;                               // Alerts Message ?
bool hma_alertsSound = false;                                 // Alerts Sound ?
bool hma_alertsEmail = false;                                 // Alerts Email ?
bool hma_showArrows = false;                                  // Show Arrows ?
string hma_arrowsIdentifer = "HMA Arrows";                    // Arrows Identifer
double hma_arrowsUpperGap = 0.5;                              // Arrows Upper Gap
double hma_arrowsLowerGap = 0.5;                              // Arrows Lower Gap
color hma_arrowUpColor = clrLimeGreen;                        // Arrow Up Color
color hma_arrowDownColor = clrRed;                            // Arrow Down Color
color hma_arrowUpCode = C'250,250,250';                       // Arrow Up Code
color hma_arrowDownCode = C'250,250,250';                     // Arrow Down Code
int hma_arrowsUpSize = 2;                                     // Arrow Up Size
int hma_arrowsDownSize = 2;                                   // Arrow Down Size
bool hma_Interpolate = true;                                  // Interpolate

datetime current;
double pip = Point,stopLevel,lotSize, PV=1;
int totalBuy = 0,totalSell = 0,step=2;
string dir="purplecrownea\\";
//purplecrownea\\
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
   if(lotType == 1)
     {
      if(MarketInfo(Symbol(),MODE_LOTSTEP) == 0.1)
        {
         step = 1;
         PV = 1;
        }
      else
         if(MarketInfo(Symbol(),MODE_LOTSTEP) == 0.01)
           {
            step = 2;
            PV = 10;
           }
         else
           {
            step = 0;
            PV = 0.1;
           }
      lotSize = autoLot();
     }
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
   /* Conditions:
      - Translation of ultra signal from red to blue or vice versa
      - If first condtion meets than we check if all hma's are of green color or vice versa
   */
   double ultraSignal_red_1 = iCustom(Symbol(), 0, dir + "Ultra-Signal", 0, 1);
   double ultraSignal_red_2 = iCustom(Symbol(), 0, dir + "Ultra-Signal", 0, 2);
   double ultraSignal_blue_1 =  iCustom(Symbol(), 0, dir + "Ultra-Signal", 1, 1);
   double ultraSignal_blue_2 =  iCustom(Symbol(), 0, dir + "Ultra-Signal", 1, 2);
   double hma1_Value4 = iCustom(Symbol(), 0, dir + "hma slope color nrp - mtf _ alerts _ arrows", hma1_timeFrame,
                        hma1_Period, hma1_PriceType, hma1_Method, hma_alertsOn, hma_alertsOnCurrent, hma_alertsMessage,
                        hma_alertsSound, hma_alertsEmail, hma_showArrows, hma_arrowsIdentifer,
                        hma_arrowsUpperGap, hma_arrowsLowerGap, hma_arrowUpColor, hma_arrowDownColor, hma_arrowUpCode,
                        hma_arrowDownCode, hma_arrowsUpSize, hma_arrowsDownSize, hma_Interpolate, 3, 1);
                        
   double hma2_Value4 = iCustom(Symbol(), 0, dir + "hma slope color nrp - mtf _ alerts _ arrows", hma2_timeFrame,
                        hma2_Period, hma2_PriceType, hma2_Method, hma_alertsOn, hma_alertsOnCurrent, hma_alertsMessage,
                        hma_alertsSound, hma_alertsEmail, hma_showArrows, hma_arrowsIdentifer,
                        hma_arrowsUpperGap, hma_arrowsLowerGap, hma_arrowUpColor, hma_arrowDownColor, hma_arrowUpCode,
                        hma_arrowDownCode, hma_arrowsUpSize, hma_arrowsDownSize, hma_Interpolate, 3, 1);
  
   double hma3_Value4 = iCustom(Symbol(), 0, dir + "hma slope color nrp - mtf _ alerts _ arrows", hma3_timeFrame,
                        hma3_Period, hma3_PriceType, hma3_Method, hma_alertsOn, hma_alertsOnCurrent, hma_alertsMessage,
                        hma_alertsSound, hma_alertsEmail, hma_showArrows, hma_arrowsIdentifer,
                        hma_arrowsUpperGap, hma_arrowsLowerGap, hma_arrowUpColor, hma_arrowDownColor, hma_arrowUpCode,
                        hma_arrowDownCode, hma_arrowsUpSize, hma_arrowsDownSize, hma_Interpolate, 3, 1);
 
   /*Print(hma3_timeFrame,hma3_Period, hma3_PriceType, hma3_Method, hma_alertsOn, hma_alertsOnCurrent, hma_alertsMessage,
                        hma_alertsSound, hma_alertsEmail, hma_showArrows, hma_arrowsIdentifer,
                        hma_arrowsUpperGap, hma_arrowsLowerGap, hma_arrowUpColor, hma_arrowDownColor, hma_arrowUpCode,
                        hma_arrowDownColor, hma_arrowsUpSize, hma_arrowsDownSize, hma_Interpolate);*/
                        
   if(hasValue(ultraSignal_blue_1) && hasValue(ultraSignal_red_2))
      orderCloseSell("Sell Order Closed!");
   if(hasValue(ultraSignal_blue_2) && hasValue(ultraSignal_red_1))
      orderCloseBuy("Buy Order Closed!");
   if(hasValue(ultraSignal_blue_1) && hasValue(ultraSignal_red_2) && !hasValue(hma1_Value4) && !hasValue(hma2_Value4) && !hasValue(hma3_Value4))
      orderBuy();
   if(hasValue(ultraSignal_blue_2) && hasValue(ultraSignal_red_1) && hasValue(hma1_Value4) && hasValue(hma2_Value4) && hasValue(hma3_Value4))
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
   if(lotType == 0 || stopLoss == 0)
      return LotSize;

   double l = NormalizeDouble((AccountEquity() * riskSL / 100.0) / (stopLoss * PV),step);
   l = MathMin(MarketInfo(Symbol(),MODE_MAXLOT),l);
   l = MathMax(MarketInfo(Symbol(),MODE_MINLOT),l);
   return l;
  }
//+------------------------------------------------------------------+
