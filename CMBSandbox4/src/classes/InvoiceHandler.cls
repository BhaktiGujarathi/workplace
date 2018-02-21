/* Description - Handler Class for InvoiceTrigger
 *  
 * Created By - Sneha P.
 *  
 * Date  - 03/01/2014
 */

public with sharing class InvoiceHandler {

    public static final String STATUS_SENT = 'Sent';    
    public static final String STATUS_PAID = 'Paid';
    public static final String STATUS_CANCELED = 'Canceled';
    public static final String STATUS_PARTIALLYPAID = 'Sent - Partially Paid';
    
     /*Fuction called on Before Delete of Invoice, if Override checkbox is checked then only 
     invoice gets deleted
     */
    public void onBeforeDelete(map<Id,Invoice__c> invoiceMap) {
        
        list<Invoice__c> InvoiceList = invoiceMap.values();
        set<Id> setDelInvoice = new set<Id>();  
        
        for(Invoice__c objInvoice : InvoiceList)
        {
            setDelInvoice.add(objInvoice.Id);
        }
        list<Line_Item__c> LineItemList = [Select Id from Line_Item__c 
                                           where Invoice__c IN: setDelInvoice ]; 
                                           
        for(Invoice__c objInvoice:InvoiceList){
            if(objInvoice.Override__c == false && LineItemList.size() > 0)
        
            objInvoice.addError('This invoice can not be deleted'); 
            else{
                    setDelInvoice.add(objInvoice.Id);
            }
        }           
        
        //Delete the Child records to fire its trigger
        if(LineItemList.size() > 0)
            delete LineItemList;    
    }
    
    
    /* Function called on After update of Invoice, if the status is changed to Sent then Check the field 
     * 'Invoice Sent to Client' on Time Entries
     */
    public void onAfterUpdate(map<Id,Invoice__c> oldInvoiceMap, list<Invoice__c> invoiceList){
        set<Id> setSentInvoice = new set<Id>(); 
        set<Id> setTimeEntry = new set<Id>();
        
        
        map<Id,HarvestTimeEntry__c> updatedTimeEntryMap = new map<Id,HarvestTimeEntry__c>();
        
        for(Invoice__c  invoice: invoiceList){
            //If the status is changed and is 'Sent' 
            if((invoice.Status__c == STATUS_SENT || invoice.Status__c == STATUS_PAID || invoice.Status__c == STATUS_CANCELED || invoice.Status__c == STATUS_PARTIALLYPAID) && invoice.Status__c != oldInvoiceMap.get(invoice.Id).Status__c){
                //fetch all the Time Entries related to invoice for that query all line items and check their TE
                setSentInvoice.add(invoice.Id);     
            }
        }
        
        //Query all line item of the Sent Invoice to get its related Time Entry
        for(Line_Item__c lineItem  : [Select Time_Entry__r.Invoice_Sent_to_Client__c,
                                             Time_Entry__r.Id,
                                             Time_Entry__c, 
                                             Invoice__c 
                                      From Line_Item__c where Invoice__c IN: setSentInvoice]){
            //Update the TimeEntry to Invoice Sent to Client
            if(lineItem.Time_Entry__c != null){
                setTimeEntry.add(lineItem.Time_Entry__c);
                updatedTimeEntryMap.put(lineItem.Time_Entry__c,new HarvestTimeEntry__c(ID = lineItem.Time_Entry__c,
                                                                Invoice_Sent_to_Client__c = true ));
            }
        }
        //Also query the Time Entry which are merged
        for(HarvestTimeEntry__c timeEntry : [Select Id,Invoice_Sent_to_Client__c,
                                                    Invoiced_Time_Entry__c 
                                            from HarvestTimeEntry__c 
                                            where Invoiced_Time_Entry__c IN : setTimeEntry]){
                                
            updatedTimeEntryMap.put(timeEntry.Id, new HarvestTimeEntry__c(ID = timeEntry.Id,
                                                            Invoice_Sent_to_Client__c = true ));                            
        }
        
        try{
            if(updatedTimeEntryMap.size() > 0)
                update updatedTimeEntryMap.values();
        }catch(Exception e){
            invoiceList[0].addError(e.getMessage());    
        }
    }
}