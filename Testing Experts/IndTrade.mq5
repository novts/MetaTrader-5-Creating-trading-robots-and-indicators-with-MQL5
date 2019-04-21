//+------------------------------------------------------------------+
//|                                                     IndTrade.mq5 |
//|                                            Copyright 2018, NOVTS |
//|                                                 http://novts.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, NOVTS"
#property link      "http://novts.com"
#property version   "1.00"
#property indicator_chart_window

#property indicator_buffers 2
#property indicator_plots   1
#property indicator_type1    DRAW_COLOR_LINE
#property indicator_color1  clrBlack,clrRed,clrBlueViolet
#property indicator_style1  STYLE_SOLID
#property indicator_width1  2

input int ma_period=5;
input double delta=0.0001;
input int shift_delta=1;
int                  ma_shift=0;                   // смещение
ENUM_MA_METHOD       ma_method=MODE_EMA;           // тип сглаживания
ENUM_APPLIED_PRICE   applied_price=PRICE_WEIGHTED;    // тип цены
 
string               symbol=_Symbol;             // символ 
ENUM_TIMEFRAMES      period=PERIOD_CURRENT;  // таймфрейм

double         InBuffer[];
double         ColorBuffer[];
int    handleMA;
//--- переменная для хранения 
string name=symbol;
//--- имя индикатора на графике
string short_name;
//--- будем хранить количество значений в индикаторе Average Directional Movement Index
int    bars_calculated=0;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit()
  {
//--- indicator buffers mapping
   SetIndexBuffer(0,InBuffer,INDICATOR_DATA);
   SetIndexBuffer(1,ColorBuffer,INDICATOR_COLOR_INDEX);
//--- определимся с символом, на котором строится индикатор
   name=symbol;
//--- удалим пробелы слева и справа
   StringTrimRight(name);
   StringTrimLeft(name);
//--- если после этого длина строки name нулевая
   if(StringLen(name)==0)
     {
      //--- возьмем символ с графика, на котором запущен индикатор
      name=_Symbol;
     }
handleMA=iMA(name,period,ma_period,ma_shift,ma_method,applied_price);
short_name="Profit";
IndicatorSetString(INDICATOR_SHORTNAME,short_name);  
//---
   return(INIT_SUCCEEDED);
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
//--- количество копируемых значений из индикатора
   int values_to_copy;
//--- узнаем количество рассчитанных значений в индикаторе
   int calculated=BarsCalculated(handleMA);
   if(calculated<=0)
     {
      PrintFormat("BarsCalculated() вернул %d, код ошибки %d",calculated,GetLastError());
      return(0);
     }
//--- если это первый запуск вычислений нашего индикатора или изменилось количество значений в индикаторе
//--- или если необходимо рассчитать индикатор для двух или более баров (значит что-то изменилось в истории)
   if(prev_calculated==0 || calculated!=bars_calculated || rates_total>prev_calculated+1)
     {
      //--- если массив больше, чем значений в индикаторе на паре symbol/period, то копируем не все 
      //--- в противном случае копировать будем меньше, чем размер индикаторных буферов
      if(calculated>rates_total) values_to_copy=rates_total;
      else                       values_to_copy=calculated;
     }
   else
     {
      //--- значит наш индикатор рассчитывается не в первый раз и с момента последнего вызова OnCalculate())
      //--- для расчета добавилось не более одного бара
      values_to_copy=(rates_total-prev_calculated)+1;
     }

//--- если FillArraysFromBuffer вернула false, значит данные не готовы - завершаем работу
   if(!FillArrayFromBufferMA(InBuffer,ma_shift,handleMA,values_to_copy)) return(0);
   
//--- запомним количество значений в индикаторе Average Directional Movement Index

bars_calculated=calculated;
if(values_to_copy>1){

bool flagSell=false;
double priceSellOpen;
double priceSellStop;
bool flagBuy=false;
double priceBuyOpen;
double priceBuyStop;

int size=values_to_copy;
for (int i=shift_delta; i<(size-1); i++){

ColorBuffer[i]=0;

if((InBuffer[i-shift_delta]-InBuffer[i])>delta){
ColorBuffer[i]=1;
if(flagSell==false){
priceSellOpen=open[i];
if(!ObjectCreate(0,"Sell"+i,OBJ_ARROW,0,time[i],low[i]))
     {      
      return(false);
     }     
      ObjectSetInteger(0,"Sell"+i,OBJPROP_COLOR,clrRed);
      ObjectSetInteger(0,"Sell"+i,OBJPROP_ARROWCODE,234);
      ObjectSetInteger(0,"Sell"+i,OBJPROP_WIDTH,1);
      ObjectSetInteger(0,"Sell"+i,OBJPROP_ANCHOR,ANCHOR_LOWER);
      ObjectSetInteger(0,"Sell"+i,OBJPROP_HIDDEN,true);
      ObjectSetString(0,"Sell"+i,OBJPROP_TOOLTIP,""+close[i]);     
      
      }
 flagSell=true;     
}else{
if(flagSell==true){
priceSellStop=open[i];
double profit=priceSellOpen-priceSellStop;
if(profit>spread[i]/MathPow(10,Digits())){
if(!ObjectCreate(0,"SellStop"+i,OBJ_TEXT,0,time[i],low[i]))
     {      
      return(false);
     }     
      ObjectSetString(0,"SellStop"+i,OBJPROP_TEXT,"Profit: "+DoubleToString(profit*MathPow(10,Digits()),1));
      ObjectSetDouble(0,"SellStop"+i,OBJPROP_ANGLE,90.0); 
      ObjectSetInteger(0,"SellStop"+i,OBJPROP_COLOR,clrRed); 
     }
flagSell=false;
}
}

if((InBuffer[i]-InBuffer[i-shift_delta])>delta){
ColorBuffer[i]=2;
if(flagBuy==false){
priceBuyOpen=open[i];
 if(!ObjectCreate(0,"Buy"+i,OBJ_ARROW,0,time[i],high[i]))
     {      
      return(false);
     }
     
      ObjectSetInteger(0,"Buy"+i,OBJPROP_COLOR,clrGreen);
      ObjectSetInteger(0,"Buy"+i,OBJPROP_ARROWCODE,233);
      ObjectSetInteger(0,"Buy"+i,OBJPROP_WIDTH,1);
      ObjectSetInteger(0,"Buy"+i,OBJPROP_ANCHOR,ANCHOR_UPPER);
      ObjectSetInteger(0,"Buy"+i,OBJPROP_HIDDEN,true);
      ObjectSetString(0,"Buy"+i,OBJPROP_TOOLTIP,""+close[i]);       
      }
flagBuy=true;
}else{
if(flagBuy==true){
priceBuyStop=open[i];
double profit=priceBuyStop-priceBuyOpen;
if(profit>spread[i]/MathPow(10,Digits())){
if(!ObjectCreate(0,"BuyStop"+i,OBJ_TEXT,0,time[i],high[i]))
     {      
      return(false);
     }     
      ObjectSetString(0,"BuyStop"+i,OBJPROP_TEXT,"Profit: "+DoubleToString(profit*MathPow(10,Digits()),1));
      ObjectSetDouble(0,"BuyStop"+i,OBJPROP_ANGLE,90.0); 
      ObjectSetInteger(0,"BuyStop"+i,OBJPROP_COLOR,clrBlueViolet); 
      }
flagBuy=false;
}}}} 
return(rates_total);
}
//+------------------------------------------------------------------+
//| Заполняем индикаторный буфер из индикатора iMA                   |
//+------------------------------------------------------------------+
bool FillArrayFromBufferMA(double &values[],   // индикаторный буфер значений Moving Average
                         int shift,          // смещение
                         int ind_handle,     // хэндл индикатора iMA
                         int amount          // количество копируемых значений
                         )
  {
//--- сбросим код ошибки
   ResetLastError();
//--- заполняем часть массива iMABuffer значениями из индикаторного буфера под индексом 0
   if(CopyBuffer(ind_handle,0,-shift,amount,values)<0)
     {
      //--- если копирование не удалось, сообщим код ошибки
      PrintFormat("Не удалось скопировать данные из индикатора iMA, код ошибки %d",GetLastError());
      //--- завершим с нулевым результатом - это означает, что индикатор будет считаться нерассчитанным
      return(false);
     }
//--- все получилось
   return(true);
  }
void  OnDeinit(const int reason){
ObjectsDeleteAll(0,-1,-1);
}
