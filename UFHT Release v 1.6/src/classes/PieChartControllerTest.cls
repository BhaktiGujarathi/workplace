@isTest
public class PieChartControllerTest
{
    public static testMethod void pieChartUFHT() 
    {
        UFHT__Ultra_Track_Container__c u =new UFHT__Ultra_Track_Container__c();
        List<UFHT__Ultra_Track_Container__c> UFHTList = new List<UFHT__Ultra_Track_Container__c>();
       
        UFHTList.add(new UFHT__Ultra_Track_Container__c(UFHT__Object_Name__c='Case',UFHT__Object_Label__c='Case(case)',UFHT__Is_Tracking_Enabled__c=true,UFHT__Must_Have__c=2,UFHT__Good_To_Have__c=2));
        UFHTList.add(new UFHT__Ultra_Track_Container__c(UFHT__Object_Name__c='Account',UFHT__Object_Label__c='Account(Account)',UFHT__Is_Tracking_Enabled__c=true,UFHT__Must_Have__c=3,UFHT__Good_To_Have__c=2));
        UFHTList.add(new UFHT__Ultra_Track_Container__c(UFHT__Object_Name__c='Campaign',UFHT__Object_Label__c='Campaign(Campaign)',UFHT__Is_Tracking_Enabled__c=true,UFHT__Must_Have__c=5,UFHT__Good_To_Have__c=2));
        UFHTList.add(new UFHT__Ultra_Track_Container__c(UFHT__Object_Name__c='Opportunity',UFHT__Object_Label__c='Opportunity(Opportunity)',UFHT__Is_Tracking_Enabled__c=true,UFHT__Must_Have__c=4,UFHT__Good_To_Have__c=2));
        UFHTList.add(new UFHT__Ultra_Track_Container__c(UFHT__Object_Name__c='Lead',UFHT__Object_Label__c='Lead(Lead)',UFHT__Is_Tracking_Enabled__c=true,UFHT__Must_Have__c=5,UFHT__Good_To_Have__c=2));
        UFHTList.add(new UFHT__Ultra_Track_Container__c(UFHT__Object_Name__c='Contract',UFHT__Object_Label__c='Contract(Contract)',UFHT__Is_Tracking_Enabled__c=true,UFHT__Must_Have__c=6,UFHT__Good_To_Have__c=2));
 
        insert UFHTList;
        
        Attachment attach=new Attachment();     
        attach.Name='Unit Test Attachment';
        Blob bodyBlob=Blob.valueOf('Unit Test Attachment Body');
        attach.body=bodyBlob;
        attach.parentId= 'a002800000qSKUN';
        system.debug('attach.parentId= u.id'+attach.parentId);
        //insert attach;
        
        test.StartTest();
        PieChartController.fetchContainerData();
        test.StopTest();  
        List<Attachment> attachments=[select id, name from Attachment where parent.id =: 'a002800000qSKUN'];
        //System.assertEquals(1, attachments.size());        
    }
}