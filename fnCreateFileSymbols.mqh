#include "head.mqh"

void fnCreateFileSymbols(stThree &MxSmb[], int filehandle)
   {
      // определяем заголовки в файле
      FileWrite(filehandle,"Symbol 1","Symbol 2","Symbol 3","Contract Size 1","Contract Size 2","Contract Size 3",
      "Lot min 1","Lot min 2","Lot min 3","Lot max 1","Lot max 2","Lot max 3","Lot step 1","Lot step 2","Lot step 3",
      "Common min lot","Common max lot","Digits 1","Digits 2","Digits 3");
      
      // заполняем файл в соответсвии вышеуказанным заголовкам
      for(int i=ArraySize(MxSmb)-1;i>=0;i--)
      {
         FileWrite(filehandle,MxSmb[i].smb1.name,MxSmb[i].smb2.name,MxSmb[i].smb3.name,
         MxSmb[i].smb1.contract,MxSmb[i].smb2.contract,MxSmb[i].smb3.contract,
         MxSmb[i].smb1.lot_min,MxSmb[i].smb2.lot_min,MxSmb[i].smb3.lot_min,
         MxSmb[i].smb1.lot_max,MxSmb[i].smb2.lot_max,MxSmb[i].smb3.lot_max,
         MxSmb[i].smb1.lot_step,MxSmb[i].smb2.lot_step,MxSmb[i].smb3.lot_step,
         MxSmb[i].lot_min,MxSmb[i].lot_max,
         MxSmb[i].smb1.digits,MxSmb[i].smb2.digits,MxSmb[i].smb3.digits);         
      }
      FileWrite(filehandle,"");//оставим пустую строку после всех символов
      
      // после завершения работы сбросим все данные на диск, для безопасности
      FileFlush(filehandle);
   }
