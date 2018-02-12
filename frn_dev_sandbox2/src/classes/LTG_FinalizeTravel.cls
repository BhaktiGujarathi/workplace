/**
* Class LTG_FinalizeTravel
*
* Class LTG_FinalizeTravel for the LTG_Finalize_Travel VF page. This class implements the functionality
* to Finalize Travel of Opportunity.
*/
public class LTG_FinalizeTravel
{
    public Opportunity newOpportunity;
    public LTG_FinalizeTravel(ApexPages.StandardController controller) {
        this.newOpportunity= (Opportunity)controller.getRecord();
    }
    
    public LTG_FinalizeTravel() {
    }
    
    public PageReference LTG_FinalizeTravel() {
        string currentPIId = ApexPages.CurrentPage().getparameters().get('id');
        newOpportunity =  [select id,RAM_Status__c,name,Final_Quote_Selected__c,stagename from Opportunity where id =: currentPIId];
        System.debug('newOpportunity '+newOpportunity);
        boolean isLockedFlag = RecordLockUtility.checkIsLocked(newOpportunity.Id);
        System.debug('<<<<<<<<<<<<<< isLockedFlag <<<<<<<<<<<<<<<<'+isLockedFlag);            

        if(!isLockedFlag)
        {            
            if(newOpportunity.Final_Quote_Selected__c != null){
                list<QuoteLineItem> lstQLI = new list<QuoteLineItem>();
                lstQLI = [SELECT Id,UnitPrice from QuoteLineItem where QuoteId =: newOpportunity.Final_Quote_Selected__c];
                decimal totalUnitPrice = 0.00;
                decimal totalBal = 0.00;
                decimal totalPymtAmt = 0.00;
                list<Id> SelectedIds = new list<Id>();
                boolean first = true;
                for(integer i=0; i< lstQLI.size(); i++) {
                    if(first){
                        SelectedIds.add(lstQLI[i].Id);
                        first = false;
                    }else{
                        SelectedIds.add(lstQLI[i].Id);
                    }
                    if(lstQLI[i].UnitPrice!=null){
                        totalUnitPrice += lstQLI[i].UnitPrice;
                    }
                }
                
                if(SelectedIds.size()>0){
                    list<Future_Payment__c> lstFuturePayments = new list<Future_Payment__c>();
                    lstFuturePayments = [SELECT Id,Balance_to_Collect__c from Future_Payment__c where Quote__c=: newOpportunity.Final_Quote_Selected__c];
                    for(integer i=0; i< lstFuturePayments.size(); i++) {
                        if(lstFuturePayments[i].Balance_to_Collect__c!=null)
                            totalBal += lstFuturePayments[i].Balance_to_Collect__c;
                        }
                    
                    list<Payment__c> lstPayments = new list<Payment__c>();
                    lstPayments = [SELECT Id,Payment_Amount__c,Treatment_Cost_Line_Item__c from Payment__c where Treatment_Cost_Line_Item__c IN: SelectedIds ORDER BY CreatedDate DESC];
                    
                    list<Id> tclI = new list<Id>();
                    boolean flag = true;
                    for(integer i=0; i< lstPayments.size(); i++) {
                        if(lstPayments[i].Payment_Amount__c!=null){
                            
                            if(!tclI.contains(lstPayments[i].Treatment_Cost_Line_Item__c)){
                                if(flag){
                                    tclI.add(lstPayments[i].Treatment_Cost_Line_Item__c);
                                    flag = false;
                                }else{
                                    tclI.add(lstPayments[i].Treatment_Cost_Line_Item__c);
                                }
                                totalPymtAmt += lstPayments[i].Payment_Amount__c;
                            }
                        }
                    
                    }
                }
                
                decimal totalUnitPrice1 = totalUnitPrice.setScale(2, RoundingMode.HALF_UP);
                decimal totalBal1 = totalBal.setScale(2, RoundingMode.HALF_UP);
                decimal totalPymtAmt1 = totalPymtAmt.setScale(2, RoundingMode.HALF_UP);
                
                boolean utilValidationFlag = UtilValidation.isEstimateBalance(totalUnitPrice1,totalBal1,totalPymtAmt1);
                if(utilValidationFlag != true)
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Final Estimate is not balanced'));
                    return null;
                }else if(newOpportunity.RAM_Status__c == 'Intervention Requested' || newOpportunity.RAM_Status__c =='Intervention Failed'){
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Unable to process request as RAM Status is incorrect'));
                    return null;
                }
                else
                {
                    PageReference pageRef;
                    pageRef= new PageReference('/apex/GenerateNAC?id='+newOpportunity.Id);                    
                    pageRef.setRedirect(true);
                    return pageRef;
                }
            }else{
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please select an Estimate as final'));
                return null;
            }
        }
        else
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Record is locked.'));
            System.debug('<<<<<<<<<<<<<< Record is locked <<<<<<<<<<<<<<<<'+isLockedFlag);
            return null;
        }
    }
}