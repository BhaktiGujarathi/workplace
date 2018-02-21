/**************************************************************************************************
* Name               : DeleteAssignedPCsBatchScheduler                                            *
* Description        : Scheduler class for DeleteAssignedPCsBatch class.                    *
* Created Date       : 06/05/2017                                                                 *
* Created By         : NSI                                                                        *
* ----------------------------------------------------------------------------------------------- *
* VERSION     AUTHOR            DATE            COMMENTS                                          *
* 1.0         NSI - Siva      06/05/2017      Initial Draft.                                    *
**************************************************************************************************/
public with sharing class DeleteAssignedPCsBatchScheduler implements Schedulable{

    public void execute(SchedulableContext SC) {
        DeleteAssignedPCsBatch batchObject = new DeleteAssignedPCsBatch();
        Database.executeBatch(batchObject,10); 
    }
}