public class QuotePDFController {
    
    private String quoteID;
    public Quote qut{get;set;}
    public String finalString {get;set;}
    public boolean CobraAccount {get;set;}
    
    public QuotePDFController(){
        qut =  new Quote();
        CobraAccount = false;
        quoteID = apexpages.currentpage().getparameters().get('id');
        if(quoteID!=null){
            getFinalValue();
        }
        
    }
    public PageReference savePdf(){
        if(quoteID==null){
            quoteID = apexpages.currentpage().getparameters().get('id');
        }
        
        if(quoteID!=null){
            getFinalValue();
        }      
       
        PageReference pr = Page.QuotePDF1;
        pr.getParameters().put('id', quoteID);
        Blob content;
        if(!Test.isRunningTest()) 
            content = pr.getContentAsPDF();
        else 
            content = Blob.valueof('TEST');
        
        QuoteDocument doc = new QuoteDocument(Document = content, QuoteId = quoteID);
        Database.SaveResult insertResult = Database.Insert(doc, false);
        return null;
    }
    
    public void getFinalValue(){
        System.debug('quoteID ::>'+quoteID);
        if(quoteID!= null){
            qut = [Select Id,
                          Name,
                          Determination_Script__c,
                          ACA_Policy_Script__c,
                          Assignment_of_Benefits_Script__c,
                          Aggression__c,
                          Policy_Termed__c,
                          Unable_to_Verify_Benefits__c,
                          Coordination_of_Benefits__c,
                          Benefits_Check__c,
                          Determination_Script_Logo__c,
                          COBRA_Policy_Script__c,
                          Pay_Agreement_Worksheet__r.Insurance_Benefit__r.Patient_Insurance__r.COBRA_Account__c,
                          Medical_Records_Text__c,
                          High_Acuity_Text__c,
                          Professional_Coverage__c,
                          Physician_Fees__c,
                          Secondary_Pay_Agreement_Worksheet__c,
                          Secondary_Determination_Script__c ,
                          Secondary_ACA_Policy_Script__c,
                          Secondary_Assignment_of_Benefits_Script__c,
                          Secondary_Aggression__c,
                          Secondary_Policy_Termed__c,
                          Secondary_Unable_to_Verify_Benefits__c,
                          Secondary_Coordination_of_Benefits__c,
                          Secondary_Benefits_Check__c,
                          Secondary_COBRA_Policy_Script__c,
                          Secondary_Pay_Agreement_Worksheet__r.Insurance_Benefit__r.Patient_Insurance__r.COBRA_Account__c,
                          Secondary_Medical_Records_Text__c,
                          Secondary_High_Acuity_Text__c,
                          Secondary_Professional_Coverage__c,
                          Secondary_Physician_Fees__c
                     FROM Quote 
                    WHERE Id=:quoteID]; 
            System.debug('qut___________________________________ '+qut);
        }
            qut = [Select Id,
                          Name,
                          Determination_Script__c,
                          ACA_Policy_Script__c,
                          Assignment_of_Benefits_Script__c,
                          Aggression__c,
                          Policy_Termed__c,
                          Unable_to_Verify_Benefits__c,
                          Coordination_of_Benefits__c,
                          Benefits_Check__c,
                          Determination_Script_Logo__c,
                          COBRA_Policy_Script__c,
                          Pay_Agreement_Worksheet__r.Insurance_Benefit__r.Patient_Insurance__r.COBRA_Account__c,
                          Medical_Records_Text__c,
                          High_Acuity_Text__c,
                          Professional_Coverage__c,
                          Physician_Fees__c,
                          Secondary_Pay_Agreement_Worksheet__c,
                          Secondary_Determination_Script__c ,
                          Secondary_ACA_Policy_Script__c,
                          Secondary_Assignment_of_Benefits_Script__c,
                          Secondary_Aggression__c,
                          Secondary_Policy_Termed__c,
                          Secondary_Unable_to_Verify_Benefits__c,
                          Secondary_Coordination_of_Benefits__c,
                          Secondary_Benefits_Check__c,
                          Secondary_COBRA_Policy_Script__c,
                          Secondary_Pay_Agreement_Worksheet__r.Insurance_Benefit__r.Patient_Insurance__r.COBRA_Account__c,
                          Secondary_Medical_Records_Text__c,
                          Secondary_High_Acuity_Text__c,
                          Secondary_Professional_Coverage__c,
                          Secondary_Physician_Fees__c
                     FROM Quote 
                    WHERE Id=:quoteID]; 
            System.debug('qut___________________________________ '+qut);
            
/*** Check for Quote.Pay_Agreement_Worksheet.Insurance_Benefit.Patient_Insurance.COBRA_Account==YES
*/
            if(qut.Pay_Agreement_Worksheet__r.Insurance_Benefit__r.Patient_Insurance__r.COBRA_Account__c!= null && qut.Pay_Agreement_Worksheet__r.Insurance_Benefit__r.Patient_Insurance__r.COBRA_Account__c == 'Yes'){
                CobraAccount = true;
            } else {
                CobraAccount = false;
            }
            System.debug('COBRA_Account.YES___________________________________ '+qut.Pay_Agreement_Worksheet__r.Insurance_Benefit__r.Patient_Insurance__r.COBRA_Account__c);
            System.debug('CobraAccount.BOOLEAN___________________________________ '+CobraAccount);
        }
               
    }