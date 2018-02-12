/**
* Class LTG_CloneInsurance
*
* Class LTG_CloneInsurance for the LTG_Clone_Insurance VF page. This class implements the functionality
* to Clone Insurance  of Account.
*/
public class LTG_CloneInsurance
{
    public Account newAccount;
    public string accountName {get;set;}
    public LTG_CloneInsurance(ApexPages.StandardController controller) {
        this.newAccount= (Account)controller.getRecord();
    }
    
    public LTG_CloneInsurance() {
    }
    
    public PageReference LTG_CloneInsurance() {
        string currentPIId = ApexPages.CurrentPage().getparameters().get('id');
        newAccount =  [select id from Account where id =: currentPIId];
        System.debug('newAccount '+newAccount);        
          
        system.debug('accountName'+accountName);
        if(accountName != NULL) { 
        
            Id accountId = CloneInsuranceCompany.triggerInsurnaceCompanyClone(newAccount.Id,accountName);
            PageReference pageRef;
            pageRef= new PageReference('/'+accountId);
            pageRef.setRedirect(true);
            return pageRef;  
        }
        return null;
    }
}