public class OppAttachmentController { 
public Document__c docobj{get;set;}
public Boolean showAttachment{get;set;}
public Map<string,List<Attachment>> mapattach{get;set;} 
    public OppAttachmentController(){
        docobj = new Document__c();
        showAttachment = false;         
    }
    
    public void AttachmentsType(){
    mapattach = new Map<string,List<Attachment>>();
    if(docobj.Opportunity__c!= null){
            List<Attachment> athList;
            Map<Id,Document__c> documentobj = new Map<Id,Document__c>([Select id,Name,Opportunity__c,Category__c  from Document__c where Opportunity__c=:docobj.Opportunity__c]);
            List<Attachment> AttachmentObj = [Select id,Name,ParentId,ContentType from Attachment where ParentId in:documentobj.keySet()];
            for(Attachment att:AttachmentObj){
                Document__c dc = documentobj.get(att.ParentId);
                if(dc.Category__c!=null && dc.Category__c != '')
                {
                    if(mapattach.containsKey(dc.Category__c)){
                        mapattach.get(dc.Category__c).add(att);
                    } else {
                        athList = new List<Attachment>();
                        athList.add(att);
                        mapattach.put(dc.Category__c,athList);
                    }
                }
            } 
        }
        
            
        
        if(mapattach.size()>0){
            showAttachment = true;
        }else{
            showAttachment  = false;
            system.debug('insideelse>>>');
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.WARNING, 'No Documents found.');
                    ApexPages.addMessage(myMsg);      
        }
        system.debug(mapattach);
    }
    
    
}