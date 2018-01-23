@isTest
public class LeadDuplicatecontroller_Test{

	@testSetup static void methodName() {

		Contact con = new Contact(LastName = 'test1');
        insert con;
		
		RecordType rc1 = [select id from  RecordType where SobjectType='Opportunity' AND Name='Residential Treatment'];
        Opportunity opp1 = new Opportunity(Name = 'Test1',Contact__c= con.id, StageName = 'Qualification',Probability = 11,CloseDate =  Date.today(),RecordTypeId = rc1.id);
        insert opp1;
		
		Contact con1 = new Contact(LastName = 'test2', MobilePhone= '3456');
        insert con1;
		
        Opportunity opp2 = new Opportunity(Name = 'Test1',Contact__c= con1.id, StageName = 'Qualification',Probability = 11,CloseDate =  Date.today(),RecordTypeId = rc1.id);
        insert opp2;
		
		Contact con2 = new Contact(LastName = 'test3', Phone= '123', Work_Phone__c = '3456');
        insert con2;
		
        Opportunity opp3 = new Opportunity(Name = 'Test1',Contact__c= con2.id, StageName = 'Qualification',Probability = 11,CloseDate =  Date.today(),RecordTypeId = rc1.id);
        insert opp3;
		
		Lead le1 = new Lead();
		le1.LastName = 'test1';
		le1.Status = 'Open';
		le1.Phone = '123';
		le1.MobilePhone = '34568';
		le1.Caller_First_Name__c = 'test';
		le1.Caller_Last_Name__c = 'test';
		le1.Caller_Last_Name__c = 'test';
		le1.Caller_Mobile__c = '123456';
		le1.IsConverted = false;
		insert le1;
		
		Lead le2 = new Lead();
		le2.LastName = 'test2';
		le2.Status = 'Open';
		le2.Phone = '123';
		le2.MobilePhone = '34564';
		le2.Caller_First_Name__c = 'test';
		le2.Caller_Last_Name__c = 'test';
		le2.Caller_Last_Name__c = 'test';
		le2.Caller_Mobile__c = '123456';
		le2.IsConverted = false;
		insert le2;
		
		Lead le3 = new Lead();
		le3.LastName = 'test2';
		le3.Status = 'Open';
		le3.Phone = '1235';
		le3.MobilePhone = '3456';
		le3.Caller_First_Name__c = 'test';
		le3.Caller_Last_Name__c = 'test';
		le3.Caller_Last_Name__c = 'test';
		le3.Caller_Mobile__c = '123456';
		le3.IsConverted = false;
		insert le3;
		 
	}


	static testMethod void test_LeadSearch(){
		
		Lead le = new Lead();
		le.LastName = 'test1';
		le.Status = 'Open';
		le.Phone = '123';
		le.MobilePhone = '3456';
		le.Caller_First_Name__c = 'test';
		le.Caller_Last_Name__c = 'test';
		le.Caller_Last_Name__c = 'test';
		le.Caller_Mobile__c = '123456';
		le.IsConverted = false;
		insert le;

		Test.startTest();
		ApexPages.currentPage().getParameters().put('Id',le.Id);
		ApexPages.StandardController sc = new ApexPages.StandardController (le);
		LeadDuplicatecontroller Ldc = new LeadDuplicatecontroller(sc);
		Ldc.initializeLeadSearch();
		Test.stopTest();
			
		System.assertEquals( 3 , Ldc.duplicateLeadList.size() , 'Lead Duplicate search should return 2 matched lead records.' );
			
	}

	static testMethod void test_initializeOpportunitySearch(){
		
		Lead le = new Lead();
		le.LastName = 'test1';
		le.Status = 'Open';
		le.Phone = '123';
		le.MobilePhone = '3456';
		le.Caller_First_Name__c = 'test';
		le.Caller_Last_Name__c = 'test';
		le.Caller_Last_Name__c = 'test';
		le.Caller_Mobile__c = '123456';
		le.IsConverted = false;
		insert le;

		Test.startTest();
		ApexPages.currentPage().getParameters().put('Id',le.Id);
		ApexPages.StandardController sc = new ApexPages.StandardController (le);
		LeadDuplicatecontroller Ldc = new LeadDuplicatecontroller(sc);
		Ldc.initializeOpportunitySearch();
		Test.stopTest();
			
		System.assertEquals( 3 , Ldc.duplicateOppContacts.size() , 'Lead Duplicate search should return 1 matched opportunity record.' );
			
	}

