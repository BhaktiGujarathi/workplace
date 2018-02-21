/*
 * Service request to handle buyer detail changes.
 */
public class ManageBuyersController {
    Map<string,string> PageParameters = new Map<string,string>();
    list<Booking__c> lstBK = new List<Booking__c>();
    public List<SelectOption> soBookings {get;set;}
    public string selectedRecord {get;set;}
    public List<Buyer__c> lstBuyers = new List<Buyer__c>();
    public id buyrID {get;set;}
    public boolean showList {get;set;}
    public boolean showAddPanel {get;set;}
    public Amendment__c newBuyer {get;set;}
    public NSIBPM__Service_Request__c objSR {get;set;}
    public List<Amendment__c> lstamd {get;set;}
    public Map<Id,Booking__c> mpBooking {get;set;}
    public string returnURLID {get;set;}  
    public ManageBuyersController(){
        try{
            PageParameters = ApexPages.currentPage().getParameters();
            mpBooking = new Map<Id,Booking__c>();
            soBookings = new List<SelectOption>();
            newBuyer = new Amendment__c();
            returnURLID = PageParameters.get('id');
            system.debug('---->'+returnURLID);
            showAddPanel = false;
            showList = false;
            lstamd = new List<Amendment__c>();
            //if page opened with out a valid url parameter.
            if(PageParameters.get('id') == null || PageParameters.get('id') == ''){
                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please provide a valid URL parameter'));
                return;
            }
            //if provided URL ID parameter is not of Deal record type or the record is not in approved status.
            //&& dealSR.NSIBPM__Internal_Status_Name__c != 'Approved'
            for(NSIBPM__Service_Request__c dealSR : [select id,name,NSIBPM__Record_Type_Name__c,NSIBPM__Internal_Status_Name__c from NSIBPM__Service_Request__c where id =: PageParameters.get('id')]){
                if(dealSR.NSIBPM__Record_Type_Name__c != 'Deal'){
                        Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Parent SR should be of type Deal and in approved status. Please try with a valid Deal.'));
                        return;
                }
            }
            //Get all bookings for the provided deal record.
            for(string str : PageParameters.keyset()){
                lstBK = (List<Booking__c>)SRUtility.getRecords('Booking__c',' where Deal_SR__c =\''+PageParameters.get('id')+'\'');
                soBookings.add(new SelectOption('NONE','-Select-'));
                for(Booking__c bk : lstBK) 
                {  
                    mpBooking.put(bk.id,bk);
                    system.debug('--->'+bk.id+' >>>> '+bk.Name);
                    soBookings.add(new SelectOption(bk.id,bk.Name));
                }
            }
        }
        catch(exception ex){
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please provide a valid URL parameter.'));
        }
    }

    
    //On change of selected list
    public pagereference onBookingSelection(){
        try{
            showList = false;
            system.debug('--selectedRecord->'+selectedRecord);
            if(selectedRecord == 'NONE'){
                Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, 'Please select a Booking.'));
                
            }else{
                //check for existing SR of booking unit type which is in open state for the selected booking unit or create a new sr. 
                Id SRRecType = Schema.SObjectType.NSIBPM__Service_Request__c.getRecordTypeInfosByName().get('Change Joint Buyer').getRecordTypeId();
                objSR = new NSIBPM__Service_Request__c();
                string condt = ' WHERE (nsibpm__internal_status_name__c != \'Approved\' AND  nsibpm__internal_status_name__c != \'Rejected\' AND nsibpm__internal_status_name__c != \'Closed\') and Booking_No__c= \''+mpBooking.get(selectedRecord).name+'\' and recordtypeid =\''+SRRecType+'\'';
                //List<NSIBPM__Service_Request__c> existingsrs = (List<NSIBPM__Service_Request__c>)SRUtility.getRecords('NSIBPM__Service_Request__c',' where Booking_No__c= \''+mpBooking.get(selectedRecord).name+'\'');nsibpm__internal_status_name__c != \'Draft\' AND
                List<NSIBPM__Service_Request__c> existingsrs = (List<NSIBPM__Service_Request__c>)SRUtility.getRecords('NSIBPM__Service_Request__c',condt);
                system.debug('--->'+existingsrs);
                if(existingsrs != null && !existingsrs.isempty()){
                    objSR = existingsrs[0];
                    //get existing amendment records.
                    lstamd = (List<Amendment__c>)SRUtility.getRecords('Amendment__c',' where Service_Request__c =\''+ objSR.id +'\'');
                }else{
                    objSR.RecordTypeId = SRRecType;
                    objSR.NSIBPM__Parent_SR__c = returnURLID;
                    objsr.Booking_No__c = mpBooking.get(selectedRecord).name;
                    upsert objSR;
                }
                system.debug('onInit.id'+objSR.id);
                initialize();
            }
            
