#property link          "https://www.earnforex.com/metatrader-indicators/supertrend-multi-timeframe/"
#property version       "1.10"
#property strict
#property copyright     "EarnForex.com - 2019-2021"
#property description   "This Indicator will show you the status of the Supertrend"
#property description   "indicator on multiple timeframes."
#property description   " "
#property description   "WARNING : You use this software at your own risk."
#property description   "The creator of these plugins cannot be held responsible for damage or loss."
#property description   " "
#property description   "Find More on EarnForex.com"
#property icon          "\\Files\\EF-Icon-64x64px.ico"

#property indicator_chart_window

#property indicator_buffers 3
#property indicator_color1 clrGreen
#property indicator_color2 clrRed
#property indicator_width1 2
#property indicator_width2 2
#property indicator_style1 STYLE_SOLID
#property indicator_style2 STYLE_SOLID
#property indicator_type1 DRAW_LINE
#property indicator_type2 DRAW_LINE

input string Comment_1 = "====================";   //Indicator Settings
extern double ATRMultiplier = 2.0;                 //ATR Multiplier
extern int ATRPeriod = 100;                        //ATR Period
input int ATRMaxBars = 1000;                       //ATR Max Bars (Max 10.000)
extern int Shift = 0;                                     //Candle shift to Calculate the Supertrend
input string Comment_2b = "====================";  //Enabled Timeframes
extern bool TFM1 = true;                           //Enable Timeframe M1
extern bool TFM5 = true;                           //Enable Timeframe M5
extern bool TFM15 = true;                          //Enable Timeframe M15
extern bool TFM30 = true;                          //Enable Timeframe M30
extern bool TFH1 = true;                           //Enable Timeframe H1
extern bool TFH4 = true;                           //Enable Timeframe H4
extern bool TFD1 = true;                           //Enable Timeframe D1
extern bool TFW1 = true;                           //Enable Timeframe W1
extern bool TFMN1 = true;                          //Enable Timeframe MN1
input string Comment_3 = "====================";   //Notification Options
extern bool EnableNotify = false;                  //Enable Notifications feature
extern bool SendAlert = true;                      //Send Alert Notification
extern bool SendApp = true;                        //Send Notification to Mobile
extern bool SendEmail = true;                      //Send Notification via Email
input string Comment_4 = "====================";   //Graphical Objects
extern bool DrawLinesEnabled = true;               //Draw Lines
extern bool DrawWindowEnabled = true;              //Draw Window
input bool DrawArrowSignal = true;                 //Draw Arrow Signal
input int ArrowCodeUp = SYMBOL_ARROWUP;            //Arrow Code Buy
input int ArrowCodeDown = SYMBOL_ARROWDOWN;        //Arrow Code Sell
extern int Xoff = 20;                              //Horizontal spacing for the control panel
extern int Yoff = 20;                              //Vertical spacing for the control panel
extern string IndicatorName = "MQLTA-SMTF";        //Indicator Name (to name the objects)

double TrendUp[], TrendDown[];
double TrendUpTmp[], TrendDownTmp[];
int changeOfTrend;
int MaxBars = ATRMaxBars;

int CalculatedBars = 0;

bool UpTrend = false;
bool DownTrend = false;

bool TFEnabled[9];
int TFValues[9];
string TFText[9];
int TFTrend[9];

double BufferZero[1];

double LastAlertDirection = 2; // Signal that was alerted on previous alert. Double because BufferZero is double. "2" because "0", "1", and "-1" are taken for signals.

