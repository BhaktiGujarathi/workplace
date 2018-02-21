trigger AttachmentTrg on Attachment (before insert, after insert) {
    
    set<string> fileNames = new set<String>();
    for(Attachment att: trigger.new){
        System.debug('>>>>>Name>>>>>>>>'+att.Name);
        /*if(trigger.isBefore && att.parentId == null && att.Name.contains('.')){
            string key = att.Name.split('\\.')[0];
            fileNames.add(key);
        }*/
        if(trigger.isAfter){
            string reqPrefix = Announcement_Request__c.sobjecttype.getDescribe().getKeyPrefix();
            list<Announcement_Request__c> lst2Update = new List<Announcement_Request__c>();
            set<Id> parentIds = new set<Id>();
            for(Attachment attObj: trigger.new){
                if(string.valueof(attObj.parentId).startswith(reqPrefix)){
                    if(!attObj.Name.contains('Announcement')){
                        Announcement_Request__c ar = new Announcement_Request__c(Id = attObj.parentId, Header_Logo__c='<img src="'+System.Label.AnnouncementURL+'/servlet/servlet.FileDownload?file='+attObj.Id+'"></img>');
                        lst2Update.add(ar);
                    }
                    if(attObj.Name.contains('Announcement')){
                        Announcement_Request__c ar = new Announcement_Request__c(Id = attObj.parentId, Announcement_URL__c=System.Label.AnnouncementURL+'/servlet/servlet.FileDownload?file='+attObj.Id);
                        lst2Update.add(ar);
                    }
                }
            }
            
            if(!lst2Update.isEmpty())
                update lst2Update;
        }
    }
    /*
    Map<String,Id> mpInventories = new Map<String,Id>();
    System.debug('>>>>>>>fileNames>>>>>>>'+fileNames);
    
    if(!fileNames.isEmpty()){
        for(Inventory__c inv: [Select id, Unit_Location__r.Location_Code_IFC__c, Unit_Location__r.Floor_code_IFC__c  from Inventory__c where Unit_Location__r.Location_Code_IFC__c in: fileNames or Unit_Location__r.Floor_code_IFC__c in: fileNames]){
            mpInventories.put(inv.Unit_Location__r.Floor_code_IFC__c, inv.Id);
            mpInventories.put(inv.Unit_Location__r.Location_code_IFC__c, inv.Id);
        }
    }
    System.debug('>>>>>>>mpInventories>>>>>>>'+mpInventories);    

    for(Attachment att: trigger.new){
        if(att.parentId == null){
            if(att.Name.contains('.')){
                string key = att.Name.split('\\.')[0];
                System.debug('>>>>>>>key>>>>>>>'+key);
                if(mpInventories.containsKey(key)){
                    att.parentId = mpInventories.get(key);
                }
                else{
                    att.addError('No Inventory Found');
                }
            }
        }
    }*/
}