﻿//+------------------------------------------------------------------+
//|                                              DowHowLinie_new.mq5 |
//|                                      © Michael Keller, Juli 2023 |
//|                                                                  |
//+------------------------------------------------------------------+
#include <Controls\Button.mqh>
#include <Controls\Dialog.mqh>
#include <Controls\Panel.mqh>
#include <Layouts\Box.mqh>

//+------------------------------------------------------------------+
//| defines                                                          |
//+------------------------------------------------------------------+
//--- indents and gaps
#define INDENT_LEFT                         (11)      // indent from left (with allowance for border width)
#define INDENT_TOP                          (11)      // indent from top (with allowance for border width)
#define INDENT_RIGHT                        (11)      // indent from right (with allowance for border width)
#define INDENT_BOTTOM                       (11)      // indent from bottom (with allowance for border width)
#define INDENT_SPACE                        (5)       // Abstand zwischen den Buttons
#define CONTROLS_GAP_X                      (5)       // gap by X coordinate
#define CONTROLS_GAP_Y                      (5)       // gap by Y coordinate
//--- for buttons
#define BUTTON_WIDTH                        (60)     // size by X coordinate
#define BUTTON_HEIGHT                       (20)      // size by Y coordinate
//--- for the indication area
#define EDIT_HEIGHT                         (20)      // size by Y coordinate
//--- for group controls
#define GROUP_WIDTH                         (150)     // size by X coordinate
#define LIST_HEIGHT                         (179)     // size by Y coordinate
#define RADIO_HEIGHT                        (56)      // size by Y coordinate
#define CHECK_HEIGHT                        (93)      // size by Y coordinate

/*
Farben und Linien einstellbar machen (ok) sieht gut aus
Buttons immer ensprechend der Linie anzeigen (ok)
Buttongröße einstellbar machen (ok)
Buttons an den rechten Bildschirmrand anzeigen (ok)

Alternative Darstellung der Buttons über/neben/unter dem Chart in einem Eigenem Teil (So wie bei MACD, z.b.).
Buttons verschiebbar machen (einzeln oder als Gruppe)
Einstellungen der DHLinie für den Chart nach Wechsel der Charts wieder herstellen.(wird wohl schwierig, da doinit immer durchlaufen wird)
Buttons klickbar machen, auch wenn Kerzen/Linien/Rechtecke etc. unter den Buttons sind (suchen nach dem Artikel)
Bottons waren in der Mitte des Charts oder am falscher Stelle, nach dem öffnen des MT5, bzw. vergrößern des Charts
*/

#property copyright   "© Michael Keller, Februar 2025"
#property link        "Michael Keller"
#property version     "5.00"
#property description "DowHow Linie. Die Linie zeigt den Maximalen und Minimalen Preis der eingestellten Periode des HeikenAshi Close Preises an."
#property description " "
#property description "Die DowHow Linie hilft uns fachlich Korrekt den Trade zu beenden und unsere Kapital zu schützen."
#property description " "
#property description "Du willst meine Arbeit unterstützen: Spende: https://streamlabs.com/michaelkeller6128"

#property indicator_chart_window
#property indicator_buffers 7
#property indicator_plots   6
//--- plot Min10
#property indicator_label1  "Min10"
#property indicator_type1   DRAW_LINE
#property indicator_color1  clrMediumSeaGreen
#property indicator_style1  STYLE_SOLID
#property indicator_width1  1
#property indicator_label1  "Min10 DowHow Linie"

//--- plot Max10
#property indicator_label2  "Max10"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrDarkOrange
#property indicator_style2  STYLE_SOLID
#property indicator_width2  1
#property indicator_label2  "Max20 DowHow Linie"
//--- plot Min20
#property indicator_label3  "Min20"
#property indicator_type3   DRAW_LINE
#property indicator_color3  clrLime
#property indicator_style3  STYLE_SOLID
#property indicator_width3  1
#property indicator_label3  "Min20 DowHow Linie"

//--- plot Max20
#property indicator_label4  "Max20"
#property indicator_type4   DRAW_LINE
#property indicator_color4  clrRed
#property indicator_style4  STYLE_SOLID
#property indicator_width4  1
#property indicator_label4  "Max20 DowHow Linie"

#property indicator_label5  "Min55"
#property indicator_type5    DRAW_LINE
#property indicator_color5  clrYellow
#property indicator_style5  STYLE_SOLID
#property indicator_width5  1

