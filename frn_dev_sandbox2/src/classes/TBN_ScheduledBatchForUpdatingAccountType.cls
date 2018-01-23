/*
    Class Name : TBN_ScheduledBatchForUpdatingAccountType
    Created By : Aditya 
    Created on : 08-04-2015
    Description: Batch Class to update the Update the Type field of Account from 'Active' to 'Inactive' that has been created more than 90 days.
*/
global class TBN_ScheduledBatchForUpdatingAccountType implements Schedulable
{
     global void execute(SchedulableContext sc) 
     {  
        // We now call the batch class to be scheduled
        TBN_BatchForUpdatingAccountType b = new TBN_BatchForUpdatingAccountType(); 
        
        //Parameters of ExecuteBatch(context,BatchSize)
        database.executebatch(b,10);
     }
}