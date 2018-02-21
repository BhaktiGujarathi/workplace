/**************************************************************************************************
* Name               : DealHandlerScheduler                                                       *
* Description        : Scheduler class for DealHandler batch class.                               *
* Created Date       : 05/01/2017                                                                 *
* Created By         : NSI                                                                        *
* ----------------------------------------------------------------------------------------------- *
* VERSION     AUTHOR            DATE            COMMENTS                                          *
* 1.0         NSI - Vineet      05/01/2017      Initial Draft.                                    *
**************************************************************************************************/
public class DealHandlerScheduler implements Schedulable {
	
	public void execute(SchedulableContext SC) {
		/* Aborting already running batch. */ 
	    for(AsyncApexJob aJob : [SELECT Id ,Status, ApexClass.Name 
	    						 FROM AsyncApexJob 
	    						 WHERE ApexClass.Name = 'DealHandlerBatch' AND 
	    						 	   Status != 'Aborted' AND 
						   			   Status != 'Completed']){
	    	system.AbortJob(aJob.Id);
		}
		DealHandlerBatch dhbObject = new DealHandlerBatch();
		Database.executeBatch(dhbObject); 
	}
}// End of class.