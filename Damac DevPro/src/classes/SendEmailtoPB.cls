global without sharing class SendEmailtoPB implements NSIBPM.CustomCodeExecutable {
        public String EvaluateCustomCode(NSIBPM__Service_Request__c SR, NSIBPM__Step__c step){
            String retStr = 'Success';
            try{
                NSIBPM__Service_Request__c objSR = SRUtility.getSRDetails(step.NSIBPM__SR__c);
                if(objSR.NSIBPM__Record_Type_Name__c == 'Deal'){
                    sendEmailtoPB(objSR.id,step.id);
                }
                return retstr;
            }
            catch(exception ex){
                return ex.getMessage();
            }
            
        }
        
        public static void sendEmailtoPB(id srid,id stpid){
            Savepoint sp = Database.setSavepoint();
            try{
                Map<Id,Booking_Unit__c> mpBU = new Map<Id,Booking_Unit__c>();
                Map<string,integer> mpGCClist = new Map<string,integer>();
                
                Set<string> stEmailNames = new Set<string>{'SPAEmailArabic1','SPAEmailChinese1','SPAEmailEnglish1','SPAEmailRussian1','SPAEmailNonDubai1'};
                    //Get all GCC Countries
                    for(string strGCC : string.valueof(Label.BuyerNationalityGCCList).split(',')){
                        mpGCClist.put(strGCC.tolowercase(),1);
                    }
                
                Map<string,EmailTemplate> mpEmailTemplate = new Map<string,EmailTemplate>();
                for(EmailTemplate et : [SELECT Id,HTMLValue,Body,Name,subject FROM EmailTemplate WHERE name in : stEmailNames]){
                    mpEmailTemplate.put(et.name,et);
                }
                
                Map<Id,EmailTemplate> mpBUIDEmailTemplateID = new Map<Id,EmailTemplate>();
                Map<Id,Id> mpBUIDSRDocID = new Map<Id,ID>();
                //Get all Booking Units 
                for(Booking_Unit__c BU : [select id,name,Primary_Buyer_s_Email__c,Related_Promotion__c,Primary_Buyer_s_Nationality__c,Inventory__c,Inventory__r.Property_Country__c,Inventory__r.Property_City__c,Primary_Buyer_s_Name__c,Unit_Location__c,(select id,name,NSIBPM__Document_Master__c,NSIBPM__Document_Master__r.Promotion_Letter__c,Doc_View_URL__c from SR_Docs__r where Booking_Unit__c != null and Docs_to_be_sent__c = true) from Booking_Unit__c where Booking__r.Deal_SR__c =: srid and Status__c !='Removed'])
                {
                    mpBU.put(bu.id,BU);
                    //Email will be sent only if nationality and inventory not null
                    if(BU.Primary_Buyer_s_Nationality__c != null && BU.Inventory__c != null && BU.Inventory__r.Property_City__c != null){
                        //if inventory > property city is dubai
                        system.debug('--inv city-> '+BU.Inventory__r.Property_City__c.tolowercase());
                        if(BU.Inventory__r.Property_City__c.tolowercase() == 'dubai'){
                            boolean isGCC = false;
                            boolean isPromo = false;
                            //if gcc
                            if(mpGCClist.containskey(BU.Primary_Buyer_s_Nationality__c.tolowercase())){
                                isGCC = true;
                            }
                            if(BU.Related_Promotion__c != null){
                                isPromo = true;
                                system.debug('--inside-> promo');
                                system.debug('--srdoc-> '+BU.id+'  --  '+BU.SR_Docs__r);
                                for(NSIBPM__SR_Doc__c srdoc : BU.SR_Docs__r){
                                    system.debug('--srdoc-> '+srdoc.id);
                                    system.debug('--srdoc-> '+srdoc.NSIBPM__Document_Master__c);
                                    system.debug('--srdoc-> '+srdoc.NSIBPM__Document_Master__r.Promotion_Letter__c);
                                    if(srdoc.NSIBPM__Document_Master__c != null && srdoc.NSIBPM__Document_Master__r.Promotion_Letter__c){
                                    	mpBUIDSRDocID.put(BU.id,srdoc.id);
                                    }
                                }
                                system.debug('--mpBUIDSRDocID-> '+mpBUIDSRDocID);
                            }
                            system.debug('--isPromo isGCC-> '+isGCC+'  ---   '+isPromo);
                            for(string strEmailName : mpEmailTemplate.keyset()){
                                if(isGCC){
                                    if(strEmailName.tolowercase().contains('arabic')){
                                        mpBUIDEmailTemplateID.put(BU.id,mpEmailTemplate.get(strEmailName));
                                    }
                                }else{
                                    if(strEmailName.tolowercase().contains(BU.Primary_Buyer_s_Nationality__c.tolowercase())){
                                        mpBUIDEmailTemplateID.put(BU.id,mpEmailTemplate.get(strEmailName));
                                    }
                                    
                                }
                            }
                            if((!mpBUIDEmailTemplateID.containskey(BU.id))){
                                mpBUIDEmailTemplateID.put(BU.id,mpEmailTemplate.get('SPAEmailEnglish1'));
                            }
                        }
                        else{
                            mpBUIDEmailTemplateID.put(bu.id,mpEmailTemplate.get('SPAEmailNonDubai1'));
                        }
                    }
                }
                
                Map<Id,List<Messaging.Emailfileattachment>> fileAttachments = new Map<Id,List<Messaging.Emailfileattachment>>();
                if(mpBUIDSRDocID != null && !mpBUIDSRDocID.isempty()){
                    set<id> stSrDocIds = new set<id>();
                    stSrDocIds.addall(mpBUIDSRDocID.values());
                    system.debug('-->ParentEmailid '+stSrDocIds);
                    for (Attachment a : [select Name, Body, BodyLength ,parentid from Attachment where parentid in : stSrDocIds])
                    {
                        List<Messaging.Emailfileattachment> lstefa = new List<Messaging.Emailfileattachment>();
                        Messaging.Emailfileattachment efa = new Messaging.Emailfileattachment();
                        efa.setFileName(a.Name);
                        efa.setBody(a.Body);
                        lstefa.add(efa);
                        fileAttachments.put(a.parentid,lstefa);
                    }
                }
                system.debug('--fileAttachments-> '+fileAttachments.size());
                system.debug('--mpBUIDEmailTemplateID-> '+mpBUIDEmailTemplateID.keyset()+'  ---  '+mpBUIDEmailTemplateID+'  ----  '+mpBUIDEmailTemplateID.size());
                system.debug('--mpEmailTemplate-> '+mpEmailTemplate.size());
                List<contact> lstcontact = new list<contact>();
                if(mpBU != null && !mpBU.isempty()){
                    for(Booking_Unit__c bu : mpBU.values()){
                        contact c = new contact();
                        c.firstname = bu.Primary_Buyer_s_Name__c;
                        c.lastname = bu.Primary_Buyer_s_Name__c;
                        c.email = bu.Primary_Buyer_s_Email__c;
                        lstcontact.add(c);
                    }
                    insert lstcontact;
                    system.debug('---->lstcontact'+lstcontact.size());
                    Map<string,contact> mpcontactUniq = new Map<string,contact>();
                    for(contact c : lstcontact){
                        mpcontactUniq.put(c.Email+c.FirstName,c);
                    }
                    system.debug('---->mpcontactUniq'+mpcontactUniq.size());
                    List<Messaging.SingleEmailMessage>  lstemail = new List<Messaging.SingleEmailMessage>();
                    //EmailTemplate emailDetails = [SELECT Id,HTMLValue,Body,Name,subject FROM EmailTemplate WHERE name = 'BookingUnitSRDoc'];
                    Messaging.SingleEmailMessage email = new Messaging.SingleEmailMessage();
                    for(Booking_Unit__c bu : mpBU.values()){
                        string localkey = bu.Primary_Buyer_s_Email__c+bu.Primary_Buyer_s_Name__c;
                        if(localkey == null || localkey == '' || !mpcontactUniq.containskey(localkey) || !mpBUIDEmailTemplateID.containskey(bu.id)){
                            continue;
                        }
                        EmailTemplate emailDetails = mpBUIDEmailTemplateID.get(bu.id);
                        String stremailBody = emailDetails.HTMLValue;
                        String strTextBody = emailDetails.Body;                        
                        email = new Messaging.SingleEmailMessage();                        
                        email.setTargetObjectId(mpcontactUniq.get(localkey).id);
                        email.setSubject(emailDetails.subject.replace('{BUName}',bu.Unit_Location__c));
                        string strLinksHTML = '';
                        string strLinksText = '';
                        if(mpBUIDSRDocID.containskey(bu.id)){
                            email.setFileAttachments(fileAttachments.get(mpBUIDSRDocID.get(bu.id)));
						}
                        
                        for(NSIBPM__SR_Doc__c doc : bu.SR_Docs__r){
                            if(doc.NSIBPM__Document_Master__c != null && doc.NSIBPM__Document_Master__r.Promotion_Letter__c){
                                continue;
                            }
                            strLinksHTML += '<a href="'+doc.Doc_View_URL__c+'">'+doc.name+'</a><br/>';
                            strLinksText += '<'+doc.Doc_View_URL__c +'>';
                        }
                        system.debug('---->strLinks'+strLinksText+strLinksHTML+stremailBody+strTextBody);
                        string htmlbdy = stremailBody;
                        if(htmlbdy != null){
                            htmlbdy = htmlbdy.replace('{Name}',mpcontactUniq.get(localkey).firstname);
                            htmlbdy = htmlbdy.replace('{BUName}',bu.Unit_Location__c);
                            htmlbdy = htmlbdy.replace('{PutLinks}',strLinksHTML);
                            email.setHtmlBody(htmlbdy);
                            system.debug('---->htmlbdy'+htmlbdy);
                        }
                        string txtBdy = strTextBody;
                        if(txtBdy != null){
                            txtBdy = txtBdy.replace('{Name}',mpcontactUniq.get(localkey).firstname);
                            txtBdy = txtBdy.replace('{BUName}',bu.Unit_Location__c);
                            txtBdy = txtBdy.replace('{PutLinks}',strLinksText);
                            system.debug('---->txtBdy'+txtBdy);
                            email.setPlainTextBody(txtBdy);
                        }
                        email.setSaveAsActivity(false);
                        email.setcharset('UTF-8');
                        email.setSenderDisplayName('DAMAC Sales Support');
                        lstemail.add(email);
                        system.debug('---->lstemail'+lstemail.size());
                    }
                    Messaging.sendEmail(lstemail);
                    delete lstcontact;
                    closestep(stpid);
                }
            }
            catch(exception ex){
                Database.rollback( sp );
                system.debug('-Exception-->'+ex.getmessage());
            }
        }
        
        public static void closestep(id stepID){
            if(stepID != null){
                NSIBPM__Step__c stp = [select id,NSIBPM__Status__r.Name,NSIBPM__SR_Step__c from NSIBPM__Step__c where id =: stepID];
                map<id,NSIBPM__Step_Transition__c> mapStepTransition = new map<id,NSIBPM__Step_Transition__c>();
                for(NSIBPM__Step_Transition__c trans:[select NSIBPM__From__c,NSIBPM__To__c,NSIBPM__Transition__c,NSIBPM__Transition__r.NSIBPM__To__c,NSIBPM__SR_Step__c,NSIBPM__SR_Status_External__c,NSIBPM__SR_Status_Internal__c from NSIBPM__Step_Transition__c where NSIBPM__Transition__c!=null and NSIBPM__From__c=:stp.NSIBPM__Status__r.Name and NSIBPM__SR_Step__c=:stp.NSIBPM__SR_Step__c and IsDeleted=false]){
                    mapStepTransition.put(trans.NSIBPM__Transition__r.NSIBPM__To__c,trans);
                }
                for(NSIBPM__Status__c objstat:[Select Id,Name,NSIBPM__Type__c,NSIBPM__Rejection__c,NSIBPM__SR_Closed_Status__c,NSIBPM__Code__c from NSIBPM__Status__c where ID!=null and ID IN:mapStepTransition.keyset() and IsDeleted=false and NSIBPM__Type__c = 'End']){
                    stp.NSIBPM__Status__c = objstat.id;
                    update stp;
                    break;
                }
            }
        }
    }