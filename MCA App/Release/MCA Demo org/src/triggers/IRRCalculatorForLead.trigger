/*
Author: Priyanshi Agrawal
Date: Feb, 2014
Description: Calculates XIRR using input from lead fields and stores the calculated xirr in a lead field
*/
trigger IRRCalculatorForLead on Lead (after insert, after update) {
Set <Id> leadIds = new Set<Id>();
String invalidFieldNames;  //comma separated list of invalid field names in custom settings
Boolean invalidFields = false; //whether any fields names are wrong in the custom settings
Set<String> leadFieldNames = new Set<String>();  //will store names of all the fields on lead
List<Lead> leadList = new List<Lead>();
XIRR_fieldNames__c leadFields = new XIRR_fieldNames__c();
Manage_triggers__c manageTrigger = new Manage_Triggers__c();
List<Manage_triggers__c> manageTriggersList = [Select lead_trigger_for_Xirr__c from manage_triggers__c where Name= 'Default'];
List<XIRR_fieldNames__c> leadFieldsList = [select month_field_apiName__c, funding_amount_field_apiName__c, process_fee_field_apiName__c, commission_amount_field_apiName__c, payback_amount_field_apiName__c, calculated_irr_field_apiName__c from XIRR_fieldNames__c where Name= 'Lead'];
if (leadFieldsList.size()>0 && manageTriggersList.size()>0)
{
    leadFields= leadFieldsList[0];
    manageTrigger = manageTriggersList[0];
    // check field names should not be null
    if (manageTrigger.lead_trigger_for_xirr__c == true && leadFields.month_field_apiName__c != null && leadFields.funding_amount_field_apiName__c!= null && leadFields.payback_amount_field_apiName__c != null && leadFields.calculated_irr_field_apiName__c != null)
    {
        //create a set of field names
        List<Schema.SObjectField> fieldMapValues = schema.SObjectType.Lead.fields.getMap().values();  //List of all fields on Lead
        for(Schema.SObjectField s : fieldMapValues)
        {
            leadFieldNames.add(s.getDescribe().getName());
        }
        /* Check whether field names are valid */
        //check for mandatory fields
        if (!leadFieldNames.contains(leadFields.month_field_apiName__c)){
            invalidFields= true; invalidFieldNames = leadFields.month_field_apiName__c; }
        if (!leadFieldNames.contains(leadFields.funding_amount_field_apiName__c)) {
            invalidFields= true; invalidFieldNames = invalidFieldNames + ', ' + leadFields.funding_amount_field_apiName__c;}
        if (!leadFieldNames.contains(leadFields.payback_amount_field_apiName__c)){
            invalidFields= true; invalidFieldNames = invalidFieldNames + ', ' + leadFields.payback_amount_field_apiName__c;}
        if (!leadFieldNames.contains(leadFields.calculated_irr_field_apiName__c)) {
            invalidFields= true; invalidFieldNames = invalidFieldNames + ', ' + leadFields.calculated_irr_field_apiName__c;}
        // check for process_fee_field_apiName__c
        if (leadFields.process_fee_field_apiName__c != null && !leadFieldNames.contains(leadFields.process_fee_field_apiName__c)) {
            invalidFields = true; invalidFieldNames = invalidFieldNames + ', ' + leadFields.process_fee_field_apiName__c;}
        // check for commission_amount_field_apiName__c
        if (leadFields.commission_amount_field_apiName__c != null && !leadFieldNames.contains(leadFields.commission_amount_field_apiName__c)) {
            invalidFields = true; invalidFieldNames = invalidFieldNames + ', ' + leadFields.commission_amount_field_apiName__c;}
        
        for (Lead leadObj: Trigger.new)
        {
            if (invalidFields == true)
            {
                leadObj.addError('Please check the API Names of the fields entered in the Custom Settings. The following fields do not exist: '+ invalidFieldNames);
                continue;
            }
            if (trigger.isInsert)
                leadIds.add(leadObj.id);
            else if (trigger.isUpdate)
            {
                //compare previous values
                if ((Trigger.oldmap.get(leadObj.id).get(leadFields.month_field_apiName__c) != leadObj.get(leadFields.month_field_apiName__c)) || 
                (Trigger.oldmap.get(leadObj.id).get(leadFields.funding_amount_field_apiName__c) != leadObj.get(leadFields.funding_amount_field_apiName__c)) || 
                (leadFields.process_fee_field_apiName__c !=null && (Trigger.oldmap.get(leadObj.id).get(leadFields.process_fee_field_apiName__c) != leadObj.get(leadFields.process_fee_field_apiName__c))) ||
                (leadFields.commission_amount_field_apiName__c != null && (Trigger.oldmap.get(leadObj.id).get(leadFields.commission_amount_field_apiName__c) != leadObj.get(leadFields.commission_amount_field_apiName__c))) ||
                (Trigger.oldmap.get(leadObj.id).get(leadFields.payback_amount_field_apiName__c) != leadObj.get(leadFields.payback_amount_field_apiName__c)))
                    leadIds.add(leadObj.id);
            }
        }    
        //lead_fields_XIRR__c leadFields = [select month_field_apiName__c, funding_amount_field_apiName__c, process_fee_field_apiName__c, commission_amount_field_apiName__c, payback_amount_field_apiName__c, calculated_irr_field_apiName__c from lead_fields_XIRR__c where Name= 'Lead' limit 1];
        if (leadIds.size()>0)
        {
            if (leadFields.commission_amount_field_apiName__c != null && leadFields.process_fee_field_apiName__c != null)
                leadList = Database.Query('Select id, name, ' + leadFields.month_field_apiName__c + ', ' + leadFields.funding_amount_field_apiName__c+', ' + leadFields.process_fee_field_apiName__c + ', ' + leadFields.commission_amount_field_apiName__c + ', ' + leadFields.payback_amount_field_apiName__c + ' from lead where id in : leadIds');
            else if (leadFields.commission_amount_field_apiName__c != null)  //process_fee_field is null
                leadList = Database.Query('Select id, name, ' + leadFields.month_field_apiName__c + ', ' + leadFields.funding_amount_field_apiName__c+', ' + leadFields.commission_amount_field_apiName__c + ', ' + leadFields.payback_amount_field_apiName__c + ' from lead where id in : leadIds');
            else if (leadFields.process_fee_field_apiName__c != null) //commission_amount_field is null
                leadList = Database.Query('Select id, name, ' + leadFields.month_field_apiName__c + ', ' + leadFields.funding_amount_field_apiName__c+', ' + leadFields.process_fee_field_apiName__c + ', ' + leadFields.payback_amount_field_apiName__c + ' from lead where id in : leadIds');
            else    
                leadList = Database.Query('Select id, name, ' + leadFields.month_field_apiName__c + ', ' + leadFields.funding_amount_field_apiName__c+', ' + leadFields.payback_amount_field_apiName__c + ' from lead where id in : leadIds');
            
            if (leadList.size() > 0)
            {
                for (lead leadObj: leadList)
                {    
                    try
                    {
                     XIRR_MCA2 obj;
                     //to avoid divide by zero error
                     if (Double.valueof(leadObj.get(leadFields.month_field_apiName__c)) ==0)
                     {
                         Lead actualRecord = Trigger.newMap.get(leadObj.Id);
                         actualRecord.addError('Value for Term (Months) must be greater than zero');
                         continue;   
                     }
                     if (Double.valueof(leadObj.get(leadFields.month_field_apiName__c)) >500)
                     {
                         Lead actualRecord = Trigger.newMap.get(leadObj.Id);
                         actualRecord.addError('Value for Term (Months) cannot be greater than 500');
                         continue;
                     }
                     if (leadFields.commission_amount_field_apiName__c != null && leadFields.process_fee_field_apiName__c != null)
                     {
                         if ( Double.valueof(leadObj.get(leadFields.month_field_apiName__c)) <0 || Double.valueof(leadObj.get(leadFields.funding_amount_field_apiName__c)) <0 || Double.valueof(leadObj.get(leadFields.process_fee_field_apiName__c)) <0 || Double.valueof(leadObj.get(leadFields.commission_amount_field_apiName__c))<0 || Double.valueof(leadObj.get(leadFields.payback_amount_field_apiName__c))<0 )
                         {
                             Lead actualRecord = Trigger.newMap.get(leadObj.Id);
                             actualRecord.addError('Input values cannot be less than zero for XIRR Calculation');
                             continue;
                         }                     
                         obj = new XIRR_MCA2(Double.valueof(leadObj.get(leadFields.month_field_apiName__c)), Double.valueof(leadObj.get(leadFields.funding_amount_field_apiName__c)), Double.valueof(leadObj.get(leadFields.process_fee_field_apiName__c)), Double.valueof(leadObj.get(leadFields.commission_amount_field_apiName__c)), Double.valueof(leadObj.get(leadFields.payback_amount_field_apiName__c)));                         
                     }
                     else if (leadFields.commission_amount_field_apiName__c != null)
                     {
                         if ( Double.valueof(leadObj.get(leadFields.month_field_apiName__c)) <0 || Double.valueof(leadObj.get(leadFields.funding_amount_field_apiName__c)) <0 || Double.valueof(leadObj.get(leadFields.commission_amount_field_apiName__c))<0 || Double.valueof(leadObj.get(leadFields.payback_amount_field_apiName__c))<0 )
                         {
                             Lead actualRecord = Trigger.newMap.get(leadObj.Id);
                             actualRecord.addError('Input values cannot be less than zero for XIRR Calculation');
                             continue;
                         }                      
                         obj = new XIRR_MCA2(Double.valueof(leadObj.get(leadFields.month_field_apiName__c)), Double.valueof(leadObj.get(leadFields.funding_amount_field_apiName__c)), 0, Double.valueof(leadObj.get(leadFields.commission_amount_field_apiName__c)), Double.valueof(leadObj.get(leadFields.payback_amount_field_apiName__c)));
                     }
                     else if (leadFields.process_fee_field_apiName__c != null)
                     {
                         if ( Double.valueof(leadObj.get(leadFields.month_field_apiName__c)) <0 || Double.valueof(leadObj.get(leadFields.funding_amount_field_apiName__c)) <0 || Double.valueof(leadObj.get(leadFields.process_fee_field_apiName__c)) <0 || Double.valueof(leadObj.get(leadFields.payback_amount_field_apiName__c))<0 )
                         {
                             Lead actualRecord = Trigger.newMap.get(leadObj.Id);
                             actualRecord.addError('Input values cannot be less than zero for XIRR Calculation');
                             continue;
                         }
                         obj = new XIRR_MCA2(Double.valueof(leadObj.get(leadFields.month_field_apiName__c)), Double.valueof(leadObj.get(leadFields.funding_amount_field_apiName__c)), Double.valueof(leadObj.get(leadFields.process_fee_field_apiName__c)), 0 , Double.valueof(leadObj.get(leadFields.payback_amount_field_apiName__c)));
                     }
                     else
                     {
                         if ( Double.valueof(leadObj.get(leadFields.month_field_apiName__c)) <0 || Double.valueof(leadObj.get(leadFields.funding_amount_field_apiName__c)) <0 || Double.valueof(leadObj.get(leadFields.payback_amount_field_apiName__c))<0 )
                         {
                             Lead actualRecord = Trigger.newMap.get(leadObj.Id);
                             actualRecord.addError('Input values cannot be less than zero for XIRR Calculation');
                             continue;
                         }                     
                         obj = new XIRR_MCA2(Double.valueof(leadObj.get(leadFields.month_field_apiName__c)), Double.valueof(leadObj.get(leadFields.funding_amount_field_apiName__c)), 0, 0 , Double.valueof(leadObj.get(leadFields.payback_amount_field_apiName__c)));                         
                     }
                     obj.cal();
                     leadObj.put(leadFields.calculated_irr_field_apiName__c , obj.XIRR);
                    }
                    catch (TypeException te)
                    {
                        Lead actualRecord = Trigger.newMap.get(leadObj.Id);
                        actualRecord.addError(te);
                    } 
                }
                upsert leadList;    
            } //if leadList.size()>0
        } //if leadIds.size()>0
    } //end if field names not null
} //if FieldList.size()>0
} //end trigger