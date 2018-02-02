/*
    Class Name : TBN_ScheduledBatchForUpdatingAccountType
    Created By : Aditya 
    Created on : 08-04-2015
    Description: Batch Class to update the Update the Type field of Account from 'Active' to 'Inactive' that has been created more than 90 days.
*/

@isTest(SeeAllData = false)
private class TBN_TestScheduledBatchForUpdating 
{
    static testMethod void TestBatchScheduler() 
    {
        // Start Test
        Test.StartTest();
        
            String CRON_EXP = '0 0 4 * * ?';
            TBN_ScheduledBatchForUpdatingAccountType objSch = new TBN_ScheduledBatchForUpdatingAccountType();
            system.schedule('Schedule daily at 4AM CST', CRON_EXP, objSch);
        
        //Stop Test
        Test.StopTest();      
    }
}