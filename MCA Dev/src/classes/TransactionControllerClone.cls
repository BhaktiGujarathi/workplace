public with sharing class TransactionControllerClone {
    
    // variable declaration
    public Apexpages.StandardController controller;
    public Transaction__c objTranscation                                              {get; set;}
    public String strTransName                                                        {set; get;}  
    
    // constructor
    public TransactionControllerClone(ApexPages.StandardController stdController) {
        // variable defination
        controller = stdController;
        objTranscation = (Transaction__c)controller.getRecord();
        strTransName = [select Name FROM RecordType WHERE Id =: objTranscation.RecordTypeId limit 1].Name;             
    }    
}