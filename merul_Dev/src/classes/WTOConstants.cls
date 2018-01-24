public class WTOConstants
{


public static string wtoObjectListingPageUrlParamKey1 = 'objectName';
public static string apiNameForOwnerIDField = 'OwnerId';
public static string urlForObjectingListingPage = '/apex/WTOObjectListing';
public static string paramKeyForWtoForm = '?WTOFormid=';
public static string newline = '@fornewline@';
public static string headerString = '<html>{0}<META HTTP-EQUIV="Content-type" CONTENT="text/html; charset=UTF-8">{0}<form action="'+label.WTOFormLink+'/WTOHtmlForm" method="POST" enctype="application/x-www-form-urlencoded">{0}';
public static string returnURL = '<input type=hidden name="returnURL" value="https://{2}">{0}';
public static string hiddenString = '<input type=hidden name="objectName" value="{1}">{0}';
public static string submitString = '<input type="submit" name="submit">{0}';
public static string footerString = '{0}</form>{0}</html>';
public static string lineBreaker = '<br/>';
public static string htmlStringForTextType='<label for="{1}">{2}</label><input  id="{1}" maxlength="{3}" name="{1}" size="{4}" type="text" /><br><br>{0}';
public static string htmlStringForTextAreaType='<label for="{1}">{2}</label><textarea  id="{1}" name="{1}" type="text" wrap="soft" rows="{3}"></textarea><br><br>{0}';
public static string htmlStringForCheckbox='<label for="{1}">{2}</label><input  id="{1}" name="{1}" type="checkbox" value="1" /><br><br>{0}';
public static string htmlStringForSelectOptionValues='<option value="{1}">{2}</option><br><br>{0}';
public static string htmlStringForEndSelectOption='</select><br><br>{0}';
//public static string htmlStringForstartSelectOptionWithMultiselect='<label for="{1}">{2}</label><select  id="{1}" multiple="{3}" name="{1}" title="{2}"><br><br>{0}';
public static string htmlStringForstartSelectOptionWithMultiselect = '<label for="{1}">{2}</label><select  id="{1}_sel" multiple="{3}" name="{1}_sel" title="{2}" onchange="convertMultiSelect( \'\'\'\'{1}_sel\'\'\'\', \'\'\'\'{1}\'\'\'\');"><br><br>{0}';
public static String htmlStringForHiddenMultiSelect = '<input type="hidden" id="{1}" name="{1}"/><br><br>{0}';
public static string htmlStringForstartSelectOptionWithoutMultiselect='<label for="{1}">{2}</label><select  id="{1}" name="{1}" title="{2}"><br><br>{0}';
public static string multipleParameter='multiple';
public static string insufficientPrivilageErrorOnObject='Please check the privilage on the object or contact Administrator';
public static string successfullRecordCreationMsg='Record successfully inserted';
public static string objectSchemaAbsentMsg='Object schema not present in environment';
public static string htmlStringScriptForMultiSelect = '<script type="text/javascript">function convertMultiSelect(idSelect, idHidden){ var options = document.getElementById(idSelect).options; var delimitedString = ""; for (var iCount = 0; iCount < options.length; iCount++){ if (options[iCount].selected){ if (delimitedString.length == 0) { delimitedString += options[iCount].value;} else { delimitedString += ";" + options[iCount].value;} } } document.getElementById(idHidden).value = delimitedString;} </script>';


//For Test Class
public static string apiNameForTestObject =  'WTOTestObject__c';
public static string apiForNameField = 'Name__c';
public static string labelForNameField ='Name';
public static List<String> listOfAPINameForTestField= new List<String> {'DOB__c','Name__c','Reminder_Date__c','Status__c','testForCheckbox__c','testForCurrency__c','testForDate__c','testForDateTime__c','testForEmail__c','testForNumber__c','testForPercentage__c','testForPhone__c','testForPicklist__c','testForPicklistMulti__c','testForText__c','testForTextArea__c','testForTextAreaLong__c','testForTextAreaRich__c','testForURL__c','TestMultiselect__c'};
public static List<String> listOfLabelsForTestField= new List<String> {'DOB','Name','Reminder Date','Status','testForCheckbox','testForCurrency','testForDate','testForDateTime','testForEmail','testForNumber','testForPercentage','testForPhone','testForPicklist','testForPicklistMulti','testForText','testForTextArea','testForTextAreaLong','testForTextAreaRich','testForURL','TestMultiselect'};

//For Godson

public static string submitLabel='submit';        // added by godson
public static string returnUrlLabel='returnURL';  // added by godson 
}