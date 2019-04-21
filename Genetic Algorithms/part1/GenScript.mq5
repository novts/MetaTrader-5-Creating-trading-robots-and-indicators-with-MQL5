//+------------------------------------------------------------------+
//|                                                    GenScript.mq5 |
//|                                            Copyright 2018, NOVTS |
//|                                                 http://novts.com |
//+------------------------------------------------------------------+
#property copyright "Copyright 2018, NOVTS"
#property link      "http://novts.com"
#property version   "1.00"
#include <MAMACDFitness.mqh>
#include <UGAlib.mqh>

double ReplicationPortion_E  = 100.0; //Доля Репликации.
double NMutationPortion_E    = 10.0;  //Доля Естественной мутации.
double ArtificialMutation_E  = 10.0;  //Доля Искусственной мутации.
double GenoMergingPortion_E  = 20.0;  //Доля Заимствования генов.
double CrossingOverPortion_E = 20.0;  //Доля Кроссинговера.
//---
double ReplicationOffset_E   = 0.5;   //Коэффициент смещения границ интервала
double NMutationProbability_E= 5.0;   //Вероятность мутации каждого гена в %

//--- inputs for main signal
input int                Signal_ThresholdOpen    =20;           // Signal threshold value to open [0...100]
input int                Signal_ThresholdClose   =20;           // Signal threshold value to close [0...100]
input double             Signal_PriceLevel       =0.0;          // Price level to execute a deal
input double             Signal_StopLevel        =50.0;         // Stop Loss level (in points)
input double             Signal_TakeLevel        =50.0;         // Take Profit level (in points)
input int                Signal_Expiration       =4;            // Expiration of pending orders (in bars)
input int                Signal_MA_PeriodMA      =12;           // Moving Average(12,0,...) Period of averaging
input int                Signal_MA_Shift         =0;            // Moving Average(12,0,...) Time shift
input ENUM_MA_METHOD     Signal_MA_Method        =MODE_SMA;     // Moving Average(12,0,...) Method of averaging
input ENUM_APPLIED_PRICE Signal_MA_Applied       =PRICE_CLOSE;  // Moving Average(12,0,...) Prices series
input double             Signal_MA_Weight        =1.0;          // Moving Average(12,0,...) Weight [0...1.0]
input int                Signal_MACD_PeriodFast  =12;           // MACD(12,24,9,PRICE_CLOSE) Period of fast EMA
input int                Signal_MACD_PeriodSlow  =24;           // MACD(12,24,9,PRICE_CLOSE) Period of slow EMA
input int                Signal_MACD_PeriodSignal=9;            // MACD(12,24,9,PRICE_CLOSE) Period of averaging of difference
input ENUM_APPLIED_PRICE Signal_MACD_Applied     =PRICE_CLOSE;  // MACD(12,24,9,PRICE_CLOSE) Prices series
input double             Signal_MACD_Weight      =1.0;          // MACD(12,24,9,PRICE_CLOSE) Weight [0...1.0]

//+------------------------------------------------------------------+
//| Script program start function                                    |
//+------------------------------------------------------------------+
void OnStart()
  {
//---
ChromosomeCount     = 10;    //Кол-во хромосом в колонии
GeneCount           = 2;     //Кол-во генов
Epoch               = 50;    //Кол-во эпох без улучшения
//---
RangeMinimum        = 0.0;  //Минимум диапазона поиска
RangeMaximum        = 1.0;   //Максимум диапазона поиска
Precision           = 0.1;//Требуемая точность
OptimizeMethod      = 2;     //Оптим.:1-Min,другое-Max
ArrayResize(Chromosome,GeneCount+1);
ArrayInitialize(Chromosome,0);   

 //Локальные переменные
  int time_start=(int)GetTickCount(),time_end=0;
  //----------------------------------------------------------------------

  //Запуск главной ф-ии UGA
  UGA
  (
  ReplicationPortion_E, //Доля Репликации.
  NMutationPortion_E,   //Доля Естественной мутации.
  ArtificialMutation_E, //Доля Искусственной мутации.
  GenoMergingPortion_E, //Доля Заимствования генов.
  CrossingOverPortion_E,//Доля Кроссинговера.
  //---
  ReplicationOffset_E,  //Коэффициент смещения границ интервала
  NMutationProbability_E//Вероятность мутации каждого гена в %
  );
  //----------------------------------
  time_end=(int)GetTickCount();
  //----------------------------------
  Print(time_end-time_start," мс - Время исполнения");
  //----------------------------------
  
  }
//+------------------------------------------------------------------+