//+------------------------------------------------------------------+
//| Custom indicator initialization function.                        |
//+------------------------------------------------------------------+
int OnInit()
{
    IndicatorSetString(INDICATOR_SHORTNAME, IndicatorName);

    CleanChart();
    CalculatedBars = 0;

    TFEnabled[0] = TFM1;
    TFEnabled[1] = TFM5;
    TFEnabled[2] = TFM15;
    TFEnabled[3] = TFM30;
    TFEnabled[4] = TFH1;
    TFEnabled[5] = TFH4;
    TFEnabled[6] = TFD1;
    TFEnabled[7] = TFW1;
    TFEnabled[8] = TFMN1;
    TFValues[0] = PERIOD_M1;
    TFValues[1] = PERIOD_M5;
    TFValues[2] = PERIOD_M15;
    TFValues[3] = PERIOD_M30;
    TFValues[4] = PERIOD_H1;
    TFValues[5] = PERIOD_H4;
    TFValues[6] = PERIOD_D1;
    TFValues[7] = PERIOD_W1;
    TFValues[8] = PERIOD_MN1;
    TFText[0] = "M1";
    TFText[1] = "M5";
    TFText[2] = "M15";
    TFText[3] = "M30";
    TFText[4] = "H1";
    TFText[5] = "H4";
    TFText[6] = "D1";
    TFText[7] = "W1";
    TFText[8] = "MN1";
    UpTrend = false;
    DownTrend = false;

    ArrayInitialize(TFTrend, 0);
    SetIndexBuffer(2, BufferZero);
    SetIndexStyle(2, DRAW_NONE);
    SetIndexBuffer(0, TrendUp);
    SetIndexLabel(0, "Trend Up");
    SetIndexBuffer(1, TrendDown);
    SetIndexLabel(1, "Trend Down");
    if (!DrawLinesEnabled)
    {
        SetIndexStyle(0, DRAW_NONE);
        SetIndexStyle(1, DRAW_NONE);
    }

    CalculateLevels();

    return INIT_SUCCEEDED;
}

//+------------------------------------------------------------------+
//| Custom indicator iteration function.                             |
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
    if (CalculatedBars != prev_calculated)
    {
        CalculateLevels();
        CalculatedBars = prev_calculated;
    }
    CalculatedBars = prev_calculated;
    FillBuffers();
    CalculateSuperTrend();
    if (EnableNotify)
    {
        Notify();
    }
    if (DrawArrowSignal)
    {
        DrawArrow(0);
    }

    if (DrawWindowEnabled) DrawPanel();
    
    return rates_total;
}

//+------------------------------------------------------------------+
//| Indicator deinitialization.                                      |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
{
    CleanChart();
}

//+------------------------------------------------------------------+
//| Delets all chart objects created by the indicator.               |
//+------------------------------------------------------------------+
void CleanChart()
{
    ObjectsDeleteAll(ChartID(), IndicatorName);
}

//+------------------------------------------------------------------+
//| Main function to detect Positive, Negative, Uncertain state.     |
//+------------------------------------------------------------------+
void CalculateLevels()
{
    int EnabledCount = 0;
    int UpCount = 0;
    int DownCount = 0;
    UpTrend = false;
    DownTrend = false;
    MaxBars = ATRMaxBars;
    ArrayInitialize(TFTrend, 0);
    for (int i = 0; i < ArraySize(TFTrend); i++)
    {
        if (!TFEnabled[i]) continue;
        if (iBars(Symbol(), TFValues[i]) < MaxBars)
        {
            MaxBars = iBars(Symbol(), TFValues[i]);
            Print("Please load more historical candles. Current calculation only on ", MaxBars, " bars for timeframe ", TFText[i], ".");
            if (MaxBars < 0)
            {
                break;
            }
        }
        EnabledCount++;
        int TFValue = TFValues[i];
        string TFDesc = TFText[i];
        double ATRTrend = GetATRTrend(Symbol(), TFValue, Shift);
        if (ATRTrend == 0)
        {
            Print("Not enough historical data, please load more candles for ", TFDesc);
        }
        if (iClose(Symbol(), TFValues[i], Shift) > ATRTrend)
        {
            TFTrend[i] = 1;
            UpCount++;
        }
        if (iClose(Symbol(), TFValues[i], Shift) < ATRTrend)
        {
            TFTrend[i] = -1;
            DownCount++;
        }
    }
    if (UpCount == EnabledCount) UpTrend = true;
    if (DownCount == EnabledCount) DownTrend = true;
}

