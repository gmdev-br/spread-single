//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
#property copyright "© GM, 2020, 2021, 2022, 2023"
#property description "Spread Single Main"
#property indicator_chart_window
#property indicator_buffers 79
#property indicator_plots   79

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
enum tipoSpread {
   Intraday,
   Diário,
   Semanal,
   Bisemanal,
   Mensal,
   Bimestral,
   Trimestral,
   Semestral,
   Anual,
   Bianual,
   Trienal,
   Quadrienal,
   Dinâmico
};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
input datetime                               DefaultInitialDate = "2022.9.1 9:00:00"; // Data inicial padrão
input tipoSpread                             inputTipoSpread = Dinâmico;
input string                                 inputAtivo1 = "";
input color                                  colorHigh = clrRed;         // Cor High
input color                                  colorClose = clrRed;         // Cor Close
input color                                  colorLow = clrRed;         // Cor Low
input double                                 desvioAtivo1 = 0.25;
input double                                 referencia1 = 0;
input double                                 offset1 = 0;
input int                                    espessura_linha = 2;              // Espessura da linha
input int                                    WaitMilliseconds = 5000;           // Timer (milliseconds) for recalculation

input bool                                   exibeCurva = true;
input bool                                   exibeCanalHigh = false;
input bool                                   exibeCanalClose = true;
input bool                                   exibeCanalLow = false;
input bool                                   debug = false;
input bool                                   autoCapitalLetters = true;
input double                                 percentual = 0.5; // Intervalo % dos níveis
input double                                 escalaMax = 0;
input double                                 escalaMin = 0;
input bool                                   showPrice = true;
input int                                    showAfter = 200;

ENUM_TIMEFRAMES tf = PERIOD_CURRENT;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double    bufferAtivoHigh[];
double    bufferAtivoClose[];
double    bufferAtivoLow[];
double    bufferShowPrice[];

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double regChannelBufferAtivoHigh[], regChannelBufferAtivoClose[], regChannelBufferAtivoLow[];

double regChannelAtivoHigh_1[], regChannelAtivoHigh_2[], regChannelAtivoHigh_3[], regChannelAtivoHigh_4[], regChannelAtivoHigh_5[], regChannelAtivoHigh_6[];
double regChannelAtivoHigh_7[], regChannelAtivoHigh_8[], regChannelAtivoHigh_9[], regChannelAtivoHigh_10[], regChannelAtivoHigh_11[], regChannelAtivoHigh_12[];
double regChannelAtivoHigh_13[], regChannelAtivoHigh_14[], regChannelAtivoHigh_15[], regChannelAtivoHigh_16[], regChannelAtivoHigh_17[], regChannelAtivoHigh_18[];
double regChannelAtivoHigh_19[], regChannelAtivoHigh_20[], regChannelAtivoHigh_21[], regChannelAtivoHigh_22[], regChannelAtivoHigh_23[], regChannelAtivoHigh_24[];

double regChannelAtivoClose_1[], regChannelAtivoClose_2[], regChannelAtivoClose_3[], regChannelAtivoClose_4[], regChannelAtivoClose_5[], regChannelAtivoClose_6[];
double regChannelAtivoClose_7[], regChannelAtivoClose_8[], regChannelAtivoClose_9[], regChannelAtivoClose_10[], regChannelAtivoClose_11[], regChannelAtivoClose_12[];
double regChannelAtivoClose_13[], regChannelAtivoClose_14[], regChannelAtivoClose_15[], regChannelAtivoClose_16[], regChannelAtivoClose_17[], regChannelAtivoClose_18[];
double regChannelAtivoClose_19[], regChannelAtivoClose_20[], regChannelAtivoClose_21[], regChannelAtivoClose_22[], regChannelAtivoClose_23[], regChannelAtivoClose_24[];

double regChannelAtivoLow_1[], regChannelAtivoLow_2[], regChannelAtivoLow_3[], regChannelAtivoLow_4[], regChannelAtivoLow_5[], regChannelAtivoLow_6[];
double regChannelAtivoLow_7[], regChannelAtivoLow_8[], regChannelAtivoLow_9[], regChannelAtivoLow_10[], regChannelAtivoLow_11[], regChannelAtivoLow_12[];
double regChannelAtivoLow_13[], regChannelAtivoLow_14[], regChannelAtivoLow_15[], regChannelAtivoLow_16[], regChannelAtivoLow_17[], regChannelAtivoLow_18[];
double regChannelAtivoLow_19[], regChannelAtivoLow_20[], regChannelAtivoLow_21[], regChannelAtivoLow_22[], regChannelAtivoLow_23[], regChannelAtivoLow_24[];

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double A, B, stdev;
datetime data_inicial;
int barFrom;

string ativo1;

long totalRates;
int rateCount;
color cor = clrDimGray;

//+------------------------------------------------------------------+
//| Custom indicator initialization function                         |
//+------------------------------------------------------------------+
int OnInit() {

   ativo1 = inputAtivo1;

   if (autoCapitalLetters) {
      StringToUpper(ativo1);
   }

   if (ativo1 == "")
      ativo1 = Symbol();

   ObjectDelete(0, "spread_from_line");

   for(int i = 0; i <= 79; i++) {
      PlotIndexSetInteger(i, PLOT_DRAW_TYPE, DRAW_LINE);
      PlotIndexSetDouble(i, PLOT_EMPTY_VALUE, 0.0);
      PlotIndexSetInteger(i, PLOT_SHOW_DATA, false);       //--- repeat for each plot
   }

//ChartSetInteger(0, CHART_SHIFT, 1);
//ChartSetDouble(0, CHART_SHIFT_SIZE, 10);

   PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_NONE);
   PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_NONE);
   PlotIndexSetInteger(2, PLOT_DRAW_TYPE, DRAW_NONE);
   PlotIndexSetInteger(3, PLOT_DRAW_TYPE, DRAW_NONE);

   if (showPrice && exibeCanalHigh) PlotIndexSetInteger(0, PLOT_DRAW_TYPE, DRAW_LINE);
   if (showPrice && exibeCanalClose) PlotIndexSetInteger(1, PLOT_DRAW_TYPE, DRAW_LINE);
   if (showPrice && exibeCanalLow) PlotIndexSetInteger(2, PLOT_DRAW_TYPE, DRAW_LINE);
   if (showPrice) PlotIndexSetInteger(3, PLOT_DRAW_TYPE, DRAW_LINE);

