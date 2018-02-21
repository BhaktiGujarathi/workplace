/**************************************************************************************************
* Name               : LeadScoreCalculatorBatch                                                   *
* Description        : Batch class to calculate the lead score. As per the below criteria:        *
*                       - No new activity logged in ACTIVE lead in past 7 days and                *
*                         No follow up due in future : Reduce score 1 notch (until Cold)          *
*                       - Call logged duration > 7 minutes : Upgrade score by 1 notch (until hot) *
* Created Date       : 15/01/2017                                                                 *
* Created By         : NSI                                                                        *
* Last Modified Date :                                                                            *
* Last Modified By   :                                                                            *
* ----------------------------------------------------------------------------------------------- *
* VERSION     AUTHOR      DATE                                                                    *
* 1.0         NSI         15/01/2017                                                              *
**************************************************************************************************/
public class LeadScoreCalculatorBatch extends InquiryService implements Database.Batchable<sObject>{
    
    private final String MEETING_TYPE_1 = 'Face to Face';
    private final String MEETING_TYPE_2 = ' Visit to Sales Office';
    private final Integer THRESHOLD_MINUTES = 7;
    
    /*********************************************************************************************
    * @Description : Implementing the start method of batch interface, contains query.           *
    * @Params      : Database.BatchableContext                                                   *
    * @Return      : Database.QueryLocator                                                       *
    *********************************************************************************************/  
    public Database.QueryLocator start(Database.BatchableContext BC){
        return Database.getQueryLocator([SELECT Id, Inquiry_Status__c, Inquiry_Score__c, 
                                                Inquiry_Score_Last_Update__c,
                                                (SELECT Id, ActivityDate, Type, DurationInMinutes 
                                                 FROM Events 
                                                 WHERE ActivityDate = LAST_N_DAYS:7) 
                                         FROM Inquiry__c
                                         WHERE Inquiry_Status__c = 'Active']); 
    }
    
    /*********************************************************************************************
    * @Description : Implementing the execute method of batch interface, contains the criteria.  *
    * @Params      : Database.BatchableContext, List<sObject>                                    *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    public void execute(Database.BatchableContext BC, List<Inquiry__c> scope){
        List<Inquiry__c> updateInquiryList = new List<Inquiry__c>();
        Boolean isScoreUpdated = false;
        for(sobject s : scope){                     
            Inquiry__c thisInquiry = (Inquiry__c) s;            
            if(thisInquiry.Events != null && thisInquiry.Events.size() > 0){
                for(Event thisEvent : thisInquiry.Events){
                    if(thisEvent.DurationInMinutes != null && thisEvent.DurationInMinutes > THRESHOLD_MINUTES){
                        thisInquiry.Inquiry_Score__c = upgradeScore(thisInquiry.Inquiry_Score__c);  
                        isScoreUpdated = true;
                    }   
                }
                thisInquiry.Inquiry_Score_Last_Update__c = isScoreUpdated ? system.today() : thisInquiry.Inquiry_Score_Last_Update__c;
                updateInquiryList.add(thisInquiry);
            }else{
                thisInquiry.Inquiry_Score__c = downgradeScore(thisInquiry.Inquiry_Score__c);    
                thisInquiry.Inquiry_Score_Last_Update__c = system.today();
                updateInquiryList.add(thisInquiry); 
            }
        }
        if(!updateInquiryList.isEmpty()){
            update updateInquiryList;   
        }
    }
    
    /*********************************************************************************************
    * @Description : Implementing Finish method, to end an email after job completion.           *
    * @Params      : Database.BatchableContext                                                   *
    * @Return      : void                                                                        *
    *********************************************************************************************/
    public void finish(Database.BatchableContext BC){
    /*
       AsyncApexJob a = [SELECT Id, Status, NumberOfErrors, JobItemsProcessed, TotalJobItems
                         FROM AsyncApexJob 
                         WHERE Id =: BC.getJobId()];
       Messaging.SingleEmailMessage mail = new Messaging.SingleEmailMessage();
       String[] toAddresses = new String[] {'vineet.kumar@nsigulf.com'};
       mail.setToAddresses(toAddresses);
       mail.setSubject('Lead Score Calculation ' + a.Status);
       mail.setPlainTextBody('The batch Apex job processed ' + a.TotalJobItems +
                             ' batches with '+ a.NumberOfErrors + ' failures.');
       Messaging.sendEmail(new Messaging.SingleEmailMessage[] { mail });*/
    }
}// End of class.