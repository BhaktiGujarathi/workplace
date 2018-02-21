public class CaseListController {

    public list<case> lstCase                 {get; set;}
    public String strBaseURL                  {get; set;}
    public list<CaseWrapper> lstCseWrapper    {get; set;}
    public CaseListController(){
        lstCase = new list<Case>();
        lstCseWrapper =  new list<CaseWrapper>();
        strBaseURL = System.URL.getSalesforceBaseUrl().toExternalForm();
        system.debug('strBaseURL'+strBaseURL);
        
        fetchCases();
    }
    
    
    public void fetchCases(){
    	Id customerAccountId;
    	List<User> lstUser =  [ SELECT  ContactId,
                                        Contact.AccountId
                                FROM    User
                                WHERE   Id = :UserInfo.getUserId()];
        if (!lstUser.isEmpty()) {
            customerAccountId = lstUser[0].ContactId == NULL || lstUser[0].Contact.AccountId == NULL
                                    ? '0017E00000aqcZm' : lstUser[0].ContactId;
        }
        lstCase = [SELECT id,
                          CaseNumber,
                          CreatedDate,
                          Type,
                          Description,
                          Contact.name,
                          Account.name,
                          Booking_Unit__r.name,
                          Account.AnnualRevenue,
                          AccountId,
                          ContactId,
                          Origin,
                          Priority,
                          Status
                     FROM Case 
                    WHERE Status != 'Closed' 
                      AND AccountId =: customerAccountId  Limit 6];
        list<CRE_Allocation_Customer_Type_Setting__mdt> lstCREMetadata = [SELECT DeveloperName, 
	                                                                             Maximum_Value__c,
						                                                         Minimum_Value__c,
						                                                         Is_Max__c    
						                                                    FROM CRE_Allocation_Customer_Type_Setting__mdt];
	    for(Case objCase : lstCase){
	       CaseWrapper objCseWrapper = new CaseWrapper();
	       objCseWrapper.objCase = objCase;
	       for(CRE_Allocation_Customer_Type_Setting__mdt objMdt : lstCREMetadata) {
	           if(objCase.AccountId != null 
	           && objCase.Account.AnnualRevenue != null){
	               if(objCase.Account.AnnualRevenue >= objMdt.Minimum_Value__c 
	               && objCase.Account.AnnualRevenue <= objMdt.Maximum_Value__c){
	                   objCseWrapper.strtype = objMdt.DeveloperName;
	               }
	               system.debug('objCase.Account.AnnualRevenue'+objCase.Account.AnnualRevenue);
	               system.debug('objCase.Account.AnnualRevenue'+objMdt.Is_Max__c);
                   
	               if(objCase.Account.AnnualRevenue >= objMdt.Minimum_Value__c
	               && objMdt.Is_Max__c == true){
                       objCseWrapper.strtype = objMdt.DeveloperName;
                       system.debug('objCase.Account.AnnualRevenue'+objCase.Account.AnnualRevenue);
                   }
	           }    
	       }
           lstCseWrapper.add(objCseWrapper);
        }
    }
    
    public class CaseWrapper{
        public Case objCase         {get;set;}
        public string strtype       {get;set;}
        public CaseWrapper(){
            objCase = new Case();
            strtype ='';
        }
    }
}