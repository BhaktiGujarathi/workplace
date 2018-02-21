/**************************************************************************************************
* Name               : InquiryScoreCalculatorScheduler                                            *
* Description        : Scheduler class for InquiryScoreCalculator batch class.                    *
* Created Date       : 22/05/2017                                                                 *
* Created By         : NSI                                                                        *
* ----------------------------------------------------------------------------------------------- *
* VERSION     AUTHOR            DATE            COMMENTS                                          *
* 1.0         NSI - Vineet      22/05/2017      Initial Draft.                                    *
**************************************************************************************************/
public class InquiryScoreCalculatorScheduler implements Schedulable {
	
	/*********************************************************************************************
    * @Description : Implementing execute method.                                                *
    * @Params      : SchedulableContext                                                          *
    * @Return      : void                                                                        *
    *********************************************************************************************/
	public void execute(SchedulableContext SC) {
		/* Aborting already running batch. */ 
        for ( AsyncApexJob aJob : [SELECT Id ,Status, ApexClass.Name 
        						   FROM AsyncApexJob 
        						   WHERE ApexClass.Name = 'InquiryScoreCalculator' AND 
        						   		 Status != 'Aborted' AND 
        						   		 Status != 'Completed']){
        	system.AbortJob(aJob.Id);
		}
		InquiryScoreCalculator iscObject = new InquiryScoreCalculator();
		Database.executeBatch(iscObject, 2000); 
	}
}// End of class.