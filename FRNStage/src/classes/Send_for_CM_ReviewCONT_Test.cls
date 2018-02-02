@isTest
private class Send_for_CM_ReviewCONT_Test{
        static testMethod void test1 () {
       
	    Opportunity Opp1 = new Opportunity();
		opp1.stagename = 'Pending Medical / Clinical Review';
		opp1.Probability= 10;
		opp1.CloseDate=System.today();
		opp1.name='test';
		insert opp1;
		
		Profile p = [SELECT Id FROM Profile WHERE Name='Standard User']; 
  
        User u = new User(Alias = 'standt', Email='standarduser@testorg.com', 
            EmailEncodingKey='UTF-8', LastName='Testing', LanguageLocaleKey='en_US', 
            LocaleSidKey='en_US', ProfileId = p.Id, isactive=true,
            TimeZoneSidKey='America/Los_Angeles', UserName='standarduser@testorg.com');
		
		apexpages.currentpage().getparameters().put('id', Opp1.id);
	   
	    Send_for_CM_ReviewCONT CM = new Send_for_CM_ReviewCONT();
	    CM.save();		
	    CM.getUsersPiclist();		
		
	   }
}