//+------------------------------------------------------------------+
//| Calculates Superеrend for a giveт timeframe.                     |
//+------------------------------------------------------------------+
double GetATRTrend(string Instrument = NULL, int Timeframe = 0, int shift = 0)
{
    ArrayResize(TrendDownTmp, ATRMaxBars, 0);
    ArrayInitialize(TrendDownTmp, 0);
    ArrayResize(TrendUpTmp, ATRMaxBars, 0);
    ArrayInitialize(TrendUpTmp, 0);
    if (Instrument == NULL) Instrument = Symbol();
    if (Timeframe == 0) Timeframe = Period();
    CalculateSupertrendTmp(Timeframe);

    double ATRTrend1 = TrendUpTmp[shift];
    double ATRTrend2 = TrendDownTmp[shift];

    if (ATRTrend1 > (iClose(Instrument, Timeframe, shift) * 2))
    {
        return NormalizeDouble(ATRTrend2, (int)MarketInfo(Instrument, MODE_DIGITS));
    }
    if (ATRTrend2 > (iClose(Instrument, Timeframe, shift) * 2))
    {
        return NormalizeDouble(ATRTrend1, (int)MarketInfo(Instrument, MODE_DIGITS));
    }
    if (ATRTrend1 == 0)
    {
        Print("Error reading ATR values.");
    }
    return 0;
}

//+------------------------------------------------------------------+
//| Fills indicator buffers.                                         |
//+------------------------------------------------------------------+
void FillBuffers()
{
    if (UpTrend) BufferZero[0] = 1;
    if (DownTrend) BufferZero[0] = -1;
    if ((!UpTrend) && (!DownTrend)) BufferZero[0] = 0;
}

//+------------------------------------------------------------------+
//| Alert processing.                                                |
//+------------------------------------------------------------------+
void Notify()
{
    if (!EnableNotify) return;
    if ((!SendAlert) && (!SendApp) && (!SendEmail)) return;
    if (LastAlertDirection == 2)
    {
        LastAlertDirection = BufferZero[0]; // Avoid initial alert when just attaching the indicator to the chart.
        return;
    }
    if (BufferZero[0] == LastAlertDirection) return; // Avoid alerting about the same signal.
    LastAlertDirection = BufferZero[0];
    string TrendString = "No trend";
    if (UpTrend) TrendString = "Uptrend";
    if (DownTrend) TrendString = "Downtrend";
    if (SendAlert)
    {
        string AlertText = IndicatorName + " - " + Symbol() + " Notification: ";
        if ((!UpTrend) && (!DownTrend)) AlertText += "The Pair is NOT Trending.";
        else AlertText += "The Pair is currently in a Trend - " + TrendString + ".";
        Alert(AlertText);
    }
    if (SendEmail)
    {
        string EmailSubject = IndicatorName + " " + Symbol() + " Notification";
        string EmailBody = AccountCompany() + " - " + AccountName() + " - " + IntegerToString(AccountNumber()) + "\r\n\r\n" + IndicatorName + " Notification for " + Symbol() + "\r\n\r\n";
        if ((!UpTrend) && (!DownTrend)) EmailBody += "The Pair is NOT Trending.";
        else EmailBody += "The Pair is currently in a Trend - " + TrendString + ".";
        if (!SendMail(EmailSubject, EmailBody)) Print("Error sending email " + IntegerToString(GetLastError()) + ".");
    }
    if (SendApp)
    {
        string AppText = AccountCompany() + " - " + AccountName() + " - " + IntegerToString(AccountNumber()) + " - " + IndicatorName + " - " + Symbol() + " - ";
        if ((!UpTrend) && (!DownTrend)) AppText += "The Pair is NOT Trending.";
        else AppText += "The Pair is currently in a Trend - " + TrendString + ".";
        if (!SendNotification(AppText)) Print("Error sending notification " + IntegerToString(GetLastError()) + ".");
    }
}

