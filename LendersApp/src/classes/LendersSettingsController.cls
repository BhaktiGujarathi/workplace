public with sharing class LendersSettingsController {
	
    public String page {get; set;}
    public String iframeSource {get; set;}
    public List<ApexPage> pages = null;
   


    public LendersSettingsController() {
        
        iframeSource ='HomePage';
        pages = [SELECT Id, Name, NamespacePrefix FROM ApexPage];
    }

    public PageReference showSection() {
        
        if ( page == 'HomePage') {

            iframeSource = '/apex/' + page;
        }
        
        else {

            for ( ApexPage p : pages) {

                if (page == p.Name ) {

                    if (p.NamespacePrefix != null) {

                        iframeSource = '/apex/' + p.NamespacePrefix + '__' + p.Name;    
                        return null;
                    }
                    else {
                        
                        iframeSource = '/apex/' + p.Name;
                        return null;
                    }
                    
                    
                    
                }            
            }

            iframeSource = '/apex/NotInstalledPage';
            return null;
        }

        return null;
    }
}