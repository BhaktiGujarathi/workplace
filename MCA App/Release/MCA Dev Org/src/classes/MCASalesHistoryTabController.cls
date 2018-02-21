public with sharing class MCASalesHistoryTabController {

  public Bank_Account__c[] statements;
  public Credit_Card__c[] credits;

  public Bank_Account__c[] newStatements {get; set;}
  public Credit_Card__c[] newCredits {get; set;}
  public boolean bankAccountAccesss {get;set;}
  public boolean creditCardAccesss {get;set;}
  public ContainerStatement[] containersStatements;
  public ContainerCard[] containersCards;

  public Boolean editAll {get;set;}

  public Id recordToDelete {get;set;}
  public Integer indexToRemove {get;set;}

  private Id opportunityId;
  public Boolean isFirstStatement;
  public Boolean isFirstCredit;
  public Decimal depositsAverage {get; set;}
  public Decimal balanceAverage {get; set;}
  public Decimal nsfAverage {get; set;}
  public Decimal negativeAverage {get; set;}

  public Decimal processedAverage {get; set;}
  public Decimal transactionAverage {get; set;}
  public Decimal batchesAverage {get; set;}
  public Decimal noDepositsAverage {get; set;}
  public Integer indexToRemoveStatement; 
  public Integer indexToRemoveCredit;
  public list<Bank_Account__c> bankAccList; 
  public list<Credit_Card__c> creditCardList;
  public list<Bank_Account__c> bankAccListShow; 
  public list<Credit_Card__c> creditCardListShow;
  public map<string,list<Bank_Account__c>> mapAverageAll = new map<string,list<Bank_Account__c>> ();
  public map<string,list<Credit_Card__c>> mapAverageAllCredit = new map<string,list<Credit_Card__c>> ();
  public Boolean isUpdatedBank;
  public Map<Id, Bank_Account__c> mapIDANDBank;
  public List<Bank_Account__c> listToUpdateBank;
  public Set<Integer> setInvalidBankRow;
  public Set<Integer> setInvalidCreditRow;
  public Boolean isUpdatedCard;
  public Map<Id, Credit_Card__c> mapIDANDCard;
  public List<Credit_Card__c> listToUpdateCard;
  public Boolean isValidation;
  Map<Integer, Integer> mapOfBankIndex;
  Map<Integer, Integer> mapOfCreditIndex;
 
  public MCASalesHistoryTabController() {
    isFirstStatement=true;
    isFirstCredit=true;
    isValidation = false;
    setInvalidBankRow = new Set<Integer>();
    setInvalidCreditRow = new Set<Integer>();
    mapOfBankIndex = new Map<Integer, Integer>();
    mapOfCreditIndex = new Map<Integer, Integer>();
    mapIDANDBank = new Map<Id, Bank_Account__c>();
    mapIDANDCard = new Map<Id, Credit_Card__c>();
    opportunityId = Apexpages.currentPage().getParameters().get('id');
    bankAccountAccesss = Schema.sObjectType.Bank_Account__c.isAccessible();
    creditCardAccesss = Schema.sObjectType.Credit_Card__c.isAccessible();
    depositsAverage = 0;
    processedAverage = 0;
    transactionAverage = 0;
    balanceAverage = 0;
    nsfAverage = 0;
    negativeAverage = 0;
    noDepositsAverage = 0;
    batchesAverage = 0;
    refresh();
  }

  public ContainerStatement[] getContainersStatements() {

    statements = new Bank_Account__c[] {};
    bankAccList = new list<Bank_Account__c>();
    bankAccListShow = new list<Bank_Account__c>();
    mapAverageAll = new map<string,list<Bank_Account__c>> ();
    statements.addAll(newStatements);
    if (isFirstStatement && !editAll && !isValidation && setInvalidBankRow.size() <= 0){
    isFirstStatement=false;
        bankAccListShow = [SELECT
                          Id,
                          Month__c,
                          Year__c,
                          Deposits__c,
                          Average_Daily_Balance__c,
                          Number_of_NSFs__c,
                          Number_of_Negative_Days__c,
                          Include_in_average__c,
                          Bank_Account_Number__c,
                          No_Deposits__c
                  FROM Bank_Account__c
                  WHERE Opportunity__c = :opportunityId]; 
                  
         system.debug('*****bankAccListShow**' + bankAccListShow);
         for(Bank_Account__c baShow :[SELECT
                          Id,
                          Month__c,
                          Year__c,
                          Deposits__c,
                          Average_Daily_Balance__c,
                          Number_of_NSFs__c,
                          Number_of_Negative_Days__c,
                          Include_in_average__c,
                          Bank_Account_Number__c,
                          No_Deposits__c
                  FROM Bank_Account__c
                  WHERE Opportunity__c = :opportunityId]){  
            
               statements.add(baShow);   
               }

    bankAccList = [SELECT
                          Id,
                          Month__c,
                          Year__c,
                          Deposits__c,
                          Average_Daily_Balance__c,
                          Number_of_NSFs__c,
                          Number_of_Negative_Days__c,
                          Include_in_average__c,
                          Bank_Account_Number__c,
                          No_Deposits__c
                  FROM Bank_Account__c
                  WHERE Opportunity__c = :opportunityId AND Include_in_average__c = true]; 
  }//if firststatement
 else{
        for (ContainerStatement containerVal: containersStatements) {
            if (recordToDelete!=null){
                if(containerVal.statement.id<> recordToDelete){
                    statements.add(containerVal.statement);
                    if (containerVal.statement.Include_in_average__c==true){
                        bankAccList.add(containerVal.statement);
                    }
                }
            }
            else if(containerVal.index <>indexToRemoveStatement){
                statements.add(containerVal.statement);
                if (containerVal.statement.Include_in_average__c==true){
                    bankAccList.add(containerVal.statement);
                }
            } 
        }
        indexToRemoveStatement = -99;
        recordToDelete=null;
        system.debug('#######containers'+containersStatements);
      }
        for(Bank_Account__c ba :bankAccList){
            if(ba.Month__c != '--None--' || ba.Year__c != '--None--'){
                if(mapAverageAll.containskey(ba.Month__c+ba.Year__c)){
                    list<Bank_Account__c> lstBank = mapAverageAll.get(ba.Month__c+ba.Year__c);
                    lstBank.add(ba);
                    mapAverageAll.put(ba.Month__c+ba.Year__c,lstBank);
                }
                else{
                    mapAverageAll.put(ba.Month__c+ba.Year__c,new  List <Bank_Account__c> { ba });
                } 
            }
        }
        system.debug('11111111111'+mapAverageAll);
          depositsAverage = 0;
          balanceAverage = 0;
          nsfAverage = 0;
          negativeAverage = 0;
          noDepositsAverage = 0;
          batchesAverage = 0;
     for (Bank_Account__c ba :bankAccList) {    

      depositsAverage += ba.Deposits__c != null ? ba.Deposits__c : 0;
      balanceAverage += ba.Average_Daily_Balance__c != null ? ba.Average_Daily_Balance__c : 0;
      nsfAverage += ba.Number_of_NSFs__c != null ? ba.Number_of_NSFs__c : 0;
      negativeAverage += ba.Number_of_Negative_Days__c != null ? ba.Number_of_Negative_Days__c : 0;
      noDepositsAverage += ba.No_Deposits__c!=null ? ba.No_Deposits__c : 0;
    }
     system.debug('2222222222'+noDepositsAverage);
    if ( mapAverageAll.size() != 0) {
      depositsAverage /= mapAverageAll.size();
      balanceAverage /= mapAverageAll.size();
      nsfAverage /= mapAverageAll.size();
      negativeAverage /= mapAverageAll.size();
      noDepositsAverage /= mapAverageAll.size();
    }
    
    containersStatements = new ContainerStatement[] {};
    
    for (Integer i = 0; i < statements.size(); i++) {
        if(setInvalidBankRow.contains(i - newStatements.size()))
            containersStatements.add(new ContainerStatement(statements[i], i, true));
        else
            containersStatements.add(new ContainerStatement(statements[i], i, false));
    }
    newStatements=new List<Bank_Account__c>();
    system.debug('$$$$$$$$$$containers'+containersStatements);
    return containersStatements;

    
  }
  public void save(){}
  public ContainerCard[] getContainersCards() {
    
    credits = new Credit_Card__c[] {};
   
    creditCardList = new list<Credit_Card__c> ();
    creditCardListShow = new list<Credit_Card__c> ();
    mapAverageAllCredit = new map<string,list<Credit_Card__c>> ();
    credits.addAll(newCredits);
    if (isFirstCredit && !editAll && !isValidation && setInvalidCreditRow.size() <= 0){
        isFirstCredit=false;
    
    creditCardListShow = [SELECT
                                Id,
                                Month__c,
                                Year__c,
                                Total_Net_Processed_All__c,
                                Number_of_Transactions_All__c,
                                Processor_Name__c,
                                Include_in_average__c,
                                MID_Account_Number__c,
                                Batches__c
                            FROM Credit_Card__c
                            WHERE Opportunity__c = :opportunityId];
                            
     for(Credit_Card__c ccShow :creditCardListShow){           
              credits.add(ccShow);  
              
              } 
    creditCardList = [SELECT
                                Id,
                                Month__c,
                                Year__c,
                                Total_Net_Processed_All__c,
                                Number_of_Transactions_All__c,
                                Processor_Name__c,
                                Include_in_average__c,
                                MID_Account_Number__c,
                                Batches__c
                            FROM Credit_Card__c
                            WHERE Opportunity__c = :opportunityId AND Include_in_average__c = true];
                            
    }//isfirstcredit condition
    else{
        for (ContainerCard containerVal: containersCards) {
            if (recordToDelete!=null){
                if(containerVal.card.id<> recordToDelete){
                    credits.add(containerVal.card);
                    if (containerVal.card.Include_in_average__c==true){
                        creditCardList.add(containerVal.card);
                    }
                }
            }
            else if(containerVal.index <>indexToRemoveCredit){
                credits.add(containerVal.card);
                if (containerVal.card.Include_in_average__c==true){
                    creditCardList.add(containerVal.card);
                }
            } 
        }
        indexToRemoveCredit = -99;
        recordToDelete=null;
      
      }

       for(Credit_Card__c cc :creditCardList){
            if(cc.Month__c != '--None--' || cc.Year__c != '--None--'){
                if(mapAverageAllCredit.containskey(cc.Month__c + cc.Year__c)){
                    list<Credit_Card__c> lstCC = mapAverageAllCredit.get(cc.Month__c+cc.Year__c);
                    lstCC.add(cc);
                    mapAverageAllCredit.put(cc.Month__c+cc.Year__c,lstCC);
                }
                else{
                    mapAverageAllCredit.put(cc.Month__c+cc.Year__c,new  List <Credit_Card__c> { cc });
                } 
            }
        }
        system.debug('33333333333'+mapAverageAllCredit);
          processedAverage = 0;
          transactionAverage = 0;
          batchesAverage = 0;
     for (Credit_Card__c cc :creditCardList) {

      processedAverage += cc.Total_Net_Processed_All__c != null ? cc.Total_Net_Processed_All__c : 0;
      transactionAverage += cc.Number_of_Transactions_All__c != null ? cc.Number_of_Transactions_All__c : 0; 
      batchesAverage += cc.Batches__c != null ? cc.Batches__c : 0;
    }
    system.debug('44444444444'+batchesAverage);
    if ( mapAverageAllCredit.size() != 0) {
      processedAverage /= mapAverageAllCredit.size();
      transactionAverage /= mapAverageAllCredit.size();
      batchesAverage /= mapAverageAllCredit.size();
    }
    
     containersCards = new ContainerCard[] {};

    for (Integer i = 0; i < credits.size(); i++) {
        if(setInvalidCreditRow.contains(i - newCredits.size()))
            containersCards.add(new ContainerCard(credits[i], i, true));
        else
            containersCards.add(new ContainerCard(credits[i], i, false));
    }
     newCredits=new List<Credit_Card__c>();
    return containersCards;
    //return credits;
  }
  public void afterSave() {
	    depositsAverage = 0.00;
	    balanceAverage = 0.00;
	    nsfAverage = 0.00;
	    negativeAverage = 0.00;
	
	    processedAverage = 0.00;
	    transactionAverage = 0.00;
	    noDepositsAverage = 0;
	    batchesAverage = 0;
	    recordToDelete = null;
	    editAll = false;
	    isFirstCredit = true;
	    isFirstStatement  = true;
	    newStatements = new Bank_Account__c[] {};
	    newCredits = new Credit_Card__c[] {};
    }
  public void refresh() {

    afterSave();
    setInvalidBankRow.clear();
    setInvalidCreditRow.clear();
  }

  public void editAll() {
    refresh();
    editAll = true;
  }

  public void saveAllSales() {
    isValidation = false;
    String bankMsgStr ='';
    String creditMsgStr ='';
    setInvalidBankRow.clear();
    setInvalidCreditRow.clear();
    try{
        //upsert statements;
        List<Database.upsertResult> statementResults = Database.upsert(statements, false);
           //for (Database.upsertResult result : statementResults ) {
           for(Integer i = 0; i<statementResults.size(); i++) {
           //system.debug('>>>result : ' +result);
              if (!statementResults[i].isSuccess()){
                  for (Database.Error err : statementResults[i].getErrors()){
                     bankMsgStr = bankMsgStr + 'Error: ' + err.getMessage() + ' For record with serial number : ' +(containersStatements[i].index +1) + '<br />';
                     //bankMsgStr = bankMsgStr + 'Error: ' + err.getMessage() + 'D\r\n' + err.getMessage();
                    setInvalidBankRow.add(i); 
                 }
              }
          }
          
         if(!bankMsgStr.contains('Argument 2 cannot be null') && String.isNotBlank(bankMsgStr)) 
               ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,bankMsgStr));
        //upsert credits;
        List<Database.upsertResult> creditResults = Database.upsert(credits, false);
        for (Integer i = 0; i < creditResults.size(); i++) {
              if (!creditResults[i].isSuccess()){
                  for (Database.Error err : creditResults[i].getErrors()){
                      creditMsgStr = creditMsgStr + 'Error: '+ err.getMessage() + ' For record with serial number : ' +(containersCards[i].index +1) + '<br />';
                      setInvalidCreditRow.add(i);
                      //creditMsgStr = creditMsgStr + 'Error: '+ err.getStatusCode() + ' ' + err.getMessage() +'</br>';
                  }
              }
         }
         if(!creditMsgStr.contains('Argument 2 cannot be null') && String.isNotBlank(creditMsgStr)) 
               ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,creditMsgStr));
    }
    catch(Exception e){
        isValidation = true;
        ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,e.getMessage()));
    }


    afterSave();
  }
    public void bankAccountList(){
        mapIDANDBank.clear();
        mapIDANDBank = new Map<Id, Bank_Account__c>([SELECT
                                                          Id,
                                                          Month__c,
                                                          Year__c,
                                                          Deposits__c,
                                                          Average_Daily_Balance__c,
                                                          Number_of_NSFs__c,
                                                          Number_of_Negative_Days__c,
                                                          Include_in_average__c,
                                                          Bank_Account_Number__c,
                                                          No_Deposits__c
                                                  FROM Bank_Account__c
                                                  WHERE Opportunity__c = :opportunityId]);
    }
    
    public void newStatement() {
        updateRecords();
        newStatements.add(new Bank_Account__c(Opportunity__c = opportunityId,Include_in_average__c = true));
    }
    
    public void updateRecords() {
        isUpdatedBank = false;
        checkoldAndNewBankVal();
        if(editAll !=true && isUpdatedBank == true){
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,'All changes have been saved.'));
            updateInlineEditedBankValue();
        }
        
        isUpdatedCard = false;
        checkoldAndNewCardVal();
        if(editAll !=true && isUpdatedCard == true){
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,'All changes have been saved.'));
            updateInlineEditedCardValue();
        }
    }
  
  public void updateInlineEditedBankValue() {
        String msgstr = '';
        setInvalidBankRow.clear();
        try{
            //update listToUpdateBank;
            List<Database.saveResult> results = Database.update(listToUpdateBank, false);
            for (Integer i = 0; i < results.size(); i++) {
              if (!results[i].isSuccess()){
                  for (Database.Error err : results[i].getErrors()){
                      msgstr = msgstr + 'Error: ' + err.getMessage() + ' For record with serial number : ' +(mapOfBankIndex.get(i)+1) + '<br />';
                  
                      setInvalidBankRow.add(mapOfBankIndex.get(i));
                  }
              }
            }
            //msgStr = showResultMsg(results);
           if(!msgStr.contains('Argument 2 cannot be null') && String.isNotBlank(msgStr)) 
               ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,msgStr));
        }
        catch(Exception e){
            system.debug('***Enter In Exception****');
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,e.getMessage()));
        }
    }
    public void checkoldAndNewBankVal() {
        listToUpdateBank = new List<Bank_Account__c>();
        Bank_Account__c bankAccountValue = new Bank_Account__c();
        bankAccountList();
        for (ContainerStatement containerVal: containersStatements) {
            if(containerVal.statement.id != null){
                bankAccountValue = mapIDANDBank.get(containerVal.statement.id);
                if(bankAccountValue !=null) {
                    if(containerVal.statement.Month__c != bankAccountValue.Month__c
                    || containerVal.statement.Year__c != bankAccountValue.Year__c
                    || containerVal.statement.Deposits__c != bankAccountValue.Deposits__c
                    || containerVal.statement.No_Deposits__c != bankAccountValue.No_Deposits__c
                    || containerVal.statement.Average_Daily_Balance__c != bankAccountValue.Average_Daily_Balance__c
                    || containerVal.statement.Number_of_NSFs__c != bankAccountValue.Number_of_NSFs__c
                    || containerVal.statement.Number_of_Negative_Days__c != bankAccountValue.Number_of_Negative_Days__c
                    || containerVal.statement.Include_in_average__c != bankAccountValue.Include_in_average__c
                    || containerVal.statement.Bank_Account_Number__c != bankAccountValue.Bank_Account_Number__c){
                        listToUpdateBank.add(containerVal.statement);
                        mapOfBankIndex.put(listToUpdateBank.size()-1, containerVal.index);
                        isUpdatedBank = true;
                    }
                }
            }
        }
    }
  public void newCredit() {
    updateRecords();
    newCredits.add(new Credit_Card__c(Opportunity__c = opportunityId,Include_in_average__c = true));
  }
  public void updateInlineEditedCardValue() {
        String msgStr;
        setInvalidCreditRow.clear();
        try{
            //update listToUpdateCard;
            List<Database.saveResult> results = Database.update(listToUpdateCard, false);            
            for (Integer i = 0; i< results.size(); i++) {
               if (!results[i].isSuccess()){
                  for (Database.Error err : results[i].getErrors()){
                      msgStr = msgStr+ 'Error: ' + err.getMessage() + ' For record with serial number : ' +(mapOfCreditIndex.get(i) +1) + ' <br />';
                      
                      setInvalidCreditRow.add(mapOfBankIndex.get(i));
                  }
               }
            }
           if(!msgStr.contains('Argument 2 cannot be null') && String.isNotBlank(msgStr)) 
               ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,msgStr));
        }
        catch(Exception e){
            system.debug('***Enter In Exception****');
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,e.getMessage()));
        }
    }
    public void checkoldAndNewCardVal() {
        listToUpdateCard = new List<Credit_Card__c>();
        Credit_Card__c creditCardValue = new Credit_Card__c();
        cardAccountList();
        for (ContainerCard containerVal: containersCards) {
            if(containerVal.card.id != null){
                creditCardValue = mapIDANDCard.get(containerVal.card.id);
                if(creditCardValue != null) {
                    if(containerVal.card.Month__c != creditCardValue.Month__c
                    || containerVal.card.Year__c != creditCardValue.Year__c
                    || containerVal.card.Total_Net_Processed_All__c != creditCardValue.Total_Net_Processed_All__c
                    || containerVal.card.Number_of_Transactions_All__c != creditCardValue.Number_of_Transactions_All__c
                    || containerVal.card.Processor_Name__c != creditCardValue.Processor_Name__c
                    || containerVal.card.Include_in_average__c != creditCardValue.Include_in_average__c
                    || containerVal.card.MID_Account_Number__c != creditCardValue.MID_Account_Number__c
                    || containerVal.card.Batches__c != creditCardValue.Batches__c){
                        listToUpdateCard.add(containerVal.card);
                        mapOfCreditIndex.put(listToUpdateCard.size()-1, containerVal.index);
                        isUpdatedCard = true;
                    }
                }
            }
        }
    }
    public void cardAccountList(){
        mapIDANDCard.clear();
        mapIDANDCard = new Map<Id, Credit_Card__c>([SELECT
                                                        Id,
                                                        Month__c,
                                                        Year__c,
                                                        Total_Net_Processed_All__c,
                                                        Number_of_Transactions_All__c,
                                                        Processor_Name__c,
                                                        Include_in_average__c,
                                                        MID_Account_Number__c,
                                                        Batches__c
                                                    FROM Credit_Card__c
                                                    WHERE Opportunity__c = :opportunityId]);
    }
  public void deleteStatement() {
    updateRecords();
    if (recordToDelete != null) {
      Bank_Account__c record = [SELECT Id FROM Bank_Account__c WHERE Id = :recordToDelete];
      try {
          delete record;
      }catch (Exception ex){
          indexToRemove = -99;
          ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,MCAExceptionHandlerUtility.getErrorMessage(ex)));
      }
    }     
     refresh();
     //getContainersStatements();
     system.debug('***depositsAverage***'+depositsAverage+'***balanceAverage***'+balanceAverage+'***nsfAverage***'+nsfAverage+'***negativeAverage**'+negativeAverage+'***processedAverage***'+processedAverage+'****transactionAverage****'+transactionAverage);
  }

  public void deleteCredit() {
    updateRecords();
    if (recordToDelete != null) {
      Credit_Card__c record = [SELECT Id FROM Credit_Card__c WHERE Id = :recordToDelete];
      try {
          delete record;
      }catch (Exception ex){
          indexToRemove = -99;
          ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,MCAExceptionHandlerUtility.getErrorMessage(ex)));
      }
    }     
     refresh();
  }

  public void removeCard() {
    updateRecords();
    if (indexToRemove != null) {

      ContainerCard c = null;

      for (ContainerCard element :containersCards) {

        if (element.index == indexToRemove) {
          c = element;
        }
      }
      indexToRemoveCredit=indexToRemove;
     // newCredits.remove(c.index);
    }

  }

  public void removeStatement() {
    updateRecords();
    if (indexToRemove != null) {

      ContainerStatement c = null;
      for (ContainerStatement element :containersStatements) {
        if (element.index == indexToRemove) {
          c = element;
        }
      }
      indexToRemoveStatement=indexToRemove;
     // newStatements.remove(c.index);
    }
  }

    
  public class ContainerCard {

    public Credit_Card__c card {get;set;}
    public Integer index {get;set;}
    public Boolean isedited {get;set;}
    public ContainerCard(Credit_Card__c instance, Integer index, Boolean isedited) {
      card = instance;
      this.index = index;
      this.isedited = isedited;
    }

  }

  public class ContainerStatement {

    public Bank_Account__c statement {get;set;}
    public Integer index {get;set;}
    public Boolean isedited {get;set;}
    public ContainerStatement(Bank_Account__c instance, Integer index, Boolean isedited) {
      statement = instance;
      this.index = index;
      this.isedited = isedited;
    }

  }
  

}