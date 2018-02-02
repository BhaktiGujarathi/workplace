@isTest
public class NAC_QuoteExtTest{
    static testMethod void Test(){
        RecordType rc1 = [select id from  RecordType where SobjectType='Contact' AND Name='Patient'];
        Contact con = new contact(Lastname = 'Test',RecordTypeId = rc1.id);
        insert con;

        RecordType rc = [select id from  RecordType where SobjectType='Opportunity' AND Name='Outpatient Treatment'];
        Opportunity opp = new Opportunity (Name = 'TestOpp', CloseDate = System.today(),StageName = '1. Prospecting',Contact__c = con.id,Probability = 10,RecordTypeId = rc.id);
        insert opp;         

        RecordType rc2 = [select id from  RecordType where SobjectType='Account' AND Name='Patient Account'];
        Account acc = new Account(Name = 'test',RecordTypeId = rc2.id );
        insert acc;
        
        Facility_Program__c FP = new Facility_Program__c(Name = 'test', FRN_Facility__c=acc.id);
        insert FP;
        Pay_Agreement_Worksheet__c PAW = new Pay_Agreement_Worksheet__c(Opportunity__c = opp.id,Deductible__c = 100, Facility_Program__c =FP.id,FRN_Facility__c=acc.id);
        insert PAW;

        Pricebook2 pb = new Pricebook2();
        pb.Name= 'FRN Price Book';
        pb.IsActive= true;
        insert pb;
        
        Id pricebookId = Test.getStandardPricebookId();

        Product2 pr = new Product2();
        pr.Name= 'Ancillary Cost';
        pr.Family= 'Insurance Cost Determination';
        pr.Available_to_Collect_at__c= 'Intake';
        pr.Sort_order__c= 1;
        pr.Payment_Application_Order__c= 1;
        pr.IsActive= true;
        insert pr;
        
        Product2 pr1 = new Product2();
        pr1.Name= 'Deductible';
        pr1.Family= 'Insurance Cost';
        pr1.Available_to_Collect_at__c= 'Intake';
        pr1.Sort_order__c= 2;
        pr1.Payment_Application_Order__c= 2;
        pr1.IsActive= true;
        insert pr1;
        
        Quote Q = new Quote(Name = 'Test',OpportunityId = opp.id,Pricebook2Id= pricebookId);
        insert Q;
        
        PricebookEntry pbe = new PricebookEntry();
        pbe.Pricebook2Id= pricebookId;
        pbe.Product2Id= pr.Id;
        pbe.IsActive= true;
        pbe.UnitPrice= 10;
        insert pbe;
        
        PricebookEntry pbe1 = new PricebookEntry();
        pbe1.Pricebook2Id= pricebookId;
        pbe1.Product2Id= pr1.Id;
        pbe1.IsActive= true;
        pbe1.UnitPrice= 11;
        insert pbe1;
        
        Quote qu = new Quote(Name = 'Test',OpportunityId = opp.id, Pricebook2Id= pricebookId );
        insert qu;
        
        QuoteLineItem qli1 = new QuoteLineItem(QuoteId = q.Id, PriceBookEntryId = pbe1.Id, Quantity = 1, UnitPrice = 100);
        insert qli1;
        
        QuoteLineItem qli = new QuoteLineItem(QuoteId = q.Id, PriceBookEntryId = pbe.Id, Quantity = 1, UnitPrice = 100);
        insert qli;
        
        Payment__c pyt = new Payment__c(Type__c = 'Credit Card',Last_4__c = '2314',Payment_Amount__c = 20,Treatment_Cost_Line_Item__c=qli.Id);
        insert pyt;
        
        Treatment_Cost_Payment__c trtCst = new Treatment_Cost_Payment__c(Payment__c = pyt.Id,Quote_Line_Item__c = qli.Id,Collect_At__c = 'Intake');
        insert trtCst;
        
        Patient_Contact__c patCon = new Patient_Contact__c(First_Name__c='Test',Last_Name__c='Test',Opportunity__c=opp.Id);
        insert patCon;
        
        Payment_Method__c payMth = new Payment_Method__c(Last_4__c='1234',Type__c='Credit Card (at Admissions Center)',Quote__c=q.Id,Cardholder_is_Patient__c=true, Total_Amount_Remaining__c=10.00);
        insert payMth;
        
        Payment_Method__c payMth1 = new Payment_Method__c(Last_4__c='1234',Type__c='Wire Transfer (at Admissions Center)',Quote__c=q.Id,Cardholder__c=patCon.Id,Total_Amount_Remaining__c=10.00);
        insert payMth1;
        
        List<Future_Payment__c> fpList = new List<Future_Payment__c>();
        Future_Payment__c ftrp = new Future_Payment__c(Quote__c=q.Id,Balance_to_Collect__c = 10.00);
        fpList.add(ftrp);
        Future_Payment__c ftrp1 = new Future_Payment__c(Quote__c=q.Id,Balance_to_Collect__c = 100.00);
        fpList.add(ftrp1);
        insert fpList;
        
        PageReference pRef = Page.NAC_PrintQuotePDF;
        pRef.getParameters().put('Qid', Q.id);
        Test.setCurrentPage(pRef);
        NAC_QuoteExt QE = new NAC_QuoteExt();
        QE.getPaymentMethodList();      
        QE.getProductType();
        QE.addNewQLIObj();
        QE.getTotalUnitPrice();
        QE.addNewFtrPyt();
        QE.removeRowPaymentPlanTable();
        QE.rowToRemove = 0;
        //QE.removeRowToQLITable();
        //QE.addNewPytObj();
        System.debug('QE.paymentMethodWrpList ::>'+QE.paymentMethodWrpList);
        QE.paymentMethodWrpList[(QE.paymentMethodWrpList).size()-1].pyt.Total_Payment_Amount__c = 5;
        QE.paymentToProcess = (QE.paymentMethodWrpList).size()-1;
        //QE.updateAmounts();
        QE.PatContactCancel();
        QE.onProductSelected();
        QE.saveAndClose();       
        QE.removeRowPytTable();     
        //QE.removeRowToQLITable();
        QE.removeRowToQLITable();
        QE.addNewPytObj();
        QE.removeRowPytTable();
        QE.removeRowPytTable();
        QE.addNewQLIObj();
        QE.getCardHolders();
        QE.newPatientContact();
        QE.paymentToProcess = (QE.paymentMethodWrpList).size()-1;
        QE.addNewPCObj();       
        QE.PatContactCancel();
        QE.saveAndClose(); 
    }
}