public with sharing class MCASyndicationTabController {

    public Syndication__c[] syndications;
    public Container[] containers;

    public Syndication__c[] newSyndications {get; set;}

    public Boolean editAll {get;set;}

    public Id recordToDelete {get;set;}
    public Integer indexToRemove {get;set;}

    private Id opportunityId;

    public Decimal amount {get;set;}
    public Decimal servicingFee {get;set;}
    public Decimal commissionFee {get;set;}
    public Boolean isFirst;
    public Boolean isUpdated;
    public Map<Id, Syndication__c> mapIDANDSyndication;
    public List<Syndication__c> listToUpdate;
    public Set<Integer> setInvalidRow;
    public Boolean isValidation;
    Map<Integer, Integer> mapOfIndex;
    
    public MCASyndicationTabController() {
        mapIDANDSyndication = new Map<Id, Syndication__c>();
        mapOfIndex = new Map<Integer, Integer>();
        newSyndications = new Syndication__c[] {};
        setInvalidRow = new Set<Integer>();
        isFirst = true;
        isValidation = false;
        opportunityId = Apexpages.currentPage().getParameters().get('id');
        refresh();
    }

    public Container[] getContainers() {

        amount = 0;
        commissionFee = 0;
        servicingFee = 0;

        syndications = new Syndication__c[] {};
        syndicationList();
        syndications.addAll(newSyndications);
        if(isFirst && !editAll && !isValidation && setInvalidRow.size() <= 0) {
            isFirst = false;
            for (Syndication__c sy : mapIDANDSyndication.values()) {
                syndications.add(sy);
                calculateVal(sy);
            }
        }else {
            for (Container containerVal: containers) {
                if(containerVal.syndication.id != null && containerVal.index != indexToRemove){
                    if(!editAll && setInvalidRow.size() <= 0)
                        syndications.add(mapIDANDSyndication.get(containerVal.syndication.id));
                    else
                        syndications.add(containerVal.syndication);
                    calculateVal(mapIDANDSyndication.get(containerVal.syndication.id));
                }else if(containerVal.index != indexToRemove )
                    syndications.add(containerVal.syndication);
            }
        }
        indexToRemove = -1;
        containers = new Container[] {};
        for (Integer i = 0; i < syndications.size(); i++) {
            if(setInvalidRow.contains(i - newSyndications.size()))
                containers.add(new Container(syndications[i], i, true));
            else
                containers.add(new Container(syndications[i], i, false));
        }
        newSyndications = new List<Syndication__c>();
        return containers;
    }
    
    public void calculateVal(Syndication__c sy) {
        amount += sy.Syndication_Amt__c != null ? sy.Syndication_Amt__c : 0;
        commissionFee += sy.Commission_Fee__c != null ? sy.Commission_Fee__c : 0;
        servicingFee += sy.Servicing_Fee__c != null ? sy.Servicing_Fee__c : 0;
    }
    //It is used query all the present task for the opportunity
    public void syndicationList() {
        
        mapIDANDSyndication.clear();
        mapIDANDSyndication = new Map<Id, Syndication__c> ([SELECT
                    Id,
                    Syndication_Amt__c,
                    Servicing_Fee__c,
                    Commission_Fee__c,
                    Disbursment_Schedule__c,
                    Syndicated_By__c,
                    Profit_Amount__c,
                    ROR_per__c,
                    Syndication_Percentage__c,
                    Memo__c
                FROM Syndication__c
                WHERE Opportunity__c = :opportunityId]);
    }

    public void newSyndication() {
        saveMessage();
        newSyndications.add(new Syndication__c(Opportunity__c = opportunityId));
    }
    
    public void saveMessage(){
        isUpdated = false;
        checkoldAndNewVal();
        if(editAll !=true && isUpdated == true){
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,'All changes have been saved.'));
            updateInlineEditedValue();
        }
    }
    
    public void updateInlineEditedValue() {
        String msgStr = '';
        setInvalidRow.clear();
        try{
            //update listToUpdate;
            List<Database.saveResult> results = Database.update(listToUpdate, false);
            for (Integer i = 0 ;i < results.size(); i++) {
              if (!results[i].isSuccess()){
                  for (Database.Error err : results[i].getErrors()){
                      msgStr = msgStr + 'Error: ' + err.getMessage() + ' For record with serial number : ' +(mapOfIndex.get(i) +1) + '<br />';
                  
                      setInvalidRow.add(mapOfIndex.get(i));
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
    public void checkoldAndNewVal() {
        listToUpdate = new List<Syndication__c>();
        Syndication__c  syndicationValue = new Syndication__c();
        mapOfIndex.clear();
        syndicationList();
        for (Container containerVal: containers) {
            if(containerVal.syndication.id != null){
               syndicationValue = mapIDANDSyndication.get(containerVal.syndication.id);
               if(syndicationValue != null) {
                    if(containerVal.syndication.Syndication_Amt__c !=syndicationValue.Syndication_Amt__c
                    || containerVal.syndication.Servicing_Fee__c !=syndicationValue.Servicing_Fee__c
                    || containerVal.syndication.Commission_Fee__c !=syndicationValue.Commission_Fee__c
                    || containerVal.syndication.Disbursment_Schedule__c !=syndicationValue.Disbursment_Schedule__c
                    || containerVal.syndication.Syndicated_By__c !=syndicationValue.Syndicated_By__c
                    || containerVal.syndication.Profit_Amount__c !=syndicationValue.Profit_Amount__c
                    || containerVal.syndication.ROR_per__c !=syndicationValue.ROR_per__c
                    || containerVal.syndication.Syndication_Percentage__c !=syndicationValue.Syndication_Percentage__c
                    || containerVal.syndication.Memo__c !=syndicationValue.Memo__c){
                        listToUpdate.add(containerVal.syndication);
                        mapOfIndex.put(listToUpdate.size()-1, containerVal.index);
                        isUpdated = true;
                    }
                }
            }
        }
    }
    public void save(){}
    public void afterSave() {
        isFirst = true;
        amount = 0;
        commissionFee = 0;
        servicingFee = 0;
        recordToDelete = null;
        editAll = false;
    }
    public void refresh() {
        afterSave();
        setInvalidRow.clear();
    }

    public void saveAllSyndications(){
        isValidation = false;
        String msgStr = '';
        setInvalidRow.clear();
        try{
            //upsert syndications;
            List<Database.upsertResult> results = Database.upsert(syndications, false);
            for ( Integer i =0 ;i < results.size(); i++ ) {
              if (!results[i].isSuccess()){
                  for (Database.Error err : results[i].getErrors()){
                      msgStr = msgStr + 'Error: ' + err.getMessage() + ' For record with serial number : ' +(containers[i].index +1) + '<br />';
                      setInvalidRow.add(i);
                  }
              }
           }
           if(!msgStr.contains('Argument 2 cannot be null') && String.isNotBlank(msgStr)) 
               ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,msgStr));
        }
        catch(Exception e){
            isValidation = true;
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,e.getMessage()));
        }
        afterSave();
    }

    public void editAll() {
        refresh();
        editAll = true;
    }
    public void removeSyndication() {
        saveMessage();
    }

    public void deleteSyndication() {
        saveMessage();
        if (recordToDelete != null) {
            Syndication__c record = [SELECT Id FROM Syndication__c WHERE Id = :recordToDelete];
            try {
                delete record;
            }catch (Exception ex){
                indexToRemove = -1;
                ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,MCAExceptionHandlerUtility.getErrorMessage(ex)));
            }
        }
    }

    public class Container {
        public Syndication__c syndication {get;set;}
        public Integer index {get;set;}
        public Boolean isedited {get;set;}
        public Container(Syndication__c instance, Integer index, Boolean isedited) {
            syndication = instance;
            this.index = index;
            this.isedited = isedited;
        }
    }
}