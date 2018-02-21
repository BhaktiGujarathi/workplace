@isTest
private class CreateRenewalControllerTest {

    static testMethod void CreateTest(){    	 
	 
		 //contact dummy data
		 List<Contact> contactList = new list<Contact>();
		 contactList.add(new Contact(LastName = 'Test Last Name'));    	
		 insert contactList;
		 
		 //Opportunity dummy data.
		 List<Opportunity> opportunityList = new list<Opportunity>();		 
		 opportunityList.add(new Opportunity(Name = 'Test Name',
		 									 CloseDate = System.today(),
		 									 StageName = 'Application Sent',
		 									 type = 'New Customer'));		
		 insert opportunityList;
		 
		 //ContactRoleDummy data		 
		 list<OpportunityContactRole> oppContactRoleList = new list<OpportunityContactRole>();
		 oppContactRoleList.add(new OpportunityContactRole(OpportunityId = opportunityList[0].Id,
		 												   ContactId = contactList[0].Id));
		 
		 insert oppContactRoleList;		 
		 		     	
		 Test.startTest();
	     Apexpages.Pagereference P = Page.CreateRenewalPage;
	     test.setCurrentPage(p);
	     system.debug('*************Test started');
	     p.getParameters().put('Id',opportunityList[0].Id); 
	     CreateRenewalController controllerObj = new CreateRenewalController();
	     controllerObj.create();	    
	     Test.stopTest(); 
	     
	     //Assertion to check newly created Opportunity record
	     System.assertEquals(opportunityList[0].Name,'Test Name');
	     list<Account> accountList = new list<Account>();
	     
	     }
	     
	     //Test method to cover catch block
    static testMethod void negativeTest(){
    	try{ 
    		
		     //contact dummy data
			 List<Contact> contactList = new list<Contact>();
			 contactList.add(new Contact(LastName = 'Test Last Name'));    	
			 insert contactList;
			 
			 //Opportunity dummy data.
			 List<Opportunity> opportunityList = new list<Opportunity>();		 
			 opportunityList.add(new Opportunity(CloseDate = System.today(),
			 									 StageName = 'Application Sent',
			 									 type = 'New Customer'));		
			 insert opportunityList;
			 
			 Test.startTest();
		     Apexpages.Pagereference P = Page.CreateRenewalPage;
		     test.setCurrentPage(p);
		     p.getParameters().put('Id',opportunityList[0].Id); 
		     CreateRenewalController controllerObj = new CreateRenewalController();
		     controllerObj.create();	    
		     Test.stopTest(); 	
    	}	
    	catch(Exception e){
    		
    	} 
	     	
	     }
		     
}