//+------------------------------------------------------------------+
//| Draws arrow signal on a given bar.                               |
//+------------------------------------------------------------------+
void DrawArrow(int i)
{
    if ((!UpTrend) && (!DownTrend)) return;
    datetime ArrowDate = iTime(Symbol(), 0, i);
    string ArrowName = IndicatorName + "-ARWS-" + IntegerToString(ArrowDate);
    double ArrowPrice = 0;
    int ArrowType = 0;
    color ArrowColor = 0;
    int ArrowAnchor = 0;
    int ArrowCode = 0;
    string ArrowDesc = "";
    if (UpTrend)
    {
        ArrowPrice = Low[i];
        ArrowType = OBJ_ARROW_UP;
        ArrowColor = clrGreen;
        ArrowAnchor = ANCHOR_TOP;
        ArrowDesc = "BUY";
        ArrowCode = ArrowCodeUp;
    }
    if (DownTrend)
    {
        ArrowPrice = High[i];
        ArrowType = OBJ_ARROW_DOWN;
        ArrowColor = clrRed;
        ArrowAnchor = ANCHOR_BOTTOM;
        ArrowDesc = "SELL";
        ArrowCode = ArrowCodeDown;
    }
    ObjectCreate(0, ArrowName, ArrowType, 0, ArrowDate, 0);
    ObjectSetDouble(0, ArrowName, OBJPROP_PRICE, ArrowPrice);
    ObjectSetInteger(0, ArrowName, OBJPROP_COLOR, ArrowColor);
    ObjectSetInteger(0, ArrowName, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, ArrowName, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, ArrowName, OBJPROP_ANCHOR, ArrowAnchor);
    int SignalWidth = (int)ChartGetInteger(0, CHART_SCALE, 0);
    if (SignalWidth == 0) SignalWidth++;
    ObjectSetInteger(0, ArrowName, OBJPROP_WIDTH, SignalWidth);
    ObjectSetInteger(0, ArrowName, OBJPROP_STYLE, STYLE_SOLID);
    ObjectSetInteger(0, ArrowName, OBJPROP_BGCOLOR, ArrowColor);
    ObjectSetString(0, ArrowName, OBJPROP_TEXT, ArrowDesc);
    ObjectSetInteger(0, ArrowName, OBJPROP_ARROWCODE, ArrowCode);
    datetime CurrTime = iTime(Symbol(), 0, 0);
}

