public class StipSelectController {
    public List<StipMasterWrap> lstStipMaster {get;set;}
    public String dealId {get;set;}
    public Boolean displayPopup {get; set;}
    public StipMaster__c objNewStip {get;set;}
    public String dealType {get;set;}

    public StipSelectController (ApexPages.StandardsetController controller) {

        lstStipMaster = new List<StipMasterWrap>();
        Map<String,String> urlParameters = ApexPages.currentPage().getParameters();
        dealId = '';
        objNewStip = new StipMaster__c ();
        dealType = '';
        Set<Id> setCurrentStipId = new Set<Id>();

        //Get deal id

        for (String key : urlParameters.keyset()) {

            if (key.contains('id')) {

                dealId = urlParameters.get(key);
            }
        }

        system.debug('###dealId' + dealId);

        //Get all Stip master ids from which the existing stips were created
        for (McaApp__Stips__c uw : [SELECT Id,StipMaster__c FROM McaApp__Stips__c WHERE McaApp__Opportunity__c = :dealId]) {

            setCurrentStipId.add(uw.StipMaster__c);
        }

        //get all Stip list from Stip master
        for (StipMaster__c objStip : [SELECT Id,Name,Type__c,Notes__c,Owner.Name FROM StipMaster__c WHERE Id NOT IN :setCurrentStipId LIMIT 1000]) {

            lstStipMaster.add(new StipMasterWrap(objStip));
        }

        List<Opportunity> lstDeal = [SELECT Id,ProgramType__c FROM Opportunity WHERE Id = :dealId];

        if (lstDeal != null && lstDeal.size() > 0 && lstDeal[0].ProgramType__c != null) {

            dealType = lstDeal[0].ProgramType__c;
        }
    }

    public void SaveAndClose() {

        objNewStip.OwnerId = UserInfo.getUserId();
        insert objNewStip;
        StipMasterWrap s = new StipMasterWrap(objNewStip);
        s.selected=true;
        lstStipMaster.add(s);
        displayPopup = false;
        //return null;
    }

    public void CancelNew() {

        displayPopup = false;
    }

    public pagereference done() {

        List<McaApp__Stips__c> lstStipToInsert = new List<McaApp__Stips__c>();

        for(StipMasterWrap wrap : lstStipMaster) {

            if (wrap.selected) {

                McaApp__Stips__c objNewStip = new McaApp__Stips__c(name = wrap.objStip.Name,McaApp__Status__c='Pending',
                McaApp__Opportunity__c = dealId, Notes__c = wrap.objStip.Notes__c, StipMaster__c = wrap.objStip.id);

                lstStipToInsert.add(objNewStip);
            }
        }

        if (lstStipToInsert != null && lstStipToInsert.size() > 0) {

            insert lstStipToInsert;
        }
        else {

            ApexPages.addMessage(new ApexPages.Message(ApexPages.Severity.error,'Please select atleast one record'));
            return null;
        }

        return new pagereference('/' + dealId);
    }

    public void newStip() {

        objNewStip = new StipMaster__c ();
        objNewStip.Type__c = dealType;
        displayPopup = true;
    }


    public class StipMasterWrap {

        public StipMaster__c objStip{get;set;}
        public boolean selected{get;set;}

        public StipMasterWrap(StipMaster__c s) {

            objStip = s;
            selected = false;
        }
    }
}