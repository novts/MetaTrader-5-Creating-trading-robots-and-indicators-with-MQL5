//+------------------------------------------------------------------+
//|                                                   CheckTrade.mqh |
//|                                            Copyright 2018, NOVTS |
//|                                                 http://novts.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, NOVTS"
#property link      "http://novts.com"
#property version   "1.00"
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CheckTrade
  {
private:

public:
                     CheckTrade();
                    ~CheckTrade();
int                  OnCheckTradeInit(double   lot);
int                  OnCheckTradeTick(double   lot, double spread);
  };
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CheckTrade::CheckTrade()
  {
  }
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CheckTrade::~CheckTrade()
  {
  }
//+------------------------------------------------------------------+
int CheckTrade::OnCheckTradeInit(double   lot){
//Проверка запуска эксперта на реальном счете  
if((ENUM_ACCOUNT_TRADE_MODE)AccountInfoInteger(ACCOUNT_TRADE_MODE)==ACCOUNT_TRADE_MODE_REAL){  
  int mb=MessageBox("Запустить советник на реальном счете?","Message Box",MB_YESNO|MB_ICONQUESTION);      
  if(mb==IDNO) return(0);     
 } 
//Проверки: 
//отсутствие соединения к серверу, запрет торговли на стороне сервера
//брокер запрещает автоматическую торговлю
if(!TerminalInfoInteger(TERMINAL_CONNECTED)){
Alert("No connection to the trade server");
return(0);
}else{
if(!AccountInfoInteger(ACCOUNT_TRADE_ALLOWED)){
Alert("Trade for this account is prohibited");
return(0);
  }
 } 
  if(!AccountInfoInteger(ACCOUNT_TRADE_EXPERT)){
      Alert("Trade with the help of experts for the account is prohibited");
   return(0);
  }
//Проверить корректность объема, с которым мы собираемся выйти на рынок
   if(lot<SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MIN)||lot>SymbolInfoDouble(Symbol(),SYMBOL_VOLUME_MAX)){ 
 Alert("Lot is not correct!!!");      
      return(0);
}
   return(INIT_SUCCEEDED);

}

int CheckTrade::OnCheckTradeTick(double   lot,double spread){
//Проверка отсутствия соединения к серверу
if(!TerminalInfoInteger(TERMINAL_CONNECTED)){
Alert("No connection to the trade server");
return(0);
}
//Включена ли кнопка авто-торговли в клиентском терминале 
if (!TerminalInfoInteger(TERMINAL_TRADE_ALLOWED)){ 
Alert("Разрешение на автоматическую торговлю выключено!");
return(0);
}
//Разрешение на торговлю с помощью эксперта отключено в общих свойствах самого эксперта   
if(!MQLInfoInteger(MQL_TRADE_ALLOWED)){
Alert("Автоматическая торговля запрещена в свойствах эксперта ",__FILE__);
return(0);
}
//Уровень залоговых средств, при котором требуется пополнение счета
if((ENUM_ACCOUNT_STOPOUT_MODE)AccountInfoInteger(ACCOUNT_MARGIN_SO_MODE)==ACCOUNT_STOPOUT_MODE_PERCENT){
if(AccountInfoDouble(ACCOUNT_MARGIN_LEVEL)!=0&&AccountInfoDouble(ACCOUNT_MARGIN_LEVEL)
<=AccountInfoDouble(ACCOUNT_MARGIN_SO_CALL)){
Alert("Margin Call!!!");
return(0);
}} 
if((ENUM_ACCOUNT_STOPOUT_MODE)AccountInfoInteger(ACCOUNT_MARGIN_SO_MODE)==ACCOUNT_STOPOUT_MODE_MONEY){
if(AccountInfoDouble(ACCOUNT_EQUITY)<=AccountInfoDouble(ACCOUNT_MARGIN_SO_CALL)){
Alert("Margin Call!!!"); 
return(0); 
}}
//Уровень залоговых средств, при достижении которого происходит принудительное закрытие самой убыточной позиции
if((ENUM_ACCOUNT_STOPOUT_MODE)AccountInfoInteger(ACCOUNT_MARGIN_SO_MODE)==ACCOUNT_STOPOUT_MODE_PERCENT){
if(AccountInfoDouble(ACCOUNT_MARGIN_LEVEL)!=0&&AccountInfoDouble(ACCOUNT_MARGIN_LEVEL)
<=AccountInfoDouble(ACCOUNT_MARGIN_SO_SO)){
Alert("Stop Out!!!");
return(0);
}} 
if((ENUM_ACCOUNT_STOPOUT_MODE)AccountInfoInteger(ACCOUNT_MARGIN_SO_MODE)==ACCOUNT_STOPOUT_MODE_MONEY){
if(AccountInfoDouble(ACCOUNT_EQUITY)<=AccountInfoDouble(ACCOUNT_MARGIN_SO_SO)){
Alert("Stop Out!!!");
return(0);
}}
//Проверка размера свободных средств на счете, доступных для открытия позиции
 double margin;
 MqlTick last_tick;
 ResetLastError();
 if(SymbolInfoTick(Symbol(),last_tick))
     {            
      if(OrderCalcMargin(ORDER_TYPE_BUY,Symbol(),lot,last_tick.ask,margin))
        {
     if(margin>AccountInfoDouble(ACCOUNT_MARGIN_FREE)){
      Alert("Not enough money in the account!");
      return(0);     
     }}
     }else{
      Print(GetLastError());
     }
//Контроль над спредом брокера
double _spread=
SymbolInfoInteger(Symbol(),SYMBOL_SPREAD)*MathPow(10,-SymbolInfoInteger(Symbol(),SYMBOL_DIGITS))/MathPow(10,-4); 
 if(_spread>spread){
 Alert("Слишком большой спред!");
 return(0);
 }
//Проверка ограничений на торговые операции по символу, установленные брокером
if((ENUM_SYMBOL_TRADE_MODE)SymbolInfoInteger(Symbol(),SYMBOL_TRADE_MODE)!=SYMBOL_TRADE_MODE_FULL){
Alert("Установлены ограничения на торговые операции");
return(0);
}
//Достаточно ли баров в истории для расчета советника
if(Bars(Symbol(), 0)<100)  
     {
      Alert("In the chart little bars, Expert will not work!!");
      return(0);
     } 
     
     return(1);    
}
