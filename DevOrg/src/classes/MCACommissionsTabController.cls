public with sharing class MCACommissionsTabController {
    public Payable__c[] payables;
    public Receivable__c[] receivables;
    public Payable__c[] newPayables {get; set;}
    public Receivable__c[] newReceivables {get; set;}
    public ContainerPayable[] containerPayables;
    public ContainerReceivable[] containerReceivables;
    public Boolean editAll {get;set;}
    public Id recordToDelete {get;set;}
    public Integer indexToRemove {get;set;}
    public Integer indexToRemoveRec {get;set;}
    public boolean recAccesss {get;set;}
    public boolean payAccesss {get;set;}
    private Id opportunityId;
    public Decimal payableAmount {get; set;}
    public Decimal receivableAmount {get; set;}
    public Decimal payableAmountDue {get; set;}
    public Decimal receivableAmountDue {get; set;}
    public Boolean isFirstPayable;
    public Boolean isFirstReceivable;
    public Boolean isUpdatedReceivable;
    public Map<Id, Receivable__c> mapIDANDReceivable;
    public List<Receivable__c> listToUpdateReceivable;
    public Boolean isUpdatedPayable;
    public Set<Integer> setInvalidReceivableRow;
    public Set<Integer> setInvalidPayableRow;
    public Map<Id, Payable__c> mapIDANDPayable;
    public List<Payable__c> listToUpdatePayable;
    public Boolean isValidation;
    Map<Integer, Integer> mapOfPayIndex;
    Map<Integer, Integer> mapOfRecIndex;
    
    //constructor
    public MCACommissionsTabController() {
        isFirstPayable = true;
        isFirstReceivable = true;
        isValidation = false;
        setInvalidReceivableRow = new Set<Integer>();
        setInvalidPayableRow = new Set<Integer>();
        mapIDANDReceivable = new Map<Id, Receivable__c>();
        mapIDANDPayable = new Map<Id, Payable__c>();
        mapOfPayIndex = new Map<Integer, Integer>();
        mapOfRecIndex = new Map<Integer, Integer>();
        opportunityId = Apexpages.currentPage().getParameters().get('id');
        recAccesss = Schema.sObjectType.Receivable__c.isAccessible();
        payAccesss = Schema.sObjectType.Payable__c.isAccessible();
        refresh();
    }

    public String selectPayableStatus{get;set;}

    public list<SelectOption> lstselectPayableStatus= new list<SelectOption>();

    public list<SelectOption> getselectPayableStatusOption(){
        lstselectPayableStatus = new list<SelectOption>();
        // Use DescribeFieldResult object to retrieve status field
        Schema.DescribeFieldResult statusFieldDescription = Payable__c.Status__c.getDescribe();
        // For each picklist value, create a new select option
        for (Schema.Picklistentry picklistEntry : statusFieldDescription.getPicklistValues()) {
            lstselectPayableStatus.add(new SelectOption (pickListEntry.getValue(),pickListEntry.getLabel())); 
        }//end for
        return lstselectPayableStatus;
    }//end getselectPayableStatusOption

    public String selectReceivableStatus{get;set;}

    public list<SelectOption> lstselectReceivableStatus= new list<SelectOption>();

    public list<SelectOption> getselectReceivableStatusOption(){
        lstselectReceivableStatus= new list<SelectOption>();
        Schema.DescribeFieldResult statusFieldDescription = Receivable__c.Status__c.getDescribe();
        // For each picklist value, create a new select option
        for (Schema.Picklistentry picklistEntry : statusFieldDescription.getPicklistValues()) {
            lstselectReceivableStatus.add(new SelectOption (pickListEntry.getValue(),pickListEntry.getLabel())); 
        }
        return lstselectReceivableStatus;
    }

    public ContainerPayable[] getPayables() {
        payableAmount = 0;
        payableAmountDue = 0;
        payables = new Payable__c[] {};
        payableList();
        payables.addAll(newPayables);
        if(isFirstPayable && !editAll && !isValidation && setInvalidPayableRow.size() <= 0) {
            isFirstPayable = false;
            for (Payable__c py :mapIDANDPayable.values()) {
                payables.add(py);
                calculatePayable(py);
            }
        } else {
            for (ContainerPayable containerVal: containerPayables) {
                if(containerVal.payable.id != null && containerVal.index != indexToRemove){
                    //if(!editAll)
                        //payables.add(mapIDANDPayable.get(containerVal.payable.id));
                    //else
                    payables.add(containerVal.payable);
                    calculatePayable(mapIDANDPayable.get(containerVal.payable.id));
                }else if(containerVal.index != indexToRemove) 
                    payables.add(containerVal.payable);
            }
        }
        indexToRemove = -1;
        containerPayables = new ContainerPayable[] {};
        for (Integer i = 0; i < payables.size(); i++) {
            if(setInvalidPayableRow.contains(i - newPayables.size()))
                containerPayables.add(new ContainerPayable(payables[i], i, true));
            else
                containerPayables.add(new ContainerPayable(payables[i], i, false));
        }
        newPayables = new List<Payable__c>();
        return containerPayables;
    }//end getPayables
    
    public void calculatePayable(Payable__c py) {
        if(py != null){
            payableAmount += (py.Amount_Due__c == null) ? 0 : py.Amount_Due__c;
            payableAmountDue += (py.Bill_Amount_Due__c == null) ? 0 : py.Bill_Amount_Due__c;
        }
        
    }//end calculatePayable
    
    //It is used query all the present task for the opportunity
    public void payableList() {
        
        mapIDANDPayable.clear();
        mapIDANDPayable = new Map<id, Payable__c>([SELECT
                      Id,
                      Payback_Funded__c,
                      Bill_Amount_Due__c,
                      Percentage__c,
                      Due_Date__c,
                      Amount_Due__c,
                      Account__c,
                      Type__c,
                      Status__c,
                      Memo__c
                FROM Payable__c
                WHERE Opportunity__c = :opportunityId]);
    }//end payableList
    
    //It is used query all the present task for the opportunity
    public void receivablesList() {
        
        mapIDANDReceivable.clear();
        mapIDANDReceivable = new Map<Id, Receivable__c>([SELECT
                      Id,
                      Payback_Funded__c,
                      Amount__c,
                      Percentage__c,
                      Due_Date__c,
                      Amount_Due__c,
                      Due_From_Account__c,
                      Type__c,
                      Status__c,
                      Memo__c
                  FROM Receivable__c
                  WHERE Opportunity__c = :opportunityId]);
    }//end receivablesList
    
    public void save(){}
    
    public ContainerReceivable[] getReceivables() {
        receivableAmount = 0;
        receivableAmountDue = 0;
        receivablesList();
        receivables = new Receivable__c[] {};
        receivables.addAll(newReceivables);
        if(isFirstReceivable && !editAll && !isValidation && setInvalidReceivableRow.size() <= 0){
            isFirstReceivable = false;
            for (Receivable__c rc : mapIDANDReceivable.values()) {
                calculateRec(rc);
                receivables.add(rc);
            }
        }else {
            for (ContainerReceivable containerVal: containerReceivables) {
                if(containerVal.index != indexToRemoveRec && containerVal.receivable.id != null){
                    //if(!editAll)
                        //receivables.add(mapIDANDReceivable.get(containerVal.receivable.id));
                    //else
                    receivables.add(containerVal.receivable);
                    calculateRec(mapIDANDReceivable.get(containerVal.receivable.id));
                }else if(containerVal.index != indexToRemoveRec) 
                    receivables.add(containerVal.receivable);
            }
        }
        indexToRemoveRec = -1;
        
        containerReceivables = new ContainerReceivable[] {};
        for (Integer i = 0; i < receivables.size(); i++) {
            if(setInvalidReceivableRow.contains(i - newReceivables.size()))
                containerReceivables.add(new ContainerReceivable(receivables[i], i, true));
            else
                containerReceivables.add(new ContainerReceivable(receivables[i], i, false));
        }
        newReceivables = new List<Receivable__c>();
        return containerReceivables;
    }//end getReceivables
    
    public void calculateRec(Receivable__c rc){
        if(rc != null){
            receivableAmount += rc.Amount__c != null ? rc.Amount__c : 0;
            receivableAmountDue += rc.Amount_Due__c != null ? rc.Amount_Due__c : 0;
        }
        
    }//end calculateRec
    
    public void afterSave() {
        isFirstReceivable = true;
        isFirstPayable = true;
        recordToDelete = null;
        editAll = false;
        payableAmount = 0;
        receivableAmount = 0;
        payableAmountDue = 0;
        receivableAmountDue = 0;
        newReceivables = new Receivable__c[] {};
        newPayables = new Payable__c[] {};
    }//end afterSave
    
    public void refresh() {
        afterSave();
        setInvalidPayableRow.clear();
        setInvalidReceivableRow.clear();
    }//end refresh
    
    public PageReference saveAllCommissions() {
        String receivablesMsgStr = '';
        String payablesMsgStr = '';
        setInvalidPayableRow.clear();
        setInvalidReceivableRow.clear();
        isValidation = false;
        try{
            //upsert payables;
            List<Database.upsertResult> receivablesResults= Database.upsert(receivables, false);
            for (Integer i = 0; i<receivablesResults.size();i++) {
                if (!receivablesResults[i].isSuccess()){
                    for (Database.Error err : receivablesResults[i].getErrors()){
                        //receivablesMsgStr = receivablesMsgStr +  'Error: ' + result.getId() + ' ' + err.getMessage();
                        receivablesMsgStr = receivablesMsgStr + 'Receivables Error: '  + err.getMessage() + ' For record with serial number : ' +(containerReceivables[i].index +1) +'<br />';
                        setInvalidReceivableRow.add(i);
                    }
                }
            }
            if(!receivablesMsgStr.contains('Argument 2 cannot be null') && String.isNotBlank(receivablesMsgStr )) 
                ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,receivablesMsgStr ));
            
            //upsert receivables;
            List<Database.upsertResult> payablesResults = Database.upsert(payables, false);
            for (Integer i = 0; i< payablesResults.size(); i++) {
                if (!payablesResults[i].isSuccess()){
                    for (Database.Error err : payablesResults[i].getErrors()){
                        //payablesMsgStr = payablesMsgStr +  'Error: ' +err.getDmlId + ' ' + err.getMessage();
                        payablesMsgStr = payablesMsgStr + 'Payables Error: ' + err.getMessage() + ' For record with serial number : ' +(containerPayables[i].index +1) +'<br />';
                        setInvalidPayableRow.add(i);
                    }
                }
            }
            if(!payablesMsgStr.contains('Argument 2 cannot be null') && String.isNotBlank(payablesMsgStr)) 
                ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,payablesMsgStr));
        }
        catch(Exception e){
            if (!(e.getMessage().contains('Status cannot be Paid if the Amount Due not equal to 0'))){
                ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,e.getMessage()));
            }
            isValidation = true;
        }
        afterSave();
        return null;
    }//end saveAllCommissions

    public void editAll() {
        refresh();
        editAll = true;
    }//end editAll

    public void newPayable() {
        updateRecord();
        newPayables.add(new Payable__c(Opportunity__c = opportunityId,IsCreatedFromGrid__c = true));
    }//end newPayable
    
    public void updateRecord() {
        
        isUpdatedPayable = false;
        String errorMSG = '';
        checkoldAndNewPayableVal();
        if(editAll !=true && isUpdatedPayable == true){
            errorMSG = 'All changes have been saved';
            updateInlineEditedPayableValue();
        }
        isUpdatedReceivable = false;
        checkoldAndNewReceivableVal();
        if(editAll !=true && isUpdatedReceivable == true){
            errorMSG = 'All changes have been saved';
            updateInlineEditedReceValue();
        }
        if (errorMSG != '')
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,'All changes have been saved.'));
    }//end updateRecord
    
    public void updateInlineEditedPayableValue() {
        String msgStr = '';
        setInvalidPayableRow.clear();
        try{
           // update listToUpdatePayable;
            List<Database.saveResult> results = Database.update(listToUpdatePayable, false);
            for (Integer i = 0; i< results.size(); i++) {
                if (!results[i].isSuccess()){
                    for (Database.Error err : results[i].getErrors()){
                        msgStr = msgStr + 'Payables Error: ' + err.getMessage()+ ' For record with serial number : ' +(mapOfPayIndex.get(i)+1) +'<br />';
                        setInvalidPayableRow.add(mapOfPayIndex.get(i));
                    }
                }
            }
            if(!msgStr.contains('Argument 2 cannot be null') && String.isNotBlank(msgStr)) 
                ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,msgStr));
        }
        catch(Exception e){
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,e.getMessage()));
        }
    }//end updateInlineEditedPayableValue
    
    public void checkoldAndNewPayableVal() {
        system.debug('containerPayables ---------->'+containerPayables);
        listToUpdatePayable = new List<Payable__c>();
        Payable__c  payableValue = new Payable__c ();
        mapOfPayIndex.clear(); 
        payableList();
        for (ContainerPayable containerVal: containerPayables) {
            if(containerVal.payable.id != null){
                system.debug('containerPayables ---------->'+containerPayables);
                payableValue = mapIDANDPayable.get(containerVal.payable.id);
                if(payableValue != null){
                    if(containerVal.payable.Type__c !=payableValue.Type__c
                    || containerVal.payable.Account__c !=payableValue.Account__c
                    || containerVal.payable.Amount_Due__c !=payableValue.Amount_Due__c
                    || containerVal.payable.Bill_Amount_Due__c !=payableValue.Bill_Amount_Due__c
                    || containerVal.payable.Percentage__c !=payableValue.Percentage__c
                    || containerVal.payable.Payback_Funded__c !=payableValue.Payback_Funded__c
                    || containerVal.payable.Memo__c !=payableValue.Memo__c
                    || containerVal.payable.Due_Date__c !=payableValue.Due_Date__c
                    || containerVal.payable.Status__c !=payableValue.Status__c) {
                        listToUpdatePayable.add(containerVal.payable);
                        mapOfPayIndex.put(listToUpdatePayable.size() - 1, containerVal.index);
                        isUpdatedPayable = true;
                    }
                }
            }
        }
    }//end checkoldAndNewPayableVal

    public void newReceivable() {
        updateRecord();
        newReceivables.add(new Receivable__c(Opportunity__c = opportunityId,IsCreatedFromGrid__c = true));
    }//end newReceivable
    
    public void updateInlineEditedReceValue() {
        String msgStr = '';
        setInvalidReceivableRow.clear();
        try{
            //update listToUpdateReceivable;
            List<Database.saveResult> results = Database.update(listToUpdateReceivable, false);
            for (Integer i = 0; i < results.size(); i++) {
                if (!results[i].isSuccess()){
                    for (Database.Error err : results[i].getErrors()){
                        msgStr = msgStr + 'Receivables Error: ' + err.getMessage() + ' For record with serial number : ' +(mapOfRecIndex.get(i)+1) +'<br />';
                        setInvalidReceivableRow.add(mapOfRecIndex.get(i));
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
    }//end updateInlineEditedReceValue
    
    public void checkoldAndNewReceivableVal() {
        system.debug('containerReceivables ---------->'+containerReceivables);
        listToUpdateReceivable = new List<Receivable__c>();
        Receivable__c receivableValue = new Receivable__c ();
        mapOfRecIndex.clear();
        receivablesList();
        for (ContainerReceivable containerVal: containerReceivables) {
            if(containerVal.receivable.id != null){
               receivableValue = mapIDANDReceivable.get(containerVal.receivable.id);
                if(receivableValue != null) {
                    if(containerVal.receivable.Payback_Funded__c !=receivableValue.Payback_Funded__c
                    || containerVal.receivable.Amount__c !=receivableValue.Amount__c
                    || containerVal.receivable.Percentage__c !=receivableValue.Percentage__c
                    || containerVal.receivable.Due_Date__c !=receivableValue.Due_Date__c
                    || containerVal.receivable.Amount_Due__c !=receivableValue.Amount_Due__c
                    || containerVal.receivable.Due_From_Account__c !=receivableValue.Due_From_Account__c
                    || containerVal.receivable.Type__c !=receivableValue.Type__c
                    || containerVal.receivable.Status__c !=receivableValue.Status__c
                    || containerVal.receivable.Memo__c !=receivableValue.Memo__c){
                        listToUpdateReceivable.add(containerVal.receivable);
                        mapOfRecIndex.put(listToUpdateReceivable.size() - 1, containerVal.index);
                        isUpdatedReceivable = true;
                    }
                }
            }
        }
    }//end checkoldAndNewReceivableVal

    public void deletePayable() {
        updateRecord();
        if (recordToDelete != null) {
            Payable__c record = [SELECT Id FROM Payable__c WHERE Id = :recordToDelete];
            try {
                delete record;
            }catch (Exception ex){
                indexToRemove = -1;
                ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,MCAExceptionHandlerUtility.getErrorMessage(ex)));
            }
        }
    }//end deletePayable

    public void deleteReceivable() {
        updateRecord();
        if (recordToDelete != null) {
            Receivable__c record = [SELECT Id FROM Receivable__c WHERE Id = :recordToDelete];
            try {
                delete record;
            }catch (Exception ex){
                indexToRemoveRec = -1;
                ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,MCAExceptionHandlerUtility.getErrorMessage(ex)));
            }
        }
    }//end deleteReceivable
    
    
    public void removeCommission() {
        updateRecord();
    }//end removeCommission
    
    public class ContainerReceivable {
        public Receivable__c receivable {get;set;}
        public Integer index {get;set;}
        public Boolean isedited {get;set;}
        public ContainerReceivable(Receivable__c instance, Integer index, Boolean isedited) {
            receivable = instance;
            this.index = index;
            this.isedited = isedited;
        }
    }//end inner class ContainerReceivable

    public class ContainerPayable {
        public Payable__c payable {get;set;}
        public Integer index {get;set;}
        public Boolean isedited {get;set;}
        public ContainerPayable(Payable__c instance, Integer index, Boolean isedited) {
            payable = instance;
            this.index = index;
            this.isedited = isedited;
        }
    }//end inner class ContainerPayable
}//end main class