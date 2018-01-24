public with sharing class testForChevronExtension {

    public List<String> statuses{get;set;}
    public String currentStatus{get;set;}
    public String completedStatus{get;set;}
    public String cancelledStatus{get;set;}
    public String onHoldStatus{get;set;}
 public testForChevronExtension(ApexPages.StandardController controller)
  {
 
      infydisdespune__Position__c project=(infydisdespune__Position__c)controller.getRecord();
      completedStatus='Complete';
      cancelledStatus='Cancelled';
      onHoldStatus='On Hold';
      project=[Select id,name,infydisdespune__Status__c from  infydisdespune__Position__c  where id=:project.id];
      statuses=new List<String>{'New Position','Pending Approval','Open - Approved','Closed - Filled','Closed - Not Approved'};
      currentStatus=project.status__c;
     

    }




}