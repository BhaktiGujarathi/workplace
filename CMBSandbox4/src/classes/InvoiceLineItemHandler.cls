/* Description - Handler Class for InvoiceTrigger
 *  
 * Created By - Shraddha P.
 *  
 * Date(DD/MM/YYYY)  - 20/08/2015
 */


public class InvoiceLineItemHandler {

    //Method calls after insert event of LineItemTrigger
    public void onAfterInsert(list<Line_Item__c> lstInvoiceLineItem){
        UpdateInvoice(lstInvoiceLineItem);
        //UpdateHarvestProject((map<Id, Line_Item__c>)trigger.newMap,
       //                                                     (map<Id, Line_Item__c>)trigger.oldMap);
    }
    //Method calls after update event of LineItemTrigger
    public void onAfterUpdate(list<Line_Item__c> lstInvoiceLineItem){
        UpdateInvoice(lstInvoiceLineItem);
        //UpdateHarvestProject((map<Id, Line_Item__c>)trigger.newMap,
       //                                                     (map<Id, Line_Item__c>)trigger.oldMap);
    }
    
    //Method calls after delete event of LineItemTrigger
     public void onAfterDelete(list<Line_Item__c> lstInvoiceLineItem){
        DeleteInvoice(lstInvoiceLineItem);
      //  UpdateHarvestProject((map<Id, Line_Item__c>)trigger.newMap,
        //                                                    (map<Id, Line_Item__c>)trigger.oldMap);
    }
  /* modified to update credit hours on project  by Ashwini kr Singh*/
  /*  public void UpdateHarvestProject(map<Id,Line_Item__c> newLineItemMap, map<Id,Line_Item__c> oldLineItemMap ){
        decimal creditHoursthisMonth=0;
        decimal creditHoursPreviousMonth=0;
        decimal creditHours=0;
        list<HarvestProject__c> projectToUpdate = new list<HarvestProject__c>();
        //Adding related projects to set
        set<Id> projectSet= new set<Id>();
         if (newLineItemMap!= null){
            for(Line_Item__c invoiceLine: newLineItemMap.Values()){
                if(invoiceLine.HarvestProject__c != null){
                    projectSet.add(invoiceLine.HarvestProject__c); 
                }
            }
        }// in case of account change on update or delete
        if (oldLineItemMap!= null){
            for(Line_Item__c invoiceLine: oldLineItemMap.Values()){
                if(invoiceLine.HarvestProject__c != null){
                    projectSet.add(invoiceLine.HarvestProject__c); 
                }
            }
        }
        
        list<HarvestProject__c> lstProj=[Select Id,
                                    Hours_Credited__c,
                                    Hours_Credited_This_Month__c,
                                    Hours_Credited_Previous_Month__c,
                                    (Select Id,
                                        isCredit_Checkbox__c,
                                        Date__c,
                                        Credit_Hrs__c
                                        FROM Invoice_Line_Items__r)
                                     FROM HarvestProject__c where Id IN :projectSet];

        if(lstProj != null && !lstProj.isEmpty()){  
            for(HarvestProject__c objProj: lstProj){
                creditHoursthisMonth=0;
                creditHours=0;
                creditHoursPreviousMonth=0;
                if (objProj.Invoice_Line_Items__r!=null){
                    for (Line_Item__c objLineItem:objProj.Invoice_Line_Items__r ){
                        creditHours=creditHours+ decimalValue(objLineItem.Credit_Hrs__c);
                        if (objLineItem.Date__c!=null && objLineItem.Date__c.month()==System.today().month()){
                            creditHoursthisMonth=creditHoursthisMonth+decimalValue(objLineItem.Credit_Hrs__c);
                        }//end if 
                        else if (objLineItem.Date__c!=null && objLineItem.Date__c.month()==(System.today().month()-1)){
                            creditHoursPreviousMonth=creditHoursPreviousMonth+decimalValue(objLineItem.Credit_Hrs__c);
                        }//end if  
                    }// end for
                    objProj.Hours_Credited__c=creditHours;
                    objProj.Hours_Credited_This_Month__c=creditHoursthisMonth;
                    objProj.Hours_Credited_Previous_Month__c=creditHoursPreviousMonth;
                }//end if
                projectToUpdate.add(objProj);
            }//end for 
        }//end if 
        if(!projectToUpdate.isEmpty()){
            update projectToUpdate;
        }
    }*/

