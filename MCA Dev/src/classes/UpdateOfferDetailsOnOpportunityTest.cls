/* Test Class For UpdateOfferDetailsOnOpportunity class
 * 
 * Revision History:
 *   
 * Version         Author                                   Date                                    Description
 * 1.0             Nachiket R. Deshpande                    20/08/2015                              Initial Draft
 */ 
@isTest
private class UpdateOfferDetailsOnOpportunityTest {
    
    /*Method to test offer details on opportunity when an Offer is created with status chosen*/
    static testMethod void testOfferDetailsOnOpportunity() {
    	
        //Calling getOpportunityRecords for getting Opportunity records.
    	list<Opportunity> lstOppRecords = TestDataUtility.getOpportunityRecords(1);
    	insert lstOppRecords;
    	
    	system.debug('*****lstOppRecords****'+lstOppRecords);
    	
    }
}