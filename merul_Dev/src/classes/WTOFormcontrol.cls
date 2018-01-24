public with sharing class WTOFormcontrol {
    
    Public List<innerWrapperClass> listWrapper {get;set;}
    Public String WTOFormid { get; set; }
    Public sObject sObjectName;
    Public boolean isObjectAllowed{get;set;}
    Public boolean isSave{get;set;}
    Public Map<String,Schema.SObjectType> schemaCall = Schema.getGlobalDescribe();
    Public String typeName{get;set;}
    
    public pagereference onload()
    {
        
        isSave=true;
        listWrapper=new list<innerWrapperClass>();
        String WTOFormid =  String.escapeSingleQuotes(System.currentPagereference().getParameters().get('WTOFormid'));
        List<WTOFormFields__c> listOfWtoFormFieldsRecords=[select id,objectapiname__c,Fieldsapiname__c,isActive__c from WTOFormFields__c where id=:WTOFormid limit 1];
        if(listOfWtoFormFieldsRecords!=null && listOfWtoFormFieldsRecords.size()!=0)
        {
            WTOFormFields__c wtoFormFieldsRecord=listOfWtoFormFieldsRecords[0];
            if(wtoFormFieldsRecord.isActive__c==false)
            {
                return Page.WTOInActivePage;
            }
            
            typeName=wtoFormFieldsRecord.objectapiname__c;
            Schema.SObjectType targetType = schemaCall.get(typeName);
            if(targetType!= null)
            {
                isObjectAllowed=targetType.getDescribe().isCreateable();
                if(isObjectAllowed)
                {
                    
                    List<String> listOfSelectedFields=(wtoFormFieldsRecord.Fieldsapiname__c).split(',');
                    
                    sObjectName = targetType.newSObject();
                    Schema.DescribeSObjectResult describeResult = schemaCall.get(typeName).getDescribe();
                    Map<String,Schema.SObjectField> fieldsMap = describeResult.fields.getMap();
                    for(String fieldApiName : listOfSelectedFields)
                    {
                        Schema.DescribeFieldResult describeFieldResult = (fieldsMap.get(fieldApiName)).getDescribe();
                        if(describeFieldResult.isAccessible() && describeFieldResult.getName()!= 'OwnerId'  && describeFieldResult.isCreateable()  /*&& describeFieldResult.isUpdateable()*/)
                        {
                            if (WTOUtility.checkForFieldType(describeFieldResult))
                            {
                                listWrapper.add(new innerWrapperClass(sObjectName,fieldApiName,describeFieldResult.getLabel(),describeFieldResult.isCreateable()));
                            }
                            
                        }
                    }
                    
                }
                else
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,WTOConstants.insufficientPrivilageErrorOnObject));
                    isSave=false;
                }
                
            }
             else
             {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,WTOConstants.objectSchemaAbsentMsg));
                    isSave=false;
            }
            
            
        }
        
        return null;
        
    }
    
    
    
    
    public PageReference save()
    {
       
       try
        {
            Schema.SObjectType targetType = schemaCall.get(typeName);
            
           if(targetType!= null)
          {
            isObjectAllowed=targetType.getDescribe().isCreateable();
            if(isObjectAllowed)
            {
                insert sObjectName;
                if(sObjectName.id!=null)
                {
                    
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.Confirm,WTOConstants.successfullRecordCreationMsg));
                    isSave=false;
                    
                }
            }
            else
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,WTOConstants.insufficientPrivilageErrorOnObject));
                isSave=false;
            }
            
          }
          else
          {
              ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.FATAL,WTOConstants.objectSchemaAbsentMsg));
              isSave=false;
          
          }  
        }
        catch(exception e)
        {
            ApexPages.addMessages(e);
           
            
        }
        return null;
    }
    
    
    public class innerWrapperClass{
        public sobject sObjectVar {get;set;}
        public String field{get;set;}
        public String label{get;set;}
        public boolean isCreateable{get;set;}
        
        
        public innerWrapperClass(sobject sObjectVar ,String  field,String label,boolean isCreateable)
        {
            this.sObjectVar = sObjectVar;
            this.field = field;
            this.label = label;
            this.isCreateable=isCreateable;
        }
    }
    
}