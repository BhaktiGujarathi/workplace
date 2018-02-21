/*
Author: Priyanshi Agrawal
Date: Feb, 2014
Description: Calculates XIRR using input from opportunity fields and stores the calculated xirr in an opportunity field
*/
trigger IRRCalculatorForOpportunity on Opportunity (after insert, after update) {
Set <Id> oppIds = new Set<Id>();
String invalidFieldNames;  //comma separated list of invalid field names in custom settings
Boolean invalidFields = false; //whether any fields names are wrong in the custom settings
Set<String> oppFieldNames = new Set<String>();  //will store names of all the fields on opportunity
List<Opportunity> oppList = new List<Opportunity>();
XIRR_fieldNames__c oppFields = new XIRR_fieldNames__c();
Manage_triggers__c manageTrigger = new Manage_triggers__c();
List<Manage_triggers__c> manageTriggersList = [Select opp_trigger_for_Xirr__c from manage_triggers__c where Name= 'Default'];
List<XIRR_fieldNames__c> oppFieldsList = [select month_field_apiName__c, funding_amount_field_apiName__c, process_fee_field_apiName__c, commission_amount_field_apiName__c, payback_amount_field_apiName__c, calculated_irr_field_apiName__c from XIRR_fieldNames__c where Name= 'Opportunity'];
if (oppFieldsList.size()>0 && manageTriggersList.size()>0)
{
    oppFields= oppFieldsList[0];
    manageTrigger = manageTriggersList[0];
    // check field names should not be null
    if (manageTrigger.opp_trigger_for_xirr__c == true && oppFields.month_field_apiName__c != null && oppFields.funding_amount_field_apiName__c!= null && oppFields.payback_amount_field_apiName__c != null && oppFields.calculated_irr_field_apiName__c != null)
    {
        //create a set of field names
        List<Schema.SObjectField> fieldMapValues = schema.SObjectType.Opportunity.fields.getMap().values();  //List of all fields on Opportunity
        for(Schema.SObjectField s : fieldMapValues)
        {
            oppFieldNames.add(s.getDescribe().getName());
            //System.debug(s.getDescribe().getName());
        }
        /* Check whether field names are valid */
        //check for mandatory fields
        if (!oppFieldNames.contains(oppFields.month_field_apiName__c)){
            invalidFields= true; invalidFieldNames = oppFields.month_field_apiName__c; }
        if (!oppFieldNames.contains(oppFields.funding_amount_field_apiName__c)) {
            invalidFields= true; invalidFieldNames = invalidFieldNames + ', ' + oppFields.funding_amount_field_apiName__c;}
        if (!oppFieldNames.contains(oppFields.payback_amount_field_apiName__c)){
            invalidFields= true; invalidFieldNames = invalidFieldNames + ', ' + oppFields.payback_amount_field_apiName__c;}
        if (!oppFieldNames.contains(oppFields.calculated_irr_field_apiName__c)) {
            invalidFields= true; invalidFieldNames = invalidFieldNames + ', ' + oppFields.calculated_irr_field_apiName__c;}
        // check for process_fee_field_apiName__c
        if (oppFields.process_fee_field_apiName__c != null && !oppFieldNames.contains(oppFields.process_fee_field_apiName__c)) {
            invalidFields = true; invalidFieldNames = invalidFieldNames + ', ' + oppFields.process_fee_field_apiName__c;}
        // check for commission_amount_field_apiName__c
        if (oppFields.commission_amount_field_apiName__c != null && !oppFieldNames.contains(oppFields.commission_amount_field_apiName__c)) {
            invalidFields = true; invalidFieldNames = invalidFieldNames + ', ' + oppFields.commission_amount_field_apiName__c;}
        for (Opportunity opp: Trigger.new)
        {
        
            if (invalidFields == true)
            {
                opp.addError('Please check the API Names of the fields entered in the Custom Settings. The following fields do not exist: '+ invalidFieldNames);
                continue;
            }
            if (trigger.isInsert)
                oppIds.add(opp.id);
            else if (trigger.isUpdate)
            {
                //compare previous values
                if ((Trigger.oldmap.get(opp.id).get(oppFields.month_field_apiName__c) != opp.get(oppFields.month_field_apiName__c)) || 
                (Trigger.oldmap.get(opp.id).get(oppFields.funding_amount_field_apiName__c) != opp.get(oppFields.funding_amount_field_apiName__c)) || 
                (oppFields.process_fee_field_apiName__c!= null && (Trigger.oldmap.get(opp.id).get(oppFields.process_fee_field_apiName__c) != opp.get(oppFields.process_fee_field_apiName__c))) ||
                (oppFields.commission_amount_field_apiName__c!=null && (Trigger.oldmap.get(opp.id).get(oppFields.commission_amount_field_apiName__c) != opp.get(oppFields.commission_amount_field_apiName__c))) ||
                (Trigger.oldmap.get(opp.id).get(oppFields.payback_amount_field_apiName__c) != opp.get(oppFields.payback_amount_field_apiName__c)))
                    oppIds.add(opp.id);
            }
        }    
        //Opp_fields_XIRR__c oppFields = [select month_field_apiName__c, funding_amount_field_apiName__c, process_fee_field_apiName__c, commission_amount_field_apiName__c, payback_amount_field_apiName__c, calculated_irr_field_apiName__c from Opp_fields_XIRR__c where Name= 'Opportunity' limit 1];
        if (oppIds.size()>0)
        {
            if (oppFields.commission_amount_field_apiName__c != null && oppFields.process_fee_field_apiName__c != null)
                oppList = Database.Query('Select id, ' + oppFields.month_field_apiName__c + ', ' + oppFields.funding_amount_field_apiName__c+', ' + oppFields.process_fee_field_apiName__c + ', ' + oppFields.commission_amount_field_apiName__c + ', ' + oppFields.payback_amount_field_apiName__c + ' from Opportunity where id in : oppIds');
            else if (oppFields.commission_amount_field_apiName__c != null)  //process_fee_field is null
                oppList = Database.Query('Select id, ' + oppFields.month_field_apiName__c + ', ' + oppFields.funding_amount_field_apiName__c+', ' + oppFields.commission_amount_field_apiName__c + ', ' + oppFields.payback_amount_field_apiName__c + ' from Opportunity where id in : oppIds');
            else if (oppFields.process_fee_field_apiName__c != null) //commission_amount_field is null          
                oppList = Database.Query('Select id, ' + oppFields.month_field_apiName__c + ', ' + oppFields.funding_amount_field_apiName__c+', ' + oppFields.process_fee_field_apiName__c + ', ' +  oppFields.payback_amount_field_apiName__c + ' from Opportunity where id in : oppIds');            
            else //both are null
                oppList = Database.Query('Select id, ' + oppFields.month_field_apiName__c + ', ' + oppFields.funding_amount_field_apiName__c+ ', ' + oppFields.payback_amount_field_apiName__c + ' from Opportunity where id in : oppIds');                
            if (oppList.size() > 0)
            {
                for (Opportunity opp: oppList)
                {
                    try
                    {                     
                     XIRR_MCA2 obj;
                     //to avoid divide by zero error
                     if (Double.valueof(opp.get(oppFields.month_field_apiName__c)) ==0)
                     {
                         Opportunity actualRecord = Trigger.newMap.get(opp.Id);
                         actualRecord.addError('Value for Term (Months) must be greater than zero');
                         continue;   
                     }
                     if (Double.valueof(opp.get(oppFields.month_field_apiName__c)) >500)
                     {
                         Opportunity actualRecord = Trigger.newMap.get(opp.Id);
                         actualRecord.addError('Value for Term (Months) cannot be greater than 500');
                         continue;
                     }
                     if (oppFields.commission_amount_field_apiName__c != null && oppFields.process_fee_field_apiName__c != null)
                     {
                         if ( Double.valueof(opp.get(oppFields.month_field_apiName__c)) <0 || Double.valueof(opp.get(oppFields.funding_amount_field_apiName__c)) <0 || Double.valueof(opp.get(oppFields.process_fee_field_apiName__c)) <0 || Double.valueof(opp.get(oppFields.commission_amount_field_apiName__c))<0 || Double.valueof(opp.get(oppFields.payback_amount_field_apiName__c))<0 )
                         {
                             Opportunity actualRecord = Trigger.newMap.get(opp.Id);
                             actualRecord.addError('Input values cannot be less than zero for XIRR Calculation');
                             continue;
                         }
                         obj = new XIRR_MCA2(Double.valueof(opp.get(oppFields.month_field_apiName__c)), Double.valueof(opp.get(oppFields.funding_amount_field_apiName__c)), Double.valueof(opp.get(oppFields.process_fee_field_apiName__c)), Double.valueof(opp.get(oppFields.commission_amount_field_apiName__c)), Double.valueof(opp.get(oppFields.payback_amount_field_apiName__c)));
                     }
                     else if (oppFields.commission_amount_field_apiName__c != null)  //process_fee_field is null                     
                     {
                         if ( Double.valueof(opp.get(oppFields.month_field_apiName__c)) <0 || Double.valueof(opp.get(oppFields.funding_amount_field_apiName__c)) <0 || Double.valueof(opp.get(oppFields.commission_amount_field_apiName__c))<0 || Double.valueof(opp.get(oppFields.payback_amount_field_apiName__c))<0 )
                         {
                             Opportunity actualRecord = Trigger.newMap.get(opp.Id);
                             actualRecord.addError('Input values cannot be less than zero for XIRR Calculation');
                             continue;
                         }
                         
                         obj = new XIRR_MCA2(Double.valueof(opp.get(oppFields.month_field_apiName__c)), Double.valueof(opp.get(oppFields.funding_amount_field_apiName__c)), 0, Double.valueof(opp.get(oppFields.commission_amount_field_apiName__c)), Double.valueof(opp.get(oppFields.payback_amount_field_apiName__c)));                    
                     }
                     else if (oppFields.process_fee_field_apiName__c != null) //commission_amount_field is null  
                     { 
                         if ( Double.valueof(opp.get(oppFields.month_field_apiName__c)) <0 || Double.valueof(opp.get(oppFields.funding_amount_field_apiName__c)) <0 || Double.valueof(opp.get(oppFields.process_fee_field_apiName__c)) <0 || Double.valueof(opp.get(oppFields.payback_amount_field_apiName__c))<0 )
                         {
                             Opportunity actualRecord = Trigger.newMap.get(opp.Id);
                             actualRecord.addError('Input values cannot be less than zero for XIRR Calculation');
                             continue;
                         }                      
                         obj = new XIRR_MCA2(Double.valueof(opp.get(oppFields.month_field_apiName__c)), Double.valueof(opp.get(oppFields.funding_amount_field_apiName__c)), Double.valueof(opp.get(oppFields.process_fee_field_apiName__c)), 0, Double.valueof(opp.get(oppFields.payback_amount_field_apiName__c)));
                     }
                     else
                     {
                         if ( Double.valueof(opp.get(oppFields.month_field_apiName__c)) <0 || Double.valueof(opp.get(oppFields.funding_amount_field_apiName__c)) <0 || Double.valueof(opp.get(oppFields.payback_amount_field_apiName__c))<0 )
                         {
                             Opportunity actualRecord = Trigger.newMap.get(opp.Id);
                             actualRecord.addError('Input values cannot be less than zero for XIRR Calculation');
                             continue;
                         }                     
                         obj = new XIRR_MCA2(Double.valueof(opp.get(oppFields.month_field_apiName__c)), Double.valueof(opp.get(oppFields.funding_amount_field_apiName__c)), 0, 0, Double.valueof(opp.get(oppFields.payback_amount_field_apiName__c)));                         
                     }
                     obj.cal();
                     opp.put(oppFields.calculated_irr_field_apiName__c , obj.XIRR);
                    }
                    catch (TypeException te)
                    {
                        Opportunity actualRecord = Trigger.newMap.get(opp.Id);
                        actualRecord.addError(te);
                    }                   
                }
                //BooleanForTrigger.calculateIrr = false;
                upsert oppList;    
            } //if oppList.size()>0
        } //if oppIds.size()>0
    } //end if field names not null
} //if FieldList.size()>0
} //end trigger