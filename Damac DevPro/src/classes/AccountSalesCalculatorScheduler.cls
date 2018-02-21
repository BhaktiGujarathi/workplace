/**************************************************************************************************
* Name               : AccountSalesCalculatorScheduler                                            *
* Description        : Scheduler class for AccountSalesCalculator batch class.                    *
* Created Date       : 05/02/2017                                                                 *
* Created By         : NSI                                                                        *
* ----------------------------------------------------------------------------------------------- *
* VERSION     AUTHOR            DATE            COMMENTS                                          *
* 1.0         NSI - Vineet      05/02/2017      Initial Draft.                                    *
**************************************************************************************************/
public class AccountSalesCalculatorScheduler implements Schedulable {
	public void execute(SchedulableContext SC) {
		AccountSalesCalculator ascObject = new AccountSalesCalculator();
		Database.executeBatch(ascObject); 
	}
}// End of class.