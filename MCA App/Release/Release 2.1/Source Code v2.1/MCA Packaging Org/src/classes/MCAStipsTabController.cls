public with sharing class MCAStipsTabController {

  public Stips__c[] stips;
  public Stips__c[] newStips {get; set;}
  public Container[] containers;

  public Opportunity opportunity {get; set;}
  public Boolean editAll {get;set;}
   public Integer noOpenStips {get;set;}
  public Id recordToDelete {get;set;}
  public Integer indexToRemove {get;set;}
  private Id opportunityId;
  public string DestURL {get; set;}
  public string openStips {get; set;}
  private string PENDING = 'Pending';
  private string REQUESTED = 'Requested';
  public Integer stipsOpenCnt {get;set;}
  public Integer stipsCloseCnt {get;set;}
  public MCAStipsTabController() {

    opportunityId = Apexpages.currentPage().getParameters().get('id');
    opportunity = new Opportunity();
    opportunity = [Select Id, Name, Open_Stips__c, Owner_1__c,Owner_1__r.Email from Opportunity where Id=:opportunityId ];
    openStips = 'SELECT count() FROM Stips__c WHERE Opportunity__c = :'+ opportunityId +' AND  (Status__c = '+ PENDING + ' OR Status__c = '+REQUESTED+')';
    refresh();
    DestURL = '/_ui/core/email/author/EmailAuthor?p3_lkid='+opportunity.Id+'&retURL=%2F'+opportunity.Id+'&template_id='+system.Label.Email_Stips_Template_Id+'&p24='+opportunity.Owner_1__r.Email+'&p2='+Opportunity.Owner_1__c+'&p2_lkid='+ Opportunity.Owner_1__c;
    stipsOpenCnt = 0;
    stipsCloseCnt = 0;
  }

  public Stips__c[] getStips() {

    stips = new Stips__c[] {};

    stips.addAll(newStips);

    stips.addAll([SELECT
                    Id,
                    Recv_d__c,
                    Name,
                    Type__c,
                    Status__c,
                    Requested_by__c,
                    Date_Requested__c,
                    Requirement__c
                FROM Stips__c
                WHERE Opportunity__c = :opportunityId]);

    return stips;
  }
  public Container[] getContainers() {
	stipsOpenCnt = 0;
	stipsCloseCnt = 0;
    stips = new Stips__c[] {};
    
    containers = new Container[] {};

    stips.addAll(newStips);

    stips.addAll([SELECT
                    Id,
                    Recv_d__c,
                    Name,
                    Type__c,
                    Status__c,
                    Requested_by__c,
                    Date_Requested__c,
                    Requirement__c
                FROM Stips__c
                WHERE Opportunity__c = :opportunityId]);

    for (Integer i = 0; i < stips.size(); i++) {
      containers.add(new Container(stips[i], i));
     if(stips[i].Status__c == 'Pending' || stips[i].Status__c == 'Requested')
      	++stipsOpenCnt;
      if(stips[i].Status__c == 'Completed')
      	++stipsCloseCnt;
    }
	system.debug('@@@stipsOpenCnt'+stipsOpenCnt);
	system.debug('@@@stipsCloseCnt'+stipsCloseCnt);
    return containers;

    //return stips;
  }
public pageReference test(){
getContainers();
return null;
}
	public void save(){
		//getContainers();
	}
  public void newStip() {

    newStips.add(new Stips__c(Opportunity__c = opportunityId, Type__c = 'Stip', Status__c = '	Pending', 	Date_Requested__c = system.today()));
  }

  public void refresh() {

    recordToDelete = null;
    editAll = false;
    newStips = new Stips__c[] {};
  }
  
  public void saveAllStips() {

    /*
    Stips__c[] recordsToUpdate = new Stips__c[] {};

    for (Stips__c record :stips) {

      if (MCARecordValidator.isRecordValid(record)) {
        recordsToUpdate.add(record);
      }
    }

    */
    try{
    	system.debug('****stips****'+stips);
    upsert stips;
    }
    catch(Exception e){
    system.debug('error Message'+e);
    }
    refresh();
  }
  public void editAll() {
    refresh();
    editAll = true;
  }

  public void deleteStip() {

    if (recordToDelete != null) {
      Stips__c record = [SELECT Id FROM Stips__c WHERE Id = :recordToDelete];
      delete record;
    }
    //getContainers();
  }

  public void removeStip() {

    if (indexToRemove != null) {

      Container c = null;

      for (Container element :containers) {

        if (element.index == indexToRemove) {
          c = element;
        }
      }

      //containers.remove(c.index);
      newStips.remove(c.index);
    }

  }

  public class Container {

    public Stips__c stip {get;set;}
    public Integer index {get;set;}

    public Container(Stips__c instance, Integer index) {
      stip = instance;
      this.index = index;
    }

  }

}