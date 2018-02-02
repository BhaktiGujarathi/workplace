@isTest
public class AbusedSubstanceHandlerTest {
    
    private static testMethod  void AbusedSubstanceHandler_test(){
        
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Contact; 
        Map<String,Schema.RecordTypeInfo> RecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 

        Contact con = new Contact();                
        if(RecordTypeInfo.size()>0)
            con.RecordTypeId = (RecordTypeInfo.get('Patient')).getRecordTypeId();
        con.LastName = 'Test';
        insert con;
        
        
        cfrSchema = Schema.SObjectType.Opportunity; 
        RecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        
        Opportunity opp = new Opportunity();
        if(RecordTypeInfo.size()>0)
            opp.RecordTypeId = (RecordTypeInfo.get('Outpatient Treatment')).getRecordTypeId();
        opp.Name = 'Test Opp';
        opp.CloseDate = System.today();
        opp.StageName = 'Closed Won';
        opp.Contact__c = con.Id;
        insert opp;
        
        Opportunity newOpp = new Opportunity();
        if(RecordTypeInfo.size()>0)
            newOpp.RecordTypeId = (RecordTypeInfo.get('Outpatient Treatment')).getRecordTypeId();
        newOpp.Name = 'Test Opp';
        newOpp.CloseDate = System.today();
        newOpp.StageName = 'Closed Won';
        newOpp.Contact__c = con.Id;
        insert newOpp;
        
        Abused_Substance__c abs = new Abused_Substance__c();
        abs.Opportunity__c = opp.Id;
        insert abs;
        abs.Opportunity__c = newOpp.Id;
        update abs;
    }    
    
    private static testMethod  void LegalOffenseHandler_test(){
        
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Contact; 
        Map<String,Schema.RecordTypeInfo> RecordTypeInfo = cfrSchema.getRecordTypeInfosByName();      

        Contact con = new Contact();                
        if(RecordTypeInfo.size()>0)
            con.RecordTypeId = (RecordTypeInfo.get('Patient')).getRecordTypeId();
        con.LastName = 'Test';
        insert con;
        
        cfrSchema = Schema.SObjectType.Opportunity; 
        RecordTypeInfo = cfrSchema.getRecordTypeInfosByName();  
        
        Opportunity opp = new Opportunity();
        if(RecordTypeInfo.size()>0)
            opp.RecordTypeId = (RecordTypeInfo.get('Outpatient Treatment')).getRecordTypeId();
        opp.Name = 'Test Opp';
        opp.CloseDate = System.today();
        opp.StageName = 'Closed Won';
        opp.Contact__c = con.Id;
        insert opp;
        
        Opportunity newOpp = new Opportunity();
        if(RecordTypeInfo.size()>0)
            newOpp.RecordTypeId = (RecordTypeInfo.get('Outpatient Treatment')).getRecordTypeId();
        newOpp.Name = 'Test Opp';
        newOpp.CloseDate = System.today();
        newOpp.StageName = 'Closed Won';
        newOpp.Contact__c = con.Id;
        insert newOpp;
        
        Legal_Offense__c abs = new Legal_Offense__c();
        abs.Opportunity__c = opp.Id;
        insert abs;
        abs.Opportunity__c = newOpp.Id;
        update abs;
    } 

    private static testMethod  void PrescriptionHandlerHandler_test(){
        
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Contact; 
        Map<String,Schema.RecordTypeInfo> RecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        
        Contact con = new Contact();
        if(RecordTypeInfo.size()>0)
            con.RecordTypeId = (RecordTypeInfo.get('Patient')).getRecordTypeId();
        con.LastName = 'test';
        insert con;
        
        cfrSchema = Schema.SObjectType.Opportunity; 
        RecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        
        Opportunity opp = new Opportunity();
        if(RecordTypeInfo.size()>0)
            opp.RecordTypeId = (RecordTypeInfo.get('Outpatient Treatment')).getRecordTypeId();
        opp.Name = 'test';
        opp.CloseDate = System.today();
        opp.StageName = 'Prospecting';
        opp.Contact__c = con.Id;
        insert opp;
        
        Opportunity newOpp = new Opportunity();
        if(RecordTypeInfo.size()>0)
            newOpp.RecordTypeId = (RecordTypeInfo.get('Outpatient Treatment')).getRecordTypeId();
        newOpp.Name = 'Test Opp';
        newOpp.CloseDate = System.today();
        newOpp.StageName = 'Closed Won';
        newOpp.Contact__c = con.Id;
        insert newOpp;
        
        Prescription_Medication__c pres = new Prescription_Medication__c();
        pres.Opportunity__c = opp.Id;
        insert pres;
        pres.Opportunity__c = newOpp.Id;
        update pres;
    }
    
    private static testMethod  void medicalprobHandler_test(){
        
        Schema.DescribeSObjectResult cfrSchema = Schema.SObjectType.Contact; 
        Map<String,Schema.RecordTypeInfo> RecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        
        Contact con = new Contact();
        if(RecordTypeInfo.size()>0)
        con.RecordTypeId = (RecordTypeInfo.get('Patient')).getRecordTypeId();
        con.LastName = 'test';
        insert con;
        
        cfrSchema = Schema.SObjectType.Opportunity; 
        RecordTypeInfo = cfrSchema.getRecordTypeInfosByName(); 
        
        Opportunity opp = new Opportunity();
        if(RecordTypeInfo.size()>0)
        opp.RecordTypeId = (RecordTypeInfo.get('Outpatient Treatment')).getRecordTypeId();
        opp.Name = 'test';
        opp.CloseDate = System.today();
        opp.StageName = 'Prospecting';
        opp.Contact__c = con.Id;
        insert opp;
        
        Opportunity newOpp = new Opportunity();
        if(RecordTypeInfo.size()>0)
            newOpp.RecordTypeId = (RecordTypeInfo.get('Outpatient Treatment')).getRecordTypeId();
        newOpp.Name = 'Test Opp';
        newOpp.CloseDate = System.today();
        newOpp.StageName = 'Closed Won';
        newOpp.Contact__c = con.Id;
        insert newOpp;
        
        Medical_Problem_Symptom__c medprob = new Medical_Problem_Symptom__c();
        medprob.Opportunity__c = opp.Id;
        insert medprob;
        medprob.Opportunity__c = newOpp.Id;
        update medprob;
    }   
    
}