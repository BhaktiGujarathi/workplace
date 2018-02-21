global with sharing class InitialPageController{
global void InitialPageController() {
        //String startUrl = System.currentPageReference().getParameters().get('startURL');
        //return new PageReference(Site.getPrefix() + 'apex/CustomLogin' +EncodingUtil.urlEncode(startURL, 'UTF-8'));
    system.debug('Hi...');
    system.debug('@@@'+apexpages.currentPage().getURL()+'@@@'+apexpages.currentPage().getHeaders().get('HOST'));
      //return null;
        //return new PageReference( 'apex/CustomLogin?id=www');
    }
    public PageReference initMethod(){
    system.debug('Hi111...');
     system.debug('@@@Host@@@'+apexpages.currentPage().getURL()+'@@@'+apexpages.currentPage().getHeaders().get('HOST'));
     system.debug('@@@startURL@@@'+apexpages.currentPage().getURL()+'@@@'+System.currentPageReference().getParameters().get('startURL'));
    //return null;
    system.debug('1111'+Site.getPrefix());
    return new PageReference( 'https://'+apexpages.currentPage().getHeaders().get('HOST')+Site.getPrefix()+'/'+'apex/CustomCommunityLogin1?pid=www');
    }

}