public class ExperianPageController {

	// Constructor - this only really matters if the autoRun function doesn't work right
    private final Opportunity o;

    public ExperianPageController(ApexPages.StandardController stdController) {
        this.o = (Opportunity)stdController.getRecord();
    }
     
    // Code we will invoke on page load.
    public PageReference autoRun() {

        Callout_Settings__c cs = Callout_Settings__c.getOrgDefaults();
        Boolean callEnabled = cs.Experian__c;
        System.debug('Custom setting is active: '+callEnabled);
 
        String theId = ApexPages.currentPage().getParameters().get('id');
        System.debug('Id is '+theId);
        if (theId == null) {
            // Display the Visualforce page's content if no Id is passed over
            return null;
        }
 		
 		Integer conCount = [SELECT count() FROM OpportunityContactRole WHERE OpportunityId = :theId];
        System.debug('Number of contacts is '+conCount);
 		// Only pull credit if there are contact roles associated to the contact
 		if(conCount < 1) {
 			throw new creditPullException('There are no contacts related to this opportunity.  Add contacts if you want to pull credit');
 		} else {
 			for (Opportunity o : [SELECT Send_to_Experian__c FROM Opportunity WHERE Id =:theId]) {
 				if(!o.Send_to_Experian__c && callEnabled) {
 					o.Send_to_Experian__c = true;
                    try { update o; } catch (DmlException de) { System.debug(de.getMessage()); } catch (Exception e) { System.debug(e.getMessage()); }
 				}
	        }
 		}
        
 
        // Redirect the user back to the original page
        PageReference pageRef = new PageReference('/' + theId);
        pageRef.setRedirect(true);
        return pageRef;
 
    }

    public class creditPullException extends Exception{}

}