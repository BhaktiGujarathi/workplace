/*
    Author: Vasu Takasi
    Created On:24th June 2013
    Trigger Name:CheckDuplicateMonthsInBankAccTrg
    Description: Need to enforce that there should not be duplicate Monthly Sales for One month. There should only be One Monthly sales record froeach month. 
*/
trigger CheckDuplicateMonthsInBankAccTrg on Bank_Account__c (before insert, before update, after insert, after update, after delete ) {
    set<id>setAccountIds=new set<id>();     
    map<string,Bank_Account__c> mapBankAccount=new map<string,Bank_Account__c>(); 
    map<Id,Account> mapBankActRelatedAccounts = new map<Id,Account>();
    map<Id,Account> mapSummartAccountsToUpdate = new map<Id,Account>();
    
    if(trigger.isDelete == false){
	    for(Bank_Account__c objBA : trigger.new){
	        /*
	        if(objBA.Bank_Name__c != null){
	            setAccountIds.add(objBA.Bank_Name__c);
	        }*/
	        //Changed SetAccountIds from Bank_Name__c to Account__c (Now Customer Account will be in Account__c field) change done on 26-08-2013 
	        if(objBA.Account__c != null){
	        	setAccountIds.add(objBA.Account__c);
	        }   
	    }
	    
	    if(trigger.isBefore){
	    	list<Bank_Account__c> lstBankAccounts = new list<Bank_Account__c>();
	        lstBankAccounts = [select id,name,Bank_Account_Number__c,Month__c,year__c,Bank_Name__c,Account__c from Bank_Account__c where Account__c IN :setAccountIds];
	        if(lstBankAccounts != null && lstBankAccounts.size() > 0){
	            for(Bank_Account__c objBA : lstBankAccounts){
	                string key=objBA.Month__c+'::'+objBA.Year__c+'::'+objBA.Account__c+'::'+objBA.Bank_Account_Number__c;
	                mapBankAccount.put(key,objBA);
	            }
	            
	            for(Bank_Account__c objBA : trigger.new){
	                string key=objBA.Month__c+'::'+objBA.Year__c+'::'+objBA.Account__c+'::'+objBA.Bank_Account_Number__c;
	                if(mapBankAccount.get(key) != null && mapBankAccount.get(key).Id != objBA.Id)
	                    objBA.Month__c.addError('Duplicate Month found for the year '+objBA.Year__c);
	            }
	        }
	    }
    }else if(trigger.isDelete){
    	for(Bank_Account__c objBA : trigger.old){
	        if(objBA.Account__c != null){
	            setAccountIds.add(objBA.Account__c);
	        }   
	    }
    }
    //added by RB, on 25th June, inorder to populate the BankAccounts Summary on Accounts
    if(trigger.isAfter){
        SupportUtil objSupportUtil = new SupportUtil();
        system.debug('setAccountIds are : '+setAccountIds);
        mapBankActRelatedAccounts = new map<Id,Account>([select Id,Name,Bank_Names__c,Bank_Acct_Nums__c,(select Id,Name,Bank_Account_number__c,Month__c,Year__c,Deposits_Minus_Transfers__c,
        							Number_of_NSFs__c,Average_Daily_Balance__c,Sys_Bank_Name__c from Bank_Accounts1__r where Month__c != null AND Year__c != null order by Year__c,Month__c) from Account where Id IN : setAccountIds]); 
        list<Bank_Account__c> lstTrgBankAccounts = new list<Bank_Account__c>();
        if(trigger.isInsert || trigger.isUpdate)
        	lstTrgBankAccounts = trigger.new;
        else if(trigger.isDelete){
        	lstTrgBankAccounts = [select Id,Name,Bank_Account_Number__c,Bank_Name__c,Account__c,Sys_Bank_Name__c from Bank_Account__c where Account__c IN : mapBankActRelatedAccounts.keySet()];
        }	
        
        for(Bank_Account__c objBA : lstTrgBankAccounts){//trigger.new
            if(objBA.Account__c != null && mapBankActRelatedAccounts.get(objBA.Account__c) != null){
                decimal dAllMonthsAvg = 0,d2MonthsAvg=0;
                decimal dTotBankStmts = 0;
                decimal dADB = 0;
                decimal dNSFavg = 0;
                Account objAccount;
                if(mapSummartAccountsToUpdate != null && mapSummartAccountsToUpdate.get(objBA.Account__c) != null)
                    objAccount = mapSummartAccountsToUpdate.get(objBA.Account__c);
                else
                    objAccount = new Account(Id=objBA.Account__c);
                    
                //objAccount.Bank_Names__c = mapBankActRelatedAccounts.get(objBA.Bank_Name__c).Name;
                string BankNames = '';//Added on 26-08-2013
                string BankActNos = '';//(mapBankActRelatedAccounts.get(objBA.Bank_Name__c).Bank_Acct_Nums__c != null)?mapBankActRelatedAccounts.get(objBA.Bank_Name__c).Bank_Acct_Nums__c:'';
                /*if(BankActNos.contains(objBA.Bank_Account_Number__c) == false){
                    BankActNos += ( BankActNos != '' )?','+objBA.Bank_Account_Number__c:objBA.Bank_Account_Number__c;
                }*/
                
                
                Integer iC = 0;
                map<string,decimal> mapMonthDeposits = new map<string,decimal>();
                if(mapBankActRelatedAccounts.get(objBA.Account__c) != null && mapBankActRelatedAccounts.get(objBA.Account__c).Bank_Accounts1__r != null){
                    for(Bank_Account__c objBankAct : mapBankActRelatedAccounts.get(objBA.Account__c).Bank_Accounts1__r){
                    	if(objBankAct.Bank_Account_Number__c != Null && BankActNos.contains(objBankAct.Bank_Account_Number__c) == false)
                        	BankActNos += ''+objBankAct.Bank_Account_Number__c+',';
                        if(objBankAct.Sys_Bank_Name__c != null && !BankNames.contains(objBankAct.Sys_Bank_Name__c))
                        	BankNames += ''+objBankAct.Sys_Bank_Name__c+',';
                        dAllMonthsAvg += (objBankAct.Deposits_Minus_Transfers__c != null)?objBankAct.Deposits_Minus_Transfers__c:0;
                        mapMonthDeposits.put(objBankAct.Month__c+'-'+objBankAct.Year__c,objBankAct.Deposits_Minus_Transfers__c);
                        dTotBankStmts += (objBankAct.Number_of_NSFs__c != null)?objBankAct.Number_of_NSFs__c:0;
                        dADB += (objBankAct.Average_Daily_Balance__c != null)?objBankAct.Average_Daily_Balance__c:0;
                        iC++;
                    }
                }
                if(BankActNos != ''){
                	objAccount.Bank_Acct_Nums__c = BankActNos.substring(0, BankActNos.length()-1);
                }
                if(BankNames != '')
                	objAccount.Bank_Names__c = BankNames.substring(0, BankNames.length()-1);
                if(dTotBankStmts != null && dTotBankStmts!=0){
                    //objAccount.Number_Bank_Statements_Available__c = iC;//dTotBankStmts; commentted as per RaviChandra comments on 26th Aug,2013 by RB
                 	objAccount.NSFs_Avg__c =  dTotBankStmts/iC;  
                }
                objAccount.Number_Bank_Statements_Available__c = iC;//dTotBankStmts; commentted as per RaviChandra comments on 26th Aug,2013 by RB
                if(dAllMonthsAvg != null && dAllMonthsAvg != 0){
                    //dAllMonthsAvg = dAllMonthsAvg/iC;
                    objAccount.Monthly_Bank_Deposit_Avg_All__c = dAllMonthsAvg/iC;
                }
                if(dADB != null && dADB != 0){
                	objAccount.NDBs_Avg__c = dADB/iC;
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
                        objAccount.Monthly_Bank_Depopsit_Avg_Last_2_Months__c = d2MonthsAvg/2;
                }
                
                mapSummartAccountsToUpdate.put(objAccount.Id,objAccount);
            }
        }
        if(mapSummartAccountsToUpdate != null && mapSummartAccountsToUpdate.size() > 0)
            update mapSummartAccountsToUpdate.values();
    }
    
}