/**************************************************************************************************
* Name               : InquiryScoreCalculatorSchedulerTest                                        *
* Description        : Test class for InquiryScoreCalculatorScheduler class.                      *
* Created Date       : 25/05/2017                                                                 *
* Created By         : NSI                                                                        *
* ----------------------------------------------------------------------------------------------- *
* VERSION     AUTHOR            DATE            COMMENTS                                          *
* 1.0         NSI - Vineet      25/05/2017      Initial Draft.                                    *
**************************************************************************************************/
@isTest
private class InquiryScoreCalculatorSchedulerTest {

    static testMethod void testScheduler() {
    	Test.startTest();
	    	InquiryScoreCalculatorScheduler iscsObject = new InquiryScoreCalculatorScheduler();
			String sch = '0 0 0 * * ?'; 
			system.schedule('Test Inquiry Score Calculator Check 1', sch, iscsObject); 
			system.schedule('Test Inquiry Score Calculator Check 2', sch, iscsObject); 
			system.schedule('Test Inquiry Score Calculator Check 3', sch, iscsObject); 
		Test.stopTest();
    }
}// End of class.