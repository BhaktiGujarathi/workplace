global without sharing class ManageBuyerDocs implements NSIBPM.CustomCodeExecutable {
    Public static Map<String,ID> mpuniqSRDOCNamedocID;
    
    public String EvaluateCustomCode(NSIBPM__Service_Request__c SR, NSIBPM__Step__c step){
        try{
            String retStr = 'Success';
            if(step.NSIBPM__SR__c != null){ 
                createdocsforBuyer(step.NSIBPM__SR__c,step.NSIBPM__SR__r.nsibpm__record_type_name__c);
            }
            return retstr;
        }
        catch(exception ex){
            return ex.getMessage();
        }
    }
    
    
    public static void createdocsforBuyer(id srid, string recTypeName){
        //Get all docs
        mpuniqSRDOCNamedocID = new Map<string,Id>();
        for(NSIBPM__SR_Doc__c srdoc : [select id,name,Unique_SR_Doc_Name__c from NSIBPM__SR_Doc__c where Buyer__c != null and NSIBPM__Service_Request__c =: srid]){
            mpuniqSRDOCNamedocID.put(srdoc.Unique_SR_Doc_Name__c,srdoc.id);
        }
        List<Constants__c> lstdocsConfig = (List<Constants__c>)srutility.getRecords('Constants__c',' where IsBuyerReqDocs__c = true');
        Map<string,Map<string,Constants__c>> minordocs = new Map<string,Map<string,Constants__c>>();
        Map<string,Map<string,Constants__c>> mpUniqCodeReqDocs = new Map<string,Map<string,Constants__c>>();
        for(Constants__c c : lstdocsConfig){
            if(c.Associate_Type__c != null && c.Country__c != null){
                string city = '';
                if(c.City__c != null){
                    city = c.City__c;
                }
                string key = c.Associate_Type__c+c.Country__c+city;
                key = key.toLowerCase();
                //for associate type corporate and individual
                if(c.Associate_Type__c != 'Minor'){
                    if(mpUniqCodeReqDocs.containsKey(key)){
                        Map<string,Constants__c> mpc = mpUniqCodeReqDocs.get(key);
                        mpc.put(c.Doc_Code__c,c);
                        mpUniqCodeReqDocs.put(key,mpc);
                    }else{
                        Map<string,Constants__c> mpc = new Map<string,Constants__c>();
                        mpc.put(c.Doc_Code__c,c);
                        mpUniqCodeReqDocs.put(key,mpc);
                    }
                }
                //for associate type minor
                else if(c.Associate_Type__c == 'Minor'){
                    Map<string,Constants__c> mpc = new Map<string,Constants__c>();
                    if(minordocs.containsKey(key)){mpc = minordocs.get(key); }
                    mpc.put(c.Doc_Code__c,c);
                    minordocs.put(key,mpc);
                }
            }
        }
        system.debug('---mpUniqCodeReqDocs->>>>'+mpUniqCodeReqDocs.size());
        system.debug('---minordocs->>>>'+minordocs.size());
        
        Map<id,List<Booking_Unit__c>> mpBKIDlstBU = new Map<id,List<Booking_Unit__c>>();
        for(Booking__c b : [select id,(select id,Inventory__c,Booking__c,Inventory__r.Property_Country__c,Inventory__r.Property_City__c 
                                       from Booking_Units__r where Status__c !='Removed') from Booking__c where Deal_SR__c =: srid]){
                                           if(b.Booking_Units__r != null && !b.Booking_Units__r.isempty()){
                                               mpBKIDlstBU.put(b.id,b.Booking_Units__r);
                                           }
                                           
                                       }
        
        Map<id,List<Buyer__c>> mpBKIDlstByrs = new Map<id,List<Buyer__c>>();
        for(Booking__c b : [select id,(select id,name,Date_of_Birth__c,Nationality__c,Country__c,Buyer_Type__c,Organisation_Name__c,Passport_Number__c,Booking__c,First_Name__c,
                                       CR_Number__c
                                       from Buyers__r) from Booking__c where Deal_SR__c =: srid]){
                                           if(b.Buyers__r != null && !b.Buyers__r.isempty()){
                                               mpBKIDlstByrs.put(b.id,b.Buyers__r);
                                           }
                                           
                                       }
        
        List<Buyer__c> lstByrs = new List<Buyer__c>();
        for(id buID : mpBKIDlstByrs.keyset()){
            lstByrs.addall(mpBKIDlstByrs.get(buID));
        }
        //get uniq buyer types
        set<string> stBuyerstype = new set<string>();
        for(Buyer__c bu : lstByrs){
            if(bu.Buyer_Type__c != null)
                stBuyerstype.add(bu.Buyer_Type__c);
        }
        
        Map<Id,Map<string,constants__c>> mpBIDTypeReqDocs = new Map<Id,Map<string,constants__c>>();
        Map<Id,Map<string,constants__c>> mpBIDTypeReqDocsMinor = new Map<Id,Map<string,constants__c>>();
        
        for(id bID : mpBKIDlstBU.keyset()){
            Map<string,constants__c> mpTypeReqDocs = new Map<string,constants__c>();
            Map<string,constants__c> mpTypeReqDocsMinor = new Map<string,constants__c>();
            
            for(Booking_Unit__c bu : mpBKIDlstBU.get(bID)){
                if(bu.Inventory__r.Property_Country__c != null){
                    //for each uniq buyer type and based on country and city get required docs
                    for(string buyrType : stBuyerstype){
                        string keyDocset = string.valueof(buyrType+bu.Inventory__r.Property_Country__c).tolowercase();
                        string keyDocsetMinor = string.valueof('Minor'+bu.Inventory__r.Property_Country__c).tolowercase();
                        //for associate/individual
                        if(keyDocset != null && keyDocset != '' && mpUniqCodeReqDocs.containskey(keyDocset)){
                            mpTypeReqDocs.putall(mpUniqCodeReqDocs.get(keyDocset));
                        }
                        if(keyDocsetMinor != null && keyDocsetMinor != '' && mpUniqCodeReqDocs.containskey(keyDocsetMinor)){
                            mpTypeReqDocsMinor.putall(mpUniqCodeReqDocs.get(keyDocsetMinor));
                        }
                        //for minor
                        if(bu.Inventory__r.Property_City__c != null){
                            string keywCityDocset = string.valueof(buyrType+bu.Inventory__r.Property_Country__c+bu.Inventory__r.Property_City__c).tolowercase();
                            string keywCityDocsetMinor = string.valueof('Minor'+bu.Inventory__r.Property_Country__c+bu.Inventory__r.Property_City__c).tolowercase();
                            if(keywCityDocset != null && keywCityDocset != '' && mpUniqCodeReqDocs.containskey(keywCityDocset)){
                                mpTypeReqDocs.putall(mpUniqCodeReqDocs.get(keywCityDocset));
                            }
                            if(keywCityDocsetMinor != null && keywCityDocsetMinor != '' && mpUniqCodeReqDocs.containskey(keywCityDocsetMinor)){
                                mpTypeReqDocsMinor.putall(mpUniqCodeReqDocs.get(keywCityDocsetMinor));
                            }
                        }
                    }
                }
            }
            //for associate or individual
            if(!mpTypeReqDocs.isempty())
                mpBIDTypeReqDocs.put(bid,mpTypeReqDocs);
            //for minor
            if(!mpTypeReqDocsMinor.isempty())
                mpBIDTypeReqDocsMinor.put(bid,mpTypeReqDocsMinor);
            
        }
        system.debug('---mpBIDTypeReqDocsMinor->>>>'+mpBIDTypeReqDocsMinor.size());
        system.debug('---mpBIDTypeReqDocs->>>>'+mpBIDTypeReqDocs.size());
        //Get all srtemplatedocs
        List<NSIBPM__SR_Template_Docs__c> lstSRTemplateDoc = [Select Id, Name, NSIBPM__Group_No__c, 
                                                              NSIBPM__Document_Master__r.NSIBPM__Code__c, NSIBPM__Requirement__c, 
                                                              NSIBPM__Generate_Document__c, NSIBPM__DMS_Document_Index__c, 
                                                              NSIBPM__Added_through_Code__c, NSIBPM__Document_Description_External__c, 
                                                              NSIBPM__SR_Template__c, NSIBPM__Document_Master__c, 
                                                              NSIBPM__Optional__c, NSIBPM__Document_Description__c, 
                                                              NSIBPM__Document_Name_for_SR__c, NSIBPM__Document_Master__r.Name 
                                                              from NSIBPM__SR_Template_Docs__c where 
                                                              NSIBPM__SR_Template__r.NSIBPM__SR_RecordType_API_Name__c =: recTypeName and 
                                                              NSIBPM__Added_through_Code__c = true];
        
        Map<string,integer> mpGCClist = new Map<string,integer>();
        for(string strGCC : string.valueof(Label.BuyerNationalityGCCList).split(',')){
            mpGCClist.put(strGCC.tolowercase(),1);
        }
        Map<string,NSIBPM__SR_Doc__c> mpuniqKeyDoc = new Map<string,NSIBPM__SR_Doc__c>();
        for(id bid : mpBKIDlstByrs.keyset()){        
            for(Buyer__c b : mpBKIDlstByrs.get(bid)){
                string docNameprefixBuyer = '';
                if(b.Buyer_Type__c == 'Corporate'){
                    docNameprefixBuyer = b.Organisation_Name__c;
                }else{
                    docNameprefixBuyer = b.first_name__c;
                }
                
                string locdocKey = b.Passport_Number__c == null ? b.CR_Number__c : b.Passport_Number__c;
                if(locdocKey != null){
                    boolean isminor = false;
                    
                    if(b.Date_of_Birth__c != null && b.Buyer_Type__c != 'Corporate'){
                        Integer days = Date.parse(b.Date_of_Birth__c).daysBetween(Date.Today());
                        Integer age = Integer.valueOf(days/365);    
                        system.debug('---b.Date_of_Birth__c->>>>'+b.Date_of_Birth__c +' --days '+days+'--- age '+age);
                        isminor = age >= 21 ? false : true;
                    }
                    boolean isGCC=false;
                    string filterCond = '';
                    string buyerCtrFilterC = '';
                    if(b.Nationality__c != null && String.isNotBlank(b.Nationality__c)){
                        isGCC = (mpGCClist.containskey(b.Nationality__c.tolowercase())) ? true : false;
                        if(isGCC){
                            filterCond = 'Is GCC';
                        }else{
                            filterCond = 'Is Non GCC';
                        }
                    }
                    if(b.Country__c != null && String.isNotBlank(b.Country__c))
                    {
                        if(b.Country__c.tolowercase() == 'united arab emirates'){
                            buyerCtrFilterC = 'Is UAE';
                        }else{
                            buyerCtrFilterC = 'Is Non UAE';
                        }
                    }             
                    system.debug('---filterCond->>>>'+filterCond +'-- Minor'+ isminor);
                    //If not minor
                    if(mpBIDTypeReqDocs.containskey(b.booking__c) && mpBIDTypeReqDocs.get(b.booking__c) != null && !isminor){
                        for(NSIBPM__SR_Template_Docs__c srtmpdoc : lstSRTemplateDoc){
                            String docCode = srtmpdoc.NSIBPM__Document_Master__r.NSIBPM__Code__c;
                            String docName = srtmpdoc.NSIBPM__Document_Master__r.Name;
                            //if doc has to be created.
                            if(mpBIDTypeReqDocs.get(b.booking__c).containskey(docCode)){
                                Constants__c clocal = mpBIDTypeReqDocs.get(b.booking__c).get(docCode);
                                //if non of the filters are applied
                                if(clocal.Filter_Doc__c == null || clocal.Filter_Doc__c == ''){
                                    system.debug('---inside doc creation->>>>'+docCode);
                                    NSIBPM__SR_Doc__c sdoc = createSRDoc(docNameprefixBuyer+'-'+docName,srtmpdoc,b.id,srid);
                                    mpuniqKeyDoc.put(locdocKey+docCode,sdoc);
                                }
                                if(filterCond != '' && buyerCtrFilterC != '' && clocal.Filter_Doc__c == filterCond && clocal.Buyer_Country__c == buyerCtrFilterC){
                                    system.debug('---inside doc creation->>>>'+docCode);
                                    NSIBPM__SR_Doc__c sdoc = createSRDoc(docNameprefixBuyer+'-'+docName,srtmpdoc,b.id,srid);
                                    mpuniqKeyDoc.put(locdocKey+docCode,sdoc);
                                }
                                //if any filter, match the values
                                if(filterCond != '' && clocal.Filter_Doc__c == filterCond && clocal.Buyer_Country__c == null){
                                    system.debug('---inside doc creation->>>>'+docCode);
                                    NSIBPM__SR_Doc__c sdoc = createSRDoc(docNameprefixBuyer+'-'+docName,srtmpdoc,b.id,srid);
                                    mpuniqKeyDoc.put(locdocKey+docCode,sdoc);
                                }
                            }
                        }
                    }
                    //if minor
                    if(mpBIDTypeReqDocsMinor.containskey(b.booking__c) && mpBIDTypeReqDocsMinor.get(b.booking__c) != null && isminor){
                        for(NSIBPM__SR_Template_Docs__c srtmpdoc : lstSRTemplateDoc){
                            String docCode = srtmpdoc.NSIBPM__Document_Master__r.NSIBPM__Code__c;
                            String docName = srtmpdoc.NSIBPM__Document_Master__r.Name;
                            //if doc has to be created. for now filters are not applied in case of minor.
                            if(mpBIDTypeReqDocsMinor.get(b.booking__c).containskey(docCode)){
                                system.debug('---inside doc creation minor->>>>'+docCode);
                                NSIBPM__SR_Doc__c sdoc = createSRDoc(b.first_name__c+'-'+docName,srtmpdoc,b.id,srid);
                                mpuniqKeyDoc.put(locdocKey+docCode,sdoc);
                            }
                        }
                    }
                }
            }
        }
        
        if(mpuniqKeyDoc != null && !mpuniqKeyDoc.isempty()){
            system.debug('---mpuniqKeyDoc->>>>'+mpuniqKeyDoc.size());
            upsert mpuniqKeyDoc.values() Unique_SR_Doc_Name__c;
        }
    }
    
    public static NSIBPM__SR_Doc__c createSRDoc(String docName, NSIBPM__SR_Template_Docs__c SRTmpDoc , Id buyerid, id srID) {
        system.debug('---inside createSRDoc->>>>');
        NSIBPM__SR_Doc__c objSRDoc = new NSIBPM__SR_Doc__c();
        
        if (docName.length() > 80)
            docName = docName.subString(0, 79);
        objSRDoc.Name = docName;
        objSRDoc.NSIBPM__Service_Request__c = srID;
        objSRDoc.Buyer__c = buyerid;
        objSRDoc.NSIBPM__SR_Template_Doc__c = SRTmpDoc.Id;
        objSRDoc.NSIBPM__Unique_SR_Doc__c = SRTmpDoc.NSIBPM__Document_Master__r.Name + '_' + buyerid;
        objSRDoc.Unique_SR_Doc_Name__c = objSRDoc.NSIBPM__Unique_SR_Doc__c;        
        if(mpuniqSRDOCNamedocID.containsKey(objSRDoc.Unique_SR_Doc_Name__c)){
            objSRDoc.id = mpuniqSRDOCNamedocID.get(objSRDoc.Unique_SR_Doc_Name__c);
        }
        else{
            objSRDoc.NSIBPM__Status__c = 'Pending Upload';
            objSRDoc.NSIBPM__Document_Master__c = SRTmpDoc.NSIBPM__Document_Master__c;
            objSRDoc.NSIBPM__Group_No__c = SRTmpDoc.NSIBPM__Group_No__c;
            objSRDoc.NSIBPM__Is_Not_Required__c = SRTmpDoc.NSIBPM__Optional__c;
            objSRDoc.NSIBPM__Generate_Document__c = SRTmpDoc.NSIBPM__Generate_Document__c;
            objSRDoc.NSIBPM__Document_Description_External__c = SRTmpDoc.NSIBPM__Document_Description_External__c;
            objSRDoc.NSIBPM__Sys_IsGenerated_Doc__c = SRTmpDoc.NSIBPM__Generate_Document__c;
            objSRDoc.NSIBPM__From_Finalize__c = true;
        }
        system.debug('---objSRDoc->>>>'+objSRDoc);
        return objSRDoc;
        
    }
}