trigger CampaignMemberTrigger on CampaignMember (before insert, before update, after insert, after update) {
    TriggerFactory.createAndExecuteHandler(CampaignMemberHandler.class);
}