global with sharing class CloneInsuranceCompany {

    WebService static Id triggerInsurnaceCompanyClone(Id accountId, String accountName){
        String INS_COMPANY_RECORDTYPE = 'Insurance Company';
        SObjectClone cloneClass = new SObjectClone(Account.SObjectType);
        Account sourceAccount = new Account();
        if(accountId != null) {
            sourceAccount = [SELECT id,
                                    Name,
                                    RecordTypeId,
                                    RecordType.Name
                               FROM Account
                              WHERE id =: accountId];
        }
        if(sourceAccount.RecordTypeId == cloneClass.recordTypeMap.get('Insurance_Company')) {            
            Map<String, String> relatedRecordNameMap = getAccountRelatedRecordsMap();
            InsuranceCompanyInitializer accountInitializer = new InsuranceCompanyInitializer();
            accountInitializer.accountName = accountName;
            Account clonedAccount = (Account)cloneClass.setFieldSet(SObjectType.Account.FieldSets.Clone_Insurance_Fields_to_Clone)
                                                       .setRelationshipNameSet(relatedRecordNameMap.keySet())
                                                       .setInitializer(accountInitializer)
                                                       .setTargetRecordTypeId('Insurance_Company')
                                                       .Clone(accountId);
            return clonedAccount.Id;
        }
        else {
            throw new InsuranceCompanyCloneException('Only Insurance Company can be cloned.');
            return null;
        }
    }

    // cloned account initializer
    public class InsuranceCompanyInitializer implements CloneInitializer{
        public String accountName = '';
        public SObject initialize(Id parentId, SObject clonedRecord){
            Account clonedAccount = (Account)clonedRecord;
            clonedAccount.Name = accountName;

            return clonedAccount;
        }
    }

    // method to get map of custom setting records 
    public static Map<String, String> getAccountRelatedRecordsMap(){
        Map<String, String> relationshipToObjectNameMap = new Map<String, String>();
        
        Map<String, Clone_Insurance_Related_Objects_To_Clone__c> objectsToCloneMap = Clone_Insurance_Related_Objects_To_Clone__c.getAll();

        for(Clone_Insurance_Related_Objects_To_Clone__c settingInstance : objectsToCloneMap.values()) {

            if(!relationshipToObjectNameMap.containsKey(settingInstance.Insurance_Company_Relationship_API_Name__c)) {
                relationshipToObjectNameMap.put(settingInstance.Insurance_Company_Relationship_API_Name__c, 
                                                settingInstance.Name);
            }
        }
        return relationshipToObjectNameMap;
    }

    // custom exception for step down
    public class InsuranceCompanyCloneException extends Exception {

    }
}