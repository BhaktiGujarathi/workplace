public class DEWOpportunityService
{
    // method to combine 2 different fieldset for building a dynamic query
    public Static String buildQueryStringForOpportunity(Id pOppId,
                                                 List<Schema.FieldSetMember> masterOppFieldSetList,
                                                 List<Schema.FieldSetMember> dynamicOppFieldSetList,
                                                 List<Schema.FieldSetMember> summaryOppFieldSetList)
    {
        Set<String> fieldsSet = new Set<String>();
        for(Schema.FieldSetMember loopInstance :dynamicOppFieldSetList)
        {
            if(!fieldsSet.contains(loopInstance.getfieldPath()))
            {
                fieldsSet.add(loopInstance.getfieldPath());
            }
        }
        
        for(Schema.FieldSetMember loopInstance :masterOppFieldSetList )
        {
            if(!fieldsSet.contains(loopInstance.getfieldPath()))
            {
                fieldsSet.add(loopInstance.getfieldPath());
            }
        }
        for(Schema.FieldSetMember loopInstance :summaryOppFieldSetList)
        {
            if(!fieldsSet.contains(loopInstance.getfieldPath()))
            {
                fieldsSet.add(loopInstance.getfieldPath());
            }
        }
        
        String fieldsString = DEWUtility.getStringfromSet(fieldsSet, null);
        String queryStr = 'Select ' +fieldsString+ 'FROM Opportunity WHERE Id =\''+pOppId+'\'';
        
        return queryStr;
    }
    
    public static Opportunity save(Opportunity objOpp, List<Schema.FieldSetMember> dynamicOppFieldSetList, string wizardType, String DEAL_SCREEN, Id OppId, Map<String, CreateContractController.OppFieldWrapper> mOppFieldWrapper, CreateContractController.OppFieldWrapper oppFieldWrap)
    {
        //try{
            // Saving Main Opportunity field
            list<Opportunity> oppList1 = new  list<Opportunity>();
            // objOpp.AccountId = AccountId;
            oppList1.add(objOpp);
            oppList1 = DEWUtility.checkSaveAccessForSObject(oppList1,userinfo.getUserId());
            if(oppList1.size() > 0 )
            {
                DEWUtility.upsertForSObject(oppList1);
            }
            
            // Saving Related object field of opportunity.
            List<Sobject> lOppRelatedSObjectToUpdate = new List<Sobject>();
            Set<Sobject> sOppRelatedSObject = new Set<Sobject>();
            
            for (FieldSetMember memberInsatnce : dynamicOppFieldSetList)
            {
                CreateContractController.ReferenceObjectDetail refObjDetail = DEWUtility.getReferenceObjectDetailOfField(objOpp,memberInsatnce.getFieldPath());
                if(refObjDetail.recSObject != null)
                {
                    sOppRelatedSObject.add(refObjDetail.recSObject);
                }
            }
            //Collection of all the related object to update with opportunity.
            lOppRelatedSObjectToUpdate.addAll(sOppRelatedSObject);
            if(lOppRelatedSObjectToUpdate.size() > 0)
            {
                DEWUtility.upsertForSObject(lOppRelatedSObjectToUpdate);
            }
            
            //Refreshing opportunity from DB.
            objOpp = new CreateContractController().refereshOpportunityByID(OppId);
           // display opportunity based on oppFieldWrapper
           /* mOppFieldWrapper = CreateContractController.refereshDisplayOfOpportuntiyWrapper(dynamicOppFieldSetList,
                                                                    objOpp,
                                                                    oppFieldWrap,
                                                                    mOppFieldWrapper); */
                                                                    
            return objOpp;
                                                                  
       /* }
        catch(Exception e)
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Error, MCAExceptionHandlerUtility.getErrorMessage(e)));
            wizardType = DEAL_SCREEN;
        }*/
    }
}