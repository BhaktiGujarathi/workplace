Public Class SCQuerySelector
{


public static String querySelectorForAuditTrail()
{

        String queryFields = 'id,Lead__c,opportunity__c,Type__c,Current_Owner__c,current_owner__r.isActive,current_owner__r.Generate_Sales_Rep_Scorecard__c,Current_owner__r.id,New_Owner__r.isActive,New_Owner__c,New_owner__r.Generate_Sales_Rep_Scorecard__c,New_owner__r.id,Object__c,New_Status_Stage_value__c,Date_Time_Change_Was_Made__c';
        String queryObject = 'Audit_Trail__c';
        String queryCondition = '(New_Owner__c != null OR Current_Owner__c != null) AND Type__c IN (\'Status / Stage\' , \'Organic Sub\',\'Outbound Call\' ,\'Create\',\'Owner\') AND Object__c IN (\'Opportunity\',\'Task\',\'Lead\')';
        return 'SELECT '+queryFields+' FROM '+queryObject+' WHERE '+queryCondition;

}


}