public with sharing class OfferHandlerTest {
    private static testmethod void testUpdateFunder(){
        
        RecordType recordTypeObj =[Select Id From RecordType Where Name = 'Bank' LIMIT 1 ];
        
        //Create Account
        Account account = new Account(Name='TestAcc', Type='Analyst', Industry='Energy', RecordTypeId = recordTypeObj.Id );
        insert account;
        
        Account account1 = new Account(Name='TestAcc1', Type='Analyst', Industry='Energy', RecordTypeId = recordTypeObj.Id);
        insert account1;
        
        //Create Opportunity
        Opportunity opportuntiy = new Opportunity(Name='TestOpp', AccountId=account.Id, CloseDate = System.today(), StageName='Prospecting', payment_Amount__c = 100, Funding_Amount__c =50);
        insert opportuntiy; 

        //Create associate submissions
        Submission__c submission = new Submission__c(Opportunity__c= opportuntiy.Id, Status__c='UW', Funder__c=account.Id);
        insert submission;
        
        Submission__c submission1 = new Submission__c(Opportunity__c=opportuntiy.Id, Status__c='UW', Funder__c=account1.Id);
        insert submission1;
        
        Test.startTest();
        Offer__c offer = new Offer__c(Opportunity__c=opportuntiy.Id, Submission__c=submission.Id);
        insert offer;
        
        Submission__c objSubmission = [select Funder__c from Submission__c where Id=:submission.Id];
        Offer__c objOffer = [select Funder__c from Offer__C where Id=:offer.Id];
        System.assertEquals(objSubmission.Funder__c,objOffer.Funder__c);
        
        submission.Funder__c = account1.Id;
        update submission;
        
        offer.Status__c = 'Chosen';
        offer.Amount__c = 12000;
        update offer;
        
        objOffer = [select Funder__c from Offer__C where Id=:offer.Id];
        
        Account objaccount = [select Id from Account where Id =: account1.Id];
        System.assertEquals(account1.Id,objOffer.Funder__c);
        
        Offer__c offer1 = new Offer__c(Opportunity__c=opportuntiy.Id, Submission__c=submission.Id, Status__c = 'Prequal', Amount__c = 15000);
        insert offer1;
        
        Opportunity objOpportunity = [select Amount from Opportunity where id =: opportuntiy.Id];
        System.assertEquals(offer1.Amount__c , objOpportunity.Amount);
        delete offer1;
        
        objOffer = [select Amount__c from Offer__C where Id=:offer.Id];
        objOpportunity = [select Amount from Opportunity where id =: opportuntiy.Id];
        System.assertEquals(objOffer.Amount__c , objOpportunity.Amount);
        
        unDelete offer1;
        Test.stopTest();
     }
}