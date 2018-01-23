trigger FeedItemTrigger on FeedItem (after insert){
   
   if(!ChatterPostUtill.FeedBoolean){
      ChatterPostUtill.FeedBoolean = true;
    TriggerFactory.createAndExecuteHandler(FeedItemHandler.class); 
    
          
   }

}