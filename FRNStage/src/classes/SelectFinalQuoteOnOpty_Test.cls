@isTest
private class SelectFinalQuoteOnOpty_Test{
       static testMethod void test1 () {
       
            Pricebook2 prod = new Pricebook2(Name = 'FRN Price Book');
            insert prod;
            
            Account acc = new Account();
            acc.Name = 'test';			
            insert acc;
            
            Contact con = new Contact();
            con.LastName = 'test';
            con.AccountId = acc.Id;
            con.Social_Security_Number__c = 'test#';
            insert con;
            
            Opportunity opp = new Opportunity();
            opp.StageName = 'Prospecting';
            opp.Name = 'test';
            opp.CloseDate = System.today();
            insert opp;
            
            Quote quo = new Quote();
            quo.Name = 'test';
            quo.opportunityId = opp.Id;
            quo.FRN_Facility__c = acc.Id;
            quo.Insurance_Company__c = acc.Id;
            quo.Insurance_Company_Contract_Type__c = 'In Network';
            insert quo;
            
            // Quote q = new Quote(name= 'test', opportunityid = opp.id);
            // insert q;            
             
            SelectFinalQuoteOnOpty Controller = new SelectFinalQuoteOnOpty();
            SelectFinalQuoteOnOpty.QuoteSelection(String.valueOf(quo.id),String.valueOf(opp.id));
            SelectFinalQuoteOnOpty.getOpportunity(String.valueOf(quo.id));
            
            Opportunity opp1 = new Opportunity();
            opp1.StageName = 'Prospecting';
            opp1.Name = 'test';
           
            opp1.CloseDate = System.today();
            opp1.Final_Quote_Selected__c = quo.Id;
            insert opp1;
			
			Account acc1 = new Account();
			acc1.Name = 'Test1';
			acc1.Facility_Approval_Group_Name__c = 'Test';
			insert acc1;
			
			Case cs = new Case();
			cs.Status = 'New';
			cs.Origin = 'New';
			cs.Opportunity__c = opp1.Id;
			cs.AccountId = acc1.Id;
			cs.RecordTypeId = Schema.SObjectType.Case.getRecordTypeInfosByName().get('Facility Approval').getRecordTypeId();
			insert cs;
            
            SelectFinalQuoteOnOpty.QuoteSelection(String.valueOf(quo.id),String.valueOf(opp1.id));
        
       }
}