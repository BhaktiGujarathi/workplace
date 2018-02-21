global class LightningForgotPasswordController {
    public LightningForgotPasswordController() { }
	
    @AuraEnabled
    public static String forgotPassowrd(String username, String checkEmailUrl) {
        Site.forgotPassword(username);
        ApexPages.PageReference checkEmailRef = new PageReference(checkEmailUrl);
        if(!Site.isValidUsername(username)) {
            return Label.Site.invalid_email;
        }
        if(String.isNotBlank(checkEmailUrl)){
        	aura.redirect(checkEmailRef);
        }
        return null;
    }
}