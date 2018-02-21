/*
  Author: Vasu Takasi
  Created On:24th June 2013
  Trigger Name:CheckDuplicateMonthsInCCTrg
  Description: Need to enforce that there should not be duplicate Monthly Sales for One month. There should only be One Monthly sales record froeach month. 
*/
trigger CheckDuplicateMonthsInCCTrg on Credit_Card__c (before insert, before update, after insert, after update, after delete ) {
  set<id>setAccountIds=new set<id>();   
  list<Credit_Card__c>lstCreditCards=new list<Credit_Card__c>();
  map<string,Credit_Card__c> mapCreditCard=new map<string,Credit_Card__c>(); 
  map<Id,Account> mapCCActRelatedAccounts = new map<Id,Account>();
  map<Id,Account> mapSummartAccountsToUpdate = new map<Id,Account>();
  
  if(trigger.isDelete == false){
    for(Credit_Card__c objCC : trigger.new){
      if(objCC.Account__c != null){
        setAccountIds.add(objCC.Account__c);
      }  
    }
    
    if(trigger.isBefore){
      lstCreditCards=[select id,name,Month__c,year__c,Account__c,MID_Account_Number__c  from Credit_Card__c where Account__c in :setAccountIds];
      for(Credit_Card__c objCC : lstCreditCards){
          string key=objCC.Month__c+'::'+objCC.Year__c+'::'+objCC.Account__c+'::'+objCC.MID_Account_Number__c;
          mapCreditCard.put(key,objCC);
      }
    
      for(Credit_Card__c objCC : trigger.new){
        string key=objCC.Month__c+'::'+objCC.Year__c+'::'+objCC.Account__c+'::'+objCC.MID_Account_Number__c;
        if(mapCreditCard.get(key) != null && mapCreditCard.get(key).Id != objCC.Id)
          objCC.Month__c.addError('Duplicate Month found for the year '+objCC.Year__c);
      }
    }
  }else if(trigger.isDelete){
      for(Credit_Card__c objCC : trigger.old){
          if(objCC.Account__c != null){
        setAccountIds.add(objCC.Account__c);
      }  
      }
    }
    
  //added by RB, on 26th June, inorder to populate the CreditCardAccounts Summary on Accounts
  if(trigger.isAfter){
    SupportUtil objSupportUtil = new SupportUtil();
    mapCCActRelatedAccounts = new map<Id,Account>([select Id,Name,Processor_Names__c,MIDs__c,(select Id,Name,MID_Account_Number__c,Month__c,Year__c,Total_Net_Processed_All__c,Number_of_Transactions_All__c,
                 Number_of_Transactions_AMEX_only__c,Total_Net_Processed_AMEX_only__c,Sys_Processor_Name__c from Credit_Cards1__r where Month__c != null AND Year__c != null order by Year__c,Month__c) from Account where Id IN : setAccountIds]);
    
    list<Credit_Card__c> lstTrgCCAccounts = new list<Credit_Card__c>();
        if(trigger.isInsert || trigger.isUpdate)
          lstTrgCCAccounts = trigger.new;
        else if(trigger.isDelete){
          lstTrgCCAccounts = [select Id,Name,Account__c,MID_Account_Number__c from Credit_Card__c where Account__c IN : mapCCActRelatedAccounts.keySet()];
        }
    
    for(Credit_Card__c objCC : lstTrgCCAccounts){//trigger.new
      if(objCC.Account__c != null && mapCCActRelatedAccounts.get(objCC.Account__c) != null){
        decimal dAllMonthsAvg = 0,d2MonthsAvg=0;
        decimal dTotCCStmts = 0;
        decimal dTolTANonAMEX = 0;
        
        Account objAccount;
        if(mapSummartAccountsToUpdate != null && mapSummartAccountsToUpdate.get(objCC.Account__c) != null)
          objAccount = mapSummartAccountsToUpdate.get(objCC.Account__c);
        else
          objAccount = new Account(Id=objCC.Account__c);
        
        //objAccount.Processor_Names__c = mapCCActRelatedAccounts.get(objCC.Account__c).Name;
        string CCNames = '';
        string CCMIDs = '';//(mapCCActRelatedAccounts.get(objCC.Processor_Name__c).MIDs__c != null)?mapCCActRelatedAccounts.get(objCC.Processor_Name__c).MIDs__c:'';
        /*if( objCC.MID_Account_Number__c != null && CCMIDs.contains(objCC.MID_Account_Number__c) == false){
          CCMIDs += ( CCMIDs != '' )?','+objCC.MID_Account_Number__c:objCC.MID_Account_Number__c;
        }
        */
        
        Integer iC = 0;
        map<string,decimal> mapMonthDeposits = new map<string,decimal>();
        if(mapCCActRelatedAccounts.get(objCC.Account__c) != null && mapCCActRelatedAccounts.get(objCC.Account__c).Credit_Cards1__r != null){
          for(Credit_Card__c objCCard : mapCCActRelatedAccounts.get(objCC.Account__c).Credit_Cards1__r){
            //system.debug('objCCard.Total_Net_Processed_All__c is : '+objCCard.Total_Net_Processed_All__c);
            //system.debug('objCCard.Total_Net_Processed_AMEX_only__c is : '+objCCard.Total_Net_Processed_AMEX_only__c);
            
            if(CCMIDs!=null && CCMIDs!='' && objCCard.MID_Account_Number__c!=null && objCCard.MID_Account_Number__c!='' && CCMIDs.contains(objCCard.MID_Account_Number__c) == false)
              CCMIDs += ''+objCCard.MID_Account_Number__c+',';
            if(objCCard.Sys_Processor_Name__c != null && !CCNames.contains(objCCard.Sys_Processor_Name__c))
                          CCNames += ''+objCCard.Sys_Processor_Name__c+',';
            dAllMonthsAvg += (objCCard.Total_Net_Processed_All__c != null)?objCCard.Total_Net_Processed_All__c:0;
            mapMonthDeposits.put(objCCard.Month__c+'-'+objCCard.Year__c,objCCard.Total_Net_Processed_All__c);
            dTotCCStmts += (objCCard.Number_of_Transactions_All__c != null)?objCCard.Number_of_Transactions_All__c:0;
                        
            if(objCCard.Total_Net_Processed_All__c != null){
              if(objCCard.Total_Net_Processed_AMEX_only__c != null){
                decimal dc = objCCard.Total_Net_Processed_All__c - objCCard.Total_Net_Processed_AMEX_only__c;
                dTolTANonAMEX += dc;
              }else
                dTolTANonAMEX += objCCard.Total_Net_Processed_All__c;
            }
            system.debug('dTolTANonAMEX @@ is : '+dTolTANonAMEX);
            iC++;
          }
        }
        if(CCMIDs != '')
          objAccount.MIDs__c = CCMIDs.substring(0, CCMIDs.length()-1);
        if(CCNames != '')
                  objAccount.Processor_Names__c = CCNames.substring(0, CCNames.length()-1);
        if(dTotCCStmts != null && dTotCCStmts!=0){
          //objAccount.Number_CC_Statements_Available__c = dTotCCStmts;
          objAccount.CC_transactions_Monthly_Avg__c = dTotCCStmts/iC;  
        }
        objAccount.Number_CC_Statements_Available__c = iC; //dTotCCStmts; commentted as per RaviChandra comments on 26th Aug,2013 by RB
        if(dAllMonthsAvg != null && dAllMonthsAvg != 0){
          //dAllMonthsAvg = dAllMonthsAvg/iC;
          objAccount.Monthly_CC_Avg_All__c = dAllMonthsAvg/iC;
        }
        
        if(mapMonthDeposits != null && mapMonthDeposits.size() > 0){
          
          Datetime d = System.now();
          Datetime thisDate = DateTime.newInstance(d.year(), d.month(), d.day());
          String Month = thisDate.format('MMMM');
          Integer Year = thisDate.Year();
          
          string Lst2Months = objSupportUtil.PreviousMonths(Month);
          if(Lst2Months != null && Lst2Months.indexOf(',') > -1){
            string Month1 = Lst2Months.split(',')[0];
            string Month2 = Lst2Months.split(',')[1];
            
            if(Month=='January'){
              Month1 += '-'+(Year-1);
              Month2 += '-'+(Year-1);
            }else if(Month=='February'){
              Month1 += '-'+Year;
              Month2 += '-'+(Year-1);
            }else{
              Month1 += '-'+Year;
              Month2 += '-'+Year;
            }
            
            if(mapMonthDeposits != null && mapMonthDeposits.get(Month1) != null)
              d2MonthsAvg += mapMonthDeposits.get(Month1);
            if(mapMonthDeposits != null && mapMonthDeposits.get(Month2) != null)
              d2MonthsAvg += mapMonthDeposits.get(Month2);  
          }
          if(d2MonthsAvg != null && d2MonthsAvg != 0)
            objAccount.Monthly_CC_Avg_Last_2_Months__c = d2MonthsAvg/2;
        }
        
        system.debug('dTolTANonAMEX is : '+dTolTANonAMEX);
        if(dTolTANonAMEX != null && dTolTANonAMEX != 0)
          objAccount.Monthly_CC_Avg_Non_Amex__c = dTolTANonAMEX/iC;
        mapSummartAccountsToUpdate.put(objAccount.Id,objAccount);
      }
    }
    
    if(mapSummartAccountsToUpdate != null && mapSummartAccountsToUpdate.size() > 0)
      update mapSummartAccountsToUpdate.values();
  }
}