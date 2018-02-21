/****************************************************************************************************************
* Name                  : TeamBuildingTrigger                                                            		*
* Test Class            : ManageTeamsAgenciesInventoriesCtrl_Test                                               *
* Description           : This trigger will create the Team users or Agency users in Inventory Users            *
* Created By            : NSI - Sivasankar K                                                                    *               
* Created Date          : 07/Feb/2017                                                                           *   
* Last Modified Date    :                                                                                       *
* Last Modified By      :                                                                                       *
* ------------------------------------------------------------------------------------------------------------  *
* ChangeHistroy     VERSION     AUTHOR                     DATE             Description                         *
* CH00              1.0         NSI - Sivasankar K         07/Feb/2017      Initial developmen                  *
* CH01              2.0                                                                                         *
*****************************************************************************************************************/
trigger TeamBuildingTrigger on Team_Building__c (before insert,after insert,before update,after update,before delete, after delete) {
    TriggerFactoryCls.createHandler(Team_Building__c.sObjectType);
}