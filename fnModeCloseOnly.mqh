//режим когда всё закрываем без ожидания профита

bool fnModeCloseOnly(ulong lcMagic, uint delta, int accounttype)
   {   
      bool find=false;//флаг что нашли ордер
      switch(accounttype)
      {
         case  ACCOUNT_MARGIN_MODE_RETAIL_HEDGING://просто закрыли все ордера по магику и всё
            for(int i=PositionsTotal()-1;i>=0;i--)
            {
               ulong mg=PositionGetInteger(POSITION_MAGIC);
               if (mg>=lcMagic && mg<(lcMagic+delta))
               {
                  find=true;
                  ctrade.PositionClose(PositionGetTicket(i));
               }
            }
            if (!find) return(true);//если больше ордеров нет то можно выгружать робот
         break;
         default:
         break;
      }      
      return(false);
   }