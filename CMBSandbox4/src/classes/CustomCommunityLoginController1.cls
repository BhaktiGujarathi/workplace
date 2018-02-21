public with sharing class CustomCommunityLoginController1 {
    public String username  {get; set;}
    public String password  {get; set;}
    public boolean icon     {get; set;}
    public String url       {get; set;}
    
    public void CustomCommunityLoginController1(){
    }
    
    public void initMethod(){
        icon = true;
        url = 'https://'+apexpages.currentPage().getHeaders().get('HOST')+Site.getPrefix()+'/'+'apex/CustomCommunityLogin?pid=www';
    }
    
    public pageReference doLogin()
    {         
        if((username == '' || username == null) && (password == '' || password == null))
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter your Credentials.');
            ApexPages.addMessage(myMsg);
            return null;
        }
        if(password == '' || password == null)
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter your Password.');
            ApexPages.addMessage(myMsg);
            return null;
        }
        if(username == '' || username == null)
        {
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter your User Name.');
            ApexPages.addMessage(myMsg);
            return null;
        }        
        try{
            return Site.login(username,password,null);
        }catch(Exception e)
        {
            username='';
            password='';
            system.debug('@@@'+e);
            ApexPages.addMessages(e);
        }
        return null;
    }
    
    /*public pageReference contactUs(){
        
        system.debug('111111');
        system.debug('@@@111leadfName'+leadfName+'@@leadlName'+leadlName+'@@leademail'+leademail);
        if(leadfName == '' || leadlName == '' || leademail == ''){
            ApexPages.Message myMsg = new ApexPages.Message(ApexPages.Severity.ERROR,'Please enter your all information.');
            ApexPages.addMessage(myMsg);
            return null;
        }
        Lead lead = new Lead();
        lead.FirstName = leadfName;
        lead.LastName = leadlName;
        lead.Company = 'Fundigo';
        lead.Email = leademail;
        lead.Tip_of_the_Week__c = 'Added - Active';
        lead.LeadSource = 'Partner';
        lead.Status = 'Open - Hot';
        try{
            system.debug('@@LEAD'+lead);
            insert lead;
            
        }catch(Exception e){
                ApexPages.addMessages(e);
            }
        return null;
    }*/
}