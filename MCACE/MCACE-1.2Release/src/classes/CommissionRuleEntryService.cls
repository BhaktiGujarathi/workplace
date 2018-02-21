public class CommissionRuleEntryService {
    
    public CommissionRuleEntryService() {}
    
    // method to validate the commission rule entry 
    public void validateRuleEntry(List<MCACE__Commission_Rule_Entry__c> pRuleEntryListNew) {
        
        MCACEFieldConvertorAndComparator convertorAndComparatorObj = new MCACEFieldConvertorAndComparator();
        MCACEFieldConvertorAndComparator.DatatypeAndValidWrapper wrapperObj = new MCACEFieldConvertorAndComparator.DatatypeAndValidWrapper();
        
        // iterate over the list of rule entries
        for(MCACE__Commission_Rule_Entry__c entryObj :pRuleEntryListNew) {
            wrapperObj  = MCACEFieldConvertorAndComparator.getDatatypeAndValidate(entryObj);
            if(!wrapperObj.isValid) {
                entryObj.addError(wrapperObj.errorString);
            } 
        }
    }
    
   /* public void updateComissionValue(List<MCACE__Commission_Rule_Entry__c> listNewCommissionRuleEntry) {
        String datatypeFieldApiString ;
        Schema.Sobjecttype objects;
        
        for(MCACE__Commission_Rule_Entry__c objCommission :listNewCommissionRuleEntry) 
        {
            
            Map<String,Schema.SObjectType> globalDescribeForObject = Schema.getGlobalDescribe();
            
            String stringFields = string.ValueOf(objCommission.get('MCACE__Field_API__c'));
            String stringObjects = String.valueOf(objCommission.get('MCACE__Object_API__c'));
            String stringValue = string.ValueOf(objCommission.get('MCACE__Text__c'));
            
            if(stringObjects != null ) 
            {
                objects = Schema.getGlobalDescribe().get(stringObjects);
                
               
            
                if(stringFields != Null && stringValue != null) 
                {
                    Map<String, Schema.SObjectField> fieldMap = objects.getDescribe().fields.getMap();
                    if(fieldMap.containsKey(stringFields))
                    {
                            datatypeFieldApiString = String.valueOf(fieldMap.get(stringFields).getDescribe().getType());
                            if(datatypeFieldApiString != null)
                            {
                                    
                                    if( datatypeFieldApiString.equalsIgnoreCase(String.ValueOf(Schema.DisplayType.REFERENCE)) )
                                    {
                                        objCommission.addError('Enter Only ' +datatypeFieldApiString +' Value');
                                    }
                                    else if( datatypeFieldApiString.equalsIgnoreCase(String.ValueOf(Schema.DisplayType.Boolean)) )
                                    {
                                        objCommission.addError('Enter Only ' +datatypeFieldApiString +' Value');
                                    
                                    }
                                    else if( datatypeFieldApiString.equalsIgnoreCase(String.ValueOf(Schema.DisplayType.Integer)) )
                                    {
                                        objCommission.addError('Enter Only ' +datatypeFieldApiString +' Value');
                                    }
                                    else if( datatypeFieldApiString.equalsIgnoreCase(String.ValueOf(Schema.DisplayType.string)) )
                                    {
                                        objCommission.addError('Enter Only ' +datatypeFieldApiString +' Value');
                                    }
                                    else if( datatypeFieldApiString.equalsIgnoreCase(String.ValueOf(Schema.DisplayType.Picklist)) )
                                    {
                                        objCommission.addError('Enter Only ' +datatypeFieldApiString +' Value');
                                    }
                                    else if( datatypeFieldApiString.equalsIgnoreCase(String.ValueOf(Schema.DisplayType.Phone)) )
                                    {
                                        objCommission.addError('Enter Only ' +datatypeFieldApiString +' Value');
                                    }
                                    else if( datatypeFieldApiString.equalsIgnoreCase(String.ValueOf(Schema.DisplayType.Email)) )
                                    {
                                        objCommission.addError('Enter Only ' +datatypeFieldApiString +' Value');
                                    }
                                    else if( datatypeFieldApiString.equalsIgnoreCase(String.ValueOf(Schema.DisplayType.URL)) )
                                    {
                                        objCommission.addError('Enter Only ' +datatypeFieldApiString +' Value');
                                    }
                                   
                                    else if( datatypeFieldApiString.equalsIgnoreCase(String.ValueOf(Schema.DisplayType.Currency)) )
                                    {
                                        objCommission.addError('Enter Only ' +datatypeFieldApiString +' Value');
                                    }
                                    else if( datatypeFieldApiString.equalsIgnoreCase(String.ValueOf(Schema.DisplayType.Percent)) )
                                    {
                                        objCommission.addError('Enter Only ' +datatypeFieldApiString +' Value');
                                    }
                                    else if( datatypeFieldApiString.equalsIgnoreCase(String.ValueOf(Schema.DisplayType.Date)) )
                                    {
                                        objCommission.addError('Enter Only ' +datatypeFieldApiString +' Value');
                                    }
                                    else if( datatypeFieldApiString.equalsIgnoreCase(String.ValueOf(Schema.DisplayType.DateTime)) )
                                    {
                                        objCommission.addError('Enter Only ' +datatypeFieldApiString +' Value');
                                    }
                                    //else if( datatypeFieldApiString.equalsIgnoreCase(String.ValueOf(Schema.DisplayType.Formula)) )
                                    //{
                                        objCommission.addError('Enter Only ' +datatypeFieldApiString +' Value');
                                    //}
                            
                            }
                    
                    
                    }
                    else
                    {
                        objCommission.addError('Please enter a valid field api name.');
                    }
                   
                    
                }
                else
                {
                
                   objCommission.addError('Please enter field api name OR value to be compare.');
                
                }
            
           
            }
            else
            {
                
                   objCommission.addError('Please select object from picklist.');
                
            }
            
            
            
            
        }
    }*/
}