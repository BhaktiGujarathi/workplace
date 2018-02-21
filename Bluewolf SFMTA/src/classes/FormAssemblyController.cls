public with sharing class FormAssemblyController {
    
    @AuraEnabled
    public static String userid() {
        return UserInfo.getUserId();
    }
    
    
}