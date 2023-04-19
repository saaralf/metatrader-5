//------------------------------------------------------------------
#property description "DowHow Linie. Die Linie zeigt den Maimalen und Minimalen Preis der eingestellten Periode des Heiken Ashi Close Kurses dar. Bitte nur zu Testzwecken verwenden."
#property copyright   "© Michael Keller, 2023"
#property link        "mail@kellermichael.de"
#property version     "00.001"
//------------------------------------------------------------------
#property indicator_chart_window
#property indicator_buffers 7
#property indicator_plots   2
#property indicator_label1  "DowHowLinie SHORT"
#property indicator_type1   DRAW_COLOR_LINE
#property indicator_color1  clrOrangeRed,clrOrangeRed,clrOrangeRed
#property indicator_style1  STYLE_DOT
#property indicator_label2  "DowHowLinie LONG"
#property indicator_type2   DRAW_COLOR_LINE
#property indicator_color2  clrMediumSeaGreen,clrMediumSeaGreen,clrMediumSeaGreen
#property indicator_style2  STYLE_DOT



//
//--- input parameters
//

input int                inpPeriod = 10;          // MinMax period

//
//--- indicator buffers
//

double valu[],valuc[],vald[],valdc[],prices[];


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
   
         IndicatorSetString(INDICATOR_SHORTNAME,"DowHow Linie ("+(string)inpPeriod+")");
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
      int    _start = i-inpPeriod+1; if (_start<0) _start=0;
      double _max   = prices[ArrayMaximum(prices,_start,inpPeriod)];            
      double _min   = prices[ArrayMinimum(prices,_start,inpPeriod)];   

      //
      //---
      //
                  
      valu[i] = _max; valuc[i] = (i>0) ?(valu[i]>valu[i-1]) ? 1 :(valu[i]<valu[i-1]) ? 2 : valuc[i-1]: 0;
      vald[i] = _min; valdc[i] = (i>0) ?(vald[i]>vald[i-1]) ? 1 :(vald[i]<vald[i-1]) ? 2 : valdc[i-1]: 0;
    
   }
   return(i);
}