public class WTOObjectListing {
    public String selectedObject{get;set;}
   
      public List<SelectOption> getName()
    {
        List<Schema.SObjectType> globalDescribe = Schema.getGlobalDescribe().Values();
        List<SelectOption> picklistForObjectLabel = new List<SelectOption>();
        List<String> listOfObjectLabel=new List<String>();
        Map<String,String> mapLabelApi=new Map<String,String>();
        
        
        for(Schema.SObjectType objectType : globalDescribe)
        {
            Schema.DescribeSObjectResult  SObjectResult=objectType.getDescribe();
            
            if(SObjectResult.isAccessible() && SObjectResult.isCreateable() /*&& SObjectResult.isCustom()*/  )
            {
                mapLabelApi.put(SObjectResult.getLabel(),SObjectResult.getName());
               
            }
        }
       
        listOfObjectLabel.addall(mapLabelApi.keyset());
        listOfObjectLabel.sort();
        for(String fieldLabel:listOfObjectLabel)
        {
            picklistForObjectLabel.add(new SelectOption(mapLabelApi.get(fieldLabel),fieldLabel));
        }
        
        return picklistForObjectLabel;
    }
    public PageReference next()
    {
    
        PageReference pageRef = Page.WTOFieldselection;
        pageRef.getParameters().put(WTOConstants.wtoObjectListingPageUrlParamKey1,selectedObject);
        pageRef.setRedirect(true);
        return pageRef;
        
    }
}