//------------------------------------------------------------------
#property description "DowHow Linie. Die Linie zeigt den Maximalen und Minimalen Preis der eingestellten Periode des HeikenAshi Close Preises an."
#property description " "
#property description "Die DowHow Linie hilft uns fachlich Korrekt den Trade zu beenden und unsere Kapital zu schützen."
#property description " "
#property description "Die Linie verwenden wir wie folgt:"
#property description "Gibt es einen LONG/SHORT Kurs (Spike, Docht, Schlusskurs) ober/unterhalb der DowHow Linie, dann ziehen wir den StoppLoss unter/über diese Kerze ran"

//#property description "V3.02: 3. Bekanntes Problem derzeit: Wählt man andere Linienarten, werden immer "Standart Linien" genommen, egal was man auswählt"
//#property description "V3.02: 2. Bekanntes Problem derzeit: SInd Kerzen oder Linien unterhalb der Buttons, dann kann man die Buttons nicht klicken. Dazu muss man zuerst den Chart scrollen, dann gehts wieder.... Ich arbeite an einer Lösung."
//#property description "V3.02: 1. Das Problem, was Markus im Webinar am Freitag hatte: Das war zur selben Zeit bei mir auch. Seit das Webinar zu Ende war, kann ich den Fehler nicht mehr reproduzieren. Bitte gibt mir Eure Hinweise. Ich vermute ein Resourcen Problem auf dem Rechner. "
//#property description "Changelog 3.02: Manchmal funktioniert nix mehr bei den Buttons. Habe die prüfung im EVenthandler angepasst ."
//#property description "Changelog 3.00: Der Indikator wurden Buttons zum aus und einschalten der Linien hinzugefügt."
//#property description "Changelog 3.00: ProgrammCode aufgeräumt."
//#property description "Changelog 2.00: Der Indikator wurde neu Programmiert und ist keine abgeleitete Kopie des MINMAX Indikators mehr."
//#property description "Die Schlusskurse werden nicht mehr selbst berechnet, sondern werden immer vom HeikenAshi Indikator bereitgestellt."
//#property description "Dies spart die doppelte Berechnung von Werten wenn Heiken Ashi und DowHowLinie gemeinsam verwendet werden. "

//#property description "Es wird iCustom und CopyBuffers verwendet um die CloseKurse zu erhalten"
//#property description "ChangeLog 1.02: Die Linien können nun aus und eingeschaltet werden, je nachdem, welche Linien man sehen will."
//#property description "ChangeLog 1.01: Die Periode wird nun für Max und Min einzeln berechnet. Dazu kann man die Periode gezielt einstellen"
//#property description "Label1 und Label2 -> DowHowLinie Short/LONG in MIN/MAX umbenannt"

#property copyright   "© Michael Keller, Juni 2023"

#property link        "mail@kellermichael.de"
#property version     "3.02"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 9
#property indicator_plots   4
//10er Linie oben
#property indicator_label1  "MAX 10 Dow How Linie"
#property indicator_type1   DRAW_LINE //
#property indicator_color1  clrRed
#property indicator_style1  STYLE_SOLID
//10er Linie unten
#property indicator_label2  "MIN 10 Dow How Linie"
#property indicator_type2   DRAW_LINE
#property indicator_color2  clrYellowGreen
#property indicator_style2  STYLE_SOLID

//20er Linie oben
#property indicator_label3  "MAX 20 Dow How Linie"
#property indicator_type3  DRAW_NONE
#property indicator_color3  clrOrangeRed
#property indicator_style3  STYLE_SOLID

//20er Linie unten
#property indicator_label4  "MIN 20 Dow How Linie"
#property indicator_type4  DRAW_NONE
#property indicator_color4  clrMediumSeaGreen
#property indicator_style4  STYLE_SOLID



#include <Controls\Button.mqh>
CButton DH10MaxButton;
CButton DH20MaxButton;
CButton DH10MinButton;
CButton DH20MinButton;


bool dh10Min=true;
bool dh20Min=false;
bool dh10Max=true;
bool dh20Max=false;


