@isTest
private class PreventProgramMasterOperationTest {

    public static ProgramMaster__c programMasterInstance;
    public static McaApp__Offer__c offer;
    public static Opportunity opp ;
    public static McaApp__Submission__c submission;
    
    public static void createProgramMaster() {

        programMasterInstance = new ProgramMaster__c ();
        programMasterInstance.Active__c = false;
        programMasterInstance.Name = 'TestClassRecord';
        programMasterInstance.Term__c = 5;
        insert programMasterInstance;
        
        system.assertEquals(true, programMasterInstance.Id != null);
    }
    
    public static void createOpportunity() {

        opp = new Opportunity();
        opp.Name = 'Test Opportunity';
        opp.StageName = 'Prospecting';
        opp.CloseDate = date.today();
        system.debug('*** opp *****' + opp.Id);
        insert opp;
        
        system.assertEquals(true, opp.Id != null);
    }
    
    public static void createsubmission() {

        submission = new McaApp__Submission__c(); 
        submission.McaApp__Opportunity__c = opp.Id;
        submission.McaApp__Status__c = 'Approved';
        system.debug('*** createsubmission *****' + submission);
        insert submission;
        
        system.assertEquals(true, submission.Id != null);
    }
    
     public static void createOffer() {

        offer = new McaApp__Offer__c();  
        offer.McaApp__Deal_Type__c = 'ACH';
        offer.McaApp__Submission__c = submission.Id;
        offer.McaApp__Opportunity__c = opp.Id;
        offer.Program_Master__c = programMasterInstance.Id;
        system.debug('*** offer *****' + offer);
        insert offer;
        
        system.assertEquals(true, offer.Id != null);
    }
    
    public static void activatedProgram() {
     
        programMasterInstance.Active__c = true;
        programMasterInstance.Term__c = 3;
        update programMasterInstance;
    }
   
    public static testMethod void updateProgramMaster() {
     
        createProgramMaster();
        createOpportunity();
        createsubmission();
        createOffer();
        activatedProgram();
        
        try {            
     
            programMasterInstance.Active__c = true;
            programMasterInstance.Term__c = 1;
            update programMasterInstance;
        }
        catch(Exception e) {}
    }
    
    public static testMethod void deleteProgramMaster() {

        createProgramMaster();
        createOpportunity();
        createsubmission();
           
        try {

            programMasterInstance.Active__c = true;
            programMasterInstance.Term__c = 8;
            update programMasterInstance;
            
            createOffer();
            
            delete programMasterInstance;
        }
        catch(Exception e) {}

    }
}