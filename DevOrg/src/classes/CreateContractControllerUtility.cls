public with sharing class CreateContractControllerUtility { 
    
    // method to replace a null value by 0
    public static decimal treateNullAsZero(Decimal pValue)
    {
        return (pValue == null) ?  0.00 : pValue;
    }
    
    // method to construct a string from Set
    public static String getStringfromSet(Set<String> theSet, String separator) {
        if (theSet == null) {
            return null;
        }
        if (separator == null) {
            separator = '';
        }

        String joinedString = '';
        Boolean firstItem = true;
        for (String item : theSet) {
            if(null != item) {
                if(firstItem){
                    firstItem = false;
                }
                else {
                    joinedString += separator;               
                }
                joinedString += item+ ', ';
            }
        }
        joinedString = joinedString.removeEnd(', ');
        joinedString += ' ';
        return joinedString;
    }
    
    // method to delete sobject
    public static list<SObject> deleteForSObject(list<SObject> SObjectList,Integer rowNum){
        list<SObject> sObjectDelList = new list<SObject>();
        list<UserRecordAccess> UserRecordAccessListNullChk = new list<UserRecordAccess>();
        set<Id> sObjectIdSet = new set<Id>();
        Boolean hasDeleteAccess;
        //rowNum = Integer.valueOf(apexpages.currentpage().getparameters().get('index'));
        
        if( rowNum != null  && SObjectList.size() >=  (rowNum-1))
        {
            if(SObjectList[rowNum-1].Id == null)
            {
                SObjectList.remove(rowNum-1);
            }
            else
            {
                sObjectIdSet.add(SObjectList[rowNum-1].Id);
                // user delete permission from user accress tab
                UserRecordAccessListNullChk = checkUserAccessForSobject(sObjectIdSet,UserInfo.getUserId());
                if(UserRecordAccessListNullChk.size() > 0)
                hasDeleteAccess = UserRecordAccessListNullChk[0].HasDeleteAccess;
                if(hasDeleteAccess)
                {
                    sObjectDelList.add(SObjectList[rowNum-1]);
                    SObjectList.remove(rowNum-1);
                }
                else
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error,'Insufficient privilege to delete this record'));
                }
            }
        }
        return sObjectDelList;
    }
    
    public static list<UserRecordAccess> checkUserAccessForSobject(Set<ID> IdSet, Id userId )
    {
        list<UserRecordAccess> listUserRecordAccess = new list<UserRecordAccess>();
        listUserRecordAccess = [SELECT RecordId,
                                       HasReadAccess,
                                       HasEditAccess,
                                       HasDeleteAccess
                                FROM UserRecordAccess
                                WHERE UserId =: userId AND
                                RecordId IN : IdSet];
        return listUserRecordAccess;
    }//End checkUserAccessSobject

    // method to upsert sobject 
    public static void upsertForSObject(list<SObject> sobjectList)
    {
        list<Sobject > lstSobjectToInsert = new list<Sobject >();
        list<Sobject > lstSobjectToUpdate = new list<Sobject >();
        
        for(Sobject sObj:sobjectList )
        {
            if(sObj.id == null)
            {
                lstSobjectToInsert.add(sObj);
            }
            else
            {
                lstSobjectToUpdate.add(sObj);
            }
        }
        
        try
        {
            if(!lstSobjectToInsert.isEmpty())
            insert lstSobjectToInsert;
            
            if(!lstSobjectToUpdate.isEmpty())
            update lstSobjectToUpdate;
        }
        Catch(SObjectException e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, MCAExceptionHandlerUtility.getErrorMessage(e)));
            
        }
    }
    // check save access for a user
    public static list<sObject> checkSaveAccessForSObject(List<sObject> SObjectList, Id userId )
    {
        map<Id,sObject> currentSObjectMap = new map<Id,sObject>();
        list<sObject> finalSObjectList = new list<sObject>();
        list<UserRecordAccess> listUserRecordAccess = new list<UserRecordAccess>();
        
        for(sObject obj : SObjectList)
        {
            if(obj.get('Id') != NULL)
            {
                currentSObjectMap.put((ID)obj.get('Id'),obj);
            }
            else
            {
                finalSObjectList.add(obj);
            }
        }
        
        if(currentSObjectMap != NULL && currentSObjectMap.size() > 0)
        {
            listUserRecordAccess = CreateContractControllerUtility.checkUserAccessForSobject(currentSObjectMap.keySet(),userId);
            for(UserRecordAccess objUserAccess : listUserRecordAccess)
            {
                if(objUserAccess.HasReadAccess && objUserAccess.HasEditAccess )
                finalSObjectList.add(currentSObjectMap.get(objUserAccess.RecordId));
            }
        }
        return finalSObjectList;
    }
}