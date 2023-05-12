//------------------------------------------------------------------
#property description "DowHow Linie. Die Linie zeigt den Maximalen und Minimalen Preis der eingestellten Periode des Heiken Ashi Close Kurses dar."
#property description " "
#property description "Die Linie verwenden wir wie folgt:"
#property description "Sobalt ein Preis die Linie unter oder überschreitet , ziehen wir den STOPPLOSS unter / über die Kerze, die die Linie über/unterschritten hat"
#property description " "
#property description "ChangeLog 1.01: Die Periode wird nun für Max und Min einzeln berechnet. Dazu kann man die Periode gezielt einstellen"
#property description "Label1 und Label2 -> DowHowLinie Short/LONG in MIN/MAX umbenannt"

#property copyright   "© Michael Keller, 2023"
#property copyright   "© Michael Keller, 2023"
#property link        "mail@kellermichael.de"
#property version     "1.01"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 7
#property indicator_plots   2
#property indicator_label1  "DowHowLinie MIN"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrOrangeRed,clrOrangeRed,clrOrangeRed
#property indicator_style1  STYLE_DOT
#property indicator_label2  "DowHowLinie MAX"
#property indicator_type2   DRAW_COLOR_LINE
#property indicator_color2  clrMediumSeaGreen,clrMediumSeaGreen,clrMediumSeaGreen
#property indicator_style2  STYLE_DOT


//
//--- input parameters
//
enum perioden  
  { 
   zehn=10,     // 10 Kerzen
   zwanzig=20,     // 20 Kerzen 
  }; 

//input int                inpPeriod = 10;          // MinMax period
input group "Periode: (10, 20)"


input perioden                inpPeriodMAX = zehn;          // Anzahl Kerzen für die Max DowHowLinie
input perioden                inpPeriodMIN = zehn;          // Anzahl Kerzen für die Min DowHowLinie
input group "Sichtbar:"

input bool  maxlinevisible=true; //Max DowHowLinie sichtbar

input bool  minlinevisible=true;//Min DowHowLinie sichtbar


//
//--- indicator buffers
//


double valu[],valuc[],vald[],valdc[],prices[];
bool m_arrows;  // entspricht der Variablen ArrowsOnChart


//------------------------------------------------------------------
// Custom indicator initialization function
//------------------------------------------------------------------

int OnInit()
{
   //
   //--- indicator buffers mapping
   //
   
         SetIndexBuffer(0,valu  ,INDICATOR_DATA);
         SetIndexBuffer(1,valuc ,INDICATOR_COLOR_INDEX);
         SetIndexBuffer(2,vald  ,INDICATOR_DATA);
         SetIndexBuffer(3,valdc ,INDICATOR_COLOR_INDEX);
         SetIndexBuffer(6,prices,INDICATOR_COLOR_INDEX);
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
//---
//

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

   int i=(prev_calculated>0?prev_calculated-1:0); for (; i<rates_total && !_StopFlag; i++)
   {
      prices[i]=(open[i]+ high[i] + low[i] + close[i] ) /4.0; //Bereche den ClosePrice so wie bei HeikenAshi
    //  int    _start = i-inpPeriod+1; if (_start<0) _start=0;
      int    _startmax = i-inpPeriodMAX+1; if (_startmax<0) _startmax=0;
      int    _startmin = i-inpPeriodMIN+1; if (_startmin<0) _startmin=0;
      
      double _max   = prices[ArrayMaximum(prices,_startmax,inpPeriodMAX)];            
      double _min   = prices[ArrayMinimum(prices,_startmin,inpPeriodMIN)];   

      //
      //---
      //
                  
    if (maxlinevisible)
    {
      valu[i] = _max; valuc[i] = (i>0) ?(valu[i]>valu[i-1]) ? 1 :(valu[i]<valu[i-1]) ? 2 : valuc[i-1]: 0;
      
    } 
         if (minlinevisible)
         {
         vald[i] = _min; valdc[i] = (i>0) ?(vald[i]>vald[i-1]) ? 1 :(vald[i]<vald[i-1]) ? 2 : valdc[i-1]: 0;
         }
    
   
   }
   return(i);
}