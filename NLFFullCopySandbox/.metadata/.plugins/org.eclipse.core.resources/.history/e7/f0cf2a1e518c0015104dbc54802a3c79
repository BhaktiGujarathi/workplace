Public Class SCResetToZero
{
    
    public Sales_Rep_Report_Card__c resetToZero()
    {
    
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