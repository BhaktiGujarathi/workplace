public class InventoryPDFDetailPage {
    public string invid{set;get;}
    public Inventory__c inventory{set;get;}
    public InventoryPDFDetailPage(ApexPages.StandardController controller) {
        
        invid = controller.getId();
        system.debug('***invid'+invid);
        for(Inventory__c thisInventory:[SELECT Selling_Price__c,List_Price_calc__c, Special_Price_calc__c,Property_Type__c,
                                        Building_Name__c,Brand__c,Unit__c,Property_Status__c,
                                        Unit_Type__c,IPMS_Bedrooms__c,Area_Sqft_2__c,Price_Per_Sqft__c,
                                        Anticipated_Completion_Date__c,Construction_Status__c,
                                        Land_Registration_Fee_A__c,Title_Deed_B__c,
                                        OQOOD_Fee_C__c,DSR_Fees_D__c,Total_Fees_to_DLD__c,
                                        Unit_Plan__c,Floor_Plan__c,Plot_Plan__c,Floor_Package_Name__c,Floor_Package_Type__c
                                        from Inventory__c 
                                    WHERE Id = : invid]){
                inventory = thisInventory;                                 
       }
        
       //if(null != inventory.Unit_Plan__c)
       	//unitPlan = getBlob(inventory.Unit_Plan__c);
        
    }
    
    /*public Blob getBlob(String url){

        Http h = new Http(); 

        system.debug(url);
        req.setEndpoint(url);
        req.setMethod('GET'); 

        req.setHeader('Content-Type', 'application/pdf');
        req.setTimeout(60000);
        HttpResponse res = null; 

        string responseValue = ''; 
        responseValue = res.getBody(); 
        system.debug('Response Body for File: ' + responseValue); 
        blob image = res.getBodyAsBlob(); 
        return image;
    }*/
   
}