    //Updates Invoice Total # of Projects - Populates number of Harvest Project present on related Line Items
    public void UpdateInvoice(list<Line_Item__c> lstInvoiceLineItem){
        set<Id> setInvoiceId = new set<Id>();
        for(Line_Item__c obj: lstInvoiceLineItem){
            setInvoiceId.add(obj.Invoice__c);
        }
        setInvoiceId.remove(null);
        map<id,list<Line_Item__c>>mapIdAndLineItemsList = new map<id,list<Line_Item__c>>();
        map<id,set<Id>> mapProjectIdAndLineItm = new Map<id,set<Id>>();
        list<Line_Item__c> templist = new list<Line_Item__c>();
        set<Id> invoiceIdSet= new set<Id>();
        list<Line_Item__c> litmList = [select id,
                                              HarvestProject__c,
                                              Invoice__c 
                                       from Line_Item__c 
                                       where Invoice__c IN: setInvoiceId];
        for(Line_Item__c objlitm: litmList){
            if((!mapProjectIdAndLineItm.containskey(objlitm.HarvestProject__c) || (mapProjectIdAndLineItm.get(objlitm.HarvestProject__c) != null && 
            (!mapProjectIdAndLineItm.get(objlitm.HarvestProject__c).contains(objlitm.Invoice__c)) && objlitm.HarvestProject__c != null)) &&
            objlitm.HarvestProject__c != null)
            {
                if(mapProjectIdAndLineItm.get(objlitm.HarvestProject__c) != null){
                    invoiceIdSet = mapProjectIdAndLineItm.get(objlitm.HarvestProject__c);
                    invoiceIdSet.add(objlitm.Invoice__c);
                }
                else{
                    invoiceIdSet =new set<Id>();
                    invoiceIdSet.add(objlitm.Invoice__c);
                }
                mapProjectIdAndLineItm.put(objlitm.HarvestProject__c, invoiceIdSet);

                if(mapIdAndLineItemsList.containskey(objlitm.Invoice__c)){
                     templist = mapIdAndLineItemsList.get(objlitm.Invoice__c);
                     templist.add(objlitm); 
                }
                else{
                     templist = new list<Line_Item__c>();
                     templist.add(objlitm);
                }
                mapIdAndLineItemsList.put(objlitm.Invoice__c,templist);
            }
        }
        list<Invoice__c>invoiceUpdateList = new list<Invoice__c>(); 
        for(id invId : mapIdAndLineItemsList.keyset() ){
            Invoice__c inv = new Invoice__c();
            inv.id = invId;
            inv.Total_of_Projects__c = mapIdAndLineItemsList.get(invId).size();
            invoiceUpdateList.add(inv);
        }
        if(invoiceUpdateList.size() > 0)
            update invoiceUpdateList;
    }// end of UpdateInvoice

    public void  deleteInvoice(list<Line_Item__c> lstInvoiceLineItem){
       set<Id> setInvoiceId = new set<Id>();
        for(Line_Item__c obj: lstInvoiceLineItem){
            setInvoiceId.add(obj.Invoice__c);
        }
        map<id,list<Line_Item__c>> mapIdAndLineItemsList = new map<id,list<Line_Item__c>>();
        map<id,Id> mapProjectIdAndLineItm = new Map<id,Id>();
        list<Line_Item__c> templist = new list<Line_Item__c>();
        list<Line_Item__c> litmList = [select id,
                                        HarvestProject__c,
                                        Invoice__c
                                        from Line_Item__c 
                                        where  Invoice__c IN: setInvoiceId
                                        AND id NOT IN :lstInvoiceLineItem];
        for(Line_Item__c objlitm: litmList){
            if(!mapProjectIdAndLineItm.containskey(objlitm.HarvestProject__c) && objlitm.HarvestProject__c != null){
                mapProjectIdAndLineItm.put(objlitm.HarvestProject__c,objlitm.id);
                    if(mapIdAndLineItemsList.containskey(objlitm.Invoice__c)){
                     templist = mapIdAndLineItemsList.get(objlitm.Invoice__c);
                     templist.add(objlitm);
                    }
                    else{
                        templist = new list<Line_Item__c>();
                        templist.add(objlitm);
                    }
                mapIdAndLineItemsList.put(objlitm.Invoice__c,templist);
            }
        }
        system.debug('****mapIdAndLineItemsList***'+mapIdAndLineItemsList);
        list<Invoice__c>invoiceUpdateList = new list<Invoice__c>();
        if(litmList.size() > 0){
            for(id invId : mapIdAndLineItemsList.keyset() ){
                Invoice__c inv = new Invoice__c();
                inv.id = invId;
                inv.Total_of_Projects__c = mapIdAndLineItemsList.get(invId).size();
                invoiceUpdateList.add(inv);
            }
        }
        else{
            for(Line_Item__c obj : lstInvoiceLineItem){
                Invoice__c inv = new Invoice__c();
                inv.id = obj.Invoice__c;
                inv.Total_of_Projects__c = 0;
                invoiceUpdateList.add(inv);
            }
        }
        system.debug('****invoiceUpdateList***'+invoiceUpdateList.size());
        if(invoiceUpdateList.size() > 0){
            update invoiceUpdateList;
        }
    
    }
    public decimal decimalValue(decimal decValue){
        return(decValue!=null?decValue:0);
  } 
}