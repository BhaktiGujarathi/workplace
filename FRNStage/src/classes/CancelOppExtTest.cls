@isTest
private class CancelOppExtTest{
       static testMethod void test1 () {
       
            Opportunity opp = new Opportunity();
            opp.StageName = 'Benefits Submitted';
            opp.Name = 'test';
            opp.Probability =10.0;
            opp.CloseDate = System.today();
            insert opp;
            
            Patient_Insurance__c ptntInsrnc = new Patient_Insurance__c();
            ptntInsrnc.VOB_status__c = 'Benefits Verified';
            ptntInsrnc.Opportunity__c = opp.Id;
            insert ptntInsrnc;
            
            Pay_Agreement_Worksheet__c paw=new Pay_Agreement_Worksheet__c();
            paw.Status__c='Cancelled';
            paw.Opportunity__c=opp.id;
            insert paw;
            
            
            Quote quo = new Quote();
            quo.Name = 'test';
            quo.opportunityId = opp.Id;
            quo.Status__c='Cancelled';
            insert quo;
            
            // Quote q = new Quote(name= 'test', opportunityid = opp.id);
            // insert q;            
             
            CancelOppExt Controller = new CancelOppExt();
            
            CancelOppExt.CancelOpp(opp.id,'Benefits Submitted','FRN - Admissions Coordinator (AC) Manager');
            //SelectFinalQuoteOnOpty.getOpportunity(String.valueOf(quo.id));
            
           
            
           // SelectFinalQuoteOnOpty.QuoteSelection(String.valueOf(quo.id),String.valueOf(opp1.id));
        
       }
}