//PlotIndexSetInteger(58, PLOT_SHOW_DATA, true);

   PlotIndexSetDouble(0, PLOT_EMPTY_VALUE, 0.0);
   PlotIndexSetDouble(1, PLOT_EMPTY_VALUE, 0.0);
   PlotIndexSetDouble(2, PLOT_EMPTY_VALUE, 0.0);
   PlotIndexSetDouble(3, PLOT_EMPTY_VALUE, 0.0);

   SetIndexBuffer(0, bufferAtivoHigh, INDICATOR_DATA);
   SetIndexBuffer(1, bufferAtivoClose, INDICATOR_DATA);
   SetIndexBuffer(2, bufferAtivoLow, INDICATOR_DATA);
   SetIndexBuffer(3, bufferShowPrice, INDICATOR_DATA);

   PlotIndexSetInteger(0, PLOT_LINE_WIDTH, espessura_linha);
   PlotIndexSetInteger(1, PLOT_LINE_WIDTH, espessura_linha);
   PlotIndexSetInteger(2, PLOT_LINE_WIDTH, espessura_linha);
   PlotIndexSetInteger(3, PLOT_LINE_WIDTH, espessura_linha);

   PlotIndexSetInteger(0, PLOT_LINE_COLOR, 0, colorClose);
   PlotIndexSetInteger(1, PLOT_LINE_COLOR, 0, colorClose);
   PlotIndexSetInteger(2, PLOT_LINE_COLOR, 0, colorClose);
   PlotIndexSetInteger(3, PLOT_LINE_COLOR, 0, colorClose);

   PlotIndexSetInteger(4, PLOT_LINE_COLOR, 0, colorHigh);
   PlotIndexSetInteger(5, PLOT_LINE_COLOR, 0, colorClose);
   PlotIndexSetInteger(6, PLOT_LINE_COLOR, 0, colorLow);

   PlotIndexSetString(3, PLOT_LABEL, "showPrice");

   ArrayInitialize(bufferAtivoHigh, 0);
   ArrayInitialize(bufferAtivoClose, 0);
   ArrayInitialize(bufferAtivoLow, 0);
   ArrayInitialize(bufferShowPrice, 0);

   ArrayInitialize(regChannelBufferAtivoHigh, 0);
   ArrayInitialize(regChannelBufferAtivoClose, 0);
   ArrayInitialize(regChannelBufferAtivoLow, 0);

   ArrayInitialize(regChannelAtivoHigh_1, 0);
   ArrayInitialize(regChannelAtivoHigh_2, 0);
   ArrayInitialize(regChannelAtivoHigh_3, 0);
   ArrayInitialize(regChannelAtivoHigh_4, 0);
   ArrayInitialize(regChannelAtivoHigh_5, 0);
   ArrayInitialize(regChannelAtivoHigh_6, 0);
   ArrayInitialize(regChannelAtivoHigh_7, 0);
   ArrayInitialize(regChannelAtivoHigh_8, 0);
   ArrayInitialize(regChannelAtivoHigh_9, 0);
   ArrayInitialize(regChannelAtivoHigh_10, 0);
   ArrayInitialize(regChannelAtivoHigh_11, 0);
   ArrayInitialize(regChannelAtivoHigh_12, 0);
   ArrayInitialize(regChannelAtivoHigh_13, 0);
   ArrayInitialize(regChannelAtivoHigh_14, 0);
   ArrayInitialize(regChannelAtivoHigh_15, 0);
   ArrayInitialize(regChannelAtivoHigh_16, 0);
   ArrayInitialize(regChannelAtivoHigh_17, 0);
   ArrayInitialize(regChannelAtivoHigh_18, 0);
   ArrayInitialize(regChannelAtivoHigh_19, 0);
   ArrayInitialize(regChannelAtivoHigh_20, 0);
   ArrayInitialize(regChannelAtivoHigh_21, 0);
   ArrayInitialize(regChannelAtivoHigh_22, 0);
   ArrayInitialize(regChannelAtivoHigh_23, 0);
   ArrayInitialize(regChannelAtivoHigh_24, 0);

   ArrayInitialize(regChannelAtivoClose_1, 0);
   ArrayInitialize(regChannelAtivoClose_2, 0);
   ArrayInitialize(regChannelAtivoClose_3, 0);
   ArrayInitialize(regChannelAtivoClose_4, 0);
   ArrayInitialize(regChannelAtivoClose_5, 0);
   ArrayInitialize(regChannelAtivoClose_6, 0);
   ArrayInitialize(regChannelAtivoClose_7, 0);
   ArrayInitialize(regChannelAtivoClose_8, 0);
   ArrayInitialize(regChannelAtivoClose_9, 0);
   ArrayInitialize(regChannelAtivoClose_10, 0);
   ArrayInitialize(regChannelAtivoClose_11, 0);
   ArrayInitialize(regChannelAtivoClose_12, 0);
   ArrayInitialize(regChannelAtivoClose_13, 0);
   ArrayInitialize(regChannelAtivoClose_14, 0);
   ArrayInitialize(regChannelAtivoClose_15, 0);
   ArrayInitialize(regChannelAtivoClose_16, 0);
   ArrayInitialize(regChannelAtivoClose_17, 0);
   ArrayInitialize(regChannelAtivoClose_18, 0);
   ArrayInitialize(regChannelAtivoClose_19, 0);
   ArrayInitialize(regChannelAtivoClose_20, 0);
   ArrayInitialize(regChannelAtivoClose_21, 0);
   ArrayInitialize(regChannelAtivoClose_22, 0);
   ArrayInitialize(regChannelAtivoClose_23, 0);
   ArrayInitialize(regChannelAtivoClose_24, 0);

   ArrayInitialize(regChannelAtivoLow_1, 0);
   ArrayInitialize(regChannelAtivoLow_2, 0);
   ArrayInitialize(regChannelAtivoLow_3, 0);
   ArrayInitialize(regChannelAtivoLow_4, 0);
   ArrayInitialize(regChannelAtivoLow_5, 0);
   ArrayInitialize(regChannelAtivoLow_6, 0);
   ArrayInitialize(regChannelAtivoLow_7, 0);
   ArrayInitialize(regChannelAtivoLow_8, 0);
   ArrayInitialize(regChannelAtivoLow_9, 0);
   ArrayInitialize(regChannelAtivoLow_10, 0);
   ArrayInitialize(regChannelAtivoLow_11, 0);
   ArrayInitialize(regChannelAtivoLow_12, 0);
   ArrayInitialize(regChannelAtivoLow_13, 0);
   ArrayInitialize(regChannelAtivoLow_14, 0);
   ArrayInitialize(regChannelAtivoLow_15, 0);
   ArrayInitialize(regChannelAtivoLow_16, 0);
   ArrayInitialize(regChannelAtivoLow_17, 0);
   ArrayInitialize(regChannelAtivoLow_18, 0);
   ArrayInitialize(regChannelAtivoLow_19, 0);
   ArrayInitialize(regChannelAtivoLow_20, 0);
   ArrayInitialize(regChannelAtivoLow_21, 0);
   ArrayInitialize(regChannelAtivoLow_22, 0);
   ArrayInitialize(regChannelAtivoLow_23, 0);
   ArrayInitialize(regChannelAtivoLow_24, 0);

   SetIndexBuffer(4, regChannelBufferAtivoHigh, INDICATOR_DATA);
   SetIndexBuffer(5, regChannelBufferAtivoClose, INDICATOR_DATA);
   SetIndexBuffer(6, regChannelBufferAtivoLow, INDICATOR_DATA);

   int nIndHigh = 7;
   SetIndexBuffer(nIndHigh, regChannelAtivoHigh_1, INDICATOR_DATA);
   SetIndexBuffer(nIndHigh + 1, regChannelAtivoHigh_2, INDICATOR_DATA);
   SetIndexBuffer(nIndHigh + 2, regChannelAtivoHigh_3, INDICATOR_DATA);
   SetIndexBuffer(nIndHigh + 3, regChannelAtivoHigh_4, INDICATOR_DATA);
   SetIndexBuffer(nIndHigh + 4, regChannelAtivoHigh_5, INDICATOR_DATA);
   SetIndexBuffer(nIndHigh + 5, regChannelAtivoHigh_6, INDICATOR_DATA);
   SetIndexBuffer(nIndHigh + 6, regChannelAtivoHigh_7, INDICATOR_DATA);
   SetIndexBuffer(nIndHigh + 7, regChannelAtivoHigh_8, INDICATOR_DATA);
   SetIndexBuffer(nIndHigh + 8, regChannelAtivoHigh_9, INDICATOR_DATA);
   SetIndexBuffer(nIndHigh + 9, regChannelAtivoHigh_10, INDICATOR_DATA);
   SetIndexBuffer(nIndHigh + 10, regChannelAtivoHigh_11, INDICATOR_DATA);
   SetIndexBuffer(nIndHigh + 11, regChannelAtivoHigh_12, INDICATOR_DATA);
   SetIndexBuffer(nIndHigh + 12, regChannelAtivoHigh_13, INDICATOR_DATA);
   SetIndexBuffer(nIndHigh + 13, regChannelAtivoHigh_14, INDICATOR_DATA);
   SetIndexBuffer(nIndHigh + 14, regChannelAtivoHigh_15, INDICATOR_DATA);
   SetIndexBuffer(nIndHigh + 15, regChannelAtivoHigh_16, INDICATOR_DATA);
   SetIndexBuffer(nIndHigh + 16, regChannelAtivoHigh_17, INDICATOR_DATA);
   SetIndexBuffer(nIndHigh + 17, regChannelAtivoHigh_18, INDICATOR_DATA);
   SetIndexBuffer(nIndHigh + 18, regChannelAtivoHigh_19, INDICATOR_DATA);
   SetIndexBuffer(nIndHigh + 19, regChannelAtivoHigh_20, INDICATOR_DATA);
   SetIndexBuffer(nIndHigh + 20, regChannelAtivoHigh_21, INDICATOR_DATA);
   SetIndexBuffer(nIndHigh + 21, regChannelAtivoHigh_22, INDICATOR_DATA);
   SetIndexBuffer(nIndHigh + 22, regChannelAtivoHigh_23, INDICATOR_DATA);
   SetIndexBuffer(nIndHigh + 23, regChannelAtivoHigh_24, INDICATOR_DATA);

   double contador = nIndHigh + 11;
   for(int i = nIndHigh; i <= nIndHigh + 11; i++) {
      PlotIndexSetString(i, PLOT_LABEL, "Spread +" + (contador * desvioAtivo1 + (offset1 * desvioAtivo1)));
      contador--;
   }

   int nIndClose = nIndHigh + 24;
   SetIndexBuffer(nIndClose, regChannelAtivoClose_1, INDICATOR_DATA);
   SetIndexBuffer(nIndClose + 1, regChannelAtivoClose_2, INDICATOR_DATA);
   SetIndexBuffer(nIndClose + 2, regChannelAtivoClose_3, INDICATOR_DATA);
   SetIndexBuffer(nIndClose + 3, regChannelAtivoClose_4, INDICATOR_DATA);
   SetIndexBuffer(nIndClose + 4, regChannelAtivoClose_5, INDICATOR_DATA);
   SetIndexBuffer(nIndClose + 5, regChannelAtivoClose_6, INDICATOR_DATA);
   SetIndexBuffer(nIndClose + 6, regChannelAtivoClose_7, INDICATOR_DATA);
   SetIndexBuffer(nIndClose + 7, regChannelAtivoClose_8, INDICATOR_DATA);
   SetIndexBuffer(nIndClose + 8, regChannelAtivoClose_9, INDICATOR_DATA);
   SetIndexBuffer(nIndClose + 9, regChannelAtivoClose_10, INDICATOR_DATA);
   SetIndexBuffer(nIndClose + 10, regChannelAtivoClose_11, INDICATOR_DATA);
   SetIndexBuffer(nIndClose + 11, regChannelAtivoClose_12, INDICATOR_DATA);
   SetIndexBuffer(nIndClose + 12, regChannelAtivoClose_13, INDICATOR_DATA);
   SetIndexBuffer(nIndClose + 13, regChannelAtivoClose_14, INDICATOR_DATA);
   SetIndexBuffer(nIndClose + 14, regChannelAtivoClose_15, INDICATOR_DATA);
   SetIndexBuffer(nIndClose + 15, regChannelAtivoClose_16, INDICATOR_DATA);
   SetIndexBuffer(nIndClose + 16, regChannelAtivoClose_17, INDICATOR_DATA);
   SetIndexBuffer(nIndClose + 17, regChannelAtivoClose_18, INDICATOR_DATA);
   SetIndexBuffer(nIndClose + 18, regChannelAtivoClose_19, INDICATOR_DATA);
   SetIndexBuffer(nIndClose + 19, regChannelAtivoClose_20, INDICATOR_DATA);
   SetIndexBuffer(nIndClose + 20, regChannelAtivoClose_21, INDICATOR_DATA);
   SetIndexBuffer(nIndClose + 21, regChannelAtivoClose_22, INDICATOR_DATA);
   SetIndexBuffer(nIndClose + 22, regChannelAtivoClose_23, INDICATOR_DATA);
   SetIndexBuffer(nIndClose + 23, regChannelAtivoClose_24, INDICATOR_DATA);

   contador = 12;
   for(int i = nIndClose; i <= nIndClose + 11; i++) {
      PlotIndexSetString(i, PLOT_LABEL, "Spread +" + (contador * desvioAtivo1 + (offset1 * desvioAtivo1)));
      contador--;
   }

   contador = 1;
   for(int i = nIndClose + 12; i <= nIndClose + 23; i++) {
      PlotIndexSetString(i, PLOT_LABEL, "Spread -" + (contador * desvioAtivo1 + (offset1 * desvioAtivo1)));
      contador++;
   }

   int nIndLow = nIndHigh + 48;
   SetIndexBuffer(nIndLow, regChannelAtivoLow_1, INDICATOR_DATA);
   SetIndexBuffer(nIndLow + 1, regChannelAtivoLow_2, INDICATOR_DATA);
   SetIndexBuffer(nIndLow + 2, regChannelAtivoLow_3, INDICATOR_DATA);
   SetIndexBuffer(nIndLow + 3, regChannelAtivoLow_4, INDICATOR_DATA);
   SetIndexBuffer(nIndLow + 4, regChannelAtivoLow_5, INDICATOR_DATA);
   SetIndexBuffer(nIndLow + 5, regChannelAtivoLow_6, INDICATOR_DATA);
   SetIndexBuffer(nIndLow + 6, regChannelAtivoLow_7, INDICATOR_DATA);
   SetIndexBuffer(nIndLow + 7, regChannelAtivoLow_8, INDICATOR_DATA);
   SetIndexBuffer(nIndLow + 8, regChannelAtivoLow_9, INDICATOR_DATA);
   SetIndexBuffer(nIndLow + 9, regChannelAtivoLow_10, INDICATOR_DATA);
   SetIndexBuffer(nIndLow + 10, regChannelAtivoLow_11, INDICATOR_DATA);
   SetIndexBuffer(nIndLow + 11, regChannelAtivoLow_12, INDICATOR_DATA);
   SetIndexBuffer(nIndLow + 12, regChannelAtivoLow_13, INDICATOR_DATA);
   SetIndexBuffer(nIndLow + 13, regChannelAtivoLow_14, INDICATOR_DATA);
   SetIndexBuffer(nIndLow + 14, regChannelAtivoLow_15, INDICATOR_DATA);
   SetIndexBuffer(nIndLow + 15, regChannelAtivoLow_16, INDICATOR_DATA);
   SetIndexBuffer(nIndLow + 16, regChannelAtivoLow_17, INDICATOR_DATA);
   SetIndexBuffer(nIndLow + 17, regChannelAtivoLow_18, INDICATOR_DATA);
   SetIndexBuffer(nIndLow + 18, regChannelAtivoLow_19, INDICATOR_DATA);
   SetIndexBuffer(nIndLow + 19, regChannelAtivoLow_20, INDICATOR_DATA);
   SetIndexBuffer(nIndLow + 20, regChannelAtivoLow_21, INDICATOR_DATA);
   SetIndexBuffer(nIndLow + 21, regChannelAtivoLow_22, INDICATOR_DATA);
   SetIndexBuffer(nIndLow + 22, regChannelAtivoLow_23, INDICATOR_DATA);
   SetIndexBuffer(nIndLow + 23, regChannelAtivoLow_24, INDICATOR_DATA);

   ArraySetAsSeries(bufferAtivoHigh, true);
   ArraySetAsSeries(bufferAtivoClose, true);
   ArraySetAsSeries(bufferAtivoLow, true);
   ArraySetAsSeries(bufferShowPrice, true);

   ArraySetAsSeries(regChannelBufferAtivoHigh, true);
   ArraySetAsSeries(regChannelBufferAtivoClose, true);
   ArraySetAsSeries(regChannelBufferAtivoLow, true);

   ArraySetAsSeries(regChannelAtivoHigh_1, true);
   ArraySetAsSeries(regChannelAtivoHigh_2, true);
   ArraySetAsSeries(regChannelAtivoHigh_3, true);
   ArraySetAsSeries(regChannelAtivoHigh_4, true);
   ArraySetAsSeries(regChannelAtivoHigh_5, true);
   ArraySetAsSeries(regChannelAtivoHigh_6, true);
   ArraySetAsSeries(regChannelAtivoHigh_7, true);
   ArraySetAsSeries(regChannelAtivoHigh_8, true);
   ArraySetAsSeries(regChannelAtivoHigh_9, true);
   ArraySetAsSeries(regChannelAtivoHigh_10, true);
   ArraySetAsSeries(regChannelAtivoHigh_11, true);
   ArraySetAsSeries(regChannelAtivoHigh_12, true);
   ArraySetAsSeries(regChannelAtivoHigh_13, true);
   ArraySetAsSeries(regChannelAtivoHigh_14, true);
   ArraySetAsSeries(regChannelAtivoHigh_15, true);
   ArraySetAsSeries(regChannelAtivoHigh_16, true);
   ArraySetAsSeries(regChannelAtivoHigh_17, true);
   ArraySetAsSeries(regChannelAtivoHigh_18, true);
   ArraySetAsSeries(regChannelAtivoHigh_19, true);
   ArraySetAsSeries(regChannelAtivoHigh_20, true);
   ArraySetAsSeries(regChannelAtivoHigh_21, true);
   ArraySetAsSeries(regChannelAtivoHigh_22, true);
   ArraySetAsSeries(regChannelAtivoHigh_23, true);
   ArraySetAsSeries(regChannelAtivoHigh_24, true);

   ArraySetAsSeries(regChannelAtivoClose_1, true);
   ArraySetAsSeries(regChannelAtivoClose_2, true);
   ArraySetAsSeries(regChannelAtivoClose_3, true);
   ArraySetAsSeries(regChannelAtivoClose_4, true);
   ArraySetAsSeries(regChannelAtivoClose_5, true);
   ArraySetAsSeries(regChannelAtivoClose_6, true);
   ArraySetAsSeries(regChannelAtivoClose_7, true);
   ArraySetAsSeries(regChannelAtivoClose_8, true);
   ArraySetAsSeries(regChannelAtivoClose_9, true);
   ArraySetAsSeries(regChannelAtivoClose_10, true);
   ArraySetAsSeries(regChannelAtivoClose_11, true);
   ArraySetAsSeries(regChannelAtivoClose_12, true);
   ArraySetAsSeries(regChannelAtivoClose_13, true);
   ArraySetAsSeries(regChannelAtivoClose_14, true);
   ArraySetAsSeries(regChannelAtivoClose_15, true);
   ArraySetAsSeries(regChannelAtivoClose_16, true);
   ArraySetAsSeries(regChannelAtivoClose_17, true);
   ArraySetAsSeries(regChannelAtivoClose_18, true);
   ArraySetAsSeries(regChannelAtivoClose_19, true);
   ArraySetAsSeries(regChannelAtivoClose_20, true);
   ArraySetAsSeries(regChannelAtivoClose_21, true);
   ArraySetAsSeries(regChannelAtivoClose_22, true);
   ArraySetAsSeries(regChannelAtivoClose_23, true);
   ArraySetAsSeries(regChannelAtivoClose_24, true);

   ArraySetAsSeries(regChannelAtivoLow_1, true);
   ArraySetAsSeries(regChannelAtivoLow_2, true);
   ArraySetAsSeries(regChannelAtivoLow_3, true);
   ArraySetAsSeries(regChannelAtivoLow_4, true);
   ArraySetAsSeries(regChannelAtivoLow_5, true);
   ArraySetAsSeries(regChannelAtivoLow_6, true);
   ArraySetAsSeries(regChannelAtivoLow_7, true);
   ArraySetAsSeries(regChannelAtivoLow_8, true);
   ArraySetAsSeries(regChannelAtivoLow_9, true);
   ArraySetAsSeries(regChannelAtivoLow_10, true);
   ArraySetAsSeries(regChannelAtivoLow_11, true);
   ArraySetAsSeries(regChannelAtivoLow_12, true);
   ArraySetAsSeries(regChannelAtivoLow_13, true);
   ArraySetAsSeries(regChannelAtivoLow_14, true);
   ArraySetAsSeries(regChannelAtivoLow_15, true);
   ArraySetAsSeries(regChannelAtivoLow_16, true);
   ArraySetAsSeries(regChannelAtivoLow_17, true);
   ArraySetAsSeries(regChannelAtivoLow_18, true);
   ArraySetAsSeries(regChannelAtivoLow_19, true);
   ArraySetAsSeries(regChannelAtivoLow_20, true);
   ArraySetAsSeries(regChannelAtivoLow_21, true);
   ArraySetAsSeries(regChannelAtivoLow_22, true);
   ArraySetAsSeries(regChannelAtivoLow_23, true);
   ArraySetAsSeries(regChannelAtivoLow_24, true);

   cor = clrDimGray;
   PlotIndexSetInteger(nIndHigh, PLOT_LINE_COLOR, 0, colorHigh);
   PlotIndexSetInteger(nIndHigh + 1, PLOT_LINE_COLOR, 0, colorHigh);
   PlotIndexSetInteger(nIndHigh + 2, PLOT_LINE_COLOR, 0, colorHigh);
   PlotIndexSetInteger(nIndHigh + 3, PLOT_LINE_COLOR, 0, colorHigh);
   PlotIndexSetInteger(nIndHigh + 4, PLOT_LINE_COLOR, 0, colorHigh);
   PlotIndexSetInteger(nIndHigh + 5, PLOT_LINE_COLOR, 0, colorHigh);
   PlotIndexSetInteger(nIndHigh + 6, PLOT_LINE_COLOR, 0, colorHigh);
   PlotIndexSetInteger(nIndHigh + 7, PLOT_LINE_COLOR, 0, colorHigh);
   PlotIndexSetInteger(nIndHigh + 8, PLOT_LINE_COLOR, 0, colorHigh);
   PlotIndexSetInteger(nIndHigh + 9, PLOT_LINE_COLOR, 0, colorHigh);
   PlotIndexSetInteger(nIndHigh + 10, PLOT_LINE_COLOR, 0, colorHigh);
   PlotIndexSetInteger(nIndHigh + 11, PLOT_LINE_COLOR, 0, colorHigh);
   PlotIndexSetInteger(nIndHigh + 12, PLOT_LINE_COLOR, 0, colorHigh);
   PlotIndexSetInteger(nIndHigh + 13, PLOT_LINE_COLOR, 0, colorHigh);
   PlotIndexSetInteger(nIndHigh + 14, PLOT_LINE_COLOR, 0, colorHigh);
   PlotIndexSetInteger(nIndHigh + 15, PLOT_LINE_COLOR, 0, colorHigh);
   PlotIndexSetInteger(nIndHigh + 16, PLOT_LINE_COLOR, 0, colorHigh);
   PlotIndexSetInteger(nIndHigh + 17, PLOT_LINE_COLOR, 0, colorHigh);
   PlotIndexSetInteger(nIndHigh + 18, PLOT_LINE_COLOR, 0, colorHigh);
   PlotIndexSetInteger(nIndHigh + 19, PLOT_LINE_COLOR, 0, colorHigh);
   PlotIndexSetInteger(nIndHigh + 20, PLOT_LINE_COLOR, 0, colorHigh);
   PlotIndexSetInteger(nIndHigh + 21, PLOT_LINE_COLOR, 0, colorHigh);
   PlotIndexSetInteger(nIndHigh + 22, PLOT_LINE_COLOR, 0, colorHigh);
   PlotIndexSetInteger(nIndHigh + 23, PLOT_LINE_COLOR, 0, colorHigh);
   PlotIndexSetInteger(nIndHigh + 24, PLOT_LINE_COLOR, 0, colorHigh);

   PlotIndexSetInteger(nIndClose, PLOT_LINE_COLOR, 0, colorClose);
   PlotIndexSetInteger(nIndClose + 1, PLOT_LINE_COLOR, 0, colorClose);
   PlotIndexSetInteger(nIndClose + 2, PLOT_LINE_COLOR, 0, colorClose);
   PlotIndexSetInteger(nIndClose + 3, PLOT_LINE_COLOR, 0, colorClose);
   PlotIndexSetInteger(nIndClose + 4, PLOT_LINE_COLOR, 0, colorClose);
   PlotIndexSetInteger(nIndClose + 5, PLOT_LINE_COLOR, 0, colorClose);
   PlotIndexSetInteger(nIndClose + 6, PLOT_LINE_COLOR, 0, colorClose);
   PlotIndexSetInteger(nIndClose + 7, PLOT_LINE_COLOR, 0, colorClose);
   PlotIndexSetInteger(nIndClose + 8, PLOT_LINE_COLOR, 0, colorClose);
   PlotIndexSetInteger(nIndClose + 9, PLOT_LINE_COLOR, 0, colorClose);
   PlotIndexSetInteger(nIndClose + 10, PLOT_LINE_COLOR, 0, colorClose);
   PlotIndexSetInteger(nIndClose + 11, PLOT_LINE_COLOR, 0, colorClose);
   PlotIndexSetInteger(nIndClose + 12, PLOT_LINE_COLOR, 0, colorClose);
   PlotIndexSetInteger(nIndClose + 13, PLOT_LINE_COLOR, 0, colorClose);
   PlotIndexSetInteger(nIndClose + 14, PLOT_LINE_COLOR, 0, colorClose);
   PlotIndexSetInteger(nIndClose + 15, PLOT_LINE_COLOR, 0, colorClose);
   PlotIndexSetInteger(nIndClose + 16, PLOT_LINE_COLOR, 0, colorClose);
   PlotIndexSetInteger(nIndClose + 17, PLOT_LINE_COLOR, 0, colorClose);
   PlotIndexSetInteger(nIndClose + 18, PLOT_LINE_COLOR, 0, colorClose);
   PlotIndexSetInteger(nIndClose + 19, PLOT_LINE_COLOR, 0, colorClose);
   PlotIndexSetInteger(nIndClose + 20, PLOT_LINE_COLOR, 0, colorClose);
   PlotIndexSetInteger(nIndClose + 21, PLOT_LINE_COLOR, 0, colorClose);
   PlotIndexSetInteger(nIndClose + 22, PLOT_LINE_COLOR, 0, colorClose);
   PlotIndexSetInteger(nIndClose + 23, PLOT_LINE_COLOR, 0, colorClose);
   PlotIndexSetInteger(nIndClose + 24, PLOT_LINE_COLOR, 0, colorClose);

   PlotIndexSetInteger(nIndLow, PLOT_LINE_COLOR, 0, colorLow);
   PlotIndexSetInteger(nIndLow + 1, PLOT_LINE_COLOR, 0, colorLow);
   PlotIndexSetInteger(nIndLow + 2, PLOT_LINE_COLOR, 0, colorLow);
   PlotIndexSetInteger(nIndLow + 3, PLOT_LINE_COLOR, 0, colorLow);
   PlotIndexSetInteger(nIndLow + 4, PLOT_LINE_COLOR, 0, colorLow);
   PlotIndexSetInteger(nIndLow + 5, PLOT_LINE_COLOR, 0, colorLow);
   PlotIndexSetInteger(nIndLow + 6, PLOT_LINE_COLOR, 0, colorLow);
   PlotIndexSetInteger(nIndLow + 7, PLOT_LINE_COLOR, 0, colorLow);
   PlotIndexSetInteger(nIndLow + 8, PLOT_LINE_COLOR, 0, colorLow);
   PlotIndexSetInteger(nIndLow + 9, PLOT_LINE_COLOR, 0, colorLow);
   PlotIndexSetInteger(nIndLow + 10, PLOT_LINE_COLOR, 0, colorLow);
   PlotIndexSetInteger(nIndLow + 11, PLOT_LINE_COLOR, 0, colorLow);
   PlotIndexSetInteger(nIndLow + 12, PLOT_LINE_COLOR, 0, colorLow);
   PlotIndexSetInteger(nIndLow + 13, PLOT_LINE_COLOR, 0, colorLow);
   PlotIndexSetInteger(nIndLow + 14, PLOT_LINE_COLOR, 0, colorLow);
   PlotIndexSetInteger(nIndLow + 15, PLOT_LINE_COLOR, 0, colorLow);
   PlotIndexSetInteger(nIndLow + 16, PLOT_LINE_COLOR, 0, colorLow);
   PlotIndexSetInteger(nIndLow + 17, PLOT_LINE_COLOR, 0, colorLow);
   PlotIndexSetInteger(nIndLow + 18, PLOT_LINE_COLOR, 0, colorLow);
   PlotIndexSetInteger(nIndLow + 19, PLOT_LINE_COLOR, 0, colorLow);
   PlotIndexSetInteger(nIndLow + 20, PLOT_LINE_COLOR, 0, colorLow);
   PlotIndexSetInteger(nIndLow + 21, PLOT_LINE_COLOR, 0, colorLow);
   PlotIndexSetInteger(nIndLow + 22, PLOT_LINE_COLOR, 0, colorLow);
   PlotIndexSetInteger(nIndLow + 23, PLOT_LINE_COLOR, 0, colorLow);
   PlotIndexSetInteger(nIndLow + 24, PLOT_LINE_COLOR, 0, colorLow);

   PlotIndexSetInteger(4, PLOT_LINE_WIDTH, espessura_linha + 1);
   PlotIndexSetInteger(5, PLOT_LINE_WIDTH, espessura_linha + 1);
   PlotIndexSetInteger(6, PLOT_LINE_WIDTH, espessura_linha + 1);

   for(int i = 7; i <= 79; i++) {
      PlotIndexSetInteger(i, PLOT_LINE_STYLE, STYLE_DOT);
      PlotIndexSetInteger(i, PLOT_LINE_WIDTH, espessura_linha);
   }

   data_inicial = DefaultInitialDate;

   MqlDateTime time;
   TimeToStruct(TimeCurrent(), time);
   int anoAtual = time.year;
   int anoAlvo;
   datetime dataAlvo;
   time.mon = 1;
   time.day = 1;
   time.hour = 0;
   time.min = 0;
   time.sec = 0;

   if (inputTipoSpread == Intraday) {
      data_inicial = iTime(NULL, tf, 0);
   } else if (inputTipoSpread == Diário) {
      data_inicial = iTime(NULL, PERIOD_D1, 0);
   } else if (inputTipoSpread == Semanal) {
      data_inicial = iTime(NULL, PERIOD_W1, 0);
   } else if (inputTipoSpread == Bisemanal) {
      data_inicial = iTime(NULL, PERIOD_W1, 1);
   } else if (inputTipoSpread == Mensal) {
      data_inicial = iTime(NULL, PERIOD_MN1, 0);
   } else if (inputTipoSpread == Bimestral) {
      data_inicial = iTime(NULL, PERIOD_MN1, 1);
   } else if (inputTipoSpread == Trimestral) {
      data_inicial = iTime(NULL, PERIOD_MN1, 2);
   } else if (inputTipoSpread == Semestral) {
      data_inicial = iTime(NULL, PERIOD_MN1, 5);
   } else if (inputTipoSpread == Anual) {
      time.year = anoAtual;
      data_inicial = dataAlvo;
   } else if (inputTipoSpread == Bianual) {
      anoAlvo = anoAtual - 1;
      time.year = anoAlvo;
      dataAlvo = StructToTime(time);
      data_inicial = dataAlvo;
   } else if (inputTipoSpread == Trienal) {
      anoAlvo = anoAtual - 2;
      time.year = anoAlvo;
      dataAlvo = StructToTime(time);
      data_inicial = dataAlvo;
   } else if (inputTipoSpread == Quadrienal) {
      anoAlvo = anoAtual - 3;
      time.year = anoAlvo;
      dataAlvo = StructToTime(time);
      data_inicial = dataAlvo;
   } else if (inputTipoSpread == Dinâmico) {
      data_inicial = DefaultInitialDate;
   }

   barFrom = iBarShift(NULL, tf, data_inicial);

   if (inputTipoSpread == Dinâmico) {
      DrawVLine("spread_from_line", DefaultInitialDate, clrLime, 1, STYLE_DOT, false, true, true, 500);
   } else {
      ObjectDelete(1, "spread_from_line");
   }

   IndicatorSetInteger(INDICATOR_DIGITS, 2);
   IndicatorSetString(INDICATOR_SHORTNAME, "Spread");

   _lastOK = false;
   _updateTimer = new MillisecondTimer(WaitMilliseconds, false);
   EventSetMillisecondTimer(WaitMilliseconds);

   return(INIT_SUCCEEDED);

}

