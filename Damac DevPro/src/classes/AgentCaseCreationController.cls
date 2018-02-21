/*
* Name : Pavithra Gajendra
* Date : 02/08/2017
* Purpose : Controller for case creation by agent 
* Company : NSI Gulf
* 
*/
public without sharing class AgentCaseCreationController {

    public Case__c newCase {get;set;}
    public String agentName{get;set;}
    public List<SelectOption> caseSubjectList {get; set;}
    public Boolean agentFieldHide{get;set;}
    private Set<String> subjectValues;


    /*
    * Controller to Initialise Case Creation Page
    */
    public AgentCaseCreationController(ApexPages.Standardcontroller stdController) {
        newCase = (Case__c)stdController.getRecord();
        Id accountIdOfAgent = UtilityQueryManager.getAccountId();
        String firstName = (UserInfo.getFirstName() != null)?UserInfo.getFirstName():'';
        String lastName = (UserInfo.getLastName() != null)?UserInfo.getLastName():'';
        agentName = firstName+' '+lastName;
        caseSubjectList = new List<SelectOption>();
        Account accountDetails = [SELECT Id,Agency_Tier__c,Agency_Tier_Q1__c,Agency_Tier_Q2__c,Agency_Tier_Q3__c,Agency_Tier_Q4__c FROM Account WHERE Id=:accountIdOfAgent];
        String agencyTier ; 
        agentFieldHide = false ; 
        
             if(accountDetails.Agency_Tier_Q4__c=='PLATINUM' || accountDetails.Agency_Tier_Q1__c=='PLATINUM' || accountDetails.Agency_Tier_Q2__c=='PLATINUM' ||  accountDetails.Agency_Tier_Q3__c=='PLATINUM'){
            	agencyTier = 'PLATINUM' ;
             }else if(accountDetails.Agency_Tier_Q4__c=='GOLD' || accountDetails.Agency_Tier_Q1__c=='GOLD' || accountDetails.Agency_Tier_Q2__c=='GOLD' ||  accountDetails.Agency_Tier_Q3__c=='GOLD'){
            	agencyTier = 'GOLD' ;
             }else if(accountDetails.Agency_Tier_Q4__c=='SILVER' || accountDetails.Agency_Tier_Q1__c=='SILVER' || accountDetails.Agency_Tier_Q2__c=='SILVER' ||  accountDetails.Agency_Tier_Q3__c=='SILVER'){
            	agencyTier = 'SILVER' ;
            	agentFieldHide = true ; 
             }else{
            	agencyTier = 'N/A' ;
            	agentFieldHide = true ;
             }
             
            if(agencyTier !=null && agencyTier!=''){
                System.debug('agentTier test--- '+agencyTier);
                Agency_Tier_Case_Status__c agentTier =  Agency_Tier_Case_Status__c.getValues(agencyTier);
                subjectValues = new Set<String>();
                if(agentTier!=null){
                    System.debug('agentTier values--- '+agentTier);
                    subjectValues =  DamacUtility.splitMutliSelect(agentTier.Case_Status__c);
                } 
                createDropdownValues();
             
            }       
    }
    
    private void createDropdownValues(){
        subjectValues.addAll(DamacUtility.splitMutliSelect(LABEL.Support_Subject_Values));
        caseSubjectList.add(new SelectOption('', '--None--'));  
        for(String subVal : subjectValues){
            caseSubjectList.add(new SelectOption(subVal.trim(), subVal.trim()));  
        }
    }


    /*
    * Save Case from Creation Page
    */
    public PageReference saveCase(){
        System.debug('Save Case '+newCase);

        if(!validateCaseFields())
            return null;

        try{

          newCase.Case_Subject__c = newCase.Case_Subject__c.trim();
          insert newCase ;
            PageReference newPG = new PageReference('/'+newCase.id);
            newPG.setRedirect(true);
            return newPG ;  
        }
        catch(Exception ex){
           // ApexPages.addMessages(new ApexPages.Message(ApexPages.Severity.ERROR,ex.getMessage()));
        }
        return null ;
    }

    public boolean validateCaseFields(){

        String subVal = newCase.Case_Subject__c;

        System.debug('Entered Validation');

        if(String.isBlank(subVal)){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please select Support Subject.'));
            return false;
        }
        else if(String.isBlank(newCase.Case_Description__c)){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please fill Support Description.'));
            return false;
        }
        else if(subVal.trim().equalsIgnoreCase('request for site viewing')){
            return validateRequestedDateTime();
        }
        else if(subVal.trim().equalsIgnoreCase('book a hotel')){
            boolean retVal = true;
            retVal = validateRequestedDateTime();

            if(null == newCase.No_of_Nights__c){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please fill No. of Nights.'));
                retVal = retVal && false;
            }

            return retVal;
        } 
        else if(subVal.trim().equalsIgnoreCase('book a luxury car')){
            boolean retVal = true;
            retVal = validateRequestedDateTime();

            if(String.isBlank(newCase.Pick_Up_Location__c)){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please fill Pick Up Location.'));
                retVal = retVal && false;
            }

            if(String.isBlank(newCase.Drop_Off_Location__c)){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please fill Drop Off Location.'));
                retVal = retVal && false;
            }

            return retVal;
        }
        else if(subVal.trim().equalsIgnoreCase('book a meeting room')){
            boolean retVal = true;
            retVal = validateRequestedDateTime();

            if(String.isBlank(newCase.Sales_Office__c)){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please fill Sales Office.'));
                retVal = retVal && false;
            }

            return retVal;

        }
        else if(subVal.trim().equalsIgnoreCase('request for training') || subVal.equalsIgnoreCase('request for brochures')){
            boolean retVal = true;
            retVal = validateRequestedDateTime();

            if(String.isBlank(newCase.Project_Name__c)){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please fill Project Name.'));
                retVal = retVal && false;
            }

            return retVal;
        }
         else if(subVal.trim().equalsIgnoreCase('query on unit commission')){
            
            boolean retVal = true;

            System.debug('**Query on Unit');
           
            if(String.isBlank(newCase.Unit_Number__c)){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please fill Unit Number.'));
                retVal = retVal && false;
            }

            if(String.isBlank(newCase.Inquiry_Number__c)){
                ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please fill Related CIL.'));
                retVal = retVal && false;
            }

            System.debug('**Query on Unit retVal'+retVal );

            return retVal;
        }

        return true;
    }

    public boolean validateRequestedDateTime(){

        if(null == newCase.Date_Time__c){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Please fill Request Date & Time.'));
            return false;
        }
        else if(newCase.Date_Time__c<=System.now()){
            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR,'Request Date & Time field must be a future date.'));
            return false;
        }

        return true;
    }

}