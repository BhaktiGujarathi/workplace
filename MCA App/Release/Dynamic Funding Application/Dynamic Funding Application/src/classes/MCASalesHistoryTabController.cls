public with sharing class MCASalesHistoryTabController {
    //Constant Variable
    private static final String ERROR_MSG = 'Please complete required fields and click on quick save before creating loan balance and sales history records.';
     
    public McaApp__Bank_Account__c[] statements;
    public McaApp__Credit_Card__c[] credits;
    public McaApp__Bank_Account__c[] newStatements {get; set;}
    public McaApp__Credit_Card__c[] newCredits {get; set;}
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
    public boolean isDisable     {get;set;}
    public Integer indexToRemoveStatement; 
    public Integer indexToRemoveCredit;
    public list<McaApp__Bank_Account__c> bankAccList; 
    public list<McaApp__Credit_Card__c> creditCardList;
    public list<McaApp__Bank_Account__c> bankAccListShow; 
    public list<McaApp__Credit_Card__c> creditCardListShow;
    public map<string,list<McaApp__Bank_Account__c>> mapAverageAll = new map<string,list<McaApp__Bank_Account__c>> ();
    public map<string,list<McaApp__Credit_Card__c>> mapAverageAllCredit = new map<string,list<McaApp__Credit_Card__c>> ();
    public Boolean isUpdatedBank;
    public Map<Id, McaApp__Bank_Account__c> mapIDANDBank;
    public List<McaApp__Bank_Account__c> listToUpdateBank;
    public Set<Integer> setInvalidBankRow;
    public Set<Integer> setInvalidCreditRow;
    public Boolean isUpdatedCard;
    public Map<Id, McaApp__Credit_Card__c> mapIDANDCard;
    public List<McaApp__Credit_Card__c> listToUpdateCard;
    public Boolean isValidation;
    Map<Integer, Integer> mapOfBankIndex;
    Map<Integer, Integer> mapOfCreditIndex;
    
    private static final String NEWAPP_PARAM = 'newApplication';
    private String isNewApplication;
    
    //constructor
    public MCASalesHistoryTabController() {
        isFirstStatement=true;
        isFirstCredit=true;
        isValidation = false;
        isDisable = false;
        setInvalidBankRow = new Set<Integer>();
        setInvalidCreditRow = new Set<Integer>();
        mapOfBankIndex = new Map<Integer, Integer>();
        mapOfCreditIndex = new Map<Integer, Integer>();
        mapIDANDBank = new Map<Id, McaApp__Bank_Account__c>();
        mapIDANDCard = new Map<Id, McaApp__Credit_Card__c>();
        isNewApplication = Apexpages.currentPage().getParameters().get(NEWAPP_PARAM);
        if(!isNewApplication.contains('true')) {
            opportunityId = Apexpages.currentPage().getParameters().get('oppId');
        }else {
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info, ERROR_MSG));
            isDisable = true;
        }// end else
        bankAccountAccesss = Schema.sObjectType.McaApp__Bank_Account__c.isAccessible();
        creditCardAccesss = Schema.sObjectType.McaApp__Credit_Card__c.isAccessible();
        depositsAverage = 0;
        processedAverage = 0;
        transactionAverage = 0;
        balanceAverage = 0;
        nsfAverage = 0;
        negativeAverage = 0;
        noDepositsAverage = 0;
        batchesAverage = 0;
        /////////////////////////////////////////////
        containersStatements = new ContainerStatement[] {};
        containersCards = new ContainerCard[]{};
        refresh();
    }

    public ContainerStatement[] getContainersStatements() {

        statements = new McaApp__Bank_Account__c[] {};
        bankAccList = new list<McaApp__Bank_Account__c>();
        bankAccListShow = new list<McaApp__Bank_Account__c>();
        mapAverageAll = new map<string,list<McaApp__Bank_Account__c>> ();
        statements.addAll(newStatements);
        if (isFirstStatement && !editAll && !isValidation && setInvalidBankRow.size() <= 0){
            isFirstStatement=false;
            bankAccListShow = [SELECT Id,
                                      McaApp__Month__c,
                                      McaApp__Year__c,
                                      McaApp__Deposits__c,
                                      McaApp__Average_Daily_Balance__c,
                                      McaApp__Number_of_NSFs__c,
                                      McaApp__Number_of_Negative_Days__c,
                                      McaApp__Include_in_average__c,
                                      McaApp__Bank_Account_Number__c,
                                      McaApp__No_Deposits__c
                                 FROM McaApp__Bank_Account__c
                                WHERE McaApp__Opportunity__c = :opportunityId]; 
                  
            system.debug('*****bankAccListShow**' + bankAccListShow);
            for(McaApp__Bank_Account__c baShow :[SELECT Id,
                                                McaApp__Month__c,
                                                McaApp__Year__c,
                                                McaApp__Deposits__c,
                                                McaApp__Average_Daily_Balance__c,
                                                McaApp__Number_of_NSFs__c,
                                                McaApp__Number_of_Negative_Days__c,
                                                McaApp__Include_in_average__c,
                                                McaApp__Bank_Account_Number__c,
                                                McaApp__No_Deposits__c
                                           FROM McaApp__Bank_Account__c
                                          WHERE McaApp__Opportunity__c = :opportunityId]){  
            
                statements.add(baShow);   
            }//end for

            bankAccList = [SELECT
                                  Id,
                                  McaApp__Month__c,
                                  McaApp__Year__c,
                                  McaApp__Deposits__c,
                                  McaApp__Average_Daily_Balance__c,
                                  McaApp__Number_of_NSFs__c,
                                  McaApp__Number_of_Negative_Days__c,
                                  McaApp__Include_in_average__c,
                                  McaApp__Bank_Account_Number__c,
                                  McaApp__No_Deposits__c
                          FROM McaApp__Bank_Account__c
                          WHERE McaApp__Opportunity__c = :opportunityId AND McaApp__Include_in_average__c = true]; 
        }//if firststatement
        else{
            for (ContainerStatement containerVal: containersStatements) {
                if (recordToDelete!=null){
                    if(containerVal.statement.id<> recordToDelete){
                        statements.add(containerVal.statement);
                        if (containerVal.statement.McaApp__Include_in_average__c==true){
                            bankAccList.add(containerVal.statement);
                        }
                    }
                } else if(containerVal.index != indexToRemoveStatement){
                    statements.add(containerVal.statement);
                    if (containerVal.statement.McaApp__Include_in_average__c==true){
                        bankAccList.add(containerVal.statement);
                    }
                }//end else if
            }//end for
            indexToRemoveStatement = -99;
            system.debug('#######containers'+containersStatements);
        }//end else if
        for(McaApp__Bank_Account__c ba :bankAccList){
            if(ba.McaApp__Month__c != '--None--' || ba.McaApp__Year__c != '--None--'){
                if(mapAverageAll.containskey(ba.McaApp__Month__c+ba.McaApp__Year__c)){
                    list<McaApp__Bank_Account__c> lstBank = mapAverageAll.get(ba.McaApp__Month__c+ba.McaApp__Year__c);
                    lstBank.add(ba);
                    mapAverageAll.put(ba.McaApp__Month__c+ba.McaApp__Year__c,lstBank);
                }
                else{
                    mapAverageAll.put(ba.McaApp__Month__c+ba.McaApp__Year__c,new  List <McaApp__Bank_Account__c> { ba });
                }//end if-else
            }//end if
        }//end for
        system.debug('11111111111'+mapAverageAll);
        depositsAverage = 0;
        balanceAverage = 0;
        nsfAverage = 0;
        negativeAverage = 0;
        noDepositsAverage = 0;
        batchesAverage = 0;
        for (McaApp__Bank_Account__c ba :bankAccList) {    

            depositsAverage += ba.McaApp__Deposits__c != null ? ba.McaApp__Deposits__c : 0;
            balanceAverage += ba.McaApp__Average_Daily_Balance__c != null ? ba.McaApp__Average_Daily_Balance__c : 0;
            nsfAverage += ba.McaApp__Number_of_NSFs__c != null ? ba.McaApp__Number_of_NSFs__c : 0;
            negativeAverage += ba.McaApp__Number_of_Negative_Days__c != null ? ba.McaApp__Number_of_Negative_Days__c : 0;
            noDepositsAverage += ba.McaApp__No_Deposits__c!=null ? ba.McaApp__No_Deposits__c : 0;
        }//end for
        system.debug('2222222222'+noDepositsAverage);
        if ( mapAverageAll.size() != 0) {
            depositsAverage /= mapAverageAll.size();
            balanceAverage /= mapAverageAll.size();
            nsfAverage /= mapAverageAll.size();
            negativeAverage /= mapAverageAll.size();
            noDepositsAverage /= mapAverageAll.size();
        }//end if
    
        containersStatements = new ContainerStatement[] {};
        for (Integer i = 0; i < statements.size(); i++) {
            if(setInvalidBankRow.contains(i - newStatements.size()))
                containersStatements.add(new ContainerStatement(statements[i], i, true));
            else
                containersStatements.add(new ContainerStatement(statements[i], i, false));
        }//end for
        newStatements=new List<McaApp__Bank_Account__c>();
        
        system.debug('$$$$$$$$$$containers'+containersStatements);
        return containersStatements;
    }//end getContainersStatements
    
    public void save(){}
    
    public ContainerCard[] getContainersCards() {
    
        credits = new McaApp__Credit_Card__c[] {};
        system.debug('IOutside If----->'+recordToDelete);
        creditCardList = new list<McaApp__Credit_Card__c> ();
        creditCardListShow = new list<McaApp__Credit_Card__c> ();
        mapAverageAllCredit = new map<string,list<McaApp__Credit_Card__c>> ();
        credits.addAll(newCredits);
        if (isFirstCredit && !editAll && !isValidation && setInvalidCreditRow.size() <= 0){
            isFirstCredit=false;
    
            creditCardListShow = [SELECT
                                        Id,
                                        McaApp__Month__c,
                                        McaApp__Year__c,
                                        McaApp__Total_Net_Processed_All__c,
                                        McaApp__Number_of_Transactions_All__c,
                                        McaApp__Processor_Name__c,
                                        McaApp__Include_in_average__c,
                                        McaApp__MID_Account_Number__c,
                                        McaApp__Batches__c
                                    FROM McaApp__Credit_Card__c
                                    WHERE McaApp__Opportunity__c = :opportunityId];
                                
            for(McaApp__Credit_Card__c ccShow :creditCardListShow){           
                credits.add(ccShow);  
            } 
            creditCardList = [SELECT
                                        Id,
                                        McaApp__Month__c,
                                        McaApp__Year__c,
                                        McaApp__Total_Net_Processed_All__c,
                                        McaApp__Number_of_Transactions_All__c,
                                        McaApp__Processor_Name__c,
                                        McaApp__Include_in_average__c,
                                        McaApp__MID_Account_Number__c,
                                        McaApp__Batches__c
                                    FROM McaApp__Credit_Card__c
                                    WHERE McaApp__Opportunity__c = :opportunityId AND McaApp__Include_in_average__c = true];
                                
        }//isfirstcredit condition
        else{
            for (ContainerCard containerVal: containersCards) {
                if (recordToDelete!=null){
                    system.debug('Inside If----->'+recordToDelete);
                    if(containerVal.card.id <> recordToDelete){
                        credits.add(containerVal.card);
                        if (containerVal.card.McaApp__Include_in_average__c==true){
                            creditCardList.add(containerVal.card);
                        }//end if
                    }//end if
                }//end if
                else if(containerVal.index != indexToRemoveCredit){
                    credits.add(containerVal.card);
                    if (containerVal.card.McaApp__Include_in_average__c==true){
                        creditCardList.add(containerVal.card);
                    }
                } //end if -else
            }//end for
            indexToRemoveCredit = -99;
        }//end else-if

        for(McaApp__Credit_Card__c cc :creditCardList){
            if(cc.McaApp__Month__c != '--None--' || cc.McaApp__Year__c != '--None--'){
                if(mapAverageAllCredit.containskey(cc.McaApp__Month__c + cc.McaApp__Year__c)){
                    list<McaApp__Credit_Card__c> lstCC = mapAverageAllCredit.get(cc.McaApp__Month__c+cc.McaApp__Year__c);
                    lstCC.add(cc);
                    mapAverageAllCredit.put(cc.McaApp__Month__c+cc.McaApp__Year__c,lstCC);
                }else{
                    mapAverageAllCredit.put(cc.McaApp__Month__c+cc.McaApp__Year__c,new  List <McaApp__Credit_Card__c> { cc });
                }//end else-if
            }//end if
        }//end for
        system.debug('33333333333'+mapAverageAllCredit);
        processedAverage = 0;
        transactionAverage = 0;
        batchesAverage = 0;
        for (McaApp__Credit_Card__c cc :creditCardList) {
            processedAverage += cc.McaApp__Total_Net_Processed_All__c != null ? cc.McaApp__Total_Net_Processed_All__c : 0;
            transactionAverage += cc.McaApp__Number_of_Transactions_All__c != null ? cc.McaApp__Number_of_Transactions_All__c : 0; 
            batchesAverage += cc.McaApp__Batches__c != null ? cc.McaApp__Batches__c : 0;
        }//end for
        system.debug('44444444444'+batchesAverage);
        if ( mapAverageAllCredit.size() != 0) {
            processedAverage /= mapAverageAllCredit.size();
            transactionAverage /= mapAverageAllCredit.size();
            batchesAverage /= mapAverageAllCredit.size();
        }//end if
        containersCards = new ContainerCard[] {};
        for (Integer i = 0; i < credits.size(); i++) {
            if(setInvalidCreditRow.contains(i - newCredits.size()))
                containersCards.add(new ContainerCard(credits[i], i, true));
            else
                containersCards.add(new ContainerCard(credits[i], i, false));
        }//end for
        newCredits=new List<McaApp__Credit_Card__c>();
        return containersCards;
        //return credits;
    }//end getContainersCards
    
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
        newStatements = new McaApp__Bank_Account__c[] {};
        newCredits = new McaApp__Credit_Card__c[] {};
    }//end afterSave
    
    public void refresh() {
        afterSave();
        setInvalidBankRow.clear();
        setInvalidCreditRow.clear();
    }//end refresh

    public void editAll() {
        refresh();
        editAll = true;
    }//end editAll
    

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
                        bankMsgStr = bankMsgStr + 'Bank Statements Error: ' + err.getMessage() + ' For record with serial number : ' +(containersStatements[i].index +1) + '<br />';
                        //bankMsgStr = bankMsgStr + 'Error: ' + err.getMessage() + 'D\r\n' + err.getMessage();
                        setInvalidBankRow.add(i); 
                    }
                }
            }//end for
            if(!bankMsgStr.contains('Argument 2 cannot be null') && String.isNotBlank(bankMsgStr)) 
                ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,bankMsgStr));
            //upsert credits;
            List<Database.upsertResult> creditResults = Database.upsert(credits, false);
            for (Integer i = 0; i < creditResults.size(); i++) {
                if (!creditResults[i].isSuccess()){
                    for (Database.Error err : creditResults[i].getErrors()){
                        creditMsgStr = creditMsgStr + 'Credit Cards Sales Error: '+ err.getMessage() + ' For record with serial number : ' +(containersCards[i].index +1) + '<br />';
                        setInvalidCreditRow.add(i);
                      //creditMsgStr = creditMsgStr + 'Error: '+ err.getStatusCode() + ' ' + err.getMessage() +'</br>';
                    }//end for
                }//end if
            }//end for
            if(!creditMsgStr.contains('Argument 2 cannot be null') && String.isNotBlank(creditMsgStr)) 
                ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,creditMsgStr));
        } catch(Exception e){
            isValidation = true;
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,e.getMessage()));
        }//end try-catch
        afterSave();
    }//end saveAllSales
    
    public void bankAccountList(){
        mapIDANDBank.clear();
        mapIDANDBank = new Map<Id, McaApp__Bank_Account__c>([SELECT
                                                          Id,
                                                          McaApp__Month__c,
                                                          McaApp__Year__c,
                                                          McaApp__Deposits__c,
                                                          McaApp__Average_Daily_Balance__c,
                                                          McaApp__Number_of_NSFs__c,
                                                          McaApp__Number_of_Negative_Days__c,
                                                          McaApp__Include_in_average__c,
                                                          McaApp__Bank_Account_Number__c,
                                                          McaApp__No_Deposits__c
                                                  FROM McaApp__Bank_Account__c
                                                  WHERE McaApp__Opportunity__c = :opportunityId]);
    }//end bankAccountList
    
    public void newStatement() {
        updateRecords();
        newStatements.add(new McaApp__Bank_Account__c(McaApp__Opportunity__c = opportunityId,McaApp__Include_in_average__c = true));
    }//end newStatement
    
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
    }//end updateRecords
  
    public void updateInlineEditedBankValue() {
        String msgstr = '';
        setInvalidBankRow.clear();
        try{
            //update listToUpdateBank;
            List<Database.saveResult> results = Database.update(listToUpdateBank, false);
            for (Integer i = 0; i < results.size(); i++) {
                if (!results[i].isSuccess()){
                    for (Database.Error err : results[i].getErrors()){
                        msgstr = msgstr + 'Bank Statements Error: ' + err.getMessage() + ' For record with serial number : ' +(mapOfBankIndex.get(i)+1) + '<br />';
                        setInvalidBankRow.add(mapOfBankIndex.get(i));
                    }
                }//end if
            }//end for
            //msgStr = showResultMsg(results);
            if(!msgStr.contains('Argument 2 cannot be null') && String.isNotBlank(msgStr)) 
                ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,msgStr));
        } catch(Exception e){
            system.debug('***Enter In Exception****');
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,e.getMessage()));
        }//end try-catch
    }//end updateInlineEditedBankValue
    
    public void checkoldAndNewBankVal() {
        listToUpdateBank = new List<McaApp__Bank_Account__c>();
        McaApp__Bank_Account__c bankAccountValue = new McaApp__Bank_Account__c();
        bankAccountList();
        for (ContainerStatement containerVal: containersStatements) {
            if(containerVal.statement.id != null){
                bankAccountValue = mapIDANDBank.get(containerVal.statement.id);
                if(bankAccountValue !=null) {
                    if(containerVal.statement.McaApp__Month__c != bankAccountValue.McaApp__Month__c
                    || containerVal.statement.McaApp__Year__c != bankAccountValue.McaApp__Year__c
                    || containerVal.statement.McaApp__Deposits__c != bankAccountValue.McaApp__Deposits__c
                    || containerVal.statement.McaApp__No_Deposits__c != bankAccountValue.McaApp__No_Deposits__c
                    || containerVal.statement.McaApp__Average_Daily_Balance__c != bankAccountValue.McaApp__Average_Daily_Balance__c
                    || containerVal.statement.McaApp__Number_of_NSFs__c != bankAccountValue.McaApp__Number_of_NSFs__c
                    || containerVal.statement.McaApp__Number_of_Negative_Days__c != bankAccountValue.McaApp__Number_of_Negative_Days__c
                    || containerVal.statement.McaApp__Include_in_average__c != bankAccountValue.McaApp__Include_in_average__c
                    || containerVal.statement.McaApp__Bank_Account_Number__c != bankAccountValue.McaApp__Bank_Account_Number__c){
                        listToUpdateBank.add(containerVal.statement);
                        mapOfBankIndex.put(listToUpdateBank.size()-1, containerVal.index);
                        isUpdatedBank = true;
                    }//end if
                }//end if
            }//end if
        }//end for
    }//end checkoldAndNewBankVal
    
    public void newCredit() {
        updateRecords();
        newCredits.add(new McaApp__Credit_Card__c(McaApp__Opportunity__c = opportunityId,McaApp__Include_in_average__c = true));
    }//end newCredit
    
    public void updateInlineEditedCardValue() {
        String msgStr;
        setInvalidCreditRow.clear();
        try{
            //update listToUpdateCard;
            List<Database.saveResult> results = Database.update(listToUpdateCard, false);            
            for (Integer i = 0; i< results.size(); i++) {
                if (!results[i].isSuccess()){
                    for (Database.Error err : results[i].getErrors()){
                        msgStr = msgStr+ 'Credit Cards Sales Error: ' + err.getMessage() + ' For record with serial number : ' +(mapOfCreditIndex.get(i) +1) + ' <br />';
                        setInvalidCreditRow.add(mapOfBankIndex.get(i));
                    }//end for
                }//end if
            }//end for
            if(!msgStr.contains('Argument 2 cannot be null') && String.isNotBlank(msgStr)) 
                ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,msgStr));
        }
        catch(Exception e){
            system.debug('***Enter In Exception****');
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,e.getMessage()));
        }//end try-catch
    }//end updateInlineEditedCardValue
    
    public void checkoldAndNewCardVal() {
        listToUpdateCard = new List<McaApp__Credit_Card__c>();
        McaApp__Credit_Card__c creditCardValue = new McaApp__Credit_Card__c();
        cardAccountList();
        for (ContainerCard containerVal: containersCards) {
            if(containerVal.card.id != null){
                creditCardValue = mapIDANDCard.get(containerVal.card.id);
                if(creditCardValue != null) {
                    if(containerVal.card.McaApp__Month__c != creditCardValue.McaApp__Month__c
                    || containerVal.card.McaApp__Year__c != creditCardValue.McaApp__Year__c
                    || containerVal.card.McaApp__Total_Net_Processed_All__c != creditCardValue.McaApp__Total_Net_Processed_All__c
                    || containerVal.card.McaApp__Number_of_Transactions_All__c != creditCardValue.McaApp__Number_of_Transactions_All__c
                    || containerVal.card.McaApp__Processor_Name__c != creditCardValue.McaApp__Processor_Name__c
                    || containerVal.card.McaApp__Include_in_average__c != creditCardValue.McaApp__Include_in_average__c
                    || containerVal.card.McaApp__MID_Account_Number__c != creditCardValue.McaApp__MID_Account_Number__c
                    || containerVal.card.McaApp__Batches__c != creditCardValue.McaApp__Batches__c){
                        listToUpdateCard.add(containerVal.card);
                        mapOfCreditIndex.put(listToUpdateCard.size()-1, containerVal.index);
                        isUpdatedCard = true;
                    }//end if
                }//end if
            }//end if
        }//end for
    }//end checkoldAndNewCardVal
    
    public void cardAccountList(){
        mapIDANDCard.clear();
        mapIDANDCard = new Map<Id, McaApp__Credit_Card__c>([SELECT
                                                        Id,
                                                        McaApp__Month__c,
                                                        McaApp__Year__c,
                                                        McaApp__Total_Net_Processed_All__c,
                                                        McaApp__Number_of_Transactions_All__c,
                                                        McaApp__Processor_Name__c,
                                                        McaApp__Include_in_average__c,
                                                        McaApp__MID_Account_Number__c,
                                                        McaApp__Batches__c
                                                    FROM McaApp__Credit_Card__c
                                                    WHERE McaApp__Opportunity__c = :opportunityId]);
    }//end cardAccountList
    
    public void deleteStatement() {
        updateRecords();
        if (recordToDelete != null) {
            McaApp__Bank_Account__c record = [SELECT Id FROM McaApp__Bank_Account__c WHERE Id = :recordToDelete];
            try {
                delete record;
            }catch (Exception ex){
                indexToRemoveStatement = -99;
                indexToRemove= -99;
               // ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,MCAExceptionHandlerUtility.getErrorMessage(ex)));
            }//end try-catch
        }//end if 
     //getContainersStatements();
        system.debug('***depositsAverage***'+depositsAverage+'***balanceAverage***'+balanceAverage+'***nsfAverage***'+nsfAverage+'***negativeAverage**'+negativeAverage+'***processedAverage***'+processedAverage+'****transactionAverage****'+transactionAverage);
    }//end deleteStatement

    public void deleteCredit() {
        updateRecords();
        if (recordToDelete != null) {
            McaApp__Credit_Card__c record = [SELECT Id FROM McaApp__Credit_Card__c WHERE Id = :recordToDelete];
            try {
                delete record;
            }catch (Exception ex){
                indexToRemoveCredit = -99;
                indexToRemove = -99;
               // ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,MCAExceptionHandlerUtility.getErrorMessage(ex)));
            }//end try-catch
        }//end if
    }//end deleteCredit

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
        }//end if
    }//end removeCard

    public void removeStatement() {
        updateRecords();
        if (indexToRemove != null) {
            ContainerStatement c = null;
            for (ContainerStatement element :containersStatements) {
                if (element.index == indexToRemove) {
                    c = element;
                }
            }
            indexToRemoveStatement = indexToRemove;
            // newStatements.remove(c.index);
        }
    }//end removeStatement

    
    public class ContainerCard {

        public McaApp__Credit_Card__c card {get;set;}
        public Integer index {get;set;}
        public Boolean isedited {get;set;}
        public ContainerCard(McaApp__Credit_Card__c instance, Integer index, Boolean isedited) {
            card = instance;
            this.index = index;
            this.isedited = isedited;
        }
    }

    public class ContainerStatement {

        public McaApp__Bank_Account__c statement {get;set;}
        public Integer index {get;set;}
        public Boolean isedited {get;set;}
        public ContainerStatement(McaApp__Bank_Account__c instance, Integer index, Boolean isedited) {
            statement = instance;
            this.index = index;
            this.isedited = isedited;
        }
    }
}//end main class