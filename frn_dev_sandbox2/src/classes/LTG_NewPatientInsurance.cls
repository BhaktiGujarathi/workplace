public with sharing class LTG_NewPatientInsurance {
 
 Id opportunityId;
 
 public LTG_NewPatientInsurance(ApexPages.StandardController controller) {
 }
 public PageReference NewPatientInsuranceMethod() {
  PageReference pageRef;
  opportunityId = ApexPages.CurrentPage().getparameters().get('id');
  pageRef= new PageReference('/apex/NewPatientInsPage?scontrolCaching=1&id='+opportunityId);
  pageRef.setRedirect(true);
  return pageRef;
 }
 
}