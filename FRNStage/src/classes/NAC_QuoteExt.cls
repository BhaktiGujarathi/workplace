public class NAC_QuoteExt{
    public String quoteId;  
    public List<QuoteLineItemWrp> lineItemWrp {get;set;}
    public Integer rowToRemove {get;set;}
    public List<PaymentMethodWrp> paymentMethodWrpList {get;set;}
    public Map<Id,QuoteLineItem> quoteLineItemMap;
    public Map<Id,Product2> productMap {get;set;}
    public Map<Id,Id> prdPriceBookMap;
    public Quote quoteObj {get;set;}
    //public boolean selectedPaymentErr{get;set;}
    public Set<String> product2Ids;
    public integer uniquePaymentNo;
    public integer uniquePatConNo;
    public List<PatientContactsWrp> patConWrpList;
    public Patient_Contact__c patcon {get;set;}
    public Integer paymentToProcess {get;set;}
    public List<FuturePaymentWrp> ftrPytWrpList {get;set;}
    public decimal totalRemaining {get;set;}
    public decimal totalPaymentAmount {get;set;}
    public boolean isOutpatientTreatment {get; set;}
    //public decimal Discharge_Balance;
    
    public NAC_QuoteExt(){   
        quoteId = ApexPages.currentPage().getParameters().get('Qid');
        isOutpatientTreatment = false;
        lineItemWrp = new List<QuoteLineItemWrp>();
        paymentMethodWrpList = new List<PaymentMethodWrp>();
        prdPriceBookMap = new Map<Id,Id>();
        product2Ids = new Set<String>();
        patConWrpList = new List<PatientContactsWrp>();
        ftrPytWrpList = new List<FuturePaymentWrp>();
        uniquePaymentNo = 0;
        uniquePatConNo = 0;
        paymentToProcess = 0;
        totalRemaining = 0.00;
        totalPaymentAmount = 0.00;
        patcon = new Patient_Contact__c();
        ID outpatientRecordTypeId = Schema.SObjectType.Opportunity.getRecordTypeInfosByName().get('Outpatient Treatment').getRecordTypeId(); 
            
            quoteObj = [Select Id,
                               Pricebook2Id,
                               OpportunityId,
                               Additional_Comments__c,
                               Opportunity.Contact__c,
                               Opportunity.Contact__r.name,
                               Opportunity.Contact__r.FirstName,
                               Opportunity.Contact__r.LastName,
                               Opportunity.RecordTypeId 
                          from Quote 
                         where Id =:quoteId];
            System.debug('quoteObj.....>>>'+quoteObj.Pricebook2Id);
            if(outpatientRecordTypeId == quoteObj.Opportunity.RecordTypeId){        
                isOutpatientTreatment = true;       
            }
            
            quoteLineItemMap = new Map<Id,QuoteLineItem>([Select Id,QuoteId,Auto_Added__c,Product2Id,UnitPrice,Product2.Family,Product2.Payment_Application_Order__c,Product2.Name FROM QuoteLineItem WHERE QuoteId =: quoteId ORDER BY Product2.Family ASC]); 
            System.debug('quoteLineItemMap_____________________ '+quoteLineItemMap);            
            
            List<Id> qlids = new List<Id>();        
            List<Id> payIds = new List<Id>();           
            Map<Id,Payment__c> mapExistingPayments = new Map<Id,Payment__c>();
            Map<String, Treatment_Cost_Payment__c> mapExistingTCP = new Map<String, Treatment_Cost_Payment__c>();
            
            for(Payment__c pay:[Select Type__c,Payment_Method__c, Last_4__c,Payment_Amount__c,Balance__c,Cardholder__c,Date__c , Reference_Confirmation_Number__c, Treatment_Cost_Line_Item__c  from Payment__c where Treatment_Cost_Line_Item__c in :quoteLineItemMap.keySet()]){
                mapExistingPayments.put(pay.Treatment_Cost_Line_Item__c,pay);
                payIds.add(pay.Id);
            }
            System.debug('mapExistingPayments...............>>>'+mapExistingPayments);
            for(Treatment_Cost_Payment__c tcpobj:[Select Id, Applied_Amount__c, Applied_Date__c, Collect_At__c, Comments__c, Payment__c, Quote_Line_Item__c, type__c,Payment__r.Type__c,Payment__r.Last_4__c from Treatment_Cost_Payment__c where Payment__c in :payIds and Quote_Line_Item__c in :quoteLineItemMap.keySet()]){
                String uniqueId = tcpobj.Quote_Line_Item__c+'#'+tcpobj.Payment__c;
                mapExistingTCP.put(uniqueId,tcpobj);
            }
            
            //Future Payment Wrapper List
            FuturePaymentWrp ftrPytWrp;
            for(Future_Payment__c ftrPyt:[Select Id,Balance_to_Collect__c,Collect_Balance_at__c,Quote__c FROM Future_Payment__c WHERE Quote__c=:quoteId]){
                ftrPytWrp = new FuturePaymentWrp();
                ftrPytWrp.ftrPyt = ftrPyt;
                ftrPytWrp.index = ftrPytWrpList.size()-1;
                ftrPytWrpList.add(ftrPytWrp);
            }
            
            productMap = new Map<Id,Product2>([Select Id,Name,Family,Auto_Add_to_Quote_Line_Items__c,Available_to_Collect_at__c,Payment_Application_Order__c,Sort_Order__c from Product2 ORDER By Payment_Application_Order__c ASC]);
            
            QuoteLineItemWrp qilWrp;            
            for(QuoteLineItem qli:quoteLineItemMap.values()){ 
                System.debug('mapExistingPayments.get(qilWrp.qli.Id)........>>>');          
                qilWrp = new QuoteLineItemWrp();
                qilWrp.qli = qli;    
                product2Ids.add(qilWrp.qli.Product2Id);             
                qilWrp.selectedFamilyType = (productMap.get(qli.Product2Id)).Family;
                System.debug('selectedFamilyType_____________________________ '+qilWrp.selectedFamilyType);
                qilWrp.collectedAt.add(new SelectOption('','--None--'));
                if((productMap.get(qli.Product2Id)).Available_to_Collect_at__c!=null){
                    String[] collectAt = ((productMap.get(qli.Product2Id)).Available_to_Collect_at__c).split(';');
                    for(String clc:collectAt){
                        qilWrp.collectedAt.add(new SelectOption(clc,clc));
                    }
                }
                qilWrp.productName = qli.Product2.Name; 
                if(qli.Product2.Payment_Application_Order__c!=null)
                    qilWrp.productOrder = Integer.valueOf(qli.Product2.Payment_Application_Order__c);       
                System.debug('mapExistingPayments.get(qilWrp.qli.Id)........>>>'+mapExistingPayments.get(qilWrp.qli.Id));
                if(mapExistingPayments.containsKey(qilWrp.qli.Id)){
                    qilWrp.PayCstPyt = mapExistingPayments.get(qilWrp.qli.Id);
                
                    String uniqueId = qilWrp.qli.Id+'#'+qilWrp.PayCstPyt.Id;
                    if(mapExistingTCP.containsKey(uniqueId))
                        qilWrp.trtCstPyt = mapExistingTCP.get(uniqueId);
                    else
                        qilWrp.trtCstPyt = new Treatment_Cost_Payment__c();
                } else {
                    qilWrp.PayCstPyt = new Payment__c();    
                    qilWrp.trtCstPyt = new Treatment_Cost_Payment__c();
                }                   
                qilWrp.isReadOnly = true;
                qilWrp.index = lineItemWrp.size()-1;
                if(qilWrp.PayCstPyt.Balance__c!=null)
                    totalRemaining += qilWrp.PayCstPyt.Balance__c;
                if(qilWrp.PayCstPyt.Payment_Amount__c!=null)
                    totalPaymentAmount += qilWrp.PayCstPyt.Payment_Amount__c;
                lineItemWrp.add(qilWrp);  
                qlids.add(qli.id);              
            }
            System.debug('lineItemWrp ::>'+lineItemWrp);
            
            Id FRNPbId;
            if(quoteObj.Pricebook2Id != null){
                FRNPbId = quoteObj.Pricebook2Id;
                System.debug('FRNPbId_________________________ '+FRNPbId);
            }else{
                Default_Pricebook__c pricebookName = Default_Pricebook__c.getValues('FRN Price Book');
                if(pricebookName!=null){
                    FRNPbId = [select id, name, isActive from Pricebook2 where Name=:pricebookName.Default_Pricebook_Name__c limit 1].Id;
                    System.debug('FRNPbId_________________________ '+FRNPbId);
                    quoteObj.Pricebook2Id = FRNPbId; 
                }                   
            }    
  
            for(PricebookEntry pBookEntry:[Select Id, Name, Product2Id from PricebookEntry WHERE Pricebook2Id =:FRNPbId]){
                prdPriceBookMap.put(pBookEntry.Product2Id,pBookEntry.Id);
                System.debug('pBookEntry_________________________ '+pBookEntry);                
            }
                System.debug('prdPriceBookMap_________________________ '+prdPriceBookMap);
                
            PatientContactsWrp patConWrp;
            for(Patient_Contact__c pCon:[Select Id,First_Name__c,Last_Name__c FROM Patient_Contact__c Where Opportunity__c=:quoteObj.OpportunityId AND (First_Name__c!=null OR Last_Name__c!=null) Order by CreatedDate DESC]){
                patConWrp = new PatientContactsWrp();
                patConWrp.record = pCon;
                patConWrp.uniqueNmbr = uniquePatConNo++;
                patConWrpList.add(patConWrp);
            }
       // }
              
        
        PaymentMethodWrp pytWrp;  
        String value;
        for(Payment_Method__c pyt:[Select Id,Last_4__c,Type__c,Cardholder__c,Cardholder__r.First_Name__c, Cardholder__r.Last_Name__c,Cardholder_is_Patient__c,Opportunity__c,Total_Payment_Amount__c,Payment_Date__c,Reference_Confirmation_Number__c,Total_Amount_Remaining__c  FROM Payment_Method__c where Quote__c =:quoteObj.id Order By CreatedDate ASC]){
            pytWrp = new PaymentMethodWrp();
            pytWrp.pyt = pyt;
            pytWrp.index = paymentMethodWrpList.size()-1;
            pytWrp.uniqueNo = uniquePaymentNo++;
            if(pyt.Cardholder_is_Patient__c && quoteObj!=null && quoteObj.Opportunity.Contact__c!=null){
                pytWrp.selectedCardHolder = quoteObj.Opportunity.Contact__c;
                pytWrp.selectedHolderName =  quoteObj.Opportunity.Contact__r.name;
            } else if(pyt.Cardholder__c!=null){
                pytWrp.selectedCardHolder = pyt.Cardholder__c;
                pytWrp.selectedHolderName = pyt.Cardholder__r.First_Name__c+''+ pyt.Cardholder__r.Last_Name__c;
            }
            paymentMethodWrpList.add(pytWrp);
        }
        if(lineItemWrp.size()==0){
            addNewQLIObj();
        }
        if(paymentMethodWrpList.size()==0){
            addNewPytObj();
        }       
        if(ftrPytWrpList.size()==0){
            addNewFtrPyt();
        }
        Render();
        getPostDischarge_Balance();
        getInsuranceCost_Charge();
    }
    
    public Decimal getTotalUnitPrice(){     
        decimal totalUnitPrice = 0.00;
        for(QuoteLineItemWrp qliW:lineItemWrp){ 
            System.debug('qliW.qli.UnitPrice....... '+qliW.qli.UnitPrice);
            if(qliW.qli.UnitPrice != null){
                totalUnitPrice = totalUnitPrice + qliW.qli.UnitPrice;
                System.debug('totalUnitPrice_____________ '+totalUnitPrice);
            }
        }       
        return totalUnitPrice;
    }
    
    public List<SelectOption> getCardHolders(){
        List<SelectOption> crdHolders = new List<SelectOption>();
        crdHolders.add(new SelectOption('','--None--'));
        if(quoteObj!=null){         
            if(quoteObj.Opportunity.Contact__c!=null){
                String conName;
                if(quoteObj.Opportunity.Contact__r.FirstName!=null)
                    conName = quoteObj.Opportunity.Contact__r.FirstName;
                conName = (conName==null) ? quoteObj.Opportunity.Contact__r.LastName : conName+' '+quoteObj.Opportunity.Contact__r.LastName;
                conName = conName+' (Patient)';
                crdHolders.add(new SelectOption(quoteObj.Opportunity.Contact__c,conName));
            }
            String pConName;
            for(PatientContactsWrp patWrp:patConWrpList){
                Patient_Contact__c pCon = patWrp.record;
                pConName = '';
                if(pCon.First_Name__c!=null)
                    pConName = pCon.First_Name__c;
                if(pCon.Last_Name__c!=null)
                    pConName = (pConName==null) ? pCon.Last_Name__c : pConName+' '+pCon.Last_Name__c;
                
                if(pCon.Id!=null)
                    crdHolders.add(new SelectOption(''+pCon.Id,pConName));
                else
                    crdHolders.add(new SelectOption(''+patWrp.uniqueNmbr,pConName));
            }
        }
        System.debug('crdHolders ::>'+crdHolders);
        return crdHolders;
    }   
    
    public List<SelectOption> getPaymentMethodList(){
        List<SelectOption> paymentOption = new List<SelectOption>();
        String value = '--None--';
        paymentOption.add(new SelectOption('',value));
        for(PaymentMethodWrp pytWrp:paymentMethodWrpList){
            System.debug('pytWrp ::>'+pytWrp);
            if(pytWrp.pyt.Type__c!=null){
                value = pytWrp.pyt.Type__c;
                System.debug('value ::>'+value);
                if(pytWrp.pyt.Last_4__c!=null)                  
                    value = value+' - '+pytWrp.pyt.Last_4__c;
                System.debug('value ::>'+value);
                if(pytWrp.pyt.Id!=null)
                    paymentOption.add(new SelectOption(''+pytWrp.pyt.Id,value));
                else
                    paymentOption.add(new SelectOption(''+pytWrp.uniqueNo,value));
            }   
        } 
        System.debug('paymentOption ::>'+paymentOption);
        return paymentOption;
    }
    
    
    public void onTypeSelected(){ 
        System.debug('lineItemWrp[rowToRemove].selectedFamilyType ::>'+lineItemWrp[rowToRemove].selectedFamilyType);
        if(lineItemWrp[rowToRemove].selectedFamilyType!=null && lineItemWrp[rowToRemove].selectedFamilyType!=''){
            QuoteLineItemWrp qliWrp = lineItemWrp[rowToRemove];
            qliWrp.productSelect = new List<SelectOption>();
            qliWrp.productSelect.add(new SelectOption('','--None--'));
            List<Product2> prdList = [Select Id,Name,Family from Product2 WHERE Family =:lineItemWrp[rowToRemove].selectedFamilyType];
            System.debug('prdList ::>'+prdList);
            for(Product2 prd:prdList){
                qliWrp.productSelect.add(new SelectOption(prd.Id,prd.Name));
            }
        }
    }
    
    public List<SelectOption> getProductType(){
        List<SelectOption> options = new List<SelectOption>(); 
        options.add(new SelectOption('','--None--'));
        Schema.DescribeFieldResult fieldResult = Product2.Family.getDescribe();
        List<Schema.PicklistEntry> ple = fieldResult.getPicklistValues();
        
        for( Schema.PicklistEntry f : ple){
            options.add(new SelectOption(f.getLabel(), f.getValue()));
        }       
        return options;
    }
    
    //Future Payment Wrapper class
    public class FuturePaymentWrp{
        public Future_Payment__c ftrPyt {get;set;}
        public integer index {get;set;}
        
        public FuturePaymentWrp(){
            ftrPyt = new Future_Payment__c();
        }
    }
    
    //Add new row in Future Payment Wrapper List
    public void addNewFtrPyt(){
        FuturePaymentWrp newRecord = new FuturePaymentWrp();
        Future_Payment__c newFTRPytRecord = new Future_Payment__c(); 
        newFTRPytRecord.Quote__c = quoteId;
        newRecord.ftrPyt = newFTRPytRecord;
        newRecord.index = ftrPytWrpList.size()-1;
        if(newRecord.index>=0){
            FuturePaymentWrp oldFTRPytRecord = ftrPytWrpList[newRecord.index];
            if(oldFTRPytRecord.ftrPyt.Balance_to_Collect__c==null && oldFTRPytRecord.ftrPyt.Collect_Balance_at__c==null){
                return;
            }           
        } 
        ftrPytWrpList.add(newRecord);
    }
    
    //Delete one row from the Payment Plan Table
    public void removeRowPaymentPlanTable(){
        Future_Payment__c ftrPytObjDel = ftrPytWrpList[rowToRemove].ftrPyt;        
        if(ftrPytWrpList.size() == 1){
            if(ftrPytObjDel.id!=null){ 
                delete ftrPytObjDel;                                   
            } 
            ftrPytObjDel = new Future_Payment__c(); 
            FuturePaymentWrp newRecord = new FuturePaymentWrp(); 
            newRecord.ftrPyt = ftrPytObjDel; 
            ftrPytWrpList[rowToRemove] = newRecord;
        }else{
            if(ftrPytObjDel.id!=null){
                delete ftrPytObjDel;                
            }           
            ftrPytWrpList.remove(rowToRemove); 
        }
    }
    
    //QuoteLineItem wrapper class
    public class QuoteLineItemWrp implements Comparable{
        public QuoteLineItem qli {get;set;} 
        public boolean isReadOnly {get;set;}
        public integer index {get;set;}
        public Treatment_Cost_Payment__c trtCstPyt {get;set;}
        public Payment__c PayCstPyt {get;set;}
        public String selectedFamilyType {get;set;}
        public String productName {get;set;}
        public boolean isEmptyRow {get;set;}
        public boolean isSameProduct {get;set;}
        public boolean isExistingTCP {get;set;}
        public List<SelectOption> productSelect {get;set;}
        public integer productOrder;
        public List<SelectOption> collectedAt {get;set;}
        
        public QuoteLineItemWrp(){
            qli = new QuoteLineItem();
            trtCstPyt = new Treatment_Cost_Payment__c();
            PayCstPyt = new Payment__c();
            isReadOnly = false; 
            isExistingTCP = false;
            productSelect = new List<SelectOption>();
            collectedAt = new List<SelectOption>();     
        }
        
        public Integer compareTo(Object ObjToCompare) {
            return (productOrder+'').CompareTo(((QuoteLineItemWrp)ObjToCompare).productOrder+'');
        }
    }
    
    //Add New row in the QuoteLineItem Table
    public void addNewQLIObj(){ 
        QuoteLineItemWrp newRecord = new QuoteLineItemWrp();
        QuoteLineItem newQLIRecord = new QuoteLineItem();       
        newRecord.qli = newQLIRecord;
        newRecord.PayCstPyt = new Payment__c();
        newRecord.index = lineItemWrp.size()-1;
        newRecord.selectedFamilyType = '--None--';
        if(newRecord.index>=0){
            QuoteLineItemWrp oldQLIRecord = lineItemWrp[newRecord.index];
            if(oldQLIRecord.qli.Product2Id==null || oldQLIRecord.qli.Product2Id+''=='' || oldQLIRecord.qli.UnitPrice==null){
                oldQLIRecord.isEmptyRow = true;
                lineItemWrp[newRecord.index] = oldQLIRecord;
                return;
            }
            System.debug('oldQLIRecord ::>'+oldQLIRecord);            
        } 
        rowToRemove = newRecord.index+1;        
        lineItemWrp.add(newRecord);
        onTypeSelected();
        System.debug('newRecord ::>'+newRecord);
    } 
    
    //Delete one row from the QuoteLineItem Table
    public void removeRowToQLITable(){
        QuoteLineItem qliObjDel = lineItemWrp[rowToRemove].qli;
        Payment__c trcCst = lineItemWrp[rowToRemove].PayCstPyt;  
        System.debug('product2Ids'+product2Ids);
        product2Ids.remove(lineItemWrp[rowToRemove].qli.Product2Id);
        System.debug('product2Ids'+product2Ids);
        
        if(lineItemWrp.size() == 1){
            if(qliObjDel.id!=null){ 
                delete qliObjDel; 
            }
            if(trcCst.Id!=null){
                delete trcCst;
            }
            qliObjDel = new QuoteLineItem();
            trcCst = new Payment__c();          
            QuoteLineItemWrp newRecord = new QuoteLineItemWrp(); 
            newRecord.qli = qliObjDel; 
            newRecord.PayCstPyt = trcCst;           
            lineItemWrp[rowToRemove] = newRecord;
            paymentToProcess = null;
            updateAmounts();
        } else {
            if(qliObjDel.id!=null){
                quoteLineItemMap.remove(qliObjDel.id);
                delete qliObjDel;
            }
            if(trcCst.Id!=null){
                delete trcCst;
            }
            lineItemWrp.remove(rowToRemove); 
            paymentToProcess = null;
            updateAmounts();
        } 
    }
    
    public void onProductSelected(){
        QuoteLineItemWrp qliWrp= lineItemWrp[rowToRemove];
        if((productMap.get(qliWrp.qli.Product2Id)).Payment_Application_Order__c!=null)
            qliWrp.productOrder = Integer.valueOf((productMap.get(qliWrp.qli.Product2Id)).Payment_Application_Order__c);
        qliWrp.collectedAt.add(new SelectOption('','--None--'));
        if((productMap.get(qliWrp.qli.Product2Id)).Available_to_Collect_at__c!=null){
            String[] collectAt = ((productMap.get(qliWrp.qli.Product2Id)).Available_to_Collect_at__c).split(';');
            for(String clc:collectAt){
                qliWrp.collectedAt.add(new SelectOption(clc,clc));
            }
        }
    }
    
    //Patient Method wrapper
    public class PaymentMethodWrp{
        public Payment_Method__c pyt {get;set;}
        public integer index {get;set;}
        public String selectedCardHolder {get;set;}
        public String selectedHolderName{get;set;}
        public Integer uniqueNo;
        public boolean isNotValidNo {get;set;}
        public PaymentMethodWrp(){
            pyt = new Payment_Method__c();
            uniqueNo = 0;
            isNotValidNo = false;
        }
    }
    
    //Add New row in the Payment Table
    public void addNewPytObj(){
        PaymentMethodWrp newRecord = new PaymentMethodWrp();
        Payment_Method__c newPyt = new Payment_Method__c();        
        newRecord.pyt = newPyt;
        newRecord.index = paymentMethodWrpList.size()-1;
        newRecord.uniqueNo = uniquePaymentNo++;
        if(newRecord.index>=0){
            PaymentMethodWrp oldPytRecord = paymentMethodWrpList[newRecord.index];
            if(oldPytRecord.pyt.Total_Amount_Remaining__c==null){
                updateAmounts();
            }
            if(oldPytRecord.pyt.Type__c==null){             
                return;
            }
            System.debug('oldPytRecord ::>'+oldPytRecord);            
        } 
        paymentMethodWrpList.add(newRecord);
        System.debug('newPaymentWrp :::>'+paymentMethodWrpList);       
    }
    
    //Delete one row from the Payment__c Table
    public void removeRowPytTable(){
        Payment_Method__c pytObjDel = paymentMethodWrpList[rowToRemove].pyt;        
        if(paymentMethodWrpList.size() == 1){
            if(pytObjDel.id!=null){ 
                delete pytObjDel;                                  
            } 
            updateAmounts(); 
            pytObjDel = new Payment_Method__c(); 
            PaymentMethodWrp newRecord = new PaymentMethodWrp(); 
            newRecord.pyt = pytObjDel; 
            paymentMethodWrpList[rowToRemove] = newRecord;
            paymentToProcess = null;
            updateAmounts();
        }else{
            if(pytObjDel.id!=null){
                delete pytObjDel;               
            }           
            paymentMethodWrpList.remove(rowToRemove); 
            paymentToProcess = null;
            updateAmounts();
        }
    }    
        
    //For processing amounts
    public void updateAmounts(){        
        getInsuranceCost_Charge();

        totalRemaining = 0.00;
        totalPaymentAmount = 0.00;
        PaymentMethodWrp pytMthWrp;         
        for(integer i=0;i<paymentMethodWrpList.size();i++){             
            pytMthWrp = paymentMethodWrpList[i];
            if(pytMthWrp.pyt.Total_Payment_Amount__c!=null)
                pytMthWrp.pyt.Total_Amount_Remaining__c = pytMthWrp.pyt.Total_Payment_Amount__c;
            paymentMethodWrpList[i] = pytMthWrp;
        }
        
        QuoteLineItemWrp qliWrp;
        for(integer i=0;i<lineItemWrp.size();i++){
            qliWrp = lineItemWrp[i];
            qliWrp.PayCstPyt.Payment_Amount__c = 0.00;
            qliWrp.PayCstPyt.Balance__c = qliWrp.qli.UnitPrice;
            lineItemWrp[i] = qliWrp;
        }
        
        //Sort on the basis of priority
        List<QuoteLineItemWrp> newQuoteLineList = new List<QuoteLineItemWrp>();
        newQuoteLineList.addAll(lineItemWrp);
        newQuoteLineList.sort();
        
        //Update payment amount
        List<QuoteLineItemWrp> updatedQLIWrpList = new List<QuoteLineItemWrp>();
        decimal tltAMt;
        for(integer opIndex=0;opIndex<newQuoteLineList.size();opIndex++){           
            qliWrp =newQuoteLineList[opIndex];
            if(qliWrp.qli.UnitPrice!=null){
                System.debug('qliWrp.PayCstPyt.Payment_Amount__c ::>'+qliWrp.PayCstPyt.Payment_Amount__c);
                if(qliWrp.qli.UnitPrice>qliWrp.PayCstPyt.Payment_Amount__c || qliWrp.PayCstPyt.Payment_Amount__c==null){                    
                    
                    for(integer i=0;i<paymentMethodWrpList.size();i++){
                        pytMthWrp = paymentMethodWrpList[i];
                        if(pytMthWrp.pyt.Total_Amount_Remaining__c==null)
                            pytMthWrp.pyt.Total_Amount_Remaining__c = 0.00;         
                        
                        System.debug('qliWrp ::>'+qliWrp);
                        decimal paymentAmount = qliWrp.qli.UnitPrice - qliWrp.PayCstPyt.Payment_Amount__c;
                        if(pytMthWrp.pyt.Total_Amount_Remaining__c>0){
                            tltAMt = pytMthWrp.pyt.Total_Amount_Remaining__c;
                            if(paymentAmount<tltAMt){
                                qliWrp.PayCstPyt.Payment_Amount__c = qliWrp.PayCstPyt.Payment_Amount__c + paymentAmount;
                                tltAMt = (tltAMt-paymentAmount);
                            } else if(paymentAmount==tltAMt){
                                qliWrp.PayCstPyt.Payment_Amount__c = qliWrp.PayCstPyt.Payment_Amount__c + paymentAmount;
                                tltAMt = 0.00;
                            } else {
                                qliWrp.PayCstPyt.Payment_Amount__c = qliWrp.PayCstPyt.Payment_Amount__c + tltAMt;
                                tltAMt = 0.00;
                            }
                            pytMthWrp.pyt.Total_Amount_Remaining__c = tltAMt.setScale(2);
                        } 
                        paymentMethodWrpList[i] = pytMthWrp;
                    }
                }
                qliWrp.PayCstPyt.Balance__c = qliWrp.qli.UnitPrice - qliWrp.PayCstPyt.Payment_Amount__c;
                if(qliWrp.PayCstPyt.Balance__c!=null)
                    totalRemaining += qliWrp.PayCstPyt.Balance__c;
                if(qliWrp.PayCstPyt.Payment_Amount__c!=null)
                    totalPaymentAmount += qliWrp.PayCstPyt.Payment_Amount__c;
                newQuoteLineList[opIndex] = qliWrp;
            }
        }
        
        //newQuoteLineList.clear();
        for(QuoteLineItemWrp qliWrp1:lineItemWrp){
            for(QuoteLineItemWrp qliWrp2:newQuoteLineList){
                if(qliWrp1.index==qliWrp2.index){
                    updatedQLIWrpList.add(qliWrp2);
                    break;
                }
            }
        }
        lineItemWrp.clear();
        lineItemWrp.addAll(updatedQLIWrpList);
        
        Render();
    }
    
    //Wrapper class for Patient Contacts Object
    public class PatientContactsWrp{
        public Patient_Contact__c record;
        public Integer UniqueNmbr; 
        public PatientContactsWrp(){
            UniqueNmbr = 0;
            record = new Patient_Contact__c(); 
        }
    } 
    
    //New Patient Contact
    public pagereference newPatientContact(){
        patcon = new Patient_Contact__c();
        patcon.Opportunity__c=quoteObj.OpportunityId;
        patcon.Contact__c = quoteObj.Opportunity.Contact__c;
        return page.NewPatContactForQuoteAddNew;
    }
    
    //Add New Patient Contact 
    public Pagereference addNewPCObj(){
        PatientContactsWrp newRecord = new PatientContactsWrp();     
        newRecord.record = patcon; 
        newRecord.UniqueNmbr = uniquePatConNo++;
        paymentMethodWrpList[paymentToProcess].selectedCardHolder = ''+newRecord.UniqueNmbr;
        patConWrpList.add(newRecord); 
        return Page.NAC_QuoteExtPage;
    } 
    
    public pagereference PatContactCancel(){
        return Page.NAC_QuoteExtPage;
    }
    
    public PageReference saveAndClose(){
        decimal totalBalance= 0.00;
        decimal TotalUnitPrice= 0.00;
        totalBalance=gettotalBalance(); //Payment_Plan.Balance_to_Collect   
        TotalUnitPrice=getTotalUnitPrice();//QuoteLineItems.Charge
        decimal postDischargeBalance = 0.00;
        postDischargeBalance = getPostDischarge_Balance();
        decimal insuranceCostCharge = 0.00;
        insuranceCostCharge = getInsuranceCost_Charge();
        System.debug('postDischargeBalance.. >> '+postDischargeBalance);
        System.debug('insuranceCostCharge.. >> '+insuranceCostCharge);
        boolean flag = false;
        if(!UtilValidation.isEstimateBalance(TotalUnitPrice,totalBalance,totalPaymentAmount)){
             ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.WARNING,'Estimate does not Balance.'));
             flag= false;
        }
         if(postDischargeBalance > insuranceCostCharge){            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'Post Discharge Amount greater than Travel and Other costs.'));
            flag= true;
         }
         
        if(flag)
            return null;
         
        /* else if((totalPaymentAmount + totalBalance)!= TotalUnitPrice){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'Estimate does not Balance.'));
            return null;
        } */
        
        update quoteObj;
        
        System.debug('postDischargeBalance <= insuranceCostCharge');            
            //Future Payment record upsert
            List<Future_Payment__c> ftrPytList = new List<Future_Payment__c>();
            if(ftrPytWrpList!=null && ftrPytWrpList.size()>0){
                for(FuturePaymentWrp ftrPytWrp:ftrPytWrpList){
                    if(ftrPytWrp.ftrPyt.Balance_to_Collect__c!=null || ftrPytWrp.ftrPyt.Collect_Balance_at__c!=null){
                        ftrPytList.add(ftrPytWrp.ftrPyt);
                    }
                }
                if(ftrPytList.size()>0){
                    upsert ftrPytList;
                }
            }
        
            //Patient_Contact Object upsert.
            Map<String,Patient_Contact__c> patConWrpMap = new Map<String,Patient_Contact__c>();
            if(patConWrpList.size()>0){
                for(PatientContactsWrp pcWrp:patConWrpList){
                    Patient_Contact__c pc =pcWrp.record;                
                    patConWrpMap.put(''+pcWrp.UniqueNmbr,pc);
                }
                upsert patConWrpMap.values();
            }
            
            //Payment Method Object Upsert
            Map<Integer,Payment_Method__c> mapPaymentmethodWrp = new Map<Integer,Payment_Method__c>();
            if(paymentMethodWrpList.size()>0){            
                Payment_Method__c pymt;
                for(PaymentMethodWrp pytW:paymentMethodWrpList){
                    pymt = pytW.pyt;
                    pymt.Opportunity__c = quoteObj.OpportunityId;
                    pymt.Quote__c = quoteObj.id;
                    if(pymt.id!=null || (pymt.Type__c!=null && pymt.Type__c!='')){
                        if(pytW.selectedCardHolder!=null && pytW.selectedCardHolder!=''){
                            if((pytW.selectedCardHolder).length()>=15 && pytW.selectedCardHolder.startsWith(Contact.sObjectType.getDescribe().getKeyPrefix())){
                                pymt.Cardholder_is_Patient__c = true;
                                pymt.Cardholder__c = null;                  
                            }else{
                                pymt.Cardholder_is_Patient__c = false;
                                if((pytW.selectedCardHolder).startsWith(Patient_Contact__c.sObjectType.getDescribe().getKeyPrefix()))
                                    pymt.Cardholder__c = pytW.selectedCardHolder;
                                else if(patConWrpMap.containsKey(''+pytW.selectedCardHolder))
                                    pymt.Cardholder__c = patConWrpMap.get(''+pytW.selectedCardHolder).Id;
                            }
                        }                   
                        //paymentList.add(pymt);
                        mapPaymentmethodWrp.put(pytW.uniqueNo,pymt);
                    }
                }
                
                if(mapPaymentmethodWrp.values().size()>0){
                    upsert mapPaymentmethodWrp.values();
                }
                System.debug('mapPaymentmethodWrp values after insert::>'+mapPaymentmethodWrp);
            } 
            
            if(lineItemWrp.size()>0){       
                List<QuoteLineItem> qliList = new List<QuoteLineItem>();
                
                //QLI Object Upsert
                for(QuoteLineItemWrp qtW:lineItemWrp){
                    QuoteLineItem qli = qtW.qli;
                    if(qli.id==null && qli.Product2Id!=null && qli.Product2Id+''!='' && qli.UnitPrice!=null){
                        if(product2Ids.contains(qli.Product2Id)){
                            qtW.isSameProduct = true;
                            return null;
                        }

                        qli.QuoteId = quoteId;
                        qli.Quantity = 1;                   
                        qli.PricebookEntryId  = prdPriceBookMap.get(qli.Product2Id);
                        product2Ids.add(qli.Product2Id);
                        qliList.add(qtW.qli);
                    }   
                }               
                upsert qliList;
                
                //Payment Object Upsert     
                List<Payment__c> toInsert = new List<Payment__c>();
                Payment__c pt;
                for(QuoteLineItemWrp qtW:lineItemWrp){
                    pt = qtW.PayCstPyt;
                    pt.Treatment_Cost_Line_Item__c = qtW.qli.id;
                    toInsert.add(pt);
                }   
                if(toInsert.size()>0){
                    upsert toInsert;
                }
                
                //Treatment_Cost_Payment__c Object Upsert
                Integer count =0;
                List<Treatment_Cost_Payment__c> tcpList = new List<Treatment_Cost_Payment__c>();
                Treatment_Cost_Payment__c tcp;
                for(QuoteLineItemWrp qtW:lineItemWrp){
                    if(qtW.PayCstPyt.Id!=null){
                        tcp = qtW.trtCstPyt;
                        if(tcp.Payment__c==null){
                            tcp.Payment__c = qtW.PayCstPyt.Id;
                        }
                        tcp.Quote_Line_Item__c = qtW.qli.id;
                        tcpList.add(tcp);
                    }               
                }    
                if(tcpList.size()>0){
                    upsert tcpList;
                }                     
            }        
            PageReference page = new Pagereference('/'+quoteId);
            page.setRedirect(true);
            return page;  
        
                            
                
    }
    
    public decimal gettotalBalance(){
        decimal total = 0;
        for(FuturePaymentWrp fpw: ftrPytWrpList){
            if(fpw.ftrPyt.Balance_to_Collect__c != null)
            total += fpw.ftrPyt.Balance_to_Collect__c;
        }
        return total;
    }
        
    public void Render(){
        decimal totalBalance= 0.00;
        decimal TotalUnitPrice= 0.00;
        totalBalance=gettotalBalance(); //Payment_Plan.Balance_to_Collect   
        TotalUnitPrice=getTotalUnitPrice();//QuoteLineItems.Charge
        decimal postDischargeBalance = 0.00;
        postDischargeBalance = getPostDischarge_Balance();
        decimal insuranceCostCharge = 0.00;
        insuranceCostCharge = getInsuranceCost_Charge();
        System.debug('postDischargeBalance.. >> '+postDischargeBalance);
        System.debug('insuranceCostCharge.. >> '+insuranceCostCharge);
        boolean flag = false;
        
        if(!UtilValidation.isEstimateBalance(TotalUnitPrice,totalBalance,totalPaymentAmount)){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.WARNING,'Estimate does not Balance.'));
            flag = true;
        }
        if(postDischargeBalance > insuranceCostCharge) {            
            ApexPages.addMessage(new ApexPages.Message(ApexPages.severity.ERROR,'Post Discharge Amount greater than Travel and Other costs.'));
            flag=true;
         }
        
         
    }

    public Decimal getPostDischarge_Balance(){  
        decimal Discharge_Balance = 0.00;   
        for(FuturePaymentWrp fpw: ftrPytWrpList){
            if(fpw.ftrPyt.Balance_to_Collect__c != null && fpw.ftrPyt.Collect_Balance_at__c != null && fpw.ftrPyt.Collect_Balance_at__c == 'Post Discharge'){
                System.debug('Balance_to_Collect_______________ '+fpw.ftrPyt.Balance_to_Collect__c);
                Discharge_Balance += fpw.ftrPyt.Balance_to_Collect__c;
            }
            System.debug('Discharge_Balance_____________ '+Discharge_Balance);
        }
        return Discharge_Balance;
    }
    
    public Decimal getInsuranceCost_Charge(){
        decimal Cost_Charge = 0.00;
        for(QuoteLineItemWrp qliW:lineItemWrp){ 
            System.debug('Product2.Family_____________________ '+qliW.qli.Product2.Family);
            System.debug('Product2.Family_____________________ '+qliW.selectedFamilyType);
            if(qliW.qli.UnitPrice != null && qliW.selectedFamilyType != null && qliW.selectedFamilyType != 'Insurance Cost'){
                Cost_Charge = Cost_Charge + qliW.qli.UnitPrice;
                System.debug('totalUnitPrice_________________ '+Cost_Charge);
            }
        }       
        return Cost_Charge;
    }
}