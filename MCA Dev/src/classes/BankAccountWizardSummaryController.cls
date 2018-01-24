/*
    Author : Brahmesh
    Class Name: BankAccountWizardSummaryController
    Description: Controller for the page BankAccountWizardSummaryVF
    Modifications: Vasu Takasi || 25th June 2013
*/
public with sharing class BankAccountWizardSummaryController {
    
    public list<BankAccountSummaryWrap> MonthlyListedBankActs {get;set;}
    public list<CreditCardSummaryWrap> MonthlyListedCreditCard {get;set;}
    public Account accObj {get;set;}
    Public list<selectOption> lstBankAccNos{get;set;}
    Public list<selectOption> lstCCMIDNos{get;set;}
    public string bankAccountNo{get;set;}
    public string ccMIDNo{get;set;}
    public BankAccountFinalSummaryWrap objBankAccFinalSum {get;set;}
    public CreditCardFinalSummaryWrap objCCFinalSum {get;set;}
    
    public string Accid;
    public string recordId{get;set;}
    
    public BankAccountWizardSummaryController(){
        Accid = '';
        accObj = new Account();
        if(ApexPages.CurrentPage().getParameters().get('id') != null){
            Accid = ApexPages.CurrentPage().getParameters().get('id');
        }
        BankAccountDetails();
         objBankAccFinalSum = new BankAccountFinalSummaryWrap();
         
        list<Bank_Account__c> lstbankAcc = [select id,name,Bank_Account_Number__c,Business_Owner_Name_Same_as_App__c,Average_Daily_Balance__c,
                                            Bank_Name__c,Deposits__c,Deposits_Minus_Transfers__c,Month__c,
                                            Month_Date__c,Address_Same_as_Biz_Home_Address__c,Notes__c,Number_of_Negative_Days__c,
                                            Number_of_NSFs__c,Omit_From_Summary__c ,Transfers_Disallowed__c,Year__c from Bank_Account__c where Month__c !=null AND Year__c!=null And  account__c =:accId order by Month__c,Year__c ];                                            
        prepareDataForBankAccountSummary(lstbankAcc);
                        
        list<Credit_Card__c> lstCreditCards = [select id,name,Address_Same_as_App__c,Average_Ticket__c,MID_Account_Number__c,
                                           Month__c,Month_Date__c,Name_Same_as_App__c,Number_of_Transactions_All__c,
                                           Number_of_Transactions_AMEX_only__c,Processor_Name__c,Total_Net_Processed_All__c,
                                           Total_Net_Processed_AMEX_only__c,Year__c,Omit_From_Summary__c  from Credit_Card__c where Month__c !=null AND Year__c!=null AND  account__c = :accId order by Month__c,Year__c ];
        prepareDataForCreditCardSummary(lstCreditCards);
        
        lstBankAccNos=new list<selectOption>();
        lstBankAccNos.add(new selectOption('--None--','--None--'));
        set<string> setBankAccNos=New set<string>();
        for(Bank_Account__c objBA:lstbankAcc){
            
            if(objBA.Bank_Account_Number__c != null)
                setBankAccNos.add(objBA.Bank_Account_Number__c);
        }
       
        list<string>lstBankAccNosStr=new list<string>();
         lstBankAccNosStr.addAll(setBankAccNos);
         lstBankAccNosStr.sort();
        for(string s:lstBankAccNosStr){
            lstBankAccNos.add(new selectOption(s,s));
        }
        
        lstCCMIDNos=new list<selectoption>();
        lstCCMIDNos.add(New selectoption('--None--','--None--'));
        set<string> setCCMIDNos=New set<string>();
        for(Credit_Card__c objCC:lstCreditCards){
            
            if(objCC.MID_Account_Number__c != null)
                setCCMIDNos.add(objCC.MID_Account_Number__c);
        }
       
        list<string>lstCCMIDNosStr=new list<string>();
        lstCCMIDNosStr.addAll(setCCMIDNos);
        lstCCMIDNosStr.sort();
        for(string s:lstCCMIDNosStr){
            lstCCMIDNos.add(New selectoption(s,s));
        }
    }
    
     
     // Method Name : BankAccountDetails
     //Descreption : This method will be used to display Backaccout details on the page
    
     public void BankAccountDetails(){
        
        
        if(Accid != ''){
            try{
            accObj = [select id,name
                            //,of_Avg_CC_Used__c ,Application_Status__c,Avg_Gross_Sales_Used__c
                            from Account where id=:Accid];
            }catch(exception e){}
        }
     }
    
    
     // Method Name : prepareDataForBankAccountSummary
     //Descreption : This method will be usefull to prepare Bank Account data to display on the page
    public void prepareDataForBankAccountSummary(list<Bank_Account__c> lstbankAcc)
    {
        
        MonthlyListedBankActs = new list<BankAccountSummaryWrap>();
        //system.debug('******lstbankacc---->'+lstbankacc);
        map<string,list<Bank_Account__c>> mpMonthAndlstBankAcc = new map<string,list<Bank_Account__c>>();
        
        BankAccountSummaryWrap objWrap;
        
        //Getting Month picklist values dynamically
        Schema.DescribeFieldResult accoutMonth = Bank_Account__c.Month__c.getDescribe();
        list<Schema.PicklistEntry> accoutMonthValues = accoutMonth.getPicklistValues();
        list<string> lstMonths = new list<string>();
        if(accoutMonthValues != null && accoutMonthValues.size() > 0){
            for(Schema.PicklistEntry objpkList :accoutMonthValues){
                lstMonths.add(objpkList.getValue());
            }
        }
        
        //Getting Year picklist values dynamically
        Schema.DescribeFieldResult accoutYear = Bank_Account__c.Year__c.getDescribe();
        list<Schema.PicklistEntry> accoutYearVal = accoutYear.getPicklistValues();
        list<string> lstYear = new list<string>();
        if(accoutYearVal != null && accoutYearVal.size() > 0){
            for(Schema.PicklistEntry objpkList :accoutYearVal){
                lstYear.add(objpkList.getValue());
            }
        }
        //system.debug('***lstMonths-->'+lstMonths);
        //system.debug('***lstYear-->'+lstYear);
        
        list<string> lstMonthYear = new list<string>();
        for(string year : lstYear){
            for(string month : lstMonths){
                string strtemp = month+'-'+year;
                lstMonthYear.add(strtemp);
            }
        }
        //system.debug('***lstMonthYear-->'+lstMonthYear);
        
        
        for( Bank_Account__c bankAccObj : lstbankacc){
            string MonthYearTemp = bankAccObj.Month__c+'-'+bankAccObj.Year__c;
            if(mpMonthAndlstBankAcc.get(MonthYearTemp) != null){
                list<Bank_Account__c> lstTemp = mpMonthAndlstBankAcc.get(MonthYearTemp);
                lstTemp.add(bankAccObj);
                mpMonthAndlstBankAcc.put(MonthYearTemp,lstTemp);
                
            }else{
                list<Bank_Account__c> lstTemp = new list<Bank_Account__c>();
                lstTemp.add(bankAccObj);
                mpMonthAndlstBankAcc.put(MonthYearTemp,lstTemp);
            }
        }
        // These map are used to prepare total of every month of year
        map<string,decimal> mpMonthYearDepositVal = new map<string,decimal>();
        map<string,decimal> mpMonthYearAvgDailyBal = new map<string,decimal>();
        map<string,integer> mpMonthYearNegativeDays = new map<string,integer>();
        map<string,integer> mpMonthYearNFSs = new map<string,integer>();
        
        //These map are used to prepare total of every month of year including omit from summary
         map<string,decimal> mpMonthYearDepositValOmitFS = new map<string,decimal>();
        map<string,decimal> mpMonthYearAvgDailyBalOmitFS = new map<string,decimal>();
        map<string,integer> mpMonthYearNegativeDaysOmitFS = new map<string,integer>();
        map<string,integer> mpMonthYearNFSsOmitFS = new map<string,integer>();
        
        if(lstMonthYear != null && lstMonthYear.size() > 0){
            for(string MonthYear : lstMonthYear){
                if(mpMonthAndlstBankAcc.get(MonthYear) != null && mpMonthAndlstBankAcc.get(MonthYear).size() > 0){
                    decimal depositVal=0.0;
                    decimal avgDailVal=0.0;
                    integer negaticveDays=0;
                    integer NFsDays=0;
                    
                    decimal depositValOmitFS=0.0;
                    decimal avgDailValOmitFS=0.0;
                    integer negaticveDaysOmitFS=0;
                    integer NFsDaysOmitFS=0;
                    
                    for( Bank_Account__c objbank : mpMonthAndlstBankAcc.get(MonthYear)){
                        if(objbank.Omit_From_Summary__c == false){
                             /**************** Hari Commeneted As per Trello Comments from HENRY*********/
                            //  if(objbank.Deposits__c != null)
                            //     depositVal += objbank.Deposits__c;
                            
                            if(objbank.Deposits_Minus_Transfers__c != null)
                                depositVal += objbank.Deposits_Minus_Transfers__c;
                          /*******************************Hari Changed As per Henry Date:31-12-2013******/
                            if(objbank.Average_Daily_Balance__c != null)
                                avgDailVal += objbank.Average_Daily_Balance__c;
                            if(objbank.Number_of_Negative_Days__c != null)
                                negaticveDays += integer.valueOf(objbank.Number_of_Negative_Days__c);
                            if(objbank.Number_of_NSFs__c != null)
                                NFsDays += integer.valueOf(objbank.Number_of_NSFs__c);
                        
                            /**************** Hari Commeneted As per Trello Comments from HENRY*********/
                            //  if(objbank.Deposits__c != null)
                            //     depositValOmitFS += objbank.Deposits__c;
                            
                            if(objbank.Deposits_Minus_Transfers__c != null)
                                depositValOmitFS += objbank.Deposits_Minus_Transfers__c;
                          /*******************************Hari Changed As per Henry Date:31-12-2013******/
                           
                            if(objbank.Average_Daily_Balance__c != null)
                                avgDailValOmitFS += objbank.Average_Daily_Balance__c;
                            if(objbank.Number_of_Negative_Days__c != null)
                                negaticveDaysOmitFS += integer.valueOf(objbank.Number_of_Negative_Days__c);
                            if(objbank.Number_of_NSFs__c != null)
                                NFsDaysOmitFS += integer.valueOf(objbank.Number_of_NSFs__c);
                                
                    }}
                    mpMonthYearDepositVal.put(MonthYear,depositVal);
                    mpMonthYearAvgDailyBal.put(MonthYear,avgDailVal);               
                    mpMonthYearNegativeDays.put(MonthYear,negaticveDays);
                    mpMonthYearNFSs.put(MonthYear,NFsDays);
                    
                    mpMonthYearDepositValOmitFS.put(MonthYear,depositValOmitFS);
                    mpMonthYearAvgDailyBalOmitFS.put(MonthYear,avgDailValOmitFS);               
                    mpMonthYearNegativeDaysOmitFS.put(MonthYear,negaticveDaysOmitFS);
                    mpMonthYearNFSsOmitFS.put(MonthYear,NFsDaysOmitFS);
                }
            }
        }
                        
        if(mpMonthAndlstBankAcc != null && mpMonthAndlstBankAcc.size() > 0){
            integer indexVal = 0;
            for(string MonthYear : lstMonthYear){
                system.debug('****MonthYear---'+MonthYear);
                if(mpMonthAndlstBankAcc.get(MonthYear) != null){
                    system.debug('MonthYear is : '+MonthYear);
                    system.debug('mpMonthAndlstBankAcc.get(MonthYear) is : '+mpMonthAndlstBankAcc.get(MonthYear));
                    objWrap = new BankAccountSummaryWrap();
                    objWrap.index = indexVal;
                    objWrap.selectedMonth = MonthYear.split('-')[0];
                    objWrap.selectedYear = MonthYear.split('-')[1];
                    objWrap.totDeposit = mpMonthYearDepositVal.get(MonthYear);
                    objWrap.totAvgDailyBalance = mpMonthYearAvgDailyBal.get(MonthYear);
                    objWrap.totNoOfNegativeDays = mpMonthYearNegativeDays.get(MonthYear);
                    objWrap.totNoOfNFSs = mpMonthYearNFSs.get(MonthYear);
                    objWrap.currentMonthAccounts = mpMonthAndlstBankAcc.get(MonthYear);
                    
                    objWrap.totDepositOmitFS = mpMonthYearDepositValOmitFS.get(MonthYear);
                    objWrap.totAvgDailyBalanceOmitFS = mpMonthYearAvgDailyBalOmitFS.get(MonthYear);
                    objWrap.totNoOfNegativeDaysOmitFS = mpMonthYearNegativeDaysOmitFS.get(MonthYear);
                    objWrap.totNoOfNFSsOmitFS = mpMonthYearNFSsOmitFS.get(MonthYear);
                    
                    MonthlyListedBankActs.add(objWrap);
                    indexVal++;
                }else{
                    if(MonthlyListedBankActs != null && MonthlyListedBankActs.size() > 0 ){//we are not adding wrapper object to list if there is no records in the previous month
                        objWrap = new BankAccountSummaryWrap();
                        objWrap.index = indexVal;
                        objWrap.selectedMonth = MonthYear.split('-')[0];
                        objWrap.selectedYear = MonthYear.split('-')[1];
                        
                        objWrap.totDeposit = (mpMonthYearDepositVal.get(MonthYear) != null)?mpMonthYearDepositVal.get(MonthYear):0.0;
                        objWrap.totAvgDailyBalance = (mpMonthYearAvgDailyBal.get(MonthYear) != null)?mpMonthYearAvgDailyBal.get(MonthYear):0.0;
                        objWrap.totNoOfNegativeDays = (mpMonthYearNegativeDays.get(MonthYear) != null)?mpMonthYearNegativeDays.get(MonthYear):0;
                        objWrap.totNoOfNFSs = (mpMonthYearNFSs.get(MonthYear) != null)?mpMonthYearNFSs.get(MonthYear):0;
                        
                         objWrap.totDepositOmitFS = (mpMonthYearDepositValOmitFS.get(MonthYear) != null)?mpMonthYearDepositValOmitFS.get(MonthYear):0.0;
                        objWrap.totAvgDailyBalanceOmitFS = (mpMonthYearAvgDailyBalOmitFS.get(MonthYear) != null)?mpMonthYearAvgDailyBalOmitFS.get(MonthYear):0.0;
                        objWrap.totNoOfNegativeDaysOmitFS = (mpMonthYearNegativeDaysOmitFS.get(MonthYear) != null)?mpMonthYearNegativeDaysOmitFS.get(MonthYear):0;
                        objWrap.totNoOfNFSsOmitFS = (mpMonthYearNFSsOmitFS.get(MonthYear) != null)?mpMonthYearNFSsOmitFS.get(MonthYear):0;
                        
                        MonthlyListedBankActs.add(objWrap);
                        indexVal++;
                    }
                }
                
            }
            if(MonthlyListedBankActs != null && MonthlyListedBankActs.size() > 0 ){
                for(integer index = MonthlyListedBankActs.size()-1 ; index >= 0 ; index--){
                    if(MonthlyListedBankActs[index] != null && ( MonthlyListedBankActs[index].currentMonthAccounts == null)){
                        MonthlyListedBankActs.remove(index);
                    }else{
                        break;
                    }
                }
            }
        }
        //system.debug('MonthlyListedBankActs is : '+MonthlyListedBankActs);
        //calculating BankAccountFinal Summary
         objBankAccFinalSum = new BankAccountFinalSummaryWrap();
         objBankAccFinalSum.totalDeposites=0;
         objBankAccFinalSum.totalAvgDailyBal=0;
         objBankAccFinalSum.totalNoOfNegativeDays=0;
         objBankAccFinalSum.totalNoOfNFS=0;
         
         datetime today=system.today(); 
          decimal avgTD=0;
          decimal avgTVDB=0;
          integer avgTND=0;
          integer avgTNFS=0;
          
          decimal lastmonthDep=0;
          decimal lastmonthAVB=0;
          decimal lastmonthNND=0;
          decimal lastmonthNFS=0;
            
         for(BankAccountSummaryWrap objBASW : MonthlyListedBankActs){
            objBankAccFinalSum.totalDeposites +=objBASW.totDepositOmitFS;
            objBankAccFinalSum.totalAvgDailyBal +=objBASW.totAvgDailyBalanceOmitFS;
            objBankAccFinalSum.totalNoOfNegativeDays +=objBASW.totNoOfNegativeDaysOmitFS;
            objBankAccFinalSum.totalNoOfNFS +=objBASW.totNoOfNFSsOmitFS;
            datetime lastMonthDt=today.addMonths(-1);
            datetime beforeLastMonthDt=today.addMonths(-2);
            
            if((lastMonthDt.format('MMMMM')).toUpperCase() == (objBASW.selectedMonth).toUpperCase() && string.valueOf(lastMonthDt.year()) == objBASW.selectedyear ){
                avgTD +=objBASW.totDepositOmitFS;
                avgTVDB +=objBASW.totAvgDailyBalanceOmitFS;
                avgTND +=objBASW.totNoOfNegativeDaysOmitFS;
                avgTNFS +=objBASW.totNoOfNFSsOmitFS;
                
               /*  lastmonthDep +=objBASW.totDepositOmitFS;
                 lastmonthAVB +=objBASW.totAvgDailyBalanceOmitFS;
                 lastmonthNND +=objBASW.totNoOfNegativeDaysOmitFS;
                 lastmonthNFS +=objBASW.totNoOfNFSsOmitFS;*/
            }
           /* if((beforeLastMonthDt.format('MMMMM')).toUpperCase() == (objBASW.selectedMonth).toUpperCase() && string.valueOf(beforeLastMonthDt.year()) == objBASW.selectedyear ){
                avgTD +=objBASW.totDepositOmitFS;
                avgTVDB +=objBASW.totAvgDailyBalanceOmitFS;
                avgTND +=objBASW.totNoOfNegativeDaysOmitFS;
                avgTNFS +=objBASW.totNoOfNFSsOmitFS;
            }*/
            
         }
         if(MonthlyListedBankActs.size() > 0){
            integer size=MonthlyListedBankActs.size()-1; 
            
            objBankAccFinalSum.avgTotalDeposites = objBankAccFinalSum.totalDeposites / MonthlyListedBankActs.size();
            objBankAccFinalSum.avgTotalAvgDailyBal = objBankAccFinalSum.totalAvgDailyBal / MonthlyListedBankActs.size();
            objBankAccFinalSum.avgTotalNoOfNegativeDays = objBankAccFinalSum.totalNoOfNegativeDays / MonthlyListedBankActs.size();
            objBankAccFinalSum.avgTotalNoOfNFS = objBankAccFinalSum.totalNoOfNFS / MonthlyListedBankActs.size();
            
            lastmonthDep =MonthlyListedBankActs[size].totDepositOmitFS;
            lastmonthAVB =MonthlyListedBankActs[size].totAvgDailyBalanceOmitFS;
            lastmonthNND =MonthlyListedBankActs[size].totNoOfNegativeDaysOmitFS;
            lastmonthNFS =MonthlyListedBankActs[size].totNoOfNFSsOmitFS;
         }
        /*objBankAccFinalSum.lastTwoMonthsAvgTD = avgTD/2;
        objBankAccFinalSum.lastTwoMonthsAvgTVDB = avgTVDB/2;
        objBankAccFinalSum.lastTwoMonthsAvgTND = avgTND/2;
        objBankAccFinalSum.lastTwoMonthsAvgTNFS = avgTNFS/2;*/
        objBankAccFinalSum.lastTwoMonthsAvgTD = avgTD;
        objBankAccFinalSum.lastTwoMonthsAvgTVDB = avgTVDB;
        objBankAccFinalSum.lastTwoMonthsAvgTND = avgTND;
        objBankAccFinalSum.lastTwoMonthsAvgTNFS = avgTNFS;
        
        //calculating TREND-------
        decimal DepGrossPercent=0;
        decimal AVBGrossPercent=0;
        decimal NNDGrossPercent=0;
        decimal NFSGrossPercent=0;
        //trend Td calculation
        if(objBankAccFinalSum.avgTotalDeposites != 0 && objBankAccFinalSum.lastTwoMonthsAvgTD != Null && objBankAccFinalSum.avgTotalDeposites != Null)
            DepGrossPercent = (objBankAccFinalSum.lastTwoMonthsAvgTD/objBankAccFinalSum.avgTotalDeposites)*100;
        if(DepGrossPercent > 120)
            objBankAccFinalSum.trendTD ='UP';
        else if(DepGrossPercent <= 120 && DepGrossPercent >= 80)
            objBankAccFinalSum.trendTD ='FLAT';
        else if(DepGrossPercent < 80 )
            objBankAccFinalSum.trendTD ='DOWN';
        //trend Tvb calculation
            if(objBankAccFinalSum.avgTotalAvgDailyBal != 0 && objBankAccFinalSum.lastTwoMonthsAvgTVDB != Null && objBankAccFinalSum.avgTotalAvgDailyBal != Null)
                AVBGrossPercent = (objBankAccFinalSum.lastTwoMonthsAvgTVDB/objBankAccFinalSum.avgTotalAvgDailyBal)*100;
            if(AVBGrossPercent > 120)
                objBankAccFinalSum.trendTVDB ='UP';
            else if(AVBGrossPercent <= 120 && AVBGrossPercent >= 80)
                objBankAccFinalSum.trendTVDB ='FLAT';
            else if(AVBGrossPercent < 80 )
                objBankAccFinalSum.trendTVDB ='DOWN';
        //trend Tnd calculation
            if(objBankAccFinalSum.avgTotalNoOfNegativeDays != 0 && objBankAccFinalSum.lastTwoMonthsAvgTND != Null && objBankAccFinalSum.avgTotalNoOfNegativeDays != Null)
                 NNDGrossPercent = (objBankAccFinalSum.lastTwoMonthsAvgTND/objBankAccFinalSum.avgTotalNoOfNegativeDays)*100;
            if(NNDGrossPercent > 120)
                objBankAccFinalSum.trendTND ='UP';
            else if(NNDGrossPercent <= 120 && NNDGrossPercent >= 80)
                objBankAccFinalSum.trendTND ='FLAT';
            else if(NNDGrossPercent < 80 )
                objBankAccFinalSum.trendTND ='DOWN';
        //trend NFS calculation
            if(objBankAccFinalSum.avgTotalNoOfNFS != 0 && objBankAccFinalSum.lastTwoMonthsAvgTNFS != Null && objBankAccFinalSum.avgTotalNoOfNFS != Null)
                NFSGrossPercent = (objBankAccFinalSum.lastTwoMonthsAvgTNFS/objBankAccFinalSum.avgTotalNoOfNFS)*100;
            if(NFSGrossPercent > 120)
                objBankAccFinalSum.trendTNFS ='UP';
            else if(NFSGrossPercent <= 120 && NFSGrossPercent >= 80)
                objBankAccFinalSum.trendTNFS ='FLAT';
            else if(NFSGrossPercent < 80 )
                objBankAccFinalSum.trendTNFS ='DOWN';
        /*if(lastmonthDep != 0){
        DepGrossPercent=((objBankAccFinalSum.avgTotalDeposites-lastmonthDep)/lastmonthDep)*100;
        if(lastmonthDep <= 120)
            objBankAccFinalSum.trendTD ='FLAT';
        else if(DepGrossPercent >= 120){
            objBankAccFinalSum.trendTD ='UP';
        }
        else if(DepGrossPercent < 120){
            objBankAccFinalSum.trendTD ='DOWN';
        }
       }
       else 
         objBankAccFinalSum.trendTD ='FLAT';
        //---------
        if(lastmonthAVB !=0){
            AVBGrossPercent=((objBankAccFinalSum.avgTotalAvgDailyBal-lastmonthAVB)/lastmonthAVB)*100;
            if(lastmonthAVB <= 120)
                objBankAccFinalSum.trendTVDB='FLAT';
            else if(AVBGrossPercent >= 120){
            objBankAccFinalSum.trendTVDB ='UP';
        }
        else if(AVBGrossPercent < 120){
            objBankAccFinalSum.trendTVDB  ='DOWN';
         }  
        } 
        else
        objBankAccFinalSum.trendTVDB='FLAT';
        //-----------
         if(lastmonthNND !=0){
            NNDGrossPercent=((objBankAccFinalSum.avgTotalNoOfNegativeDays-lastmonthNND)/lastmonthNND)*100;
            if(lastmonthNND <=120)
                objBankAccFinalSum.trendTND='FLAT';
            else if(NNDGrossPercent >= 120){
            objBankAccFinalSum.trendTND ='UP';
        }
        else if(NNDGrossPercent < 120){
            objBankAccFinalSum.trendTND  ='DOWN';
         }  
        } 
        else
        objBankAccFinalSum.trendTND='FLAT';
        //-----
       // system.debug('========================='+lastmonthNFS);
       if(lastmonthNFS !=0){
            NFSGrossPercent=((objBankAccFinalSum.avgTotalNoOfNFS-lastmonthNFS)/lastmonthNFS)*100;
            if(lastmonthNFS <= 120)
                objBankAccFinalSum.trendTNFS='FLAT';
            else if(NFSGrossPercent >= 120){
            objBankAccFinalSum.trendTNFS ='UP';
        }
        else if(NFSGrossPercent < 120){
            objBankAccFinalSum.trendTNFS  ='DOWN';
         }  
        } 
        else
        objBankAccFinalSum.trendTNFS='FLAT';*/
    }
    
    
     // Method Name : prepareDataForCreditCardSummary
     // Descreption : This method will be usefull to prepare Credit Card data to display on the page
    
    public void prepareDataForCreditCardSummary(list<Credit_Card__c> lstCreditCards){
        MonthlyListedCreditCard = new list<CreditCardSummaryWrap>();
        map<string,list<Credit_Card__c>> mpMonthAndlstCreditCard = new map<string,list<Credit_Card__c>>();
        
        CreditCardSummaryWrap objWrap;
        
        //Getting Month picklist values dynamically
        Schema.DescribeFieldResult cardMonth = Credit_Card__c.Month__c.getDescribe();
        list<Schema.PicklistEntry> cardMonthValues = cardMonth.getPicklistValues();
        list<string> lstMonths = new list<string>();
        if(cardMonthValues != null && cardMonthValues.size() > 0){
            for(Schema.PicklistEntry objpkList :cardMonthValues){
                lstMonths.add(objpkList.getValue());
            }
        }
        
        //Getting Year picklist values dynamically
        Schema.DescribeFieldResult cardYear = Credit_Card__c.Year__c.getDescribe();
        list<Schema.PicklistEntry> cardYearVal = cardYear.getPicklistValues();
        list<string> lstYear = new list<string>();  
        if(cardYearVal != null && cardYearVal.size() > 0){
            for(Schema.PicklistEntry objpkList :cardYearVal){
                lstYear.add(objpkList.getValue());
            }
        }
        
        list<string> lstMonthYear = new list<string>();
        if(lstYear != null && lstYear.size() > 0){
            for(string year : lstYear){
              if(lstMonths != null && lstMonths.size() > 0){    
                    for(string month : lstMonths){
                        string strtemp = month+'-'+year;
                        lstMonthYear.add(strtemp);
                    }
              }
            }
        }
        
        if(lstCreditCards != null && lstCreditCards.size() > 0 ){
            for( Credit_Card__c bankAccObj : lstCreditCards){
                string MonthYearTemp = bankAccObj.Month__c+'-'+bankAccObj.Year__c;
                if(mpMonthAndlstCreditCard.get(MonthYearTemp) != null){
                    list<Credit_Card__c> lstTemp = mpMonthAndlstCreditCard.get(MonthYearTemp);
                    lstTemp.add(bankAccObj);
                    mpMonthAndlstCreditCard.put(MonthYearTemp,lstTemp);
                    
                }else{
                    list<Credit_Card__c> lstTemp = new list<Credit_Card__c>();
                    lstTemp.add(bankAccObj);
                    mpMonthAndlstCreditCard.put(MonthYearTemp,lstTemp);
                }
            }
        }
        
        map<string,decimal> mpMonthYearNetProcess = new map<string,decimal>();
        map<string,decimal> mpMonthYearNoOfTransactions = new map<string,decimal>();
        map<string,integer> mpMonthYearProcessedAMEX = new map<string,integer>();
        map<string,integer> mpMonthYearNoOfTransationsAMEX = new map<string,integer>();
        map<string,decimal> mpMonthYearAVGTickets = new map<string,decimal>();
        
        map<string,decimal> mpMonthYearNetProcessOmitFS = new map<string,decimal>();
        map<string,decimal> mpMonthYearNoOfTransactionsOmitFS = new map<string,decimal>();
        map<string,integer> mpMonthYearProcessedAMEXOmitFS = new map<string,integer>();
        map<string,integer> mpMonthYearNoOfTransationsAMEXOmitFS = new map<string,integer>();
        map<string,decimal> mpMonthYearAVGTicketsOmitFS = new map<string,decimal>();
        
        if(lstMonthYear != null && lstMonthYear.size() > 0){
            for(string MonthYear : lstMonthYear){
                if(mpMonthAndlstCreditCard.get(MonthYear) != null && mpMonthAndlstCreditCard.get(MonthYear).size() > 0){
                    decimal netProcessVal = 0.0;
                    decimal noOfTransactionVal = 0.0;
                    integer processedAMEX = 0;
                    integer transationsAMEX = 0;
                    decimal avgTickt = 0.0;
                    
                     decimal netProcessValOmitFS = 0.0;
                    decimal noOfTransactionValOmitFS = 0.0;
                    integer processedAMEXOmitFS = 0;
                    integer transationsAMEXOmitFS = 0;
                    decimal avgTicktOmitFS = 0.0;
                    
                    for( Credit_Card__c objCredit : mpMonthAndlstCreditCard.get(MonthYear)){
                         if(objCredit.Omit_From_Summary__c == false){
                            if(objCredit.Total_Net_Processed_All__c != null)
                                netProcessVal += objCredit.Total_Net_Processed_All__c;
                            if(objCredit.Number_of_Transactions_All__c != null)
                                noOfTransactionVal += objCredit.Number_of_Transactions_All__c;
                            if(objCredit.Total_Net_Processed_AMEX_only__c != null)
                                processedAMEX += integer.valueOf(objCredit.Total_Net_Processed_AMEX_only__c);
                            if(objCredit.Number_of_Transactions_AMEX_only__c != null)
                                transationsAMEX += integer.valueOf(objCredit.Number_of_Transactions_AMEX_only__c);
                            if(objCredit.Average_Ticket__c != null)
                                avgTickt += objCredit.Average_Ticket__c;
                        
                         
                            if(objCredit.Total_Net_Processed_All__c != null)
                                netProcessValOmitFS += objCredit.Total_Net_Processed_All__c;
                            if(objCredit.Number_of_Transactions_All__c != null)
                                noOfTransactionValOmitFS += objCredit.Number_of_Transactions_All__c;
                            if(objCredit.Total_Net_Processed_AMEX_only__c != null)
                                processedAMEXOmitFS += integer.valueOf(objCredit.Total_Net_Processed_AMEX_only__c);
                            if(objCredit.Number_of_Transactions_AMEX_only__c != null)
                                transationsAMEXOmitFS += integer.valueOf(objCredit.Number_of_Transactions_AMEX_only__c);
                            if(objCredit.Average_Ticket__c != null)
                                avgTicktOmitFS += objCredit.Average_Ticket__c;    
                    } }
                    mpMonthYearNetProcess.put(MonthYear,netProcessVal);
                    mpMonthYearNoOfTransactions.put(MonthYear,noOfTransactionVal);              
                    mpMonthYearProcessedAMEX.put(MonthYear,processedAMEX);
                    mpMonthYearNoOfTransationsAMEX.put(MonthYear,transationsAMEX);
                    mpMonthYearAVGTickets.put(MonthYear,avgTickt);
                    
                    mpMonthYearNetProcessOmitFS.put(MonthYear,netProcessValOmitFS);
                    mpMonthYearNoOfTransactionsOmitFS.put(MonthYear,noOfTransactionValOmitFS);              
                    mpMonthYearProcessedAMEXOmitFS.put(MonthYear,processedAMEXOmitFS);
                    mpMonthYearNoOfTransationsAMEXOmitFS.put(MonthYear,transationsAMEXOmitFS);
                    mpMonthYearAVGTicketsOmitFS.put(MonthYear,avgTicktOmitFS);
                }
            }
        }
        
        if(mpMonthAndlstCreditCard != null && mpMonthAndlstCreditCard.size() > 0){
            integer indexVal = 0;
            for(string MonthYear : lstMonthYear){
                //system.debug('****MonthYear---'+MonthYear);
                if(mpMonthAndlstCreditCard.get(MonthYear) != null){
                   // system.debug('MonthYear is : '+MonthYear);
                    //system.debug('mpMonthAndlstBankAcc.get(MonthYear) is : '+mpMonthAndlstCreditCard.get(MonthYear));
                    objWrap = new CreditCardSummaryWrap();
                    objWrap.index = indexVal;
                    objWrap.selectedMonth = MonthYear.split('-')[0];
                    objWrap.selectedYear = MonthYear.split('-')[1];
                    
                    objWrap.totNetProcess = mpMonthYearNetProcess.get(MonthYear);
                    objWrap.totNoOfTransactions = mpMonthYearNoOfTransactions.get(MonthYear);
                    objWrap.totProcessedAMEX = mpMonthYearProcessedAMEX.get(MonthYear);
                    objWrap.totNoOfTransationsAMEX = mpMonthYearNoOfTransationsAMEX.get(MonthYear);
                    objWrap.currentMonthCredits = mpMonthAndlstCreditCard.get(MonthYear);
                    objWrap.totAvgTicket = mpMonthYearAVGTickets.get(MonthYear);
                    
                    objWrap.totNetProcessOmitFS = mpMonthYearNetProcessOmitFS.get(MonthYear);
                    objWrap.totNoOfTransactionsOmitFS = mpMonthYearNoOfTransactionsOmitFS.get(MonthYear);
                    objWrap.totProcessedAMEXOmitFS = mpMonthYearProcessedAMEXOmitFS.get(MonthYear);
                    objWrap.totNoOfTransationsAMEXOmitFS = mpMonthYearNoOfTransationsAMEXOmitFS.get(MonthYear);
                    objWrap.totAvgTicketOmitFS = mpMonthYearAVGTicketsOmitFS.get(MonthYear);
                    
                    MonthlyListedCreditCard.add(objWrap);
                    indexVal++;
                }else{
                    if(MonthlyListedCreditCard != null && MonthlyListedCreditCard.size() > 0){
                        objWrap = new CreditCardSummaryWrap();
                        objWrap.index = indexVal;
                        objWrap.selectedMonth = MonthYear.split('-')[0];
                        objWrap.selectedYear = MonthYear.split('-')[1];
                        
                        objWrap.totNetProcess = (mpMonthYearNetProcess.get(MonthYear) != null)?mpMonthYearNetProcess.get(MonthYear):0.0;
                        objWrap.totNoOfTransactions = (mpMonthYearNoOfTransactions.get(MonthYear) != null)?mpMonthYearNoOfTransactions.get(MonthYear):0.0;
                        objWrap.totProcessedAMEX = (mpMonthYearProcessedAMEX.get(MonthYear) != null)?mpMonthYearProcessedAMEX.get(MonthYear):0;
                        objWrap.totNoOfTransationsAMEX = (mpMonthYearNoOfTransationsAMEX.get(MonthYear) != null)?mpMonthYearNoOfTransationsAMEX.get(MonthYear):0;
                        objWrap.totAvgTicket = (mpMonthYearAVGTickets.get(MonthYear) != null)?mpMonthYearAVGTickets.get(MonthYear):0;
                        
                        objWrap.totNetProcessOmitFS = (mpMonthYearNetProcessOmitFS.get(MonthYear) != null)?mpMonthYearNetProcessOmitFS.get(MonthYear):0.0;
                        objWrap.totNoOfTransactionsOmitFS = (mpMonthYearNoOfTransactionsOmitFS.get(MonthYear) != null)?mpMonthYearNoOfTransactionsOmitFS.get(MonthYear):0.0;
                        objWrap.totProcessedAMEXOmitFS = (mpMonthYearProcessedAMEXOmitFS.get(MonthYear) != null)?mpMonthYearProcessedAMEXOmitFS.get(MonthYear):0;
                        objWrap.totNoOfTransationsAMEXOmitFS = (mpMonthYearNoOfTransationsAMEXOmitFS.get(MonthYear) != null)?mpMonthYearNoOfTransationsAMEXOmitFS.get(MonthYear):0;
                        objWrap.totAvgTicketOmitFS = (mpMonthYearAVGTicketsOmitFS.get(MonthYear) != null)?mpMonthYearAVGTicketsOmitFS.get(MonthYear):0;
                        
                        MonthlyListedCreditCard.add(objWrap);
                        indexVal++;
                    }
                }
                
            }
            if(MonthlyListedCreditCard != null && MonthlyListedCreditCard.size() > 0 ){
                for(integer index = MonthlyListedCreditCard.size()-1 ; index >= 0 ; index--){
                    if(MonthlyListedCreditCard[index] != null && ( MonthlyListedCreditCard[index].currentMonthCredits == null)){
                        MonthlyListedCreditCard.remove(index);
                    }else{
                        break;
                    }
                }
            }
        }
        
        //system.debug('******MonthlyListedCreditCard-----'+MonthlyListedCreditCard);
        //calculating CreditCardFinal Summary
         objCCFinalSum = new CreditCardFinalSummaryWrap();
         objCCFinalSum.totalDeposites=0;
         objCCFinalSum.totalAvgDailyBal=0;
         objCCFinalSum.totalNoOfNegativeDays=0;
         objCCFinalSum.totalNoOfNFS=0;
         objCCFinalSum.totAvgTickets=0;
         
         datetime today=system.today(); 
          decimal avgTD=0;
          decimal avgTVDB=0;
          integer avgTND=0;
          integer avgTNFS=0;
          
          decimal lastmonthTNPA=0;
          decimal lastmonthNT=0;
          decimal lastmonthTNPAO=0;
          decimal lastmonthNTAO=0;
            
         for(CreditCardSummaryWrap objBASW : MonthlyListedCreditCard){
            
            objCCFinalSum.totalDeposites +=objBASW.totNetProcessOmitFS;
            objCCFinalSum.totalAvgDailyBal +=objBASW.totNoOfTransactionsOmitFS;
            objCCFinalSum.totalNoOfNegativeDays +=objBASW.totProcessedAMEXOmitFS;
            objCCFinalSum.totalNoOfNFS +=objBASW.totNoOfTransationsAMEXOmitFS;
            objCCFinalSum.totAvgTickets +=  objBASW.totAvgTicketOmitFS;
            
            datetime lastMonthDt=today.addMonths(-1);
            datetime beforeLastMonthDt=today.addMonths(-2);
            
            if((lastMonthDt.format('MMMMM')).toUpperCase() == (objBASW.selectedMonth).toUpperCase() && string.valueOf(lastMonthDt.year()) == objBASW.selectedyear ){
                avgTD +=objBASW.totNetProcessOmitFS;
                avgTVDB +=objBASW.totNoOfTransactionsOmitFS;
                avgTND +=objBASW.totProcessedAMEXOmitFS;
                avgTNFS +=objBASW.totNoOfTransationsAMEXOmitFS;
                
              //  lastmonthTNPA +=objBASW.totNetProcessOmitFS;
              //  lastmonthNT +=objBASW.totNoOfTransactionsOmitFS;
              //  lastmonthTNPA +=objBASW.totProcessedAMEXOmitFS;
              //  lastmonthNTAO +=objBASW.totNoOfTransationsAMEXOmitFS;
            }
           /* if((beforeLastMonthDt.format('MMMMM')).toUpperCase() == (objBASW.selectedMonth).toUpperCase() && string.valueOf(beforeLastMonthDt.year()) == objBASW.selectedyear ){
                avgTD +=objBASW.totNetProcessOmitFS;
                avgTVDB +=objBASW.totNoOfTransactionsOmitFS;
                avgTND +=objBASW.totProcessedAMEXOmitFS;
                avgTNFS +=objBASW.totNoOfTransationsAMEXOmitFS;
            }*/
            
         }
         if(MonthlyListedCreditCard.size() > 0){
            objCCFinalSum.avgTotalDeposites = objCCFinalSum.totalDeposites / MonthlyListedCreditCard.size();
            objCCFinalSum.avgTotalAvgDailyBal = objCCFinalSum.totalAvgDailyBal / MonthlyListedCreditCard.size();
            objCCFinalSum.avgTotalNoOfNegativeDays = objCCFinalSum.totalNoOfNegativeDays / MonthlyListedCreditCard.size();
            objCCFinalSum.avgTotalNoOfNFS = objCCFinalSum.totalNoOfNFS / MonthlyListedCreditCard.size();
            
            integer size=MonthlyListedCreditCard.size()-1;
            lastmonthTNPA =MonthlyListedCreditCard[size].totNetProcessOmitFS;
            lastmonthNT =MonthlyListedCreditCard[size].totNoOfTransactionsOmitFS;
            lastmonthTNPAO =MonthlyListedCreditCard[size].totProcessedAMEXOmitFS;
            lastmonthNTAO =MonthlyListedCreditCard[size].totNoOfTransationsAMEXOmitFS;
         }
       /* objCCFinalSum.lastTwoMonthsAvgTD = avgTD/2;
        objCCFinalSum.lastTwoMonthsAvgTVDB = avgTVDB/2;
        objCCFinalSum.lastTwoMonthsAvgTND = avgTND/2;
        objCCFinalSum.lastTwoMonthsAvgTNFS = avgTNFS/2;*/
        objCCFinalSum.lastTwoMonthsAvgTD = avgTD;
        objCCFinalSum.lastTwoMonthsAvgTVDB = avgTVDB;
        objCCFinalSum.lastTwoMonthsAvgTND = avgTND;
        objCCFinalSum.lastTwoMonthsAvgTNFS = avgTNFS;
        
         // system.debug('===================='+lastmonthTNPA);
           //system.debug('===================='+lastmonthNT);
            //system.debug('===================='+lastmonthTNPAO);
             //system.debug('===================='+lastmonthNTAO);
        //calculate trend
        decimal GrossPercent1=0;
        decimal GrossPercent2=0;
        decimal GrossPercent3=0;
        decimal GrossPercent4=0;
        //gross percent1
         if(objCCFinalSum.avgTotalDeposites != 0 && objCCFinalSum.lastTwoMonthsAvgTD != Null && objCCFinalSum.avgTotalDeposites != NUll)
            GrossPercent1 = (objCCFinalSum.lastTwoMonthsAvgTD/objCCFinalSum.avgTotalDeposites)*100;
         if(GrossPercent1 >=120)
            objCCFinalSum.trendTD ='UP';
         else if(GrossPercent1 <= 120 && GrossPercent1 >= 80)
            objCCFinalSum.trendTD ='FLAT';
         else if(GrossPercent1 < 80 )
            objCCFinalSum.trendTD ='DOWN';
        //gross percent2
        if(objCCFinalSum.avgTotalAvgDailyBal != 0 && objCCFinalSum.lastTwoMonthsAvgTVDB != Null && objCCFinalSum.avgTotalAvgDailyBal != Null)
            GrossPercent2 = (objCCFinalSum.lastTwoMonthsAvgTVDB/objCCFinalSum.avgTotalAvgDailyBal)*100;
        if(GrossPercent2 >=120)
            objCCFinalSum.trendTVDB ='UP';
         else if(GrossPercent2 <= 120 && GrossPercent2 >= 80)
            objCCFinalSum.trendTVDB ='FLAT';
         else if(GrossPercent2 < 80 )
            objCCFinalSum.trendTVDB ='DOWN';
        //gross percent3
        if(objCCFinalSum.avgTotalNoOfNegativeDays != 0 && objCCFinalSum.lastTwoMonthsAvgTND != Null && objCCFinalSum.avgTotalNoOfNegativeDays != Null)
            GrossPercent3 = (objCCFinalSum.lastTwoMonthsAvgTND/objCCFinalSum.avgTotalNoOfNegativeDays)*100;
        if(GrossPercent3 >=120)
            objCCFinalSum.trendTND ='UP';
         else if(GrossPercent3 <= 120 && GrossPercent3 >= 80)
            objCCFinalSum.trendTND ='FLAT';
         else if(GrossPercent3 < 80 )
            objCCFinalSum.trendTND ='DOWN';
        //grosee percent4
        if(objCCFinalSum.avgTotalNoOfNFS != 0 && objCCFinalSum.lastTwoMonthsAvgTNFS != Null && objCCFinalSum.avgTotalNoOfNFS != Null)
            GrossPercent4 = ( objCCFinalSum.lastTwoMonthsAvgTNFS/objCCFinalSum.avgTotalNoOfNFS)*100;
        if(GrossPercent4 >=120)
            objCCFinalSum.trendTNFS ='UP';
         else if(GrossPercent4 <= 120 && GrossPercent4 >= 80)
            objCCFinalSum.trendTNFS ='FLAT';
         else if(GrossPercent4 < 80 )
            objCCFinalSum.trendTNFS ='DOWN';
       /* if(lastmonthTNPA != 0){
        GrossPercent1=((objCCFinalSum.avgTotalDeposites-lastmonthTNPA)/lastmonthTNPA)*100;
       
        if( lastmonthTNPA <= 120)
            objCCFinalSum.trendTD ='FLAT';
        else  if( GrossPercent1 >= 120){
            objCCFinalSum.trendTD ='UP';
        }
        else if(GrossPercent1 < 120){
        objCCFinalSum.trendTD ='DOWN';
        }
       }
       else objCCFinalSum.trendTD ='FLAT';
       
             
        //---------
        system.debug('===================='+lastmonthNT);
        if( lastmonthNT !=0){
            GrossPercent2=((objCCFinalSum.avgTotalAvgDailyBal-lastmonthNT )/lastmonthNT )*100;
            if( lastmonthNT <= 120 )
                 objCCFinalSum.trendTVDB='FLAT';
            else if(GrossPercent2 >= 120){
                objCCFinalSum.trendTVDB ='UP';
        }
        else if(GrossPercent2 < 120){
            objCCFinalSum.trendTVDB  ='DOWN';
         }  
        } 
        else objCCFinalSum.trendTVDB='FLAT';
        
        //-----------
         if(lastmonthTNPAO !=0){
            GrossPercent3=((objCCFinalSum.avgTotalNoOfNegativeDays-lastmonthTNPAO)/lastmonthTNPAO)*100;
            if(lastmonthTNPAO <= 120)
                 objCCFinalSum.trendTND='FLAT';
             else if(GrossPercent3 >= 120){
                objCCFinalSum.trendTND ='UP';
            }
            else if(GrossPercent3 < 120){
                objCCFinalSum.trendTND  ='DOWN';
             }  
        } else objCCFinalSum.trendTND='FLAT';
       
       
        //-----
        
       if(lastmonthNTAO !=0){
            GrossPercent4=((objCCFinalSum.avgTotalNoOfNFS-lastmonthNTAO)/lastmonthNTAO)*100;
            if(lastmonthNTAO == Null || lastmonthNTAO < 120)
                objCCFinalSum.trendTNFS='FLAT';
            else if(GrossPercent4 >= 120){
            objCCFinalSum.trendTNFS ='UP';
            }
            else if(GrossPercent4 < 120){
                objCCFinalSum.trendTNFS  ='DOWN';
             }  
        } 
        else
            objCCFinalSum.trendTNFS='FLAT';*/
        
        
        
    }
    //method Name:filterByBankAccountNo
    //description: Used to filter BankAccount Summary by bank account number
    public void filterByBankAccountNo(){
        if(bankAccountNo == '--None--')
            bankAccountNo='%';
        list<Bank_Account__c> lstbankAcc = [select id,name,Business_Owner_Name_Same_as_App__c,Average_Daily_Balance__c,Bank_Account_Number__c,
                                            Bank_Name__c,Deposits__c,Deposits_Minus_Transfers__c,Month__c,
                                            Month_Date__c,Address_Same_as_Biz_Home_Address__c,Notes__c,Number_of_Negative_Days__c,
                                            Number_of_NSFs__c,Omit_From_Summary__c ,Transfers_Disallowed__c,Year__c from Bank_Account__c where Month__c !=null AND Year__c!=null AND Bank_Account_Number__c like :bankAccountNo AND account__c = :accId order by Month__c,Year__c ];
        prepareDataForBankAccountSummary(lstbankAcc);
        
       
    }
    
    //method Name:filterByCCMIDNo
    //description: Used to filter CC Summary by cc MID number
    public void filterByCCMIDNo(){
        if(ccMIDNo == '--None--')
            ccMIDNo='%';
        list<Credit_Card__c> lstCreditCards = [select id,name,Address_Same_as_App__c,Average_Ticket__c,MID_Account_Number__c,
                                           Month__c,Month_Date__c,Name_Same_as_App__c,Number_of_Transactions_All__c,
                                           Number_of_Transactions_AMEX_only__c,Processor_Name__c,Total_Net_Processed_All__c,
                                           Total_Net_Processed_AMEX_only__c,Year__c,Omit_From_Summary__c  from Credit_Card__c where Month__c !=null AND Year__c!=null AND MID_Account_Number__c like :ccMIDNo AND account__c = :accId order by Month__c,Year__c ];
        prepareDataForCreditCardSummary(lstCreditCards);
      
    }
    //redirect to pendingitemsVF
    public pageReference redirectPendingItems(){
        // this page reference is broken, page does not exist 
        PageReference ref = new PageReference('/apex/PendingItemsVF?id='+accId);
        ref.setRedirect(true);
        return ref;
    }
     
    //update checked record of BankAccount
    public void updateBankAccRecord(){
        try{
        list<Bank_Account__c> lstBankAccount=[select id,name,Bank_Account_Number__c,Omit_From_Summary__c from Bank_Account__c where id=:recordId];
        if( lstBankAccount.size() >0 ){
            if(lstBankAccount[0].Omit_From_Summary__c)
                lstBankAccount[0].Omit_From_Summary__c = false;
            else
                lstBankAccount[0].Omit_From_Summary__c = true;  
                
            update lstBankAccount;    
            filterByBankAccountNo();            
        }
        }
        Catch(exception e){
            apexpages.addMessages(e);
        }
    }
    
    //update checked record of Credit_Card__c
    public void updateCCRecord(){
        try{
        list<Credit_Card__c> lstCreditCard=[select id,name,Omit_From_Summary__c from Credit_Card__c where id=:recordId];
        if( lstCreditCard.size() >0 ){
            if(lstCreditCard[0].Omit_From_Summary__c)
                lstCreditCard[0].Omit_From_Summary__c = false;
            else
                lstCreditCard[0].Omit_From_Summary__c = true;   
                
            update lstCreditCard;  
            filterByCCMIDNo();              
        }
        }
        Catch(exception e){
            apexpages.addMessages(e);
        }
    }
    
    // Class Name : BankAccountSummaryWrap
    // Descreption  :
    
    public class BankAccountSummaryWrap{
        public integer index {get;set;}
        public string selectedMonth { get;set; }
        public string selectedYear { get;set; }
        public string total {get;set;}
        public decimal totDeposit{get;set;}
        public decimal totAvgDailyBalance{get;set;}
        public integer totNoOfNegativeDays{get;set;}
        public integer totNoOfNFSs{get;set;}
        public list<Bank_Account__c> currentMonthAccounts { get;Set; }    
        
        public decimal totDepositOmitFS{get;set;}
        public decimal totAvgDailyBalanceOmitFS{get;set;}
        public integer totNoOfNegativeDaysOmitFS{get;set;}
        public integer totNoOfNFSsOmitFS{get;set;}
    }
    
     // Class Name : CreditCardSummaryWrap
     // Descreption  :
    public class CreditCardSummaryWrap{
        public integer index {get;set;}
        public string selectedMonth { get;set; }
        public string selectedYear { get;set; }
        public string total {get;set;}
        public decimal totNetProcess{get;set;}
        public decimal totNoOfTransactions{get;set;}
        public decimal totAvgTicket{get;set;}
        public integer totProcessedAMEX{get;set;}
        public integer totNoOfTransationsAMEX{get;set;}
        public list<Credit_Card__c> currentMonthCredits { get;Set; }   
        
        public decimal totNetProcessOmitFS{get;set;}    
        public decimal totNoOfTransactionsOmitFS{get;set;}
        public integer totProcessedAMEXOmitFS{get;set;}
        public integer totNoOfTransationsAMEXOmitFS{get;set;}     
         public decimal totAvgTicketomitFS{get;set;}
    }
    
    //Class name:   BankAccountFinalSummaryWrap
    //Description: Used to calculate Totals,Averages,Last two months Avg and Trend of Bank Accounts
    public class BankAccountFinalSummaryWrap{
        public decimal totalDeposites{get;set;}
        public decimal totalAvgDailyBal{get;set;}
        public integer totalNoOfNegativeDays{get;set;}
        public integer totalNoOfNFS{get;set;}
        
        public decimal avgTotalDeposites{get;set;}
        public decimal avgTotalAvgDailyBal{get;set;}
        public decimal avgTotalNoOfNegativeDays{get;set;}
        public decimal avgTotalNoOfNFS{get;set;}
        
        public decimal lastTwoMonthsAvgTD{get;set;}
        public decimal lastTwoMonthsAvgTVDB{get;set;}
        public decimal lastTwoMonthsAvgTND{get;set;}
        public decimal lastTwoMonthsAvgTNFS{get;set;}
        
        public string trendTD{get;set;}
        public string trendTVDB{get;set;}
        public string trendTND{get;set;}
        public string trendTNFS{get;set;}
    }
    
    // Class Name : CreditCardFinalSummaryWrap
    // Descreption  :Used to calculate Totals,Averages,Last two months Avg and Trend of CreditCards
    public class CreditCardFinalSummaryWrap{
        public decimal totalDeposites{get;set;}
        public decimal totalAvgDailyBal{get;set;}
        public integer totalNoOfNegativeDays{get;set;}
        public integer totalNoOfNFS{get;set;}
        
        public decimal avgTotalDeposites{get;set;}
        public decimal avgTotalAvgDailyBal{get;set;}
        public decimal avgTotalNoOfNegativeDays{get;set;}
        public decimal avgTotalNoOfNFS{get;set;}
        
        public decimal lastTwoMonthsAvgTD{get;set;}
        public decimal lastTwoMonthsAvgTVDB{get;set;}
        public decimal lastTwoMonthsAvgTND{get;set;}
        public decimal lastTwoMonthsAvgTNFS{get;set;}
        
        public string trendTD{get;set;}
        public string trendTVDB{get;set;}
        public string trendTND{get;set;}
        public string trendTNFS{get;set;}
        
        public decimal totAvgTickets{get;set;}
    }
}