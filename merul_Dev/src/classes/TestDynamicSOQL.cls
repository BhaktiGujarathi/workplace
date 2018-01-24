public class TestDynamicSOQL
{
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
String soqlQuery = 'SELECT ';
for(Schema.SObjectField sObjField : sObjFieldList)
{
String fieldLabel = sObjField.getDescribe().getLabel();
String fieldName = sObjField.getDescribe().getName();
String fieldType = String.valueOf(sObjField.getDescribe().getType());
String relationshipName = sObjField.getDescribe().getRelationshipName();
System.debug('>>>>>>>>>>>>>>>>>>>> Label = ' + fieldLabel + ' Name = ' + fieldName + ' Type = ' +
fieldType + ' relationshipName = ' + relationshipName);
// add each field to the base soql query
soqlQuery += ' ' + fieldName + ',';

// if this is a lookup field, also include the name field of the parent
if(('REFERENCE'.equalsIgnoreCase(fieldType) == true) && ((relationshipName != null) && (relationshipName.length() > 0)))
{
// add the name field from the parent object to the base soql query
soqlQuery += ' ' + relationshipName + '.Name,';
}
}
// add additional custom fields specified in the call to the base soql query
if((customFields != null) && (customFields.size() > 0))
{
for(String customField : customFields)
{
soqlQuery += ' ' + String.escapeSingleQuotes(customField) + ',';
}
}
// remove the last comma from the base query
soqlQuery = soqlQuery.subString(0, soqlQuery.length()-1);
// add the from clause to the base query
soqlQuery += ' FROM ' + objName + ' ';
//return the dynamic base soql query string
return soqlQuery;
}




}