public with sharing class RoleUtility {
    
    //Method to return Salesforce role for relevant IPMS role
    public static String getSalesforceRole(String strIPMSRole) {
        String strSFRole = '';
        if(strIPMSRole.equalsIgnoreCase('CRM-Manager')) {
            strSFRole = 'Manager';
        }
        else if(strIPMSRole.equalsIgnoreCase('CRM-Director')) {
            strSFRole = 'Director';
        }
        else if(strIPMSRole.equalsIgnoreCase('CRM-HOD')) {
            strSFRole = 'HOD';
        }
        else if(strIPMSRole.equalsIgnoreCase('CRM-Committee')) {
            strSFRole = 'Committee';
        }
        return strSFRole;
    }
}