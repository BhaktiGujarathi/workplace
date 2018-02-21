public with sharing class GRIDContactRolesController {

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
    private Id oppId;
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
    public string conRoleSortDirection                                                     {get; set;}
    public String conRoleSortExpression                                                    {get; set;}
    
    public GRIDContactRolesController()
    {
        if(GRIDOnloadStaticVariable.flipContactRole())
        {
        
             oppId = Apexpages.currentPage().getParameters().get('id');
             conRoleIsNewBtnPress = false;
             conRoleOffsetsize = 0;
             conRoleBlockSize = (Integer)GRIDTabSetting__c.getValues('Contact Role').PageSize__c;
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
             
             //globalMap = GRIDOnloadStaticVariable.getGlobalMap();
             /*Schema.DescribeSObjectResult descbResultTask = globalMap.get('Task').getDescribe();
              conRoleFieldsetList = descbResultTask.FieldSets.getMap().get('TestFieldset').getFields();*/
              conRoleFieldsApiSet.add('ContactId');
              conRoleFieldsApiSet.add('Contact.Name');
              conRoleFieldsApiSet.add('IsPrimary');
              conRoleFieldsApiSet.add('OpportunityId');
              conRoleFieldsApiSet.add('Role');
              conRoleFieldsApiSet.add('Contact.Email');
              conRoleFieldsApiSet.add('Contact.MobilePhone');
              conRoleFieldsApiSet.add('Contact.Phone');
              conRoleAggregateQueryStr = buildContactRoleAggregateQuery(conRoleFieldsApiSet);
              conRoleLst = getContactRoleFromDB(oppId, conRoleBlockSize , conRoleOffsetsize , conRoleFieldsApiSet, conRoleSortExpression, conRoleSortDirection);
              //conRoleFieldsApiSet 
             
              conRoleFirstRun = true;
        }
    }
    
    // method to build dynamic query for SUM and COUNT
    public String buildContactRoleAggregateQuery(Set<String> pConRoleFieldsApiSet)
    {
        conRoleAggregateQueryStr = 'SELECT ';
        
        /*for(String fieldInstance :pConRoleFieldsApiSet)
        {
            if(fieldInstance.equalsIgnoreCase('Currency') 
               || fieldInstance.equalsIgnoreCase('Double'))
            {
                conRoleAggregateQueryStr += 'SUM('+fieldInstance+') '+fieldInstance+ ', ';
                conRoleFieldSumSet.add(fieldInstance);
                
            }
            conRoleFieldToSumMap.put(fieldInstance, 100);
        }*/
        
        conRoleAggregateQueryStr += 'COUNT(Id) conRoleCount FROM OpportunityContactRole Where  OpportunityId = \''+oppId+'\'';
        
        return conRoleAggregateQueryStr;
    }
    
    // method to query and get the sum of numeric fields
    public Map<String, Decimal> getContactRoleFieldSum(String pConRoleAggregateQueryStr)
    {
        List<SObject> conRoleSumQueryResult = new List<SObject>();
        conRoleSumQueryResult = Database.query(pConRoleAggregateQueryStr);
        /*
        for(String fieldName :conRoleFieldSumSet) 
        {
            if(conRoleSumQueryResult[0].get(fieldName) != null)
            {
                conRoleFieldToSumMap.put(fieldName, (Decimal)conRoleSumQueryResult[0].get(fieldName)); 
            }
        }*/
        conRoleRecordCount = (Integer)conRoleSumQueryResult[0].get('conRoleCount');
       
        return conRoleFieldToSumMap;
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
    public List<OpportunityContactRole> getContactRoleFromDB(ID pOppId, Integer pConRoleBlockSize, Integer pConRoleOffsetSize, Set<String> pConRoleFieldsApiSet,
                                                             String pconRoleSortExpression, String pconRoleSortDirection) 
    {
        conRoleLst.clear();
        String conRoleQueryStr = '';
        conRoleFieldsString = DEWUtility.getStringfromSet(pConRoleFieldsApiSet, null);
        conRoleQueryStr = 'Select ' +conRoleFieldsString + 
                          ' From OpportunityContactRole Where OpportunityID =:pOppId ORDER BY '+pconRoleSortExpression+' '+pconRoleSortDirection+' NULLS LAST LIMIT '
                           +pConRoleBlockSize+' Offset ' +pConRoleOffsetSize;
        //conRoleLst = database.query(conRoleQueryStr);

        return database.query(conRoleQueryStr);
    }
    
    // method to create new payables
    public void newContactRole() 
    {
        conRoleIsNewBtnPress = true;
        saveContactRoles();
        conRoleIsNewBtnPress = false;
        
        if(!conRoleSingleErrorOnSave)
        {
            // to add new record only on first page
            if(conRoleOffsetsize <> 0) 
            {
                conRoleOffsetsize = 0;
                beginningContactRoles();
            }
            
            OpportunityContactRole roleNew = new OpportunityContactRole(OpportunityId = oppId);
            
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
    
    // method to cave payable
    public void saveContactRoles()
    {
        String conRoleMsgStr = '';
        String contactMsgStr = '';
        conRoleSingleErrorOnSave = false;
        Boolean conRoleIsUpdated = false;
        List<OpportunityContactRole> conRoleListToUpdate = new List<OpportunityContactRole>();
        List<Contact> contactListToUpdate = new List<Contact>();
        
        Map<Integer, Integer> conRoleErrorToWraperIndexMap = new map<Integer, Integer>();
        Map<Integer, Integer> contactErrorToWraperIndexMap = new map<Integer, Integer>();
        
        List<OpportunityContactRole> conRoleTempLst = getContactRoleFromDB(oppId, conRoleBlockSize, conRoleOffsetsize, conRoleFieldsApiSet, conRoleSortExpression, conRoleSortDirection);
        conRoleFromDBMap = getContactRoleMapFromList(conRoleTempLst);
        for(ContactRoleWrapper conRoleWraperInstance :conRoleWrapperLst) 
        {
            OpportunityContactRole conRoleDBObj = conRoleFromDBMap.get(conRoleWraperInstance.conRole.Id);
            if(conRoleDBObj != null)
            {
                conRoleIsUpdated = false;
                for(String conRoleFieldInstance :conRoleFieldsApiSet)
                {
                    if(!conRoleFieldInstance.contains('__r.Name')) 
                    {
	                    if(conRoleFieldInstance.contains('Contact.'))
	                    {
	                        conRoleFieldInstance = conRoleFieldInstance.substringafter('Contact.');
	                        conRoleIsUpdated  = conRoleIsUpdated ||(conRoleWraperInstance.conRoleContact.get(conRoleFieldInstance) != conRoleDBObj.Contact.get(conRoleFieldInstance));
	                    }
	                    else
	                    {
	                        conRoleIsUpdated  = conRoleIsUpdated ||(conRoleWraperInstance.conRole.get(conRoleFieldInstance) != conRoleDBObj.get(conRoleFieldInstance));
	                    }
                    }
                }
            }
            else
            {
                if(!conRoleIsNewBtnPress)
                {
                    conRoleIsUpdated = true;
                }
            }
            if(conRoleIsUpdated)
            {
                conRoleListToUpdate.add(conRoleWraperInstance.conRole);
                contactListToUpdate.add(new Contact(Id = conRoleWraperInstance.conRole.ContactId,
                                                    Email = conRoleWraperInstance.conRoleContact.Email,
                                                    MobilePhone = conRoleWraperInstance.conRoleContact.MobilePhone,
                                                    Phone = conRoleWraperInstance.conRoleContact.Phone));
                conRoleErrorToWraperIndexMap.put(conRoleListToUpdate.size()-1, conRoleWraperInstance.conRoleIndex);
                contactErrorToWraperIndexMap.put(contactListToUpdate.size()-1, conRoleWraperInstance.conRoleIndex);
                
            }
            conRoleWraperInstance.conRoleEdit = false;
            
        }
        try
        {
            if((conRoleListToUpdate != null && conRoleListToUpdate.size() >0) 
               || (contactListToUpdate != null && contactListToUpdate.size() > 0))
            {
                List<Database.upsertResult> conRoleresults = Database.upsert(conRoleListToUpdate, false);
                for (Integer i =0; i < conRoleresults.size(); i++) 
                {
                    if (!conRoleresults[i].isSuccess())
                    {
                        for (Database.Error err : conRoleresults[i].getErrors())
                        {
                              //+1 is added for Display on VF page only  
                              conRoleMsgStr = conRoleMsgStr + 'Error:'+(conRoleErrorToWraperIndexMap.get(i)+1)+' : '+ err.getMessage() + '<br />'; 
                        }
                        if (!conRoleMsgStr.contains('insufficient access rights on object id'))
                        {
                            conRoleWrapperLst[conRoleErrorToWraperIndexMap.get(i)].conRoleEdit = true; 
                            //note on insuffivient privilage
                            conRoleSingleErrorOnSave = true;
                        }
                    }
                    /*else
                    {
                         conRoleWrapperLst[conRoleErrorToWraperIndexMap.get(i)].conRoleEdit = false;
                    }*/
                }
                
                List<Database.upsertResult> contactResults = Database.upsert(contactListToUpdate, false);
                for(Integer i = 0; i < contactResults.size(); i++) 
                {
                    if (!contactResults[i].isSuccess())
                    {
                        for (Database.Error err : contactResults[i].getErrors())
                        {
                              //+1 is added for Display on VF page only  
                              contactMsgStr = contactMsgStr + 'Error Record '+(contactErrorToWraperIndexMap.get(i)+1)+' : '+ err.getMessage() + '<br />'; 
                        }
                        if (!contactMsgStr.contains('insufficient access rights on object id'))
                        {
                            conRoleWrapperLst[contactErrorToWraperIndexMap.get(i)].conRoleEdit = true; 
                            //note on insuffivient privilage
                            conRoleSingleErrorOnSave = true;
                        }
                    }
                   /* else
                    {
                         conRoleWrapperLst[contactErrorToWraperIndexMap.get(i)].conRoleEdit = false;
                    }*/
                }
                if(conRoleSingleErrorOnSave == false && !conRoleIsNewBtnPress)
                {
                  conRoleLst = getContactRoleFromDB(oppId, conRoleBlockSize, conRoleOffsetsize, conRoleFieldsApiSet, conRoleSortExpression, conRoleSortDirection);
                  //conRoleFieldToSumMap = getContactRoleFieldSum(conRoleAggregateQueryStr);
                  conRoleFirstRun = true;
                }
                if(String.isNotBlank(conRoleMsgStr) || String.isNotBlank(contactMsgStr)) 
                {
                       ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info, conRoleMsgStr + ' ' +contactMsgStr));
                }
            }
        }
        catch (Exception e)
        {
             ApexPages.addMessage(new Apexpages.Message(ApexPages.Severity.Info, MCAExceptionHandlerUtility.getErrorMessage(e)));
             conRoleFirstRun = false;
        }
    }
    
    // method to edit all contactRoles
    public void editAllContactRoles()
    {
        conRoleFirstRun = false;
        for(Integer i=0; i< conRoleWrapperLst.size(); i++) 
        {
            conRoleWrapperLst[i].conRoleEdit = true;
        }
    }
    
    // method to refresh
    public void refreshContactRoles()
    {
        conRoleLst = getContactRoleFromDB(oppId, conRoleBlockSize, conRoleOffsetsize, conRoleFieldsApiSet, conRoleSortExpression, conRoleSortDirection);
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
            for (Integer i = 0; i < conRoleLst.size(); i++) 
            {
                conRoleWrapperLst.add(new ContactRoleWrapper(conRoleLst[i], i, false));
            }
            conRoleFirstRun = false;
        }
        
        conRoleFieldToSumMap = getContactRoleFieldSum(conRoleAggregateQueryStr);
        
        return conRoleWrapperLst;
    }
    
    //method for the first page of list to be displayed
    public void beginningContactRoles() 
    {
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