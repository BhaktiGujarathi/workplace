public with sharing class GerneralHandlerForTrigger {
	
	public static void beforeInsertTrigger()
	{
	  
	  for(Position__C vposition:(List<Position__C>)trigger.new)
	  {
	  		vposition.infydisdespune__Apex__c =true;
	  
	  }
			
	
	}

}