//+------------------------------------------------------------------+
//| Calculates Supertrend indicator's buffers.                       |
//+------------------------------------------------------------------+
void CalculateSuperTrend()
{
    int limit, i, flag, flagh, trend[10000];
    double up[10000], dn[10000], medianPrice, atr;
    int counted_bars = IndicatorCounted();
    if (counted_bars < 0) return;
    if (counted_bars > 0) counted_bars--;
    limit = Bars - counted_bars;
    MaxBars = ATRMaxBars;
    if (Bars < MaxBars + 2 + ATRPeriod) MaxBars = Bars - 2 - ATRPeriod;
    if (MaxBars <= 0)
    {
        Print("Need more historical data to calculate the Supertrend. Currently, the indicator has only ", Bars, " bars.");
        return;
    }
    for (i = MaxBars; i >= 0; i--)
    {
        TrendUp[i] = EMPTY_VALUE;
        TrendDown[i] = EMPTY_VALUE;
        atr = iATR(NULL, 0, ATRPeriod, i);

        medianPrice = (High[i] + Low[i]) / 2;

        up[i] = medianPrice + (ATRMultiplier * atr);
        dn[i] = medianPrice - (ATRMultiplier * atr);
        trend[i] = 1;

        if (Close[i] > up[i + 1])
        {
            trend[i] = 1;
            if (trend[i + 1] == -1) changeOfTrend = 1;
        }
        else if (Close[i] < dn[i + 1])
        {
            trend[i] = -1;
            if (trend[i + 1] == 1) changeOfTrend = 1;
        }
        else if (trend[i + 1] == 1)
        {
            trend[i] = 1;
            changeOfTrend = 0;
        }
        else if (trend[i + 1] == -1)
        {
            trend[i] = -1;
            changeOfTrend = 0;
        }

        if ((trend[i] < 0) && (trend[i + 1] > 0))
        {
            flag = 1;
        }
        else
        {
            flag = 0;
        }

        if ((trend[i] > 0) && (trend[i + 1] < 0))
        {
            flagh = 1;
        }
        else
        {
            flagh = 0;
        }

        if ((trend[i] > 0) && (dn[i] < dn[i + 1]))
        {
            dn[i] = dn[i + 1];
        }
        
        if ((trend[i] < 0) && (up[i] > up[i + 1]))
        {
            up[i] = up[i + 1];
        }

        if (flag == 1)
        {
            up[i] = medianPrice + (ATRMultiplier * atr);
        }

        if (flagh == 1)
        {
            dn[i] = medianPrice - (ATRMultiplier * atr);
        }

        //-- Draw the indicator
        if (trend[i] == 1)
        {
            TrendUp[i] = dn[i];
            if (changeOfTrend == 1)
            {
                TrendUp[i + 1] = TrendDown[i + 1];
                changeOfTrend = 0;
            }
        }
        else if (trend[i] == -1)
        {
            TrendDown[i] = up[i];
            if (changeOfTrend == 1)
            {
                TrendDown[i + 1] = TrendUp[i + 1];
                changeOfTrend = 0;
            }
        }
    }
    WindowRedraw();
}

//+------------------------------------------------------------------+
//| Calculates Supetrend values for a given timeframe.               |
//+------------------------------------------------------------------+
void CalculateSupertrendTmp(int Timeframe)
{
    MaxBars = ATRMaxBars;
    int limit, i, flag, flagh, trend[10000];
    double up[10000], dn[10000], medianPrice, atr;
    int counted_bars = 0;
    if (counted_bars < 0) return;
    if (counted_bars > 0) counted_bars--;
    limit = iBars(Symbol(), Timeframe) - counted_bars - 1;
    MaxBars--;
    if (iBars(Symbol(), Timeframe) < MaxBars + 2 + ATRPeriod) MaxBars = iBars(Symbol(), Timeframe) - 2 - ATRPeriod;
    if (MaxBars <= 0)
    {
        Print("Need more historical data to calculate the Supertrend. Currently have only ", iBars(Symbol(), Timeframe), " bars.");
        return;
    }
    for (i = MaxBars; i >= 0; i--)
    {
        TrendUpTmp[i] = EMPTY_VALUE;
        TrendDownTmp[i] = EMPTY_VALUE;
        atr = iATR(Symbol(), Timeframe, ATRPeriod, i);

        medianPrice = (iHigh(Symbol(), Timeframe, i) + iLow(Symbol(), Timeframe, i)) / 2;
        up[i] = medianPrice + (ATRMultiplier * atr);
        dn[i] = medianPrice - (ATRMultiplier * atr);
        trend[i] = 1;

        if (iClose(Symbol(), Timeframe, i) > up[i + 1])
        {
            trend[i] = 1;
            if (trend[i + 1] == -1) changeOfTrend = 1;

        }
        else if (iClose(Symbol(), Timeframe, i) < dn[i + 1])
        {
            trend[i] = -1;
            if (trend[i + 1] == 1) changeOfTrend = 1;
        }
        else if (trend[i + 1] == 1)
        {
            trend[i] = 1;
            changeOfTrend = 0;
        }
        else if (trend[i + 1] == -1)
        {
            trend[i] = -1;
            changeOfTrend = 0;
        }

        if (trend[i] < 0 && trend[i + 1] > 0)
        {
            flag = 1;
        }
        else
        {
            flag = 0;
        }

        if (trend[i] > 0 && trend[i + 1] < 0)
        {
            flagh = 1;
        }
        else
        {
            flagh = 0;
        }

        if (trend[i] > 0 && dn[i] < dn[i + 1])
            dn[i] = dn[i + 1];

        if (trend[i] < 0 && up[i] > up[i + 1])
            up[i] = up[i + 1];

        if (flag == 1)
            up[i] = medianPrice + (ATRMultiplier * atr);

        if (flagh == 1)
            dn[i] = medianPrice - (ATRMultiplier * atr);

        //-- Draw the indicator
        if (i == MaxBars) continue;
        if (trend[i] == 1)
        {
            TrendUpTmp[i] = dn[i];
            if (changeOfTrend == 1)
            {
                TrendUpTmp[i + 1] = TrendDownTmp[i + 1];
                changeOfTrend = 0;
            }
        }
        else if (trend[i] == -1)
        {
            TrendDownTmp[i] = up[i];
            if (changeOfTrend == 1)
            {
                TrendDownTmp[i + 1] = TrendUpTmp[i + 1];
                changeOfTrend = 0;
            }
        }
    }
    WindowRedraw();
}


