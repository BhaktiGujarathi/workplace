/*
* Version       Date             Author         Description
*   1.1         04/06/2016       Ashwini S      For creating invoice line item from credit line item
*/
public with sharing class CreditLineTriggerHandlerService {

    // before create or update populate project from invoice
    public void updateCreditLineItem(list<Credit_Line_Item__c> newLineItemList){
        set<id> invoiceSet= new set<id>();//id of invoice from credit line item
        map<id,id> invoiceProject= new map<id,id>();// map of invoice id and its project id
        map<id,id> invoiceOpportunity= new map<id,id>();// map of invoice id and its opportrunity
        list<Invoice__c> invoiceList= new list<Invoice__c>();
        
        for (Credit_Line_Item__c creditLineItem:newLineItemList){
            if(creditLineItem.Invoice__c!=null){
                invoiceSet.add(creditLineItem.Invoice__c);
            }
        }
        // mapping project and opportunity
        invoiceList =[Select Id, 
                             Project_Harvest__c,
                             Opportunity__c 
                     From Invoice__c where Id in :invoiceSet];
        for (Invoice__c invoice:invoiceList){
            invoiceProject.put(invoice.Id,invoice.Project_Harvest__c);
            invoiceOpportunity.put(invoice.Id,invoice.Opportunity__c);
        }
        
        //updating project and opportunity of credit line item
        for (Credit_Line_Item__c creditLineItem:newLineItemList){
            if(creditLineItem.Invoice__c!=null){
                 creditLineItem.Project__c=invoiceProject.get(creditLineItem.Invoice__c);
                 creditLineItem.Opportunity__c=invoiceOpportunity.get(creditLineItem.Invoice__c);
            } 
        }
    }

     //after create and update of credit line item
     public void createInvoiceLineItem(map<Id,Credit_Line_Item__c> newLineItemMap,
                                                      map<Id,Credit_Line_Item__c> oldLineItemMap){
        //
        list <Line_Item__c> invoiceLineItemtoCreate= new list<Line_Item__c>();
        //map <Id,HarvestProject__c> InvoiceProjectmap=new map<Id,HarvestProject__c>(); for later use fetching rate,fee and other value 
        
        for (Credit_Line_Item__c creditLineItem:newLineItemMap.Values()){
            if(creditLineItem.Invoice__c!=null){
                 Line_Item__c invoicelineitem = new Line_Item__c();
            // logic starts here
            // if hours are credited
                if(creditLineItem.Hours_Credited__c!=null && creditLineItem.Hours_Credited__c!=0){
                    invoicelineitem.Credit_Hrs__c=creditLineItem.Hours_Credited__c;
                    invoicelineitem.Credit__c=0;
                }
                // if amount is credited
                else if(creditLineItem.Amount_Credited__c!=null && 
                                                            creditLineItem.Amount_Credited__c!=0){
                    invoicelineitem.Credit__c=creditLineItem.Amount_Credited__c;
                    invoicelineitem.Credit_Hrs__c=0;
                }//if
                
                if (creditLineItem.Invoice_Line_Item__c!=null){
                    invoicelineitem.id=creditLineItem.Invoice_Line_Item__c;
                }
                
                invoicelineitem.Hours_Num__c=0;
                invoicelineitem.Credit_Reason__c = creditLineItem.Credit_Reason__c;
                invoicelineitem.Opportunity__c = creditLineItem.Opportunity__c;
                invoicelineitem.Credit_Line_Item__c = creditLineItem.id;
                invoicelineitem.Invoice__c = creditLineItem.Invoice__c;
                invoiceLineItemtoCreate.add(invoicelineitem);
            
            }//if
        }//for
        
        // updating credit line with newly generated invoice line item 
        List<Credit_Line_Item__c> newCreditItemList = new List<Credit_Line_Item__c>();
        if (!invoiceLineItemtoCreate.isEmpty()){
             upsert(invoiceLineItemtoCreate);
              for (Line_Item__c lineItemObj : invoiceLineItemtoCreate) 
              {
                  Credit_Line_Item__c creditLineItemObj = new Credit_Line_Item__c(); 
                  creditLineItemObj.id= lineItemObj.Credit_Line_Item__c;
                  creditLineItemObj.Invoice_Line_Item__c = lineItemObj.Id;
                  newCreditItemList.add(creditLineItemObj);
              }
              if(!newCreditItemList.isEmpty()) {
                  update newCreditItemList;
              }
        }
     }
     
     // on deletion of credit line item  invoice line item is deleted 
     public void deleteInvoiceLineItem(map<Id,Credit_Line_Item__c> oldLineItemMap){
          list <Line_Item__c> invoiceLineItemtoDelete= new list<Line_Item__c>();
          for (Credit_Line_Item__c creditLineItem:oldLineItemMap.Values()){
               Line_Item__c invoicelineitem = new Line_Item__c();
               invoicelineitem.id=creditLineItem.Invoice_Line_Item__c;
               invoiceLineItemtoDelete.add(invoicelineitem);
          }
          if (!invoiceLineItemtoDelete.isEmpty()){
             delete invoiceLineItemtoDelete;
          }
     }


// updating project  after insertion updationa and delete
     public void updateHarvestProject(map<Id,Credit_Line_Item__c> newLineItemMap, 
                                                map<Id,Credit_Line_Item__c> oldLineItemMap ){

        decimal creditHoursthisMonth=0;
        decimal creditHoursPreviousMonth=0;
        decimal creditHours=0;
        list<HarvestProject__c> projectToUpdate = new list<HarvestProject__c>();
        //Adding related projects to set
        set<Id> projectSet= new set<Id>();
        if (newLineItemMap!= null){
            for(Credit_Line_Item__c invoiceLine: newLineItemMap.Values()){
                if(invoiceLine.Project__c != null){
                    projectSet.add(invoiceLine.Project__c); 
                }
            }
        }// in case of project change on update or delete
        if (oldLineItemMap!= null){
            for(Credit_Line_Item__c invoiceLine: oldLineItemMap.Values()){
                if(invoiceLine.Project__c != null){
                    projectSet.add(invoiceLine.Project__c); 
                }
            }
        }
        // list of projects for roll up 
        list<HarvestProject__c> lstProj=[Select Id,
                                    Hours_Credited__c,
                                    Hours_Credited_This_Month__c,
                                    Hours_Credited_Previous_Month__c,
                                    (Select Id,
                                        Hours_Credited__c,
                                        Credited_Date__c
                                        FROM Credit_Line_Items__r)
                                     FROM HarvestProject__c where Id IN :projectSet];
       
        if(lstProj != null && !lstProj.isEmpty()){  
            
            for(HarvestProject__c objProj: lstProj){
                creditHoursthisMonth=0;
                creditHours=0;
                creditHoursPreviousMonth=0;
                
                if (objProj.Invoice_Line_Items__r!=null){
                    
                    for (Credit_Line_Item__c objLineItem:objProj.Credit_Line_Items__r ){
                        creditHours=creditHours+ decimalValue(objLineItem.Hours_Credited__c);
                        if (objLineItem.Credited_Date__c!=null && objLineItem.Credited_Date__c.month()==System.today().month()){
                            creditHoursthisMonth=creditHoursthisMonth+decimalValue(objLineItem.Hours_Credited__c);
                        }//end if 
                        else if (objLineItem.Credited_Date__c!=null && objLineItem.Credited_Date__c.month()==(System.today().month()-1)){
                            creditHoursPreviousMonth=creditHoursPreviousMonth+decimalValue(objLineItem.Hours_Credited__c);
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
     }
     
     public decimal decimalValue(decimal decValue){
        return(decValue!=null?decValue:0);
  } 
}