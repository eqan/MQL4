
#property copyright "Copyright © 2021 FLYWINS SUPERTREND"
#property link      "http://www.flywins.de"
#property indicator_chart_window
#property indicator_buffers 4
#property indicator_color1 Blue
#property indicator_color2 Red
#property indicator_color3 Blue
#property indicator_color4 Red

double G_ibuf_76[];
double G_ibuf_80[];
double G_ibuf_84[];
double G_ibuf_88[];
bool Gi_92;
extern int Nbr_Periods = 10;
extern double Multiplier = 4.0;
extern string note = "turn on Alert = true; turn off = false";
extern bool alertsOn = TRUE;
extern bool alertsOnCurrent = FALSE;
extern bool alertsMessage = TRUE;
extern bool alertsSound = TRUE;
extern bool alertsEmail = FALSE;
extern string soundfile = "alert2.wav";
extern int sidFontSize = 30;
extern string sidFontName = "Ariel";
extern string NoteRedGreenBlue = "Red/Green/Blue each 0..255";
extern int sidRed = 30;
extern int sidGreen = 30;
extern int sidBlue = 30;
extern int sidXPos = 30;
extern int sidYPos = 150;
extern bool tagDisplayText = TRUE;
extern string tagText = "www.flywins.de";
extern int tagFontSize = 15;
extern string tagFontName = "Ariel";
extern int tagRed = 30;
extern int tagGreen = 30;
extern int tagBlue = 30;
extern int tagXPos = 200;
extern int tagYPos = 300;
string Gs_symbol_228 = "Symbol";
int Gi_unused_236 = 0;
string Gs_tag_240 = "Tag";
int Gi_248 = 0;
string Gs_dummy_252;
string Gs_nothing_260 = "nothing";
datetime G_time_268;

// E37F0136AA3FFAF149B351F6A4C948E9
int init()
  {
   SetIndexBuffer(0, G_ibuf_76);
   SetIndexStyle(0, DRAW_LINE, STYLE_DASH, 1);
   SetIndexLabel(0, "Trend Up");
   SetIndexBuffer(1, G_ibuf_80);
   SetIndexStyle(1, DRAW_LINE, STYLE_DASH, 1);
   SetIndexLabel(1, "Trend Down");
   SetIndexStyle(2, DRAW_ARROW, EMPTY);
   SetIndexStyle(3, DRAW_ARROW, EMPTY);
   SetIndexBuffer(2, G_ibuf_84);
   SetIndexBuffer(3, G_ibuf_88);
   SetIndexArrow(2, 233);
   SetIndexArrow(3, 234);
   SetIndexLabel(3, "Up Signal");
   SetIndexLabel(4, "Down Signal");
   return (0);
  }

// 52D46093050F38C27267BCE42543EF60
int deinit()
  {
   ObjectDelete(Gs_symbol_228);
   ObjectDelete(Gs_tag_240);
   return (0);
  }

