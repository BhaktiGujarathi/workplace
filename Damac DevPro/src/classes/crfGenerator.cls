public without sharing class crfGenerator {
    public Id caseId;
    public String recordtypeName;
    public String strSubject {get;set;}
    
    public void Generator(){
        String caseIdParameter = ApexPages.currentpage().getParameters().get('Id');
        if(caseIdParameter != null && caseIdParameter != ''){
            caseId = ApexPages.currentpage().getParameters().get('Id');
        }
        recordtypeName = ApexPages.currentpage().getParameters().get('recTypeName');
        system.debug('caseId*****'+caseId);
        system.debug('recordtypeName*****'+recordtypeName);
        generateDynamicContent();
    }
    
    public void generateDynamicContent(){
        strSubject = recordtypeName+' Request';
        system.debug('strSubject*****'+strSubject);
    }
}