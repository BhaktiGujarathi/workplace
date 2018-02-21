/**************************************************************************************************
* Name               : AccountSalesCalculatorSchedulerTest                                        *
* Description        : Test class for AccountSalesCalculatorScheduler class.                      *
* Created Date       : 21/02/2017                                                                 *
* Created By         : NSI                                                                        *
* ----------------------------------------------------------------------------------------------- *
* VERSION     AUTHOR            DATE            COMMENTS                                          *
* 1.0         NSI - Vineet      21/02/2017      Initial Draft.                                    *
**************************************************************************************************/
@isTest
private class AccountSalesCalculatorSchedulerTest {

    static testMethod void testScheduler() {
    	Test.startTest();
	    	AccountSalesCalculatorScheduler ascsObject = new AccountSalesCalculatorScheduler();
			String sch = '0 0 23 * * ?'; 
			system.schedule('Test Account Sales Calculator Check', sch, ascsObject); 
		Test.stopTest();
    }
}// End of class.