//==============================
//Die obere Linien ist nur rot
//Die untere Linie ist nur grün.
//Grundsätzlich:
//LONG Trade: StopLoss an die grüne Linie.
//SHORT Trade: StopLoss an die rote Linie.

//
//--- indicator buffers
//

string               dh10Min_button_text="Min10";
string               dh20Min_button_text="Min20";
string               dh10Max_button_text="Max10";
string               dh20Max_button_text="Max20";

double DowHowLinieMin10[];
double DowHowLinieMax10[];
double DowHowLinieMin20[];
double DowHowLinieMax20[];
double prices[];
// Zum kopieren der HeikenAshi
int DowHowButtler;
int heikenAshi;
double heikenAshiOpen[], heikenAshiHigh[], heikenAshiLow[], heikenAshiClose[];


//------------------------------------------------------------------
// Custom indicator initialization function
//------------------------------------------------------------------

//+------------------------------------------------------------------+
//| ChartEvent function                                              |
//+------------------------------------------------------------------+
void OnChartEvent(const int id,
                  const long &lparam,
                  const double &dparam,
                  const string &sparam)
  {
//---Observes cursor position, Highlight button and detect Click event

   if(id == CHARTEVENT_OBJECT_CLICK)
     {
      check(id, lparam, dparam, sparam);
     }
  }

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void check(const int id,
           const long &lparam,
           const double &dparam,
           const string &sparam)
  {



   Print("check ausgelöst");
   if(DH10MaxButton.Contains(lparam,dparam))
      DH10MaxButton.Pressed(true);   //Dtect cursor on the button
   else
      DH10MaxButton.Pressed(false);
   if(id == CHARTEVENT_OBJECT_CLICK && sparam == dh10Max_button_text)
     {
      Print("dh10Max_button_text Pressed");

      if(dh10Max==false)
         dh10Max=true;
      else
         dh10Max=false;


      switch(dh10Max)
        {
         case(true):
            PlotIndexSetInteger(0,PLOT_DRAW_TYPE,DRAW_LINE);
            PlotIndexSetInteger(0,PLOT_LINE_STYLE,indicator_type1);
            PlotIndexSetInteger(0,PLOT_LINE_COLOR,indicator_color1);
            DH10MaxButton.ColorBackground(clrRed);
            break;

         case(false):
            PlotIndexSetInteger(0,PLOT_DRAW_TYPE,DRAW_NONE);
            PlotIndexSetInteger(0,PLOT_LINE_STYLE,indicator_type1);
            PlotIndexSetInteger(0,PLOT_LINE_COLOR,clrNONE);
            DH10MaxButton.ColorBackground(clrGray);
            break;
        }
     }

   if(DH20MaxButton.Contains(lparam,dparam))
      DH20MaxButton.Pressed(true);   //Dtect cursor on the button
   else
      DH20MaxButton.Pressed(false);
   if(id == CHARTEVENT_OBJECT_CLICK && sparam == dh20Max_button_text)
     {
      Print("dh20Max_button_text Pressed");

      if(dh20Max==false)
         dh20Max=true;
      else
         dh20Max=false;


      switch(dh20Max)
        {
         case(true):
            PlotIndexSetInteger(2,PLOT_DRAW_TYPE,DRAW_LINE);
            PlotIndexSetInteger(2,PLOT_LINE_STYLE,indicator_type3);
            PlotIndexSetInteger(2,PLOT_LINE_COLOR,indicator_color3);
            DH20MaxButton.ColorBackground(clrOrangeRed);
            break;

         case(false):
            PlotIndexSetInteger(2,PLOT_DRAW_TYPE,DRAW_NONE);
            PlotIndexSetInteger(2,PLOT_LINE_STYLE,indicator_type3);
            PlotIndexSetInteger(2,PLOT_LINE_COLOR,clrNONE);
            DH20MaxButton.ColorBackground(clrGray);
            break;
        }
     }

   if(DH10MinButton.Contains(lparam,dparam))
      DH10MinButton.Pressed(true);   //Dtect cursor on the button
   else
      DH10MinButton.Pressed(false);
   if(id == CHARTEVENT_OBJECT_CLICK && sparam == dh10Min_button_text)
     {
      Print("dh10Min_button_text Pressed");

      if(dh10Min==false)
         dh10Min=true;
      else
         dh10Min=false;


      switch(dh10Min)
        {
         case(true):
            PlotIndexSetInteger(1,PLOT_DRAW_TYPE,DRAW_LINE);
            PlotIndexSetInteger(1,PLOT_LINE_STYLE,indicator_type2);
            PlotIndexSetInteger(1,PLOT_LINE_COLOR,indicator_color2);
            DH10MinButton.ColorBackground(clrYellowGreen);
            break;

         case(false):
            PlotIndexSetInteger(1,PLOT_DRAW_TYPE,DRAW_NONE);
            PlotIndexSetInteger(1,PLOT_LINE_STYLE,indicator_type2);
            PlotIndexSetInteger(1,PLOT_LINE_COLOR,clrNONE);
            DH10MinButton.ColorBackground(clrGray);
            break;
        }
     }

   if(DH20MinButton.Contains(lparam,dparam))
      DH20MinButton.Pressed(true);   //Dtect cursor on the button
   else
      DH20MinButton.Pressed(false);
   if(id == CHARTEVENT_OBJECT_CLICK && sparam == dh20Min_button_text)
     {
      Print("dh20Min_button_text Pressed");

      if(dh20Min==false)
         dh20Min=true;
      else
         dh20Min=false;


      switch(dh20Min)
        {
         case(true):
            PlotIndexSetInteger(3,PLOT_DRAW_TYPE,DRAW_LINE);
            PlotIndexSetInteger(3,PLOT_LINE_STYLE,indicator_type4);
            PlotIndexSetInteger(3,PLOT_LINE_COLOR,indicator_color2);
            DH20MinButton.ColorBackground(clrMediumSeaGreen);
            break;

         case(false):
            PlotIndexSetInteger(3,PLOT_DRAW_TYPE,DRAW_NONE);
            PlotIndexSetInteger(3,PLOT_LINE_STYLE,indicator_type4);
            PlotIndexSetInteger(3,PLOT_LINE_COLOR,clrNONE);
            DH20MinButton.ColorBackground(clrGray);
            break;
        }
     }

   ChartRedraw();
  }


