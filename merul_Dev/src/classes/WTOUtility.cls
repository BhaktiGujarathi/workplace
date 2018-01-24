public class WTOUtility
{
    
    
    public static String buildHtmlStringField(Schema.DescribeFieldResult describeFieldResult,String fieldApiName)
    {
        
        
        if(describeFieldResult.getType() == Schema.DisplayType.Boolean)
        {
            List<String> stringStuffing = new List<String>{WTOConstants.newline,fieldApiName,describeFieldResult.getLabel()};
            return String.format(WTOConstants.htmlStringForCheckbox,stringStuffing);
        }
        
        if(describeFieldResult.getType() == Schema.DisplayType.Currency)
        {
            return buildHtmlTextType(fieldApiName,describeFieldResult.getLabel(),'','20');
            
        }
        
        if(describeFieldResult.getType() == Schema.DisplayType.Date)
        {
            return buildHtmlTextType(fieldApiName,describeFieldResult.getLabel()+'(eg.11/20/2010)','','12');
            
        }
        
        if(describeFieldResult.getType() == Schema.DisplayType.DateTime)
        {
            return buildHtmlTextType(fieldApiName,describeFieldResult.getLabel()+'(eg.11/6/2014 12:00 AM)','','20');
            
        }
        
        if(describeFieldResult.getType() == Schema.DisplayType.Email)
        {
            return buildHtmlTextType(fieldApiName,describeFieldResult.getLabel(),'80','20');
            
        }
        
        
        if(describeFieldResult.getType() == Schema.DisplayType.Double)
        {
            return buildHtmlTextType(fieldApiName,describeFieldResult.getLabel(),'','20');
            
        }
        
        if(describeFieldResult.getType() == Schema.DisplayType.Integer)
        {
            return buildHtmlTextType(fieldApiName,describeFieldResult.getLabel(),'','20');
            
        }
        
        if(describeFieldResult.getType() == Schema.DisplayType.Percent)
        {
            return buildHtmlTextType(fieldApiName,describeFieldResult.getLabel(),'','20');
            
        }
        
        
        if(describeFieldResult.getType() == Schema.DisplayType.Phone)
        {
            return buildHtmlTextType(fieldApiName,describeFieldResult.getLabel(),'40','20');
            
        }
        
        if(describeFieldResult.getType() == Schema.DisplayType.Picklist)
        {
            return buildHtmlPicklistType(describeFieldResult,fieldApiName,describeFieldResult.getLabel(),'');
            
        }
        
        
        if(describeFieldResult.getType() == Schema.DisplayType.MultiPicklist)
        {
            return buildHtmlPicklistType(describeFieldResult,fieldApiName,describeFieldResult.getLabel(),WTOConstants.multipleParameter);
            
        }
        
        if(describeFieldResult.getType() == Schema.DisplayType.String)
        {
            return buildHtmlTextType(fieldApiName,describeFieldResult.getLabel(),'80','20');
            
        }
        
        if(describeFieldResult.getType() == Schema.DisplayType.TextArea)
        {
           if(describeFieldResult.getLength() <= 255 )
            return buildHtmlTextAreaType(fieldApiName,describeFieldResult.getLabel(),'10');
           else
            return buildHtmlTextAreaType(fieldApiName,describeFieldResult.getLabel(),'25'); 
        }
        
        if(describeFieldResult.getType() == Schema.DisplayType.URL)
        {
            return buildHtmlTextType(fieldApiName,describeFieldResult.getLabel(),'255','20');
            
        }
        
        return null;
    }
    
    public static boolean checkForFieldType(Schema.DescribeFieldResult describeFieldResult)
    {
        
        return (describeFieldResult.getType() == Schema.DisplayType.Boolean ||
        describeFieldResult.getType() == Schema.DisplayType.Combobox ||
        describeFieldResult.getType() == Schema.DisplayType.Currency ||
        describeFieldResult.getType() == Schema.DisplayType.Date ||
        describeFieldResult.getType() == Schema.DisplayType.DateTime ||
        describeFieldResult.getType() == Schema.DisplayType.Double ||
        describeFieldResult.getType() == Schema.DisplayType.Email ||
        describeFieldResult.getType() == Schema.DisplayType.Integer ||
        describeFieldResult.getType() == Schema.DisplayType.MultiPicklist ||
        describeFieldResult.getType() == Schema.DisplayType.Percent ||
        describeFieldResult.getType() == Schema.DisplayType.Phone ||
        describeFieldResult.getType() == Schema.DisplayType.Picklist ||
        describeFieldResult.getType() == Schema.DisplayType.String ||
        describeFieldResult.getType() == Schema.DisplayType.TextArea ||
        describeFieldResult.getType() == Schema.DisplayType.Time ||
        describeFieldResult.getType() == Schema.DisplayType.URL ||
        describeFieldResult.getRelationshipName() == null );
    }
    
    
    
    private static String  buildHtmlTextType(String fieldApiName,String label,String maxlength,String size)
    {
        List<String> stringStuffing = new List<String>{WTOConstants.newline,fieldApiName,label,maxlength,size};
        return String.format(WTOConstants.htmlStringForTextType,stringStuffing);
        
        
    }
    
    
    private static String  buildHtmlTextAreaType(String fieldApiName,String label,String row)
    {
        
        List<String> stringStuffing = new List<String>{WTOConstants.newline,fieldApiName,label,row};
        return String.format(WTOConstants.htmlStringForTextAreaType,stringStuffing);
        
    }
    
    private static String  buildHtmlPicklistType(Schema.DescribeFieldResult describeFieldResult,String fieldApiName,String label,string multiple)
    {
        string startSelectOption;
        string hiddenMultiSelect=''; 
        List<String> stringStuffing = new List<String>{WTOConstants.newline,fieldApiName,label,multiple};
        if(multiple.equals(WTOConstants.multipleParameter))
        {
            startSelectOption=String.format(WTOConstants.htmlStringForstartSelectOptionWithMultiselect,stringStuffing);
            hiddenMultiSelect = String.format(WTOConstants.htmlStringForHiddenMultiSelect,stringStuffing);
            
        }
        else
        {
            startSelectOption=String.format(WTOConstants.htmlStringForstartSelectOptionWithoutMultiselect,stringStuffing);
        }
        string selectOptionValues='';
        string endSelectOption=String.format(WTOConstants.htmlStringForEndSelectOption,stringStuffing);
        
        for (Schema.PicklistEntry picklistValueProperty : describeFieldResult.getPicklistValues()) {
            
            List<String> stringStuffingForPicklistValues = new List<String>{WTOConstants.newline,picklistValueProperty.getValue(),picklistValueProperty .getLabel()};
            selectOptionValues=selectOptionValues+String.format(WTOConstants.htmlStringForSelectOptionValues,stringStuffingForPicklistValues);
            
        }
        return startSelectOption+selectOptionValues+endSelectOption+hiddenMultiSelect;
        
        
    }
    
    public static string convertComponentToNameSpaceComponent(String component)
    {
      return Label.WTONameSpace+component;
    }
    
    
}