public with sharing class UnderwriterAssignmentRuleMember {
    
    private Underwriter_Assignment_Rule_Member__c assignmentRuleMember;
    
    public String id { get; set; }
    public String underwriter { get; set; }
    public Datetime lastAssignmentDatetime { get; set; }
    public Integer quota { get; set; }


    public UnderwriterAssignmentRuleMember(Underwriter_Assignment_Rule_Member__c assignmentRuleMember) {
        
        this.assignmentRuleMember = assignmentRuleMember;   

        id = assignmentRuleMember.Id;
        underwriter = assignmentRuleMember.Underwriter__c;
        lastAssignmentDatetime = assignmentRuleMember.Last_Assignment_Date_Time__c;

        if (assignmentRuleMember.Quota__c != null) {
        
            quota = Integer.valueOf(assignmentRuleMember.Quota__c);
        }
        else {

            quota = 0;
        }           
    }

    
    public void updateRecord() {

        assignmentRuleMember.Last_Assignment_Date_Time__c = lastAssignmentDatetime;
        update assignmentRuleMember;
    }   
}