//+------------------------------------------------------------------+
//| Relative Strength Index                                          |
//+------------------------------------------------------------------+
int OnCalculate(const int rates_total, const int prev_calculated, const int begin, const double &price[]) {
   return (1);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool Update() {

   if (inputTipoSpread == Dinâmico) {
      data_inicial = ObjectGetInteger(0, "spread_from_line", OBJPROP_TIME);
      barFrom = iBarShift(NULL, tf, data_inicial) + 2;
   }

   totalRates = SeriesInfoInteger(_Symbol, tf, SERIES_BARS_COUNT);
   if (totalRates >= barFrom)
      totalRates = barFrom;

   int lastIndex = totalRates - 1;

   if (lastIndex <= 0)
      return false;

   if (ArraySize(bufferShowPrice) <= 0)
      return false;

   double priceHigh, priceClose, priceLow;
   double high1, close1, low1;
   datetime ontem, atual;

   ArrayInitialize(bufferAtivoHigh, 0);
   ArrayInitialize(bufferAtivoClose, 0);
   ArrayInitialize(bufferAtivoLow, 0);
   ArrayInitialize(bufferShowPrice, 0);

   for(int i = 0; i <= lastIndex - 1; i++) {

      ontem = StringToTime(TimeToString(iTime(ativo1, tf, i)  - PeriodSeconds(PERIOD_D1), TIME_DATE));
      atual = iTime(ativo1, tf, i);
      int barOntem = iBarShift(ativo1, tf, ontem);

      if (ativo1 != "") {
         if (referencia1 <= 0) {
            if (inputTipoSpread == Intraday)
               high1 = iHigh(ativo1, PERIOD_D1, iBarShift(ativo1, PERIOD_D1, ontem));
            else
               high1 = iHigh(ativo1, tf, barFrom);
         } else {
            high1 = referencia1;
         }

         priceHigh = iHigh(ativo1, tf, iBarShift(ativo1, tf, atual));
      }

      if (ativo1 != "" && high1 > 0) {
         if (priceHigh >= high1) {
            if (showPrice) {
               bufferAtivoHigh[i] = (priceHigh / high1 - 1) * 100;
               bufferShowPrice[i] = high1 * (1 + (priceHigh / high1 - 1));
            } else {
               bufferAtivoHigh[i] = (priceHigh / high1 - 1) * 100;
            }
         } else {
            if (showPrice) {
               bufferAtivoHigh[i] = (1 - priceHigh / high1) * -100;
               bufferShowPrice[i] = high1 * (1 - (1 - priceHigh / close1));
            } else {
               bufferAtivoHigh[i] = (1 - priceHigh / high1) * -100;
            }
         }
      } else {
         bufferAtivoHigh[i] = 0;
      }

      if (ativo1 != "") {
         if (referencia1 <= 0) {
            if (inputTipoSpread == Intraday)
               close1 = iClose(ativo1, PERIOD_D1, iBarShift(ativo1, PERIOD_D1, ontem));
            else
               close1 = iClose(ativo1, tf, barFrom);
         } else {
            close1 = referencia1;
         }

         priceClose = iClose(ativo1, tf, iBarShift(ativo1, tf, atual));
      }

      if (ativo1 != "" && close1 > 0) {
         if (priceClose >= close1) {
            if (showPrice) {
               bufferAtivoClose[i] = (priceClose / close1 - 1) * 100;
               bufferShowPrice[i] = close1 * (1 + (priceClose / close1 - 1));
            } else {
               bufferAtivoClose[i] = (priceClose / close1 - 1) * 100;
            }
         } else {
            if (showPrice) {
               bufferAtivoClose[i] = (1 - priceClose / close1) * -100;
               bufferShowPrice[i] = close1 * (1 - (1 - priceClose / close1));
            } else {
               bufferAtivoClose[i] = (1 - priceClose / close1) * -100;
            }
         }
      } else {
         bufferAtivoClose[i] = 0;
         bufferShowPrice[i] = 0;
      }

      if (ativo1 != "") {
         if (referencia1 <= 0) {
            if (inputTipoSpread == Intraday)
               low1 = iLow(ativo1, PERIOD_D1, iBarShift(ativo1, PERIOD_D1, ontem));
            else
               low1 = iLow(ativo1, tf, barFrom);
         } else {
            low1 = referencia1;
         }

         priceLow = iLow(ativo1, tf, iBarShift(ativo1, tf, atual));
      }

      if (ativo1 != "" && low1 > 0) {
         if (priceLow >= low1) {
            if (showPrice) {
               bufferAtivoLow[i] = (priceLow / low1 - 1) * 100;
            } else {
               bufferAtivoLow[i] = (priceLow / low1 - 1) * 100;
            }
         } else {
            if (showPrice) {
               bufferAtivoLow[i] = (1 - priceLow / low1) * -100;
            } else {
               bufferAtivoLow[i] = (1 - priceLow / low1) * -100;
            }
         }
      } else {
         bufferAtivoLow[i] = 0;
      }

      double tempArray[2];
      tempArray[0] = bufferAtivoHigh[i];
      tempArray[1] = bufferAtivoClose[i] + bufferAtivoLow[i];
   }

   for(int n = 0; n < ArraySize(regChannelBufferAtivoClose) - 1; n++) {
      regChannelBufferAtivoHigh[n] = 0.0;
      regChannelBufferAtivoClose[n] = 0.0;
      regChannelBufferAtivoLow[n] = 0.0;
      bufferShowPrice[n] = 0.0;

      regChannelAtivoHigh_1[n] = 0.0;
      regChannelAtivoHigh_2[n] = 0.0;
      regChannelAtivoHigh_3[n] = 0.0;
      regChannelAtivoHigh_4[n] = 0.0;
      regChannelAtivoHigh_5[n] = 0.0;
      regChannelAtivoHigh_6[n] = 0.0;
      regChannelAtivoHigh_7[n] = 0.0;
      regChannelAtivoHigh_8[n] = 0.0;
      regChannelAtivoHigh_9[n] = 0.0;
      regChannelAtivoHigh_10[n] = 0.0;
      regChannelAtivoHigh_11[n] = 0.0;
      regChannelAtivoHigh_12[n] = 0.0;
      regChannelAtivoHigh_13[n] = 0.0;
      regChannelAtivoHigh_14[n] = 0.0;
      regChannelAtivoHigh_15[n] = 0.0;
      regChannelAtivoHigh_16[n] = 0.0;
      regChannelAtivoHigh_17[n] = 0.0;
      regChannelAtivoHigh_18[n] = 0.0;
      regChannelAtivoHigh_19[n] = 0.0;
      regChannelAtivoHigh_20[n] = 0.0;
      regChannelAtivoHigh_21[n] = 0.0;
      regChannelAtivoHigh_22[n] = 0.0;
      regChannelAtivoHigh_23[n] = 0.0;
      regChannelAtivoHigh_24[n] = 0.0;

      regChannelAtivoClose_1[n] = 0.0;
      regChannelAtivoClose_2[n] = 0.0;
      regChannelAtivoClose_3[n] = 0.0;
      regChannelAtivoClose_4[n] = 0.0;
      regChannelAtivoClose_5[n] = 0.0;
      regChannelAtivoClose_6[n] = 0.0;
      regChannelAtivoClose_7[n] = 0.0;
      regChannelAtivoClose_8[n] = 0.0;
      regChannelAtivoClose_9[n] = 0.0;
      regChannelAtivoClose_10[n] = 0.0;
      regChannelAtivoClose_11[n] = 0.0;
      regChannelAtivoClose_12[n] = 0.0;
      regChannelAtivoClose_13[n] = 0.0;
      regChannelAtivoClose_14[n] = 0.0;
      regChannelAtivoClose_15[n] = 0.0;
      regChannelAtivoClose_16[n] = 0.0;
      regChannelAtivoClose_17[n] = 0.0;
      regChannelAtivoClose_18[n] = 0.0;
      regChannelAtivoClose_19[n] = 0.0;
      regChannelAtivoClose_20[n] = 0.0;
      regChannelAtivoClose_21[n] = 0.0;
      regChannelAtivoClose_22[n] = 0.0;
      regChannelAtivoClose_23[n] = 0.0;
      regChannelAtivoClose_24[n] = 0.0;

      regChannelAtivoLow_1[n] = 0.0;
      regChannelAtivoLow_2[n] = 0.0;
      regChannelAtivoLow_3[n] = 0.0;
      regChannelAtivoLow_4[n] = 0.0;
      regChannelAtivoLow_5[n] = 0.0;
      regChannelAtivoLow_6[n] = 0.0;
      regChannelAtivoLow_7[n] = 0.0;
      regChannelAtivoLow_8[n] = 0.0;
      regChannelAtivoLow_9[n] = 0.0;
      regChannelAtivoLow_10[n] = 0.0;
      regChannelAtivoLow_11[n] = 0.0;
      regChannelAtivoLow_12[n] = 0.0;
      regChannelAtivoLow_13[n] = 0.0;
      regChannelAtivoLow_14[n] = 0.0;
      regChannelAtivoLow_15[n] = 0.0;
      regChannelAtivoLow_16[n] = 0.0;
      regChannelAtivoLow_17[n] = 0.0;
      regChannelAtivoLow_18[n] = 0.0;
      regChannelAtivoLow_19[n] = 0.0;
      regChannelAtivoLow_20[n] = 0.0;
      regChannelAtivoLow_21[n] = 0.0;
      regChannelAtivoLow_22[n] = 0.0;
      regChannelAtivoLow_23[n] = 0.0;
      regChannelAtivoLow_24[n] = 0.0;
   }

   double dataArray[];

   if (exibeCanalHigh) {
      ArrayFree(dataArray);
      ArrayCopy(dataArray, bufferAtivoHigh);
      ArrayReverse(dataArray);
      if (!exibeCurva) {
         CalcAB(dataArray, 0, barFrom, A, B);
         stdev = GetStdDev(dataArray, 0, barFrom); //calculate standand deviation
      }

      for (int i = 0; i < showAfter > 0 ? showAfter : barFrom; i++) {
         if (exibeCurva) {
            CalcAB(dataArray, i, barFrom, A, B);
            stdev = GetStdDev(dataArray, i, barFrom);
         }

         if (exibeCanalHigh) {
            regChannelBufferAtivoHigh[i] = high1 * (1 + (A * (i) + B) / 100);
            regChannelAtivoHigh_1[i] = high1 * (1 + ((A * (i) + B) + (12 + offset1) * desvioAtivo1 * stdev) / 100);
            regChannelAtivoHigh_2[i] = high1 * (1 + ((A * (i) + B) + (11 + offset1) * desvioAtivo1 * stdev) / 100);
            regChannelAtivoHigh_3[i] = high1 * (1 + ((A * (i) + B) + (10 + offset1) * desvioAtivo1 * stdev) / 100);
            regChannelAtivoHigh_4[i] = high1 * (1 + ((A * (i) + B) + (9 + offset1) * desvioAtivo1 * stdev) / 100);
            regChannelAtivoHigh_5[i] = high1 * (1 + ((A * (i) + B) + (8 + offset1) * desvioAtivo1 * stdev) / 100);
            regChannelAtivoHigh_6[i] = high1 * (1 + ((A * (i) + B) + (7 + offset1) * desvioAtivo1 * stdev) / 100);
            regChannelAtivoHigh_7[i] = high1 * (1 + ((A * (i) + B) + (6 + offset1) * desvioAtivo1 * stdev) / 100);
            regChannelAtivoHigh_8[i] = high1 * (1 + ((A * (i) + B) + (5 + offset1) * desvioAtivo1 * stdev) / 100);
            regChannelAtivoHigh_9[i] = high1 * (1 + ((A * (i) + B) + (4 + offset1) * desvioAtivo1 * stdev) / 100);
            regChannelAtivoHigh_10[i] = high1 * (1 + ((A * (i) + B) + (3 + offset1) * desvioAtivo1 * stdev) / 100);
            regChannelAtivoHigh_11[i] = high1 * (1 + ((A * (i) + B) + (2 + offset1) * desvioAtivo1 * stdev) / 100);
            regChannelAtivoHigh_12[i] = high1 * (1 + ((A * (i) + B) + (1 + offset1) * desvioAtivo1 * stdev) / 100);
            regChannelAtivoHigh_13[i] = high1 * (1 + ((A * (i) + B) - (1 + offset1) * desvioAtivo1 * stdev) / 100);
            regChannelAtivoHigh_14[i] = high1 * (1 + ((A * (i) + B) - (2 + offset1) * desvioAtivo1 * stdev) / 100);
            regChannelAtivoHigh_15[i] = high1 * (1 + ((A * (i) + B) - (3 + offset1) * desvioAtivo1 * stdev) / 100);
            regChannelAtivoHigh_16[i] = high1 * (1 + ((A * (i) + B) - (4 + offset1) * desvioAtivo1 * stdev) / 100);
            regChannelAtivoHigh_17[i] = high1 * (1 + ((A * (i) + B) - (5 + offset1) * desvioAtivo1 * stdev) / 100);
            regChannelAtivoHigh_18[i] = high1 * (1 + ((A * (i) + B) - (6 + offset1) * desvioAtivo1 * stdev) / 100);
            regChannelAtivoHigh_19[i] = high1 * (1 + ((A * (i) + B) - (7 + offset1) * desvioAtivo1 * stdev) / 100);
            regChannelAtivoHigh_20[i] = high1 * (1 + ((A * (i) + B) - (8 + offset1) * desvioAtivo1 * stdev) / 100);
            regChannelAtivoHigh_21[i] = high1 * (1 + ((A * (i) + B) - (9 + offset1) * desvioAtivo1 * stdev) / 100);
            regChannelAtivoHigh_22[i] = high1 * (1 + ((A * (i) + B) - (10 + offset1) * desvioAtivo1 * stdev) / 100);
            regChannelAtivoHigh_23[i] = high1 * (1 + ((A * (i) + B) - (11 + offset1) * desvioAtivo1 * stdev) / 100);
            regChannelAtivoHigh_24[i] = high1 * (1 + ((A * (i) + B) - (12 + offset1) * desvioAtivo1 * stdev) / 100);
         }
      }
   }

   if (exibeCanalClose) {
      ArrayFree(dataArray);
      ArrayCopy(dataArray, bufferAtivoClose);
      ArrayReverse(dataArray);
      if (!exibeCurva) {
         CalcAB(dataArray, 0, barFrom, A, B);
         stdev = GetStdDev(dataArray, 0, barFrom); //calculate standand deviation
      }

      for (int i = 0; i < showAfter; i++) {
         if (exibeCurva) {
            CalcAB(dataArray, i, barFrom, A, B);
            stdev = GetStdDev(dataArray, i, barFrom);
         }
         if (exibeCanalClose) {
            regChannelBufferAtivoClose[i] = close1 * (1 + (A * (i) + B) / 100);
            regChannelAtivoClose_1[i] = close1 * (1 + ((A * (i) + B) + (12 + offset1) * desvioAtivo1 * stdev) / 100);
            regChannelAtivoClose_2[i] = close1 * (1 + ((A * (i) + B) + (11 + offset1) * desvioAtivo1 * stdev) / 100);
            regChannelAtivoClose_3[i] = close1 * (1 + ((A * (i) + B) + (10 + offset1) * desvioAtivo1 * stdev) / 100);
            regChannelAtivoClose_4[i] = close1 * (1 + ((A * (i) + B) + (9 + offset1) * desvioAtivo1 * stdev) / 100);
            regChannelAtivoClose_5[i] = close1 * (1 + ((A * (i) + B) + (8 + offset1) * desvioAtivo1 * stdev) / 100);
            regChannelAtivoClose_6[i] = close1 * (1 + ((A * (i) + B) + (7 + offset1) * desvioAtivo1 * stdev) / 100);
            regChannelAtivoClose_7[i] = close1 * (1 + ((A * (i) + B) + (6 + offset1) * desvioAtivo1 * stdev) / 100);
            regChannelAtivoClose_8[i] = close1 * (1 + ((A * (i) + B) + (5 + offset1) * desvioAtivo1 * stdev) / 100);
            regChannelAtivoClose_9[i] = close1 * (1 + ((A * (i) + B) + (4 + offset1) * desvioAtivo1 * stdev) / 100);
            regChannelAtivoClose_10[i] = close1 * (1 + ((A * (i) + B) + (3 + offset1) * desvioAtivo1 * stdev) / 100);
            regChannelAtivoClose_11[i] = close1 * (1 + ((A * (i) + B) + (2 + offset1) * desvioAtivo1 * stdev) / 100);
            regChannelAtivoClose_12[i] = close1 * (1 + ((A * (i) + B) + (1 + offset1) * desvioAtivo1 * stdev) / 100);
            regChannelAtivoClose_13[i] = close1 * (1 + ((A * (i) + B) - (1 + offset1) * desvioAtivo1 * stdev) / 100);
            regChannelAtivoClose_14[i] = close1 * (1 + ((A * (i) + B) - (2 + offset1) * desvioAtivo1 * stdev) / 100);
            regChannelAtivoClose_15[i] = close1 * (1 + ((A * (i) + B) - (3 + offset1) * desvioAtivo1 * stdev) / 100);
            regChannelAtivoClose_16[i] = close1 * (1 + ((A * (i) + B) - (4 + offset1) * desvioAtivo1 * stdev) / 100);
            regChannelAtivoClose_17[i] = close1 * (1 + ((A * (i) + B) - (5 + offset1) * desvioAtivo1 * stdev) / 100);
            regChannelAtivoClose_18[i] = close1 * (1 + ((A * (i) + B) - (6 + offset1) * desvioAtivo1 * stdev) / 100);
            regChannelAtivoClose_19[i] = close1 * (1 + ((A * (i) + B) - (7 + offset1) * desvioAtivo1 * stdev) / 100);
            regChannelAtivoClose_20[i] = close1 * (1 + ((A * (i) + B) - (8 + offset1) * desvioAtivo1 * stdev) / 100);
            regChannelAtivoClose_21[i] = close1 * (1 + ((A * (i) + B) - (9 + offset1) * desvioAtivo1 * stdev) / 100);
            regChannelAtivoClose_22[i] = close1 * (1 + ((A * (i) + B) - (10 + offset1) * desvioAtivo1 * stdev) / 100);
            regChannelAtivoClose_23[i] = close1 * (1 + ((A * (i) + B) - (11 + offset1) * desvioAtivo1 * stdev) / 100);
            regChannelAtivoClose_24[i] = close1 * (1 + ((A * (i) + B) - (12 + offset1) * desvioAtivo1 * stdev) / 100);
         }
      }
   }

   if (exibeCanalLow) {
      ArrayFree(dataArray);
      ArrayCopy(dataArray, bufferAtivoLow);
      ArrayReverse(dataArray);
      if (!exibeCurva) {
         CalcAB(dataArray, 0, barFrom, A, B);
         stdev = GetStdDev(dataArray, 0, barFrom); //calculate standand deviation
      }

      for (int i = 0; i < showAfter > 0 ? showAfter : barFrom; i++) {
         if (exibeCurva) {
            CalcAB(dataArray, i, barFrom, A, B);
            stdev = GetStdDev(dataArray, i, barFrom);
         }

         if (exibeCanalLow) {
            regChannelBufferAtivoLow[i] = low1 * (1 + (A * (i) + B) / 100);
            regChannelAtivoLow_1[i] = low1 * (1 + ((A * (i) + B) + (12 + offset1) * desvioAtivo1 * stdev) / 100);
            regChannelAtivoLow_2[i] = low1 * (1 + ((A * (i) + B) + (11 + offset1) * desvioAtivo1 * stdev) / 100);
            regChannelAtivoLow_3[i] = low1 * (1 + ((A * (i) + B) + (10 + offset1) * desvioAtivo1 * stdev) / 100);
            regChannelAtivoLow_4[i] = low1 * (1 + ((A * (i) + B) + (9 + offset1) * desvioAtivo1 * stdev) / 100);
            regChannelAtivoLow_5[i] = low1 * (1 + ((A * (i) + B) + (8 + offset1) * desvioAtivo1 * stdev) / 100);
            regChannelAtivoLow_6[i] = low1 * (1 + ((A * (i) + B) + (7 + offset1) * desvioAtivo1 * stdev) / 100);
            regChannelAtivoLow_7[i] = low1 * (1 + ((A * (i) + B) + (6 + offset1) * desvioAtivo1 * stdev) / 100);
            regChannelAtivoLow_8[i] = low1 * (1 + ((A * (i) + B) + (5 + offset1) * desvioAtivo1 * stdev) / 100);
            regChannelAtivoLow_9[i] = low1 * (1 + ((A * (i) + B) + (4 + offset1) * desvioAtivo1 * stdev) / 100);
            regChannelAtivoLow_10[i] = low1 * (1 + ((A * (i) + B) + (3 + offset1) * desvioAtivo1 * stdev) / 100);
            regChannelAtivoLow_11[i] = low1 * (1 + ((A * (i) + B) + (2 + offset1) * desvioAtivo1 * stdev) / 100);
            regChannelAtivoLow_12[i] = low1 * (1 + ((A * (i) + B) + (1 + offset1) * desvioAtivo1 * stdev) / 100);
            regChannelAtivoLow_13[i] = low1 * (1 + ((A * (i) + B) - (1 + offset1) * desvioAtivo1 * stdev) / 100);
            regChannelAtivoLow_14[i] = low1 * (1 + ((A * (i) + B) - (2 + offset1) * desvioAtivo1 * stdev) / 100);
            regChannelAtivoLow_15[i] = low1 * (1 + ((A * (i) + B) - (3 + offset1) * desvioAtivo1 * stdev) / 100);
            regChannelAtivoLow_16[i] = low1 * (1 + ((A * (i) + B) - (4 + offset1) * desvioAtivo1 * stdev) / 100);
            regChannelAtivoLow_17[i] = low1 * (1 + ((A * (i) + B) - (5 + offset1) * desvioAtivo1 * stdev) / 100);
            regChannelAtivoLow_18[i] = low1 * (1 + ((A * (i) + B) - (6 + offset1) * desvioAtivo1 * stdev) / 100);
            regChannelAtivoLow_19[i] = low1 * (1 + ((A * (i) + B) - (7 + offset1) * desvioAtivo1 * stdev) / 100);
            regChannelAtivoLow_20[i] = low1 * (1 + ((A * (i) + B) - (8 + offset1) * desvioAtivo1 * stdev) / 100);
            regChannelAtivoLow_21[i] = low1 * (1 + ((A * (i) + B) - (9 + offset1) * desvioAtivo1 * stdev) / 100);
            regChannelAtivoLow_22[i] = low1 * (1 + ((A * (i) + B) - (10 + offset1) * desvioAtivo1 * stdev) / 100);
            regChannelAtivoLow_23[i] = low1 * (1 + ((A * (i) + B) - (11 + offset1) * desvioAtivo1 * stdev) / 100);
            regChannelAtivoLow_24[i] = low1 * (1 + ((A * (i) + B) - (12 + offset1) * desvioAtivo1 * stdev) / 100);
         }
      }
   }

   double max, min;

   if (showPrice) {
      double tempArray[];
      CopyHigh(ativo1, tf, 0, barFrom, tempArray);
      max = tempArray[ArrayMaximum(tempArray)];
      CopyLow(ativo1, tf, 0, barFrom, tempArray);
      min = tempArray[ArrayMinimum(tempArray)];
   } else {
      if (inputTipoSpread == Intraday) {
         double tempArray[] = {bufferAtivoHigh[0],
                               bufferAtivoClose[0],
                               bufferAtivoLow[0],
                              };

         max = tempArray[ArrayMaximum(tempArray)];
         min = tempArray[ArrayMinimum(tempArray)];
      } else {
         double tempArrayMax[], tempArrayMin[];
         ArrayAdd(tempArrayMax, bufferAtivoHigh[ArrayMaximum(bufferAtivoHigh)]);
         ArrayAdd(tempArrayMax, bufferAtivoClose[ArrayMaximum(bufferAtivoClose)]);
         ArrayAdd(tempArrayMax, bufferAtivoLow[ArrayMaximum(bufferAtivoLow)]);

         ArrayAdd(tempArrayMin, bufferAtivoHigh[ArrayMinimum(bufferAtivoHigh)]);
         ArrayAdd(tempArrayMin, bufferAtivoClose[ArrayMinimum(bufferAtivoClose)]);
         ArrayAdd(tempArrayMin, bufferAtivoLow[ArrayMinimum(bufferAtivoLow)]);
         max = tempArrayMax[ArrayMaximum(tempArrayMax)];
         min = tempArrayMin[ArrayMinimum(tempArrayMin)];
      }
   }

//ChartSetInteger(0, CHART_SCALEFIX, 0, true);
//ChartSetDouble(0, CHART_FIXED_MAX, max + 1);
//ChartSetDouble(0, CHART_FIXED_MIN, min - 1);

   if (escalaMax == 0)
      IndicatorSetDouble(INDICATOR_MAXIMUM, max + 1);
   else
      IndicatorSetDouble(INDICATOR_MAXIMUM, escalaMax);

   if (escalaMin == 0)
      IndicatorSetDouble(INDICATOR_MINIMUM, min - 1);
   else
      IndicatorSetDouble(INDICATOR_MINIMUM, escalaMin);

   if (!showPrice) {
      PlotIndexSetInteger(3, PLOT_DRAW_TYPE, DRAW_NONE);
      ArrayFree(bufferShowPrice);
   }

   return(true);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnTimer() {
   CheckTimer();
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void OnDeinit(const int reason) {

   delete(_updateTimer);
   if(UninitializeReason() == REASON_REMOVE) {
      ObjectDelete(0, "spread_from_line");
   }
   ChartRedraw();

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CheckTimer() {

   EventKillTimer();

   if(_updateTimer.Check() || !_lastOK) {
      _lastOK = Update();

      EventSetMillisecondTimer(WaitMilliseconds);

      ChartRedraw();
      if (debug) Print("Spread Single Main " + " " + _Symbol + ":" + GetTimeFrame(Period()) + " ok");

      _updateTimer.Reset();
   } else {
      EventSetTimer(1);
   }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class MillisecondTimer {

 private:
   int               _milliseconds;
 private:
   uint              _lastTick;

 public:
   void              MillisecondTimer(const int milliseconds, const bool reset = true) {
      _milliseconds = milliseconds;

      if(reset)
         Reset();
      else
         _lastTick = 0;
   }

 public:
   bool              Check() {
      uint now = getCurrentTick();
      bool stop = now >= _lastTick + _milliseconds;

      if(stop)
         _lastTick = now;

      return(stop);
   }

 public:
   void              Reset() {
      _lastTick = getCurrentTick();
   }

 private:
   uint              getCurrentTick() const {
      return(GetTickCount());
   }

};

bool _lastOK = false;
MillisecondTimer *_updateTimer;

//+---------------------------------------------------------------------+
//| GetTimeFrame function - returns the textual timeframe               |
//+---------------------------------------------------------------------+
string GetTimeFrame(int lPeriod) {
   switch(lPeriod) {
   case PERIOD_M1:
      return("M1");
   case PERIOD_M2:
      return("M2");
   case PERIOD_M3:
      return("M3");
   case PERIOD_M4:
      return("M4");
   case PERIOD_M5:
      return("M5");
   case PERIOD_M6:
      return("M6");
   case PERIOD_M10:
      return("M10");
   case PERIOD_M12:
      return("M12");
   case PERIOD_M15:
      return("M15");
   case PERIOD_M20:
      return("M20");
   case PERIOD_M30:
      return("M30");
   case PERIOD_H1:
      return("H1");
   case PERIOD_H2:
      return("H2");
   case PERIOD_H3:
      return("H3");
   case PERIOD_H4:
      return("H4");
   case PERIOD_H6:
      return("H6");
   case PERIOD_H8:
      return("H8");
   case PERIOD_H12:
      return("H12");
   case PERIOD_D1:
      return("D1");
   case PERIOD_W1:
      return("W1");
   case PERIOD_MN1:
      return("MN1");
   }
   return IntegerToString(lPeriod);
}
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
//Linear Regression Calculation for sample data: arr[]
//line equation  y = f(x)  = ax + b
void CalcAB(const double &arr[], int start, int end, double & a, double & b) {

   a = 0.0;
   b = 0.0;
   int size = MathAbs(start - end) + 1;
   if(size < 2)
      return;

   double sumxy = 0.0, sumx = 0.0, sumy = 0.0, sumx2 = 0.0;
   for(int i = start; i < end; i++) {
      sumxy += i * arr[i];
      sumy += arr[i];
      sumx += i;
      sumx2 += i * i;
   }

   double M = size * sumx2 - sumx * sumx;
   if(M == 0.0)
      return;

   a = (size * sumxy - sumx * sumy) / M;
   b = (sumy - a * sumx) / size;

}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
double GetStdDev(const double & arr[], int start, int end) {
   int size = MathAbs(start - end) + 1;
   if(size < 2)
      return(0.0);

   double sum = 0.0;
   for(int i = start; i < end; i++) {
      sum = sum + arr[i];
   }

   sum = sum / size;

   double sum2 = 0.0;
   for(int i = start; i < end; i++) {
      sum2 = sum2 + (arr[i] - sum) * (arr[i] - sum);
   }

   sum2 = sum2 / (size - 1);
   sum2 = MathSqrt(sum2);

   return(sum2);
}

//+------------------------------------------------------------------+
void ArrayAdd(int &sourceArr[], int value) {
   int iLast = ArraySize(sourceArr);        // End
   ArrayResize(sourceArr, iLast + 1);       // Make room
   sourceArr[iLast] = value;                // Store at new
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void ArrayAdd(double &sourceArr[], double value) {
   int iLast = ArraySize(sourceArr);        // End
   ArrayResize(sourceArr, iLast + 1);       // Make room
   sourceArr[iLast] = value;                // Store at new
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void DrawVLine(const string name, const datetime time1, const color lineColor, const int width, const int style, const bool back = true, const bool hidden = true, const bool selectable = false, const int zorder = 0) {
   ObjectDelete(0, name);
   ObjectCreate(0, name, OBJ_VLINE, 0, time1, 0);
   ObjectSetInteger(0, name, OBJPROP_COLOR, lineColor);
   ObjectSetInteger(0, name, OBJPROP_BACK, back);
   ObjectSetInteger(0, name, OBJPROP_HIDDEN, hidden);
   ObjectSetInteger(0, name, OBJPROP_SELECTABLE, selectable);
   ObjectSetInteger(0, name, OBJPROP_STYLE, style);
   ObjectSetInteger(0, name, OBJPROP_WIDTH, width);
   ObjectSetInteger(0, name, OBJPROP_ZORDER, zorder);
}
//+------------------------------------------------------------------+
