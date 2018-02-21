@istest
public class CreateStepOnDPOverDueTest{



    static testmethod void CreateStepOnDPOverDue_Methods(){
    
        NSIBPM__Service_Request__c sr = new NSIBPM__Service_Request__c();
        insert sr;
        
        NSIBPM__Service_Request__c sr1 = new NSIBPM__Service_Request__c();
        insert sr1;
        
        NSIBPM__Step_Template__c stpTemp  = new NSIBPM__Step_Template__c();
        stpTemp.NSIBPM__Code__c = 'DEAL_REJECTION';
        stpTemp.NSIBPM__Step_RecordType_API_Name__c = 'Deal_Rejection';
        insert stpTemp;
                
        NSIBPM__Step__c dealrej = new NSIBPM__Step__c();
        dealRej.NSIBPM__Step_Template__c = stpTemp.id;
        insert dealrej;
        
        NSIBPM__Status__c stat = new NSIBPM__Status__c();
        stat.NSIBPM__Code__c = 'DEAL_REJECTION';
        insert stat;
        
        
        
        NSIBPM__SR_Template__c srtemp = new NSIBPM__SR_Template__c();
        srtemp.Name = 'Deal';
        srtemp.NSIBPM__SR_RecordType_API_Name__c ='Deal_Rejection';
        insert srtemp;
        
        NSIBPM__SR_Steps__c srstep = new NSIBPM__SR_Steps__c();
        srstep.NSIBPM__Step_Template__c= stpTemp.id;
        srstep.NSIBPM__Start_Status__c=stat.id;
        srstep.ownerid = userinfo.getuserid();
        srstep.NSIBPM__SR_Template__c = srtemp.id;
        srstep.NSIBPM__Step_No__c = 40;
        insert srstep;
        
        booking__c b1 = new booking__c();
        b1.Deal_SR__c = sr1.id;
        insert b1;
        
        Booking_Unit__c bu1 = new Booking_Unit__c();
        bu1.booking__c = b1.id;        
        insert bu1;
        
        booking__c b = new booking__c();
        b.Deal_SR__c = sr.id;
        insert b;
        
        Booking_Unit__c bu = new Booking_Unit__c();
        bu.booking__c = b.id;        
        insert bu;
        
        
        List<Id> srIds=new list<id>();
        srIds.add(sr.id);
        CreateStepOnDPOverDue.createStep(srIds);
        srIds.clear();
        srIds.add(sr1.id);
        CreateStepOnDPOverDue.createStepFromButton((srIds)[0]);
        CreateStepOnDPOverDue.reinstatementDeal((srIds)[0]);
    }
    
    // Re Instatement
    static testmethod void reinstatement_Methods(){
    
        NSIBPM__Service_Request__c sr = new NSIBPM__Service_Request__c();
        insert sr;
        
        NSIBPM__Service_Request__c sr1 = new NSIBPM__Service_Request__c();
        insert sr1;
        
        NSIBPM__Step_Template__c stpTemp  = new NSIBPM__Step_Template__c();
        stpTemp.NSIBPM__Code__c = 'DEAL_REINSTATEMENT';
        stpTemp.NSIBPM__Step_RecordType_API_Name__c = 'DEAL_REINSTATEMENT';
        insert stpTemp;
                
        NSIBPM__Step__c dealrej = new NSIBPM__Step__c();
        dealRej.NSIBPM__Step_Template__c = stpTemp.id;
        insert dealrej;
        
        NSIBPM__Status__c stat = new NSIBPM__Status__c();
        stat.NSIBPM__Code__c = 'DEAL_REINSTATEMENT';
        insert stat;
        
        
        
        NSIBPM__SR_Template__c srtemp = new NSIBPM__SR_Template__c();
        srtemp.Name = 'Deal';
        srtemp.NSIBPM__SR_RecordType_API_Name__c ='DEAL_REINSTATEMENT';
        insert srtemp;
        
        NSIBPM__SR_Steps__c srstep = new NSIBPM__SR_Steps__c();
        srstep.NSIBPM__Step_Template__c= stpTemp.id;
        srstep.NSIBPM__Start_Status__c=stat.id;
        srstep.ownerid = userinfo.getuserid();
        srstep.NSIBPM__SR_Template__c = srtemp.id;
        srstep.NSIBPM__Step_No__c = 30;
        insert srstep;
        
        booking__c b1 = new booking__c();
        b1.Deal_SR__c = sr1.id;
        insert b1;
        
        Booking_Unit__c bu1 = new Booking_Unit__c();
        bu1.booking__c = b1.id;        
        insert bu1;
        
        booking__c b = new booking__c();
        b.Deal_SR__c = sr.id;
        insert b;
        
        Booking_Unit__c bu = new Booking_Unit__c();
        bu.booking__c = b.id;        
        insert bu;
        
        
        List<Id> srIds=new list<id>();
        srIds.add(sr.id);
        CreateStepOnDPOverDue.createStep(srIds);
        srIds.clear();
        srIds.add(sr1.id);        
        CreateStepOnDPOverDue.reinstatementDeal((srIds)[0]);
    }


}