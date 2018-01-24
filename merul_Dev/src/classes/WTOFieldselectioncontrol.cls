public class WTOFieldselectioncontrol
{
    
    Public String htmlCode{get;set;}
    Public String test{get;set;}
    Public String objectType{get;set;}
    Public String link{get;set;}
    Public String returnURL{get;set;}
    Public boolean renderlink{get;set;}
    Public boolean renderTextArea{get;set;}
    Public Map<String,String> mapApiLabel{get;set;}
    Public Map<String,Schema.SObjectField> fieldsMap=new Map<String,Schema.SObjectField>();
    Public List<string> leftSelected{get;set;}
    Public List<string> rightSelected{get;set;}
    Public Set<string> leftValues = new Set<string>();
    Public List<string> rightValues = new List<string>();
    Public Set<string> requiredField = new Set<string>();
      
    public void onload()
    {
        
        mapApiLabel = new Map<String,String>();
        leftSelected = new List<String>();
        rightSelected = new List<String>();
        renderlink=false;
        renderTextArea=false;
        objectType = System.currentPagereference().getParameters().get(WTOConstants.wtoObjectListingPageUrlParamKey1);
        Map<String,Schema.SObjectType> globalDescribeForObject = Schema.getGlobalDescribe();
        Schema.SObjectType sobjType = globalDescribeForObject .get(objectType);
        Schema.DescribeSObjectResult describeResult = sobjType.getDescribe();
        fieldsMap = describeResult.fields.getMap();
        
        for(String fieldApiName : fieldsMap.keySet())
        {
           Schema.DescribeFieldResult describeFieldResult = (fieldsMap.get(fieldApiName)).getDescribe();
            if(describeFieldResult.isAccessible() && describeFieldResult.getName()!= WTOConstants.apiNameForOwnerIDField && describeFieldResult.isUpdateable() && describeFieldResult.isCreateable())
            {                                                                //Change done by godson in line 36 for ownerId
                 
                if(WTOUtility.checkForFieldType(describeFieldResult))    
                {
                    mapApiLabel.put(fieldApiName,describeFieldResult.getlabel());
                    if(!describeFieldResult.isNillable() && !describeFieldResult.isDefaultedOnCreate())
                    {
                        rightValues.add(fieldApiName);
                        requiredField.add(fieldApiName);
                        
                    }
                    else
                    {
                        leftValues.add(fieldApiName);
                        
                    }
                    
                    
                }
                
            }
            
        }
        
    }
    
    public List<SelectOption> getUnSelectedValues()
    {
        List<SelectOption> unSelectedValuesList = new List<SelectOption>();
        List<string> tempUnSelectedValuesList = new List<String>();
        tempUnSelectedValuesList.addAll(leftValues);
        tempUnSelectedValuesList.sort();
        for(String fieldApiName  : tempUnSelectedValuesList )
        unSelectedValuesList.add(new SelectOption(fieldApiName,mapApiLabel.get(fieldApiName )));
        return unSelectedValuesList ;
    }
    
    
    public List<SelectOption> getSelectedValues()
    {
        
        List<SelectOption> selectedValuesList = new List<SelectOption>();
        List<string> tempSelectedValuesList = new List<String>();
        tempSelectedValuesList.addAll(rightValues);
        for(String fieldApiName:tempSelectedValuesList)
        selectedValuesList.add(new SelectOption(fieldApiName,mapApiLabel.get(fieldApiName)));
        return selectedValuesList;
        
    }
    
    public PageReference selectClick()
    {
        
        rightSelected.clear();
        for(String fieldApiName : leftSelected)
        {
            leftValues.remove(fieldApiName );
            rightValues.add(fieldApiName );
        }
        return null;
    }
    
    
    public PageReference unSelectclick()
    {
        leftSelected.clear();
        for(String fieldApiName : rightSelected)
        {
            
            if(!requiredField.contains(fieldApiName ))
            {
                for(Integer i=0;i<rightValues.size();i++)
                {
                    if(rightValues[i].equals(fieldApiName))
                    {
                        rightValues.remove(i);
                        
                    }
                    
                }
                
                leftValues.add(fieldApiName);
                
            }
            
        }
        return null;
    }
    
    public PageReference upClick()
    {
        Map<Integer,String> indexOfValue=new Map<Integer,String>();
        List<String> tempRightValuesList = new List<String>();
        tempRightValuesList .addall(rightValues);
        for(String fieldApiName : rightSelected)
        {
            for(Integer i=0; i<tempRightValuesList.size();i++)
            {
                if(fieldApiName.equals(tempRightValuesList[i]))
                {
                    indexOfValue.put(i,fieldApiName);
                }
                
            }
            
        }
        
        for(Integer i:indexOfValue.keyset())
        {
            if(i!=0)
            {
                String firstVarForSwap=tempRightValuesList.get(i-1);
                String secondVarForSwap=tempRightValuesList.get(i);
                tempRightValuesList.set(i,firstVarForSwap);
                tempRightValuesList.set(i-1,secondVarForSwap);
                
            }
        }
        
        rightValues=tempRightValuesList;
        return null;
    }
    
    
    
    public PageReference downClick()
    {
        Map<Integer,String> indexOfValue=new Map<Integer,String>();
        List<string> tempRightValuesList = new List<String>();
        List<integer> tempIndex = new List<integer>();
        tempRightValuesList.addall(rightValues);
        for(String fieldApiName : rightSelected)
        {
            for(Integer i=0; i<tempRightValuesList.size();i++)
            {
                if(fieldApiName.equals(tempRightValuesList[i]))
                {
                    indexOfValue.put(i,fieldApiName);
                }
                
            }
            
        }
        
        tempIndex.addall(indexOfValue.keyset());
        for(Integer i=tempIndex.size()-1;i>=0;i--)
        {
            if(tempIndex[i]!=tempRightValuesList.size()-1)
            {
                String previousIndex=tempRightValuesList.get(tempIndex[i]+1);
                String currentIndex=tempRightValuesList.get(tempIndex[i]);
                tempRightValuesList.set(tempIndex[i],previousIndex);
                tempRightValuesList.set(tempIndex[i]+1,currentIndex);
                
            }
        }
        
        rightValues=tempRightValuesList;
        return null;
    }
    
    
    
    
    
    
    public PageReference cancel()
    {
        PageReference redirect = new PageReference(WTOConstants.urlForObjectingListingPage );
        redirect.setRedirect(true);
        return redirect;
    }
    
    
    
    public PageReference save()
    {
        
        renderlink=true;
        renderTextArea=false;
        String selectedFields;
        
        for(String fieldApiName:rightValues)
        {
            
            if(selectedFields==null)
            {
                selectedFields=fieldApiName;
            }
            else
            {
                selectedFields=selectedFields+','+fieldApiName;
            }
            
            
        }
        
        WTOFormFields__c wtoFormField= new WTOFormFields__c(objectapiname__c=objectType,Fieldsapiname__c=selectedFields);
        insert wtoFormField;
        link=label.WTOFormLink+WTOConstants.paramKeyForWtoForm+wtoFormField.id;
        wtoFormField.Link__c = link;
        update wtoFormField;
        return null;
        
        
    }
    
    public PageReference generateHTML()
    {   
        renderlink=false;
        renderTextArea=true;
        
        List<String> stringStuffing = new List<String>{WTOConstants.newline,objectType,returnURL};
        String headerString = String.format(WTOConstants.headerString,stringStuffing);
        String hiddenString = String.format(WTOConstants.hiddenString,stringStuffing);
        String submitString = String.format(WTOConstants.submitString,stringStuffing);
        String footerString = String.format(WTOConstants.footerString,stringStuffing);
        String htmlStringField='';
        String scriptForHtml='';
        String tempHtmlStringField;
        Integer countForMultiSelectPicklist = 0;
        for(String fieldApiName:rightvalues)
        {
            
            Schema.DescribeFieldResult describeFieldResult = (fieldsMap.get(fieldApiName)).getDescribe();
                if(describeFieldResult.getType() == Schema.DisplayType.MultiPicklist)
                {
                  countForMultiSelectPicklist++;
                }
            tempHtmlStringField=WTOUtility.buildHtmlStringField(describeFieldResult,fieldApiName);
            if(tempHtmlStringField!=null)
            {
                htmlStringField=htmlStringField+tempHtmlStringField;
            }
        }
        if(countForMultiSelectPicklist > 0)
        {
           
           scriptForHtml = WTOConstants.htmlStringScriptForMultiSelect;
        }
        
        htmlCode=String.format(headerString+hiddenString+WTOConstants.returnURL+HtmlStringField+submitString,stringStuffing)+scriptForHtml+String.format(footerString,stringStuffing);
        htmlCode=htmlCode.escapeHtml4();
        htmlCode=htmlCode.replaceAll(WTOConstants.newline,WTOConstants.lineBreaker);
       
        return null;
    }
    
    
}