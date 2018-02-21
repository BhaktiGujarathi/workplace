/**************************************************************************************************
* Name               : DamacCommissionController                                               
* Description        : An apex page controller for                                              
* Created Date       : NSI - Diana                                                                        
* Created By         : 07/March/2017                                                                 
* Last Modified Date :                                                                            
* Last Modified By   :                                                                            
* ----------------------------------------------------------------------------------------------- 
* VERSION     AUTHOR                    DATE                                                                    
* 1.0         NSI - Diana          07/March/2017                                                               
**************************************************************************************************/
public class DamacCommissionController {
/**************************************************************************************************
            Variables used in the class
**************************************************************************************************/
private Contact contactInfo;
private Id accountId;
public List<Agent_Commission__c> agentCommissionList{set;get;}
public Decimal totalUnitPrice{set;get;}
public Decimal totalCommissionAmount{set;get;}
public Integer fieldSetSize{set;get;}

/**************************************************************************************************
    Method:         DamacCommissionController
    Description:    Constructor executing model of the class 
**************************************************************************************************/

	public DamacCommissionController() {

		contactInfo = UtilityQueryManager.getContactInformation();
        //accountId = UtilityQueryManager.getAccountId();
        if(null != contactInfo)
          accountId = contactInfo.AccountID;
        totalCommissionAmount = 0;
        totalUnitPrice = 0;


		Date currentDate = System.now().date();
		Date firstDateOfCurrentMonth = Date.newInstance(currentDate.year(), currentDate.month(), 1);
        Date twoMonthsBackDate = firstDateOfCurrentMonth.addMonths(-2);

		//get all unpaid commissions
		//get all paid commissions for past 3 months
        agentCommissionList = new List<Agent_Commission__c>();
        agentCommissionList = UtilityQueryManager.getCommission(accountId);

        totalCommissionAmount = UtilityQueryManager.totalCommissionAmount;
        totalUnitPrice = UtilityQueryManager.totalUnitPrice;


		system.debug(agentCommissionList);
        List<Schema.FieldsetMember> lstMembers = SObjectType.Agent_Commission__c.FieldSets.Agent_Commission_List.getFields();
        system.debug(lstMembers.size());
        fieldSetSize = (lstMembers.size() == 0)?0:lstMembers.size()-1;
	}
}