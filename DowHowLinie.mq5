//------------------------------------------------------------------
#property description "DowHow Linie. Die Linie zeigt den Maximalen und Minimalen Preis der eingestellten Periode des HeikenAshi Close Preises an."
#property description " "
#property description "Die DowHow Linie hilft uns fachlich Korrekt den Trade zu beenden und unsere Kapital zu schützen."
#property description " "
#property description "Die Linie verwenden wir wie folgt:"
#property description "Gibt es einen Kurs (Spike, Docht, Schlusskurs) ober/unterhalb der DowHow Linie, dann ziehen wir den StoppLoss unter/über diese Kerze ran"


//#property description "Changelog 2.00: Der Indikator wurde neu Programmiert und ist keine abgeleitete Kopie des MINMAX Indikators mehr."
//#property description "Die Schlusskurse werden nicht mehr selbst berechnet, sondern werden immer vom HeikenAshi Indikator bereitgestellt."
//#property description "Dies spart die doppelte Berechnung von Werten wenn Heiken Ashi und DowHowLinie gemeinsam verwendet werden. "

//#property description "Es wird iCustom und CopyBuffers verwendet um die CloseKurse zu erhalten"
//#property description "ChangeLog 1.02: Die Linien können nun aus und eingeschaltet werden, je nachdem, welche Linien man sehen will."
//#property description "ChangeLog 1.01: Die Periode wird nun für Max und Min einzeln berechnet. Dazu kann man die Periode gezielt einstellen"
//#property description "Label1 und Label2 -> DowHowLinie Short/LONG in MIN/MAX umbenannt"

#property copyright   "© Michael Keller, 2023"

#property link        "mail@kellermichael.de"
#property version     "2.00"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 5
#property indicator_plots   2
//Linie oben
#property indicator_label1  "DowHowLinieMax"
#property indicator_type1   DRAW_COLOR_LINE //
#property indicator_color1  clrOrangeRed
#property indicator_style1  STYLE_DOT
//Linie unten
#property indicator_label2  "DowHowLinieMin"
#property indicator_type2   DRAW_COLOR_LINE
#property indicator_color2  clrMediumSeaGreen
#property indicator_style2  STYLE_DOT





//==============================
//Die obere Linien ist nur rot
//Die untere Linie ist nur grün.
//Grundsätzlich:
//LONG Trade: StopLoss an die grüne Linie.
//SHORT Trade: StopLoss an die rote Linie.

//
//--- input parameters
//
enum perioden  
  { 
   zehn=10,     // 10 Kerzen
   zwanzig=20,     // 20 Kerzen 
  }; 


input group "Periode: (10, 20)"
input perioden                inpPeriodMAX = zehn;          // Anzahl Kerzen für die Max DowHowLinie
input perioden                inpPeriodMIN = zehn;          // Anzahl Kerzen für die Min DowHowLinie
input group "Sichtbar:"
input bool  maxlinevisible=true; //Max DowHowLinie sichtbar
input bool  minlinevisible=true;//Min DowHowLinie sichtbar


//
//--- indicator buffers
//


double DowHowLinieMin[],DowHowLinieMinColor[];
double DowHowLinieMax[],DowHowLinieMaxColor[];
double prices[];
// Zum kopieren der HeikenAshi
int DowHowButtler;
int heikenAshi;
double heikenAshiOpen[], heikenAshiHigh[], heikenAshiLow[], heikenAshiClose[];


//------------------------------------------------------------------
// Custom indicator initialization function
//------------------------------------------------------------------


int OnInit()
{

 
 
   heikenAshi= iCustom ( _Symbol , _Period , "Examples\\Heiken_Ashi" );

  
   //
   //--- indicator buffers mapping
   //
   
      SetIndexBuffer(0,DowHowLinieMax  ,INDICATOR_DATA);
      SetIndexBuffer(1,DowHowLinieMaxColor ,INDICATOR_COLOR_INDEX);
      SetIndexBuffer(2,DowHowLinieMin  ,INDICATOR_DATA);
      SetIndexBuffer(3,DowHowLinieMinColor ,INDICATOR_COLOR_INDEX);
      SetIndexBuffer(4,prices,INDICATOR_COLOR_INDEX);
     
   
   //            
   //--- indicator short name assignment
   //
   
   IndicatorSetString(INDICATOR_SHORTNAME,"DowHow Linie MIN("+(string)inpPeriodMIN+"), MAX("+(string)inpPeriodMAX+")");
   return (INIT_SUCCEEDED);
}
void OnDeinit(const int reason)
{
  
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

int OnCalculate(const int rates_total,const int prev_calculated,const datetime &time[],
                const double &open[],
                const double &high[],
                const double &low[],
                const double &close[],
                const long &tick_volume[],
                const long &volume[],
                const int &spread[])
{

   copy(rates_total); //Importiere soviele HeikenAshi Kerzen wie rates_total
   
   int i=(prev_calculated>0?prev_calculated-1:0);
   
   for (; i<rates_total && !_StopFlag; i++)
   {
     
      // Nimm den HeikenAshi Close Preis
      prices[i]=heikenAshiClose[i];
    
      int    _startmax = i-inpPeriodMAX+1; if (_startmax<0) _startmax=0;
      int    _startmin = i-inpPeriodMIN+1; if (_startmin<0) _startmin=0;
      
      double _max   = prices[ArrayMaximum(prices,_startmax,inpPeriodMAX)];            
      double _min   = prices[ArrayMinimum(prices,_startmin,inpPeriodMIN)];   

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
   
     
                  
    if (maxlinevisible)
    {
      DowHowLinieMax[i] = _max; DowHowLinieMaxColor[i] =  0;
      
    } 
    if (minlinevisible)
    {
      DowHowLinieMin[i] = _min; DowHowLinieMinColor[i] = 0;
    }
    
   
        
   }
   return(i);
}