// EA2B2676C28C0DB26D39331A336C6B92
int start()
  {
   bool Li_24;
   bool Li_28;
   int Lia_32[5000];
   double Lda_36[5000];
   double Lda_40[5000];
   double Ld_44;
   double iatr_52;
   int Li_64;
   double close_0 = Close[0];
   string str_concat_8 = StringConcatenate("www.flywins.de      Winsprice: ", close_0);
   f0_0(Gs_tag_240, str_concat_8, tagFontSize, tagFontName, Gi_248, 80, 20);
   int Li_60 = IndicatorCounted();
   if(Li_60 < 0)
      return (-1);
   if(Li_60 > 0)
      Li_60--;
   int Li_16 = Bars - 1 - Li_60;
   for(int bars_20 = Bars; bars_20 >= 1; bars_20--)
     {
      G_ibuf_76[bars_20] = EMPTY_VALUE;
      G_ibuf_80[bars_20] = EMPTY_VALUE;
      iatr_52 = iATR(NULL, 0, Nbr_Periods, bars_20);
      Ld_44 = (High[bars_20] + Low[bars_20]) / 2.0;
      Lda_36[bars_20] = Ld_44 + Multiplier * iatr_52;
      Lda_40[bars_20] = Ld_44 - Multiplier * iatr_52;
      Lia_32[bars_20] = 1;
      if(Close[bars_20] > Lda_36[bars_20 + 1])
        {
         Lia_32[bars_20] = 1;
         if(Lia_32[bars_20 + 1] == -1)
            Gi_92 = TRUE;
        }
      else
        {
         if(Close[bars_20] < Lda_40[bars_20 + 1])
           {
            Lia_32[bars_20] = -1;
            if(Lia_32[bars_20 + 1] == 1)
               Gi_92 = TRUE;
           }
         else
           {
            if(Lia_32[bars_20 + 1] == 1)
              {
               Lia_32[bars_20] = 1;
               Gi_92 = FALSE;
              }
            else
              {
               if(Lia_32[bars_20 + 1] == -1)
                 {
                  Lia_32[bars_20] = -1;
                  Gi_92 = FALSE;
                 }
              }
           }
        }
      if(Lia_32[bars_20] < 0 && Lia_32[bars_20 + 1] > 0)
         Li_24 = TRUE;
      else
         Li_24 = FALSE;
      if(Lia_32[bars_20] > 0 && Lia_32[bars_20 + 1] < 0)
         Li_28 = TRUE;
      else
         Li_28 = FALSE;
      if(Lia_32[bars_20] > 0 && Lda_40[bars_20] < Lda_40[bars_20 + 1])
         Lda_40[bars_20] = Lda_40[bars_20 + 1];
      if(Lia_32[bars_20] < 0 && Lda_36[bars_20] > Lda_36[bars_20 + 1])
         Lda_36[bars_20] = Lda_36[bars_20 + 1];
      if(Li_24 == TRUE)
         Lda_36[bars_20] = Ld_44 + Multiplier * iatr_52;
      if(Li_28 == TRUE)
         Lda_40[bars_20] = Ld_44 - Multiplier * iatr_52;
      if(Lia_32[bars_20] == 1)
        {
         G_ibuf_76[bars_20] = Lda_40[bars_20];
         if(Gi_92 == TRUE)
           {
            G_ibuf_76[bars_20 + 1] = G_ibuf_80[bars_20 + 1];
            Gi_92 = FALSE;
           }
        }
      else
        {
         if(Lia_32[bars_20] == -1)
           {
            G_ibuf_80[bars_20] = Lda_36[bars_20];
            if(Gi_92 == TRUE)
              {
               G_ibuf_80[bars_20 + 1] = G_ibuf_76[bars_20 + 1];
               Gi_92 = FALSE;
              }
           }
        }
      if(Lia_32[bars_20] == 1 && Lia_32[bars_20 + 1] == -1)
        {
         G_ibuf_84[bars_20] = iLow(Symbol(), 0, bars_20) - 3.0 * Point;
         G_ibuf_88[bars_20] = EMPTY_VALUE;
        }
      if(Lia_32[bars_20] == -1 && Lia_32[bars_20 + 1] == 1)
        {
         G_ibuf_84[bars_20] = EMPTY_VALUE;
         G_ibuf_88[bars_20] = iHigh(Symbol(), 0, bars_20) + 3.0 * Point;
        }
     }
   WindowRedraw();
   if(alertsOn)
     {
      if(alertsOnCurrent)
         Li_64 = 0;
      else
         Li_64 = 1;
      if(Lia_32[Li_64] != Lia_32[Li_64 + 1])
        {
         if(Lia_32[Li_64] == 1)
            f0_1("up trend");
         else
            f0_1("down trend");
        }
     }
   return (0);
  }

// DA717D55A7C333716E8D000540764674
void f0_1(string As_0)
  {
   string str_concat_8;
   if(Gs_nothing_260 != As_0 || G_time_268 != Time[0])
     {
      Gs_nothing_260 = As_0;
      G_time_268 = Time[0];
      str_concat_8 = StringConcatenate(Symbol(), " at ", TimeToStr(TimeLocal(), TIME_SECONDS), " SuperTrend ", As_0);
      if(alertsMessage)
         Alert(str_concat_8);
      if(alertsEmail)
         SendMail(StringConcatenate(Symbol(), " SuperTrend "), str_concat_8);
      if(alertsSound)
         PlaySound(soundfile);
     }
  }

// 3D0C068162A45AE740814B843CF989AA
void f0_0(string A_name_0, string A_text_8, int A_fontsize_16, string A_fontname_20, int Ai_unused_28, int A_x_32, int A_y_36)
  {
   ObjectCreate(A_name_0, OBJ_LABEL, 0, 0, 0);
   ObjectSetText(A_name_0, A_text_8, A_fontsize_16, A_fontname_20, Red);
   ObjectSet(A_name_0, OBJPROP_CORNER, 0);
   ObjectSet(A_name_0, OBJPROP_XDISTANCE, A_x_32);
   ObjectSet(A_name_0, OBJPROP_YDISTANCE, A_y_36);
   ObjectSet(A_name_0, OBJPROP_BACK, TRUE);
  }
//+------------------------------------------------------------------+
