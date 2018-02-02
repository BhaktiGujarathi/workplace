trigger Referral on Referral__c  (before insert,after insert, after update) {
    TriggerFactory.createAndExecuteHandler(ReferralHandler.class);

}