string PanelBase = IndicatorName + "-P-BAS";
string PanelLabel = IndicatorName + "-P-LAB";
string PanelDAbove = IndicatorName + "-P-DABOVE";
string PanelDBelow = IndicatorName + "-P-DBELOW";
string PanelSig = IndicatorName + "-P-SIG";

int PanelMovX = 50;
int PanelMovY = 20;
int PanelLabX = 102;
int PanelLabY = PanelMovY;
int PanelRecX = PanelLabX + 4;
//+------------------------------------------------------------------+
//| Main panel drawing function.                                     |
//+------------------------------------------------------------------+
void DrawPanel()
{
    int Rows = 1;
    ObjectCreate(0, PanelBase, OBJ_RECTANGLE_LABEL, 0, 0, 0);
    ObjectSet(PanelBase, OBJPROP_XDISTANCE, Xoff);
    ObjectSet(PanelBase, OBJPROP_YDISTANCE, Yoff);
    ObjectSetInteger(0, PanelBase, OBJPROP_XSIZE, PanelRecX);
    ObjectSetInteger(0, PanelBase, OBJPROP_YSIZE, (PanelMovY + 2) * 1 + 2);
    ObjectSetInteger(0, PanelBase, OBJPROP_BGCOLOR, White);
    ObjectSetInteger(0, PanelBase, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, PanelBase, OBJPROP_STATE, false);
    ObjectSetInteger(0, PanelBase, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, PanelBase, OBJPROP_FONTSIZE, 8);
    ObjectSet(PanelBase, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, PanelBase, OBJPROP_COLOR, clrBlack);

    ObjectCreate(0, PanelLabel, OBJ_EDIT, 0, 0, 0);
    ObjectSet(PanelLabel, OBJPROP_XDISTANCE, Xoff + 2);
    ObjectSet(PanelLabel, OBJPROP_YDISTANCE, Yoff + 2);
    ObjectSetInteger(0, PanelLabel, OBJPROP_XSIZE, PanelLabX);
    ObjectSetInteger(0, PanelLabel, OBJPROP_YSIZE, PanelLabY);
    ObjectSetInteger(0, PanelLabel, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, PanelLabel, OBJPROP_STATE, false);
    ObjectSetInteger(0, PanelLabel, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, PanelLabel, OBJPROP_READONLY, true);
    ObjectSetInteger(0, PanelLabel, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, PanelLabel, OBJPROP_TOOLTIP, "Drag to Move");
    ObjectSetString(0, PanelLabel, OBJPROP_TEXT, "MT SUPERTREND");
    ObjectSetString(0, PanelLabel, OBJPROP_FONT, "Consolas");
    ObjectSetInteger(0, PanelLabel, OBJPROP_FONTSIZE, 10);
    ObjectSet(PanelLabel, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, PanelLabel, OBJPROP_COLOR, clrNavy);
    ObjectSetInteger(0, PanelLabel, OBJPROP_BGCOLOR, clrKhaki);
    ObjectSetInteger(0, PanelLabel, OBJPROP_BORDER_COLOR, clrBlack);

    for(int i = 0; i < ArraySize(TFTrend); i++)
    {
        if (!TFEnabled[i]) continue;
        string TrendRowText = IndicatorName + "-P-TREND-" + TFText[i];
        string TrendRowValue = IndicatorName + "-P-TREND-V-" + TFText[i];
        string TrendDirectionText = TFText[i];
        string TrendDirectionValue = "";
        color TrendBackColor = clrKhaki;
        color TrendTextColor = clrNavy;
        if (TFTrend[i] == 1)
        {
            TrendDirectionValue = "UP";
            TrendBackColor = clrDarkGreen;
            TrendTextColor = clrWhite;
        }
        if (TFTrend[i] == -1)
        {
            TrendDirectionValue = "DOWN";
            TrendBackColor = clrDarkRed;
            TrendTextColor = clrWhite;
        }
        if (TFTrend[i] == 0)
        {
            TrendDirectionValue = "-";
        }
        ObjectCreate(0, TrendRowText, OBJ_EDIT, 0, 0, 0);
        ObjectSet(TrendRowText, OBJPROP_XDISTANCE, Xoff + 2);
        ObjectSet(TrendRowText, OBJPROP_YDISTANCE, Yoff + (PanelMovY + 1) * Rows + 2);
        ObjectSetInteger(0, TrendRowText, OBJPROP_XSIZE, PanelMovX);
        ObjectSetInteger(0, TrendRowText, OBJPROP_YSIZE, PanelLabY);
        ObjectSetInteger(0, TrendRowText, OBJPROP_BORDER_TYPE, BORDER_FLAT);
        ObjectSetInteger(0, TrendRowText, OBJPROP_STATE, false);
        ObjectSetInteger(0, TrendRowText, OBJPROP_HIDDEN, true);
        ObjectSetInteger(0, TrendRowText, OBJPROP_READONLY, true);
        ObjectSetInteger(0, TrendRowText, OBJPROP_FONTSIZE, 8);
        ObjectSetString(0, TrendRowText, OBJPROP_TOOLTIP, "Trend Detected in the Timeframe");
        ObjectSetInteger(0, TrendRowText, OBJPROP_ALIGN, ALIGN_CENTER);
        ObjectSetString(0, TrendRowText, OBJPROP_FONT, "Consolas");
        ObjectSetString(0, TrendRowText, OBJPROP_TEXT, TrendDirectionText);
        ObjectSet(TrendRowText, OBJPROP_SELECTABLE, false);
        ObjectSetInteger(0, TrendRowText, OBJPROP_COLOR, clrNavy);
        ObjectSetInteger(0, TrendRowText, OBJPROP_BGCOLOR, clrKhaki);
        ObjectSetInteger(0, TrendRowText, OBJPROP_BORDER_COLOR, clrBlack);

        ObjectCreate(0, TrendRowValue, OBJ_EDIT, 0, 0, 0);
        ObjectSet(TrendRowValue, OBJPROP_XDISTANCE, Xoff + PanelMovX + 4);
        ObjectSet(TrendRowValue, OBJPROP_YDISTANCE, Yoff + (PanelMovY + 1) * Rows + 2);
        ObjectSetInteger(0, TrendRowValue, OBJPROP_XSIZE, PanelMovX);
        ObjectSetInteger(0, TrendRowValue, OBJPROP_YSIZE, PanelLabY);
        ObjectSetInteger(0, TrendRowValue, OBJPROP_BORDER_TYPE, BORDER_FLAT);
        ObjectSetInteger(0, TrendRowValue, OBJPROP_STATE, false);
        ObjectSetInteger(0, TrendRowValue, OBJPROP_HIDDEN, true);
        ObjectSetInteger(0, TrendRowValue, OBJPROP_READONLY, true);
        ObjectSetInteger(0, TrendRowValue, OBJPROP_FONTSIZE, 8);
        ObjectSetString(0, TrendRowValue, OBJPROP_TOOLTIP, "Trend Detected in the Timeframe");
        ObjectSetInteger(0, TrendRowValue, OBJPROP_ALIGN, ALIGN_CENTER);
        ObjectSetString(0, TrendRowValue, OBJPROP_FONT, "Consolas");
        ObjectSetString(0, TrendRowValue, OBJPROP_TEXT, TrendDirectionValue);
        ObjectSet(TrendRowValue, OBJPROP_SELECTABLE, false);
        ObjectSetInteger(0, TrendRowValue, OBJPROP_COLOR, TrendTextColor);
        ObjectSetInteger(0, TrendRowValue, OBJPROP_BGCOLOR, TrendBackColor);
        ObjectSetInteger(0, TrendRowValue, OBJPROP_BORDER_COLOR, clrBlack);
        Rows++;

    }
    string SigText = "";
    color SigColor = clrNavy;
    color SigBack = clrKhaki;
    if (UpTrend)
    {
        SigText = "Uptrend";
        SigColor = clrWhite;
        SigBack = clrDarkGreen;
    }
    if (DownTrend)
    {
        SigText = "Downtrend";
        SigColor = clrWhite;
        SigBack = clrDarkRed;
    }
    if (!UpTrend && !DownTrend)
    {
        SigText = "Uncertain";
    }

    ObjectCreate(0, PanelSig, OBJ_EDIT, 0, 0, 0);
    ObjectSet(PanelSig, OBJPROP_XDISTANCE, Xoff + 2);
    ObjectSet(PanelSig, OBJPROP_YDISTANCE, Yoff + (PanelMovY + 1) * Rows + 2);
    ObjectSetInteger(0, PanelSig, OBJPROP_XSIZE, PanelLabX);
    ObjectSetInteger(0, PanelSig, OBJPROP_YSIZE, PanelLabY);
    ObjectSetInteger(0, PanelSig, OBJPROP_BORDER_TYPE, BORDER_FLAT);
    ObjectSetInteger(0, PanelSig, OBJPROP_STATE, false);
    ObjectSetInteger(0, PanelSig, OBJPROP_HIDDEN, true);
    ObjectSetInteger(0, PanelSig, OBJPROP_READONLY, true);
    ObjectSetInteger(0, PanelSig, OBJPROP_FONTSIZE, 8);
    ObjectSetInteger(0, PanelSig, OBJPROP_ALIGN, ALIGN_CENTER);
    ObjectSetString(0, PanelSig, OBJPROP_FONT, "Consolas");
    ObjectSetString(0, PanelSig, OBJPROP_TOOLTIP, "Trend Detected Considering All Timeframes");
    ObjectSetString(0, PanelSig, OBJPROP_TEXT, SigText);
    ObjectSet(PanelSig, OBJPROP_SELECTABLE, false);
    ObjectSetInteger(0, PanelSig, OBJPROP_COLOR, SigColor);
    ObjectSetInteger(0, PanelSig, OBJPROP_BGCOLOR, SigBack);
    ObjectSetInteger(0, PanelSig, OBJPROP_BORDER_COLOR, clrBlack);
    Rows++;


    ObjectSetInteger(0, PanelBase, OBJPROP_XSIZE, PanelRecX);
    ObjectSetInteger(0, PanelBase, OBJPROP_YSIZE, (PanelMovY + 1) * Rows + 3);
}
//+------------------------------------------------------------------+