//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int OnInit()
  {
   int xstart=500;
   int ystart=5;
   int button_breite=50;
   int button_hoehe=20;
   int button_abstand=5;
   int x1_DH10MaxButton = xstart;
   int y1_DH10MaxButton = ystart;
   int x2_DH10MaxButton = x1_DH10MaxButton+button_breite;
   int y2_DH10MaxButton = y1_DH10MaxButton+button_hoehe;


   DH10MaxButton.Create(0,dh10Max_button_text,0,x1_DH10MaxButton,y1_DH10MaxButton,x2_DH10MaxButton,y2_DH10MaxButton); //Create DH10MaxButton
   DH10MaxButton.Text(dh10Max_button_text);                         //Label

   int x1_DH20MaxButton = xstart+button_breite+button_abstand;
   int y1_DH20MaxButton = ystart;
   int x2_DH20MaxButton = x1_DH20MaxButton+button_breite;
   int y2_DH20MaxButton = y1_DH20MaxButton+button_hoehe;

   DH20MaxButton.Create(0,dh20Max_button_text,0,x1_DH20MaxButton,y1_DH20MaxButton,x2_DH20MaxButton,y2_DH20MaxButton); //Create DH20MaxButton
   DH20MaxButton.Text(dh20Max_button_text);                         //Label

   int x1_DH10MinButton = xstart+button_breite+button_abstand+button_breite+button_abstand;
   int y1_DH10MinButton = ystart;
   int x2_DH10MinButton = x1_DH10MinButton+button_breite;
   int y2_DH10MinButton = y1_DH10MinButton+button_hoehe;

   DH10MinButton.Create(0,dh10Min_button_text,0,x1_DH10MinButton,y1_DH10MinButton,x2_DH10MinButton,y2_DH10MinButton);//Create DH10MinButton
   DH10MinButton.Text(dh10Min_button_text);                         //Label


   int x1_DH20MinButton = xstart+button_breite+button_abstand+button_breite+button_abstand+button_breite+button_abstand;
   int y1_DH20MinButton = ystart;
   int x2_DH20MinButton = x1_DH20MinButton+button_breite;
   int y2_DH20MinButton = y1_DH20MinButton+button_hoehe;

   DH20MinButton.Create(0,dh20Min_button_text,0,x1_DH20MinButton,y1_DH20MinButton,x2_DH20MinButton,y2_DH20MinButton);//Create DH20MinButton
   DH20MinButton.Text(dh20Min_button_text);                         //Label


   DH10MaxButton.Pressed(true);
   DH10MinButton.Pressed(true);

   if(DH10MaxButton.Pressed())
     {
      DH10MaxButton.ColorBackground(indicator_color1);
     }
   else
     {
      DH10MaxButton.ColorBackground(clrGray);
     }
   if(DH20MaxButton.Pressed())
     {
      DH20MaxButton.ColorBackground(indicator_color3);
     }
   else
     {
      DH20MaxButton.ColorBackground(clrGray);
     }
   if(DH10MinButton.Pressed())
     {
      DH10MinButton.ColorBackground(indicator_color2);
     }
   else
     {
      DH10MinButton.ColorBackground(clrGray);
     }
   if(DH20MinButton.Pressed())
     {
      DH20MinButton.ColorBackground(indicator_color4);
     }
   else
     {
      DH20MinButton.ColorBackground(clrGray);
     }



   heikenAshi= iCustom(_Symbol, _Period, "Examples\\Heiken_Ashi");


//
//--- indicator buffers mapping
//

   SetIndexBuffer(0,DowHowLinieMax10,INDICATOR_DATA);
   SetIndexBuffer(1,DowHowLinieMin10,INDICATOR_DATA);
   SetIndexBuffer(2,DowHowLinieMax20,INDICATOR_DATA);
   SetIndexBuffer(3,DowHowLinieMin20,INDICATOR_DATA);
// SetIndexBuffer(4,DowHowLinieMaxColor10 ,INDICATOR_COLOR_INDEX);
//// SetIndexBuffer(5,DowHowLinieMinColor10 ,INDICATOR_COLOR_INDEX);
//SetIndexBuffer(6,DowHowLinieMaxColor20 ,INDICATOR_COLOR_INDEX);
////SetIndexBuffer(7,DowHowLinieMinColor20 ,INDICATOR_COLOR_INDEX);
   SetIndexBuffer(8,prices,INDICATOR_DATA);

   PlotIndexSetInteger(0,PLOT_LINE_STYLE,indicator_type1);
   PlotIndexSetInteger(1,PLOT_LINE_STYLE,indicator_type2);
   PlotIndexSetInteger(2,PLOT_LINE_STYLE,indicator_type3);
   PlotIndexSetInteger(3,PLOT_LINE_STYLE,indicator_type4);


   if(dh10Max)
     {
      PlotIndexSetInteger(0,PLOT_LINE_COLOR,indicator_color1);
     }
   else
     {
      PlotIndexSetInteger(0,PLOT_LINE_COLOR,clrGray);
     }

   if(dh10Min)
     {
      PlotIndexSetInteger(1,PLOT_LINE_COLOR,indicator_color2);
     }
   else
     {
      PlotIndexSetInteger(1,PLOT_LINE_COLOR,clrGray);
     }
   if(dh10Max)
     {
      PlotIndexSetInteger(2,PLOT_LINE_COLOR,indicator_color3);
     }
   else
     {
      PlotIndexSetInteger(2,PLOT_LINE_COLOR,clrGray);
     }
   if(dh10Min)
     {
      PlotIndexSetInteger(3,PLOT_LINE_COLOR,indicator_color4);
     }
   else
     {
      PlotIndexSetInteger(3,PLOT_LINE_COLOR,clrGray);
     }

//
//--- indicator short name assignment
//
   ChartRedraw();
   IndicatorSetString(INDICATOR_SHORTNAME,"Dow How Linie");
   return (INIT_SUCCEEDED);
  }



