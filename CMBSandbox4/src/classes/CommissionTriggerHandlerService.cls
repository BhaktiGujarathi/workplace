/*
* Version       Date             Author         Description
*   1.0         02/10/2015       Ashwini S      For Roll up on Invoice for AmountPaid on Commission 
*   2.0         30/11/2015       Ashwini S      For Opportunity update from Commission
*/

public with sharing class CommissionTriggerHandlerService {
    
    public CommissionTriggerHandlerService(){}
//this roll up will update invoice
    public void InvoiceRollup(map<Id, Commission__c> mapNewCommissionList, map<Id, Commission__c> mapOldCommissionList){ 
        set<Id> setInvoice = new set<Id>();// to  fetch  related account
        decimal totalAmountPaid = 0;// to count unused estimated hours
        list<Invoice__c> invoiceListResult = new list<Invoice__c>(); // list of account that will be updated
        if (mapNewCommissionList!= null){
            for(Commission__c commission: mapNewCommissionList.Values()){
                if(commission.Invoice__c != null){
                    setInvoice.add(commission.Invoice__c); 
                }
            }
        }// in case of Invoice change on update
        if (mapOldCommissionList!= null){
            for(Commission__c commission: mapOldCommissionList.Values()){
                if(commission.Invoice__c != null){
                    setInvoice.add(commission.Invoice__c); 
                }
            }
        }
        list<Invoice__c> lstinvoice = [Select Id,
                                        Total_Commissions_Paid__c,
                                        (Select Invoice__c,
                                        Amount_Paid__c 
                                        From Commissions__r)
                                    From Invoice__c 
                                    Where Id IN : setInvoice];
system.debug('*****Issue update'+lstinvoice);
    if(lstinvoice != null && !lstinvoice.isEmpty()){    
       for(Invoice__c objInvoice: lstinvoice){ 
            totalAmountPaid = 0;
           for(Commission__c objcommission: objInvoice.Commissions__r){
                totalAmountPaid = totalAmountPaid + decimalValue(objcommission.Amount_Paid__c);
            }
            objInvoice.Total_Commissions_Paid__c = totalAmountPaid;
            invoiceListResult.add(objInvoice);
        }
        if(!invoiceListResult.isEmpty()){
            update invoiceListResult;
        }
    }
  }
  
  public void OpportunityUpdate(map<Id, Commission__c> mapNewCommissionList, map<Id, Commission__c> mapOldCommissionList){
   set<Id> setOppId = new set<Id>();// to  fetch  related opportunity
        decimal totalcommissionPaid = 0;// to count commission paid
        decimal totaloverridePaid=0;// to count overide paid
        list<Opportunity> opportunityListResult = new list<Opportunity>(); // list of opportunity that will be updated
        //for insert and update
        if (mapNewCommissionList!= null){
            for(Commission__c commission: mapNewCommissionList.Values()){
                if(commission.Opportunity__c!= null){
                    setOppId.add(commission.Opportunity__c); 
                }
            }
        }// for update and delete
        if (mapOldCommissionList!= null){
            for(Commission__c commission: mapOldCommissionList.Values()){
                if(commission.Opportunity__c!= null){
                    setOppId.add(commission.Opportunity__c); 
                }
            }
        }
        list<Opportunity> oppList=[Select o.Total_Override_Paid__c, 
                                          o.Total_Commission_Paid__c,
                                          o.Id,
                                          (Select Status__c,
                                                        Amount_Paid__c, 
                                                        Type__c 
                                                  From Commissions__r) 
                                          From Opportunity o
                                          where o.Id in : setOppId];
                                          
        if(oppList != null && !oppList.isEmpty()){
           for(Opportunity objOpp: oppList){
               totalcommissionPaid=0;
               totaloverridePaid=0;
               for(Commission__c objcommission: objOpp.Commissions__r){ 
                   if (objcommission.Status__c=='Paid' && objcommission.Type__c<>'Override'){
                       totalcommissionPaid=totalcommissionPaid+decimalValue(objcommission.Amount_Paid__c);
                   }else if(objcommission.Status__c=='Paid' && objcommission.Type__c=='Override')
                   {
                       totaloverridePaid=totaloverridePaid+decimalValue(objcommission.Amount_Paid__c);
                   }
               }//end commission loop
               objOpp.Total_Commission_Paid__c=totalcommissionPaid;
               objOpp.Total_Override_Paid__c=totaloverridePaid;
               opportunityListResult.add(objOpp);
           }//end opportunity loop
           if(!opportunityListResult.isEmpty()){
            update opportunityListResult;
           }//end result
        }//end if 
  }
  
  //to convert null value into decimal
  public decimal decimalValue(decimal decValue){
        return(decValue!=null?decValue:0);
  } 
}