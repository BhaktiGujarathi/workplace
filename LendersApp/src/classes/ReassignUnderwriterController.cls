public with sharing class ReassignUnderwriterController {
    
    private Opportunity opportunity;

    public ReassignUnderwriterController() {
        
        String opportunityId = ApexPages.currentPage().getParameters().get('oid');

        for (Opportunity opp : [SELECT Id 
                                  FROM Opportunity
                                 WHERE Id = :opportunityId]) {
            opportunity = opp;
        }
    }

    public PageReference assignUnderwriter() {
        
        if (opportunity != null) {

            UnderwriterAssignmentHandler assignmentHandler = new UnderwriterAssignmentHandler(opportunity);
            assignmentHandler.assign();

            return new PageReference('/' + opportunity.Id);            
        }

        return new PageReference('/home/home.jsp');        
    }
}