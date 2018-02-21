public class DamacLandingPageController {
    
    public DamacLandingPageController(){
        
    }
    
    public PageReference redirectToHome(){
        if(UserInfo.getUserType() != 'Guest'){
            return new PageReference('/Damac_Home');
        }
        else{
            return new PageReference('/Damac_Login');
        }

    }

}