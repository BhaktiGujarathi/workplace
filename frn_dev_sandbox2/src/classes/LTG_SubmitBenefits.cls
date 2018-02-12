/**
* Class LTG_SubmitBenefits
*
* Class LTG_SubmitBenefits for the LTG_Submit_Benefits VF page. This class implements the functionality
* to Submit Benefits of opportunity.
*/
public without sharing class LTG_SubmitBenefits
{
    public Opportunity newOpportunity {get;set;}
    String queryStr;
    public LTG_SubmitBenefits(ApexPages.StandardController controller) {
        String message = '' + ApexPages.CurrentPage().GetParameters().Get('message');
        String pageHeaderReferer = ApexPages.currentPage().getHeaders().get('Referer');

        // Use the referrer parameter to only show the message when coming from Page 1
        if(pageHeaderReferer != null && pageHeaderReferer.containsIgnoreCase('LTG_Submit_Benefits') && message != 'null')
        {
               ApexPages.AddMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM, message));
        }
    }

    public LTG_SubmitBenefits() {
    }

    public PageReference SubmitBenefits() {
        string currentOpportunityId = ApexPages.CurrentPage().getparameters().get('id');
        newOpportunity =  [select id,name from Opportunity where id =: currentOpportunityId];
        boolean isLockedFlag = RecordLockUtility.checkIsLocked(newOpportunity.Id);
        System.debug('<<<<<<<<<<<<<< isLockedFlag <<<<<<<<<<<<<<<<'+isLockedFlag);
        boolean isVOBExpired;

        if(!isLockedFlag)
        {
            list<Patient_Insurance__c> lstPatientInsuranceRecords= new list<Patient_Insurance__c>();
            lstPatientInsuranceRecords = [Select Id,VOB_status__c From Patient_Insurance__c Where Opportunity__c =: newOpportunity.Id];
            isVOBExpired = true;

            if (lstPatientInsuranceRecords.size() > 0)
            {
                for (Patient_Insurance__c objPatientInsurance : lstPatientInsuranceRecords) {
                    isVOBExpired = isVOBExpired && (objPatientInsurance.VOB_status__c == 'VOB over 10 days');
                }

                if (isVOBExpired)
                {
                    ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Verification for this insurance record is greater than 10 days old and a new record must be created.'));
                    return null;
                }
                else
                {
                    string nullFields = OpportunityFieldValidationService.validateForNullValue(currentOpportunityId);

                    if (nullFields == null || nullFields == '') {
                    string oppid = newOpportunity.Id;
                    string redirect = OppShareContr.shareOpportunity(oppid);
                        if (redirect == 'success')
                        {
                            list<opportunity> lstOpportunity = new list<opportunity>();
                            opportunity objOppotunity = new Opportunity();
                            objOppotunity.id = newOpportunity.Id;
                            objOppotunity.StageName = 'Benefits Submitted';
                            objOppotunity.Benefits_Status__c = 'Benefits Submitted';
                            lstOpportunity.add(objOppotunity);
                            try{
                                update lstOpportunity;
                                system.debug('lstOpportunity'+lstOpportunity);
                            } catch (Exception e) {
                                system.debug('DML failed --- Error'+e);
                                return null;
                            }

                            cloneOpportunity.UpdatePatientForOpp(newOpportunity.Id);
                            PageReference pageRef;
                            pageRef= new PageReference('/'+newOpportunity.Id);
                            system.debug('pageRef'+pageRef);
                            pageRef.getParameters().put('message', 'Benefits submitted successfully');
                            pageRef.setRedirect(true);
                            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.CONFIRM,'Benefits submitted successfully'));
                            return pageRef;
                        }
                    }
                    else
                    {
                        ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'The following fields are required before the benefits can be submitted:'+nullFields));
                        return null;
                    }
                }
            }
            else
            {
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Opportunity should have atleast one patient insurance record.'));
                return null;
            }
            return null;
        }
        else
        {
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Record is locked.'));
            System.debug('<<<<<<<<<<<<<< Record is locked <<<<<<<<<<<<<<<<'+isLockedFlag);
            return null;
        }
    }
}