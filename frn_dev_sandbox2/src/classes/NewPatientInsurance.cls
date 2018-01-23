public with sharing class NewPatientInsurance {
 
 Id opportunityId;
 public PageReference NewPatientInsuranceMethod() {
  PageReference pageRef;
  opportunityId = ApexPages.CurrentPage().getparameters().get('id');
  pageRef= new PageReference('/apex/NewPatientInsPage?scontrolCaching=1&id='+opportunityId);
  pageRef.setRedirect(true);
        return pageRef;
 }
 
}