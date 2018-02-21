/******************************************************************************************
*  Author   : Ravindra Babu Nagaboina													  *
*  Company  : NSI DMCC																	  *
*  Date     : 03rd Jan 2017                                                               *
*-----------------------------------------------------------------------------------------*
* Modification History                                                                    *
*-----------------------------------------------------------------------------------------*
* V.No   Date            Updated By          Description                                  *
*-----------------------------------------------------------------------------------------*             
* V1.0  03/Jan/2016      Ravi                Created                                      *
******************************************************************************************/
public interface TriggerFactoryInterface {
	
	//Before Trigger Methods
	void executeBeforeInsertTrigger(list<sObject> lstNewRecords);
	void executeBeforeUpdateTrigger(Map<Id, sObject> mapNewRecords, Map<Id, sObject> mapOldRecords);
	void executeBeforeDeleteTrigger(Map<Id, sObject> mapOldRecords);
	void executeBeforeInsertUpdateTrigger(list<sObject> lstNewRecords, Map<Id,sObject> mapOldRecords);
	
	//After Trigger Methods
	void executeAfterInsertTrigger(Map<Id, sObject> mapNewRecords);
	void executeAfterUpdateTrigger(Map<Id, sObject> mapNewRecords, Map<Id, sObject> mapOldRecords);
	void executeAfterDeleteTrigger(Map<Id, sObject> mapOldRecords);
	void executeAfterInsertUpdateTrigger(Map<Id, sObject> mapNewRecords, Map<Id, sObject> mapOldRecords);
}// End of class.