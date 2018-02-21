/* Class Functionality : Will provide excess amount from IPMS call
 * Revision History: 
 * Version     Author                Date             Description.
 * 1.1         Swapnil Gholap        04/08/2017       Initial Draft
 
 */

public class CustomerRefundApproval{
    public Service_Request__c SR {get;set;}
    public decimal excessAmount {get;set;}
      
    public CustomerRefundApproval(ApexPages.StandardController stdController) {
        this.SR= (Service_Request__c)stdController.getRecord();
        SR = [Select id,name,Excess_Amount__c from Service_Request__c  where id =:SR.id ];
        excessAmount = 0;
    }
    
    // will get excess amount from IPMS 
    public void callOut(){
        excessAmount = SR.Excess_Amount__c ;
    }

   

}