//------------------------------------------------------------------
// Custom pseudo function(s)
//------------------------------------------------------------------
//
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
//------------------------------------------------------------------
// Custom indicator iteration function
//------------------------------------------------------------------

//+------------------------------------------------------------------+
//|                                                                  |
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

   copy(rates_total+100); //Importiere soviele HeikenAshi Kerzen wie rates_total

   int i=(prev_calculated>0?prev_calculated-1:0);

   for(; i<rates_total && !_StopFlag; i++)
     {

      // Nimm den HeikenAshi Close Preis
      prices[i]=heikenAshiClose[i];

      int    _startmax10 = i-10+1;
      if(_startmax10<0)
         _startmax10=0;
      int    _startmin10 = i-10+1;
      if(_startmin10<0)
         _startmin10=0;


      int    _startmax20 = i-20+1;
      if(_startmax20<0)
         _startmax20=0;
      int    _startmin20 = i-20+1;
      if(_startmin20<0)
         _startmin20=0;

      double _max10   = prices[ArrayMaximum(prices,_startmax10,10)];
      double _min10   = prices[ArrayMinimum(prices,_startmin10,10)];

      double _max20   = prices[ArrayMaximum(prices,_startmax20,20)];
      double _min20   = prices[ArrayMinimum(prices,_startmin20,20)];

      //
      //---
      //
      // HeikenAshi Werte ausgeben der aktuellen Kerze
      /*
       Comment("heikenAshiOpen ",DoubleToString(heikenAshiOpen[i],_Digits),
               "\n heikenAshiHigh ",DoubleToString(heikenAshiHigh[i],_Digits),
               "\n heikenAshiLow ",DoubleToString(heikenAshiLow[i],_Digits),
               "\n heikenAshiClose ",DoubleToString(heikenAshiClose[i],_Digits));
      */

      if(dh10Max)
        {
         PlotIndexSetInteger(0,PLOT_LINE_COLOR,indicator_color1);
        }
      else
        {
         PlotIndexSetInteger(0,PLOT_LINE_COLOR,clrGray);
        }

      if(dh10Min)
        {
         PlotIndexSetInteger(1,PLOT_LINE_COLOR,indicator_color2);
        }
      else
        {
         PlotIndexSetInteger(1,PLOT_LINE_COLOR,clrGray);
        }
      if(dh10Max)
        {
         PlotIndexSetInteger(2,PLOT_LINE_COLOR,indicator_color3);
        }
      else
        {
         PlotIndexSetInteger(2,PLOT_LINE_COLOR,clrGray);
        }
      if(dh10Min)
        {
         PlotIndexSetInteger(3,PLOT_LINE_COLOR,indicator_color4);
        }
      else
        {
         PlotIndexSetInteger(3,PLOT_LINE_COLOR,clrGray);
        }


      DowHowLinieMax10[i] = _max10; //DowHowLinieMaxColor10[i] =  0;
      DowHowLinieMax20[i] = _max20;// DowHowLinieMaxColor20[i] =  0;
      DowHowLinieMin10[i] = _min10;// DowHowLinieMinColor10[i] = 0;
      DowHowLinieMin20[i] = _min20;// DowHowLinieMinColor20[i] = 0;
      ChartRedraw();



     }
   return(i);
  }

//+------------------------------------------------------------------+
//| Expert deinitialization function                                 |
//+------------------------------------------------------------------+
void OnDeinit(const int reason)
  {
//--- Kommentare löschen
   Comment("");
//--- destroy dialog
   DH10MaxButton.Destroy(reason);
   DH20MaxButton.Destroy(reason);
   DH10MinButton.Destroy(reason);
   DH20MinButton.Destroy(reason);


  }
//+------------------------------------------------------------------+