#property indicator_label6  "Max55"
#property indicator_type6  DRAW_LINE
#property indicator_color6  clrBlue
#property indicator_style6  STYLE_SOLID
#property indicator_width6  1
//--- input parameters
input bool     showLineMin10=false;
input bool     showLineMax10=false;
input bool     showLineMin20=false;
input bool     showLineMax20=false;
bool showMin10 = showLineMin10;
bool showMax10 = showLineMax10;
bool showMin20 = showLineMin20;
bool showMax20 = showLineMax20;
input bool     showLineMin55=false;
input bool     showLineMax55=false;

bool showMin55 = showLineMin55;
bool showMax55 = showLineMax55;

enum origin
  {
   o=1, //oben
   u=2, // unten
   r=3, // rechts
   l=4 // links
  };




input  origin button_origin =4; //Buttons oben, rechts, unten

input color LineMin10Color = clrMediumSeaGreen;    // Farbe für Linie Min10
input color LineMax10Color = clrDarkOrange;     // Farbe für Linie Max10
input color LineMin20Color = clrLime;   // Farbe für Linie Min20
input color LineMax20Color = clrRed;  // Farbe für Linie Max20
input color LineMin55Color = clrYellow;  // Farbe für Linie Max20
input color LineMax55Color = clrBlue;  // Farbe für Linie Max20

input int Period3 = 55;  // Zeitraum für die 55er Linie
input int Period1 = 10;  // Zeitraum für die 10er Linie
input int Period2 = 20;  // Zeitraum für die 20er Linie

input int buttonbreite =60; // Button breite in Pixel
input int buttonhoehe =20;// Button Höhe in Pixel


//--- indicator buffers
double         Min10Buffer[];
double         Max10Buffer[];
double         Min20Buffer[];
double         Max20Buffer[];
double         Min55Buffer[];
double         Max55Buffer[];
double prices[];
int heikenAshi;

CButton m_buttonMin10;
CButton m_buttonMax10;
CButton m_buttonMin20;
CButton m_buttonMax20;
CButton m_buttonMin55;
CButton m_buttonMax55;
int m_subwin=0;

CBox mybox;
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool moveBox()
  {

   if(button_origin==1)
     {
      if(!mybox.Move((ChartWidthInPixels()/2)-(buttonbreite*2)-INDENT_LEFT-INDENT_SPACE,0))
         return false;
     }

   if(button_origin==2)
     {
      if(!mybox.Move((ChartWidthInPixels()/2)-(buttonbreite*2)-INDENT_LEFT-INDENT_SPACE, ChartHeightInPixelsGet()-60))
         return false;
     }
   if(button_origin==3)
     {
      if(!  mybox.Move(ChartWidthInPixels()-INDENT_LEFT-buttonbreite-INDENT_RIGHT, ChartHeightInPixelsGet()/2-buttonhoehe-buttonhoehe-INDENT_SPACE))
         return false;
     }

   if(button_origin==4)
     {
      if(!mybox.Move(0, ChartHeightInPixelsGet()/2-buttonhoehe-buttonhoehe-INDENT_SPACE))
         return false;
     }
   ChartRedraw();
   return true;
  }
//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {

