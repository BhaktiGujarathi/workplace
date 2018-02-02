trigger createTask on Note_Comment__c ( after insert){
    TriggerFactory.createAndExecuteHandler(NoteCommentHandler.class);
}