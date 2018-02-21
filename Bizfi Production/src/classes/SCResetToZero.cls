Public Class SCResetToZero
{
    
    public Sales_Rep_Report_Card__c resetToZero(Map<String,SCTimeframe_Metric__c> mapOfCustSetTimeFrame)
    {
    
        Set<String> fieldApiName = new Set<String>();
        Set<String> fieldApiHeader = new Set<String>();
        fieldApiHeader.add('Last_7_Days__c');
        fieldApiHeader.add('Last_Month__c');
        fieldApiHeader.add('MTD__c');
        fieldApiHeader.add('Yesterday__c');
        fieldApiHeader.add('YTD__c');
        
        
        
        for(String statusName:mapOfCustSetTimeFrame.keySet())
        {
            SCTimeframe_Metric__c scCustSetting = mapOfCustSetTimeFrame.get(statusName);
            for(String fielsApiVar:fieldApiHeader)
            {
                /*if(tempSC.get((String)scCustSetting.get(fielsApiVar)) == null)
                {
                            
                    tempSC.put((String)scCustSetting.get(fielsApiVar),0);
                            
                }*/
                
                fieldApiName.add((String)scCustSetting.get(fielsApiVar));
                
                
            }
         
        }
       
       
        Sales_Rep_Report_Card__c tempSC =new Sales_Rep_Report_Card__c();
        Map<String, Schema.SObjectField> allIntegrationFieldsMap = Schema.SObjectType.Sales_Rep_Report_Card__c.fields.getMap();
        Map<String, Schema.DescribeFieldResult> IntegrationFieldsToTrack = new Map<String, Schema.DescribeFieldResult>();
        
        
        for(Schema.SObjectField integrationField :allIntegrationFieldsMap.values())
        {
            Schema.DescribeFieldResult describeResult = integrationField.getDescribe();
            
            //choose which fields to track depending on the field type
            if (describeResult.getType() == Schema.DisplayType.Double)
            {
                    //don't add standard fields that are not necessary
                if (describeResult.getName() != 'CreatedDate' &&
                    describeResult.getName() != 'LastModifiedDate' &&
                    describeResult.getName() != 'SystemModstamp' &&
                    fieldApiName.contains(describeResult.getName()) &&
                    //do not add formula fields
                    !describeResult.isCalculated()
                    
                   )
                    {
                        if(tempSC.get(describeResult.getName()) == null)
                        {
                            
                            tempSC.put(describeResult.getName(),0);
                            
                        }
                    }
            }
            
        }
        
        
       
        
        
        return tempSC;
    
    }
    
    
    
    
    
    
    
}