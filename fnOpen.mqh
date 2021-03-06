//всё открытие здесь

#include "head.mqh"

bool fnOpen(stThree &MxSmb[],int i,string cmnt,bool side, ushort &opt)
   {
      // флаг открытия первого ордера
      bool openflag=false;
      
      // если нет разрешения на торговлю то и не торгуем
      if (!cterm.IsTradeAllowed())  return(false);
      if (!cterm.IsConnected())     return(false);
      
      // треуголник не открылся подряд TIMEOUT_COUNT_MAX раз. Блокируем до выяснения...
      if (MxSmb[i].timeout_count >= TIMEOUT_COUNT_MAX) return(false);
      
      // исходно считаем, что треугольник не откроется
      MxSmb[i].timeout = TIMEOUT_OPEN;
      MxSmb[i].timeout_count++;
      MxSmb[i].stored_profit = 0;

      switch(side)
      {
         case  true:
         
         // если после отправки ордера на открытие вернулсоь true, это не гарантия что он будет открыт
         // но если вернулся фальш, то уже точно не откроемся т.к. приказ даже не отправлен
         // следовательно и нет смысла отправлять на открытие 2 остальных пары. Лучше попробуем заново на следующем тике
         // также робот не занимается дооткрываением треугольника. Приказы отправлены, если что то неоткрылось, то после ожидания
         // времени указанного в дефайне MAXTIMEWAIT закрываем треугольник если он всё таки до конца не открылся
         if(ctrade.Buy(MxSmb[i].smb1.lot,MxSmb[i].smb1.name,0,0,0,cmnt))
         {
            openflag=true;
            MxSmb[i].status=1;
            opt++;
            // далее логика таже - если не смогли открыть, то треугольник уйдёт в закрываемые
            if(ctrade.Sell(MxSmb[i].smb2.lot,MxSmb[i].smb2.name,0,0,0,cmnt))
               ctrade.Sell(MxSmb[i].smb3.lot,MxSmb[i].smb3.name,0,0,0,cmnt);               
         }
         break;
         case  false:
         
         if(ctrade.Sell(MxSmb[i].smb1.lot,MxSmb[i].smb1.name,0,0,0,cmnt))
         {
            openflag=true;
            MxSmb[i].status=1;  
            opt++;        
            if(ctrade.Buy(MxSmb[i].smb2.lot,MxSmb[i].smb2.name,0,0,0,cmnt))
               ctrade.Buy(MxSmb[i].smb3.lot,MxSmb[i].smb3.name,0,0,0,cmnt);         
         }           
         break;
      }      
      return(openflag);
   }