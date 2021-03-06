#include "head.mqh"

// макросы
#define DEVIATION       3                                      // максимально возможное проскальзывание
#define FILENAME        "Balance Three Point.csv"            // здесь хранятся символы для работы
#define FILELOG         "Balance Three Point Control "       // часть имено лог файла
#define FILEOPENWRITE(nm)  FileOpen(nm,FILE_UNICODE|FILE_WRITE|FILE_SHARE_READ|FILE_CSV)  // открытие файла для записи
#define FILEOPENREAD(nm)   FileOpen(nm,FILE_UNICODE|FILE_READ|FILE_SHARE_READ|FILE_CSV)   // открытие файла для чтения
#define CF                1.2                                    // повышаюший коэффициент для маржи
#define MAGIC             200                                    // диапазон используемых магиков
#define MAXTIMEWAIT       10                                     // максимальное время ожидания открытия треугольника в секундах
#define TIMEOUT_OPEN      30                                     //pz таймаут на повторное открытие в случае ошибки
#define TIMEOUT_COUNT_MAX 3                                      //pz количество непрерывных таймутов до блокировки треугольника
#define SPREAD_CF         1.02                                   //pz повышаюший коэффициент для спреда (типа страховки от убытка)

// структура для валютной пары
struct stSmb
   {
      string            name;            // Валютная пара
      int               digits;          // Количество знаков после запятой в котировке
      uchar             digits_lot;      // Количество знаков после запятой в лоте, для округления
      int               Rpoint;          // 1/point точбы в формулах на это значение умножать а не делить
      double            dev;             // возможное проскальзывание. переводим сразу в кол-во поинтов
      double            lot;             // Объём торговли для валютной пары
      double            lot_min;         // минимальный объём
      double            lot_max;         // максимальный объём
      double            lot_step;        // шаг лота
      double            contract;        // размер контракта
      double            price;           // цена открытия пары в треугольнике. нужна для неттинга
      ulong             tkt;             // тикет ордера которым открыта сделка. нужна только для удобства в хедж счетах
      MqlTick           tick;            // текущие цены пары
      double            tv;              // текущая стоимость тика
      double            mrg;             // текущая необходимая маржа для открытия
      double            sppoint;         // спред в целых пунктах
      double            spcost;          // спред в деньгах на текущий открываемый лот
      double            profit;          // 

      stSmb(){price=0;tkt=0;mrg=0;}   
   };

// структура для треугольника
struct stThree
   {
      stSmb             smb1;
      stSmb             smb2;
      stSmb             smb3;
      double            lot_min;          // минимальный объём для всего треугольника
      double            lot_max;          // максимальный объём для всего треугольника     
      ulong             magic;            // магик треугольника
      uchar             status;           // статус треугольника. 0-не используется. 1 - отправили на открытие. 2 - успешно открыт. 3- отправили на закрытие
      double            pl;               // профит треугольника
      datetime          timeopen;         // время отправки треугольника на открытие
      double            PLBuy;            // сколько можно заработать если купить треугольник
      double            PLSell;           // сколько можно заработать если продать треугольник
      double            spread;           // стоимость суммарная всех трёх спредов. с комиссиЕЙ
      int               timeout;          // таймаут на следующее открытие треугольника в случае ошибки
      int               timeout_count;    // кол-во непрерывных таймаутов
      double            stored_profit;    // накопленная прибыль
      
      stThree(){status=0;magic=0;timeout=0;timeout_count = 0;stored_profit=0;}
      string name() {return smb1.name+" + "+smb2.name+" + "+smb3.name;};
   };

  
// режимы работы эксперта  
enum enMode
   {
      STANDART_MODE  =  0, /*Symbols from Market Watch*/                //Обычный режим работы. символы из обзора рынка//
      USE_FILE       =  1, /*Symbols from file*/                        //Использовать файл символов
      CREATE_FILE    =  2, /*Create file with symbols*/                 //Создать файл для тестера или для работы
      //END_ADN_CLOSE  =  3, /*Not open, wait profit, close & exit*/      //Закрыть все свои сделки и закончить работу
      //CLOSE_ONLY     =  4  /*Not open, not wait profit, close & exit*/
   };


stThree  MxThree[];           // основной массив где храняться рабочие треугольники и все необходимые дополнительные данные

CTrade         ctrade;        // класс CTrade стандартной библиотеки
CSymbolInfo    csmb;          // класс CSymbolInfo стандартной библиотеки
CSupport       csup;          // вспомогательный класс для часто используемых функций
CTerminalInfo  cterm;         // класс CTerminalInfo стандартной библиотеки

int         glAccountsType=0; // тип счёте. хедж или неттинг
int         glFileLog=0;      // хендл лог файла
//int         glTimeout=0;      //pz таймаут между открытиями треугольников


// Входные параметры

sinput      enMode      inMode=     0;          //Job mode
input       double      inFixProfit =   0;          //Commission
input       double      inLot=      1;          //Trade volume
input       short       inMaxThree= 0;          //Together triangles open
sinput      ulong       inMagic=    300;        //EA number
sinput      string      inCmnt=     "R ";       //Comment



