global with sharing class GRIDContactRolesController {

    //declaration
    //public static Map<String, Schema.SObjectType> globalMap;
    public List<OpportunityContactRole > conRoleLst;
    public List<ContactRoleWrapper> conRoleWrapperLst;
    public Map<Id, OpportunityContactRole > conRoleFromDbMap;
    public Set<String> conRoleFieldsApiSet;
    public String conRoleFieldsString = '';
    public String conRoleAggregateQueryStr = '';
    public Set<String> conRoleFieldSumSet                  {get; set;}
    public Map<String, Decimal> conRoleFieldToSumMap       {get; set;}
    private String oppId;
    public List<Schema.FieldSetMember> conRoleFieldsetList {get; set;}
    public Boolean conRoleFirstRun;
    public Integer conRoleOffsetsize  {get; set;}
    public Integer conRoleBlockSize   {get; set;}
    public Integer conRoleRecordCount {get; set;}
    public Id recordToDelete        {get;set;}
    public Integer conRoleindexToRemove    {get;set;}
    public Boolean conRoleSingleErrorOnSave;
    public Boolean conRoleIsNewBtnPress;
    public String conRoleFieldType;
    public string conRoleSortDirection                                                      {get; set;}
    public String conRoleSortExpression                                                     {get; set;}
    public Integer conRoleIndexToFetch                                                      {get; set;}
    public Boolean conRoleEditAll;
    public String conRoleSortExprFieldApi                                                   {get; set;}
    public static Map<String, GRIDTabsSetting__mdt> customMetaDataSettingMap;
    public boolean conRoleIsDisable                                                         {get; set;}
    // Editall Attribute
    public Boolean conRoleEditAllFlag                                                       {get; set;}
    // boolean to handle save success message on navigation
    public Boolean conRolePageNavigated;
    public String roleDefaultValue = '';

    public GRIDContactRolesController()
    {
        if(GRIDOnloadStaticVariable.flipContactRole())
        {
             conRoleIsDisable = false;
             oppId = Apexpages.currentPage().getParameters().get('id');
             if(oppId == null || oppId == '') {
                conRoleIsDisable = true;
             }
             customMetaDataSettingMap = GRIDOnloadStaticVariable.getCustomMetaDataMap();
             
             conRoleIsNewBtnPress = false;
             conRoleOffsetsize = 0;
             conRoleBlockSize = (Integer)customMetaDataSettingMap.get('Contact_Roles').PageSize__c;
             conRoleRecordCount = 0;
             conRoleWrapperLst = new List<ContactRoleWrapper>();
             conRoleLst = new List<OpportunityContactRole>();
             conRoleFromDbMap = new Map<Id, OpportunityContactRole>();
             conRoleFieldsApiSet = new Set<String>();
             conRolefieldSumSet = new Set<String>();
             conRoleFieldToSumMap = new Map<String, Decimal>();
             conRoleSortDirection = 'DESC';
             conRoleSortExpression = 'CreatedDate';
             conRoleFieldType = '';
             conRoleEditAll = false;
             conRolePageNavigated = false;

              conRoleFieldsApiSet.add('ContactId');
              conRoleFieldsApiSet.add('Contact.Name');
              conRoleFieldsApiSet.add('IsPrimary');
              conRoleFieldsApiSet.add('OpportunityId');
              conRoleFieldsApiSet.add('Role');
              conRoleFieldsApiSet.add('Contact.Email');
              conRoleFieldsApiSet.add('Contact.MobilePhone');
              conRoleFieldsApiSet.add('Contact.Phone');
              conRoleAggregateQueryStr = buildContactRoleAggregateQuery(conRoleFieldsApiSet);
              conRoleFieldToSumMap = getContactRoleFieldSum(conRoleAggregateQueryStr);
              if(oppId != null && oppId != '')
                  conRoleLst = getContactRoleFromDB(oppId, conRoleBlockSize , conRoleOffsetsize , conRoleFieldsApiSet, conRoleSortExpression, conRoleSortDirection);
              //conRoleFieldsApiSet 
              roleDefaultValue = String.valueOf(OpportunityContactRole.Role.getDescribe().getDefaultValue());
              conRoleFirstRun = true;
        }
    }

    // method to build dynamic query for SUM and COUNT
    public String buildContactRoleAggregateQuery(Set<String> pConRoleFieldsApiSet)
    {
        conRoleAggregateQueryStr = 'SELECT ';
        conRoleAggregateQueryStr += 'COUNT(Id) conRoleCount FROM OpportunityContactRole Where  OpportunityId = \''+oppId+'\'';
        return conRoleAggregateQueryStr;
    }

    // method to query and get the sum of numeric fields
    public Map<String, Decimal> getContactRoleFieldSum(String pConRoleAggregateQueryStr)
    {
        if(oppId <> null && oppId <> '') 
        {
            List<SObject> conRoleSumQueryResult = new List<SObject>();
            conRoleSumQueryResult = Database.query(pConRoleAggregateQueryStr);
            
            conRoleRecordCount = (Integer)conRoleSumQueryResult[0].get('conRoleCount');
           
            return conRoleFieldToSumMap;
        }
        conRoleRecordCount = 0;
        return null;
    }

    // method to build a map from a list from DB
    public Map<Id, OpportunityContactRole> getContactRoleMapFromList(List<OpportunityContactRole> pConRoleLst) 
    {
        conRoleFromDbMap.clear();
        for(OpportunityContactRole conRoleInstance :pConRoleLst) 
        {
            conRoleFromDbMap.put(conRoleInstance.Id, conRoleInstance);
        }
        return conRoleFromDbMap;
    }

    // method to get syndications from DB
    public List<OpportunityContactRole> getContactRoleFromDB(String pOppId, Integer pConRoleBlockSize, Integer pConRoleOffsetSize, Set<String> pConRoleFieldsApiSet,
                                                             String pconRoleSortExpression, String pconRoleSortDirection) 
    {
        if(pOppId<> null && pOppId<> '') 
        {
            //conRoleLst.clear();
            String conRoleQueryStr = '';
            conRoleFieldsString = MCAUtility.getStringfromSet(pConRoleFieldsApiSet, null);
            conRoleQueryStr = 'Select ' +conRoleFieldsString + 
                              ' From OpportunityContactRole Where OpportunityID =:pOppId ORDER BY '+pconRoleSortExpression+' '+pconRoleSortDirection+' NULLS LAST LIMIT '
                               +pConRoleBlockSize+' Offset ' +pConRoleOffsetSize;

            return database.query(conRoleQueryStr);
        }
        return new List<OpportunityContactRole>();
    }

    // method to create new payables
    public void newContactRole() 
    {
        conRoleIsNewBtnPress = true;
        if(!conRoleEditAll)
        {
            saveContactRoles();
        }
        else
        {
            conRoleSingleErrorOnSave = false;
        }
        conRoleIsNewBtnPress = false;
        
        if(!conRoleSingleErrorOnSave)
        {
            // to add new record only on first page
            if(conRoleOffsetsize <> 0) 
            {
                conRoleOffsetsize = 0;
                beginningContactRoles();
            }
            
            OpportunityContactRole roleNew = new OpportunityContactRole(OpportunityId = oppId, Role = roleDefaultValue);
            
                /*need to add at 0th index if list size > 0 else simple add will work*/
                if(conRoleWrapperLst.size() > 0 && conRoleLst.size() > 0)
                {
                    conRoleWrapperLst.add(0, new ContactRoleWrapper(roleNew, null, true));
                    conRoleLst.add(0, roleNew);
                }
                else
                {
                    conRoleWrapperLst.add(new ContactRoleWrapper(roleNew, null, true));
                    conRoleLst.add(roleNew);
                }
            // reindexing
            for(Integer i = 0; i < conRoleWrapperLst.size(); i++)
            {
                conRoleWrapperLst[i].conRoleIndex = i;
            }
        }
    }

    // mehotd to fetch details of changed contact role
    public void contactFetch()
    {
        List<Contact> detailContact=[Select Id, Phone, MobilePhone, Email from Contact where Id=:conRoleWrapperLst[conRoleIndexToFetch].conRole.ContactId];
        if(detailContact != null && detailContact.size() > 0)
        {
          conRoleWrapperLst[conRoleIndexToFetch].conRoleContact = detailContact[0];
        }
        else
        {
            ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info, 'You do not have access on the selected contact. Please contact your administrator.'));        
        }
    }//end contactFetch

    // method to cave payable
    public void saveContactRoles()
    {
        String conRoleMsgStr = '';
        String contactMsgStr = '';
        String conRoleSuccessMsgStr ='';
        String contactSuccessMsgStr ='';
        conRoleSingleErrorOnSave = false;
        Boolean conRoleIsUpdated = false;
        conRoleEditAll = false;
        List<OpportunityContactRole> conRoleListToUpdate = new List<OpportunityContactRole>();
        List<Contact> contactListToUpdate = new List<Contact>();
        Map<Integer, Integer> conRoleErrorToWraperIndexMap = new map<Integer, Integer>();
        Map<Integer, Integer> contactErrorToWraperIndexMap = new map<Integer, Integer>();
        List<OpportunityContactRole> conRoleTempLst = getContactRoleFromDB(
            oppId,
            conRoleBlockSize,
            conRoleOffsetsize,
            conRoleFieldsApiSet,
            conRoleSortExpression,
            conRoleSortDirection
        );
        conRoleFromDBMap = getContactRoleMapFromList(conRoleTempLst);
        for(ContactRoleWrapper conRoleWraperInstance :conRoleWrapperLst) {
            OpportunityContactRole conRoleDBObj = conRoleFromDBMap.get(conRoleWraperInstance.conRole.Id);
            conRoleIsUpdated = false;
            if(conRoleWraperInstance.conRole != null && conRoleDBObj != null) {
                for(String conRoleFieldInstance :conRoleFieldsApiSet)   {
                    if(!conRoleFieldInstance.contains('.Name')) {
                        if(conRoleFieldInstance.contains('Contact.')) {
                            if(conRoleDBObj.Contact != null) {
                                conRoleFieldInstance = conRoleFieldInstance.substringafter('Contact.');
                                conRoleIsUpdated  = conRoleIsUpdated ||
                                    (conRoleWraperInstance.conRoleContact.get(
                                        conRoleFieldInstance) != conRoleDBObj.Contact.get(conRoleFieldInstance));
                            }
                        } else {
                            conRoleIsUpdated  = conRoleIsUpdated 
                                ||(conRoleWraperInstance.conRole.get(
                                    conRoleFieldInstance) != conRoleDBObj.get(conRoleFieldInstance));
                        }
                    }
                }
            }else{
                if(!conRoleIsNewBtnPress) {
                     conRoleIsUpdated = true;
                }
            }
            if(conRoleIsUpdated)
            {
                conRoleListToUpdate.add(conRoleWraperInstance.conRole);
                contactListToUpdate.add(new Contact(
                    Id = conRoleWraperInstance.conRole.ContactId,
                    Email = conRoleWraperInstance.conRoleContact.Email,
                    MobilePhone = conRoleWraperInstance.conRoleContact.MobilePhone,
                    Phone = conRoleWraperInstance.conRoleContact.Phone)
                );
                conRoleErrorToWraperIndexMap.put(conRoleListToUpdate.size()-1, conRoleWraperInstance.conRoleIndex);
                contactErrorToWraperIndexMap.put(contactListToUpdate.size()-1, conRoleWraperInstance.conRoleIndex);
            }
            conRoleWraperInstance.conRoleEdit = conRoleEditAllFlag;
        }
        try {
            if((conRoleListToUpdate != null && conRoleListToUpdate.size() >0) 
               || (contactListToUpdate != null && contactListToUpdate.size() > 0)) {
               
               List<Database.upsertResult> conRoleresults = Database.upsert(conRoleListToUpdate, false);
                for (Integer i =0; i < conRoleresults.size(); i++) {
                    if (!conRoleresults[i].isSuccess()) {
                        for (Database.Error err : conRoleresults[i].getErrors()) {
                             String recordError = err.getMessage();
                             /*
                             if(recordError.contains('insufficient access rights on'))
                             {
                                 recordError = 'You do not have the 
                                 level of access necessary to perform 
                                 the operation you requested on contact role.
                                  Please contact the owner of the record or your 
                                  administrator if access is necessary.';
                             }
                             else
                             {
                             
                                conRoleWrapperLst[conRoleErrorToWraperIndexMap.get(i)].conRoleEdit = true; 
                                
                             }*/
                             if(!recordError.contains('insufficient access rights on')) {
                                 conRoleWrapperLst[conRoleErrorToWraperIndexMap.get(i)].conRoleEdit = true; 
                             }
                             conRoleSingleErrorOnSave = true;
                             if(conRoleresults.size() > 1) {
                                 conRoleMsgStr = conRoleMsgStr 
                                    + 'Error Record'
                                    +(conRoleErrorToWraperIndexMap.get(i)+1)
                                    +' : '+ recordError + '<br />'; 
                             } else {
                                conRoleMsgStr = conRoleMsgStr 
                                    + 'Error Record'
                                    +(conRoleErrorToWraperIndexMap.get(i)+1)
                                    +' : '+ recordError ; 
                             }
                        }
                    }
                    else if(conRoleresults[i].isSuccess()) {
                        if(conRoleListToUpdate.size() > 1) {
                            conRoleSuccessMsgStr = conRoleSuccessMsgStr
                                + 'Success Record '
                                +(conRoleErrorToWraperIndexMap.get(i)+1)
                                +' : '+ 'saved successfully!' + '<br />';
                            
                        } else {
                            conRoleSuccessMsgStr = conRoleSuccessMsgStr
                                + 'Success Record '
                                +(conRoleErrorToWraperIndexMap.get(i)+1)
                                +' : '+ 'saved successfully!' ;
                        }
                         conRoleWrapperLst[conRoleErrorToWraperIndexMap.get(i)].conRoleEdit = conRoleEditAllFlag;
                    }
                }
                conRoleSuccessMsgStr = conRoleSuccessMsgStr.removeEnd('<br />');
                conRoleMsgStr = conRoleMsgStr.removeEnd('<br />');
                List<Database.upsertResult> contactResults = Database.upsert(contactListToUpdate, false);
                for(Integer i = 0; i < contactResults.size(); i++) 
                {
                    if (!contactResults[i].isSuccess())
                    {
                        for (Database.Error err : contactResults[i].getErrors())
                        {
                             String recordError = err.getMessage();
                             /*
                             if(recordError.contains('insufficient access rights on'))
                             {
                                 recordError = 'You do not have the level of access necessary 
                                 to perform the operation you requested on contact. 
                                 Please contact the owner of the record or your 
                                 administrator if access is necessary.';
                             }
                             else
                             {
                                conRoleWrapperLst[contactErrorToWraperIndexMap.get(i)].conRoleEdit = true; 
                                
                             }*/
                             if(!recordError.contains('insufficient access rights on'))
                             {
                                 conRoleWrapperLst[contactErrorToWraperIndexMap.get(i)].conRoleEdit = true; 
                             }
                             conRoleSingleErrorOnSave = true;
                             if(contactResults.size() > 1) {
                                 contactMsgStr = contactMsgStr 
                                    + 'Error Record'
                                    +(contactErrorToWraperIndexMap.get(i)+1)
                                    +' : '+ recordError + '<br />'; 
                             } else {
                                contactMsgStr = contactMsgStr 
                                    + 'Error Record'
                                    +(contactErrorToWraperIndexMap.get(i)+1)
                                    +' : '+ recordError ; 
                             }
                        }
                    }
                    
                    else if(contactResults[i].isSuccess())
                    {
                        if(contactListToUpdate.size() > 1) {
                            contactSuccessMsgStr = contactSuccessMsgStr
                                + 'Success Record '
                                +(contactErrorToWraperIndexMap.get(i)+1)
                                +' : '+ 'saved successfully!' + '<br />';
                            
                        } else {
                            contactSuccessMsgStr = contactSuccessMsgStr
                                + 'Success Record '
                                +(contactErrorToWraperIndexMap.get(i)+1)
                                +' : '+ 'saved successfully!';
                        }
                        conRoleWrapperLst[contactErrorToWraperIndexMap.get(i)].conRoleEdit = conRoleEditAllFlag;
                    }
                }
                contactSuccessMsgStr = contactSuccessMsgStr.removeEnd('<br />');
                contactMsgStr = contactMsgStr.removeEnd('<br />');
                if(conRoleSingleErrorOnSave == false && !conRoleIsNewBtnPress)
                {
                  conRoleLst = getContactRoleFromDB(oppId, conRoleBlockSize, conRoleOffsetsize, conRoleFieldsApiSet, conRoleSortExpression, conRoleSortDirection);
                  conRoleFieldToSumMap = getContactRoleFieldSum(conRoleAggregateQueryStr);
                  conRoleFirstRun = true;
                }
                if((String.isNotBlank(conRoleMsgStr) || String.isNotBlank(contactMsgStr)) || (String.isNotBlank(conRoleSuccessMsgStr) || String.isNotBlank(contactSuccessMsgStr))) 
                {
                    if(conRolePageNavigated)
                    {
                        //conRolePageNavigated = false;
                        conRoleSuccessMsgStr = 'Last changes made by you were saved successfully!';
                    }
                    if(String.isNotBlank(contactMsgStr)) {
                        if(String.isNotBlank(conRoleSuccessMsgStr) ||
                         String.isNotBlank(contactSuccessMsgStr)) {
                            ApexPages.addMessage(new Apexpages.Message(
                                ApexPages.Severity.Info, conRoleMsgStr 
                                + ' ' +contactMsgStr  +'<br/>'
                                + conRoleSuccessMsgStr + ' ' +contactSuccessMsgStr)
                            );
                        } else {
                            ApexPages.addMessage(new Apexpages.Message(
                                ApexPages.Severity.Info, conRoleMsgStr 
                                    + ' ' +contactMsgStr)
                            );
                        }
                    } else {
                        ApexPages.addMessage(new Apexpages.Message(
                            ApexPages.Severity.Info,conRoleSuccessMsgStr.removeEnd('<br />') )
                        );
                    }
                }
            }
            conRolePageNavigated = false;
        }
        catch (Exception e)
        {
             ApexPages.addMessage(new Apexpages.Message(
                ApexPages.Severity.Info, MCAExceptionHandlerUtility.getErrorMessage(e))
                );
             conRoleFirstRun = false;
        }
    }

    // method to edit all contactRoles
    public void editAllContactRoles()
    {
        conRoleFirstRun = false;
        conRoleEditAll = true;
        for(Integer i=0; i< conRoleWrapperLst.size(); i++) 
        {
            conRoleWrapperLst[i].conRoleEdit = true;
        }
    }

    // method to refresh
    public void refreshContactRoles()
    {
        conRoleLst = getContactRoleFromDB(oppId, conRoleBlockSize, conRoleOffsetsize, conRoleFieldsApiSet, conRoleSortExpression, conRoleSortDirection);
        conRoleFieldToSumMap = getContactRoleFieldSum(conRoleAggregateQueryStr);
        conRoleFirstRun = true;
    }

    // method to delete payables
    public void deleteContactRole()
    {
        if(conRoleWrapperLst[conRoleIndexToRemove].conRole.Id != null) 
         {
            try
            {
                delete conRoleWrapperLst[conRoleIndexToRemove].conRole;
            }
            catch(Exception e)
            {
                ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info,MCAExceptionHandlerUtility.getErrorMessage(e)));
            }
         }
         
         conRoleLst.remove(conRoleIndexToRemove);
         conRoleWrapperLst.remove(conRoleIndexToRemove);
         
        //re-indexing
        for(Integer i=0;i < conRoleWrapperLst.size();i++)
        {
            conRoleWrapperLst[i].conRoleIndex = i;
        }
        if(conRoleWrapperLst.size() <= 0)
        {
            refreshContactRoles();
        }
        conRoleFieldToSumMap = getContactRoleFieldSum(conRoleAggregateQueryStr);
    }

    //method to sort list of offers
    public void sortContactRoles()
    {
        string conRoleReferenceFieldName = '';
        conRoleFieldType = Apexpages.currentPage().getParameters().get('conRoleTypeParam');
        if(conRoleFieldType.equalsIgnoreCase('REFERENCE'))
        {
            if(conRoleSortExpression.contains('__c'))
            {
                conRoleReferenceFieldName += conRoleSortExpression.substringBefore('__c')+'__r.Name';
            }
            else 
            {
                conRoleReferenceFieldName += conRoleSortExpression.substringBefore('Id')+'.Name';
            }
            conRoleSortExpression = string.valueOf(conRoleReferenceFieldName);
        }
        refreshContactRoles();
    }

    // method to get List wrapper 
    public List<ContactRoleWrapper> getConRoleWrapperLst()
    {
        if(conRoleFirstRun)
        {
            conRoleWrapperLst = new List<ContactRoleWrapper>();
        }
        if(conRoleLst<> null && conRoleLst.size() > 0 ) 
        {
            if(conRoleFirstRun)
            {
                //conRoleWrapperLst = new List<ContactRoleWrapper>();
                for (Integer i = 0; i < conRoleLst.size(); i++) 
                {
                    conRoleWrapperLst.add(new ContactRoleWrapper(conRoleLst[i], i, conRoleEditAllFlag));
                }
                conRoleFirstRun = false;
            }
        }
        //conRoleFieldToSumMap = getContactRoleFieldSum(conRoleAggregateQueryStr);
        return conRoleWrapperLst;
    }

    //method for the first page of list to be displayed
    public void beginningContactRoles() 
    {
        conRolePageNavigated = true;
        saveContactRoles();
        if (!conRoleSingleErrorOnSave)
        {
            conRoleOffsetsize = 0;
            conRoleLst = getContactRoleFromDB(oppId, conRoleBlockSize, conRoleOffsetsize, conRoleFieldsApiSet, conRoleSortExpression, conRoleSortDirection);
            conRoleFirstRun = true;
        }
    }

    //method for previous page of list to be displayed
    public void previousContactRoles() 
    {
        conRolePageNavigated = true;
        saveContactRoles();
        if(!conRoleSingleErrorOnSave && conRoleBlockSize <= conRoleOffsetsize)
        {
            conRoleOffsetsize = conRoleOffsetsize - conRoleBlockSize;
            conRoleLst = getContactRoleFromDB(oppId, conRoleBlockSize, conRoleOffsetsize, conRoleFieldsApiSet, conRoleSortExpression, conRoleSortDirection);
            conRoleFirstRun = true;
        } 
    } 

    //method for next page of list to be displayed
    public void nextContactRoles() 
    {
        conRolePageNavigated = true;
        saveContactRoles();
        if(!conRoleSingleErrorOnSave && conRoleOffsetsize <= conRoleRecordCount) 
        {
            conRoleOffsetsize = conRoleOffsetsize + conRoleBlockSize;
            conRoleLst = getContactRoleFromDB(oppId, conRoleBlockSize, conRoleOffsetsize, conRoleFieldsApiSet, conRoleSortExpression, conRoleSortDirection);
            conRoleFirstRun = true;
        }
    }

    //method for last page of list to be displayed
    public void endContactRoles() 
    {
        conRolePageNavigated = true;
        saveContactRoles();
        if(!conRoleSingleErrorOnSave && math.mod(conRoleRecordCount , conRoleBlockSize) == 0){
            conRoleOffsetsize = conRoleBlockSize * ((conRoleRecordCount/conRoleBlockSize)-1);
            
        } else if (!conRoleSingleErrorOnSave && math.mod(conRoleRecordCount , conRoleBlockSize) != 0){
            
            conRoleOffsetsize = conRoleBlockSize * ((conRoleRecordCount/conRoleBlockSize));
        }
        conRoleLst = getContactRoleFromDB(oppId, conRoleBlockSize, conRoleOffsetsize, conRoleFieldsApiSet, conRoleSortExpression, conRoleSortDirection);
        conRoleFirstRun = true;
    }

    public class ContactRoleWrapper 
    {
        public OpportunityContactRole conRole                                           {get; set;}
        public Integer conRoleIndex                                                     {get; set;}
        public Boolean  conRoleEdit                                                     {get; set;}
        public Contact  conRoleContact                                                  {get; set;}
        public ContactRoleWrapper (OpportunityContactRole conRoleInstance,  Integer pConRoleIndex, Boolean  pConRoleEdit) 
        {
            conRole = conRoleInstance;
            conRoleIndex = pConRoleIndex;
            conRoleEdit = pConRoleEdit;
            conRoleContact = (new Contact(id = conRole.ContactId, 
                                          Email = conRole.Contact.Email,
                                          Phone = conRole.Contact.Phone, 
                                          MobilePhone = conRole.Contact.MobilePhone));
        }
    }
}