public class WTOHtmlFormController {
    public Map<String,String> paramMap=new Map<String,String>();
    
    Public Map<String,Schema.SObjectType> schemaCall = Schema.getGlobalDescribe();
    Public Map<String,Schema.SObjectField> fieldsMap=new Map<String,Schema.SObjectField>();
    public String objectName;
    public String returnURL;  
    public sObject dynamicObject;
    public Schema.SObjectType dynamicObjectType;
    public boolean isObjectAllowed;
    public PageReference returnPage;
    //public Map<String,Schema.SObjectField> fieldsMap;
    public Pagereference onload()
    {
        
        try
        {
            
           
            paramMap=ApexPages.currentPage().getParameters();
            
            system.debug('$$$$$$$$$$ Parameters '+paramMap);
            paramMap.remove(WTOConstants.submitLabel);      //hardcodding will be removed                                   // changed by godson 
            objectName=paramMap.remove(WTOConstants.wtoObjectListingPageUrlParamKey1);    //hardcodding will be removed     // changed by godson object name
            returnPage =new PageReference(paramMap.remove(WTOConstants.returnUrlLabel));                                   //Changed by godson
            dynamicObjectType = schemaCall.get(objectName);
            if(dynamicObjectType != null)
            {
                Schema.DescribeSObjectResult describeResult = dynamicObjectType.getDescribe();
                isObjectAllowed = describeResult.isCreateable();
                if(isObjectAllowed)
                {
                    
                    dynamicObject = dynamicObjectType.newSObject();
                    fieldsMap = describeResult.fields.getMap();
                    
                    system.debug('######## fieldmap '+fieldsMap);
                    for(String fieldApi:paramMap.keySet())
                    {
                      
                      if(fieldsMap.containsKey(fieldApi) )
                      {
                                Schema.DescribeFieldResult describeFieldResult = (fieldsMap.get(fieldApi)).getDescribe();
                                String fieldApiValue = paramMap.get(fieldApi);
                                boolean isfieldApiValueBlank = String.isEmpty(fieldApiValue) && String.isBlank(fieldApiValue);
                            
                          
                            
                           if(!String.isEmpty(fieldApiValue) && !String.isBlank(fieldApiValue))
                           {     
                                if(describeFieldResult.getType() == Schema.DisplayType.Boolean)
                                {
                                     system.debug('$$$$ its boolean'+fieldApiValue);
                                     
                                    if(fieldApiValue.equalsIgnoreCase('1'))
                                    {
                                        dynamicObject.put(fieldApi, true);
                                    } 
                                    //dynamicObject.put(fieldApi, Boolean.valueOf(fieldApiValue));
                                    
                                }
                                
                                if(describeFieldResult.getType() == Schema.DisplayType.Currency)
                                {
                                   dynamicObject.put(fieldApi, Decimal.valueOf(fieldApiValue));
                                    
                                }
                                if(describeFieldResult.getType() == Schema.DisplayType.Date)
                                {   // 11/20/2010
                                    dynamicObject.put(fieldApi, Date.parse(fieldApiValue));
                                    
                                }
                                if(describeFieldResult.getType() == Schema.DisplayType.DateTime)
                                {      // 11/6/2014 12:00 AM
                                    dynamicObject.put(fieldApi, Datetime.parse(fieldApiValue));
                                    
                                }
                                
                                if(describeFieldResult.getType() == Schema.DisplayType.Email)
                                {
                                
                                    //email parsing
                                    String email = paramMap.get(fieldApi);
                                    System.debug('@@ for Email'+email);  
                               
                                    if(Pattern.matches('[a-zA-Z0-9._-]+@[a-zA-Z]+.[a-zA-Z]{2,4}', email))
                                    {
                                        dynamicObject.put(fieldApi,paramMap.get(fieldApi));
                                    }
                                    else
                                    {
                                    
                                      throw  new  WTOException('Invalid Email Format');  
                                                                           
                                    }
                                }
                                
                                if(describeFieldResult.getType() == Schema.DisplayType.Double)
                                {
                                    dynamicObject.put(fieldApi, Double.valueOf(fieldApiValue));
                                    
                                }
                                
                                if(describeFieldResult.getType() == Schema.DisplayType.Integer)
                                {
                                    dynamicObject.put(fieldApi, Integer.valueOf(fieldApiValue));
                                    
                                }
                                
                                
                                
                                if(describeFieldResult.getType() == Schema.DisplayType.Percent)
                                {
                                    dynamicObject.put(fieldApi, Decimal.valueOf(fieldApiValue));
                                    
                                }
                                
                                
                                if(describeFieldResult.getType() == Schema.DisplayType.Phone)
                                {
                                    // as refered as std functionality
                                    dynamicObject.put(fieldApi,paramMap.get(fieldApi));
                                    
                                }
                                
                                if(describeFieldResult.getType() == Schema.DisplayType.Picklist)
                                {
                                    // as refered as std functionality
                                    dynamicObject.put(fieldApi,paramMap.get(fieldApi));
                                    
                                }
                                
                                
                                if(describeFieldResult.getType() == Schema.DisplayType.MultiPicklist)
                                {
                                  dynamicObject.put(fieldApi,paramMap.get(fieldApi));
                                }
                                
                                
                                
                                if(describeFieldResult.getType() == Schema.DisplayType.String )
                                {
                                    // for text
                                    dynamicObject.put(fieldApi,paramMap.get(fieldApi));
                                    
                                }
                                
                                if(describeFieldResult.getType() == Schema.DisplayType.TextArea)
                                {
                                    dynamicObject.put(fieldApi,paramMap.get(fieldApi));
                                }
                                
                                if(describeFieldResult.getType() == Schema.DisplayType.URL)
                                {
                                    dynamicObject.put(fieldApi,paramMap.get(fieldApi));
                                    
                                }
                                
                           }
                        
                       } 
                        
                        
                    }
                    
                    insert dynamicObject;
                    
                    if(dynamicObject.id!=null)
                    {
                        
                        system.debug('$$$$$$ record inserted');
                        
                    }
                    else
                    {
                        system.debug('$$$$$$ record not inserted');
                       
                    }
                }
                else
                {
                    // Error for is object allowed.
                    system.debug('$$$$$$ object is not allowed');
                   
                }
                
            }
            else
            {
                // dont knw how to bounce back error(object is not present)
                system.debug('$$$$$$ object is deleted');
               
            }
            
            
            
        }
        catch(exception e)
        {
            // dont knw how to bounce back error
            system.debug('$$$$$$$$$ exception in Wtohtmlcontroller'   +e.getMessage());
            return returnPage;
            
        }
        
        return returnPage;
    }
    
    
    
    
    
}