	static testMethod void test_initializeContactSearch(){
		
		Lead le = new Lead();
		le.LastName = 'test1';
		le.Status = 'Open';
		le.Phone = '123';
		le.MobilePhone = '3456';
		le.Caller_First_Name__c = 'test';
		le.Caller_Last_Name__c = 'test';
		le.Caller_Last_Name__c = 'test';
		le.Caller_Mobile__c = '123456';
		le.IsConverted = false;
		insert le;

		Test.startTest();
		ApexPages.currentPage().getParameters().put('Id',le.Id);
		ApexPages.StandardController sc = new ApexPages.StandardController (le);
		LeadDuplicatecontroller Ldc = new LeadDuplicatecontroller(sc);
		Ldc.initializeContactSearch();
		Test.stopTest();
			
		System.assertEquals( 3 , Ldc.duplicateContact.size() , 'Lead Duplicate search should return 1 matched contact record.' );
			
	}

	static testMethod void Test(){
		
		Contact con = new Contact(LastName = 'test1');
        insert con;
		
		RecordType rc1 = [select id from  RecordType where SobjectType='Opportunity' AND Name='Residential Treatment'];
        Opportunity opp1 = new Opportunity(Name = 'Test1',Contact__c= con.id, StageName = 'Qualification',Probability = 11,CloseDate =  Date.today(),RecordTypeId = rc1.id);
        insert opp1;
		
		Contact con1 = new Contact(LastName = 'test2', MobilePhone= '3456');
        insert con1;
		
        Opportunity opp2 = new Opportunity(Name = 'Test1',Contact__c= con1.id, StageName = 'Qualification',Probability = 11,CloseDate =  Date.today(),RecordTypeId = rc1.id);
        insert opp2;
		
		Contact con2 = new Contact(LastName = 'test3', Phone= '123');
        insert con2;
		
        Opportunity opp3 = new Opportunity(Name = 'Test1',Contact__c= con2.id, StageName = 'Qualification',Probability = 11,CloseDate =  Date.today(),RecordTypeId = rc1.id);
        insert opp3;
		
		
		Lead le1 = new Lead();
		le1.LastName = 'test1';
		le1.Status = 'Open';
		le1.Phone = '123';
		le1.MobilePhone = '34568';
		le1.Caller_First_Name__c = 'test';
		le1.Caller_Last_Name__c = 'test';
		le1.Caller_Last_Name__c = 'test';
		le1.Caller_Mobile__c = '123456';
		le1.IsConverted = false;
		insert le1;
		
		Lead le2 = new Lead();
		le2.LastName = 'test2';
		le2.Status = 'Open';
		le2.Phone = '123';
		le2.MobilePhone = '34564';
		le2.Caller_First_Name__c = 'test';
		le2.Caller_Last_Name__c = 'test';
		le2.Caller_Last_Name__c = 'test';
		le2.Caller_Mobile__c = '123456';
		le2.IsConverted = false;
		insert le2;
		
		Lead le3 = new Lead();
		le3.LastName = 'test2';
		le3.Status = 'Open';
		le3.Phone = '1235';
		le3.MobilePhone = '3456';
		le3.Caller_First_Name__c = 'test';
		le3.Caller_Last_Name__c = 'test';
		le3.Caller_Last_Name__c = 'test';
		le3.Caller_Mobile__c = '123456';
		le3.IsConverted = false;
		insert le3;
		 
		Lead le = new Lead();
		le.LastName = 'test1';
		le.Status = 'Open';
		le.Phone = '123';
		le.MobilePhone = '3456';
		le.Caller_First_Name__c = 'test';
		le.Caller_Last_Name__c = 'test';
		le.Caller_Last_Name__c = 'test';
		le.Caller_Mobile__c = '123456';
		le.IsConverted = false;
		insert le;
		
		ApexPages.currentPage().getParameters().put('Id',le.Id);
		ApexPages.StandardController sc = new ApexPages.StandardController (le);
		ApexPages.currentPage().getParameters().put('onEditMode','true');
        LeadDuplicatecontroller Ldc = new LeadDuplicatecontroller(sc);
	}
}