// x1 = Der Wert der X-Koordinate des oberen linken Punktes.
// y1 = Der Wert der Y-Koordinate des oberen linken Punktes.
// x2 = Der Wert der X-Koordinate des unten rechten Punktes.
// y2 = Der Wert der Y-Koordinate des unten rechten Punktes.

   if(button_origin==1)
     {
      if(!mybox.Create(0,"Panel",0, (ChartWidthInPixels()/2)-(buttonbreite*2)-INDENT_LEFT-INDENT_SPACE,0,       ChartWidthInPixels()/2+(INDENT_SPACE)+(buttonbreite*4)+INDENT_RIGHT,       INDENT_TOP+(buttonhoehe)+INDENT_BOTTOM)
        )
        {
         Print("Fehler beim erstellen des Panels");
         return(false);
        }
     }

   if(button_origin==2)
     {
      if(!mybox.Create(0,"Panel",0, (ChartWidthInPixels()/2)-(buttonbreite*2)-INDENT_LEFT-INDENT_SPACE, ChartHeightInPixelsGet()-60, ChartWidthInPixels()/2+(INDENT_SPACE)+(buttonbreite*4)+INDENT_RIGHT,ChartHeightInPixelsGet()-10)
        )
        {
         Print("Fehler beim erstellen des Panels");
         return(false);
        }
     }

   if(button_origin==3)
     {
      if(!mybox.Create(0,"Panel",0, ChartWidthInPixels()-INDENT_LEFT-buttonbreite-INDENT_RIGHT, ChartHeightInPixelsGet()/2-buttonhoehe-buttonhoehe-INDENT_SPACE,
                       ChartWidthInPixels(),ChartHeightInPixelsGet()/2+buttonhoehe+buttonhoehe+INDENT_SPACE  +INDENT_SPACE)
        )
        {
         Print("Fehler beim erstellen des Panels");
         return(false);
        }
     }
   if(button_origin==4)
     {
      if(!mybox.Create(0,"Panel",0, 0, ChartHeightInPixelsGet()/2-buttonhoehe-buttonhoehe-INDENT_SPACE,
                       INDENT_LEFT+buttonbreite+INDENT_RIGHT,ChartHeightInPixelsGet()/2+buttonhoehe+buttonhoehe+INDENT_SPACE +INDENT_SPACE)
        )
        {
         Print("Fehler beim erstellen des Panels");
         return(false);
        }
     }


   mybox.Enable();
   mybox.Show();
   mybox.ColorBorder(clrNONE);
   mybox.ColorBackground(clrNONE);

   heikenAshi= iCustom(_Symbol, _Period, "Examples\\Heiken_Ashi");
//--- indicator buffers mapping
   SetIndexBuffer(0,Min10Buffer,INDICATOR_DATA);
   SetIndexBuffer(1,Max10Buffer,INDICATOR_DATA);
   SetIndexBuffer(2,Min20Buffer,INDICATOR_DATA);
   SetIndexBuffer(3,Max20Buffer,INDICATOR_DATA);
   SetIndexBuffer(4,Min55Buffer,INDICATOR_DATA);
   SetIndexBuffer(5,Max55Buffer,INDICATOR_DATA);
   SetIndexBuffer(6,prices,INDICATOR_DATA);
   IndicatorSetString(INDICATOR_SHORTNAME,"Dow How Linie");
//---

//CHART_PROP_WIDTH_IN_PIXELS,                        // Width of the chart in pixels
// CHART_PROP_HEIGHT_IN_PIXELS,                       // Height of the chart in pixels

   EventSetTimer(1);

   CreateButtons();
   return(INIT_SUCCEEDED);
  }


