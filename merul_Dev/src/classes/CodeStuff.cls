public Class CodeStuff
{

// Sorting Object base on field
/*

.link
{
    font-size:11px;    
text-decoration:none;
color:#19A3FF;
cursor:pointer;
}
.link:hover
{
    font-size:12px;
    text-decoration:none;
    color:#0F6299;    
    cursor:pointer;
}


then in the componet have following attriibute
styleClass="link"

*/

/*

public static List<sObject> sortList(List<sObject> items,String sortField,String order)
    {
        List<sObject> resultList = new List<sObject>();
        //Create a map that can be used for sorting 
        Map<object, List<sObject>> objectMap = new Map<object, List<sObject>>();
        
        for(sObject ob : items) {
            if(objectMap.get(ob.get(sortField)) == null) {
                // For non Sobject use obj.ProperyName
                objectMap.put(ob.get(sortField), new List<sObject>());
            }
            objectMap.get(ob.get(sortField)).add(ob);
        }
    
        //Sort the keys
        List<object> keys = new List<object>(objectMap.keySet());
        keys.sort();
        for(object key : keys) {
            resultList.addAll(objectMap.get(key));
        }
        
        //Apply the sorted values to the source list
        items.clear();
        if(order.toLowerCase() == 'asc') {
            for(Sobject ob : resultList)
                items.add(ob);
        }
        else if(order.toLowerCase() == 'desc') {
            for(integer i = resultList.size()-1; i >= 0; i--)
                items.add(resultList[i]);
        }
        
        return items;
    }






*/

// Email As PDF by parameter

/*

         List<String> EmailIds = new List<String>();
         EmailIds.add('merulkumar.s.shah@aexp.com');
         PageReference ref = Page.PDF_DEMO;        // PDF_DEMO is page in Developer org 
         
        ref.getParameters().put('id', 'Merul');    // setting parameter. Developer can query on base 
                                                   // of these parameter in loading action method of  PDF_DEMO to get the details
        
        Blob b = ref.getContentAsPDF();
        system.debug('#######  '+b);
        Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
        Messaging.EmailFileAttachment efa1 = new Messaging.EmailFileAttachment();
        efa1.setFileName('attachment_WORK.pdf');
        efa1.setBody(b);
        String addresses;
        email.setSubject('hiii Merul');
        email.setToAddresses( EmailIds  );
        email.setPlainTextBody('hii');
        email.setFileAttachments(new Messaging.EmailFileAttachment[] {efa1});
        Messaging.SendEmailResult [] r = Messaging.sendEmail(new Messaging.SingleEmailMessage[] {email});



*/








// Schema Class for getting object information.
/*

 Map<String, Schema.SObjectType> gd=new  Map<String, Schema.SObjectType>();
gd = Schema.getGlobalDescribe();
Schema.DescribeSObjectResult gdSObject;


                            for(String sObj :  gd.keySet())    
                              {
                                
                                       gdSObject= gd.get(sObj).getDescribe();   
                                          
                                       if(gdSObject.getKeyPrefix()!=null && gdSObject.custom==true  && gdSObject.customSetting==false && gdSObject.accessible && !objRejected1.equalsIgnoreCase(gdSObject.getLabel())  && !objRejected2.equalsIgnoreCase(gdSObject.getLabel()) )     
                                                                          
                                        {
                                                                               
                                                                                                         
                                        }                                                                    
                           
                              }






*/





// Schema Class for getting the fields details of object.

/*

            Map<String, Schema.SObjectField> allIntegrationFieldsMap = Schema.SObjectType.Integration_Project__c.fields.getMap();
            
            // here Integration_Project__c is object name
            
             Map<String, Schema.DescribeFieldResult> IntegrationFieldsToTrack = new Map<String, Schema.DescribeFieldResult>();
            
            
             for(Schema.SObjectField integrationField :allIntegrationFieldsMap.values())
                {
                    Schema.DescribeFieldResult describeResult = integrationField.getDescribe();
                   
                    //choose which fields to track depending on the field type
                    if (describeResult.getType() == Schema.DisplayType.Boolean ||
                        describeResult.getType() == Schema.DisplayType.Combobox ||
                        describeResult.getType() == Schema.DisplayType.Currency ||
                        describeResult.getType() == Schema.DisplayType.Date ||
                        describeResult.getType() == Schema.DisplayType.DateTime ||
                        describeResult.getType() == Schema.DisplayType.Double ||
                        describeResult.getType() == Schema.DisplayType.Email ||
                        describeResult.getType() == Schema.DisplayType.Integer ||
                        describeResult.getType() == Schema.DisplayType.MultiPicklist ||
                        describeResult.getType() == Schema.DisplayType.Percent ||
                        describeResult.getType() == Schema.DisplayType.Phone ||
                        describeResult.getType() == Schema.DisplayType.Picklist ||
                        describeResult.getType() == Schema.DisplayType.String ||
                        describeResult.getType() == Schema.DisplayType.TextArea ||
                        describeResult.getType() == Schema.DisplayType.Time ||
                        describeResult.getType() == Schema.DisplayType.URL) 
                        {
                        //don't add standard fields that are not necessary
                        if (describeResult.getName() != 'CreatedDate' &&
                            describeResult.getName() != 'LastModifiedDate' &&
                            describeResult.getName() != 'SystemModstamp' &&
                            //only add fields that are visible to the current user
                            describeResult.isAccessible() &&
                            //do not add formula fields
                            !describeResult.isCalculated()
                            )
                            {
                                IntegrationFieldsToTrack.put(describeResult.getName(), describeResult);
                            }
                        }
                        
                }
                
                
                // for tracking the field's changed value
                
                    sObject  oldInt;
                    sObject  NewInt;
                    for(sObject  integration: Trigger.New)
                    {
                        oldInt = Trigger.oldMap.get(integration.ID);
                        NewInt = Trigger.newMap.get(integration.ID);
                    }
                                    
                                  for(String tempfield: IntegrationFieldsToTrack.keySet())
                                  {    
                                              if(oldInt.get(tempfield)!= NewInt.get(tempfield))
                                            {
                                                //write logic inside 
                                            }
                                   }
            



*/ 


//Schema Class for getting the fields details of object, when object name is dynamic
/*


  
    sObject sobj=Database.query(qry);  // dynamic query which return the any sobject based on query
    Map<String, Schema.SObjectField> fields =sobj.getSObjectType().getDescribe().fields.getMap();
    // then u can use describe calls
           
*/

//Creating sobject using if i know object api name in string

/*


String typeName = 'Account';

Schema.SObjectType targetType = Schema.getGlobalDescribe().get(typeName);

if(targetType!= null)
{
   sObject obj = targetType.newSObject();
}
// now either cast it to Account and proceed
// Account a = (Account) obj;
// a.Name = 'Abc';

// or use sObject's generic get() and put() methods
obj.put('Name', 'Abc'); // use targetType.getDescribe().fields.getMap() to obtain map of all available field names
insert obj;


/*




 <apex:variable value="{!1}" var="counter"/>
<table>

 <tr>
 <apex:repeat value="{!listWrapper}" var="f">
 
                 
                  <td>{!f.label}</td>
                 
                    <td> 
                    <apex:inputField value="{!f.acc[f.field]}" /><br></br>
                    </td>
                
                  <apex:outputText rendered="{!AND((MOD(counter, 4) == 0), (counter < listWrapper.size))}" value="</tr><tr>" escape="false"/>
                <apex:variable var="counter" value="{!counter + 1}"/>
                  
                  
 </apex:repeat>
 

  </tr>
 
 
 </table>
 
 





*/


/*  Custom webservice and partner WSDL

partnerSoapSforceCom.Soap sp = new partnerSoapSforceCom.Soap();
   
 
  String username = '<Your username here>';
  String password = '<Your password here>';
   
  partnerSoapSforceCom.LoginResult loginResult = sp.login(username, password);
   
  system.debug('   loginResult ' + loginResult);
   // Custom class generated------->soapSforceCom200608Apex
   
  soapSforceCom200608Apex.Apex apexWebSvc = new soapSforceCom200608Apex.Apex();
  soapSforceCom200608Apex.SessionHeader_element sessionHeader = new soapSforceCom200608Apex.SessionHeader_element();
  sessionHeader.sessionId = loginResult.sessionId;
   
  // The Web services have a maximum timeout of 2 minutes. The timeout value
  // is in milliseconds.
  apexWebSvc.timeout_x = 120000;
  apexWebSvc.SessionHeader = sessionHeader;
   
  soapSforceCom200608Apex.RunTestsRequest testsRequest = new soapSforceCom200608Apex.RunTestsRequest();
  testsRequest.allTests = true;
           
  soapSforceCom200608Apex.RunTestsResult testResults = apexWebSvc.runTests(testsRequest);
 
*/


/*

    
    // Join an Apex list of fields into a SELECT fields list string Or making the query string.
    private static String joinList(List<String> theList, String separator) {

        if (theList == null) {
            return null;
        }
        if (separator == null) {
            separator = '';
        }

        String joined = '';
        Boolean firstItem = true;
        for (String item : theList) {
            if(null != item) {
                if(firstItem){
                    firstItem = false;
                }
                else {
                    joined += separator;               
                }
                joined += item;
            }
        }
        return joined;
    }
}




*/


/*

// for Object Access Utility Please refer class:
 Apex class: ObjectAccessUtils 

*/



/*

//return a dynamic Query string that includes all the direct sObject fields and the related Name fields from the parent objects
//dependent method of getSobjects
//TODO: move this into platform wide sobject utils class as it is not domain specific
public static String getBaseQuery(String objName, List<String> customFields)
{
// get the describe info for the org, object and its fields
Map<String,Schema.SObjectType> orgMap = Schema.getGlobalDescribe();
Schema.SObjectType sObjType = orgMap.get(objName);
Schema.DescribeSObjectResult sObjDescribe = sObjType.getDescribe();
Map<String, Schema.SObjectField> sObjFieldMap = sObjDescribe.fields.getMap();
List<Schema.SObjectField> sObjFieldList = sObjFieldMap.values();
//build out the base soql query using the describe info
String soqlQuery = ‘SELECT ‘;
for(Schema.SObjectField sObjField : sObjFieldList)
{
String fieldLabel = sObjField.getDescribe().getLabel();
String fieldName = sObjField.getDescribe().getName();
String fieldType = String.valueOf(sObjField.getDescribe().getType());
String relationshipName = sObjField.getDescribe().getRelationshipName();
System.debug(‘>>>>>>>>>>>>>>>>>>>> Label = ‘ + fieldLabel + ‘ Name = ‘ + fieldName + ‘ Type = ‘ +
fieldType + ‘ relationshipName = ‘ + relationshipName);
// add each field to the base soql query
soqlQuery += ‘ ‘ + fieldName + ‘,';
// if this is a lookup field, also include the name field of the parent
if((‘REFERENCE’.equalsIgnoreCase(fieldType) == true) && ((relationshipName != null) && (relationshipName.length() > 0)))
{
// add the name field from the parent object to the base soql query
soqlQuery += ‘ ‘ + relationshipName + ‘.Name,';
}
}
// add additional custom fields specified in the call to the base soql query
if((customFields != null) && (customFields.size() > 0))
{
for(String customField : customFields)
{
soqlQuery += ‘ ‘ + String.escapeSingleQuotes(customField) + ‘,';
}
}
// remove the last comma from the base query
soqlQuery = soqlQuery.subString(0, soqlQuery.length() – 1);
// add the from clause to the base query
soqlQuery += ‘ FROM ‘ + objName + ‘ ‘;
//return the dynamic base soql query string
return soqlQuery;
}




*/




}