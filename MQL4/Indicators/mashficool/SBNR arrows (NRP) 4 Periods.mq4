//+------------------------------------------------------------------+
//|                                            SBNR arrows (NRP).mq4 |
//|                                       Copyright © 2021, Mananhfz |
//|                                      https://fiverr.com/mananhfz |
//+------------------------------------------------------------------+
#property copyright "Copyright © 2021, Mananhfz"
#property link      "https://fiverr.com/mananhfz"
#property version   "1.00"
#property strict
#property indicator_chart_window
#property indicator_buffers 2
#property indicator_label1 "Up"
#property indicator_label2 "Down"
#property indicator_width1 3
#property indicator_width2 3
#property indicator_color1 Blue
#property indicator_color2 Red



#define FLINESIZE 14 // ðàçìåð çàïèñè ôàéëà ðàâåí 14 áàéò

//TimeFrame, RsiPeriod, MaType, MaPeriod
input int maxBars = 3000; //Max History Bars
extern string TimeFrame = "M1";
extern int RsiPeriod1 = 2;
extern int RsiPeriod2 = 3;
extern int RsiPeriod3 = 4;
extern int RsiPeriod4 = 5;
extern int MaType = 1;
extern int MaPeriod = 2;
extern bool Interpolate = TRUE;
extern string arrowsIdentifier = "SNL arrows";
color arrowsUpColor = Lime;
color arrowsDnColor = Red;
extern bool alertsOn = TRUE;
extern bool alertsMessage = FALSE;
extern bool alertsEmail = FALSE;


double buyBuff[],sellBuff[];
datetime prevBuy,prevSell;
string indicatorName = "SBNR Arrows (NRP) 4 periods";
int i;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexStyle(0,DRAW_ARROW,EMPTY);
   SetIndexArrow(0,233);
   SetIndexBuffer(0,buyBuff);
   SetIndexStyle(1,DRAW_ARROW,EMPTY);
   SetIndexArrow(1,234);
   SetIndexBuffer(1,sellBuff);

   IndicatorShortName(indicatorName);
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
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,
                const int prev_calculated,
                const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---
// Bar index
   int Counted_bars;                // Number of counted bars
   Counted_bars = IndicatorCounted(); // Number of counted bars
   i = Bars - Counted_bars - 1;   // Index of the first uncounted
   if(i > maxBars)
      i = maxBars;
   if(i > 1)
      --i;
   while(i > 0)
     {
      buyBuff[i] = 0;
      sellBuff[i] = 0;
      ObjectsDeleteAll(0,arrowsIdentifier);

      if((!RsiPeriod1 || hasValue(sbnrBuy(RsiPeriod1))) && (!RsiPeriod2 || hasValue(sbnrBuy(RsiPeriod2)))
            && (!RsiPeriod3 || hasValue(sbnrBuy(RsiPeriod3))) && (!RsiPeriod4 || hasValue(sbnrBuy(RsiPeriod4))))
        {
         buyBuff[i] = Low[i] - getPoint();
         if(i == 1 && prevBuy != Time[0]) //Only Alert if its 1 candle
            doAlert("Buy Signal",Symbol() + " " + TFName() + ": Buy Signal");
        }

      //--- Sell
      else if((!RsiPeriod1 || hasValue(sbnrSell(RsiPeriod1))) && (!RsiPeriod2 || hasValue(sbnrSell(RsiPeriod2)))
              && (!RsiPeriod3 || hasValue(sbnrSell(RsiPeriod3))) && (!RsiPeriod4 || hasValue(sbnrSell(RsiPeriod4))))
        {
         sellBuff[i] = High[i] + getPoint();
         if(i == 1 && prevSell != Time[0]) //Only Alert if its 1 candle
            doAlert("Sell Signal",Symbol() + " " + TFName() + ": Sell Signal");
        }
      --i;
     } // end while
   return(rates_total);
  }
//+------------------------------------------------------------------------+
//| Function to return True if the double has some value, false otherwise  |
//+------------------------------------------------------------------------+
bool hasValue(double val)
  {
   return (val && val != EMPTY_VALUE);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double sbnrBuy(int period)
  {
   return iCustom(Symbol(),Period(),"SBNR arrows (NRP)",TimeFrame,maxBars,period,MaType,MaPeriod,Interpolate,arrowsIdentifier,arrowsUpColor,arrowsDnColor,false,false,false,false,false,0,i);
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double sbnrSell(int period)
  {
   return iCustom(Symbol(),Period(),"SBNR arrows (NRP)",TimeFrame,maxBars,period,MaType,MaPeriod,Interpolate,arrowsIdentifier,arrowsUpColor,arrowsDnColor,false,false,false,false,false,1,i);
  }
//+------------------------------------------------------------------+
//| Period to String                                                 |
//+------------------------------------------------------------------+
string TFName()
  {
   switch(Period())
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
//| Function to Show Alerts                                          |
//+------------------------------------------------------------------+
void doAlert(string title = "",string msg = "")
  {
   msg = indicatorName + " :: "  + msg;
   if(alertsOn)
      Alert(msg);
   if(alertsEmail)
      SendMail(title,msg);
   if(alertsMessage)
      SendNotification(msg);
  }
//+------------------------------------------------------------------+
//| Function to return the distance of arrow from Candle             |
//+------------------------------------------------------------------+
double getPoint()
  {
   int tf = Period();
   if(tf == 1)
      return 5.0 * Point;
   if(tf == 5)
      return 10.0 * Point;
   if(tf == 15)
      return 22.0 * Point;
   if(tf == 30)
      return 44.0 * Point;
   if(tf == 60)
      return 80.0 * Point;
   if(tf == 240)
      return 120.0 * Point;
   if(tf == 1440)
      return 170.0 * Point;
   if(tf == 10080)
      return 500.0 * Point;
   if(tf == 43200)
      return 900.0 * Point;
   return 20.0 * Point;
  }
//+------------------------------------------------------------------+