//+------------------------------------------------------------------+
//| Create the "CreateButtonMin10" button                                      |
//+------------------------------------------------------------------+
bool CreateButtonMin10(void)
  {

   if(!m_buttonMin10.Create(0,"Min10",m_subwin,0,0,buttonbreite,buttonhoehe))
      return(false);
   if(!m_buttonMin10.Text("Min10"))
      return(false);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "CreateButtonMin20" button                                      |
//+------------------------------------------------------------------+
bool CreateButtonMin20(void)
  {

   if(!m_buttonMin20.Create(0,"Min20",m_subwin,0,0,buttonbreite,buttonhoehe))
      return(false);
   if(!m_buttonMin20.Text("Min20"))
      return(false);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "CreateButtonMax10" button                                      |
//+------------------------------------------------------------------+
bool CreateButtonMax10(void)
  {

   if(!m_buttonMax10.Create(0,"Max10",m_subwin,0,0,buttonbreite,buttonhoehe))
      return(false);
   if(!m_buttonMax10.Text("Max10"))
      return(false);
//--- succeed
   return(true);
  }
//+------------------------------------------------------------------+
//| Create the "CreateButtonMax20" button                                      |
//+------------------------------------------------------------------+
bool CreateButtonMax20(void)
  {

   if(!m_buttonMax20.Create(0,"Max20",m_subwin,0,0,buttonbreite,buttonhoehe))
      return(false);
   if(!m_buttonMax20.Text("Max20"))
      return(false);
//--- succeed
   return(true);
  }


//+------------------------------------------------------------------+
//| Create the "CreateButtonMax20" button                                      |
//+------------------------------------------------------------------+
bool CreateButtonMax55(void)
  {

   if(!m_buttonMax55.Create(0,"Max55",m_subwin,0,0,buttonbreite,buttonhoehe))
      return(false);
   if(!m_buttonMax55.Text("Max55"))
      return(false);
//--- succeed
   return(true);
  }

//+------------------------------------------------------------------+
//| Create the "CreateButtonMax20" button                                      |
//+------------------------------------------------------------------+
bool CreateButtonMin55(void)
  {

   if(!m_buttonMin55.Create(0,"Min55",m_subwin,0,0,buttonbreite,buttonhoehe))
      return(false);
   if(!m_buttonMin55.Text("Min55"))
      return(false);
//--- succeed
   return(true);
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CreateButtons()
  {


   if(button_origin==1 || button_origin==2)
     {
      mybox.LayoutStyle(LAYOUT_STYLE_HORIZONTAL);
      if(!CreateButtonMin10())
         Print("Fehler beim erstellen von ButtonMin10");
      if(!CreateButtonMin20())
         Print("Fehler beim erstellen von ButtonMin20 ");
      if(!CreateButtonMax10())
         Print("Fehler beim erstellen von ButtonMax10");
      if(!CreateButtonMax20())
         Print("Fehler beim erstellen von ButtonMax20 ");
      if(!CreateButtonMin55())
         Print("Fehler beim erstellen von ButtonMin55 ");
      if(!CreateButtonMax55())
         Print("Fehler beim erstellen von ButtonMax55 ");

      mybox.Add(m_buttonMin10);
      mybox.Add(m_buttonMin20);
      mybox.Add(m_buttonMax10);
      mybox.Add(m_buttonMax20);
      mybox.Add(m_buttonMin55);
      mybox.Add(m_buttonMax55);
      mybox.Pack();


     }





   if(button_origin==3||button_origin==4)
     {
      mybox.LayoutStyle(LAYOUT_STYLE_VERTICAL);
      if(!CreateButtonMin10())
         Print("Fehler beim erstellen von ButtonMin10");
      if(!CreateButtonMin20())
         Print("Fehler beim erstellen von ButtonMin20 ");
      if(!CreateButtonMax10())
         Print("Fehler beim erstellen von ButtonMax10");
      if(!CreateButtonMax20())
         Print("Fehler beim erstellen von ButtonMax20 ");
      if(!CreateButtonMin55())
         Print("Fehler beim erstellen von ButtonMin55 ");
      if(!CreateButtonMax55())
         Print("Fehler beim erstellen von ButtonMax55 ");
      mybox.Add(m_buttonMin10);
      mybox.Add(m_buttonMin20);
      mybox.Add(m_buttonMax10);
      mybox.Add(m_buttonMax20);
      mybox.Add(m_buttonMin55);
      mybox.Add(m_buttonMax55);
      mybox.Pack();


     }



   if(showMin10)
     {
      m_buttonMin10.ColorBackground(LineMin10Color);
      PlotIndexSetInteger(0,PLOT_LINE_COLOR,LineMin10Color);
     }
   else
     {
      m_buttonMin10.ColorBackground(clrLightGray);
      PlotIndexSetInteger(0,PLOT_LINE_COLOR,clrNONE);
     }
   if(showMin20)
     {
      m_buttonMin20.ColorBackground(LineMin20Color);
      PlotIndexSetInteger(2,PLOT_LINE_COLOR,LineMin20Color);
     }
   else
     {
      m_buttonMin20.ColorBackground(clrLightGray);
      PlotIndexSetInteger(2,PLOT_LINE_COLOR,clrNONE);
     }
   if(showMax10)
     {
      m_buttonMax10.ColorBackground(LineMax10Color);
      PlotIndexSetInteger(1,PLOT_LINE_COLOR,LineMax10Color);
     }
   else
     {
      m_buttonMax10.ColorBackground(clrLightGray);
      PlotIndexSetInteger(1,PLOT_LINE_COLOR,clrNONE);
     }
   if(showMax20)
     {
      m_buttonMax20.ColorBackground(LineMax20Color);
      PlotIndexSetInteger(3,PLOT_LINE_COLOR,LineMax20Color);
     }
   else
     {
      m_buttonMax20.ColorBackground(clrLightGray);
      PlotIndexSetInteger(3,PLOT_LINE_COLOR,clrNONE);
     }


   if(showMax55)
     {
      m_buttonMax55.ColorBackground(LineMax55Color);
      PlotIndexSetInteger(5,PLOT_LINE_COLOR,LineMax55Color);
     }
   else
     {
      m_buttonMax55.ColorBackground(clrLightGray);
      PlotIndexSetInteger(5,PLOT_LINE_COLOR,clrNONE);
     }
   if(showMin55)
     {
      m_buttonMin55.ColorBackground(LineMin55Color);
      PlotIndexSetInteger(4,PLOT_LINE_COLOR,LineMin55Color);
     }
   else
     {
      m_buttonMin55.ColorBackground(clrLightGray);
      PlotIndexSetInteger(4,PLOT_LINE_COLOR,clrNONE);
     }




   return(true);
  }


//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---Observes cursor position, Highlight button and detect Click event
   mybox.OnEvent(id,
                 lparam,
                 dparam,
                 sparam);
   if(id == CHARTEVENT_CHART_CHANGE)
     {
      moveBox();

     }
   if(id == CHARTEVENT_OBJECT_CLICK && sparam == "Min10")
     {

      showMin10 = !showMin10;

      switch(showMin10)
        {
         case(true):
            m_buttonMin10.ColorBackground(LineMin10Color);

            PlotIndexSetInteger(0,PLOT_LINE_COLOR,LineMin10Color);
            break;

         case(false):
            m_buttonMin10.ColorBackground(clrLightGray);
            PlotIndexSetInteger(0,PLOT_LINE_COLOR,clrNONE);
            break;
        }

     }
   if(id == CHARTEVENT_OBJECT_CLICK && sparam == "Min20")
     {

      showMin20 = !showMin20;

      switch(showMin20)
        {
         case(true):
            m_buttonMin20.ColorBackground(LineMin20Color);
            PlotIndexSetInteger(2,PLOT_LINE_COLOR,LineMin20Color);
            break;

         case(false):
            m_buttonMin20.ColorBackground(clrLightGray);
            PlotIndexSetInteger(2,PLOT_LINE_COLOR,clrNONE);
            break;
        }

     }
   if(id == CHARTEVENT_OBJECT_CLICK && sparam == "Max10")
     {

      showMax10 = !showMax10;

      switch(showMax10)
        {
         case(true):
            m_buttonMax10.ColorBackground(LineMax10Color);
            PlotIndexSetInteger(1,PLOT_LINE_COLOR,LineMax10Color);
            break;

         case(false):
            m_buttonMax10.ColorBackground(clrLightGray);
            PlotIndexSetInteger(1,PLOT_LINE_COLOR,clrNONE);
            break;
        }

     }
   if(id == CHARTEVENT_OBJECT_CLICK && sparam == "Max20")
     {

      showMax20 = !showMax20;

      switch(showMax20)
        {
         case(true):
            m_buttonMax20.ColorBackground(LineMax20Color);
            PlotIndexSetInteger(3,PLOT_LINE_COLOR,LineMax20Color);
            break;

         case(false):
            m_buttonMax20.ColorBackground(clrLightGray);
            PlotIndexSetInteger(3,PLOT_LINE_COLOR,clrNONE);
            break;
        }

     }
   if(id == CHARTEVENT_OBJECT_CLICK && sparam == "Min55")
     {

      showMin55 = !showMin55;

      switch(showMin55)
        {
         case(true):
            m_buttonMin55.ColorBackground(LineMin55Color);
            PlotIndexSetInteger(4,PLOT_LINE_COLOR,LineMin55Color);
            break;

         case(false):
            m_buttonMin55.ColorBackground(clrLightGray);
            PlotIndexSetInteger(4,PLOT_LINE_COLOR,clrNONE);
            break;
        }

     }

   if(id == CHARTEVENT_OBJECT_CLICK && sparam == "Max55")
     {

      showMax55 = !showMax55;

      switch(showMax55)
        {
         case(true):
            m_buttonMax55.ColorBackground(LineMax55Color);
            PlotIndexSetInteger(5,PLOT_LINE_COLOR,LineMax55Color);
            break;

         case(false):
            m_buttonMax55.ColorBackground(clrLightGray);
            PlotIndexSetInteger(5,PLOT_LINE_COLOR,clrNONE);
            break;
        }

     }

   ChartRedraw();

  }


//+------------------------------------------------------------------+
//| Custom indicator iteration function                              |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
  {
//---
   ChartRedraw();
   moveBox();


   int i=(prev_calculated>0?prev_calculated-1:0);
// Print("Period1: ",Period1);
   for(; i<rates_total && !_StopFlag; i++)
     {

      // Nimm den HeikenAshi Close Preis
      prices[i]= (open[i] + high[i] + low[i] + close[i]) / 4;

      int    _startmin10 = i-Period1+1;
      if(_startmin10<0)
         _startmin10=0;
      int    _startmax10 = i-Period1+1;
      if(_startmax10<0)
         _startmax10=0;

      int    _startmin20 = i-Period2+1;
      if(_startmin20<0)
         _startmin20=0;
      int    _startmax20 = i-Period2+1;
      if(_startmax20<0)
         _startmax20=0;
      int    _startmin55 = i-Period3+1;
      if(_startmin55<0)
         _startmin55=0;

      int    _startmax55 = i-Period3+1;
      if(_startmax55<0)
         _startmax55=0;

      double _min55   = prices[ArrayMinimum(prices,_startmin55,Period3)];
      double _max55   = prices[ArrayMaximum(prices,_startmax55,Period3)];


      double _min10   = prices[ArrayMinimum(prices,_startmin10,Period1)];
      double _max10   = prices[ArrayMaximum(prices,_startmax10,Period1)];

      double _min20   = prices[ArrayMinimum(prices,_startmin20,Period2)];
      double _max20   = prices[ArrayMaximum(prices,_startmax20,Period2)];

      Min10Buffer[i] =  _min10 ;
      Max10Buffer[i] =  _max10 ;
      Min20Buffer[i] =  _min20 ;
      Max20Buffer[i] =  _max20 ;
      Min55Buffer[i] =  _min55 ;
      Max55Buffer[i] =  _max55 ;
      ChartRedraw();


     }
   return(rates_total);
  }




//+------------------------------------------------------------------+
//| Timer function                                                   |
//+------------------------------------------------------------------+
void OnTimer()
  {
//---
   ChartRedraw();
  }



//+------------------------------------------------------------------+


double heikenAshiOpen[], heikenAshiHigh[], heikenAshiLow[], heikenAshiClose[];
// Kopiert die HeikenAshi Werte in die Arrays
// Es werden nur die Werte für die Close Kurse benötigt
//
void copy(int anzahl)
  {

//CopyBuffer(heikenAshi,0,0,anzahl,heikenAshiOpen);
//CopyBuffer(heikenAshi,1,0,anzahl,heikenAshiHigh);
//CopyBuffer(heikenAshi,2,0,anzahl,heikenAshiLow);
   CopyBuffer(heikenAshi,3,0,anzahl,heikenAshiClose);

  }
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- Kommentare löschen
 //--- Der erste Weg, um an den Code der Deinitialisierung zu kommen
   Print(__FUNCTION__," Deinitialization reason code = ",reason);
//--- Der zweite Weg, um an den Code der Deinitialisierung zu kommen
   Print(__FUNCTION__," _UninitReason = ",getUninitReasonText(_UninitReason));
//--- Der dritte Weg, um an den Code der Deinitialisierung zu kommen
   Print(__FUNCTION__," UninitializeReason() = ",getUninitReasonText(UninitializeReason()));



//--- destroy dialog
//--- Löschen des Dialogs

   m_buttonMax10.Destroy();
   m_buttonMax20.Destroy();
   m_buttonMin10.Destroy();
   m_buttonMin20.Destroy();
   m_buttonMin55.Destroy();
   m_buttonMax55.Destroy();
   mybox.Destroy(reason);

   IndicatorRelease(heikenAshi);




   ArrayFree(heikenAshiClose);
   ArrayFree(heikenAshiLow);
   ArrayFree(heikenAshiHigh);
   ArrayFree(heikenAshiOpen);


   ArrayFree(prices);
   ArrayFree(Max10Buffer);
   ArrayFree(Max20Buffer);
   ArrayFree(Min10Buffer);
   ArrayFree(Min20Buffer);
   ArrayFree(Min55Buffer);
   ArrayFree(Min55Buffer);
  }
  
  
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
string getUninitReasonText(int reasonCode)
  {
   string text="";
//---
   switch(reasonCode)
     {
      case REASON_ACCOUNT:
         text="Account was changed";
         break;
      case REASON_CHARTCHANGE:
         text="Symbol or timeframe was changed";
         break;
      case REASON_CHARTCLOSE:
         text="Chart was closed";
         break;
      case REASON_PARAMETERS:
         text="Input-parameter was changed";
         break;
      case REASON_RECOMPILE:
         text="Program "+__FILE__+" was recompiled";
         break;
      case REASON_REMOVE:
         text="Program "+__FILE__+" was removed from chart";
         break;
      case REASON_TEMPLATE:
         text="New template was applied to chart";
         break;
      default:
         text="Another reason";
     }
//---
   return text;
  }
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//| Die Funktion erhält den Wert der Breite des Charts in Pixeln     |
//+------------------------------------------------------------------+
int ChartWidthInPixels(const long chart_ID=0)
  {
//--- Bereiten wir eine Variable, um den Wert der Eigenschaft zu erhalten
   long result=-1;
//--- Setzen den Wert des Fehlers zurück
   ResetLastError();
//--- Erhalten wir den Wert der Eigenschaft
   if(!ChartGetInteger(chart_ID,CHART_WIDTH_IN_PIXELS,0,result))
     {
      //--- Schreiben die Fehlermeldung in den Log "Experten"
      Print(__FUNCTION__+", Error Code = ",GetLastError());
     }
//--- Geben den Wert der Eigenschaft zurück
   return((int)result);
  }




//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
/*
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int writeIndicator()
  {

   string             FileName=Symbol()+"_"+Timeframe()+"_"+"dhline.csv";   // der Dateiname
   string             DirectoryName="Data"; // der Verzeichnisname

   int file_handle=FileOpen(DirectoryName+"//"+FileName,FILE_READ|FILE_WRITE|FILE_CSV|FILE_ANSI);
   if(file_handle!=INVALID_HANDLE)
     {
      PrintFormat("%s Datei ist zum Lesen geöffnet",FileName);
      PrintFormat("Pfad zur Datei: %s\\Files\\",TerminalInfoString(TERMINAL_DATA_PATH));

      string     str="";
      str=Symbol()+";"+
          Timeframe()+";"+
          showLineMin10+";"+
          showLineMax10+";"+
          showLineMin20+";"+
          showLineMax20+";"+
          showMin10 +";"+
          showMax10 +";"+
          showMin20 +";"+
          showMax20 +";"+
          button_origin +";"+
          LineMin10Color+";"+
          LineMax10Color +";"+
          LineMin20Color +";"+
          LineMax20Color +";"+
          Period1 +";"+
          Period2 +";"+
          buttonbreite +";"+
          buttonhoehe +";"+
          m_buttonMin10.ColorBackground()+";"+
          m_buttonMax10.ColorBackground()      +";"+
          m_buttonMin20.ColorBackground()+";"+
          m_buttonMax20.ColorBackground()+";"+
          m_buttonMin10.Pressed()+";"+
          m_buttonMax10.Pressed()+";"+
          m_buttonMin20.Pressed()+";"+
          m_buttonMax20.Pressed()+";"+
          PlotIndexGetInteger(0, PLOT_LINE_STYLE)+";"+
          PlotIndexGetInteger(1, PLOT_LINE_STYLE)+";"+
          PlotIndexGetInteger(2, PLOT_LINE_STYLE)+";"+
          PlotIndexGetInteger(3, PLOT_LINE_STYLE)+";";
      Print(str);
      FileWriteString(file_handle,str+"\r\n");


      //--- schließen Sie die Datei
      FileClose(file_handle);
      PrintFormat("Die Daten sind aufgezeichnet, die Datei %s geschlossen",FileName);
     }
   else
      PrintFormat("Fehler beim Öffnen der Datei %s, Fehlercode = %d",FileName,GetLastError());

   return 1;
  }
//+------------------------------------------------------------------+
*/

//+------------------------------------------------------------------+

//+------------------------------------------------------------------+
//| Die Funktion erhält den Wert der Höhe des Charts in Pixeln       |
//+------------------------------------------------------------------+
int ChartHeightInPixelsGet(const long chart_ID=0,const int sub_window=0)
  {
//--- Bereiten wir eine Variable, um den Wert der Eigenschaft zu erhalten
   long result=-1;
//--- Setzen den Wert des Fehlers zurück
   ResetLastError();
//--- Erhalten wir den Wert der Eigenschaft
   if(!ChartGetInteger(chart_ID,CHART_HEIGHT_IN_PIXELS,sub_window,result))
     {
      //--- Schreiben die Fehlermeldung in den Log "Experten"
      Print(__FUNCTION__+", Error Code = ",GetLastError());
     }
//--- Geben den Wert der Eigenschaft zurück
   return((int)result);
  }
//+------------------------------------------------------------------+
