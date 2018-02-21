public with sharing class VerificationActionLinkController {

    VerificationMaster__c[] verificationMaster = new VerificationMaster__c[]{};
    String verId = '';
    UWVerification__c[] ver = null;

    public VerificationActionLinkController(ApexPages.StandardController controller) {
        verId = ApexPages.currentpage().getParameters().get('vid');
        ver = [SELECT Id, VerificationMaster__c, Action_Link__c FROM UWVerification__c WHERE Id = :verId ];

        if (!ver.isEmpty()) {

            verificationMaster = [SELECT Id, Action_Link__c FROM VerificationMaster__c WHERE Id = :ver[0].VerificationMaster__c];    
        }
    }

    public PageReference goToUrl() {

        String query = '';
        String paramName = '';
        String[] params = new String[]{};
        String url = '';

        if (!verificationMaster.isEmpty()) {

            if (VerificationMaster[0].Action_Link__c != null) {

                url = String.valueOf(VerificationMaster[0].Action_Link__c);

                //Get URL params
                while (url.indexOf('{!') != -1) {

                    params.add(url.substring(url.indexOf('{') + 2, url.indexOf('}')));
                    url = url.substring(url.indexOf('}') + 1, url.length());
                }

                Map<String, Object> paramValue = new Map<String, Object>();

                //Load query
                if (!params.isEmpty()) {

                    query = 'SELECT ';
                    query += String.join(params, ',');
                    query += ' FROM UWVerification__c WHERE Id = \'' + verId + '\'';

                    UWVerification__c verification = (UWVerification__c)Database.query(query);

                   
                    //Create URL
                    for (String p : params) {
                      
                        paramValue.put(p, (Object)verification.get(p));
                    }

                    url = String.valueOf(VerificationMaster[0].Action_Link__c);


                    for (String param : params) {
                    
                        if (paramValue.get(param) != null) {
                    
                            url = url.replace('{!' + param + '}', String.valueOf(paramValue.get(param)));    
                        }
                        else {
                    
                            url = url.replace('{!' + param + '}', ''); 
                        }
                        
                    }
                }

                if (String.valueOf(verificationMaster[0].Action_Link__c).startsWith('http://') || String.valueOf(verificationMaster[0].Action_Link__c).startsWith('https://')) {

                    //System.assert(false, ' With ' + url );
                    return new PageReference(url);
                }
                else {

                    //System.assert(false, ' Without ' + url );
                    return new PageReference('http://' + url);
                }

            }

            //return null;
        }
        
        if (verId != null) {
            
            return new PageReference('/' + verId);
        }
        else {
            
            return new PageReference('/home/home.jsp');
        }
    }
}