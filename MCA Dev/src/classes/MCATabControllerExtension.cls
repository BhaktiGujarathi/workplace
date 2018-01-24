public with sharing class MCATabControllerExtension {
    Private String currentTabName = 'Submissions';
     public MCATabControllerExtension(ApexPages.StandardController controller) {

    }
    public void setSelectedTab (String n) {
        currentTabName = n;
    }

    public String getSelectedTab () {
        return currentTabName;
    }
    
    public void setActiveTab(){
        String para = ApexPages.CurrentPage().getParameters().get('tabname');        
        System.debug('current tab is ' + para);
    }
}