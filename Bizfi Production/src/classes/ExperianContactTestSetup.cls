@isTest
public class ExperianContactTestSetup {

	public static void dmlData() {
		Account a = new Account();
		a.Name = 'Test Account'; 
		a.RecordTypeId = RecordTypesUtility.recId('Account', 'Merchant'); 
		a.Industry = 'Agriculture';
		a.Test_Complete__c = true;
		insert a;

		Contact[] testCons = new Contact[]{};
		for(Integer i = 0; i < 200; i++){
			Contact c = new Contact();
			c.AccountId = a.Id;
			c.LastName = 'test-'+i;
			c.Email = 'callouttest'+i+'@testing.com';
			testCons.add(c);
		}
		insert testCons;
	}

	public static Map<Id, Contact> mapSetup(Boolean mix){

        Map<Id, Contact> conMap = new Map<Id, Contact>();

        Account a = [SELECT Id FROM Account LIMIT 1];

        for(Integer n = 0; n < 9; n++){
            Contact c = new Contact();
            c.Id = '0031700000LI'+n+'BT'; 
			c.AccountId = a.Id;
			c.LastName = 'test-'+n;
			c.Email = 'callouttest'+n+'@testing.com';

            if(n <= 2 && mix) {
                c.Authorize_Run_Credit__c = true;
                c.Opportunity_Id__c = '006 plus other stuff';
            } else if(n > 2 && mix) {
                c.Authorize_Run_Credit__c = true;
            } else if(n <= 5 && !mix) {
                c.Authorize_Run_Credit__c = true;
                c.Opportunity_Id__c = '006 nega other stuff';
            } else {
                c.Authorize_Run_Credit__c = false;
            }

            conMap.put(c.Id, c);
        }

        return conMap;
    }

    public static String jsonSetup() {

    	Contact[] conList = new Contact[]{};

    	for(Integer n = 0; n < 9; n++){
            Contact c = new Contact();
            c.Id = '0031700000LI'+n+'BT'; 
			c.LastName = 'test-'+n;
			c.Email = 'callouttest'+n+'@testing.com';

            conList.add(c);
        }

        String jsonData = JSON.serialize(conList);
        return jsonData;
    }

    public static void acctOppCon() {

        Id rec = RecordTypesUtility.recId('Account', 'Merchant');

        Account a = new Account(
            Name = 'Test Account',
            Industry = 'Banking',
            Test_Complete__c = true,
            RecordTypeId = rec);

        insert a;


        Account acct = [SELECT Id FROM Account WHERE RecordTypeId = :rec LIMIT 1];


        Contact[] cons = new Contact[]{};
        for(Integer n = 0; n < 2; n++) {
            Contact c = new Contact(
                AccountId = acct.Id,
                LastName = 'test opp '+n,
                Email = 'con'+n+'@exptest.com');

            cons.add(c);
        }

        insert cons;


        Opportunity[] opps = new Opportunity[]{};
        for(Integer n = 0; n < 2; n++) {
            Opportunity o = new Opportunity(
                AccountId = acct.Id,
                Name = 'test opp '+n,
                StageName = 'Application In',
                CloseDate = date.today()+20,
                Test_Complete__c = true);

            opps.add(o);
        }

        insert opps;
    }

    public static void conRoles(Opportunity opp) {

        Contact[] cons = [SELECT Id FROM Contact WHERE AccountId = :opp.AccountId];

        OpportunityContactRole[] oppConList = new OpportunityContactRole[]{};
        for(Contact c : cons) {
            OpportunityContactRole ocr = new OpportunityContactRole(
                ContactId = c.Id,
                OpportunityId = opp.Id);

            oppConList.add(ocr);
        }

        insert oppConList;
    }

}