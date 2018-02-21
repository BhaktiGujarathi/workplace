trigger VerificationAfterInsertUpdateDelete on UWVerification__c (after insert, after update, after delete) {

    if (Trigger.isInsert || Trigger.isUpdate) {     

        OpportunityRollUpHandler handler = new OpportunityRollUpHandler(Trigger.new);
    }

    if (Trigger.isDelete) {

        OpportunityRollUpHandler handler = new OpportunityRollUpHandler(Trigger.old);
    }   
        
}