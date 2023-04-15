//+------------------------------------------------------------------+
//|                                                 DowHow Linie.mq4 |
//|                                      Erstellt von Michael Keller |
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "Michael Keller"
#property link      "mail@kellermichael.de"

#property indicator_chart_window
#property indicator_buffers  9
#property indicator_color1   clrMediumSeaGreen
#property indicator_color2   clrOrangeRed
#property indicator_color3   clrOrangeRed
#property indicator_color4   clrMediumSeaGreen
#property indicator_color5   clrOrangeRed
#property indicator_color6   clrOrangeRed
#property indicator_color7   clrMediumSeaGreen
#property indicator_color8   clrOrangeRed
#property indicator_color9   clrOrangeRed
#property indicator_width7   2
#property indicator_width8   2
#property indicator_width9   2
#property strict

//
//
//
//
//


input int                inpPeriod = 10;       // DowHow Linie periode (Standart auf 10)


double valu[],valuDa[],valuDb[],valuc[],vald[],valdDa[],valdDb[],valdc[],prices[];

//------------------------------------------------------------------
// Custom indicator initialization function
//------------------------------------------------------------------

int OnInit()
{
   IndicatorBuffers(13);
   SetIndexBuffer(0, valu  ,INDICATOR_DATA); SetIndexStyle(0,DRAW_LINE);
   SetIndexBuffer(1, valuDa,INDICATOR_DATA); SetIndexStyle(1,DRAW_LINE);
   SetIndexBuffer(2, valuDb,INDICATOR_DATA); SetIndexStyle(2,DRAW_LINE);
   SetIndexBuffer(3, vald  ,INDICATOR_DATA); SetIndexStyle(3,DRAW_LINE);
   SetIndexBuffer(4, valdDa,INDICATOR_DATA); SetIndexStyle(4,DRAW_LINE);
   SetIndexBuffer(5, valdDb,INDICATOR_DATA); SetIndexStyle(5,DRAW_LINE);
   SetIndexBuffer(9, valuc ,INDICATOR_CALCULATIONS);
   SetIndexBuffer(10,valdc ,INDICATOR_CALCULATIONS);
   SetIndexBuffer(12,prices,INDICATOR_CALCULATIONS);
   
   IndicatorShortName("DowHow Linie ("+(string)inpPeriod+")");
return (INIT_SUCCEEDED);
}
void OnDeinit(const int reason) { }

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
  
  int i,counted_bars=prev_calculated;
      if(counted_bars<0) return(-1);
      if(counted_bars>0) counted_bars--;
         int limit = fmin(rates_total-counted_bars,rates_total-1); 
   
   //
   //
   //
   //
   //
   
   if (valuc[limit]==-1) CleanPoint(limit,valuDa,valuDb);
   if (valdc[limit]==-1) CleanPoint(limit,valdDa,valdDb);
   for(i = limit; i >= 0; i--)
   { 
      prices[i]=(open[i]+ high[i] + low[i] + close[i] ) /4.0; //Bereche den ClosePrice so wie bei HeikenAshi
      double _max = prices[ArrayMaximum(prices,inpPeriod,i)];            
      double _min = prices[ArrayMinimum(prices,inpPeriod,i)];   

      //
      //
      //
      //
      //
      
      valuDa[i] = EMPTY_VALUE;
      valuDb[i] = EMPTY_VALUE; 
      valdDa[i] = EMPTY_VALUE;
      valdDb[i] = EMPTY_VALUE;  
      valu[i] = _max; valuc[i] =            (i<rates_total-1) ?(valu[i]>valu[i+1]) ? 1 :(valu[i]<valu[i+1]) ? -1 : valuc[i+1]: 0;
      vald[i] = _min; valdc[i] =            (i<rates_total-1) ?(vald[i]>vald[i+1]) ? 1 :(vald[i]<vald[i+1]) ? -1 : valdc[i+1]: 0;
      if (valuc[i] == -1) PlotPoint(i,valuDa,valuDb,valu);
      if (valdc[i] == -1) PlotPoint(i,valdDa,valdDb,vald);
     
   }
return(rates_total);
}


//-------------------------------------------------------------------
//                                                                  
//-------------------------------------------------------------------
//
//
//
//
//

void CleanPoint(int i,double& first[],double& second[])
{
   if (i>=Bars-3) return;
   if ((second[i]  != EMPTY_VALUE) && (second[i+1] != EMPTY_VALUE))
        second[i+1] = EMPTY_VALUE;
   else
      if ((first[i] != EMPTY_VALUE) && (first[i+1] != EMPTY_VALUE) && (first[i+2] == EMPTY_VALUE))
          first[i+1] = EMPTY_VALUE;
}

void PlotPoint(int i,double& first[],double& second[],double& from[])
{
   if (i>=Bars-2) return;
   if (first[i+1] == EMPTY_VALUE)
      if (first[i+2] == EMPTY_VALUE) 
            { first[i]  = from[i]; first[i+1]  = from[i+1]; second[i] = EMPTY_VALUE; }
      else  { second[i] = from[i]; second[i+1] = from[i+1]; first[i]  = EMPTY_VALUE; }
   else     { first[i]  = from[i];                          second[i] = EMPTY_VALUE; }
}
