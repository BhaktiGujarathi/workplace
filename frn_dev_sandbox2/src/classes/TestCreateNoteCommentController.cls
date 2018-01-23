@isTest
private class TestCreateNoteCommentController{
    
    static testMethod void myUnitTest(){ 
        
        Account acc = new Account(name='Black Bear Lodge');
        insert acc;
           
        RecordType rc = [select id from  RecordType where SobjectType='Contact' AND Name='Patient'];
        Contact con = new contact(Firstname='Test', Birthdate = system.today(), Description = 'tttt',Lastname = 'Test', RecordTypeId = rc.id, accountId = acc.id);
        insert con;

        String rtId =   Schema.SObjectType.Note_Comment__c.getRecordTypeInfosByName().get('NAC Note/Comment').getRecordTypeId();        
        
        RecordType rc1 = [select id from  RecordType where SobjectType='Opportunity' AND Name='Outpatient Treatment'];
        Opportunity opp = new Opportunity(  Name = 'Test',RecordTypeId = rc1.id, StageName = 'Prospecting',Probability = 10.00,CloseDate = system.today(),Contact__c  = con.id);
        insert opp;
        
        Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 

        User u = new User(Alias = 'stan1t', Email='standarduser@testorg.com', 
        EmailEncodingKey='UTF-8', LastName='TestingU1', LanguageLocaleKey='en_US', 
        LocaleSidKey='en_US', ProfileId = p.Id,
        TimeZoneSidKey='America/Los_Angeles', UserName='standarduserU1@testorg.com'); 
        insert u;
         
        PageReference pageRef = Page.CreateNoteCommentPage;
        Test.setCurrentPage(pageRef);
        ApexPages.currentPage().getParameters().put('Id',opp.id);
        
        CreateNoteCommentController cncc = new CreateNoteCommentController();
        cncc.sortGroup();
        cncc.sortUser();
        cncc.cancel();
        cncc.selectedType = rtId;
        cncc.save();
        
        Patient_Insurance__c pi = new Patient_Insurance__c(Name = 'Test', Opportunity__c = opp.Id, Policy_Effective_Date__c = System.today(), Renewal_Date__c = System.Today().addYears(1), Term_Date__c = System.Today(),Patient__c= Con.id,Subscriber_is_Patient__c=True);
        insert pi;
        Pay_Agreement_Worksheet__c PAW = new Pay_Agreement_Worksheet__c(Opportunity__c = opp.id, Patient_Insurance__c = pi.id);
        insert PAW;
        ApexPages.currentPage().getParameters().put('Id',PAW.id);
        cncc = new CreateNoteCommentController();
        cncc.sortGroup();
        cncc.sortUser();
        cncc.cancel();
        cncc.selectedType = rtId;
        cncc.save();
        
        RecordType rc3 = [select id from  RecordType where SobjectType='case' AND Name='Facility Approval'];
        Case cs = new Case(Status = 'Closed',RecordTypeId = rc3.id,Origin = 'Email',ContactId = con.id,Opportunity__c=opp.id);
        insert cs;
        
        ApexPages.currentPage().getParameters().put('Id',cs.id);
        cncc = new CreateNoteCommentController();
        cncc.sortGroup();
        cncc.sortUser();
        cncc.cancel();
        cncc.selectedType = rtId;
        cncc.save();
        
        Insurance_Benefit__c insBenefit = new Insurance_Benefit__c();
        insBenefit.LOC_Benefits_are_the_Same__c = true;
        insBenefit.Patient_Insurance__c = pi.Id;
        insBenefit.PHP_Covered__c = 'Yes';
        insBenefit.Detox_Covered__c = 'Yes';
        insert insBenefit;
        
        ApexPages.currentPage().getParameters().put('Id',insBenefit.id);
        cncc = new CreateNoteCommentController();
        cncc.sortGroup();
        cncc.sortUser();
        cncc.cancel();
        cncc.selectedType = rtId;
        cncc.save();
        
        Lead ld = new Lead(OwnerId = u.id, status = 'Open',FirstName='test',LastName='test',Birthdate__c=System.Today(),IsConverted=False);
        insert ld;
        
        ApexPages.currentPage().getParameters().put('Id',ld.id);
        cncc = new CreateNoteCommentController();
        cncc.sortGroup();
        cncc.sortUser();
        cncc.cancel();
        cncc.selectedType = rtId;
        cncc.save();
        
        Pricebook2 pb = new Pricebook2();
        pb.Name= 'FRN Price Book';
        pb.IsActive= true;
        insert pb;
        
        Quote Q = new Quote(Name = 'Test',OpportunityId = opp.id,Pricebook2Id= pb.id);
        insert Q;
        list<SelectOption> susersList = new list<SelectOption>();
        susersList.add(new SelectOption('test@test.com','test@test.com'));
        
        ApexPages.currentPage().getParameters().put('Id',q.id);
        cncc = new CreateNoteCommentController();
        cncc.selecteduser = susersList;
        cncc.selectedGroup = susersList;
        cncc.searchGroup = 'All';
        cncc.searchUser = 'All';
        cncc.sortGroup();
        cncc.sortUser();
        cncc.selectedType = rtId;
        cncc.save();
        cncc.cancel();       
    }
}