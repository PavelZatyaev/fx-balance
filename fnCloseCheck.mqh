//проверяем успешность закрыти треугольника. Здесь не закрываем, толкьо проверка !

#include "head.mqh"

void fnCloseCheck(stThree &MxSmb[], int accounttype,int fh)
   {
      // пробежались по массиву треугольников
      for(int i=ArraySize(MxSmb)-1;i>=0;i--)
      {
         // интересуют только те, где статус = 3, то есть уже закрытые или только отправленные на закрытие
         if(MxSmb[i].status!=3) continue;
         
         switch(accounttype)
         {
            case  ACCOUNT_MARGIN_MODE_RETAIL_HEDGING: 
            
            // если не смогли выделить ни одной пары из всего треугольника, значит закрыли успешно. Возвращаем статус в 0
            if (!PositionSelectByTicket(MxSmb[i].smb1.tkt))
            if (!PositionSelectByTicket(MxSmb[i].smb2.tkt))
            if (!PositionSelectByTicket(MxSmb[i].smb3.tkt))
            {  // значит закрыли успешно
               MxSmb[i].status=0;   
               
               Print("Close triangle: "+MxSmb[i].name() + " magic: "+(string)MxSmb[i].magic+"  P/L: "+DoubleToString(MxSmb[i].pl,2));
               
               // записали в лог файл информацию о закрытии
               if (fh!=INVALID_HANDLE)
               {
                  FileWrite(fh,"============");
                  FileWrite(fh,"Close:",MxSmb[i].name());
                  FileWrite(fh,"Lot",DoubleToString(MxSmb[i].smb1.lot,MxSmb[i].smb1.digits_lot),DoubleToString(MxSmb[i].smb2.lot,MxSmb[i].smb2.digits_lot),DoubleToString(MxSmb[i].smb3.lot,MxSmb[i].smb3.digits_lot));
                  FileWrite(fh,"Tiket",string(MxSmb[i].smb1.tkt),string(MxSmb[i].smb2.tkt),string(MxSmb[i].smb3.tkt));
                  FileWrite(fh,"Magic",string(MxSmb[i].magic));
                  FileWrite(fh,"Profit",DoubleToString(MxSmb[i].pl,3));
                  FileWrite(fh,"Time current",TimeToString(TimeCurrent(),TIME_DATE|TIME_SECONDS));
                  FileFlush(fh);               
               }                   
            }                  
            break;
         }            
      }      
   }