            return null;
        }
        Catch(exception ex){
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            return null;
        }
    }
    
    public void initialize(){
        //If amendments records on sr doesn't exist for any reason get the buyers info on to amendments
        if(lstamd == null || lstamd.isempty()){
            lstamd = new List<Amendment__c>();
            lstBuyers = (List<Buyer__c>)SRUtility.getRecords('Buyer__c',' where Booking__c =\''+ selectedRecord +'\'');        
            if(!lstBuyers.isEmpty()){
                showList = true;
                for(Buyer__c b : lstBuyers){
                    Amendment__c amd = new Amendment__c();
                    amd.First_Name__c = b.First_Name__c;
                    amd.Last_Name__c  = b.Last_Name__c;
                    amd.Passport_Number__c = b.Passport_Number__c;
                    amd.Buyer__c = b.id;
                    system.debug('objSR.id'+objSR.id);
                    amd.Service_Request__c = objSR.id;
                    lstamd.add(amd);
                    system.debug('--lstBuyers->'+lstBuyers[0].id);
                }
            }
            if(lstamd != null && !lstamd.isempty()){
                upsert lstamd;
            }
        }
        else{
            lstamd = (List<Amendment__c>)SRUtility.getRecords('Amendment__c',' where Service_Request__c =\''+ objSR.id +'\''); 
            showList = true; 
        }
        system.debug('--lstamd->'+lstamd);
    }
    

    //when a buyer is saved.
    public PageReference Save(){
        try{
            upsert newBuyer;
            initialize();
            showAddPanel = false;
            return null;
        }
        Catch(exception ex){
            Apexpages.addMessage(new ApexPages.Message(ApexPages.Severity.ERROR, ex.getMessage()));
            return null;
        }
    }
    
    //to cancel the creation of new buyer.
    public PageReference Cancel(){
        
        showAddPanel = false;
        return null;
        
    }
    //Proceed to SR view page.
    public PageReference Proceed(){
        if(objsr != null && objsr.id != null){
            pagereference pg = new pagereference('/'+objsr.id);
        	return pg;
        }else{
            return null;
        }
    }
    
    public PageReference GoBack(){
        pagereference pg = null;
        if(returnURLID != null && returnURLID != '')
            pg = new pagereference('/'+returnURLID);
        else{
            string sobjectkeyprefix = NSIBPM__Service_Request__c.sobjecttype.getDescribe().getKeyPrefix();
            pg = new pagereference('/'+sobjectkeyprefix+'/o');
        }
        return pg;
    }
    //add a new buyer
    public PageReference AddNew(){
        showAddPanel = true;
        if(objSR != null && objSR.id != null){
            newBuyer = new Amendment__c(Service_Request__c = objSR.id);
        }
        system.debug('-->'+showAddPanel);
        return null;
    }
    //soft delete buyer
    public pagereference BuyrDelete(){
        if(buyrID != null){
            update new Amendment__c(id=buyrID,Mark_for_Deletion__c = true); 
            initialize();
        }
        return null;
    }
    //edit buyer details if added from this page.
    public pagereference Edit(){
        if(buyrID != null){
            newBuyer = ((List<Amendment__c>)SRUtility.getRecords('Amendment__c',' where id =\''+ buyrID +'\''))[0];  
            showAddPanel = true;
        }
        return null;
    }
    //undo soft delete of buyer.
    public pagereference BuyrDeleteUNDO(){
        if(buyrID != null){
            update new Amendment__c(id=buyrID,Mark_for_Deletion__c = false); 
            initialize();
        }
        return null;
    }
}